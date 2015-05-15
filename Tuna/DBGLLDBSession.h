//
//  DBGLLDBSession.h
//  Tuna
//
//  Created by Toshihiro Morimoto on 5/16/15.
//  Copyright (c) 2015 Toshihiro Morimoto. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBGDebugSession.h"

@class DBGLLDBLauncher;

@interface DBGLLDBSession : DBGDebugSession

@property BOOL pauseRequested;
@property(readonly) DBGLLDBLauncher *launcher;

- (id)dbgLLDBProcess;

@end
