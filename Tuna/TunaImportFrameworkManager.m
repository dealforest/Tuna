//
//  TunaImportManager.m
//  Tuna
//
//  Created by Tomohiro Kumagai on H27/05/17.
//  Copyright (c) 平成27年 Toshihiro Morimoto. All rights reserved.
//

#import "TunaImportFrameworkManager.h"
#import "DBGLLDBSession.h"

@interface TunaImportFrameworkManager ()

@property (readonly) BOOL _isImportListFileExists;
@property (readonly) NSArray* __nonnull _defaultImportFrameworks;

- (BOOL)_createImportListFile:(nonnull NSString*)path withImportFrameworks:(nonnull NSArray*)importFrameworks;

@end

@implementation TunaImportFrameworkManager
{
    NSArray* _importFrameworks;
}

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        [self load];
    }
    
    return self;
}

- (nonnull NSArray*)_defaultImportFrameworks
{
    return @[ @"UIKit", @"Foundation" ];
}

- (nullable NSString*)importListPath
{
    NSArray* libraryDirectories = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    
    if (libraryDirectories.count > 0)
    {
        return [[NSString alloc] initWithFormat:@"%@/Preferences/%@", libraryDirectories.firstObject, @"net.dealforest.Tuna.import.plist"];
    }
    else
    {
        return nil;
    }
}

- (nonnull NSString*)description
{
    NSArray* importFrameworks = self.importFrameworks;
    
    switch (importFrameworks.count)
    {
        case 0:
            return @"(none)";
            
        case 1:
            return importFrameworks.firstObject;
            
        default:
        {
            NSArray* importFrameworksWithoutLastElement = [importFrameworks subarrayWithRange:NSMakeRange(0, importFrameworks.count - 1)];
            NSString* importFrameworksWithoutLastElementDescription = [importFrameworksWithoutLastElement componentsJoinedByString:@", "];
        
            return [[NSString alloc] initWithFormat:@"%@ and %@", importFrameworksWithoutLastElementDescription, importFrameworks.lastObject];
        }
    }
}

- (BOOL)load
{
    _importFrameworks = nil;
    
    NSString* importListPath = self.importListPath;
    
    if (!importListPath)
    {
        NSLog(@"INTERNAL ERROR: Failed to get a path of import frameworks list.");
        return false;
    }

    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:importListPath isDirectory:NO])
    {
        NSArray* importFrameworks = [[NSArray alloc] initWithContentsOfFile:importListPath];
        
        if (importFrameworks)
        {
            _importFrameworks = importFrameworks;

            return YES;
        }
        else
        {
            NSLog(@"INTERNAL ERROR: Failed to load an import frameworks list '%@'.", importListPath);
            
            return NO;
        }
    }
    else
    {
        _importFrameworks = self._defaultImportFrameworks;
        
        if ([self _createImportListFile:importListPath withImportFrameworks:self.importFrameworks])
        {
            return YES;
        }
        else
        {
            NSLog(@"INTERNAL ERROR: Failed to load an import frameworks list.");

            return NO;
        }
    }
}

- (BOOL)save
{
    NSString* path = self.importListPath;
    NSArray* importFrameworks = self.importFrameworks;
    
    return [self _createImportListFile:path withImportFrameworks:importFrameworks];
}

- (BOOL)_createImportListFile:(nonnull NSString*)path withImportFrameworks:(nonnull NSArray*)importFrameworks
{
    return [importFrameworks writeToFile:path atomically:NO];
}

- (void)doImportWithSession:(nullable DBGLLDBSession*)session
{
    if (session)
    {
        for (NSString* framework in self.importFrameworks)
        {
            NSString* command = [[NSString alloc] initWithFormat:@"p @import %@\n", framework];
            [[session launcher] _executeLLDBCommands:command];
        }
    }
}

- (void)printDescriptionWithSession:(nullable DBGLLDBSession*)session
{
    if (session)
    {
        if (self.importFrameworks.count > 0)
        {
            NSString* command = [[NSString alloc] initWithFormat:@"po \"import framework %@\"\n", self.description];
            [[session launcher] _executeLLDBCommands:command];
        }
    }
}

@end
