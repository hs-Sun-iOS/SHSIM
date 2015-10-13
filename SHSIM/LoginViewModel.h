//
//  LoginViewModel.h
//  SHSIM
//
//  Created by apple on 15/10/8.
//  Copyright (c) 2015年 SHSDeveloper. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoginViewModel : NSObject

@property (nonatomic,copy) NSString *account;

@property (nonatomic,copy) NSString *password;

@property (nonatomic,strong) RACSignal *loginBtnEnableSignal;

@property (nonatomic,strong) RACSignal *loginModeSignal;

@property (nonatomic,strong) RACSubject *loginCompleteSubject;


/**
 *  handle login
 */
@property (strong,nonatomic) RACCommand *loginCommend;



@end
