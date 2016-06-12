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
@end

@implementation ViewController

- (IBAction)start:(id)sender {
    if (_startLive.tag==0) {
        [_session startRunning];
        _startLive.tag=1;
        [_startLive setTitle:@"暂停直播" forState:UIControlStateNormal];
        _videoConnection=[_videoOUTput connectionWithMediaType:AVMediaTypeVideo];
        _audioConnection=[_audioOUTput connectionWithMediaType:AVMediaTypeAudio];
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
    AVCaptureDevice* audiodevice=[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    AVCaptureDeviceInput* videoInput=[[AVCaptureDeviceInput alloc]initWithDevice:videodevice error:nil];
    AVCaptureDeviceInput* audioInput=[[AVCaptureDeviceInput alloc]initWithDevice:audiodevice error:nil];
    if ([_session canAddInput:videoInput]) {
        [_session addInput:videoInput];
    }
    if ([_session canAddInput:audioInput]) {
        [_session addInput:audioInput];
    }
    
  _videoOUTput=[[AVCaptureVideoDataOutput alloc]init];
    [_videoOUTput setSampleBufferDelegate:self queue:dispatch_queue_create("video", DISPATCH_QUEUE_SERIAL)];
    if ([_session canAddOutput:_videoOUTput]) {
        [_session addOutput:_videoOUTput];
    }
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
        NSLog(@"video width:%ld,height:%ld,%@",width,height,pixelbuffer);
        //在此编码h.264
    }
    else if(connection   ==_audioConnection){
       // 在此编码AAc；
        NSLog(@"ok");
    }
    NSLog(@"");

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
