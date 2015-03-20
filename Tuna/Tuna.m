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

@interface Tuna()

@property (nonatomic, strong, readwrite) NSBundle *bundle;

/// Install Tuna menu item in Xcode.
- (void)installMenuItem:(NSMenuItem*)menu;

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
    NSString *pluginName = [bundle objectForInfoDictionaryKey:@"CFBundleName"];
    NSMenuItem *pluginMenuItem = [[NSMenuItem alloc] initWithTitle:pluginName
                                                            action:nil
                                                     keyEquivalent:@""];
    
    NSMenu *pluginMenu = [[NSMenu alloc] initWithTitle:pluginName];
    [pluginMenu addItem:({
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"Set Print Breakpoint"
                                                      action:@selector(setPrintBreakpoint)
                                               keyEquivalent:@""];
        item.target = self;
        item;
    })];
    [pluginMenu addItem:({
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"Set Backtrace Breakpoint"
                                                      action:@selector(setBacktraceBreakpoint)
                                               keyEquivalent:@""];
        item.target = self;
        item;
    })];
    
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

- (void)setPrintBreakpoint
{
    NSTextView *textView = [self currentSourceCodeTextView];
    NSString *selectedText = [[textView.string substringWithRange:textView.selectedRange]
                              stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (selectedText.length == 0) {
        return;
    }
    
    long long lineNumber = [self currentSourceCodeEditor]._currentOneBasedLineNubmer + 1;
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
}

- (void)setBacktraceBreakpoint
{
    long long lineNumber = [self currentSourceCodeEditor]._currentOneBasedLineNubmer;
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

- (IDESourceCodeEditor *)currentSourceCodeEditor
{
    IDEEditor *editor = [self currentEditor];
    if ([editor isKindOfClass:NSClassFromString(@"IDESourceCodeEditor")]) {
        return (IDESourceCodeEditor *)editor;
    }
    else {
        return nil;
    }
}


- (NSTextView *)currentSourceCodeTextView
{
    IDEEditor *editor = [self currentEditor];
    if ([editor isKindOfClass:NSClassFromString(@"IDESourceCodeEditor")]) {
        return (NSTextView *)editor.textView;
    }
    else if ([editor isKindOfClass:NSClassFromString(@"IDESourceCodeComparisonEditor")]) {
        return (NSTextView *)((IDESourceCodeComparisonEditor *)editor).keyTextView;
    }
    else {
        return nil;
    }
}

@end
