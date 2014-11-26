/*!
 * MCTWebAppViewController.h
 * MCTWebApp
 *
 * Copyright (c) 2014 Ministry Centered Technology
 *
 * Created by Skylar Schipper on 11/25/14
 */

#ifndef MCTWebApp_MCTWebAppViewController_h
#define MCTWebApp_MCTWebAppViewController_h

@import UIKit;
@import WebKit;

@class MCTWebAppConfiguration;

typedef void (^MCTWebAppHandler)(WKWebView *, WKScriptMessage *);

@interface MCTWebAppViewController : UIViewController <WKNavigationDelegate>

/**
 *  Create a new view controller with the configuration
 *
 *  @param config The configuration for the web view controller
 *
 *  @return A new view controller
 */
- (instancetype)initWithConfiguration:(MCTWebAppConfiguration *)config NS_DESIGNATED_INITIALIZER;

/**
 *  The configuration
 */
@property (nonatomic, strong, readonly) MCTWebAppConfiguration *configuration;

/**
 *  The webview
 */
@property (nonatomic, weak, readonly) WKWebView *webView;

/**
 *  Loads the web root page specified by the configuration
 */
- (void)loadRootPage;

/**
 *  Add an event handler and make it available in the javascript page
 *
 *  @param name    The name of the event handler. Exposed as `window.webkit.messageHandlers.OBSERVER_NAME.postMessage(obj)`
 *  @param handler The block to call when a message is received.
 */
- (void)addEventHandlerWithName:(NSString *)name handler:(MCTWebAppHandler)handler;

/**
 *  Evaluates the passed JavaScript on the web ivew
 *
 *  @param js                The JavaScript to handle
 *  @param completionHandler The block to call when the JavaScript finishes executing.
 *
 *  The block will be passed the results and an error if one occured.
 *
 *  The configuration's error handler will be called before the completion handler if an error occurred.
 */
- (void)evaluateJavaScript:(NSString *)js completionHandler:(void (^)(id, NSError *))completionHandler;

/**
 *  Call the function on the web view.
 *
 *  @param name              The name of the function to call.
 *  @param info              The object to encode as JSON and pass to the function
 *  @param completionHandler The block to call when the JavaScript finishes executing.
 *
 *  The block will be passed the results and an error if one occured.
 *
 *  The configuration's error handler will be called before the completion handler if an error occurred.
 */
- (void)callFunctionWithName:(NSString *)name info:(NSDictionary *)info completionHandler:(void (^)(id, NSError *))completionHandler;

// MARK: - Navigation

/**
 *  Class to use for the navigation bar.  Must conform to MCTWebAppNavigationBarProtocol
 */
+ (Class)navigationBarClass;

/**
 *  Is the navigation bar showing
 */
@property (nonatomic, assign, readonly, getter=isNavigationShowing) BOOL navigationShowing;

/**
 *  Show the navigation bar
 *
 *  @param flag       Animate showing the navigation bar
 *  @param completion Called when bar is showing
 */
- (void)showNavigationBarAnimated:(BOOL)flag completion:(void(^)(void))completion;

/**
 *  Hide the navigation bar
 *
 *  @param flag       Animate hiding the navigation bar
 *  @param completion Called when the bar is hidden
 */
- (void)hideNavigationBarAnimated:(BOOL)flag completion:(void(^)(void))completion;

@end

@interface MCTWebAppViewController (SubclassingHooks)

- (void)addDefaultEventHandlers NS_REQUIRES_SUPER;

@end

#endif
