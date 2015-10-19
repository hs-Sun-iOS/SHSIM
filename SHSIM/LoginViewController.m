//
//  LoginViewController.m
//  SHSIM
//
//  Created by apple on 15/9/24.
//  Copyright (c) 2015年 SHSDeveloper. All rights reserved.
//

#import "LoginViewController.h"
#import "StreamManager.h"
#import "UITextField+SpringAnimation.h"
#import "RegisterViewController.h"
#import "LoginViewModel.h"

@interface LoginViewController ()<UITextFieldDelegate> {

}
@property (weak, nonatomic) IBOutlet UIImageView *userPhoto;
@property (weak, nonatomic) IBOutlet UITextField *accountTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UILabel *accountLabel;
@property (weak, nonatomic) IBOutlet UIButton *switchAccountBtn;
@property (weak, nonatomic) IBOutlet UIButton *registerBtn;
@property (weak, nonatomic) IBOutlet UIButton *getPasswordBtn;
@property (strong, nonatomic) LoginViewModel *loginViewModel;

@end

@implementation LoginViewController
#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self blindViewModel];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self configureSubViews];
    [self switchAccountBtnSignal];
}

- (void)blindViewModel {
    RAC(self.loginViewModel,account) = self.accountTextField.rac_textSignal;
    RAC(self.loginViewModel,password) = self.passwordTextField.rac_textSignal;
    RAC(self.accountTextField,hidden) = self.loginViewModel.loginModeSignal;
    RAC(self.loginBtn,enabled) = self.loginViewModel.loginBtnEnableSignal;
    [[self.loginBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view endEditing:YES];
            [MBProgressHUD showMessage:@"正在登录..." toView:self.view];
        });
        [self.loginViewModel.loginCommend execute:nil];
    }];
    [self.loginViewModel.loginCompleteSubject subscribeNext:^(NSNumber *x) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self hanleLoginResult:x.integerValue];
        });
    }];
    self.accountLabel.hidden = !self.accountTextField.hidden;
}

- (void)hanleLoginResult:(StreamResultType)resultType {
    switch (resultType) {
        case StreamResultTypeSussessful: {
            [MBProgressHUD showSuccess:@"登录成功"];
            UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            self.view.window.rootViewController = mainStoryBoard.instantiateInitialViewController;
            break;
        }
        case StreamResultTypeFailure: {
            [MBProgressHUD showError:@"账号或密码错误"];
            [self.accountTextField textFieldSpringAnimation];
            [self.passwordTextField textFieldSpringAnimation];
            break;
        }
        case StreamResultTypeTimeout: {
            [MBProgressHUD showError:@"登录超时，请检查网络"];
            break;
        }
            
        default:
            break;
    }
}

- (void)configureSubViews {
    self.accountLabel.text = [[StreamManager shareManager] loadAccountFromSandbox];
    self.accountTextField.leftView = ({
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 4, 22, 22)];
        imageView.image = [UIImage imageNamed:@"iconfont-user"];
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [view addSubview:imageView];
        view;
    });
    self.accountTextField.leftViewMode = UITextFieldViewModeAlways;
    self.accountTextField.layer.borderWidth = 1.0f;
    self.accountTextField.layer.borderColor = [UIColor grayColor].CGColor;
    self.accountTextField.layer.cornerRadius = 5.0f;
    self.accountTextField.layer.shadowColor = [UIColor greenColor].CGColor;
    self.accountTextField.layer.shadowRadius = 5.0;
    self.accountTextField.layer.shadowPath = CGPathCreateWithRoundedRect(CGRectMake(0, 2, self.accountTextField.width, self.accountTextField.height), 5.0, 5.0,NULL);
    self.accountTextField.layer.masksToBounds = NO;
    
    
    self.passwordTextField.leftView = ({
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        imageView.image = [UIImage imageNamed:@"iconfont-password"];
        imageView;
    });
    self.passwordTextField.leftViewMode = UITextFieldViewModeAlways;
    self.passwordTextField.layer.borderWidth = 1.0f;
    self.passwordTextField.layer.borderColor = [UIColor grayColor].CGColor;
    self.passwordTextField.layer.cornerRadius = 5.0;
    self.passwordTextField.layer.shadowColor = [UIColor greenColor].CGColor;
    self.passwordTextField.layer.shadowRadius = 5.0;
    self.passwordTextField.layer.shadowPath = CGPathCreateWithRoundedRect(CGRectMake(0, 2, self.passwordTextField.width, self.passwordTextField.height), 5.0, 5.0,NULL);
    self.passwordTextField.layer.masksToBounds = NO;

    
    self.loginBtn.layer.cornerRadius = 5.0f;
    [self.loginBtn setBackgroundImage:[UIImage autoStretchWithimageName:@"fts_green_btn"] forState:UIControlStateNormal];
    [self.loginBtn setBackgroundImage:[UIImage autoStretchWithimageName:@"fts_green_btn_HL"] forState:UIControlStateHighlighted];
}
#pragma mark - btn action

- (void)switchAccountBtnSignal {
    @weakify(self);
    [[self.switchAccountBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        self.accountLabel.hidden = YES;
        self.accountTextField.hidden = NO;
        self.accountTextField.layer.borderColor = [UIColor grayColor].CGColor;
        self.passwordTextField.layer.borderColor = [UIColor grayColor].CGColor;
        self.passwordTextField.text = @"";
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"register"]) {
        UINavigationController *nav = segue.destinationViewController;
        RegisterViewController *registerVC = (RegisterViewController *)nav.topViewController;
        registerVC.registerDidFinishBlock = ^(NSString *account){
            self.accountLabel.hidden = NO;
            self.accountLabel.text = account;
            self.accountTextField.hidden = YES;
        };
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.accountTextField.layer.borderColor = [UIColor grayColor].CGColor;
    self.passwordTextField.layer.borderColor = [UIColor grayColor].CGColor;
    
     textField.layer.shadowOpacity = 1.0f;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    textField.layer.shadowOpacity = .0f;
}

- (void)dealloc {
    NSLog(@"%s",__func__);
}

- (LoginViewModel *)loginViewModel {
    if (!_loginViewModel) {
        _loginViewModel = [[LoginViewModel alloc] init];
    }
    return _loginViewModel;
}

@end
