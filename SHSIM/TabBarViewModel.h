//
//  TabBarViewModel.h
//  SHSIM
//
//  Created by apple on 15/10/12.
//  Copyright © 2015年 SHSDeveloper. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TabBarViewModel : NSObject<UIScrollViewDelegate>

@property (nonatomic,assign) NSInteger selectedIndex;

@property (nonatomic,strong) NSArray *itemAttributes;

@end
