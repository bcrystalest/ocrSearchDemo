//
//  NumCaptureViewController.m
//  OCRSearchDemo
//
//  Created by 陈威利 on 2017/11/15.
//  Copyright © 2017年 陈威利. All rights reserved.
//

#import "NumCaptureViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "LHSIDCardScaningView.h"
#import "IDInfo.h"
#import "excards.h"
#import "IDInfoViewController.h"
#import "UIImage+Extend.h"
#import "RectManager.h"
#import "UIAlertController+Extend.h"

@interface NumCaptureViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureMetadataOutputObjectsDelegate>
// 摄像头设备
@property (nonatomic,strong) AVCaptureDevice *device;

// AVCaptureSession对象来执行输入设备和输出设备之间的数据传递
@property (nonatomic,strong) AVCaptureSession *session;

// 输出格式
@property (nonatomic,strong) NSNumber *outPutSetting;

// 出流对象
@property (nonatomic,strong) AVCaptureVideoDataOutput *videoDataOutput;

// 元数据（用于人脸识别）
@property (nonatomic,strong) AVCaptureMetadataOutput *metadataOutput;

// 预览图层
@property (nonatomic,strong) AVCaptureVideoPreviewLayer *previewLayer;

// 人脸检测框区域
@property (nonatomic,assign) CGRect faceDetectionFrame;

// 队列
@property (nonatomic,strong) dispatch_queue_t queue;

// 是否打开手电筒
@property (nonatomic,assign,getter = isTorchOn) BOOL torchOn;
@end

@implementation NumCaptureViewController

#pragma mark - 检测是模拟器还是真机
#if TARGET_IPHONE_SIMULATOR
// 是模拟器的话，提示“请使用真机测试！！！”
-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"扫描合同文本";
    
    __weak __typeof__(self) weakSelf = self;
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"返回" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"模拟器没有摄像设备" message:@"请使用真机测试！！！" okAction:okAction cancelAction:nil];
    
    [self presentViewController:alertC animated:YES completion:nil];
}
#else
#pragma mark - 懒加载
#pragma mark device
-(AVCaptureDevice *)device {
    if (_device == nil) {
        _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        NSError *error = nil;
        if ([_device lockForConfiguration:&error]) {
            if ([_device isSmoothAutoFocusSupported]) {// 平滑对焦
                _device.smoothAutoFocusEnabled = YES;
            }
            
            if ([_device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {// 自动持续对焦
                _device.focusMode = AVCaptureFocusModeContinuousAutoFocus;
            }
            
            if ([_device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure ]) {// 自动持续曝光
                _device.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
            }
            
            if ([_device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance]) {// 自动持续白平衡
                _device.whiteBalanceMode = AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance;
            }
            
            //            NSError *error1;
            //            CMTime frameDuration = CMTimeMake(1, 30); // 默认是1秒30帧
            //            NSArray *supportedFrameRateRanges = [_device.activeFormat videoSupportedFrameRateRanges];
            //            BOOL frameRateSupported = NO;
            //            for (AVFrameRateRange *range in supportedFrameRateRanges) {
            //                if (CMTIME_COMPARE_INLINE(frameDuration, >=, range.minFrameDuration) && CMTIME_COMPARE_INLINE(frameDuration, <=, range.maxFrameDuration)) {
            //                    frameRateSupported = YES;
            //                }
            //            }
            //
            //            if (frameRateSupported && [self.device lockForConfiguration:&error1]) {
            //                [_device setActiveVideoMaxFrameDuration:frameDuration];
            //                [_device setActiveVideoMinFrameDuration:frameDuration];
            ////                [self.device unlockForConfiguration];
            //            }
            
            [_device unlockForConfiguration];
        }
    }
    
    return _device;
}

#pragma mark outPutSetting
-(NSNumber *)outPutSetting {
    if (_outPutSetting == nil) {
        _outPutSetting = @(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange);
    }
    
    return _outPutSetting;
}

#pragma mark metadataOutput
-(AVCaptureMetadataOutput *)metadataOutput {
    if (_metadataOutput == nil) {
        _metadataOutput = [[AVCaptureMetadataOutput alloc]init];
        
        [_metadataOutput setMetadataObjectsDelegate:self queue:self.queue];
    }
    
    return _metadataOutput;
}

#pragma mark videoDataOutput
-(AVCaptureVideoDataOutput *)videoDataOutput {
    if (_videoDataOutput == nil) {
        _videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
        
        _videoDataOutput.alwaysDiscardsLateVideoFrames = YES;
        _videoDataOutput.videoSettings = @{(id)kCVPixelBufferPixelFormatTypeKey:self.outPutSetting};
        
        [_videoDataOutput setSampleBufferDelegate:self queue:self.queue];
    }
    
    return _videoDataOutput;
}

#pragma mark session
-(AVCaptureSession *)session {
    if (_session == nil) {
        _session = [[AVCaptureSession alloc] init];
        
        _session.sessionPreset = AVCaptureSessionPresetHigh;
        
        // 2、设置输入：由于模拟器没有摄像头，因此最好做一个判断
        NSError *error = nil;
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:&error];
        
        if (error) {
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
            [self alertControllerWithTitle:@"没有摄像设备" message:error.localizedDescription okAction:okAction cancelAction:nil];
        }else {
            if ([_session canAddInput:input]) {
                [_session addInput:input];
            }
            
            if ([_session canAddOutput:self.videoDataOutput]) {
                [_session addOutput:self.videoDataOutput];
            }
            
            if ([_session canAddOutput:self.metadataOutput]) {
                [_session addOutput:self.metadataOutput];
                // 输出格式要放在addOutPut之后，否则奔溃
                self.metadataOutput.metadataObjectTypes = @[AVMetadataObjectTypeFace];
            }
        }
    }
    
    return _session;
}

#pragma mark previewLayer
-(AVCaptureVideoPreviewLayer *)previewLayer {
    if (_previewLayer == nil) {
        _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
        
        _previewLayer.frame = self.view.frame;
        _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    
    return _previewLayer;
}

#pragma mark queue
-(dispatch_queue_t)queue {
    if (_queue == nil) {
        //        _queue = dispatch_queue_create("AVCaptureSession_Start_Running_Queue", DISPATCH_QUEUE_SERIAL);
        _queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    }
    
    return _queue;
}

#pragma mark - 运行session
// session开始，即输入设备和输出设备开始数据传递
- (void)runSession {
    if (![self.session isRunning]) {
        dispatch_async(self.queue, ^{
            [self.session startRunning];
        });
    }
}

#pragma mark - 停止session
// session停止，即输入设备和输出设备结束数据传递
-(void)stopSession {
    if ([self.session isRunning]) {
        dispatch_async(self.queue, ^{
            [self.session stopRunning];
        });
    }
}

#pragma mark - 打开／关闭手电筒
-(void)turnOnOrOffTorch {
    self.torchOn = !self.isTorchOn;
    
    if ([self.device hasTorch]){ // 判断是否有闪光灯
        [self.device lockForConfiguration:nil];// 请求独占访问硬件设备
        
        if (self.isTorchOn) {
            self.navigationItem.rightBarButtonItem.image = [[UIImage imageNamed:@"nav_torch_on"] originalImage];
            [self.device setTorchMode:AVCaptureTorchModeOn];
        } else {
            self.navigationItem.rightBarButtonItem.image = [[UIImage imageNamed:@"nav_torch_off"] originalImage];
            [self.device setTorchMode:AVCaptureTorchModeOff];
        }
        [self.device unlockForConfiguration];// 请求解除独占访问硬件设备
    }else {
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
        [self alertControllerWithTitle:@"提示" message:@"您的设备没有闪光设备，不能提供手电筒功能，请检查" okAction:okAction cancelAction:nil];
    }
}

#pragma mark - view即将出现时
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 将AVCaptureViewController的navigationBar调为透明
    //    [[[self.navigationController.navigationBar subviews] objectAtIndex:0] setAlpha:0];
    //    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    // 每次展现AVCaptureViewController的界面时，都检查摄像头使用权限
    [self checkAuthorizationStatus];
    
    // rightBarButtonItem设为原样
    self.torchOn = NO;
    self.navigationItem.rightBarButtonItem.image = [[UIImage imageNamed:@"nav_torch_off"] originalImage];
}

#pragma mark - view即将消失时
-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // 将AVCaptureViewController的navigationBar调为不透明
    [[[self.navigationController.navigationBar subviews] objectAtIndex:0] setAlpha:1];
    //    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor]}];
    
    [self stopSession];
}

#pragma mark - 检测摄像头权限
-(void)checkAuthorizationStatus {
    AVAuthorizationStatus authorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    switch (authorizationStatus) {
        case AVAuthorizationStatusNotDetermined:[self showAuthorizationNotDetermined]; break;// 用户尚未决定授权与否，那就请求授权
        case AVAuthorizationStatusAuthorized:[self showAuthorizationAuthorized]; break;// 用户已授权，那就立即使用
        case AVAuthorizationStatusDenied:[self showAuthorizationDenied]; break;// 用户明确地拒绝授权，那就展示提示
        case AVAuthorizationStatusRestricted:[self showAuthorizationRestricted]; break;// 无法访问相机设备，那就展示提示
    }
}

#pragma mark 使用相机设备受限
-(void)showAuthorizationRestricted {
    NSString *title = @"相机设备受限";
    NSString *message = @"请检查您的手机硬件或设置";
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [self alertControllerWithTitle:title message:message okAction:okAction cancelAction:nil];
}

#pragma mark - 相机使用权限处理
#pragma mark 用户还未决定是否授权使用相机
-(void)showAuthorizationNotDetermined {
    __weak __typeof__(self) weakSelf = self;
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        granted? [weakSelf runSession]: [weakSelf showAuthorizationDenied];
    }];
}

#pragma mark 被授权使用相机
-(void)showAuthorizationAuthorized {
    [self runSession];
}

#pragma mark 未被授权使用相机
-(void)showAuthorizationDenied {
    NSString *title = @"相机未授权";
    NSString *message = @"请到系统的“设置-隐私-相机”中授权此应用使用您的相机";
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 跳转到该应用的隐私设授权置界面
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    
    [self alertControllerWithTitle:title message:message okAction:okAction cancelAction:cancelAction];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - 展示UIAlertController
-(void)alertControllerWithTitle:(NSString *)title message:(NSString *)message okAction:(UIAlertAction *)okAction cancelAction:(UIAlertAction *)cancelAction {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message okAction:okAction cancelAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#endif

@end
