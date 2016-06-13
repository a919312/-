//
//  ViewController.m
//  直播采集数据
//
//  Created by txy on 16/6/8.
//  Copyright © 2016年 txy. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface ViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate>
{
    BOOL enableROTation;
}
@property(strong,nonatomic)AVCaptureVideoPreviewLayer* videoPreviewLayer;
@property (weak, nonatomic) IBOutlet UIButton *startLive;
@property(strong,nonatomic)AVCaptureSession* session;
@property(assign,nonatomic)BOOL isUsingFrontCamera;
@property(strong,nonatomic)AVCaptureVideoDataOutput* videoOUTput;
@property(strong,nonatomic)AVCaptureAudioDataOutput* audioOUTput;
@property(nonatomic,strong)AVCaptureConnection* videoConnection;
@property(strong,nonatomic)AVCaptureConnection* audioConnection;
@property(nonatomic,strong) UIImageView* ima;
@end

@implementation ViewController

- (IBAction)start:(id)sender {
    if (_startLive.tag==0) {
        _startLive.tag=1;
        [_startLive setTitle:@"暂停直播" forState:UIControlStateNormal];
        _videoConnection=[_videoOUTput connectionWithMediaType:AVMediaTypeVideo];
        _audioConnection=[_audioOUTput connectionWithMediaType:AVMediaTypeAudio];
        [_session startRunning];
        
    }
    else{
        _startLive.tag=0;
        [_startLive setTitle:@"开始直播" forState:UIControlStateNormal];
        [_session stopRunning];
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _startLive.tag=0;
    _session=[[AVCaptureSession alloc]init];
    
    AVCaptureDevice* videodevice=[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo] ;
    //videodevice.activeVideoMinFrameDuration=CMTimeMake(1.0, 24.0);
    AVCaptureDevice* audiodevice=[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    //audiodevice.activeVideoMinFrameDuration=CMTimeMake(1.0, 24.0);
    AVCaptureDeviceInput* videoInput=[[AVCaptureDeviceInput alloc]initWithDevice:videodevice error:nil];
    AVCaptureDeviceInput* audioInput=[[AVCaptureDeviceInput alloc]initWithDevice:audiodevice error:nil];
    // 配置采集帧率
    NSError *error;
    CMTime frameDuration = CMTimeMake(1, 60);
    NSArray *supportedFrameRateRanges = [videodevice.activeFormat videoSupportedFrameRateRanges];
    BOOL frameRateSupported = NO;
    for (AVFrameRateRange *range in supportedFrameRateRanges) {
        if (CMTIME_COMPARE_INLINE(frameDuration, >=, range.minFrameDuration) &&
            CMTIME_COMPARE_INLINE(frameDuration, <=, range.maxFrameDuration)) {
            frameRateSupported = YES;
        }
    }
    //防抖动，ios6以后和iphone4s以后引入的新功能
    if (frameRateSupported && [videodevice lockForConfiguration:&error]) {
        [videodevice setActiveVideoMaxFrameDuration:frameDuration];
        [videodevice setActiveVideoMinFrameDuration:frameDuration];
        [videodevice unlockForConfiguration];
    }
    if ([_session canAddInput:videoInput]) {
        [_session addInput:videoInput];
    }
    if ([_session canAddInput:audioInput]) {
        [_session addInput:audioInput];
    }
    
  _videoOUTput=[[AVCaptureVideoDataOutput alloc]init];
    _videoOUTput.alwaysDiscardsLateVideoFrames=YES;
    
    [_videoOUTput setSampleBufferDelegate:self queue:dispatch_queue_create("video", DISPATCH_QUEUE_SERIAL)];
    if ([_session canAddOutput:_videoOUTput]) {
        [_session addOutput:_videoOUTput];
    }
    NSString* key = (NSString*)kCVPixelBufferPixelFormatTypeKey;
    NSNumber* value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA];
    
    NSDictionary* videoSettings = [NSDictionary dictionaryWithObject:value forKey:key];
    [_videoOUTput setVideoSettings:videoSettings];
    _audioOUTput=[[AVCaptureAudioDataOutput alloc]init];
    [_audioOUTput setSampleBufferDelegate:self queue:dispatch_queue_create("audio", DISPATCH_QUEUE_SERIAL)];
    if ([_session canAddOutput:_audioOUTput]) {
        [_session addOutput:_audioOUTput];
    }
    _isUsingFrontCamera=NO;
    enableROTation=YES;
    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.session];
    CALayer *layer = self.view.layer;
    layer.masksToBounds = YES;
    _videoPreviewLayer.frame = layer.bounds;
    _videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [layer addSublayer:self.videoPreviewLayer];
    [layer insertSublayer:_startLive.layer above:_videoPreviewLayer];
    
    _ima=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 200, 200)];
    [_ima setImage:[UIImage imageNamed:@"1"]];
    [self.view addSubview:_ima];
    // Do any additional setup after loading the view, typically from a nib.
}
-(void)viewWillAppear:(BOOL)animated{
    [self initAVCpture];
}
-(void)initAVCpture{
    
}
-(void)viewDidAppear:(BOOL)animated{
    
}
-(void)viewWillDisappear:(BOOL)animated{
    [_session stopRunning];
}
#pragma mark delegate
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    if (connection ==_videoConnection) {
        CVPixelBufferRef pixelbuffer=CMSampleBufferGetImageBuffer(sampleBuffer);
        long width =CVPixelBufferGetWidth(pixelbuffer);
        long height=CVPixelBufferGetHeight(pixelbuffer);
       // NSLog(@"video width:%ld,height:%ld,%@",width,height,pixelbuffer);
        //在此编码h.264
        NSData* videoData=[ViewController dataWithYUVPixelBuffer:pixelbuffer];
    
        
//        UIImage *image = [self imageFromSampleBuffer:sampleBuffer];
//        [_ima setImage:image];
//        [self.view.layer insertSublayer:_ima.layer above:_videoPreviewLayer];
       // < 此处添加使用该image对象的代码 >

    }
    else if(connection   ==_audioConnection){
       // 在此编码AAc；
        
    }
    

}

// 通过抽样缓存数据创建一个UIImage对象
- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
    // 为媒体数据设置一个CMSampleBuffer的Core Video图像缓存对象
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // 锁定pixel buffer的基地址
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // 得到pixel buffer的基地址
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // 得到pixel buffer的行字节数
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // 得到pixel buffer的宽和高
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // 创建一个依赖于设备的RGB颜色空间
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // 用抽样缓存的数据创建一个位图格式的图形上下文（graphics context）对象
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // 根据这个位图context中的像素数据创建一个Quartz image对象
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // 解锁pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    // 释放context和颜色空间
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    // 用Quartz image创建一个UIImage对象image
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    
    // 释放Quartz image对象
    CGImageRelease(quartzImage);
    
    return (image);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

+ (NSData *)dataWithYUVPixelBuffer:(CVPixelBufferRef)pixelBuffer
{
    size_t width = CVPixelBufferGetWidth(pixelBuffer);
    size_t height  = CVPixelBufferGetHeight(pixelBuffer);
    unsigned char* buffer = (unsigned char*) malloc(width * height * 1.5);
    // 取视频YUV数据
    [self copyDataFromYUVPixelBuffer:pixelBuffer toBuffer:buffer];
    // 保存到本地
    NSData *retData = [NSData dataWithBytes:buffer length:sizeof(unsigned char)*(width*height*1.5)];
    free(buffer);
    buffer = nil;
    return retData;
}

//the size of buffer has to be width * height * 1.5 (yuv)
+ (void) copyDataFromYUVPixelBuffer:(CVPixelBufferRef)pixelBuffer toBuffer:(unsigned char*)buffer {
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    if (CVPixelBufferIsPlanar(pixelBuffer)) {
        size_t w = CVPixelBufferGetWidth(pixelBuffer);
        size_t h = CVPixelBufferGetHeight(pixelBuffer);
        
        size_t d = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 0);
        unsigned char* src = (unsigned char*) CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
        unsigned char* dst = buffer;
        
        for (unsigned int rIdx = 0; rIdx < h; ++rIdx, dst += w, src += d) {
            memcpy(dst, src, w);
        }
        
        d = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 1);
        src = (unsigned char *) CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1);
        
        h = h >> 1;
        for (unsigned int rIdx = 0; rIdx < h; ++rIdx, dst += w, src += d) {
            memcpy(dst, src, w);
        }
    }
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    
}
@end
