//
//  NetWorkTool.m
//  OCRSearchDemo
//
//  Created by 陈威利 on 2017/9/14.
//  Copyright © 2017年 陈威利. All rights reserved.
//

#import "NetWorkTool.h"
#import "AFNetworking.h"
#import "MJExtension.h"
#import "personInfoModel.h"
#import "SVProgressHUD.h"
@implementation NetWorkTool

///获取验证码
- (NSURLSessionDataTask *)getName:(NSString *)name andCode:(NSString *)code WithSuccess:(SuccessedBlock)success failure:(FailureBlock)failure{
    _successBlock = success;
    _failureBlock = failure;
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD showWithStatus:@"加载中"];
    AFHTTPSessionManager *manager =[AFHTTPSessionManager manager];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 5;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    //如果报接受类型不一致请替换一致text/html或别的
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/plain", @"text/html" ,@"image/jpeg", nil];
    //Authorization:APPCODE 0d764ed2783444a1ba9b0690d1ba83bc
    [manager.requestSerializer setValue:@"APPCODE 0d764ed2783444a1ba9b0690d1ba83bc" forHTTPHeaderField:@"Authorization"];
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic setObject:code forKey:@"idcard"];
    [dic setObject:name forKey:@"realname"];
    NSURLSessionDataTask *task = [manager GET:@"http://jisusfzfzp.market.alicloudapi.com/idcardverify2/verify" parameters:dic progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [SVProgressHUD dismissWithDelay:0.3];
        NSDictionary *newJson = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        if (newJson && [newJson[@"msg"] isEqualToString: @"ok"] && [newJson[@"status"] isEqualToString:@"0"]) {
            personInfoModel *model= [personInfoModel mj_objectWithKeyValues:newJson[@"result"]];
//            model.pic = newJson[@"result"][@"pic"];
            _successBlock(model);
        }else{
            
            NSMutableDictionary *dic = [NSMutableDictionary new];
            [dic setObject:@"服务器错误" forKey:@"ServerError"];
            _failureBlock(dic);
        }

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:@"error" forKey:@"code"];
        [dic setObject:error forKey:@"message"];
        _failureBlock(dic);
    }];
    
//    NSURLSessionDataTask *task2 = [manager POST:@"https://www.sonystyle.com.cn/mysony/campaign/api/captcha.do" parameters:nil progress:^(NSProgress * _Nonnull uploadProgress) {
//        
//    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSDictionary *newJson = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
//        if (newJson) {
//            _successBlock(newJson);
//        }else{
//            NSMutableDictionary *dic = [NSMutableDictionary new];
//            [dic setObject:@"服务器错误" forKey:@"ServerError"];
//            _failureBlock(dic);
//        }
//        
//        
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        //        [_loadingView stopAiAnimating];
//        NSMutableDictionary *dic = [NSMutableDictionary new];
//        [dic setObject:@"error" forKey:@"code"];
//        [dic setObject:error forKey:@"message"];
//        _failureBlock(dic);
//    }];
    
    return task;
}

@end
