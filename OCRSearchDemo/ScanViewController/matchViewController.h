//
//  KnowledgeVC.h
//  knowledge_link
//
//  Created by 陈威利 on 2017/8/18.
//  Copyright © 2017年 陈威利. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IDInfo.h"
@interface matchViewController : UIViewController
@property (nonatomic, strong)IDInfo *IDInfo;
// 身份证图像
@property (nonatomic, strong)UIImage *IDImage;
@end
