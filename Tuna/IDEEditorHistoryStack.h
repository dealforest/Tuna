//
//  IDEEditorHistoryStack.h
//  Tuna
//
//  Created by Toshihiro Morimoto on 3/13/15.
//  Copyright (c) 2015 Toshihiro Morimoto. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IDEEditorHistoryItem;

@interface IDEEditorHistoryStack : NSObject

@property(readonly) IDEEditorHistoryItem *currentEditorHistoryItem;

@end