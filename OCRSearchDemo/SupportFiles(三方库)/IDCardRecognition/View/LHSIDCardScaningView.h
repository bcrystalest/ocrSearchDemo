//
//  LHSIDCardScaningView.h
//  身份证识别
//
//  Created by huashan on 2017/2/17.
//  Copyright © 2017年 LiHuashan. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^heightLightBlock)();

@interface LHSIDCardScaningView : UIView

@property (nonatomic,assign) CGRect facePathRect;
@property (nonatomic, copy) heightLightBlock block;
@end
