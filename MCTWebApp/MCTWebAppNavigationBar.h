/*!
 * MCTWebAppNavigationBar.h
 * MCTWebApp
 *
 * Copyright (c) 2014 Ministry Centered Technology
 *
 * Created by Skylar Schipper on 11/25/14
 */

#ifndef MCTWebApp_MCTWebAppNavigationBar_h
#define MCTWebApp_MCTWebAppNavigationBar_h

@import UIKit;
@import WebKit;

#import "MCTWebAppNavigationBarProtocol.h"

@interface MCTWebAppNavigationBar : UIView <MCTWebAppNavigationBarProtocol>

@property (nonatomic, weak, readonly) WKWebView *webView;

@end

#endif
