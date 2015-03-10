//
//  IDEBreakpointAction.h
//  Tuna
//
//  Created by Toshihiro Morimoto on 3/11/15.
//  Copyright (c) 2015 Toshihiro Morimoto. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IDEBreakpointAction : NSObject

@property(copy) NSString *displayName; // @synthesize displayName=_displayName;
@property(getter=isDisplayable) BOOL displayable; // @synthesize displayable=_displyable;

@end