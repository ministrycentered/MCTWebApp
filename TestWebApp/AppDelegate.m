//
//  AppDelegate.m
//  TestWebApp
//
//  Created by Skylar Schipper on 11/25/14.
//  Copyright (c) 2014 Ministry Centered Technology. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    MCTWebAppConfiguration *config = [[MCTWebAppConfiguration alloc] init];
    config.rootURL = [NSURL URLWithString:@"http://mct-test-app.skylarsch.com"];
    
    self.window.rootViewController = [[MCTWebAppViewController alloc] initWithConfiguration:config];
    
    [((MCTWebAppViewController *)self.window.rootViewController) addEventHandlerWithName:@"objHandler" handler:^(WKWebView *webView, WKScriptMessage *message) {
        NSLog(@"JSObj: %@",message.body);
    }];
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
