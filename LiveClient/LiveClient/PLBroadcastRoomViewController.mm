//
//  PLBroadcastRoomViewController.m
//  PLLiveCourse
//
//  Created by 小布丁 on 2017/2/14.
//  Copyright © 2017年 小布丁. All rights reserved.
//

#import "PLBroadcastRoomViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "X264Manager.h"
#import "H264SendHelper.h"

#ifdef __cplusplus
extern "C" {
#endif
    
#ifdef __cplusplus
};
#endif


#import "AACEncoder.h"

#define CAPTURE_FRAMES_PER_SECOND       20
#define SAMPLE_RATE                     44100
#define WIDTH                           self.view.bounds.size.width
#define HEIGHT                          self.view.bounds.size.height

@interface PLBroadcastRoomViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate,
    NSStreamDelegate,H264SendHelperConnectionDelegate>{
    
    AVCaptureVideoPreviewLayer *_previewLayer;
//    AVCaptureVideoDataOutput *_videoOutput;
    dispatch_queue_t _videoQueue;
    dispatch_queue_t _audioQueue;
    AVCaptureConnection *_videoConnection;
    AVCaptureConnection *_audioConnection;
    AVCaptureDeviceInput *_currentVideoDeviceInput;
    
    BOOL _isClosed;
    dispatch_queue_t                    _encodeQueue;
    FILE                                * aacHandle;
}

@property (nonatomic, strong) NSString   *aacFile;
@property (nonatomic, strong) AACEncoder *aacEncoder;
@property (nonatomic, strong) NSInputStream *inputStream;
@property (nonatomic, strong) X264Manager * manager264;
@property (nonatomic, weak) UIImageView *focusCursorImageView;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) H264SendHelper *sendHelper;
@property (nonatomic, strong) NSDateFormatter       *formatter;

@end

@implementation PLBroadcastRoomViewController

- (NSDateFormatter *)formatter {
    if (!_formatter) {
        _formatter = [[NSDateFormatter alloc] init];
        _formatter.dateFormat = @"YYYYMMdd";
    }
    
    return _formatter;
}

- (int)initPoutACC {
    _aacFile = [self savedFilePathStr];
    
    NSUInteger len = [_aacFile length];
    char *filepath = (char*)malloc(sizeof(char) * (len + 1));
    
    [_aacFile getCString:filepath maxLength:len + 1 encoding:[NSString defaultCStringEncoding]];
    
    aacHandle = NULL;
    aacHandle = fopen(filepath, "wb");
    //Check
    if(aacHandle==NULL){
        free(filepath);
        printf("Error open files.n");
        return -1;
    }
    
    free(filepath);
    return 0;
}

- (X264Manager *)manager264 {
    if (!_manager264) {
        //初始化编码器
        _manager264 = [X264Manager defaultManager];
    }
    return _manager264;
}

- (H264SendHelper *)sendHelper {
    if (!_sendHelper) {
        _sendHelper = [H264SendHelper defaultH264SendHelper];
        _sendHelper.delegate = self;
    }
    
    return _sendHelper;
}

- (void)dealloc
{
    fclose(aacHandle);
    aacHandle = NULL;
    
    [self stopCarmera];

    [_previewLayer removeFromSuperlayer];
    _previewLayer = nil;
    _captureSession = nil;
}

/**
 *  懒加载聚焦视图
 *
 */
- (UIImageView *)focusCursorImageView
{
    if (_focusCursorImageView == nil) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"focus"]];
        _focusCursorImageView = imageView;
        [self.view addSubview:_focusCursorImageView];
    }
    return _focusCursorImageView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    _encodeQueue = dispatch_queue_create("encodeQueue", DISPATCH_QUEUE_SERIAL);
//    //添加发转相机按钮
//    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithCustomView:({
//        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 30)];
//        [btn setImage:[UIImage imageNamed:@"camera_switch"] forState:UIControlStateNormal];
//        [btn addTarget:self action:@selector(swapFrontAndBackCameras) forControlEvents:UIControlEventTouchUpInside];
//        btn;
//    })];
    
//    self.navigationItem.rightBarButtonItem = rightBtn;
    
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    _captureSession = session;
    
    [self requireDevicePermissionWithComplete:^(BOOL granted) {
        if (granted) {
            [self startCamera];
            
            //获取设备权限，此时显示出 preview
            _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_captureSession];
            _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill; // 设置预览时的视频缩放方式
            
            _previewLayer.frame = CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height-64);
            [[_previewLayer connection] setVideoOrientation:AVCaptureVideoOrientationPortrait]; // 设置视频的朝向
            
            [self.view.layer addSublayer:_previewLayer];
        }
    }];
}

- (void)requireDevicePermissionWithComplete:(void (^)(BOOL granted))complete{
    NSString * mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus  authorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    
    if (authorizationStatus == AVAuthorizationStatusRestricted|| authorizationStatus == AVAuthorizationStatusDenied) {
        UIAlertController * alertC = [UIAlertController alertControllerWithTitle:@"摄像头访问受限" message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction * action = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [self.navigationController popViewControllerAnimated:YES];
        }];
        [alertC addAction:action];
        
        [self presentViewController:alertC animated:YES completion:nil];
        
        complete(NO);
        
    }else if(authorizationStatus == AVAuthorizationStatusAuthorized || authorizationStatus == AVAuthorizationStatusNotDetermined){
        //检测麦克风功能是否打开
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            if (!granted)
            {
                [MBProgressHUD showError:@"没有权限使用麦克风。" toView:self.view];
            }else{
                [self setupAudioCapture];
            }
        }];
        
        complete(YES);
    }
}

#pragma mark
#pragma mark - 设置音频 capture
- (void) setupAudioCapture {
    _aacEncoder = [[AACEncoder alloc] init];
    //创建 acc 文件
    [self initPoutACC];
    // create capture device with video input
    
    /*
     * Create audio connection
     */
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    NSError *error = nil;
    AVCaptureDeviceInput *audioInput = [[AVCaptureDeviceInput alloc] initWithDevice:audioDevice error:&error];
    if (error) {
        
        NSLog(@"Error getting audio input device: %@", error.description);
        return;
    }
    if ([_captureSession canAddInput:audioInput]) {
        [_captureSession addInput:audioInput];
    }
    
    _audioQueue = dispatch_queue_create("Audio Capture Queue", DISPATCH_QUEUE_SERIAL);
    AVCaptureAudioDataOutput* audioOutput = [[AVCaptureAudioDataOutput alloc] init];
    [audioOutput setSampleBufferDelegate:self queue:_audioQueue];
    
    if ([_captureSession canAddOutput:audioOutput]) {
        [_captureSession addOutput:audioOutput];
    }
    _audioConnection = [audioOutput connectionWithMediaType:AVMediaTypeAudio];
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position
{
    AVCaptureDeviceDiscoverySession *deviceDiscoverySession = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInDualCamera,AVCaptureDeviceTypeBuiltInTelephotoCamera,AVCaptureDeviceTypeBuiltInWideAngleCamera] mediaType:AVMediaTypeVideo position:position];
    
    NSArray *devices = [deviceDiscoverySession devices];
    for ( AVCaptureDevice *device in devices )
        if ( device.position == position )
            return device;
    return nil;
}

//设备的前后切换 Switching Between Devices
- (void)swapFrontAndBackCameras {
    // Assume the session is already running
//    NSArray *inputs = _captureSession.inputs;
//    for ( AVCaptureDeviceInput *input in inputs ) {
//        AVCaptureDevice *device = input.device;
        AVCaptureDevice *device = _currentVideoDeviceInput.device;
        if ( [device hasMediaType:AVMediaTypeVideo] ) {
            AVCaptureDevicePosition position = device.position;
            AVCaptureDevice *newCamera = nil;
            AVCaptureDeviceInput *newInput = nil;
            
            if (position == AVCaptureDevicePositionFront)
                newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
            else
                newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
            
            NSError *error = nil;
            newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:&error];
            if (!error) {
                // beginConfiguration ensures that pending changes are not applied immediately
                [_captureSession beginConfiguration];
                
                [_captureSession removeInput:_currentVideoDeviceInput];
                [_captureSession addInput:newInput];
                
                // Changes take effect once the outermost commitConfiguration is invoked.
                [_captureSession commitConfiguration];
                
                _currentVideoDeviceInput = newInput;
            }
//            break;
        }
//    }
}

#pragma mark
#pragma mark - 设置视频 capture
- (void) setupVideoCaprure
{
    NSError *deviceError;
    
    AVCaptureDevice *cameraDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    AVCaptureDeviceInput *inputDevice = [AVCaptureDeviceInput deviceInputWithDevice:cameraDevice error:&deviceError];
    if (deviceError) {
        return;
    }
    _currentVideoDeviceInput = inputDevice;
    // make output device
    
    AVCaptureVideoDataOutput *outputDevice = [[AVCaptureVideoDataOutput alloc] init];

    NSString* key = (NSString*)kCVPixelBufferPixelFormatTypeKey;
    
    //Nv12 kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange
    //i420 kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
    NSNumber* val = [NSNumber
                     numberWithUnsignedInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange];
    NSDictionary* videoSettings =
    [NSDictionary dictionaryWithObject:val forKey:key];
    
    NSError *error;
    [cameraDevice lockForConfiguration:&error];
    if (error == nil) {
        // handle error2
    }
    NSLog(@"cameraDevice.activeFormat.videoSupportedFrameRateRanges IS %@",[cameraDevice.activeFormat.videoSupportedFrameRateRanges objectAtIndex:0]);
    
    if (cameraDevice.activeFormat.videoSupportedFrameRateRanges){
        
        [cameraDevice setActiveVideoMinFrameDuration:CMTimeMake(1, CAPTURE_FRAMES_PER_SECOND)];
        [cameraDevice setActiveVideoMaxFrameDuration:CMTimeMake(1, CAPTURE_FRAMES_PER_SECOND)];
    }
    
    [cameraDevice unlockForConfiguration];
    
    
    // Start the session running to start the flow of data
    
    outputDevice.videoSettings = videoSettings;
    
    // 注意：队列必须是串行队列，才能获取到数据，而且不能为空
    dispatch_queue_t videoQueue = dispatch_queue_create("Video Capture Queue", DISPATCH_QUEUE_SERIAL);
    
    [outputDevice setSampleBufferDelegate:self queue:videoQueue];
    _videoQueue = videoQueue;
    
    // initialize capture session
    
    if ([_captureSession canAddInput:inputDevice]) {
        [_captureSession addInput:inputDevice];
    }
    if ([_captureSession canAddOutput:outputDevice]) {
        [_captureSession addOutput:outputDevice];
    }
    
    // begin configuration for the AVCaptureSession
    [_captureSession beginConfiguration];
    
    // picture resolution
    //[_captureSession canSetSessionPreset:AVCaptureSessionPreset1280x720]
    if ([_captureSession canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
        [_captureSession setSessionPreset:AVCaptureSessionPreset1280x720];
    }else{
        [_captureSession setSessionPreset:[NSString stringWithString:AVCaptureSessionPreset640x480]];
    }
    
    _videoConnection = [outputDevice connectionWithMediaType:AVMediaTypeVideo];
    
    //Set landscape (if required)
    if ([_videoConnection isVideoOrientationSupported])
    {
        AVCaptureVideoOrientation orientation = AVCaptureVideoOrientationPortrait;        ///<SET VIDEO ORIENTATION IF LANDSCAPE
        [_videoConnection setVideoOrientation:orientation];
    }
    
    [_captureSession commitConfiguration];
}

#pragma mark
#pragma mark - 视频 sps 和 pps
- (void)gotSpsPps:(NSData*)sps pps:(NSData*)pps
{
    const char bytes[] = "\x00\x00\x00\x01";
    size_t length = (sizeof bytes) - 1; //string literals have implicit trailing '\0'
    NSData *ByteHeader = [NSData dataWithBytes:bytes length:length];
//    [_fileHandle writeData:ByteHeader];
//    [_fileHandle writeData:sps];
//    [_fileHandle writeData:ByteHeader];
//    [_fileHandle writeData:pps];
}

#pragma mark
#pragma mark - 视频数据回调
- (void)gotEncodedData:(NSData*)data isKeyFrame:(BOOL)isKeyFrame
{
    NSLog(@"Video data (%lu): %@", (unsigned long)data.length, data.description);
    
//    if (_fileHandle != NULL)
//    {
//        const char bytes[] = "\x00\x00\x00\x01";
//        size_t length = (sizeof bytes) - 1; //string literals have implicit trailing '\0'
//        NSData *ByteHeader = [NSData dataWithBytes:bytes length:length];
//        
//#pragma mark
//#pragma mark - 视频数据(data)
//        
//        [_fileHandle writeData:ByteHeader];
//        [_fileHandle writeData:data];
//
//    }
}

#pragma mark
#pragma mark - 录制
- (void) startCamera
{
    //连接服务器
    [self.sendHelper startConnect];
    [self setupVideoCaprure];
    
    [self.manager264 startEncoder:WIDTH height:HEIGHT];
    [_captureSession startRunning];
}

- (void) stopCarmera
{
    [_captureSession stopRunning];
    [_sendHelper disConnection];
    _sendHelper = nil;
    //释放编码资源
    [_manager264 freeX264Resource];
    _manager264 = nil;
}

//- (void)sendPacketUseFFMPEG:(NSString *)x264File {
//    //ffmpeg -re -i chunwan.h264 -vcodec copy -f h264 udp://233.233.233.223:6666
//    int argc = 8;
//    char **arguments = &(calloc(argc, sizeof(char*)));
//    if(arguments != NULL)
//    {
//        arguments[0] = (char *)"-re";
//        arguments[1] = (char *)"-i";
//        arguments[2] = (char *)[x264File cStringUsingEncoding:NSUTF8StringEncoding];
//        arguments[3] = (char *)"-vcodec";
//        arguments[4] = (char *)"copy";
//        arguments[5] = (char *)"-f";
//        arguments[6] = (char *)"h264";
//        NSString *desAddr = RTPAddr;
//        arguments[7] = (char *)[desAddr cStringUsingEncoding:NSUTF8StringEncoding];
//        ffmpeg_main(argc, arguments);
//    }
//}

#pragma -mark 聚焦光标
// 点击屏幕，出现聚焦视图
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    // 获取点击位置
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];
    
    // 把当前位置转换为摄像头点上的位置
    CGPoint cameraPoint = [_previewLayer captureDevicePointOfInterestForPoint:point];
    
    // 设置聚焦点光标位置
    [self setFocusCursorWithPoint:point];
    
    // 设置聚焦
    [self focusWithMode:AVCaptureFocusModeAutoFocus exposureMode:AVCaptureExposureModeAutoExpose atPoint:cameraPoint];
}

/**
 *  设置聚焦光标位置
 *
 *  @param point 光标位置
 */
-(void)setFocusCursorWithPoint:(CGPoint)point{
    
    self.focusCursorImageView.center=point;
    self.focusCursorImageView.transform=CGAffineTransformMakeScale(1.5, 1.5);
    self.focusCursorImageView.alpha=1.0;
    [UIView animateWithDuration:1.0 animations:^{
        self.focusCursorImageView.transform=CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        self.focusCursorImageView.alpha=0;
        
    }];
}

/**
 *  设置聚焦
 */
-(void)focusWithMode:(AVCaptureFocusMode)focusMode exposureMode:(AVCaptureExposureMode)exposureMode atPoint:(CGPoint)point{
    
    AVCaptureDevice *captureDevice = _currentVideoDeviceInput.device;
    // 锁定配置
    [captureDevice lockForConfiguration:nil];
    
    // 设置聚焦
    if ([captureDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        [captureDevice setFocusMode:AVCaptureFocusModeAutoFocus];
    }
    if ([captureDevice isFocusPointOfInterestSupported]) {
        [captureDevice setFocusPointOfInterest:point];
    }
    
    // 设置曝光
    if ([captureDevice isExposureModeSupported:AVCaptureExposureModeAutoExpose]) {
        [captureDevice setExposureMode:AVCaptureExposureModeAutoExpose];
    }
    if ([captureDevice isExposurePointOfInterestSupported]) {
        [captureDevice setExposurePointOfInterest:point];
    }
    
    // 解锁配置
    [captureDevice unlockForConfiguration];
}

#pragma -mark NSStreamDelegate
- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode{
    switch (eventCode) {
        case NSStreamEventOpenCompleted:
            break;
            
        case NSStreamEventErrorOccurred:
            NSLog(@"NSStreamEventErrorOccureed: error when reading file");
            break;
            
        case NSStreamEventEndEncountered: {
            //handle last part of data
            [self.inputStream close];
//            [self.connect sayByebye];
            break;
        }
            
        case NSStreamEventHasBytesAvailable: {
            NSMutableData *buffer = [[NSMutableData alloc] initWithLength:4 * 1024];
            NSUInteger length = (NSUInteger)[self.inputStream read:(uint8_t *)[buffer mutableBytes] maxLength:[buffer length]];
            
            if (length > 0) {
                [buffer setLength:length];
//                [self obj_enumerateComponentsSeparatedBy:buffer usingBlock:^(NSData *data) {
//                    [self.connect writeData:data timeout:-1 tag:0];
//                }];
            }
            break;
        }
            
        default:
            break;
    }
}

- (void)obj_enumerateComponentsSeparatedBy:(NSData *)delimiter usingBlock:(void(^)(NSData *data))block{
//    NSUInteger location = 0;
    
//    while (YES) {
        //get a new component separated by delimiter
//        NSRange rangeOfDelimiter = [delimiter rangeOfData:delimiter
//                                             options:0
//                                               range:NSMakeRange(location,delimiter.length  - location)];
    
        //has reached the last component
//        if (rangeOfDelimiter.location == NSNotFound) {
//            break;
//        }
        
//        NSRange rangeOfNewComponent = NSMakeRange(location, rangeOfDelimiter.location - location + delimiter.length);
//        //get the data of every component
//        NSData *everyComponent = [delimiter subdataWithRange:rangeOfNewComponent];
//        //invoke the block
//        block(everyComponent);
//        //make the offset of location
//        location = NSMaxRange(rangeOfNewComponent);
//    }
    
    //reminding data
//    NSData *reminder = [reminder subdataWithRange:NSMakeRange(location, reminder.length - location)];
//    //handle reminding data
//    block(reminder);
}

#pragma -mark
- (void) captureOutput:(AVCaptureOutput *)captureOutput
 didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
        fromConnection:(AVCaptureConnection *)connection
{
//    CMTime pts = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
//    double dPTS = (double)(pts.value) / pts.timescale;
    
//    NSLog(@"DPTS is %f",dPTS);
    // 这里的sampleBuffer就是采集到的数据了，但它是Video还是Audio的数据，得根据connection来判断
    if (connection == _videoConnection) {  // Video
        /*
         // 取得当前视频尺寸信息
         CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
         int width = CVPixelBufferGetWidth(pixelBuffer);
         int height = CVPixelBufferGetHeight(pixelBuffer);
         NSLog(@"video width: %d  height: %d", width, height);
         */
//        NSLog(@"在这里获得video sampleBuffer，做进一步处理（编码H.264）");

        __weak typeof(self) ws = self;
        if([_manager264 canEncode]){
            [_manager264 encoderToH264:sampleBuffer compeleteBlock:^(NSString *path, long tag, NSTimeInterval durate) {
                
                [ws.sendHelper sendPacketWithPath:path withACCPath:self.aacFile withDuration:durate];
                fclose(aacHandle);
                aacHandle = NULL;
                
                [self initPoutACC];
            }];
        }
    }else if (connection == _audioConnection) {  // Audio
//        NSLog(@"这里获得audio sampleBuffer，做进一步处理（编码AAC）");
        [_aacEncoder encodeSampleBuffer:sampleBuffer completionBlock:^(NSData *encodedData, NSError *error) {
            if (encodedData) {
//                NSLog(@"Audio data (%lu): %@", (unsigned long)encodedData.length, encodedData.description);
//        #pragma mark
//        #pragma mark -  音频数据(encodedData)
                if(aacHandle){
                    fwrite((void *)[encodedData bytes], encodedData.length, 1, aacHandle);
                }
                
            } else {
                        NSLog(@"Error encoding AAC: %@", error);
            }
        }];
    }
}


#pragma -mark 
- (void)ConnecedCallback {
    
}

- (void)disConnecedCallback {
    [self.manager264 stopEncode];
    [self.aacEncoder stopAccEncode];
}

#pragma -mark savedFile
// 当前系统时间
- (NSString* )nowTime2String
{
    NSString *date = nil;
    
    date = [self.formatter stringFromDate:[NSDate date]];
    return date;
}

- (NSString *)savedFileName
{
    NSString *filename = [NSString stringWithFormat:@"%@%d",[self nowTime2String],arc4random() % 10000];
    return [filename stringByAppendingString:@".acc"];
}

- (NSString *)savedFilePathStr {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *directory = [documentsDirectory stringByAppendingPathComponent:@"SmartKiller"];
    
    NSString *fileName = [self savedFileName];
    
    NSString *writablePath = [directory stringByAppendingPathComponent:fileName];
    
    return writablePath;
}
- (char *)savedFilePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *directory = [documentsDirectory stringByAppendingPathComponent:@"SmartKiller"];
    
    NSString *fileName = [self savedFileName];
    
    NSString *writablePath = [directory stringByAppendingPathComponent:fileName];
    
    return [self nsstring2char:writablePath];
}

- (char*)nsstring2char:(NSString *)path
{
    NSUInteger len = [path length];
    char *filepath = (char*)malloc(sizeof(char) * (len + 1));
    
    [path getCString:filepath maxLength:len + 1 encoding:[NSString defaultCStringEncoding]];
    
    return filepath;
}
@end
