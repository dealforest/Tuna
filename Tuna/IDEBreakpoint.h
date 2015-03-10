//
//  IDEBreakpoint.h
//  Tuna
//
//  Created by Toshihiro Morimoto on 3/11/15.
//  Copyright (c) 2015 Toshihiro Morimoto. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IDEBreakpoint : NSObject

@property(copy) NSString *displayName;
@property(copy) NSArray *actions;
@property(readonly) NSMutableArray *mutableActions;
@property BOOL continueAfterRunningActions;

@end