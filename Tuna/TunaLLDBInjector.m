//
//  TunaLLDBInjector.m
//  Tuna
//
//  Created by Toshihiro Morimoto on 6/8/15.
//  Copyright (c) 2015 Toshihiro Morimoto. All rights reserved.
//

#import "TunaLLDBInjector.h"
#import "TunaIDEHelper.h"

#import "DBGLLDBSession.h"
#import "DBGLLDBLauncher.h"

static NSString * const TunaLLDBFileName = @".lldbinit-Tuna";

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
    if (!self.running || self.lastSession == session) {
        return;
    }
    
    __weak typeof(self) wself = self;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        if ([[session process] isPaused]) {
            // {PROJECT_ROOT}/.lldbinit-Tuna
            IDEWorkspace *workspace = [TunaIDEHelper currentWorkspace];
            DVTFilePath *representingFilePath = workspace.representingFilePath;
            NSString *projectRootPath = [representingFilePath.pathString stringByDeletingLastPathComponent];
            [wself loadLLDBFileWithPath:[projectRootPath stringByAppendingPathComponent:TunaLLDBFileName]
                               session:session];

            // {HOME}/.lldbinit-Tuna
            NSString *homeRootPath = [NSProcessInfo processInfo].environment[@"HOME"];
            [wself loadLLDBFileWithPath:[homeRootPath stringByAppendingPathComponent:TunaLLDBFileName]
                               session:session];
            
            wself.lastSession = session;
        }
    });
}

- (void)loadLLDBFileWithPath:(NSString *)path session:(DBGLLDBSession *)session
{
    NSString *text = [NSString stringWithContentsOfFile:path
                                               encoding:NSUTF8StringEncoding
                                                  error:nil];
    if (text) {
        NSArray *lines = [text componentsSeparatedByString:@"\n"];
        for (NSString *command in lines) {
            if ([command isEqualToString:@""]) {
                continue;
            }
            [[session launcher] _executeLLDBCommands:command];
        }
    }
}

@end
