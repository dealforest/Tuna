//
//  IDESourceCodeComparisonEditor.h
//  Tuna
//
//  Created by Toshihiro Morimoto on 3/11/15.
//  Copyright (c) 2015 Toshihiro Morimoto. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DVTSourceTextView;

@interface IDESourceCodeComparisonEditor : NSObject

@property(readonly) DVTSourceTextView *keyTextView;

@end