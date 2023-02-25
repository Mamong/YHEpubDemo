//
//  ShareViewController.m
//  YHEpubShareExtension
//
//  Created by tryao on 2023/2/24.
//  Copyright © 2023 survivorsfyh. All rights reserved.
//

#import "ShareViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface ShareViewController ()

@end

@implementation ShareViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //[self didSelectPost];
    [self setUpData];
}

- (BOOL)isContentValid {
    // Do validation of contentText and/or NSExtensionContext attachments here
    return YES;
}

- (void)didSelectPost {
    // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
    
    // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
    [self.extensionContext completeRequestReturningItems:@[] completionHandler:^(BOOL expired) {
        [self openContainerApp];
    }];
}

- (NSArray *)configurationItems {
    // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
    return @[];
}

- (void)setUpData {
   //[self.exportDatas removeAllObjects];
   [self.extensionContext.inputItems enumerateObjectsUsingBlock:^(NSExtensionItem * _Nonnull extItem, NSUInteger idx, BOOL * _Nonnull stop) {
       [extItem.attachments enumerateObjectsUsingBlock:^(NSItemProvider * _Nonnull itemProvider, NSUInteger idx, BOOL * _Nonnull stop) {
           //[self.exportDatas addObject:itemProvider];
           if ([itemProvider hasItemConformingToTypeIdentifier:(NSString*)kUTTypePlainText]) {
               NSLog(@"text");
           }else if ([itemProvider hasItemConformingToTypeIdentifier:(NSString*)kUTTypeFileURL]){
               NSLog(@"file");
           }
           NSArray *types = itemProvider.registeredTypeIdentifiers;
           [itemProvider loadItemForTypeIdentifier:types[0] options:nil completionHandler:^(__kindof id<NSSecureCoding>  _Nullable item, NSError * _Null_unspecified error) {
               NSLog(@"");
               //把文件写到共享目录，然后调起主应用
               NSURL *groupURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@""];
               NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.AppShareDemo"];
               //[[NSFileManager defaultManager] copyItemAtPath:fromPath toPath:toPath error:&copyError];
               //[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory() inDomains:NSSearchPathDomainMask];
           }];
//           [itemProvider loadFileRepresentationForTypeIdentifier:(NSString*)kUTTypePlainText completionHandler:^(NSURL * _Nullable url, NSError * _Nullable error) {
//
//           }];
           //@"public.movie"视频//@"public.file-url"文件//@"public.url"url连接//@"public.plain-text"文字
       }];
   }];
   //[self loadItemForTypeIdentifier];
}


//关闭
- (void)cancel {
    [self.extensionContext cancelRequestWithError:[NSError errorWithDomain:@"用户取消" code:NSUserCancelledError userInfo:nil]];
}

- (void)openContainerApp {
    UIResponder* responder = self;
    while ((responder = [responder nextResponder]) != nil) {
        if ([responder respondsToSelector:@selector(openURL:)] == YES) {
            [responder performSelector:@selector(openURL:) withObject:[NSURL URLWithString:[NSString stringWithFormat:@"yhepub://share"]]];
        }
    }
}


@end
