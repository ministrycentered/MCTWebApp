//
//  MCTWebAppNavigationBarProtocol.h
//  MCTWebApp
//
//  Created by Skylar Schipper on 11/25/14.
//  Copyright (c) 2014 Ministry Centered Technology. All rights reserved.
//

#ifndef MCTWebApp_MCTWebAppNavigationBarProtocol_h
#define MCTWebApp_MCTWebAppNavigationBarProtocol_h

@import Foundation;

@class WKWebView;

@protocol MCTWebAppNavigationBarProtocol <NSObject>

- (instancetype)initWithFrame:(CGRect)frame webView:(WKWebView *)webView;

- (WKWebView *)webView;

- (void)setNeedsUpdatedState;

- (void)setGoBackButtonHidden:(BOOL)hidden;
- (void)setGoForwardButtonHidden:(BOOL)hidden;

@end

#endif
