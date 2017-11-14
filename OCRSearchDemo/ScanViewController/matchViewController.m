//
//  KnowledgeVC.m
//  knowledge_link
//
//  Created by 陈威利 on 2017/8/18.
//  Copyright © 2017年 陈威利. All rights reserved.
//

#import "matchViewController.h"
#import "IDAuthViewController.h"
#import "NetWorkTool.h"
#import "personInfoModel.h"
#import "SVProgressHUD.h"
#import "TableViewAnimationKit.h"
#import "Masonry.h"
@interface matchViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong)UITableView *leftTableView;
@property (nonatomic, strong)UITableView *rightTableView;
@property (nonatomic, strong)personInfoModel *mainModel;
@property (nonatomic, strong)UILabel *resultLabel;
@end

@implementation matchViewController
{
    UIImageView *imgView;
    NSMutableArray *netWorkArray;
}

- (UITableView *)leftTableView
{
    
    if (_leftTableView == nil) {
        _leftTableView = [[UITableView alloc]initWithFrame:CGRectMake(0,0,0,0) style:UITableViewStylePlain];
        _leftTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
    }return _leftTableView;
    
}

- (UITableView *)rightTableView
{
    
    if (_rightTableView == nil) {
        _rightTableView = [[UITableView alloc]initWithFrame:CGRectMake(0,0,0,0) style:UITableViewStylePlain];
        _rightTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _rightTableView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configUI];
    [self getData];
}

- (void)configUI{
    OcrWeakSelf;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"网络查询结果";
    [self.view addSubview:self.leftTableView];
    [self.view addSubview:self.rightTableView];
    
    UIImageView *imageView = [UIImageView new];
    [self.view addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf.view.mas_centerX);
        make.top.equalTo(weakSelf.view.mas_top);
        make.width.mas_equalTo((ScreenWidth - 20)*0.6);
        make.height.mas_equalTo((ScreenWidth - 20)*0.6/355*238);
    }];
    
    imageView.image = _IDImage;
    
    [self.leftTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.view.mas_left);
        make.right.equalTo(weakSelf.view.mas_right);
        make.top.equalTo(imageView.mas_bottom).offset(10);
        make.height.mas_equalTo(75);
    }];
    
    imgView = [UIImageView new];
    [self.view addSubview:imgView];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf.view.mas_centerX);
        make.top.equalTo(weakSelf.leftTableView.mas_bottom).offset(10);
        make.width.mas_equalTo(178*ScreenWidth/375);
        make.height.mas_equalTo(220*ScreenWidth/375);
    }];
    
    [self.rightTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.view.mas_left);
        make.right.equalTo(weakSelf.view.mas_right);
        make.top.equalTo(imgView.mas_bottom).offset(10);
        make.height.mas_equalTo(75);
    }];
    
    self.leftTableView.delegate = self;
    self.leftTableView.dataSource = self;
    self.rightTableView.delegate = self;
    self.rightTableView.dataSource = self;
    self.leftTableView.hidden = YES;
    self.rightTableView.hidden = YES;
//    [self performSelector:@selector(loadData) withObject:nil afterDelay:1.0];
//    self.infoTableView.hidden = NO;
    
    self.resultLabel = [UILabel new];
    [self.view addSubview:self.resultLabel];
    _resultLabel.textColor = [UIColor redColor];
    _resultLabel.font = [UIFont systemFontOfSize:13];
    [_resultLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf.view.mas_centerX);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(50);
        make.top.equalTo(weakSelf.rightTableView.mas_bottom).offset(10);
    }];
}

- (void)getData{
//    __weak typeof(self) weakSelf = self;
    OcrWeakSelf;
    NetWorkTool *tool = [NetWorkTool new];
    NSURLSessionTask *task = [tool getName:_IDInfo.name andCode:_IDInfo.num WithSuccess:^(id successDic) {
//    NSURLSessionTask *task = [tool getName:@"陈威利" andCode:@"342502199310267212" WithSuccess:^(id successDic) {
        weakSelf.mainModel = successDic;
        weakSelf.leftTableView.hidden = NO;
        
        [TableViewAnimationKit moveAnimationWithTableView:weakSelf.leftTableView];
        
        [weakSelf performSelector:@selector(showRightTableViewData) withObject:nil afterDelay:1.0];
        [weakSelf.rightTableView reloadData];
        
        
    } failure:^(NSDictionary *failureDic) {
        [SVProgressHUD showWithStatus:@"请求出错"];
        [SVProgressHUD dismissWithDelay:1.0];
    }];
    [netWorkArray addObject:task];
}

- (void)showRightTableViewData{
    OcrWeakSelf;
    weakSelf.rightTableView.hidden = NO;
    [TableViewAnimationKit moveAnimationWithTableView:weakSelf.rightTableView];
    NSData  *decodedImageData   = [[NSData alloc] initWithBase64EncodedString:weakSelf.mainModel.pic options:0];
//    NSData  *decodedImageData   = [[NSData alloc] initWithBase64Encoding:weakSelf.mainModel.pic];
    UIImage *decodedImage       = [UIImage imageWithData:decodedImageData];
    imgView.image = decodedImage;
    
    [weakSelf performSelector:@selector(showMatchResult) withObject:nil afterDelay:0.5];
}

- (void)showMatchResult{
    /*,_mainModel.realname];
     ,_mainModel.sex];
     号码:%@",_mainModel.idcard]
     @",_IDInfo.name];
     @",_IDInfo.gender];
     份证号码:%@",_IDInfo.num];*/
    OcrWeakSelf;
    if ([_IDInfo.name isEqualToString: _mainModel.realname] && [_IDInfo.gender isEqualToString: _mainModel.sex] && [_mainModel.idcard isEqualToString: _IDInfo.num]) {
        weakSelf.resultLabel.text = @"匹配成功!";
    }else{
        weakSelf.resultLabel.text = @"匹配失败!";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
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
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if ([tableView isEqual:_leftTableView]) {
        if (indexPath.row == 0) {
            cell.textLabel.font = [UIFont systemFontOfSize:14];
            cell.textLabel.text = [NSString stringWithFormat:@"本地扫描结果"];
        }else if (indexPath.row == 1) {
            cell.textLabel.text = [NSString stringWithFormat:@"姓名:%@",_IDInfo.name];
        }else if (indexPath.row == 2) {
            cell.textLabel.text = [NSString stringWithFormat:@"性别:%@",_IDInfo.gender];
        }else if (indexPath.row == 3) {
            cell.textLabel.text = [NSString stringWithFormat:@"公民身份证号码:%@",_IDInfo.num];
        }
    }else if ([tableView isEqual:_rightTableView])
    {
        /*
         @property (nonatomic, strong)NSString *idcard;
         @property (nonatomic, strong)NSString *city;
         @property (nonatomic, strong)NSString *town;
         @property (nonatomic, strong)NSString *birth;
         @property (nonatomic, strong)NSString *realname;
         @property (nonatomic, strong)NSString *sex;
         @property (nonatomic, strong)NSString *province;
         */
        if (indexPath.row == 0) {
            cell.textLabel.font = [UIFont systemFontOfSize:14];
            cell.textLabel.text = [NSString stringWithFormat:@"公安部查询结果"];
        }else if (indexPath.row == 1) {
            cell.textLabel.text = [NSString stringWithFormat:@"姓名:%@",_mainModel.realname];
        }else if (indexPath.row == 2) {
            cell.textLabel.text = [NSString stringWithFormat:@"性别:%@",_mainModel.sex];
        }else if (indexPath.row == 3) {
            cell.textLabel.text = [NSString stringWithFormat:@"公民身份证号码:%@",_mainModel.idcard];
        }
    }
    return cell;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([tableView isEqual:_leftTableView]) {
        return tableView.frame.size.height/4;
    }else{
        return tableView.frame.size.height/4;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    for (NSInteger i = 0; i<netWorkArray.count; i++) {
        NSURLSessionTask *task = netWorkArray[i];
        [task cancel];
    }
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
