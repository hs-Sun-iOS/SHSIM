//
//  StreamManager.h
//  SHSIM
//
//  Created by apple on 15/9/23.
//  Copyright (c) 2015年 SHSDeveloper. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, StreamResultType) {
    StreamResultTypeSussessful,
    StreamResultTypeFailure,
    StreamResultTypeTimeout,
};

@interface StreamManager : NSObject

@property (nonatomic,assign,getter=isLogin,readonly) BOOL loginStatus;
@property (nonatomic,assign,getter=isConnect,readonly) BOOL connectStatus;

+ (instancetype)shareManager;

- (void)loginToSeverWithAccount:(NSString *)account andPassword:(NSString *)password completeBlock:(void(^)(StreamResultType resultType))completeBlock;

- (void)registerNewAccount:(NSString *)account andPassword:(NSString *)password completeBlock:(void(^)(StreamResultType resultType))completeBlock;

- (void)logoutFromSever;

- (NSString *)loadAccountFromSandbox;

- (NSString *)loadPasswordFromSandbox;

- (void)saveAccountToSandbox:(NSString *)account;

- (void)savePasswordToSandbox:(NSString *)password;

@end
