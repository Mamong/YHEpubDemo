//
//  WKWebViewControllerEx.h
//  YHEpubDemo
//
//  Created by tryao on 2023/2/26.
//  Copyright © 2023 survivorsfyh. All rights reserved.
//

#import "WKWebViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface WKWebViewControllerEx : WKWebViewController

/**
 * Show or hide progressBar, Default is YES.
 */
@property (nonatomic, assign) BOOL showProgress;
/**
 * ProgressBar Color
 */
@property (nonnull, nonatomic, strong) UIColor* progressColor;

/**
 * Show or hide backForward bar, Default is YES.
 */
@property (nonatomic, assign) BOOL showBackForwardBar;
/**
 * Back forwardbar tintColor
 */
@property (nonnull, nonatomic, strong) UIColor* backForwardBarTintColor;
/**
 * Back forward item space
 */
@property (nonatomic, assign) CGFloat backForwardBarSpace;

/**
 * A title display on navigation bar, if not special, get "document.title" instead.
 */
@property (nullable, nonatomic, copy) NSString* documentTitle;

/**
 * mimeTypes allowed to download
 */
@property (nonnull, nonatomic, strong) NSArray<NSString*>* mimeTypes;

/**
 * Load html from bundle
 */
- (void)loadResourceHtml:(NSString*)name;

/**
 * Clear webview cache
 */
+ (void)clearCache;

- (BOOL)shouldDownloadFile:(NSURL*)url name:(NSURL*)name;
@end

NS_ASSUME_NONNULL_END
