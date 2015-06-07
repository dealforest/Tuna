//
//  TunaLLDBInjector.h
//  Tuna
//
//  Created by Toshihiro Morimoto on 6/8/15.
//  Copyright (c) 2015 Toshihiro Morimoto. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DBGLLDBSession;

@interface TunaLLDBInjector : NSObject

@property (nonatomic, readonly, getter=isRunning) BOOL running;

+ (instancetype)sharedInstance;

- (void)start;
- (void)stop;

- (void)handleSessionPause:(DBGLLDBSession *)session;

@end
