//
//  FaceRequestViewController.m
//  IFlyFaceDemo
//
//  Created by 张剑 on 14-10-13.
//  Copyright (c) 2014年 iflytek. All rights reserved.
//

#import "FaceRequestViewController.h"
#import "UIImage+Extensions.h"
#import "UIImage+compress.h"
#import "DemoPreDefine.h"
#import "FaceRequestSettingViewController.h"
#import "PermissionDetector.h"
#import "iflyMSC/IFlyFaceSDK.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "IFlyFaceResultKeys.h"

@interface FaceRequestViewController ()
<
IFlyFaceRequestDelegate,
UINavigationControllerDelegate,
UIImagePickerControllerDelegate,
UIActionSheetDelegate,
UIPopoverControllerDelegate
>

@property (nonatomic,retain) IFlyFaceRequest * iFlySpFaceRequest;
@property (nonatomic,retain) IBOutlet UILabel *labelView;
@property (nonatomic,retain) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic,retain) IBOutlet UIImageView *imgToUse;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *imgSelectBtn;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *funcSelectBtn;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *settingBtn;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *backBtn;
@property (nonatomic,retain) UIPopoverController *popover;
@property (nonatomic,retain) CALayer *imgToUseCoverLayer;
@property (nonatomic,retain) NSString *resultStings;
@property (nonatomic,assign) int keyboardHight;
@property (nonatomic,retain) FaceRequestSettingViewController* settingViewController;

@end

@implementation FaceRequestViewController

@synthesize iFlySpFaceRequest=_iFlySpFaceRequest;
@synthesize labelView=_labelView;
@synthesize activityIndicator=_activityIndicator;
@synthesize imgSelectBtn=_imgSelectBtn;
@synthesize funcSelectBtn=_funcSelectBtn;
@synthesize settingBtn=_settingBtn;
@synthesize backBtn=_backBtn;
@synthesize imgToUse=_imgToUse;
@synthesize imgToUseCoverLayer=_imgToUseCoverLayer;
@synthesize settingViewController=_settingViewController;

- (void)viewDidLoad{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.title=@"在线人脸识别示例";
    
    //adjust the UI for iOS 7
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    if ( IOS7_OR_LATER ){
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = NO;
        self.navigationController.navigationBar.translucent = NO;
    }
#endif
    
    self.iFlySpFaceRequest=[IFlyFaceRequest sharedInstance];
    [self.iFlySpFaceRequest setDelegate:self];
    self.imgToUse.contentMode = UIViewContentModeScaleAspectFit;
    self.labelView.textAlignment=NSTextAlignmentCenter;
    [self.activityIndicator setHidden:YES];
    CGRect rect= self.activityIndicator.frame;
    self.activityIndicator.frame=CGRectMake(rect.origin.x-1.5*rect.size.width, rect.origin.y-1.5*rect.size.height, 3*rect.size.width, 3*rect.size.height);
    self.imgSelectBtn.enabled=YES;
    self.labelView.numberOfLines=0;
    self.resultStings=[[NSString alloc] init];

}

-(void)dealloc{
    self.popover=nil;
    self.iFlySpFaceRequest=nil;
    self.imgToUse=nil;
    self.imgToUseCoverLayer=nil;
    self.settingViewController=nil;
    self.resultStings=nil;
}

-(void)showAlert:(NSString*)info{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:info delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
    alert=nil;
}

#pragma mark - button event

- (void)presentImagePicker:(UIImagePickerController* )picker{
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
//        if(self.popover){
//            self.popover=nil;
//        }
//        self.popover=[[UIPopoverController alloc] initWithContentViewController:picker];
//        self.popover.delegate=self;
//        [self.popover presentPopoverFromBarButtonItem: self.imgSelectBtn
//                             permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
//    }
//    else
    {
        [self presentViewController:picker animated:YES completion:nil];
    }
}

- (IBAction)btnSelectImageClicked:(id)sender{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"图片获取方式" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"摄相机", @"图片库", nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
    actionSheet.alpha = 1.f;
    actionSheet.tag = 1;
    
    UIView *bgView=[[UIView alloc] initWithFrame:actionSheet.frame];
    bgView.backgroundColor = [UIColor lightGrayColor];
    [actionSheet addSubview:bgView];
    bgView=nil;
    
    [actionSheet showInView:self.view];
    actionSheet=nil;

}
- (IBAction)btnRecognizeImageClicked:(id)sender{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"接口功能示例"
                                                             delegate:self
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:
                                                                      @"注册",
                                                                      @"验证",
                                                                      @"人脸检测",
                                                                      @"人脸关键点检测",
                                                                      nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
    actionSheet.alpha = 1.0f;
    actionSheet.tag = 2;
    UIView *bgView=[[UIView alloc] initWithFrame:actionSheet.frame];
    bgView.backgroundColor = [UIColor lightGrayColor];
    [actionSheet addSubview:bgView];
    bgView=nil;
    
    [actionSheet showInView:self.view];
    actionSheet=nil;
}


- (IBAction)btnbackClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnSettingClicked:(id)sender{
    if(!self.settingViewController){
        _settingViewController=[[FaceRequestSettingViewController alloc] initWithStyle:UITableViewStyleGrouped];
    }
    [self.navigationController pushViewController: _settingViewController animated:YES];
}

- (void)btnExploerClicked:(id)sender {
    
    if(![PermissionDetector isAssetsLibraryPermissionGranted]){
        NSString* info=@"没有相册权限";
        [self showAlert:info];
        return;
    }
    
    _backBtn.enabled=NO;
    _imgSelectBtn.enabled=NO;
    _settingBtn.enabled=NO;
    _funcSelectBtn.enabled=NO;
    _labelView.text=@"";
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.modalPresentationStyle = UIModalPresentationCurrentContext;
    if([UIImagePickerController isSourceTypeAvailable: picker.sourceType ]) {
        picker.mediaTypes = @[(NSString*)kUTTypeImage];
        picker.delegate = self;
        picker.allowsEditing = NO;
    }
    
    [self performSelector:@selector(presentImagePicker:) withObject:picker afterDelay:1.0f];
}

- (void)btnPhotoClicked:(id)sender {
    
    if(![PermissionDetector isCapturePermissionGranted]){
        NSString* info=@"没有相机权限";
        [self showAlert:info];
        return;
    }
    
    _backBtn.enabled=NO;
    _imgSelectBtn.enabled=NO;
    _settingBtn.enabled=NO;
    _funcSelectBtn.enabled=NO;
    _labelView.text=@"";
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController * picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.modalPresentationStyle = UIModalPresentationFullScreen;
        if([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]){
            picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        }
       
        picker.mediaTypes = @[(NSString*)kUTTypeImage];
        picker.allowsEditing = NO;//设置可编辑
        picker.delegate = self;

        [self performSelector:@selector(presentImagePicker:) withObject:picker afterDelay:1.0f];

    }else{
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"设备不可用" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        alert=nil;
        _backBtn.enabled=YES;
        _imgSelectBtn.enabled=YES;
        _settingBtn.enabled=YES;
        _funcSelectBtn.enabled=YES;
    }
}

- (void)btnRegClicked:(id)sender {
    self.resultStings=nil;
    self.resultStings=[[NSString alloc] init];
    
    if(_imgToUseCoverLayer){
        _imgToUseCoverLayer.sublayers=nil;
        [_imgToUseCoverLayer removeFromSuperlayer];
        _imgToUseCoverLayer=nil;
    }
    [_activityIndicator startAnimating];
    [_activityIndicator setHidden:NO];
    _backBtn.enabled=NO;
    _imgSelectBtn.enabled=NO;
    _settingBtn.enabled=NO;
    _funcSelectBtn.enabled=NO;
    _labelView.text=@"";
    [self.iFlySpFaceRequest setParameter:[IFlySpeechConstant FACE_REG] forKey:[IFlySpeechConstant FACE_SST]];
    [self.iFlySpFaceRequest setParameter:USER_APPID forKey:[IFlySpeechConstant APPID]];
    [self.iFlySpFaceRequest setParameter:USER_APPID forKey:@"auth_id"];
    [self.iFlySpFaceRequest setParameter:@"del" forKey:@"property"];
//  压缩图片大小
    NSData* imgData=[_imgToUse.image compressedData];
    NSLog(@"reg image data length: %lu",(unsigned long)[imgData length]);
    [self.iFlySpFaceRequest sendRequest:imgData];

}

- (void)btnVerifyClicked:(id)sender {
    
    self.resultStings=nil;
    self.resultStings=[[NSString alloc] init];
    
    if(_imgToUseCoverLayer){
        _imgToUseCoverLayer.sublayers=nil;
        [_imgToUseCoverLayer removeFromSuperlayer];
        _imgToUseCoverLayer=nil;
    }
    [_activityIndicator startAnimating];
    [_activityIndicator setHidden:NO];
    _backBtn.enabled=NO;
    _imgSelectBtn.enabled=NO;
    _settingBtn.enabled=NO;
    _funcSelectBtn.enabled=NO;
    _labelView.text=@"";
    
    [self.iFlySpFaceRequest setParameter:[IFlySpeechConstant FACE_VERIFY] forKey:[IFlySpeechConstant FACE_SST]];
    [self.iFlySpFaceRequest setParameter:USER_APPID forKey:[IFlySpeechConstant APPID]];
    [self.iFlySpFaceRequest setParameter:USER_APPID forKey:@"auth_id"];
    
    NSUserDefaults* userDefaults=[NSUserDefaults standardUserDefaults];
    NSString* gid=[userDefaults objectForKey:KCIFlyFaceResultGID];
    if(!gid){
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"结果" message:@"请先注册，或在设置中输入已注册的gid" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        alert=nil;
        [_activityIndicator stopAnimating];
        [_activityIndicator setHidden:YES];
        _backBtn.enabled=YES;
        _imgSelectBtn.enabled=YES;
        _settingBtn.enabled=YES;
        _funcSelectBtn.enabled=YES;
        return;
    }
    [self.iFlySpFaceRequest setParameter:gid forKey:[IFlySpeechConstant FACE_GID]];
    [self.iFlySpFaceRequest setParameter:@"2000" forKey:@"wait_time"];
    //  压缩图片大小
    NSData* imgData=[_imgToUse.image compressedData];
    NSLog(@"verify image data length: %lu",(unsigned long)[imgData length]);
    [self.iFlySpFaceRequest sendRequest:imgData];

}

- (void)btnDetectClicked:(id)sender {
    
    self.resultStings=nil;
    self.resultStings=[[NSString alloc] init];
    
    if(_imgToUseCoverLayer){
        _imgToUseCoverLayer.sublayers=nil;
        [_imgToUseCoverLayer removeFromSuperlayer];
        _imgToUseCoverLayer=nil;
    }
    [_activityIndicator startAnimating];
    [_activityIndicator setHidden:NO];
    _backBtn.enabled=NO;
    _imgSelectBtn.enabled=NO;
    _settingBtn.enabled=NO;
    _funcSelectBtn.enabled=NO;
    _labelView.text=@"";
    [self.iFlySpFaceRequest setParameter:[IFlySpeechConstant FACE_DETECT] forKey:[IFlySpeechConstant FACE_SST]];
    [self.iFlySpFaceRequest setParameter:USER_APPID forKey:[IFlySpeechConstant APPID]];
    //  压缩图片大小
    NSData* imgData=[_imgToUse.image compressedData];
    NSLog(@"detect image data length: %lu",(unsigned long)[imgData length]);
    [self.iFlySpFaceRequest sendRequest:imgData];

}

- (void)btnAlignClicked:(id)sender {
    
    self.resultStings=nil;
    self.resultStings=[[NSString alloc] init];
    
    if(_imgToUseCoverLayer){
        _imgToUseCoverLayer.sublayers=nil;
        [_imgToUseCoverLayer removeFromSuperlayer];
        _imgToUseCoverLayer=nil;
    }
    [_activityIndicator startAnimating];
    [_activityIndicator setHidden:NO];
    _backBtn.enabled=NO;
    _imgSelectBtn.enabled=NO;
    _settingBtn.enabled=NO;
    _funcSelectBtn.enabled=NO;
    _labelView.text=@"";
    [self.iFlySpFaceRequest setParameter:[IFlySpeechConstant FACE_ALIGN] forKey:[IFlySpeechConstant FACE_SST]];
    [self.iFlySpFaceRequest setParameter:USER_APPID forKey:[IFlySpeechConstant APPID]];
    //  压缩图片大小
    NSData* imgData=[_imgToUse.image compressedData];
    NSLog(@"align image data length: %lu",(unsigned long)[imgData length]);
    [self.iFlySpFaceRequest sendRequest:imgData];

}

- (void)btnAttrClicked:(id)sender {
    
    self.resultStings=nil;
    self.resultStings=[[NSString alloc] init];
    
    if(_imgToUseCoverLayer){
        _imgToUseCoverLayer.sublayers=nil;
        [_imgToUseCoverLayer removeFromSuperlayer];
        _imgToUseCoverLayer=nil;
    }
    [_activityIndicator startAnimating];
    [_activityIndicator setHidden:NO];
    _backBtn.enabled=NO;
    _imgSelectBtn.enabled=NO;
    _settingBtn.enabled=NO;
    _funcSelectBtn.enabled=NO;
    _labelView.text=@"";
    [self.iFlySpFaceRequest setParameter:[IFlySpeechConstant FACE_ATTR] forKey:[IFlySpeechConstant FACE_SST]];
    [self.iFlySpFaceRequest setParameter:USER_APPID forKey:[IFlySpeechConstant APPID]];
    //  压缩图片大小
    NSData* imgData=[_imgToUse.image compressedData];
    NSLog(@"attr image data length: %lu",(unsigned long)[imgData length]);
    [self.iFlySpFaceRequest sendRequest:imgData];
    
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    switch (actionSheet.tag)
    {
        case 1://选择图片
            switch (buttonIndex)
        {
            _labelView.hidden = YES;
            case 0:
            {
                [self btnPhotoClicked:nil];
            }
                break;
            case 1:
            {
                [self btnExploerClicked:nil];
            }
                break;
        }
            break;
        case 2://选择功能
            switch (buttonIndex)
        {
            _labelView.hidden = YES;
            case 0:
            {
                [self btnRegClicked:nil];
                
            }
                break;
            case 1:
            {
                [self btnVerifyClicked:nil];
            }
                break;
            case 2:
            {
                [self btnDetectClicked:nil];
            }
                break;
            case 3:
            {
                [self btnAlignClicked:nil];
            }
                break;
        }
            break;
    }
}
#pragma mark - Data Parser

-(void)praseRegResult:(NSString*)result{
    NSString *resultInfo = @"";
    NSString *resultInfoForLabel = @"";

    @try {
        NSError* error;
        NSData* resultData=[result dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary* dic=[NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:&error];
        
        if(dic){
            NSString* strSessionType=[dic objectForKey:KCIFlyFaceResultSST];
            
            //注册
            if([strSessionType isEqualToString:KCIFlyFaceResultReg]){
                NSString* rst=[dic objectForKey:KCIFlyFaceResultRST];
                NSString* ret=[dic objectForKey:KCIFlyFaceResultRet];
                if([ret integerValue]!=0){
                    resultInfo=[resultInfo stringByAppendingFormat:@"注册错误\n错误码：%@",ret];
                }else{
                    if(rst && [rst isEqualToString:KCIFlyFaceResultSuccess]){
                        NSString* gid=[dic objectForKey:KCIFlyFaceResultGID];
                        resultInfo=[resultInfo stringByAppendingString:@"检测到人脸\n注册成功！"];
                        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
                        [defaults setObject:gid forKey:KCIFlyFaceResultGID];
                        resultInfoForLabel=[resultInfoForLabel stringByAppendingFormat:@"gid:%@",gid];
                    }else{
                        resultInfo=[resultInfo stringByAppendingString:@"未检测到人脸\n注册失败！"];
                    }
                }
            }
            _labelView.text=resultInfoForLabel;
            _labelView.textColor=[UIColor redColor];
            _labelView.hidden=NO;
            [_activityIndicator stopAnimating];
            [_activityIndicator setHidden:YES];
            _backBtn.enabled=YES;
            _imgSelectBtn.enabled=YES;
            _settingBtn.enabled=YES;
            _funcSelectBtn.enabled=YES;

            [self performSelectorOnMainThread:@selector(showResultInfo:) withObject:resultInfo waitUntilDone:NO];
        }

    }
    @catch (NSException *exception) {
        NSLog(@"prase exception:%@",exception.name);
    }
    @finally {
    }
    

}

-(void)praseVerifyResult:(NSString*)result{
    NSString *resultInfo = @"";
    NSString *resultInfoForLabel = @"";
    
    @try {
        NSError* error;
        NSData* resultData=[result dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary* dic=[NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:&error];
        
        if(dic){
            NSString* strSessionType=[dic objectForKey:KCIFlyFaceResultSST];
            
            if([strSessionType isEqualToString:KCIFlyFaceResultVerify]){
                NSString* rst=[dic objectForKey:KCIFlyFaceResultRST];
                NSString* ret=[dic objectForKey:KCIFlyFaceResultRet];
                if([ret integerValue]!=0){
                    resultInfo=[resultInfo stringByAppendingFormat:@"验证错误\n错误码：%@",ret];
                }else{
                    
                    if([rst isEqualToString:KCIFlyFaceResultSuccess]){
                        resultInfo=[resultInfo stringByAppendingString:@"检测到人脸\n"];
                    }else{
                        resultInfo=[resultInfo stringByAppendingString:@"未检测到人脸\n"];
                    }
                    NSString* verf=[dic objectForKey:KCIFlyFaceResultVerf];
                    NSString* score=[dic objectForKey:KCIFlyFaceResultScore];
                    if([verf boolValue]){
                        resultInfoForLabel=[resultInfoForLabel stringByAppendingFormat:@"score:%@\n",score];
                        resultInfo=[resultInfo stringByAppendingString:@"验证结果:验证成功!"];
                    }else{
                        NSUserDefaults* defaults=[NSUserDefaults standardUserDefaults];
                        NSString* gid=[defaults objectForKey:KCIFlyFaceResultGID];
                        resultInfoForLabel=[resultInfoForLabel stringByAppendingFormat:@"last reg gid:%@\n",gid];
                        resultInfo=[resultInfo stringByAppendingString:@"验证结果:验证失败!"];
                    }
                }
                
            }
            
            _labelView.text=resultInfoForLabel;
            _labelView.textColor=[UIColor redColor];
            _labelView.hidden=NO;
            [_activityIndicator stopAnimating];
            [_activityIndicator setHidden:YES];
            _backBtn.enabled=YES;
            _imgSelectBtn.enabled=YES;
            _settingBtn.enabled=YES;
            _funcSelectBtn.enabled=YES;
            
            if([resultInfo length]<1){
                resultInfo=@"结果异常";
            }
            
            [self performSelectorOnMainThread:@selector(showResultInfo:) withObject:resultInfo waitUntilDone:NO];
        }

    }
    @catch (NSException *exception) {
        NSLog(@"prase exception:%@",exception.name);
    }
    @finally {
        
    }
    
    
}

-(void)praseDetectResult:(NSString*)result{
    NSString *resultInfo = @"";
    NSString *resultInfoForLabel = @"";
    
    @try {
        NSError* error;
        NSData* resultData=[result dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary* dic=[NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:&error];
        
        if(dic){
            NSString* strSessionType=[dic objectForKey:KCIFlyFaceResultSST];
            
            //检测
            if([strSessionType isEqualToString:KCIFlyFaceResultDetect]){
                NSString* rst=[dic objectForKey:KCIFlyFaceResultRST];
                NSString* ret=[dic objectForKey:KCIFlyFaceResultRet];
                if([ret integerValue]!=0){
                    resultInfo=[resultInfo stringByAppendingFormat:@"检测人脸错误\n错误码：%@",ret];
                }else{
                    resultInfo=[resultInfo stringByAppendingString:[rst isEqualToString:KCIFlyFaceResultSuccess]?@"检测到人脸轮廓":@"未检测到人脸轮廓"];
                }
                
                
                //绘图
                if(_imgToUseCoverLayer){
                    _imgToUseCoverLayer.sublayers=nil;
                    [_imgToUseCoverLayer removeFromSuperlayer];
                    _imgToUseCoverLayer=nil;
                }
                _imgToUseCoverLayer = [[CALayer alloc] init];
                
                
                NSArray* faceArray=[dic objectForKey:KCIFlyFaceResultFace];
                
                for(id faceInArr in faceArray){
                    
                    CALayer* layer= [[CALayer alloc] init];
                    layer.borderWidth = 2.0f;
                    [layer setCornerRadius:2.0f];
                    
                    float image_x, image_y, image_width, image_height;
                    if(_imgToUse.image.size.width/_imgToUse.image.size.height > _imgToUse.frame.size.width/_imgToUse.frame.size.height){
                        image_width = _imgToUse.frame.size.width;
                        image_height = image_width/_imgToUse.image.size.width * _imgToUse.image.size.height;
                        image_x = 0;
                        image_y = (_imgToUse.frame.size.height - image_height)/2;
                        
                    }else if(_imgToUse.image.size.width/_imgToUse.image.size.height < _imgToUse.frame.size.width/_imgToUse.frame.size.height)
                    {
                        image_height = _imgToUse.frame.size.height;
                        image_width = image_height/_imgToUse.image.size.height * _imgToUse.image.size.width;
                        image_y = 0;
                        image_x = (_imgToUse.frame.size.width - image_width)/2;
                        
                    }else{
                        image_x = 0;
                        image_y = 0;
                        image_width = _imgToUse.frame.size.width;
                        image_height = _imgToUse.frame.size.height;
                    }
                    
                    CGFloat resize_scale = image_width/_imgToUse.image.size.width;
                    //
                    if(faceInArr && [faceInArr isKindOfClass:[NSDictionary class]]){
                        
                        id posDic=[faceInArr objectForKey:KCIFlyFaceResultPosition];
                        if([posDic isKindOfClass:[NSDictionary class]]){
                            CGFloat bottom =[[posDic objectForKey:KCIFlyFaceResultBottom] floatValue];
                            CGFloat top=[[posDic objectForKey:KCIFlyFaceResultTop] floatValue];
                            CGFloat left=[[posDic objectForKey:KCIFlyFaceResultLeft] floatValue];
                            CGFloat right=[[posDic objectForKey:KCIFlyFaceResultRight] floatValue];
                            
                            float x = left;
                            float y = top;
                            float width = right- left;
                            float height = bottom- top;
                            
                            CGRect innerRect = CGRectMake( resize_scale*x+image_x, resize_scale*y+image_y, resize_scale*width, resize_scale*height);
                            
                            [layer setFrame:innerRect];
                            layer.borderColor = [[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0] CGColor];
                            
                        }
                        
                        id attrDic=[faceInArr objectForKey:KCIFlyFaceResultAttribute];
                        if([attrDic isKindOfClass:[NSDictionary class]]){
                            id poseDic=[attrDic objectForKey:KCIFlyFaceResultPose];
                            id pit=[poseDic objectForKey:KCIFlyFaceResultPitch];
                            
                            CATextLayer *label = [[CATextLayer alloc] init];
                            [label setFontSize:14];
                            [label setString:[@"" stringByAppendingFormat:@"%@", pit]];
                            [label setAlignmentMode:kCAAlignmentCenter];
                            [label setForegroundColor:layer.borderColor];
                            [label setFrame:CGRectMake(0, layer.frame.size.height, layer.frame.size.width, 25)];
                            
                            [layer addSublayer:label];
                        }
                    }
                    [_imgToUseCoverLayer addSublayer:layer];

                }
                
                
                [self.imgToUse.layer addSublayer:_imgToUseCoverLayer];
            }
            
            _labelView.text=resultInfoForLabel;
            _labelView.textColor=[UIColor redColor];
            _labelView.hidden=NO;
            [_activityIndicator stopAnimating];
            [_activityIndicator setHidden:YES];
            _backBtn.enabled=YES;
            _imgSelectBtn.enabled=YES;
            _settingBtn.enabled=NO;
            _funcSelectBtn.enabled=YES;
            
            [self performSelectorOnMainThread:@selector(showResultInfo:) withObject:resultInfo waitUntilDone:NO];
        }

    }
    @catch (NSException *exception) {
        NSLog(@"prase exception:%@",exception.name);
    }
    @finally {
    }
    
}

-(void)praseAlignResult:(NSString*)result{
    NSString *resultInfo = @"";
    NSString *resultInfoForLabel = @"";
    
    @try {
        NSError* error;
        NSData* resultData=[result dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary* dic=[NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:&error];
        
        if(dic){
            NSString* strSessionType=[dic objectForKey:KCIFlyFaceResultSST];
            
            //关键点
            if([strSessionType isEqualToString:KCIFlyFaceResultAlign]){
                NSString* rst=[dic objectForKey:KCIFlyFaceResultRST];
                NSString* ret=[dic objectForKey:KCIFlyFaceResultRet];
                if([ret integerValue]!=0){
                    resultInfo=[resultInfo stringByAppendingFormat:@"检测关键点错误\n错误码：%@",ret];
                }else{
                    resultInfo=[resultInfo stringByAppendingString:[rst isEqualToString:@"success"]?@"检测到人脸关键点":@"未检测到人脸关键点"];
                }
                
                
                //绘图
                if(_imgToUseCoverLayer){
                    _imgToUseCoverLayer.sublayers=nil;
                    [_imgToUseCoverLayer removeFromSuperlayer];
                    _imgToUseCoverLayer=nil;
                }
                _imgToUseCoverLayer = [[CALayer alloc] init];
                
                float image_x, image_y, image_width, image_height;
                if(_imgToUse.image.size.width/_imgToUse.image.size.height > _imgToUse.frame.size.width/_imgToUse.frame.size.height){
                    image_width = _imgToUse.frame.size.width;
                    image_height = image_width/_imgToUse.image.size.width * _imgToUse.image.size.height;
                    image_x = 0;
                    image_y = (_imgToUse.frame.size.height - image_height)/2;
                    
                }else if(_imgToUse.image.size.width/_imgToUse.image.size.height < _imgToUse.frame.size.width/_imgToUse.frame.size.height)
                {
                    image_height = _imgToUse.frame.size.height;
                    image_width = image_height/_imgToUse.image.size.height * _imgToUse.image.size.width;
                    image_y = 0;
                    image_x = (_imgToUse.frame.size.width - image_width)/2;
                    
                }else{
                    image_x = 0;
                    image_y = 0;
                    image_width = _imgToUse.frame.size.width;
                    image_height = _imgToUse.frame.size.height;
                }
                
                CGFloat resize_scale = image_width/_imgToUse.image.size.width;
                
                NSArray* resultArray=[dic objectForKey:KCIFlyFaceResultResult];
                for (id anRst in resultArray) {
                    if(anRst && [anRst isKindOfClass:[NSDictionary class]]){
                        NSDictionary* landMarkDic=[anRst objectForKey:KCIFlyFaceResultLandmark];
                        NSEnumerator* keys=[landMarkDic keyEnumerator];
                        for(id key in keys){
                            id attr=[landMarkDic objectForKey:key];
                            if(attr && [attr isKindOfClass:[NSDictionary class]]){
                                id attr=[landMarkDic objectForKey:key];
                                CGFloat x=[[attr objectForKey:KCIFlyFaceResultPointX] floatValue];
                                CGFloat y=[[attr objectForKey:KCIFlyFaceResultPointY] floatValue];
                                
                                CALayer* layer= [[CALayer alloc] init];
                                NSLog(@"resize_scale:%f",resize_scale);
                                CGFloat radius=5.0f*resize_scale;
                                //关键点大小限制
                                if(radius>10){
                                    radius=10;
                                }
                                [layer setCornerRadius:radius];
                                CGRect innerRect = CGRectMake( resize_scale*x+image_x-radius/2, resize_scale*y+image_y-radius/2, radius, radius);
                                [layer setFrame:innerRect];
                                layer.backgroundColor = [[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0] CGColor];
                                
                                [_imgToUseCoverLayer addSublayer:layer];
                               
                                
                            }
                        }
                    }
                }
                
                [self.imgToUse.layer addSublayer:_imgToUseCoverLayer];
                
            }
            
            _labelView.text=resultInfoForLabel;
            _labelView.textColor=[UIColor redColor];
            _labelView.hidden=NO;
            [_activityIndicator stopAnimating];
            [_activityIndicator setHidden:YES];
            _backBtn.enabled=YES;
            _imgSelectBtn.enabled=YES;
            _settingBtn.enabled=YES;
            _funcSelectBtn.enabled=YES;
            
             [self performSelectorOnMainThread:@selector(showResultInfo:) withObject:resultInfo waitUntilDone:NO];
        }

    }
    @catch (NSException *exception) {
        NSLog(@"prase exception:%@",exception.name);
    }
    @finally {
      
    }
    
}

#pragma mark - Perform results On UI

-(void)updateFaceImage:(NSString*)result{
    
    NSError* error;
    NSData* resultData=[result dataUsingEncoding:NSUTF8StringEncoding];
    
    
    NSDictionary* dic=[NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:&error];
    
    if(dic){
        NSString* strSessionType=[dic objectForKey:KCIFlyFaceResultSST];
        
        //注册
        if([strSessionType isEqualToString:KCIFlyFaceResultReg]){
            [self praseRegResult:result];
        }
        
        //验证
        if([strSessionType isEqualToString:KCIFlyFaceResultVerify]){
            [self praseVerifyResult:result];
        }
        
        //检测
        if([strSessionType isEqualToString:KCIFlyFaceResultDetect]){
            [self praseDetectResult:result];
        }
        
        //关键点
        if([strSessionType isEqualToString:KCIFlyFaceResultAlign]){
            [self praseAlignResult:result];
        }
        
    }
}

-(void)showResultInfo:(NSString*)resultInfo{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"结果" message:resultInfo delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
    alert=nil;
}



#pragma mark - IFlyFaceRequestDelegate


/**
 * 消息回调
 * @param eventType 消息类型
 * @param params 消息数据对象
 */
- (void) onEvent:(int) eventType WithBundle:(NSString*) params{
    NSLog(@"onEvent | params:%@",params);
}

/**
 * 数据回调，可能调用多次，也可能一次不调用
 * @param buffer 服务端返回的二进制数据
 */
- (void) onData:(NSData* )data{
    
    NSLog(@"onData | ");
    NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"result:%@",result);
    
    if (result) {
        self.resultStings=[self.resultStings stringByAppendingString:result];
    }
    
}

/**
 * 结束回调，没有错误时，error为null
 * @param error 错误类型
 */
- (void) onCompleted:(IFlySpeechError*) error{
    [_activityIndicator stopAnimating];
    [_activityIndicator setHidden:YES];
    _backBtn.enabled=YES;
    _imgSelectBtn.enabled=YES;
    _settingBtn.enabled=YES;
    _funcSelectBtn.enabled=YES;
    NSLog(@"onCompleted | error:%@",[error errorDesc]);
    NSString* errorInfo=[NSString stringWithFormat:@"错误码：%d\n 错误描述：%@",[error errorCode],[error errorDesc]];
    if(0!=[error errorCode]){
        [self performSelectorOnMainThread:@selector(showResultInfo:) withObject:errorInfo waitUntilDone:NO];
    }
    else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateFaceImage:self.resultStings];
        });
    }
}

#pragma mark - UIPopoverControllerDelegate
- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController{
    _backBtn.enabled=YES;
    _imgSelectBtn.enabled=YES;
    _settingBtn.enabled=YES;
    _funcSelectBtn.enabled=YES;
    
    return YES;
}

#pragma mark - UIImagePickerControllerDelegate


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{

    [picker dismissViewControllerAnimated:YES completion:nil];
    if(_imgToUseCoverLayer){
        _imgToUseCoverLayer.sublayers=nil;
        [_imgToUseCoverLayer removeFromSuperlayer];
        _imgToUseCoverLayer=nil;
    }
    
    UIImage* image=[info objectForKey:@"UIImagePickerControllerOriginalImage"];
    _imgToUse.image = [[image fixOrientation] compressedImage];//将图片压缩以上传服务器
    _backBtn.enabled=YES;
    _imgSelectBtn.enabled=YES;
    _settingBtn.enabled=YES;
    _funcSelectBtn.enabled=YES;
    
    if(self.popover){
        [self.popover dismissPopoverAnimated:YES];
        self.popover=nil;
    }
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
    _backBtn.enabled=YES;
    _imgSelectBtn.enabled=YES;
    _settingBtn.enabled=YES;
    _funcSelectBtn.enabled=YES;
    
    if(self.popover){
        [self.popover dismissPopoverAnimated:YES];
        self.popover=nil;
    }
}

@end
