//
//  UIImage+AutoStretch.m
//  新浪微博by孙浩胜
//
//  Created by apple on 15-3-18.
//  Copyright (c) 2015年 孙浩胜. All rights reserved.
//

#import "UIImage+AutoStretch.h"

@implementation UIImage (AutoStretch)
+ (UIImage *)autoStretchWithimageName:(NSString *)imageName
{
    return [UIImage autoStretchWithimageName:imageName Left:0.5 top:0.5];
}

+ (UIImage *)autoStretchWithimageName:(NSString *)imageName Left:(CGFloat)left top:(CGFloat)top
{
    UIImage *image = [self imageNamed:imageName];
    image = [image stretchableImageWithLeftCapWidth:image.size.width*left topCapHeight:image.size.height*top];
    return image;
}
@end
