//
//  WKWebViewController.h
//  YHEpubDemo
//
//  Created by tryao on 2023/2/26.
//  Copyright © 2023 survivorsfyh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Extend function name key, more infomation see getExtendJSFunction.
 */
FOUNDATION_EXPORT NSString* const WKExtendJSFunctionNameKey;

/**
 * A view controller that specializes in managing a WKWebView.
 */
@interface WKWebViewController : UIViewController <WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler>

/**
 * Returns the WKWebView managed by the controller object.
 */
@property (nonatomic, strong, readonly) WKWebView* wkWebView;

/**
 * The name of the message handler.
 * @discussion Function window.<messageName>.functionName(arg) for all frame.
 */
@property (nonnull, nonatomic, copy) NSString* messageName;

/**
 * The url string for the new WKWebviewController.
 */
@property (nonnull, nonatomic, copy) NSString* url;

/**
 * The cache policy for the request.
 */
@property (nonatomic, assign) NSURLRequestCachePolicy cachePolicy;

/**
 * The timeout interval for the request.
 */
@property (nonatomic, assign) NSTimeInterval timeoutInterval;

/**
 * Returns a WKWebViewController initialized with a specified url.
 */
- (instancetype)initWithUrl:(NSString*)url;

/**
 * Navigates to a  specified url.
 */
- (void)loadURL:(NSURL*)url;

/**
 * Navigates to a requested URL.
 */
- (void)loadRequest:(NSURLRequest *)request;

/**
 * Sets the webpage contents and base URL.
 */
- (void)loadHTMLString:(NSString *)string baseURL:(nullable NSURL *)baseURL;

/**
 * Reloads the current page.
 */
- (void)reload;

/**
 * Returns custom cookie property array
 */
- (nullable NSArray<NSHTTPCookie*>*)getCookiesProperty;

/**
 * Returns function config for messageHandler

 @code
  return @[@{WKExtendJSFunctionNameKey: @"functionA"},
           @{WKExtendJSFunctionNameKey: @"functionB"},
           @{WKExtendJSFunctionNameKey: @"functionC"}];

 @endcode

    Javascript call:
    window.<messageName>.functionA(arg1, arg2);
    window.<messageName>.functionB();
    window.<messageName>.functionC(arg1, arg2, function() {} );

    Native Function:
    - (void)functionA:(id)argument;
    - (void)functionB;
    - (id)functionC:(id)argument;
 */
- (nullable NSArray<NSDictionary*>*)getExtendJSFunction;

/**
 * Returns custom config for window.<messageName>.configs['key'].
 */
- (nullable NSDictionary<NSString*, id>*)getCustomConfigProperty;

/**
 * Invoke Javascript function with some arguments.
 @code
 invokeJSFunction(@"functionName", @[@"str", @{"key":value}, @[@"item"], @(1)], completionHandler:completionHandler);
 @endcode
 */
- (void)invokeJSFunction:(NSString*)functionName
                    args:(NSArray*)args
       completionHandler:(void(^)(id _Nullable response, NSError * _Nullable error))completionHandler;

@end

NS_ASSUME_NONNULL_END
