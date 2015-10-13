//
//  TabbarItem.m
//  SHSIM
//
//  Created by apple on 15/9/29.
//  Copyright (c) 2015年 SHSDeveloper. All rights reserved.
//

#import "TabbarItem.h"


@interface TabbarItem()

@property (nonatomic,strong) UIButton *badgeView;
@property (nonatomic,strong) UIImageView *NormalImage;
@property (nonatomic,strong) UILabel *NormalLabel;
@property (nonatomic,strong) UIImageView *HighLightImage;
@property (nonatomic,strong) UILabel *HighLightLabel;

@end

@implementation TabbarItem

- (instancetype)initWithFrame:(CGRect)frame andAttributes:(NSDictionary *)attributes {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubViews:attributes];
    }
    return self;
}

- (void)setupSubViews:(NSDictionary *)attributes {

    _NormalImage = ({
        UIImageView *img = [[UIImageView alloc] initWithImage:attributes[KImageAttribute]];
        img.center = CGPointMake(self.width/2, self.height*0.7/2);
        [self addSubview:img];
        img;
    });
    _HighLightImage = ({
        UIImageView *img = [[UIImageView alloc] initWithImage:attributes[KImageSelectedAttribute]];
        img.frame = _NormalImage.frame;
        img.layer.mask = ({
            CALayer *mask = [CALayer layer];
            mask.bounds = img.bounds;
            mask.opacity = 0;
            mask.anchorPoint = CGPointZero;
            mask.backgroundColor = [UIColor blackColor].CGColor;
            mask;
        });
        [self addSubview:img];
        img;
    });
    _NormalLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.text = attributes[KTitleAttribute];
        label.textColor = [UIColor grayColor];
        label.font = [UIFont systemFontOfSize:11.0f];
        label.bounds = [label.text boundingRectWithSize:CGSizeMake(self.width, 13.0f) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:label.font} context:nil];
        label.center = CGPointMake(self.width/2, self.height*0.3/2 + self.height*0.6);
        [self addSubview:label];
        label;
    });
    _HighLightLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.text = attributes[KTitleAttribute];
        label.textColor = COLOR(43.0f, 179.0f, 0, 1);
        label.font = [UIFont systemFontOfSize:11.0f];
        label.frame = _NormalLabel.frame;
        label.layer.mask = ({
            CALayer *mask = [CALayer layer];
            mask.bounds = label.bounds;
            mask.opacity = 0;
            mask.anchorPoint = CGPointZero;
            mask.backgroundColor = [UIColor blackColor].CGColor;
            mask;
        });
        [self addSubview:label];
        label;
    });
    _badgeView = ({
        UIButton *btn = [[UIButton alloc] init];
        [btn setBackgroundImage:[UIImage autoStretchWithimageName:@"main_badge_os7"] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:11.0f];
        btn.userInteractionEnabled = NO;
        btn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
        [self addSubview:btn];
        btn;
    });
}

#pragma mark - Setter

- (void)setBadgeValue:(NSInteger)badgeValue {
    _badgeValue = badgeValue;
    if (badgeValue != 0) {
        self.badgeView.hidden = NO;
        [self.badgeView setTitle:[NSString stringWithFormat:@"%zd",badgeValue] forState:UIControlStateNormal];
        CGFloat Y = 2;
        CGFloat Height = self.badgeView.currentBackgroundImage.size.height;
        CGSize size = CGSizeMake(40, Height);
        CGFloat Width = [[NSString stringWithFormat:@"%zd",badgeValue] boundingRectWithSize:size options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:self.badgeView.titleLabel.font} context:nil].size.width + 13;
        CGFloat X = self.frame.size.width - Width -10;
        
        
        self.badgeView.frame = CGRectMake(X,Y,Width,Height);
    } else {
        self.badgeView.hidden = YES;
    }
}
- (void)setHighLightDegree:(float)highLightDegree{
    _highLightDegree = highLightDegree;
    self.HighLightImage.layer.mask.opacity = highLightDegree;
    self.HighLightLabel.layer.mask.opacity = highLightDegree;
}


@end
