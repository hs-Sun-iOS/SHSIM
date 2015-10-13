//
//  TabbarViewController.m
//  SHSIM
//
//  Created by apple on 15/9/29.
//  Copyright (c) 2015年 SHSDeveloper. All rights reserved.
//

#import "TabbarViewController.h"
#import "TabbarItem.h"
#import "TabBarViewModel.h"
#import "ChatViewController.h"
#import "AddressBookViewController.h"
#import "DiscoveryViewController.h"
#import "MeViewController.h"

@interface TabbarViewController () <UIScrollViewDelegate> {
    NSInteger _selectedIndex;
    CGFloat _xOffset;
}

@property (weak, nonatomic) IBOutlet UIView *tabbarView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (nonatomic,strong) ChatViewController *chatVC;
@property (nonatomic,strong) AddressBookViewController *addressBookVC;
@property (nonatomic,strong) DiscoveryViewController *discoveryVC;
@property (nonatomic,strong) MeViewController *meVC;

@property (nonatomic,strong) TabBarViewModel *tabbarVM;
@property (nonatomic,strong) NSMutableArray *items;

@end

@implementation TabbarViewController

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    _selectedIndex = 0;
    _xOffset = 0;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
   
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setupTabbarItem];

}

#pragma mark - private Method

- (void)setupTabbarItem {
    CGFloat itemWidth = SCREEN_WIDTH / 4;
    for (int i = 0; i < 4; i++) {
        TabbarItem *item = [[TabbarItem alloc] initWithFrame:CGRectMake(i * itemWidth, 0, itemWidth, 50) andAttributes:self.tabbarVM.itemAttributes[i]];
        UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGREvent:)];
        [item addGestureRecognizer:tapGR];
        item.badgeValue = 10;
        item.tag = i + 1;
        if (i == 0) {
            [item setHighLightDegree:1.0f];
        }
        [self.tabbarView addSubview:item];
        [self.items addObject:item];
    }
}

- (void)tapGREvent:(UITapGestureRecognizer *)tap {
    if (_selectedIndex != tap.view.tag - 1) {
        TabbarItem *selectedItem = self.items[_selectedIndex];
        _selectedIndex = tap.view.tag - 1;
        self.scrollView.delegate = nil;
        [self.scrollView setContentOffset:CGPointMake(_selectedIndex*self.scrollView.frame.size.width, 0) animated:NO];
        [UIView animateWithDuration:0.5 animations:^{
            [selectedItem setHighLightDegree:.0f];
            [(TabbarItem *)tap.view setHighLightDegree:1.0f];
        } completion:^(BOOL finished) {
            self.scrollView.delegate = self;
            _xOffset = self.scrollView.contentOffset.x;
        }];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"chat"]) {
        UINavigationController *nav = segue.destinationViewController;
        self.chatVC = (ChatViewController *)nav.topViewController;
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    float rate = (scrollView.contentOffset.x - _xOffset)/scrollView.frame.size.width;
    TabbarItem *sourceItem = self.items[_selectedIndex];
    TabbarItem *destinationItem = nil;
    if (rate > 0) {
        if (_selectedIndex == self.items.count - 1) {
            return;
        }
        destinationItem = self.items[_selectedIndex + 1];
    } else {
        if (_selectedIndex == 0) {
            return;
        }
        destinationItem = self.items[_selectedIndex - 1];
    }
    sourceItem.highLightDegree = 1 - fabsf(rate) ;
    destinationItem.highLightDegree = fabsf(rate);
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [scrollView setContentOffset:CGPointMake(_xOffset, 0) animated:NO];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    _xOffset = targetContentOffset->x;
    float rate = _xOffset/scrollView.frame.size.width;
    _selectedIndex = rate;
}

#pragma mark - lazy load
- (TabBarViewModel *)tabbarVM {
    if (!_tabbarVM) {
        _tabbarVM = [[TabBarViewModel alloc] init];
    }
    return _tabbarVM;
}
- (NSMutableArray *)items {
    if (!_items) {
        _items = [NSMutableArray array];
    }
    return _items;
}
@end
