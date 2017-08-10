//
//  SMAVPlayerViewController.m
//  LiveClient
//
//  Created by 小布丁 on 2017/3/11.
//  Copyright © 2017年 小布丁. All rights reserved.
//

#import "SMAVPlayerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "SMSliderBar.h"
#import "UIImage+GIF.h"
#import "VideoAssetUrlLoader.h"
#import "LCFileHandle.h"

#import <MediaPlayer/MediaPlayer.h>

#define ScreenHeight [[UIScreen mainScreen] bounds].size.height
#define ScreenWidth [[UIScreen mainScreen] bounds].size.width

@interface SMAVPlayerViewController ()<SMSliderDelegate, VideoAssetUrlLoaderDelegate> {
    UIInterfaceOrientation _currentOrientation;
    float _width, _height;
}

@property (strong, nonatomic) AVPlayerLayer *playerLayer;
@property (weak, nonatomic) IBOutlet UIView *viewHead;   //35 35 35            //显示返回按钮View
@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewLogin;   //加载image
@property (weak, nonatomic) IBOutlet UIView *viewAvPlayer;          //播放视图
@property (weak, nonatomic) IBOutlet SMSliderBar *sliderBar;  //进度条

@property (weak, nonatomic) IBOutlet UIView *viewBottom;            //底部控制view
@property (weak, nonatomic) IBOutlet UIButton *btnPause;            //暂停播放按钮
@property (weak, nonatomic) IBOutlet UIButton *btnNetx;             //下一个按钮
@property (weak, nonatomic) IBOutlet UIButton *btnFullScreen;       //全屏按钮

@property (weak, nonatomic) IBOutlet UILabel *labelTimeNow;         //当前时间label
@property (weak, nonatomic) IBOutlet UILabel *labelTimeTotal;       //总时间label
@property (strong, nonatomic) AVPlayer *player;                     //播放器对象
@property (strong, nonatomic) id timeObserver;                      //视频播放时间观察者
@property (assign, nonatomic) double totalTime;                      //视频总时长
@property (assign, nonatomic) BOOL isBottomViewHide;                //底部的view是否隐藏
@property (assign, nonatomic) NSInteger subscript;                  //数组下标，记录当前播放视频
@property (assign, nonatomic) NSUInteger currentTime;                //当前视频播放时间位置
@property (nonatomic, strong) NSString *subTitile;
@property (nonatomic, assign) PlayerType type;

@property (nonatomic, strong) AVURLAsset *videoAsset;
@property (nonatomic, strong) VideoAssetUrlLoader *resouerLoader;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *playerHeightConstraint;

@property (strong, nonatomic) UISlider *volumeViewSlider;
@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;
@property (assign, nonatomic) BOOL isPlaying;

@end

@implementation SMAVPlayerViewController
@synthesize subscript;

- (instancetype)initWithType:(PlayerType)type
{
    self = [self initWithNibName:@"SMAVPlayerViewController" bundle:nil];
    if (self) {
        _type = type;
        _isPlaying = YES;
    }
    return self;
}

- (void)setSubTitile:(NSString *)subTitile {
    _subTitile = subTitile;
}

- (void)setupHeadView {
    self.viewHead.backgroundColor = [UIColor colorWithRed:35.0/255 green:35.0/255 blue:35.0/255 alpha:1.0];
    self.titleLabel.text = self.subTitile;
}

- (void)setupLoadView {
    [self.imageViewLogin setImage:[UIImage sd_animatedGIFNamed:@"greenloading.gif"]];
}

- (void)setupBottomView {
    self.viewBottom.backgroundColor = [UIColor colorWithRed:35.0/255 green:35.0/255 blue:35.0/255 alpha:1.0];
    self.btnPause.selected = NO; //NO 暂停， YES 播放
}

- (void)setupSlider {
    self.sliderBar.backgroundColor = [UIColor colorWithRed:35.0/255 green:35.0/255 blue:35.0/255 alpha:1.0];
    self.sliderBar.delegate=self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self){
        _currentOrientation = UIInterfaceOrientationLandscapeRight;
        _width = ScreenWidth;
        _height = ScreenHeight;
        
        if(_width > _height){
            _width = ScreenHeight;
            _height = ScreenWidth;
        }
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupHeadView];
    [self setupLoadView];
    [self setupSlider];
    [self setupBottomView];
    
    subscript = 0;
    self.currentTime = 0;

    [self prohibitOperation];
    [self setMediaPlayer];
    
    //监听AVPlayerItem状态
    [self addObserverToPlayerItem];
    [self addProgressObserver];//进度监听
    
    [self addPlayerClick];//双击,单击事件
    [self setupObservers];//监听应用状态
    [self addNotification];//广播监听播放状态
    
//    splashTimer = [NSTimer scheduledTimerWithTimeInterval:1  target:self selector:@selector(roteImageView) userInfo:nil repeats:YES];
//    [[NSRunLoop currentRunLoop] addTimer:splashTimer forMode:NSRunLoopCommonModes];
    
    NSError *error;
    [[AVAudioSession sharedInstance] setActive:YES error:&error];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(volumeChange:) name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
    
    //第一次获取不到，但是可以先使用该方法 初始化volumViewSlider（最好先调用一次，不然viewDidAppear中依然拿不到值）
    self.volumeSlider.value = [self getSystemVolumValue];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    
    [self orientationToRotate:UIInterfaceOrientationLandscapeRight];
    //调整播放层的高度
    [self updatePlayerConstraint];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.volumeSlider.value = [self getSystemVolumValue];
    //接受远程控制事件
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
    
}

- (IBAction)switchScreenSize:(UIButton *)sender {
    sender.selected = !sender.selected;
    if(sender.selected){
        [sender setImage:[UIImage imageNamed:@"PlayerMaximizeHover.tiff"] forState:UIControlStateSelected];
        [self orientationToRotate:UIInterfaceOrientationPortrait];
        _currentOrientation = UIInterfaceOrientationPortrait;
        [self updatePlayerConstraint];
    }else {
        [sender setImage:[UIImage imageNamed:@"PlayerMinimizeHover.tiff"] forState:UIControlStateNormal];
        [self orientationToRotate:UIInterfaceOrientationLandscapeRight];
        _currentOrientation = UIInterfaceOrientationLandscapeRight;
        [self updatePlayerConstraint];
    }
}

- (void)updatePlayerConstraint {
    if (_currentOrientation == UIInterfaceOrientationLandscapeRight) {
        self.playerHeightConstraint.constant = _width;
    }else {
        self.playerHeightConstraint.constant =  _width * 3 / 4;
    }
    
    [self.view layoutIfNeeded];
    
    self.playerLayer.frame = CGRectMake(0, 0, ScreenWidth, self.playerHeightConstraint.constant);
    [self.viewAvPlayer.layer layoutIfNeeded];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self orientationToRotate:UIInterfaceOrientationPortrait];
    
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];
//    [splashTimer invalidate];
}

- (AVPlayerLayer *)playerLayer {
    if(!_playerLayer){
        AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        _playerLayer = layer;
    }
    
    return _playerLayer;
}

- (void)setMediaPlayer{
    //创建播放器层
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.viewAvPlayer.layer insertSublayer:self.playerLayer atIndex:0];
}

#pragma mark - set/get
- (AVPlayer *)player{
    if (!_player) {
        AVPlayerItem *playerItem = [self getPlayItem:subscript];
        _player = [AVPlayer playerWithPlayerItem:playerItem];
        if(IOS_VERSION >= 10){
            //增加下面这行可以解决iOS10兼容性问题了
            _player.automaticallyWaitsToMinimizeStalling = NO;
        }
        _player.volume = 0.5;
    }
    return _player;
}

#pragma -mark 设置AVPlayerItem
- (AVPlayerItem *)getPlayItem:(NSUInteger)videoIndex{
    AVPlayerItem *playerItem = nil;
    self.subTitile = self.video.subTitile;
    
    switch (self.type) {
        case PlayerLocationType:
        {
            self.sliderBar.type = SMSliderLocationType;
            playerItem = [AVPlayerItem playerItemWithURL:self.video.strURL];
            
        }
            break;
        case PlayerLocationLiveType:
        {
            self.sliderBar.type = SMSliderLiveType;
            
//            AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:self.video.strURL options:nil];
//            playerItem  = [AVPlayerItem playerItemWithAsset:asset];
            playerItem = [AVPlayerItem playerItemWithURL:self.video.strURL];
        }
            break;
        case PlayerNoLoaderURLType:
        {
            self.sliderBar.type = SMSliderLocationType;
            playerItem = [self loadURLAsset:self.video.strURL];
        }
            break;
        case PlayerVODType:
        {
            self.sliderBar.type = SMSliderLocationType;
            playerItem = [self loadURLAsset:self.video.strURL];
            self.resouerLoader.type = AssetUrlLiveLoader;
        }
            break;
        case PlayerURLType:
        {
            self.sliderBar.type = SMSliderURLType;
            playerItem = [self loadURLAsset:self.video.strURL];
            self.resouerLoader.type = AssetUrlCacheLoader;
        }
            break;
        case PlayerLiveType:
        {
            //去服务器取直播资源
            self.sliderBar.type = SMSliderLiveType;
            playerItem = [self loadURLAsset:self.video.strURL];
            self.resouerLoader.type = AssetUrlLiveLoader;
        }
            break;
        default:
            break;
    }
    
    if (IOS9_OR_LATER) {
        playerItem.canUseNetworkResourcesForLiveStreamingWhilePaused = YES;
    }
    return playerItem;
}

- (AVPlayerItem *)loadURLAsset:(NSURL *)url {
    if(IOS_VERSION < 7.0){
        _videoAsset  = [AVURLAsset URLAssetWithURL:url options:nil];
    }else{
        //判断缓存中是否已经存在
        NSString *cacheUrl = [LCFileHandle cacheFileExistsWithURL:url];
        if(cacheUrl){
            self.type = PlayerLocationType;
            self.sliderBar.type = SMSliderLocationType;
            NSURL *localUrl = [NSURL fileURLWithPath:cacheUrl];
            AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:localUrl];
            return playerItem;
        }
        
        VideoAssetUrlLoader *loader = [[VideoAssetUrlLoader alloc] init];
        loader.delegate = self;
        
        NSURL *playUrl = [loader getSchemeVideoURL:url];
        _videoAsset = [AVURLAsset URLAssetWithURL:playUrl options:nil];
        [_videoAsset.resourceLoader setDelegate:loader queue:dispatch_get_main_queue()];

        self.resouerLoader = loader;
    }
    
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:_videoAsset];
    return item;
}
#pragma mark - 通知
//给AVPlayerItem添加播放完成通知
- (void)addNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:_player.currentItem];
}

// 播放完成通知
- (void)playbackFinished:(NSNotification *)notification{
    NSSLog(@"视频播放完成.");
    [self prohibitOperation];
//    [self savePayHistory];
    [self nextClick:nil];
}

//注册通知
- (void)setupObservers
{
    NSNotificationCenter *notification = [NSNotificationCenter defaultCenter];
    [notification addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationWillEnterForegroundNotification object:[UIApplication sharedApplication]];
    [notification addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationWillResignActiveNotification object:[UIApplication sharedApplication]];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    //当以UIInterfaceOrientationLandscapeRight进入后台后，回来时尺寸不对，解决办法旋转为竖屏
    if(_currentOrientation == UIInterfaceOrientationLandscapeRight){
        [self switchScreenSize:self.btnFullScreen];
    }
}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    self.isPlaying = self.btnPause.selected;
}

/**
 *  给AVPlayer添加监控
 *  @param player AVPlayer对象
 */
//- (void)addObserverToPlayer:(AVPlayer *)player{
//    //监控状态属性，注意AVPlayer也有一个status属性，通过监控它的status也可以获得播放状态
//    [player addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
//}

/**
 *  给AVPlayerItem添加监控
 *  @param playerItem AVPlayerItem对象
 */
- (void)addObserverToPlayerItem{
    
    AVPlayerItem *playerItem = self.player.currentItem;
    //监控状态属性，注意AVPlayer也有一个status属性，通过监控它的status也可以获得播放状态
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    //监控网络加载情况属性
    [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    //监听播放的区域缓存是否为空
    [playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    //缓存可以播放的时候调用
    [playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    
    [self.player addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removeObserverFromPlayerItem:(AVPlayerItem *)playerItem{
    if(playerItem){
        [playerItem removeObserver:self forKeyPath:@"status"];
        [playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
        [playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
        [playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    }
    
    [self.player removeObserver:self forKeyPath:@"rate"];
}
/**
 *  通过KVO监控播放器状态
 *  @param keyPath 监控属性
 *  @param object  监视器
 *  @param change  状态改变
 *  @param context 上下文
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    AVPlayerItem *playerItem = object;
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItemStatus status= [[change objectForKey:@"new"] intValue];
        if(status == AVPlayerItemStatusReadyToPlay){
            NSSLog(@"开始播放。。。。。。。。");
            [self clearProhibitOperation];
            [self setIsBottomViewHide:YES];
            if(self.isPlaying){
                [self startPlayer:self.currentTime];
            }
        }else if(status == AVPlayerItemStatusUnknown){
            NSSLog(@"%@",@"AVPlayerItemStatusUnknown");
        }else if (status == AVPlayerItemStatusFailed){
            NSSLog(@"%@",@"AVPlayerItemStatusFailed");
//            AVPlayerItemErrorLog *errorLog = [self.player.currentItem errorLog];
            NSSLog(@"%@",self.player.currentItem.error);
//            NSSLog(@"======error======%@",[[NSString alloc] initWithData:[errorLog extendedLogData] encoding:[errorLog extendedLogDataStringEncoding]]);
        }
    }else if([keyPath isEqualToString:@"loadedTimeRanges"]){
        NSArray *array = playerItem.loadedTimeRanges;
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];//本次缓冲时间范围
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        NSTimeInterval totalBuffer = startSeconds + durationSeconds;//缓冲总长度
        if (self.currentTime < (startSeconds + durationSeconds + 8)) {
            self.imageViewLogin.hidden  = YES;
        }else{
            self.imageViewLogin.hidden = NO;
        }
        NSSLog(@"缓冲：%.2f",totalBuffer);
    }else if ([keyPath isEqualToString:@"playbackBufferEmpty"]){
        NSSLog(@"playbackBufferEmpty");
        [self.imageViewLogin setHidden:NO];
    }else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]){
        [self.imageViewLogin setHidden:YES];
        NSSLog(@"playbackLikelyToKeepUp");
    }
    
//    else if([keyPath isEqualToString:@"rate"]){
//        if (self.player.rate == 0.0) {
//            self.isPlaying = NO;
//        }else {
//            self.isPlaying = YES;
//        }
//    }
}

#pragma mark - 手势监听
- (void)addPlayerClick{
    //单击手势监听
    UITapGestureRecognizer * tapGes=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(playerSingleClick:)];
    tapGes.numberOfTapsRequired=1;
    [self.viewAvPlayer addGestureRecognizer:tapGes];
    
//     //双击手势监听
//     UITapGestureRecognizer * tapGesDouble=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(playerDoubleTap:)];
//     tapGesDouble.numberOfTapsRequired=2;
//     [self.viewAvPlayer addGestureRecognizer:tapGesDouble];
//     //双击手势确定监测失败才会触发单击手势的相应操作
//     [tapGes requireGestureRecognizerToFail:tapGesDouble];
}

- (void)setIsBottomViewHide:(BOOL)isBottomViewHide {
    _isBottomViewHide = isBottomViewHide;
    if (!_isBottomViewHide) {
        //显示
        [UIView animateWithDuration:0.3 animations:^{
            [self.viewBottom setAlpha:1];
            [self.sliderBar setAlpha:1];
            [self.viewHead setAlpha:1];
        }];
    }else{
        //隐藏
        [UIView animateWithDuration:0.3 animations:^{
            [self.viewBottom setAlpha:0.0];
            [self.sliderBar setAlpha:0.0];
            [self.viewHead setAlpha:0.0];
        }];
    }
}

//显示或隐藏控制view
- (void)playerSingleClick:(UITapGestureRecognizer*)recognizer{
    self.isBottomViewHide = !self.isBottomViewHide;
}

//改变播放模式
- (void)playerDoubleTap:(UITapGestureRecognizer*)recognizer{
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    if ([playerLayer.videoGravity isEqualToString:AVLayerVideoGravityResizeAspect]) {
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }else if ([playerLayer.videoGravity isEqualToString:AVLayerVideoGravityResizeAspectFill]){
        playerLayer.videoGravity = AVLayerVideoGravityResize;
    }else if ([playerLayer.videoGravity isEqualToString:AVLayerVideoGravityResize]){
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    }
}

#pragma mark - IBAction
- (IBAction)pauseClick:(id)sender {
    if (!self.btnPause.selected) {
        [self startPlayer:self.currentTime];
    }else{
        [self pausePlayer];
    }
}

- (IBAction)nextClick:(id)sender {
    [MBProgressHUD showSuccess:@"没有更多了" toView:self.view];
//    self.labelTimeNow.text = @"00:00:00";
//    self.labelTimeTotal.text = @"00:00:00";
//    self.sliderBar.value = 0;
//    if (subscript < self.arrVedio.count) {
//        [self.player seekToTime:CMTimeMakeWithSeconds(0, _player.currentItem.duration.timescale)];
//        [self removeNotification];
//        [self removeObserverFromPlayerItem:self.player.currentItem];
//        [self.player removeTimeObserver:self.timeObserver];
//        [_player replaceCurrentItemWithPlayerItem:[self getPlayItem:subscript]];
//        [self addObserverToPlayerItem:self.player.currentItem];
//        [self addNotification];
//        [self addProgressObserver];
//        if (self.player.rate == 0 ) {
//            [self.player play];
//        }
//    }else{
//        --subscript;
//        /*
//         [self.player.currentItem cancelPendingSeeks];
//         [self.player.currentItem.asset cancelLoading];
//         */
//        [self.btnPause setTitle:@"播放" forState:UIControlStateNormal];
//        [self.btnPause setBackgroundImage:[UIImage imageNamed:@"play_start.png"] forState:UIControlStateNormal];
//        self.labelTimeTotal.text = @"00:00:00";
//        self.labelTimeNow.text = @"00:00:00";
//        [MBMessageTip messageWithTip:self.view withMessage:@"没有更多了" ];
//    }
}

- (IBAction)backAction:(id)sender {
    [self savePayHistory];
    [self pausePlayer];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - interface rotation
//强制旋转屏幕
- (void)orientationToRotate:(UIInterfaceOrientation)orientation {
    SEL selector = NSSelectorFromString(@"setOrientation:");
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
    [invocation setSelector:selector];
    [invocation setTarget:[UIDevice currentDevice]];
    int val = orientation;
    [invocation setArgument:&val atIndex:2];//前两个参数已被target和selector占用
    [invocation invoke];
}

- (BOOL)shouldAutorotate{
    return NO;
}

#pragma mark - 私有方法
//设置播放时长
- (void)setTime:(double)current withTotal:(double)total{
    self.sliderBar.value = current/total;
    self.labelTimeNow.text = [self displayTime:current];
    self.labelTimeTotal.text = [@"/" stringByAppendingString:[self displayTime:total]];
}

- (NSString*)displayTime:(NSTimeInterval)timeInterval{
    int seconds = (int)timeInterval % 60;
    int minutes = ((int)timeInterval / 60) % 60;
    int hours = timeInterval / 3600;
    
    NSString *secondstr = @"";
    if(seconds < 10){
        secondstr = [NSString stringWithFormat:@"0%d",seconds];
    }else{
        secondstr = [NSString stringWithFormat:@"%d",seconds];
    }
    
    NSString *minutesstr = @"";
    if(minutes < 10){
        minutesstr = [NSString stringWithFormat:@"0%d",minutes];
    }else{
        minutesstr = [NSString stringWithFormat:@"%d",minutes];
    }
    
    NSString *hoursstr = @"";
    if(hours < 10){
        hoursstr = [NSString stringWithFormat:@"0%d",hours];
    }else{
        hoursstr = [NSString stringWithFormat:@"%d",hours];
    }
    
    return [NSString stringWithFormat:@"%@:%@:%@",hoursstr, minutesstr, secondstr];
}

//视频加载指示条
- (void)roteImageView{
//    CABasicAnimation* rotationAnimation;
//    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
//    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
//    rotationAnimation.cumulative = YES;
//    rotationAnimation.repeatCount = 1;
//    rotationAnimation.duration = 1;
//    [self.imageViewLogin.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

//保存播放历史
- (void)savePayHistory{
//    NSDate *currentDate = [NSDate date];//获取当前时间,日期
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"YYYY-MM-dd"];
//    NSString *dateString = [dateFormatter stringFromDate:currentDate];
//    VedioModel *vedioModel = _arrVedio[subscript];
//    VedioHistory *vedioHistory = [[VedioHistory alloc] init];
//    [vedioHistory insertTitle:vedioModel.strTitle createTime:dateString userId:[NSNumber numberWithInt:[vedioModel.strUserID intValue]] videoType:[NSNumber numberWithInt:vedioModel.vedioType]  playTime:[NSNumber numberWithInteger:self.currentTime] videoUrl:vedioModel.strURL picUrl:vedioModel.strImage];
}

//视频未播放时禁止点击
- (void)prohibitOperation{
    [self.imageViewLogin setHidden:NO];
    self.btnNetx.enabled = NO;
    self.btnPause.enabled = NO;
    self.sliderBar.isAllowDrag = NO;
}

//视频播放时取消禁止点击
- (void)clearProhibitOperation{
    [self.imageViewLogin setHidden:YES];
    self.btnNetx.enabled = YES;
    self.btnPause.enabled = YES;
    if(self.type == PlayerLiveType){
        self.sliderBar.isAllowDrag = NO;
    }else{
        self.sliderBar.isAllowDrag = YES;
    }
}

- (void)dealloc{
    [self releaseResourceLoader];
    
    [self.player.currentItem cancelPendingSeeks];
    [self.player.currentItem.asset cancelLoading];
    
    [self removeObserverFromPlayerItem:self.player.currentItem];
    [self.player removeTimeObserver:self.timeObserver];
    self.timeObserver = nil;
    
    //
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma -mark 下载代理 VideoAssetUrlLoaderDelegate
- (void)loaderDidFailWithError {
    
}

- (void)cacheProgress:(CGFloat)progress
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.player.currentItem.status == AVPlayerStatusFailed && progress > 20){
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                [self.player play];
            });
        }
        self.sliderBar.endBufferValue = progress;
    });
}

- (void)finishedCache:(NSURL *)url {
    if(url){
        self.sliderBar.isAllowDrag = YES;
        self.type = PlayerLocationType;
        self.sliderBar.type = SMSliderLocationType;
        self.resouerLoader.type = AssetUrlLocationLoader;
    }
    
}

#pragma mark - smSliderDelegate
- (void)SMSliderBarBeginTouch:(UIView *)slider{
    [self.player pause];
}

- (void)SMSliderBar:(UIView *)slider valueChanged:(float)value{
    if(self.type == PlayerURLType && ![self.resouerLoader canMove:value]){
        self.sliderBar.value = self.currentTime/self.totalTime;
        return;
    }
    
    self.currentTime = ceil(self.totalTime * value);
    self.labelTimeNow.text = [self displayTime:self.currentTime];
    self.resouerLoader.seekRequire = YES;
    //当移动的同时，删除了缓存文件，出现崩溃
    @try {
        [self.player seekToTime:CMTimeMakeWithSeconds(self.currentTime, self.player.currentItem.duration.timescale)];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}

- (void)SMSliderBarEndTouch:(UIView *)slider{
    if (self.btnPause.selected) {
        [self startPlayer:self.currentTime];
    }
}

#pragma mark - KVO
- (void)addProgressObserver{
    AVPlayerItem *playerItem = self.player.currentItem;
    //这里设置每秒执行一次
    __weak typeof(self) weakself = self;
    self.timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        //playerItem.asset.duration 千万不能用(avpleritem 一直会出现AVPlayerItemStatusFailed（但是模拟器不会出问题(纠结)）)
//        double total = CMTimeGetSeconds(playerItem.asset.duration);
        double total = CMTimeGetSeconds(playerItem.duration);
        double current = CMTimeGetSeconds(time);
        weakself.currentTime = current;
        weakself.totalTime = total;
        if (current) {
            [weakself setTime:current withTotal:total];
        }
    }];
}

#pragma -mark 播放器开始/暂停

- (void)startPlayer:(NSTimeInterval)time {
    [self.player seekToTime:CMTimeMakeWithSeconds(time, self.player.currentItem.duration.timescale) completionHandler:^(BOOL finished) {
        if (finished) {
            [self.player play];
        }
    }];
    self.btnPause.selected = YES;
    [self.btnPause setImage:[UIImage imageNamed:@"pPause_h.tiff"] forState:UIControlStateSelected];
}

- (void)pausePlayer {
    [self.player pause];
    
    self.btnPause.selected = NO;
    [self.btnPause setImage:[UIImage imageNamed:@"pPlay_p.tiff"] forState:UIControlStateNormal];
}

- (void)releaseResourceLoader {
    //删除缓存文件
    [LCFileHandle clearCache];
    self.resouerLoader.delegate = nil;
    self.resouerLoader = nil;
}


#pragma -mark 改变系统音量
/** 改变铃声 的 通知
 
 "AVSystemController_AudioCategoryNotificationParameter" = Ringtone;    // 铃声改变
 "AVSystemController_AudioVolumeChangeReasonNotificationParameter" = ExplicitVolumeChange; // 改变原因
 "AVSystemController_AudioVolumeNotificationParameter" = "0.0625";  // 当前值
 "AVSystemController_UserVolumeAboveEUVolumeLimitNotificationParameter" = 0; 最小值
 
 
 改变音量的通知
 "AVSystemController_AudioCategoryNotificationParameter" = "Audio/Video"; // 音量改变
 "AVSystemController_AudioVolumeChangeReasonNotificationParameter" = ExplicitVolumeChange; // 改变原因
 "AVSystemController_AudioVolumeNotificationParameter" = "0.3";  // 当前值
 "AVSystemController_UserVolumeAboveEUVolumeLimitNotificationParameter" = 0; 最小值
 */
-(void)volumeChange:(NSNotification*)notifi{
    NSString * style = [notifi.userInfo objectForKey:@"AVSystemController_AudioCategoryNotificationParameter"];
    CGFloat value = [[notifi.userInfo objectForKey:@"AVSystemController_AudioVolumeNotificationParameter"] doubleValue];
    if ([style isEqualToString:@"Ringtone"]) {
        NSLog(@"铃声改变");
    }else if ([style isEqualToString:@"Audio/Video"]){
        NSLog(@"音量改变 当前值:%f",value);
        self.volumeSlider.value = value;
    }
}

#pragma mark - 音量控制
/*
 *获取系统音量滑块
 */
- (UISlider *)volumeViewSlider {
    if (_volumeViewSlider == nil) {
        MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(-200, -50, 100, 4)];
        
        //将MPVolumeView 添加到 当前视图中 ，就可以 实现隐藏 系统音量调节 控制 出现
        [self.view addSubview:volumeView];
        for (UIView* newView in volumeView.subviews) {
            if ([newView.class.description isEqualToString:@"MPVolumeSlider"]){
                _volumeViewSlider = (UISlider*)newView;
                break;
            }
        }
        
        // change system volume, the value is between 0.0f and 1.0f
//        [_volumeViewSlider setValue:0.5f animated:NO];
        
        // send UI control event to make the change effect right now.
        [_volumeViewSlider sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
    return _volumeViewSlider;
}

-(CGFloat)getSystemVolumValue{
    return self.volumeViewSlider.value;
}
/*
 *设置系统音量大小
 */
- (IBAction)setSysVolum:(UISlider *)sender {
    self.volumeViewSlider.value = sender.value;
}
@end
