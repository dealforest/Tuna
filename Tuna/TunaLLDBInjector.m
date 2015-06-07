//
//  TunaLLDBInjector.m
//  Tuna
//
//  Created by Toshihiro Morimoto on 6/8/15.
//  Copyright (c) 2015 Toshihiro Morimoto. All rights reserved.
//

#import "TunaLLDBInjector.h"

#import "DBGLLDBSession.h"
#import "DBGLLDBLauncher.h"

@interface TunaLLDBInjector()

@property (nonatomic) BOOL running;
@property (nonatomic, weak) DBGLLDBSession *lastSession;

@end


@implementation TunaLLDBInjector

+ (instancetype)sharedInstance
{
    static id sharedInstance;
    static dispatch_once_t _onceToken;
    dispatch_once( &_onceToken, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}

- (void)start
{
  self.running = YES;
}

- (void)stop
{
  self.running = NO;
}

- (void)handleSessionPause:(DBGLLDBSession *)session
{
    __weak typeof(self) wself = self;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        if ([[session process] isPaused] && wself.isRunning && wself.lastSession != session) {
//            [[session launcher] _executeLLDBCommands:@"p @import UIKit\n"];
//            [[session launcher] _executeLLDBCommands:@"p @import Foundation\n"];
//            [[session launcher] _executeLLDBCommands:@"po @\"import framework UIKit and Foundation\"\n"];
            wself.lastSession = session;
        }
    });
}

@end
