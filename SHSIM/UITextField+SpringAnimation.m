//
//  UITextField+SpringAnimation.m
//  SHSIM
//
//  Created by apple on 15/10/2.
//  Copyright (c) 2015年 SHSDeveloper. All rights reserved.
//

#import "UITextField+SpringAnimation.h"

@implementation UITextField(SpringAnimation)

- (void)textFieldSpringAnimation {
    self.layer.borderColor = [UIColor redColor].CGColor;
    self.transform = CGAffineTransformMakeTranslation(5.0f, 0);
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.1 initialSpringVelocity:5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.transform = CGAffineTransformIdentity;
    } completion:nil];
}

@end
