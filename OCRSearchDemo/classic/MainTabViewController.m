//
//  MainViewController.m
//  knowledge_link
//
//  Created by 陈威利 on 2017/8/18.
//  Copyright © 2017年 陈威利. All rights reserved.
//

#import "MainTabViewController.h"

#import "classicNavigationController.h"
#import "IDAuthViewController.h"
@interface MainTabViewController ()

@end

@implementation MainTabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setUpAllChildViewController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUpAllChildViewController{
    // 1.添加第一个控制器
//    scanViewController *oneVC = [[scanViewController alloc]init];
    IDAuthViewController *IDAuthVC = [[IDAuthViewController alloc] init];
    [self setUpOneChildViewController:IDAuthVC image:[UIImage imageNamed:@"书签"] title:@"扫描界面"];
    // 2.添加第2个控制器
//    KnowledgeVC *twoVC = [[KnowledgeVC alloc]init];
//    [self setUpOneChildViewController:twoVC image:[UIImage imageNamed:@"js"] title:@"知识库"];
    
    // 3.添加第3个控制器
//    personalVC *threeVC = [[personalVC alloc]init];
//    [self setUpOneChildViewController:threeVC image:[UIImage imageNamed:@"qw"] title:@"个人中心"];
    
}
/**
 *  添加一个子控制器的方法
 */
- (void)setUpOneChildViewController:(UIViewController *)viewController image:(UIImage *)image title:(NSString *)title{
    
    classicNavigationController *navC = [[classicNavigationController alloc]initWithRootViewController:viewController];
    navC.title = title;
    navC.tabBarItem.image = image;
//    [navC.navigationBar setBackgroundImage:[UIImage imageNamed:@"commentary_num_bg"] forBarMetrics:UIBarMetricsDefaultPrompt];
    navC.tabBarItem.image = [[UIImage imageNamed:@"hiSelect"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    viewController.navigationItem.title = title;
    [self addChildViewController:navC];
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
