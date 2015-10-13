//
//  RegisterViewController.m
//  SHSIM
//
//  Created by apple on 15/10/2.
//  Copyright (c) 2015年 SHSDeveloper. All rights reserved.
//

#import "RegisterViewController.h"
#import "StreamManager.h"
#import "UITextField+SpringAnimation.h"

@interface RegisterViewController ()
@property (weak, nonatomic) IBOutlet UITextField *accountTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextField;
@property (weak, nonatomic) IBOutlet UIButton *registerBtn;

@end

@implementation RegisterViewController


#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self configureSubViews];
}

- (void)configureSubViews {
    self.accountTextField.layer.borderWidth = 0.5f;
    self.accountTextField.layer.cornerRadius = 5.0f;
    
    self.passwordTextField.layer.borderWidth = 0.5f;
    self.passwordTextField.layer.cornerRadius = 5.0f;
    
    self.confirmPasswordTextField.layer.borderWidth = 0.5f;
    self.confirmPasswordTextField.layer.cornerRadius = 5.0f;
    
    self.registerBtn.layer.cornerRadius = 5.0f;
    [self.registerBtn setBackgroundImage:[UIImage autoStretchWithimageName:@"fts_green_btn"] forState:UIControlStateNormal];
    [self.registerBtn setBackgroundImage:[UIImage autoStretchWithimageName:@"fts_green_btn_HL"] forState:UIControlStateHighlighted];
    
    @weakify(self);
    
    RACSignal *accountIsVaildSignal = [self.accountTextField.rac_textSignal map:^id(NSString *text) {
        self_weak_.accountTextField.layer.borderColor = [UIColor blackColor].CGColor;
        return @(text.length > 3);
    }];
    
    RACSignal *passwordIsVaildSignal = [self.passwordTextField.rac_textSignal map:^id(NSString *text) {
        self_weak_.accountTextField.layer.borderColor = [UIColor blackColor].CGColor;
        self_weak_.passwordTextField.layer.borderColor = [UIColor blackColor].CGColor;
        self_weak_.confirmPasswordTextField.layer.borderColor = [UIColor blackColor].CGColor;
        return @(text.length >= 6);
    }];
    
    [self.confirmPasswordTextField.rac_textSignal subscribeNext:^(id x) {
        self_weak_.accountTextField.layer.borderColor = [UIColor blackColor].CGColor;
        self_weak_.passwordTextField.layer.borderColor = [UIColor blackColor].CGColor;
        self_weak_.confirmPasswordTextField.layer.borderColor = [UIColor blackColor].CGColor;
    }];
    
    [[RACSignal combineLatest:@[accountIsVaildSignal,passwordIsVaildSignal] reduce:^id(NSNumber *accountVaild,NSNumber *passwordVaild){
        return @((accountVaild.boolValue) && passwordVaild.boolValue);
    }] subscribeNext:^(NSNumber *isValid) {
        self_weak_.registerBtn.enabled = isValid.boolValue;
    }];
    
    
    [[[self.registerBtn rac_signalForControlEvents:UIControlEventTouchUpInside] flattenMap:^id(id value) {
        [self_weak_.accountTextField resignFirstResponder];
        [self_weak_.passwordTextField resignFirstResponder];
        [self_weak_.confirmPasswordTextField resignFirstResponder];
        if ([self_weak_.passwordTextField.text isEqualToString:self.confirmPasswordTextField.text]) {
            [MBProgressHUD showMessage:@"正在注册新账户..."];
            return [self_weak_ registerResultSignal];
        } else {
            [MBProgressHUD showError:@"两次密码输入不一致"];
            [self_weak_.passwordTextField textFieldSpringAnimation];
            [self_weak_.confirmPasswordTextField textFieldSpringAnimation];
            return nil;
        }
    }] subscribeNext:^(NSNumber *resultType) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUD];
            if (resultType.integerValue == StreamResultTypeSussessful) {
                // login successful
                [MBProgressHUD showSuccess:@"注册成功"];
                [self_weak_ dismissViewControllerAnimated:YES completion:^{
                    self_weak_.registerDidFinishBlock(self_weak_.accountTextField.text);
                }];
            } else if (resultType.integerValue == StreamResultTypeFailure){
                [MBProgressHUD showError:@"用户名已经存在"];
                // login fail
                [self.accountTextField textFieldSpringAnimation];
            } else if (resultType.integerValue == StreamResultTypeTimeout) {
                // login timeout
                [MBProgressHUD showError:@"连接服务器超时，请检查您的网络"];
            }
        });
    }];
}

- (RACSignal *)registerResultSignal {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [[StreamManager shareManager] registerNewAccount:self_weak_.accountTextField.text andPassword:self_weak_.passwordTextField.text completeBlock:^(StreamResultType resultType) {
            [subscriber sendNext:@(resultType)];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
}
- (IBAction)backBtnClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.accountTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    [self.confirmPasswordTextField resignFirstResponder];
}


@end
