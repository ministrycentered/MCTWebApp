/*!
 * MCTWebAppViewController.m
 * MCTWebApp
 *
 * Copyright (c) 2014 Ministry Centered Technology
 *
 * Created by Skylar Schipper on 11/25/14
 */

#import "MCTWebAppViewController.h"
#import "MCTWebAppConfiguration.h"
#import "MCTWebAppEventHandler.h"
#import "MCTWebAppNativeFile.h"
#import "MCTWebAppNavigationBar.h"

@interface MCTWebAppViewController () <QLPreviewControllerDataSource, QLPreviewControllerDelegate>

@property (nonatomic, weak) NSLayoutConstraint *bottomWebConstraint;

@property (nonatomic, strong, readwrite) MCTWebAppConfiguration *configuration;

@property (nonatomic, weak, readwrite) WKWebView *webView;

@property (nonatomic, strong) NSMutableSet *eventHandlers;

@property (nonatomic, strong) NSURL *quickLookURL;

@property (nonatomic, assign, readwrite, getter=isNavigationShowing) BOOL navigationShowing;
@property (nonatomic, weak) id<MCTWebAppNavigationBarProtocol> navigationBar;

@end

@implementation MCTWebAppViewController

- (instancetype)initWithConfiguration:(MCTWebAppConfiguration *)config {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.configuration = config;
    }
    return self;
}

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self hideNavigationBarAnimated:YES completion:nil];
    
    [self addDefaultEventHandlers];
    
    [self loadRootPage];
}

- (void)addDefaultEventHandlers {
    typeof(self) __weak welf = self;
    [self addEventHandlerWithName:@"log" handler:^(WKWebView *webView, WKScriptMessage *message) {
        NSLog(@"%@ - \"%@\"",webView.URL.host,message.body);
    }];
    [self addEventHandlerWithName:@"openExternal" handler:^(WKWebView *webView, WKScriptMessage *message) {
        if (![message.body isKindOfClass:[NSDictionary class]]) {
            return;
        }
        NSDictionary *msg = message.body;
        
        NSString *URLString = msg[@"url"];
        
        BOOL didOpen = NO;
        if (URLString) {
            NSURL *URL = [NSURL URLWithString:URLString];
            if ([[UIApplication sharedApplication] canOpenURL:URL]) {
                [[UIApplication sharedApplication] openURL:URL];
                didOpen = YES;
            }
        }
        
        if (msg[@"callback"] && URLString) {
            [welf callFunctionWithName:msg[@"callback"] info:@{@"url": URLString, @"status": (didOpen) ? @"true" : @"false"} completionHandler:nil];
        }
    }];
    [self addEventHandlerWithName:@"open" handler:^(WKWebView *webView, WKScriptMessage *message) {
        if (![message.body isKindOfClass:[NSString class]]) {
            return;
        }
        NSURL *URL = [NSURL URLWithString:message.body];
        [webView loadRequest:[NSURLRequest requestWithURL:URL]];
        
        [welf showNavigationBarAnimated:YES completion:nil];
    }];
    [self addEventHandlerWithName:@"loadRoot" handler:^(WKWebView *webView, WKScriptMessage *message) {
        [welf loadRootPage];
    }];
    [self addEventHandlerWithName:@"goForward" handler:^(WKWebView *webView, WKScriptMessage *message) {
        if ([welf.webView canGoForward]) {
            [welf.webView goForward];
        }
    }];
    [self addEventHandlerWithName:@"goBack" handler:^(WKWebView *webView, WKScriptMessage *message) {
        if ([welf.webView canGoBack]) {
            [welf.webView goBack];
        }
    }];
    [self addEventHandlerWithName:@"canGoForward" handler:^(WKWebView *webView, WKScriptMessage *message) {
        if (![message.body isKindOfClass:[NSDictionary class]]) {
            return;
        }
        NSDictionary *msg = message.body;
        if (msg[@"callback"]) {
            [welf callFunctionWithName:msg[@"callback"] webView:webView info:@{@"canGoForward": ([webView canGoForward]) ? @"true": @"false"} completionHandler:nil];
        }
    }];
    [self addEventHandlerWithName:@"canGoBack" handler:^(WKWebView *webView, WKScriptMessage *message) {
        if (![message.body isKindOfClass:[NSDictionary class]]) {
            return;
        }
        NSDictionary *msg = message.body;
        if (msg[@"callback"]) {
            [welf callFunctionWithName:msg[@"callback"] webView:webView info:@{@"canGoBack": ([webView canGoBack]) ? @"true": @"false"} completionHandler:nil];
        }
    }];
    [self addEventHandlerWithName:@"endEditing" handler:^(WKWebView *webView, WKScriptMessage *message) {
        [welf.view endEditing:YES];
    }];
    [self addEventHandlerWithName:@"openFile" handler:^(WKWebView *webView, WKScriptMessage *message) {
        if (![message.body isKindOfClass:[NSDictionary class]]) {
            return;
        }
        NSDictionary *opts = message.body;
        if (!opts[@"url"]) {
            return;
        }
        NSURL *URL = [NSURL URLWithString:opts[@"url"]];
        
        [MCTWebAppNativeFile downloadFile:URL completion:^(NSURL *location, NSError *error) {
            if (error) {
                [welf handleError:error];
            }
            if (location) {
                [welf viewFileAtLocation:location];
            }
        }];
    }];
    [self addEventHandlerWithName:@"showNavigation" handler:^(WKWebView *webView, WKScriptMessage *message) {
        if (![welf isNavigationShowing]) {
            [welf showNavigationBarAnimated:YES completion:nil];
        }
    }];
    [self addEventHandlerWithName:@"hideNavigation" handler:^(WKWebView *webView, WKScriptMessage *message) {
        if ([welf isNavigationShowing]) {
            [welf hideNavigationBarAnimated:YES completion:nil];
        }
    }];
    [self addEventHandlerWithName:@"openInModal" handler:^(WKWebView *webView, WKScriptMessage *message) {
        if (![message.body isKindOfClass:[NSString class]]) {
            return;
        }
        NSURL *URL = [NSURL URLWithString:message.body];
        [welf openURLInModal:URL];
    }];
}

- (void)loadRootPage {
    NSURLRequest *request = [NSURLRequest requestWithURL:self.configuration.rootURL];
    [self.webView loadRequest:request];
}

// MARK: - Setup WebView
- (WKWebView *)webView {
    if (!_webView) {
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        
        WKUserContentController *userController = [[WKUserContentController alloc] init];
        
        config.userContentController = userController;
        
        WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
        webView.translatesAutoresizingMaskIntoConstraints = NO;
        webView.navigationDelegate = self;
        
        _webView = webView;
        [self.view addSubview:webView];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:webView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.topLayoutGuide attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:webView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:webView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0]];
        
        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:webView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.bottomLayoutGuide attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
        [self.view addConstraint:constraint];
        
        self.bottomWebConstraint = constraint;
    }
    return _webView;
}

// MARK: - Error handling
- (void)handleError:(NSError *)error {
    if (self.configuration.errorHandler) {
        self.configuration.errorHandler(self, error);
    } else {
        NSLog(@"%@ Error: %@",NSStringFromClass(self.class),error);
    }
}

// MARK: - Event Handlers
- (void)addEventHandlerWithName:(NSString *)name handler:(MCTWebAppHandler)handler {
    MCTWebAppEventHandler *_handler = [MCTWebAppEventHandler handlerWithName:name block:handler webView:self.webView];
    
    [self.webView.configuration.userContentController addScriptMessageHandler:_handler name:name];
    
    [self.eventHandlers addObject:_handler];
}

// MARK: - Run JS
- (void)evaluateJavaScript:(NSString *)js completionHandler:(void (^)(id, NSError *))completionHandler {
    [self evaluateJavaScript:js webView:self.webView completionHandler:completionHandler];
}
- (void)evaluateJavaScript:(NSString *)js webView:(WKWebView *)webView completionHandler:(void (^)(id, NSError *))completionHandler {
    typeof(self) __weak welf = self;
    [webView evaluateJavaScript:js completionHandler:^(id r, NSError *error) {
        if (error) {
            [welf handleError:error];
        }
        if (completionHandler) {
            completionHandler(r, error);
        }
    }];
}

- (void)callFunctionWithName:(NSString *)name info:(NSDictionary *)info completionHandler:(void (^)(id, NSError *))completionHandler {
    [self callFunctionWithName:name webView:self.webView info:info completionHandler:completionHandler];
}
- (void)callFunctionWithName:(NSString *)name webView:(WKWebView *)webView info:(NSDictionary *)info completionHandler:(void (^)(id, NSError *))completionHandler {
    NSString *params = @"";
    if (info) {
        NSError *JSONError = nil;
        NSData *JSON = [NSJSONSerialization dataWithJSONObject:info options:0 error:&JSONError];
        if (!JSON || JSONError) {
            if (completionHandler) {
                completionHandler(nil, JSONError);
            }
            return;
        }
        params = [[NSString alloc] initWithData:JSON encoding:NSUTF8StringEncoding];
    }
    typeof(self) __weak welf = self;
    [webView evaluateJavaScript:[NSString stringWithFormat:@"%@('%@');",name,params] completionHandler:^(id r, NSError *e) {
        if (e) {
            [welf handleError:e];
        }
        if (completionHandler) {
            completionHandler(r, e);
        }
    }];
}

// MARK: - Navigation
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    if ([webView.URL.host isEqualToString:self.configuration.rootURL.host]) {
        NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:[self.configuration appInfo]];
        if (self.configuration.userInfo) {
            [info addEntriesFromDictionary:self.configuration.userInfo];
        }
        [self callFunctionWithName:self.configuration.infoHandlerFunction webView:webView info:info completionHandler:nil];
    }
    self.title = webView.title;
    [self.navigationBar setNeedsUpdatedState];
}

// MARK: - File Viewer
- (void)viewFileAtLocation:(NSURL *)location {
    if (![QLPreviewController canPreviewItem:location]) {
        NSLog(@"QuickLook can't open file at location %@",location);
        return;
    }
    self.quickLookURL = location;
    
    QLPreviewController *controller = [[QLPreviewController alloc] initWithNibName:nil bundle:nil];
    controller.dataSource = self;
    controller.delegate = self;
    controller.view.backgroundColor = self.view.backgroundColor;
    
    if (self.navigationController) {
        [self.navigationController pushViewController:controller animated:YES];
    } else {
        [self presentViewController:controller animated:YES completion:nil];
    }
}

// MARK: - Quick Look
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
    if (self.quickLookURL) {
        return 1;
    }
    return 0;
}
- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index {
    return self.quickLookURL;
}
- (void)previewControllerDidDismiss:(QLPreviewController *)controller {
    self.quickLookURL = nil;
}

// MARK: - Navigation
+ (Class)navigationBarClass {
    return [MCTWebAppNavigationBar class];
}

- (void)prepareNavigationBarIfNeeded {
    if (!_navigationBar) {
        if (![[self.class navigationBarClass] conformsToProtocol:@protocol(MCTWebAppNavigationBarProtocol)]) {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"%@ does not conform to MCTWebAppNavigationBarProtocol",NSStringFromClass([self.class navigationBarClass])] userInfo:nil];
        }
        UIView <MCTWebAppNavigationBarProtocol>*view = [[[self.class navigationBarClass] alloc] initWithFrame:CGRectZero webView:self.webView];
        
        view.translatesAutoresizingMaskIntoConstraints = NO;
        view.backgroundColor = self.view.backgroundColor;
        
        [self.view addSubview:view];
        _navigationBar = view;
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.webView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
    }
}

- (void)showNavigationBarAnimated:(BOOL)flag completion:(void(^)(void))completion {
    self.navigationShowing = YES;
    
    [UIView performWithoutAnimation:^{
        [self prepareNavigationBarIfNeeded];
        [self.view layoutIfNeeded];
    }];
    
    UIView <MCTWebAppNavigationBarProtocol> *view = (UIView <MCTWebAppNavigationBarProtocol> *)self.navigationBar;
    
    self.bottomWebConstraint.constant = -(view.intrinsicContentSize.height);
    
    void(^ani)(void) = ^ {
        [self.view layoutIfNeeded];
    };
    
    [view setNeedsUpdatedState];
    
    if (flag) {
        [UIView animateWithDuration:0.2 animations:ani completion:^(BOOL finished) {
            if (completion) {
                completion();
            }
        }];
    } else {
        [UIView performWithoutAnimation:ani];
        if (completion) {
            completion();
        }
    }
}
- (void)hideNavigationBarAnimated:(BOOL)flag completion:(void(^)(void))completion {
    self.navigationShowing = NO;
    self.bottomWebConstraint.constant = 0.0;
    
    void(^ani)(void) = ^ {
        [self.view layoutIfNeeded];
    };
    
    if (flag) {
        [UIView animateWithDuration:0.2 animations:ani completion:^(BOOL finished) {
            if (completion) {
                completion();
            }
        }];
    } else {
        [UIView performWithoutAnimation:ani];
        if (completion) {
            completion();
        }
    }
}

// MARK: - Load In Modal
- (void)openURLInModal:(NSURL *)URL {
    typeof(self) __weak welf = self;
    
    MCTWebAppConfiguration *config = [[MCTWebAppConfiguration alloc] init];
    config.rootURL = URL;
    
    config.errorHandler = ^(MCTWebAppViewController *c, NSError *e) {
        [welf handleError:e];
    };
    
    MCTWebAppViewController *controller = [[MCTWebAppViewController alloc] initWithConfiguration:config];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:controller];
    nav.navigationBar.translucent = NO;
    nav.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    nav.modalPresentationStyle = UIModalPresentationCurrentContext;
    
    [self presentViewController:nav animated:YES completion:nil];
    
    controller.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(modalURLDoneButtonAction:)];
    [controller showNavigationBarAnimated:NO completion:nil];
}
- (void)modalURLDoneButtonAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
