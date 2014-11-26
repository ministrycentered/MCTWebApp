/*!
 * MCTWebAppNativeFile.h
 * MCTWebApp
 *
 * Copyright (c) 2014 Ministry Centered Technology
 *
 * Created by Skylar Schipper on 11/25/14
 */

#ifndef MCTWebApp_MCTWebAppNativeFile_h
#define MCTWebApp_MCTWebAppNativeFile_h

@import Foundation;
@import UIKit;
@import QuickLook;

@interface MCTWebAppNativeFile : NSObject

+ (void)downloadFile:(NSURL *)fileURL completion:(void(^)(NSURL *location, NSError *error))completion;

@end

FOUNDATION_EXTERN
NSString *const MCTWebAppNativeFileErrorDomain;

typedef NS_ENUM(NSUInteger, MCTWebAppNativeFileError) {
    MCTWebAppNativeFileErrorNoFile = 0
};

#endif
