//
//  X264Manager.m
//  FFmpeg_X264_Codec
//
//  Created by sunminmin on 15/9/7.
//  Copyright (c) 2015年 suntongmian@163.com. All rights reserved.
//

#import "X264Manager.h"

#ifdef __cplusplus
extern "C" {
#endif
    
#include "x264.h"
#ifdef __cplusplus
};
#endif

/*配置参数
 * 使用默认参数，在这里使用了zerolatency的选项，使用这个选项之后，就不会有
 * delayed_frames，如果你使用不是这个的话，还需要在编码完成之后得到缓存的
 * 编码帧
 */
#define ENCODER_TUNE   "zerolatency"
#define ENCODER_PROFILE  "baseline"
#define ENCODER_COLORSPACE X264_CSP_I420
#define ENCODER_PRESET "veryfast"

@interface X264Manager()
{
    BOOL _enableToEncode;
    x264_param_t                        * pParam;
    x264_t                              * pHandle;
    FILE                                * fp_dst;
    int                                  framecnt;
    NSDate                              *startEncodeDate;
    int                                  encoder_h264_frame_width; // 编码的图像宽度
    int                                  encoder_h264_frame_height; // 编码的图像高度
    NSString                            *outpath;
    BOOL                                _resetOutput;
    
}

@property (nonatomic, strong) NSDateFormatter       *formatter;
@end

@implementation X264Manager

static id manager = nil;
+ (instancetype)defaultManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!manager) {
            manager = [[self alloc] initWithConfiguration];
        }
    });
    
    return manager;
}

- (instancetype)initWithConfiguration
{
    self = [super init];
    if (self) {
        _enableToEncode = NO;
        _resetOutput = YES;
    }
    return self;
}

- (NSDateFormatter *)formatter {
    if (!_formatter) {
        _formatter = [[NSDateFormatter alloc] init];
        _formatter.dateFormat = @"YYYYMMdd";
    }
    
    return _formatter;
}

- (void)startEncoder:(int)width height:(int)height {
    startEncodeDate = [NSDate date];
    if ([self initX264Configure:width height:height] != 0) {
        _enableToEncode = NO;
        [MBProgressHUD showError:@"编码器初始化失败！" toView:[UIApplication sharedApplication].keyWindow];
    }else{
        _enableToEncode = YES;
    }
}

- (void)stopEncode {
    _enableToEncode = NO;
}

- (BOOL)canEncode {
    return _enableToEncode;
}
/*
 * 设置X264
 * 0: 成功； －1: 失败
 * width: 视频宽度
 * height: 视频高度
 * bitrate: 视频码率，码率直接影响编码后视频画面的清晰度， 越大越清晰，但是为了便于保证编码后的数据量不至于过大，以及适应网络带宽传输，就需要合适的选择该值
 */
- (int)initX264Configure:(int)width height:(int)height
{
    framecnt = 0;
    int ret = 0;
    pHandle   =  NULL;
    
    char parameter_preset[20];
    char parameter_tune[20];
    char parameter_profile[20];
    
    encoder_h264_frame_width = width;
    encoder_h264_frame_height = height;
    
    //Encode 50 frame
    //if set 0, encode all frame
    strcpy(parameter_preset,ENCODER_PRESET);
    strcpy(parameter_tune,ENCODER_TUNE);

    pParam = (x264_param_t*)malloc(sizeof(x264_param_t));
    
    if(!pParam){
        printf("malloc x264_parameter error!n");
        return -1;
    }
    
    x264_param_default(pParam);
    
    
    ret = x264_param_default_preset(pParam, parameter_preset ,parameter_tune);
    if(ret < 0){
        printf("x264_param_default_preset error!n");
        return ret;
    }
    
    pParam->i_width   = 320;
    pParam->i_height  = 480;
    
    //Param
    
    /*cpuFlags 去空缓冲区继续使用不死锁保证*/
    pParam->i_threads  = X264_SYNC_LOOKAHEAD_AUTO;
    pParam->i_frame_total = 0; //要编码的总帧数，不知道用0
    pParam->i_keyint_max = 25;
    /*流参数*/
    pParam->i_bframe  = 5;
    pParam->b_open_gop  = 0;
    pParam->i_bframe_pyramid = 0;
    pParam->rc.i_qp_constant=0;
    pParam->rc.i_qp_max=0;
    pParam->rc.i_qp_min=0;
    pParam->i_bframe_adaptive = X264_B_ADAPT_TRELLIS;
    /*log参数，不需要打印编码信息时直接注释掉*/
//    pParam->i_log_level  = X264_LOG_DEBUG;
    
    pParam->i_fps_den  = 1; //码率分母
    pParam->i_fps_num  = 25; //码率分子
    pParam->i_timebase_den = pParam->i_fps_num;
    pParam->i_timebase_num = pParam->i_fps_den;
    pParam->b_intra_refresh = 1;
    pParam->b_annexb = 1;
    
    strcpy(parameter_profile,ENCODER_PROFILE);
    ret = x264_param_apply_profile(pParam,parameter_profile);
    //x264_param_apply_profile(pParam, x264_profile_names[5]);
    if(ret <0 ){
        printf("x264_param_apply_profile error!n");
        return ret;
    }
    
    /*打开编码器*/
    pHandle = x264_encoder_open(pParam);
    pParam->rc.i_bitrate = 1.5*1000000; //1500000
    pParam->i_csp = ENCODER_COLORSPACE;
    
//    y_size = encoder_h264_frame_width * encoder_h264_frame_height;
    return 0;
}

//- (BOOL)writerHeader {
////    int ret = x264_encoder_headers(pHandle, &pNals, &iNal);
////    if (ret != 0) {
////        return false;
////    }
//    
////    int i = 0;
////    for (i = 0; i < iNal; i++)
////    {
////        if (pNals[i].i_type == 7)	//sps
////        {
////            m_iSPSLen = pNals[i].i_payload - 4;
////            memcpy(m_pSPS, pNals[i].p_payload + 4, m_iSPSLen);
////        }
////        else if (pNals[i].i_type == 8)	//pps
////        {
////            m_iPPSLen = pNals[i].i_payload - 4;
////            memcpy(m_pPPS, pNals[i].p_payload + 4, m_iPPSLen);
////        }
////        else
////        {
////            continue;
////        }
////    }
//    return YES;
//}
//(1)处理不用旋转的图像，格式转换加裁剪
void detailPic0(uint8_t* d, uint8_t* yuv_temp, int nw, int nh, int w, int h) {
    int deleteW = (nw - w) / 2;
    int deleteH = (nh - h) / 2;
    //处理y 旋转加裁剪
    int i, j;
    int index = 0;
    for (j = deleteH; j < nh- deleteH; j++) {
        for (i = deleteW; i < nw- deleteW; i++)
            yuv_temp[index++]= d[j * nw + i];
    }
    //处理u
    index= w * h;
    for (i = nh + deleteH / 2;i < nh / 2 * 3 - deleteH / 2; i++)
        for (j = deleteW + 1; j< nw - deleteW; j += 2)
            yuv_temp[index++]= d[i * nw + j];
    //处理v 旋转裁剪加格式转换
    for (i = nh + deleteH / 2;i < nh / 2 * 3 - deleteH / 2; i++)
        for (j = deleteW; j < nw- deleteW; j += 2)
            yuv_temp[index++]= d[i * nw + j];
}

int I420Rotate90(uint8_t  *des,uint8_t  *src,int srcWidth, int srcHeight) {
    int nWidth = 0, nHeight = 0;
    int wh = 0;
    int uvHeight = 0;
    if(srcWidth != nWidth || srcHeight != nHeight)
    {
        nWidth = srcWidth;
        nHeight = srcHeight;
        wh = srcWidth * srcHeight;
        uvHeight = srcHeight >> 1;//uvHeight = height / 2
    }
    
    //旋转Y
    int k = 0;
    for(int i = 0; i < srcWidth; i++) {
        int nPos = 0;
        for(int j = 0; j < srcHeight; j++) {
            des[k] = src[nPos + i];
            k++;
            nPos += srcWidth;
        }
    }
    
    for(int i = 0; i < srcWidth; i+=2){
        int nPos = wh;
        for(int j = 0; j < uvHeight; j++) {
            des[k] = src[nPos + i];
            des[k + 1] = src[nPos + i + 1];
            k += 2;
            nPos += srcWidth;
        }
    }
    
    return 0;
}

int interleave_to_planar(uint32_t wxh,uint8_t *u,uint8_t *v,const uint8_t *uv)
{
    int i;
    
    for (i = 0; i < wxh / 4; i++)
    {
        uint8_t u_data = uv[2 * i];     // fetch u data
        uint8_t v_data = uv[2 * i + 1]; // fetch v data
        
        u[i] = u_data;                  // write u data
        v[i] = v_data;                  // write v data
    }
    
    return 0;
}

int rotateYUV420Degree90(uint8_t* dstyuv,uint8_t* srcdata, int imageWidth, int imageHeight) {
    int i = 0, j = 0;
    int index = 0;
    int tempindex = 0;
    int div = 0;
    int ustart = imageWidth *imageHeight;
    for (i = 0; i <imageHeight; i++) {
        div= i;
        tempindex= ustart;
        for (j = 0; j <imageHeight; j++) {
            tempindex-= imageWidth;
            dstyuv[index++]= srcdata[tempindex + div];
        }
    }
    int udiv = imageWidth *imageHeight / 4;
    int uWidth = imageWidth /2;
    int uHeight = imageHeight /2;
    index= ustart;
    for (i = 0; i < uHeight;i++) {
        div= i ;
        tempindex= ustart+udiv;
        for (j = 0; j < uWidth;j++) {
            tempindex-= uWidth;
            dstyuv[index]= srcdata[tempindex + div];
            dstyuv[index+ udiv] = srcdata[tempindex + div + udiv];
            index++;
        }
    }
    return 0;
}

//crop yuv data 裁剪
int crop_yuv (uint8_t* data, uint8_t*dst, int width, int height,
              int goalwidth, int goalheight) {
    int i, j;
    int h_div = 0, w_div = 0;
    w_div= (width - goalwidth) / 2;
    if (w_div % 2)
        w_div--;
    h_div= (height - goalheight) / 2;
    if (h_div % 2)
        h_div--;
    //u_div = (height-goalheight)/4;
    int src_y_length = width *height;
    int dst_y_length =goalwidth * goalheight;
    for (i = 0; i <goalheight; i++)
        for (j = 0; j <goalwidth; j++) {
            dst[i* goalwidth + j] = data[(i + h_div) * width + j + w_div];
        }
    int index = dst_y_length;
    int src_begin =src_y_length + h_div * width / 4;
    int src_u_length =src_y_length / 4;
    int dst_u_length =dst_y_length / 4;
    for (i = 0; i <goalheight / 2; i++)
        for (j = 0; j <goalwidth / 2; j++) {
            int p = src_begin + i *(width >> 1) + (w_div >> 1) + j;
            dst[index]= data[p];
            dst[dst_u_length+ index++] = data[p + src_u_length];
        }
    return 0;
}

//**(2)格式转换、裁剪加旋转90度
void detailPic90(uint8_t* d, uint8_t* yuv_temp, int nw, int nh, int w, int h) {
    int deleteW = (nw - h) / 2;
    int deleteH = (nh - w) / 2;
    int i, j;
    for (i = 0; i < h; i++){
        for (j = 0; j < w; j++){
            yuv_temp[(h- i) * w - 1 - j] = d[nw * (deleteH + j) + nw - deleteW
                                              -i];
        }
    }
    int index = w * h;
    for (i = deleteW + 1; i< nw - deleteW; i += 2)
        for (j = nh / 2 * 3 -deleteH / 2; j > nh + deleteH / 2; j--)
            yuv_temp[index++]= d[(j - 1) * nw + i];
    for (i = deleteW; i < nw- deleteW; i += 2)
        for (j = nh / 2 * 3 -deleteH / 2; j > nh + deleteH / 2; j--)
            yuv_temp[index++]= d[(j - 1) * nw + i];
}

- (int)encodeSampleBuffer:(CMSampleBufferRef)videoSample {
    int ret = 0;
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(videoSample);
    
    if (CVPixelBufferLockBaseAddress(pixelBuffer, 0) == kCVReturnSuccess) {
        x264_picture_t * pPic_in = NULL;
        pPic_in = (x264_picture_t*)malloc(sizeof(x264_picture_t));
        x264_picture_alloc(pPic_in, pParam->i_csp, pParam->i_width, pParam->i_height);
        pPic_in->img.i_csp = pParam->i_csp;
        pPic_in->img.i_plane = 3;
        pPic_in->i_type = X264_TYPE_AUTO;
        
        x264_picture_t * pPic_out = NULL;
        pPic_out = (x264_picture_t*)malloc(sizeof(x264_picture_t));
        x264_picture_init(pPic_out);
        
//        I420格式：y,u,v 3个部分分别存储：Y0,Y1…Yn,U0,U1…Un/2,V0,V1…Vn/2
//        NV12格式：y和uv 2个部分分别存储：Y0,Y1…Yn,U0,V0,U1,V1…Un/2,Vn/2
//        NV21格式：同NV12，只是U和V的顺序相反。
//        UInt8 *bufferPtr2 = (UInt8 *)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer,2);
        
        ///////////////
        //图像宽度（像素）
        size_t pixelWidth = CVPixelBufferGetWidth(pixelBuffer);
        //图像高度（像素）
        size_t pixelHeight = CVPixelBufferGetHeight(pixelBuffer);
        //yuv中的y所占字节数
        size_t y_size = pixelWidth * pixelHeight;
        //yuv中的uv所占的字节数
        size_t uv_size = y_size / 2;
        
        //获取CVImageBufferRef中的y数据
        uint8_t *y_frame = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);

        //获取CMVImageBufferRef中的uv数据
        uint8_t *uv_frame = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1);

        uint8_t *yuv_data = (uint8_t *)malloc(y_size + uv_size);
        memset(yuv_data, 0, y_size+uv_size);
        memcpy(yuv_data, y_frame, y_size);
//        memcpy(yuv_data, uv_frame, uv_size);
        
        //////////////////
//        uint8_t * pDsty = yuv_data;
        uint8_t * pDstU = yuv_data + y_size;
        uint8_t * pDstV = pDstU + (y_size / 4);
        
        interleave_to_planar((int)y_size, pDstU, pDstV, uv_frame);
//
//        //顺时针旋转90度
//        uint8_t *yuv_r_data = (uint8_t *)malloc(y_size + uv_size);
//        memset(yuv_r_data, 0, y_size+uv_size);
        
//        I420Rotate90(yuv_r_data, yuv_data, (int)pixelWidth, (int)pixelHeight);
//        free(yuv_data);
        //裁剪
        
        size_t crop_size = pParam->i_width * pParam->i_height;
        uint8_t *yuv_c_data = (uint8_t *)malloc(crop_size*3/2);
        memset(yuv_c_data, 0, crop_size*3/2);
        crop_yuv(yuv_data, yuv_c_data, (int)pixelWidth, (int)pixelHeight, pParam->i_width, pParam->i_height);
        
        memcpy(pPic_in->img.plane[0], yuv_c_data, crop_size);                    //先写Y
        memcpy(pPic_in->img.plane[1], yuv_c_data + crop_size, crop_size/4);         //再写U
        memcpy(pPic_in->img.plane[2], yuv_c_data + crop_size + crop_size/4, crop_size/4);
        
//        memcpy(pPic_in->img.plane[0], yuv_data, y_size);                    //先写Y
//        memcpy(pPic_in->img.plane[1], yuv_data + y_size, y_size/4);         //再写U
//        memcpy(pPic_in->img.plane[2], yuv_data + y_size + y_size/4, y_size/4);

        
        free(yuv_data);
        free(yuv_c_data);
        //Read raw YUV data 这种方法赋值 会出现 内存泄漏
//        pPic_in->img.plane[0] = yuv_data;                  // Y
//        pPic_in->img.plane[1] = yuv_data + y_size;          // U
//        pPic_in->img.plane[2] = yuv_data + y_size + y_size/4;     // V
        
//        detailPic90(yuv_data, yuv_c_data,(int)pixelWidth, (int)pixelHeight,(int)pixelWidth, (int)pixelHeight);
        
        
//        memcpy(pPic_in->img.plane[0], yuv_r_data, y_size);                    //先写Y
//        memcpy(pPic_in->img.plane[1], yuv_r_data + y_size, y_size/4);         //再写U
//        memcpy(pPic_in->img.plane[2], yuv_r_data + y_size + y_size/4, y_size/4); //再写V
        
        pPic_in->img.i_csp = X264_CSP_I420;
        pPic_in->i_pts = ++framecnt;
        int iNal = 0;
        x264_nal_t *pNals = NULL;
        
        ret = x264_encoder_encode(pHandle, &pNals, &iNal, pPic_in, pPic_out);
        if (ret < 0){
//            free(yuv_r_data);
            x264_picture_clean(pPic_in);
            free(pPic_in);
            free(pPic_out);
        
            goto freeStep;
        }
        
//        printf("Succeed encode frame: %5dn",framecnt);
        for (int j = 0; j < iNal; ++j){
            fwrite(pNals[j].p_payload, 1, pNals[j].i_payload, fp_dst);
        }
        
        ret = [self flush_encoder:pPic_out withPNals:pNals withINal:iNal];
        if(ret < 0){
//            free(yuv_r_data);
            x264_picture_clean(pPic_in);
            free(pPic_in);
            free(pPic_out);
            
            goto freeStep;
        }
//        free(yuv_r_data);
        x264_picture_clean(pPic_in);
        free(pPic_in);
        free(pPic_out);
    }
    
freeStep:
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    return ret;
}

- (int)flush_encoder:(x264_picture_t *)pPic_out withPNals:(x264_nal_t *)pNals withINal:(int)iNal
{
    while(1){
        int ret = x264_encoder_encode(pHandle, &pNals, &iNal, NULL, pPic_out);
        if(ret < 0 ){
            return ret;
        }else if(ret == 0){
            break;
        }
        
        for (int j = 0; j < iNal; ++j){
            fwrite(pNals[j].p_payload, 1, pNals[j].i_payload, fp_dst);
        }
    }
    
    return 0;
}

/*
 * 将CMSampleBufferRef格式的数据编码成h264并写入文件
 *
 */
- (void)encoderToH264:(CMSampleBufferRef)sampleBuffer compeleteBlock:(void (^)(NSString *, long, NSTimeInterval))complete
{
        bool keyframe = !CFDictionaryContainsKey((CFArrayGetValueAtIndex(CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, true), 0)), kCMSampleAttachmentKey_NotSync);
    
    
        //准备接受下一个片段
        if(_resetOutput && [self initPout] != 0){
            return;
        }

        int ret = [self encodeSampleBuffer:sampleBuffer];
        if(ret < 0){
            return;
        }
    
        if (keyframe) // 关键帧
        {
            NSTimeInterval nowTime = [startEncodeDate timeIntervalSinceNow];
            
            int seconds = abs((int)nowTime % 60);
            
            if (seconds >= 30) {
                if (complete) {
                    fclose(fp_dst);
                    fp_dst = NULL;
                    framecnt = 0;
                    complete(outpath,0,fabs(nowTime));
                    startEncodeDate = [NSDate date];
                    _resetOutput = YES;
                    
                    //测试
//                    _enableToEncode = NO;
                    return;
                }
            }else if((int)(fabs(nowTime)*100) % 3 == 2){
                if (complete) {
                    fclose(fp_dst);
                    fp_dst = NULL;
                    complete(outpath,0,0);
                    _resetOutput = YES;
                    return;
                }
            }else{
                _resetOutput = NO;
            }
        }
    
}

/*
 * 释放资源
 */
- (void)freeX264Resource
{
    if (pHandle) {
       x264_encoder_close(pHandle);
       pHandle = NULL;
    }
    
    if (pParam) {
       free(pParam);
       pParam = NULL;
    }
    
    fclose(fp_dst);
}

- (int)initPout {
    outpath = [self savedFilePathStr];
    
    NSUInteger len = [outpath length];
    char *filepath = (char*)malloc(sizeof(char) * (len + 1));
    
    [outpath getCString:filepath maxLength:len + 1 encoding:[NSString defaultCStringEncoding]];
    
    fp_dst = NULL;
    fp_dst = fopen(filepath, "wb");
    //Check
    if(fp_dst==NULL){
        free(filepath);
        printf("Error open files.n");
        return -1;
    }
    
    free(filepath);
    return 0;
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
    return [filename stringByAppendingString:@".h264"];
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
