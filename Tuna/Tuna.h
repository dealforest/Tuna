//
//  Tuna.h
//  Tuna
//
//  Created by Toshihiro Morimoto on 3/11/15.
//  Copyright (c) 2015 Toshihiro Morimoto. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface Tuna : NSObject

+ (void)pluginDidLoad:(NSBundle *)bundle;
+ (instancetype)sharedInstance;

@end