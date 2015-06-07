//
//  TunaIDEHelper.m
//  Tuna
//
//  Created by Toshihiro Morimoto on 6/8/15.
//  Copyright (c) 2015 Toshihiro Morimoto. All rights reserved.
//

#import "TunaIDEHelper.h"

@implementation TunaIDEHelper

+ (IDEWorkspace *)currentWorkspace
{
    NSWindowController *currentWindowController = [[NSApp keyWindow] windowController];
    if ([currentWindowController isKindOfClass:NSClassFromString(@"IDEWorkspaceWindowController")]) {
        return [currentWindowController valueForKey:@"_workspace"];
    }
    else {
        return nil;
    }
}

+ (IDEWorkspaceDocument *)currentWorkspaceDocument
{
    NSWindowController *currentWindowController = [[NSApp keyWindow] windowController];
    id document = [currentWindowController document];
    if (currentWindowController && [document isKindOfClass:NSClassFromString(@"IDEWorkspaceDocument")]) {
        return (IDEWorkspaceDocument *)document;
    }
    else {
        return nil;
    }
}

+ (IDEEditorContext *)currentEditorContext
{
    NSWindowController *currentWindowController = [[NSApp keyWindow] windowController];
    if ([currentWindowController isKindOfClass:NSClassFromString(@"IDEWorkspaceWindowController")]) {
        IDEEditorArea *editorArea = [(IDEWorkspaceWindowController *)currentWindowController editorArea];
        return [editorArea lastActiveEditorContext];
    }
    else {
        return nil;
    }
}

+ (IDEEditor *)currentEditor
{
    IDEEditorContext *editorContext = [self currentEditorContext];
    if (editorContext) {
        return [editorContext editor];
    }
    else {
        return nil;
    }
}

+ (EditorType)editorTypeOf:(IDEEditor *)editor
{
    NSDictionary *editors = @{
                             @"IDESourceCodeEditor" : @(EditorTypeSourceCodeEditor),
                             @"IDESourceCodeComparisonEditor" : @(EditorTypeSourceCodeComparisonEditor)
                             };
    
    for (NSString *className in editors.allKeys) {
        if ([editor isKindOfClass:NSClassFromString(className)]) {
            return (EditorType)[editors[className] integerValue];
        }
    }
    
    return EditorTypeOther;
}

+ (IDESourceCodeEditor *)currentSourceCodeEditor
{
    IDEEditor *editor = [self currentEditor];
    
    switch ([self editorTypeOf:editor]) {
        case EditorTypeSourceCodeEditor:
            return (IDESourceCodeEditor *)editor;

        case EditorTypeSourceCodeComparisonEditor:
            return [self getKeySourceCodeEditorOnlyIfKeyEditorIsEqualToPrimaryEditor:(IDESourceCodeComparisonEditor*)editor];
            
        case EditorTypeOther:
            return nil;
    }
}

+ (BOOL)isKeyEditorEqualToPrimaryEditor:(IDESourceCodeComparisonEditor *)sourceCodeComparisonEditor
{
    return sourceCodeComparisonEditor.keyEditor == sourceCodeComparisonEditor.primaryEditorInstance;
}

+ (IDESourceCodeEditor *)getKeySourceCodeEditorOnlyIfKeyEditorIsEqualToPrimaryEditor:(IDESourceCodeComparisonEditor *)sourceCodeComparisonEditor
{
    if ([self isKeyEditorEqualToPrimaryEditor:sourceCodeComparisonEditor]) {
        return [self getKeySourceCodeEditor:sourceCodeComparisonEditor];
    }
    else {
        return nil;
    }
}

+ (IDESourceCodeEditor *)getKeySourceCodeEditor:(IDESourceCodeComparisonEditor *)sourceCodeComparisonEditor
{
    IDEEditor *editor = sourceCodeComparisonEditor.keyEditor;
    
    switch ([self editorTypeOf:editor]) {
        case EditorTypeSourceCodeEditor:
            return (IDESourceCodeEditor*)editor;
            
        case EditorTypeSourceCodeComparisonEditor:
        case EditorTypeOther:
            return nil;
    }
}


+ (NSTextView *)currentSourceCodeTextView
{
    IDEEditor *editor = [self currentEditor];
    
    switch ([self editorTypeOf:editor]) {
        case EditorTypeSourceCodeEditor:
            return (NSTextView *)editor.textView;
            
        case EditorTypeSourceCodeComparisonEditor:
            return (NSTextView *)((IDESourceCodeComparisonEditor *)editor).keyTextView;
            
        case EditorTypeOther:
            return nil;
    }
}

+ (long long)currentLineNumberWithEditor:(IDESourceCodeEditor *)editor
{
    return [editor respondsToSelector:@selector(_currentOneBasedLineNumber)] ? editor._currentOneBasedLineNumber : editor._currentOneBasedLineNubmer;
}

@end
