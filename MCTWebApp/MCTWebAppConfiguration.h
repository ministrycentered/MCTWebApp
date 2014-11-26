/*!
 * MCTWebAppConfiguration.h
 * MCTWebApp
 *
 * Copyright (c) 2014 Ministry Centered Technology
 *
 * Created by Skylar Schipper on 11/25/14
 */

#ifndef MCTWebApp_MCTWebAppConfiguration_h
#define MCTWebApp_MCTWebAppConfiguration_h

@import Foundation;
@import UIKit;

@class MCTWebAppViewController;

@interface MCTWebAppConfiguration : NSObject

/**
 *  The root URL for the web view
 */
@property (nonatomic, strong) NSURL *rootURL;

/**
 *  Added as custom data passed to the root URL info handler on load
 */
@property (nonatomic, strong) NSDictionary *userInfo;

/**
 *  Called if error are raised internally.
 */
@property (nonatomic, copy) void (^errorHandler)(MCTWebAppViewController *viewController, NSError *error);

/**
 *  Info Handler Function name
 */
@property (nonatomic, strong) NSString *infoHandlerFunction;

- (NSDictionary *)appInfo;

@end

#define MCTWebAppVersion_1_0_0 100000

FOUNDATION_EXTERN
NSUInteger const MCTWebAppVersion;

#endif
