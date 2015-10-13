//
//  TabBarViewModel.m
//  SHSIM
//
//  Created by apple on 15/10/12.
//  Copyright © 2015年 SHSDeveloper. All rights reserved.
//

#import "TabBarViewModel.h"
#import "TabbarItem.h"
#import "StreamManager.h"

@interface TabBarViewModel() {
}

@end

@implementation TabBarViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
        if (![StreamManager shareManager].connectStatus) {
            [self autoLogin];
        }
    }
    return self;
}

#pragma mark - Private Method

- (void)autoLogin {
    StreamManager *manager = [StreamManager shareManager];
    [manager loginToSeverWithAccount:[manager loadAccountFromSandbox] andPassword:[manager loadPasswordFromSandbox] completeBlock:nil];
}

#pragma lazy load

- (NSArray *)itemAttributes {
    if (!_itemAttributes) {
        NSDictionary *chatAttribute = [NSDictionary dictionaryWithObjectsAndKeys:@"聊天",KTitleAttribute,[UIImage imageNamed:@"tabbar_mainframe"],KImageAttribute,[UIImage imageNamed:@"tabbar_mainframeHL"],KImageSelectedAttribute,nil];
        NSDictionary *addressBookAttribute = [NSDictionary dictionaryWithObjectsAndKeys:@"通讯录",KTitleAttribute,[UIImage imageNamed:@"tabbar_contacts"],KImageAttribute,[UIImage imageNamed:@"tabbar_contactsHL"],KImageSelectedAttribute,nil];
        NSDictionary *discoveryAttribute = [NSDictionary dictionaryWithObjectsAndKeys:@"发现",KTitleAttribute,[UIImage imageNamed:@"tabbar_discover"],KImageAttribute,[UIImage imageNamed:@"tabbar_discoverHL"],KImageSelectedAttribute,nil];
        NSDictionary *meAttribute = [NSDictionary dictionaryWithObjectsAndKeys:@"我",KTitleAttribute,[UIImage imageNamed:@"tabbar_me"],KImageAttribute,[UIImage imageNamed:@"tabbar_meHL"],KImageSelectedAttribute,nil];
        _itemAttributes = [NSArray arrayWithObjects:chatAttribute,addressBookAttribute,discoveryAttribute,meAttribute, nil];
    }
    return _itemAttributes;
}

@end
