//
//  TabbarItem.h
//  SHSIM
//
//  Created by apple on 15/9/29.
//  Copyright (c) 2015年 SHSDeveloper. All rights reserved.
//

#import <UIKit/UIKit.h>

static const NSString *KImageAttribute = @"image";
static const NSString *KImageSelectedAttribute = @"selectedImage";
static const NSString *KTitleAttribute = @"title";

@interface TabbarItem : UIView

@property (nonatomic,assign) NSInteger badgeValue;
@property (nonatomic,assign) float highLightDegree;

- (instancetype)initWithFrame:(CGRect)frame andAttributes:(NSDictionary *)attributes;

@end
