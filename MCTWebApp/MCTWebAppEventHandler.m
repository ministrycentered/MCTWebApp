/*!
 * MCTWebAppEventHandler.m
 * MCTWebApp
 *
 * Copyright (c) 2014 Ministry Centered Technology
 *
 * Created by Skylar Schipper on 11/25/14
 */

#import "MCTWebAppEventHandler.h"

@interface MCTWebAppEventHandler ()

@property (nonatomic, strong) NSString *name;
@property (nonatomic, copy) MCTWebAppHandler handler;
@property (nonatomic, weak) WKWebView *webView;

@end

@implementation MCTWebAppEventHandler

+ (instancetype)handlerWithName:(NSString *)name block:(MCTWebAppHandler)block webView:(WKWebView *)webView {
    MCTWebAppEventHandler *h = [[self alloc] init];
    h.name = name;
    h.handler = [block copy];
    h.webView = webView;
    return h;
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    self.handler(self.webView, message);
}

@end
