//
//  LoginViewModel.m
//  SHSIM
//
//  Created by apple on 15/10/8.
//  Copyright (c) 2015年 SHSDeveloper. All rights reserved.
//

#import "LoginViewModel.h"
#import "StreamManager.h"

@implementation LoginViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initialBlind];
    }
    return self;
}

- (void)initialBlind {
    _loginBtnEnableSignal = [RACSignal combineLatest:@[RACObserve(self,account),RACObserve(self, password)] reduce:^id(NSString *account,NSString *password){
        return @(account.length && password.length);
    }];
    
    _loginModeSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        if ([[StreamManager shareManager] loadAccountFromSandbox]) {
            [subscriber sendNext:@(YES)];
            self.account = [[StreamManager shareManager] loadAccountFromSandbox];
        } else {
            [subscriber sendNext:@(NO)];
        }
        [subscriber sendCompleted];
        return nil;
    }];
    
    _loginCommend = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [[StreamManager shareManager] loginToSeverWithAccount:self.account andPassword:self.password completeBlock:^(StreamResultType resultType) {
                if (resultType == StreamResultTypeSussessful) {
                    [[StreamManager shareManager] saveAccountToSandbox:self.account];
                    [[StreamManager shareManager] savePasswordToSandbox:self.password];
                }
                [subscriber sendNext:@(resultType)];
                [subscriber sendCompleted];
            }];
            return nil;
        }];
    }];
    
    _loginCompleteSubject = [RACSubject subject];
    
    [_loginCommend.executionSignals.switchToLatest subscribeNext:^(NSNumber *x) {
        [_loginCompleteSubject sendNext:x];
        //如果登录成功，发送完成的信号
        if (x.integerValue == StreamResultTypeSussessful) {
            [_loginCompleteSubject sendCompleted];
        }
    }];
    
}




@end
