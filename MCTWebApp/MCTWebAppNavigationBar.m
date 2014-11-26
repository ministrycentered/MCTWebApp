/*!
 * MCTWebAppNavigationBar.m
 * MCTWebApp
 *
 * Copyright (c) 2014 Ministry Centered Technology
 *
 * Created by Skylar Schipper on 11/25/14
 */

#import "MCTWebAppNavigationBar.h"
#import "MCTWebAppNavigationBarProtocol.h"

@interface MCTWebAppNavigationBar ()

@property (nonatomic, weak, readwrite) WKWebView *webView;

@property (nonatomic, weak) UIButton *backButton;
@property (nonatomic, weak) UIButton *forwardButton;

@end

@implementation MCTWebAppNavigationBar

- (instancetype)initWithFrame:(CGRect)frame webView:(WKWebView *)webView {
    self = [super initWithFrame:frame];
    if (self) {
        self.webView = webView;
        
        self.layoutMargins = UIEdgeInsetsMake(0.0, 16.0, 0.0, 16.0);
        
        [self setNeedsUpdatedState];
        
        UIView *top = [[UIView alloc] initWithFrame:CGRectZero];
        top.backgroundColor = [UIColor colorWithWhite:0.89 alpha:1.0];
        top.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self addSubview:top];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[top(==1)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(top)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[top]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(top)]];
    }
    return self;
}

- (void)setNeedsUpdatedState {
    [self updateState];
}
- (void)updateState {
    [self setGoBackButtonHidden:![self.webView canGoBack]];
    [self setGoForwardButtonHidden:![self.webView canGoForward]];
    [self setNeedsLayout];
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(UIViewNoIntrinsicMetric, 50.0);
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    
    [self.backButton setTitleColor:self.tintColor forState:UIControlStateNormal];
    [self.forwardButton setTitleColor:self.tintColor forState:UIControlStateNormal];
}

// MARK: - Buttons
- (UIButton *)backButton {
    if (!_backButton) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectZero];
        button.translatesAutoresizingMaskIntoConstraints = NO;
        [button setTitleColor:self.tintColor forState:UIControlStateNormal];
        [button setTitle:NSLocalizedString(@"back", nil) forState:UIControlStateNormal];
        
        [button addTarget:self.webView action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
        
        _backButton = button;
        [self addSubview:button];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:self.layoutMargins.left]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    }
    return _backButton;
}
- (UIButton *)forwardButton {
    if (!_forwardButton) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectZero];
        button.translatesAutoresizingMaskIntoConstraints = NO;
        [button setTitleColor:self.tintColor forState:UIControlStateNormal];
        [button setTitle:NSLocalizedString(@"forward", nil) forState:UIControlStateNormal];
        
        [button addTarget:self.webView action:@selector(goForward) forControlEvents:UIControlEventTouchUpInside];
        
        _forwardButton = button;
        [self addSubview:button];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:-self.layoutMargins.right]];
    }
    return _forwardButton;
}

// MARK: - MCTWebAppNavigationBarProtocol
- (void)setGoForwardButtonHidden:(BOOL)hidden {
    self.forwardButton.hidden = hidden;
}
- (void)setGoBackButtonHidden:(BOOL)hidden {
    self.backButton.hidden = hidden;
}

@end
