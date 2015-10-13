//
//  MeViewController.m
//  SHSIM
//
//  Created by apple on 15/9/29.
//  Copyright (c) 2015年 SHSDeveloper. All rights reserved.
//

#import "MeViewController.h"
#import "StreamManager.h"

@interface MeViewController ()

@end

@implementation MeViewController

#pragma mark life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.layer.shadowOffset = CGSizeMake(5, 0);
    self.view.layer.shadowOpacity = 0.5f;
}


- (IBAction)LogoutBtnClick:(id)sender {
    [[StreamManager shareManager] logoutFromSever];
    UIStoryboard *loginSB = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    self.view.window.rootViewController = loginSB.instantiateInitialViewController;
    
}


@end
