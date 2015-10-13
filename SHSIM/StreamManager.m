//
//  StreamManager.m
//  SHSIM
//
//  Created by apple on 15/9/23.
//  Copyright (c) 2015年 SHSDeveloper. All rights reserved.
//

#import "StreamManager.h"
#import "XMPPFramework.h"

@interface StreamManager ()<XMPPStreamDelegate> {
    
    XMPPStream *_stream;
    XMPPvCardTempModule *_vCard;
    XMPPvCardCoreDataStorage *_vCardStorage;
    XMPPvCardAvatarModule *_avatar;
    
    void (^_completeBlock)(StreamResultType);
    NSString *_account;
    NSString *_password;
}
@end

#define AccountKey  @"KAccount"
#define PasswordKey @"KPassword"
#define LoginStatusKey @"KloginStatus"
#define LoginTag @"login"
#define RegisterTag @"register"

@implementation StreamManager

#pragma mark - single Instance

+ (instancetype)shareManager {
    static StreamManager *_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[StreamManager alloc] init];
    });
    return _manager;
}

#pragma mark - Private Method

- (void)connectToSever {
    [_stream disconnect];
    _stream = nil;
    _stream = ({
        XMPPStream *stream = [[XMPPStream alloc] init];
        [stream addDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
        stream.myJID = ({
            XMPPJID *jId = [XMPPJID jidWithUser:_account domain:@"sunhaosheng.local" resource:@"iOS"];
            jId;
        });
        stream.hostName = @"sunhaosheng.local";
        stream.hostPort = 5222;
        stream;
    });
    _vCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
    _vCard = [[XMPPvCardTempModule alloc] initWithvCardStorage:_vCardStorage];
    [_vCard activate:_stream];
    _avatar = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:_vCard];
    [_avatar activate:_stream];
    NSError *error = nil;
    [_stream connectWithTimeout:XMPPStreamTimeoutNone error:&error];

}

#pragma mark - Public Method
- (void)loginToSeverWithAccount:(NSString *)account andPassword:(NSString *)password completeBlock:(void (^)(StreamResultType))completeBlock {
    _completeBlock = completeBlock;
    _password = password;
    _account = account;
    [self connectToSever];
    _stream.tag = LoginTag;
}

- (void)registerNewAccount:(NSString *)account andPassword:(NSString *)password completeBlock:(void (^)(StreamResultType))completeBlock {
    _completeBlock = completeBlock;
    _account = account;
    _password = password;
    [self connectToSever];
    _stream.tag = RegisterTag;
}

- (void)logoutFromSever {
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:LoginStatusKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [_stream disconnect];
    [_stream sendElement:[XMPPPresence presenceWithType:@"unavailable"]];
}


- (NSString *)loadAccountFromSandbox {
    return [[NSUserDefaults standardUserDefaults] objectForKey:AccountKey];
}

- (void)saveAccountToSandbox:(NSString *)account {
    [[NSUserDefaults standardUserDefaults] setObject:account forKey:AccountKey];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:LoginStatusKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)loadPasswordFromSandbox {
    return [[NSUserDefaults standardUserDefaults] objectForKey:PasswordKey];
}

- (void)savePasswordToSandbox:(NSString *)password {
    [[NSUserDefaults standardUserDefaults] setObject:password forKey:PasswordKey];
}

- (BOOL)isLogin {
    return [[NSUserDefaults standardUserDefaults] boolForKey:LoginStatusKey];
}

- (BOOL)isConnect {
    return _stream.isConnected;
}

#pragma mark - XMPPStreamDelegate

- (void)xmppStreamDidConnect:(XMPPStream *)sender {
#ifdef IM_DEBUG
    NSLog(@"connect to server successful!");
#endif
    NSError *error = nil;
    if ([sender.tag isEqualToString:LoginTag]) {
       [_stream authenticateWithPassword:_password error:&error];
    } else if ([sender.tag isEqualToString:RegisterTag]) {
        [_stream registerWithPassword:_password error:&error];
    }
    
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error {
    if (error) {
#ifdef IM_DEBUG
        NSLog(@"connect to server failure! reason:%@",error.localizedDescription);
#endif
        if (_completeBlock) {
            _completeBlock(StreamResultTypeTimeout);
        }
    }
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
#ifdef IM_DEBUG
    NSLog(@"authenticate successfully!");
#endif
    [_stream sendElement:[XMPPPresence presence]];
    //save the current account
    [[NSUserDefaults standardUserDefaults] setObject:_account forKey:@"account"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if (_completeBlock) {
        _completeBlock(StreamResultTypeSussessful);
    }
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error {
#ifdef IM_DEBUG
    NSLog(@"authenticate failure! reason:%@",error);
#endif
    
    if (_completeBlock) {
        _completeBlock(StreamResultTypeFailure);
    }
}

-(void)xmppStreamDidRegister:(XMPPStream *)sender {
#ifdef IM_DEBUG
    NSLog(@"register successfully!");
#endif
    if (_completeBlock) {
        _completeBlock(StreamResultTypeSussessful);
    }
}

-(void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error {
#ifdef IM_DEBUG
    NSLog(@"register failure! reason:%@",error);
#endif
    if (_completeBlock) {
        _completeBlock(StreamResultTypeFailure);
    }
}




@end
