//
//  TunaSwizzler.m
//  Tuna
//
//  Created by Toshihiro Morimoto on 5/16/15.
//  Copyright (c) 2015 Toshihiro Morimoto. All rights reserved.
//

#import "TunaSwizzler.h"
#import "DBGLLDBSession.h"
#import "DBGLLDBLauncher.h"
#import <objc/runtime.h>

@implementation TunaSwizzler

+ (void)load
{
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    [self swizzle:@selector(DBGLLDBSession$setPauseRequested:)];
  });
}

+ (void)swizzle:(SEL)sourceSelector
{
    @try {
        NSArray *components = [NSStringFromSelector(sourceSelector) componentsSeparatedByString:@"$"];
        
        Class sourceClass = self;
        Method sourceMethod = class_getInstanceMethod(sourceClass, sourceSelector);
        Class destinationClass = NSClassFromString(components[0]);
        SEL destinationSelector = NSSelectorFromString(components[1]);
        
        class_addMethod(destinationClass, sourceSelector, method_getImplementation(sourceMethod), method_getTypeEncoding(sourceMethod));
        
        Method originalMethod = class_getInstanceMethod(destinationClass, sourceSelector);
        Method swizzledMethod = class_getInstanceMethod(destinationClass, destinationSelector);
        
        method_exchangeImplementations(originalMethod, swizzledMethod);
        
    } @catch (NSException *exception) {
        NSLog(@"TunaSwizzler: Failed to swizzle %@. %@", NSStringFromSelector(sourceSelector), exception);
    }
}


#pragma mark - swizzle for ideplugin

- (void)DBGLLDBSession$setPauseRequested:(BOOL)pauseRequested
{
    [self DBGLLDBSession$setPauseRequested:pauseRequested];
    
    if (!pauseRequested) {
        __weak DBGLLDBSession *wself = (DBGLLDBSession *)self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            if ([[wself process] isPaused]) {
                [[wself launcher] _executeLLDBCommands:@"p @import Foundation\n"];
                [[wself launcher] _executeLLDBCommands:@"p @import UIKit\n"];
            }
        });
    }
}

@end
