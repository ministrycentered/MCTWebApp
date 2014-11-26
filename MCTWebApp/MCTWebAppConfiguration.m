/*!
 * MCTWebAppConfiguration.m
 * MCTWebApp
 *
 * Copyright (c) 2014 Ministry Centered Technology
 *
 * Created by Skylar Schipper on 11/25/14
 */

#import "MCTWebAppConfiguration.h"

@interface MCTWebAppConfiguration ()

@end

@implementation MCTWebAppConfiguration

- (NSDictionary *)appInfo {
    return @{
             @"identifier": [[NSBundle mainBundle] bundleIdentifier],
             @"system": @{
                     @"version": [[UIDevice currentDevice] systemVersion],
                     @"name": [[UIDevice currentDevice] systemName],
                     @"app": @(MCTWebAppVersion)
                     },
             @"version": @{
                     @"major": ([[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"]) ?: @"",
                     @"build": ([[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"]) ?: @"",
                     }
             };
}

- (NSString *)infoHandlerFunction {
    if (!_infoHandlerFunction) {
        return @"MCTWebAppUserInfoHandler";
    }
    return _infoHandlerFunction;
}

@end

NSUInteger const MCTWebAppVersion = MCTWebAppVersion_1_0_0;
