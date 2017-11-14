//
//  classicViewController.m
//  knowledge_link
//
//  Created by 陈威利 on 2017/8/18.
//  Copyright © 2017年 陈威利. All rights reserved.
//

#import "classicNavigationController.h"

@interface classicNavigationController ()

@end

@implementation classicNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

+ (void)load{
    
}


+ (void)initialize
{
    
    UINavigationBar *navigationBar = [UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[[classicNavigationController class]]];
    
    // bgImage
    [navigationBar setBackgroundImage:[UIImage imageNamed:@"back.png"] forBarMetrics:UIBarMetricsDefault];
    
    // 字体属性
    NSMutableDictionary *dictAttr = [NSMutableDictionary dictionary];
    dictAttr[NSFontAttributeName] = [UIFont systemFontOfSize:20];
    dictAttr[NSForegroundColorAttributeName] = [UIColor blackColor];
    [navigationBar setTitleTextAttributes:dictAttr];
    
    //更改导航条主题颜色
    navigationBar.translucent = NO; 
    
    navigationBar.tintColor = [UIColor blackColor];
    //    navigationBar.backgroundColor = [UIColor blackColor];
    //调整返回按钮当中标题的位置.（我们只要返回按钮的那个图片，但是不要上面的文字，移走文字就好了）
    UIBarButtonItem *item = [UIBarButtonItem appearance];
    [item setBackButtonTitlePositionAdjustment:UIOffsetMake(0, 0) forBarMetrics:UIBarMetricsDefault];
    
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    
    if (self.childViewControllers.count > 0) {
        
        /* 自动显示和隐藏tabbar */
        viewController.hidesBottomBarWhenPushed = YES;
    }
    
    [super pushViewController:viewController animated:animated];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
