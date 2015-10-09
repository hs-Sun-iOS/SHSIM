//
//  LoginManager.m
//  SHSIM
//
//  Created by apple on 15/9/23.
//  Copyright (c) 2015年 SHSDeveloper. All rights reserved.
//

#import "LoginManager.h"
#import "XMPPFramework.h"

@interface LoginManager ()<XMPPStreamDelegate> {
    
    XMPPStream *_stream;
    void (^_successfulHandle)();
    void (^_failureHandle)(NSError *);
    
    NSString *_password;
}
@end

@implementation LoginManager

#pragma mark - single Instance

+ (instancetype)shareManager {
    static LoginManager *_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[LoginManager alloc] init];
    });
    return _manager;
}

#pragma mark - Public Method
- (void)loginToSeverWith:(NSString *)account andPassword:(NSString *)password successfulHandle:(void (^)())successfulHandle andfailureHandle:(void (^)(NSError *))failureHandle{
    _successfulHandle = successfulHandle;
    _failureHandle = failureHandle;
    _password = password;
    _stream = ({
        XMPPStream *stream = [[XMPPStream alloc] init];
        [stream addDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
        stream.myJID = ({
            XMPPJID *jId = [XMPPJID jidWithUser:account domain:@"sunhaosheng.local" resource:@"iOS"];
            jId;
        });
        stream.hostName = @"sunhaosheng.local";
        stream.hostPort = 5222;
        stream;
    });
    NSError *error = nil;
    [_stream connectWithTimeout:XMPPStreamTimeoutNone error:&error];
}

- (void)logoutFromSever {
    [_stream disconnect];
    [_stream sendElement:[XMPPPresence presenceWithType:@"unavailable"]];
}

#pragma mark - XMPPStreamDelegate

- (void)xmppStreamDidConnect:(XMPPStream *)sender {
#ifdef IM_DEBUG
    NSLog(@"connect to server successful!");
#endif
    NSError *error = nil;
    [_stream authenticateWithPassword:_password error:&error];
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error {
    if (error) {
#ifdef IM_DEBUG
        NSLog(@"connect to server failure! reason:%@",error.localizedDescription);
#endif
        _failureHandle(error);
    }
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
#ifdef IM_DEBUG
    NSLog(@"authenticate successfully!");
#endif
    [_stream sendElement:[XMPPPresence presence]];
    _successfulHandle();
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error {
#ifdef IM_DEBUG
    NSLog(@"authenticate failure! reason:%@",error);
#endif
    _failureHandle(nil);
}




@end
