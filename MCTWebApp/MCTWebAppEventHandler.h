/*!
 * MCTWebAppEventHandler.h
 * MCTWebApp
 *
 * Copyright (c) 2014 Ministry Centered Technology
 *
 * Created by Skylar Schipper on 11/25/14
 */

#ifndef MCTWebApp_MCTWebAppEventHandler_h
#define MCTWebApp_MCTWebAppEventHandler_h

@import Foundation;
@import WebKit;

#import "MCTWebAppViewController.h"

@interface MCTWebAppEventHandler : NSObject <WKScriptMessageHandler>

+ (instancetype)handlerWithName:(NSString *)name block:(MCTWebAppHandler)block webView:(WKWebView *)webView;

@end

#endif
