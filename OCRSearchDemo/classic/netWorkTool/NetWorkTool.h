//
//  NetWorkTool.h
//  OCRSearchDemo
//
//  Created by 陈威利 on 2017/9/14.
//  Copyright © 2017年 陈威利. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void(^SuccessedBlock)(id successDic);
typedef void(^FailureBlock)(NSDictionary *failureDic);
@interface NetWorkTool : NSObject

@property (nonatomic, copy) SuccessedBlock successBlock;
@property (nonatomic, copy) FailureBlock failureBlock;
- (NSURLSessionDataTask *)getName:(NSString *)name andCode:(NSString *)code WithSuccess:(SuccessedBlock)success failure:(FailureBlock)failure;
@end
