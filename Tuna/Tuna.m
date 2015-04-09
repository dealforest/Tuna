//
//  Tuna.m
//  Tuna
//
//  Created by Toshihiro Morimoto on 3/11/15.
//  Copyright (c) 2015 Toshihiro Morimoto. All rights reserved.
//

#import "Tuna.h"
#import "Xcode.h"

static id _sharedInstance = nil;


static Tuna *sharedPlugin;

/// SourceCodeEditor Type.
typedef NS_ENUM(NSInteger, EditorType)
{
    EditorTypeOther,
    EditorTypeSourceCodeEditor,
    EditorTypeSourceCodeComparisonEditor
};

@interface Tuna()

@property (nonatomic, strong, readwrite) NSBundle *bundle;

/// Install Tuna menu item in Xcode.
- (void)installMenuItem:(NSMenuItem*)menu;

/// Get type of the editor.
- (EditorType)editorTypeOf:(IDEEditor*)editor;

/// Returns whether a SourceCodeComparisonEditor's primary editor is key editor.
- (BOOL)isKeyEditorEqualToPrimaryEditor:(IDESourceCodeComparisonEditor*)sourceCodeComparisonEditor;

/// Get key SourceCodeEditor from a SourceCodeComparisonEditor.
- (IDESourceCodeEditor *)getKeySourceCodeEditor:(IDESourceCodeComparisonEditor*)sourceCodeComparisonEditor;

/// Get key SourceCodeEditor from a SourceCodeComparisonEditor. If the SourceCodeComparisonEditor's primary editor is not key editor, return nil.
- (IDESourceCodeEditor *)getKeySourceCodeEditorOnlyIfKeyEditorIsEqualToPrimaryEditor:(IDESourceCodeComparisonEditor*)sourceCodeComparisonEditor;

@end

@implementation Tuna

+ (void)pluginDidLoad:(NSBundle *)bundle
{
    static dispatch_once_t _onceToken;
    dispatch_once(&_onceToken, ^{
        _sharedInstance = [self new];
    });
}

+ (instancetype)sharedInstance
{
    return _sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
         [self createMenuItem];
    }
    return self;
}

#pragma mark - menu

- (void)createMenuItem
{
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *pluginName = [bundle objectForInfoDictionaryKey:(NSString *)kCFBundleNameKey];
    NSString *pluginVersion = [bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    
    NSMenu *pluginMenu = [[NSMenu alloc] initWithTitle:pluginName];
    [pluginMenu addItem:({
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:[@"Plugin Version: " stringByAppendingString:pluginVersion]
                                                      action:nil
                                               keyEquivalent:@""];
        item;
    })];
    
    [pluginMenu addItem:[NSMenuItem separatorItem]];
    
    [pluginMenu addItem:({
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"Toggle Breakpoint"
                                                      action:@selector(toggleEnableFileBreakpoint)
                                               keyEquivalent:@"["];
        [item setKeyEquivalentModifierMask:NSShiftKeyMask|NSCommandKeyMask];

        item.target = self;
        item;
    })];
    [pluginMenu addItem:({
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"Clear All File Breakpoint"
                                                      action:@selector(clearAllFileBreakpoint)
                                               keyEquivalent:@"]"];
        [item setKeyEquivalentModifierMask:NSShiftKeyMask|NSCommandKeyMask];

        item.target = self;
        item;
    })];
    
    [pluginMenu addItem:[NSMenuItem separatorItem]];
    
    [pluginMenu addItem:({
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"Set Print Breakpoint"
                                                      action:@selector(setPrintBreakpoint)
                                               keyEquivalent:@"'"];
        [item setKeyEquivalentModifierMask:NSShiftKeyMask|NSCommandKeyMask];

        item.target = self;
        item;
    })];
    [pluginMenu addItem:({
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"Set Backtrace Breakpoint"
                                                      action:@selector(setBacktraceBreakpoint)
                                               keyEquivalent:@";"];
        [item setKeyEquivalentModifierMask:NSShiftKeyMask|NSCommandKeyMask];

        item.target = self;
        item;
    })];
    
    NSMenuItem *pluginMenuItem = [[NSMenuItem alloc] initWithTitle:pluginName action:nil keyEquivalent:@""];
    pluginMenuItem.submenu = pluginMenu;
    [self installMenuItem:pluginMenuItem];
}

- (void)installMenuItem:(NSMenuItem *)menuItem
{
    NSMenuItem *debugMenuItem = [[NSApp mainMenu] itemWithTitle:@"Debug"];
    NSMenu *debugSubmenu = debugMenuItem.submenu;
    NSMenuItem *debugBreakpointsMenuItem = [debugSubmenu itemWithTitle:@"Breakpoints"];
    NSUInteger indexForInsertMenu = [debugSubmenu.itemArray indexOfObject:debugBreakpointsMenuItem] + 1;
    
    [debugSubmenu insertItem:menuItem atIndex:indexForInsertMenu];
}

#pragma mark - menu selector

- (void)toggleEnableFileBreakpoint
{
    IDESourceCodeEditor *currentSourceCodeEditor = [self currentSourceCodeEditor];
    
    if (!currentSourceCodeEditor)
    {
        NSBeep();
        return;
    }
    
    long long lineNumber = [self currentLineNumberWithEditor:currentSourceCodeEditor];
    DVTTextDocumentLocation *documentLocation = [self documentLocationWithLineNumber:lineNumber];
    IDEFileBreakpoint *breakpoint = [[self currentWorkspace].breakpointManager fileBreakpointAtDocumentLocation:documentLocation];
    if (breakpoint) {
        [breakpoint toggleShouldBeEnabled];
    }
}

- (void)clearAllFileBreakpoint
{
    IDEWorkspace *workspace = [self currentWorkspace];
    NSMutableIndexSet *target = [NSMutableIndexSet indexSet];
    NSUInteger index = 0;
    for (IDEBreakpoint *breakpoint in workspace.breakpointManager.breakpoints) {
        if ([breakpoint isKindOfClass:[IDEFileBreakpoint class]]) {
            [target addIndex:index];
        }
        index++;
    }
    [workspace.breakpointManager.mutableBreakpoints removeObjectsAtIndexes:target];
}

- (void)setPrintBreakpoint
{
    NSTextView *textView = [self currentSourceCodeTextView];
    NSString *selectedText = [[textView.string substringWithRange:textView.selectedRange]
                              stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (selectedText.length == 0) {
        NSBeep();
        return;
    }
    
    IDESourceCodeEditor *currentSourceCodeEditor = [self currentSourceCodeEditor];
    
    if (!currentSourceCodeEditor)
    {
        NSBeep();
        return;
    }

    long long lineNumber = [self currentLineNumberWithEditor:currentSourceCodeEditor] + 1;
    DVTTextDocumentLocation *documentLocation = [self documentLocationWithLineNumber:lineNumber];
    IDEFileBreakpoint *breakpoint = [self fileBreakpointAtDocumentLocation:documentLocation];
    [breakpoint.mutableActions addObject:({
        IDELogBreakpointAction *action = [IDELogBreakpointAction new];
        action.message = [NSString stringWithFormat:@"🐟🐟🐟🐟🐟🐟🐟🐟🐟🐟 %@", selectedText];
        action;
    })];
    [breakpoint.mutableActions addObject:({
        IDEDebuggerCommandBreakpointAction *action = [IDEDebuggerCommandBreakpointAction new];
        action.consoleCommand = [@"po " stringByAppendingString:selectedText];
        action;
    })];
    [breakpoint.mutableActions addObject:({
        IDEDebuggerCommandBreakpointAction *action = [IDEDebuggerCommandBreakpointAction new];
        action.consoleCommand = @"bt 0";
        action;
    })];
}

- (void)setBacktraceBreakpoint
{
    IDESourceCodeEditor *currentSourceCodeEditor = [self currentSourceCodeEditor];
    
    if (!currentSourceCodeEditor)
    {
        NSBeep();
        return;
    }

    long long lineNumber = [self currentLineNumberWithEditor:currentSourceCodeEditor];
    DVTTextDocumentLocation *documentLocation = [self documentLocationWithLineNumber:lineNumber];
    IDEFileBreakpoint *breakpoint = [self fileBreakpointAtDocumentLocation:documentLocation];
    [breakpoint.mutableActions addObject:({
        IDELogBreakpointAction *action = [IDELogBreakpointAction new];
        action.message = @"🐟🐟🐟🐟🐟🐟🐟🐟🐟🐟 backtrace";
        action;
    })];
    [breakpoint.mutableActions addObject:({
        IDEDebuggerCommandBreakpointAction *action = [IDEDebuggerCommandBreakpointAction new];
        action.consoleCommand = @"bt 5";
        action;
    })];
}

#pragma mark - private

- (IDEFileBreakpoint *)fileBreakpointAtDocumentLocation:(DVTTextDocumentLocation *)documentLocation
{
    IDEWorkspace *workspace = [self currentWorkspace];
    IDEFileBreakpoint *breakpoint = [workspace.breakpointManager fileBreakpointAtDocumentLocation:documentLocation] ?:
        [workspace.breakpointManager createFileBreakpointAtDocumentLocation:documentLocation];
    breakpoint.continueAfterRunningActions = YES;
    return breakpoint;
}

- (DVTTextDocumentLocation *)documentLocationWithLineNumber:(long long)lineNumber
{
    IDEEditorContext *editorContext = [self currentEditorContext];
    IDEEditorHistoryStack *stack = [editorContext currentHistoryStack];
    NSNumber *timestamp = @([[NSDate date] timeIntervalSince1970]);
    return [[DVTTextDocumentLocation alloc] initWithDocumentURL:stack.currentEditorHistoryItem.documentURL
                                                      timestamp:timestamp
                                                      lineRange:NSMakeRange(MAX(lineNumber, 0), lineNumber)];
}

#pragma mark - IDE helper

- (IDEWorkspace *)currentWorkspace
{
    NSWindowController *currentWindowController = [[NSApp keyWindow] windowController];
    if ([currentWindowController isKindOfClass:NSClassFromString(@"IDEWorkspaceWindowController")]) {
        return [currentWindowController valueForKey:@"_workspace"];
    }
    else {
        return nil;
    }
}

- (IDEWorkspaceDocument *)currentWorkspaceDocument
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

- (IDEEditorContext *)currentEditorContext
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

- (IDEEditor *)currentEditor
{
    IDEEditorContext *editorContext = [self currentEditorContext];
    if (editorContext) {
        return [editorContext editor];
    }
    else {
        return nil;
    }
}

- (EditorType)editorTypeOf:(IDEEditor *)editor
{
    NSDictionary* editors = @{
                         @"IDESourceCodeEditor" : @(EditorTypeSourceCodeEditor),
                         @"IDESourceCodeComparisonEditor" : @(EditorTypeSourceCodeComparisonEditor)
                         };
    
    for (NSString* className in editors.allKeys)
    {
        if ([editor isKindOfClass:NSClassFromString(className)])
        {
            return (EditorType)[editors[className] integerValue];
        }
    }
    
    return EditorTypeOther;
}

- (IDESourceCodeEditor *)currentSourceCodeEditor
{
    IDEEditor *editor = [self currentEditor];
    
    switch ([self editorTypeOf:editor])
    {
        case EditorTypeSourceCodeEditor:
            return (IDESourceCodeEditor *)editor;

        case EditorTypeSourceCodeComparisonEditor:
            return [self getKeySourceCodeEditorOnlyIfKeyEditorIsEqualToPrimaryEditor:(IDESourceCodeComparisonEditor*)editor];
            
        case EditorTypeOther:
            return nil;
    }
}

- (BOOL)isKeyEditorEqualToPrimaryEditor:(IDESourceCodeComparisonEditor*)sourceCodeComparisonEditor
{
    return sourceCodeComparisonEditor.keyEditor == sourceCodeComparisonEditor.primaryEditorInstance;
}

- (IDESourceCodeEditor *)getKeySourceCodeEditorOnlyIfKeyEditorIsEqualToPrimaryEditor:(IDESourceCodeComparisonEditor*)sourceCodeComparisonEditor
{
    if ([self isKeyEditorEqualToPrimaryEditor:sourceCodeComparisonEditor])
    {
        return [self getKeySourceCodeEditor:sourceCodeComparisonEditor];
    }
    else
    {
        return nil;
    }
}

- (IDESourceCodeEditor *)getKeySourceCodeEditor:(IDESourceCodeComparisonEditor*)sourceCodeComparisonEditor
{
    IDEEditor *editor = sourceCodeComparisonEditor.keyEditor;
    
    switch ([self editorTypeOf:editor])
    {
        case EditorTypeSourceCodeEditor:
            return (IDESourceCodeEditor*)editor;
            
        case EditorTypeSourceCodeComparisonEditor:
        case EditorTypeOther:
            return nil;
    }
}


- (NSTextView *)currentSourceCodeTextView
{
    IDEEditor *editor = [self currentEditor];
    
    switch ([self editorTypeOf:editor])
    {
        case EditorTypeSourceCodeEditor:
            return (NSTextView *)editor.textView;
            
        case EditorTypeSourceCodeComparisonEditor:
            return (NSTextView *)((IDESourceCodeComparisonEditor *)editor).keyTextView;
            
        case EditorTypeOther:
            return nil;
    }
}

- (long long)currentLineNumberWithEditor:(IDESourceCodeEditor *)editor
{
    return [editor respondsToSelector:@selector(_currentOneBasedLineNumber)] ? editor._currentOneBasedLineNumber : editor._currentOneBasedLineNubmer;
}

@end
