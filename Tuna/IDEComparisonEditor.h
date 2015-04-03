//
//  IDEComparisonEditor.h
//  Tuna
//
//  Created by Tomohiro Kumagai on H27/04/03.
//  Copyright (c) 平成27年 Toshihiro Morimoto. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IDEEditor;

@interface IDEComparisonEditor : IDEEditor

- (id)secondaryEditorInstance;
- (id)primaryEditorInstance;
- (id)keyEditor;

@end