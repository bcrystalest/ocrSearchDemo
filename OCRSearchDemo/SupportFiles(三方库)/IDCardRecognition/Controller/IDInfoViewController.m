//
//  IDInfoViewController.m
//  IDCardRecognition
//
//  Created by zhongfeng1 on 2017/2/21.
//  Copyright © 2017年 李中峰. All rights reserved.

//  请给个星：https://github.com/zhongfenglee/IDCardRecognition
//  请关注我：https://github.com/zhongfenglee

#import "IDInfoViewController.h"
#import "IDInfo.h"
#import "AVCaptureViewController.h"
#import "TableViewAnimationKit.h"
#import "matchViewController.h"
#import "SVProgressHUD.h"
@interface IDInfoViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UIImageView *IDImageView;
//@property (strong, nonatomic) IBOutlet UILabel *IDNumLabel;
@property (nonatomic, strong) IBOutlet UITableView *infoTableView;

@end

@implementation IDInfoViewController
//- (UITableView *)infoTableView{
//    if (_infoTableView == nil) {
//        _infoTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 0, 0) style:UITableViewStylePlain];
//    }
//    return _infoTableView;
//}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.infoTableView.hidden = YES;
    self.navigationItem.title = @"身份证信息";
    [self performSelector:@selector(loadData) withObject:nil afterDelay:1.0];
    self.IDImageView.layer.cornerRadius = 8;
    self.IDImageView.layer.masksToBounds = YES;
    self.infoTableView.scrollEnabled = NO;
    self.infoTableView.delegate = self;
    self.infoTableView.dataSource = self;
    self.infoTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
//    self.IDNumLabel.text = _IDInfo.num;
    self.IDImageView.image = _IDImage;
}

- (void)loadData{
    self.infoTableView.hidden = NO;
    [TableViewAnimationKit moveAnimationWithTableView:self.infoTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 错误，重新拍摄
- (IBAction)shootAgain:(UIButton *)sender {    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 正确，下一步
- (IBAction)nextStep:(UIButton *)sender {
    NSLog(@"经用户核对，身份证号码正确，那就进行下一步，比如身份证图像或号码经加密后，传递给后台");
    if (_IDInfo.name.length == 0 ||  _IDInfo.num == 0) {
        [SVProgressHUD setDefaultStyle:SVProgressHUDStyleCustom];
        [SVProgressHUD showInfoWithStatus:@"数据缺失请重新扫描"];
        [SVProgressHUD dismissWithDelay:1.0];
        [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    }else{
        matchViewController *vc = [matchViewController new];
        vc.IDInfo = _IDInfo;
        vc.IDImage = _IDImage;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc ]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        cell.layoutMargins=UIEdgeInsetsZero;
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        cell.separatorInset=UIEdgeInsetsZero;
    }
    cell.textLabel.font = [UIFont systemFontOfSize:12];
    cell.textLabel.textColor = [UIColor darkGrayColor];
    if (indexPath.row == 0) {
        cell.textLabel.text = [NSString stringWithFormat:@"姓名:%@",_IDInfo.name];
    }else if (indexPath.row == 1) {
        cell.textLabel.text = [NSString stringWithFormat:@"性别:%@",_IDInfo.gender];
    }else if (indexPath.row == 2) {
        cell.textLabel.text = [NSString stringWithFormat:@"民族:%@",_IDInfo.nation];
    }else if (indexPath.row == 3) {
        cell.textLabel.text = [NSString stringWithFormat:@"住址:%@",_IDInfo.address];
    }else if (indexPath.row == 4) {
        cell.textLabel.text = [NSString stringWithFormat:@"公民身份证号码:%@",_IDInfo.num];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return self.infoTableView.frame.size.height/5;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationAVCaptureViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
