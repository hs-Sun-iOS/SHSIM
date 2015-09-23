//
//  LoginManager.h
//  SHSIM
//
//  Created by apple on 15/9/23.
//  Copyright (c) 2015年 SHSDeveloper. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoginManager : NSObject

+ (instancetype)shareManager;

- (void)loginToSeverWith:(NSString *)account andPassword:(NSString *)password successfulHandle:(void(^)())successfulHandle andfailureHandle:(void(^)(NSError *error))failureHandle;

- (void)logoutFromSever;

@end
