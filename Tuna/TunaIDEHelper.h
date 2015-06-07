//
//  TunaIDEHelper.h
//  Tuna
//
//  Created by Toshihiro Morimoto on 6/8/15.
//  Copyright (c) 2015 Toshihiro Morimoto. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "Xcode.h"

typedef NS_ENUM(NSInteger, EditorType)
{
    EditorTypeOther,
    EditorTypeSourceCodeEditor,
    EditorTypeSourceCodeComparisonEditor
};

@interface TunaIDEHelper : NSObject

+ (IDEWorkspace *)currentWorkspace;
+ (IDEWorkspaceDocument *)currentWorkspaceDocument;
+ (IDEEditorContext *)currentEditorContext;
+ (IDEEditor *)currentEditor;
+ (IDESourceCodeEditor *)currentSourceCodeEditor;
+ (NSTextView *)currentSourceCodeTextView;
+ (long long)currentLineNumberWithEditor:(IDESourceCodeEditor *)editor;

/// Get type of the editor.
+ (EditorType)editorTypeOf:(IDEEditor *)editor;

/// Returns whether a SourceCodeComparisonEditor's primary editor is key editor.
+ (BOOL)isKeyEditorEqualToPrimaryEditor:(IDESourceCodeComparisonEditor *)sourceCodeComparisonEditor;

/// Get key SourceCodeEditor from a SourceCodeComparisonEditor.
+ (IDESourceCodeEditor *)getKeySourceCodeEditor:(IDESourceCodeComparisonEditor *)sourceCodeComparisonEditor;

/// Get key SourceCodeEditor from a SourceCodeComparisonEditor. If the SourceCodeComparisonEditor's primary editor is not key editor, return nil.
+ (IDESourceCodeEditor *)getKeySourceCodeEditorOnlyIfKeyEditorIsEqualToPrimaryEditor:(IDESourceCodeComparisonEditor *)sourceCodeComparisonEditor;

@end
