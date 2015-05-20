//
//  TunaImportManager.h
//  Tuna
//
//  Created by Tomohiro Kumagai on H27/05/17.
//  Copyright (c) 平成27年 Toshihiro Morimoto. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBGLLDBSession.h"
#import "DBGLLDBLauncher.h"

/*!
 This object supports to import frameworks to LLDB when debugging.

 Read from ~/Library/Preferences/com.dealforest.Tuna.import.plist.
 If the file is not exists, create a import.plist file by default.
 */
@interface TunaImportFrameworkManager : NSObject

/// Initialize with Default Import framework list.
- (nonnull instancetype)init;

/// Get path of import.plist. If failed to get import.plist, returns nil.
- (nullable NSString*)importListPath;

/// Get import framework list
@property (readonly, strong) NSArray* __nonnull importFrameworks;

/// Save import framework list.
- (BOOL)save;

/// Load import framework list.
- (BOOL)load;

/// Import Frameworks to LLDB.
- (void)doImportWithSession:(nullable DBGLLDBSession*)session;

/// Print description to LLDB.
- (void)printDescriptionWithSession:(nullable DBGLLDBSession*)session;

@end
