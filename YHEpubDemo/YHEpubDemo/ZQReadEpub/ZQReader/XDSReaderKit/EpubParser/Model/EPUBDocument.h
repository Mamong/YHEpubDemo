//
//  EPUBDocument.h
//  YHEpubDemo
//
//  Created by tryao on 2023/3/1.
//  Copyright © 2023 survivorsfyh. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class EPUBMetadata, EPUBManifest, EPUBSpine, EPUBTableOfContents, EPUBGuide;

@interface EPUBDocument : NSObject

@property(nonatomic, strong, readonly) NSURL *directory;
@property(nonatomic, strong, readonly) NSURL *contentDirectory;
@property(nonatomic, strong, readonly) EPUBMetadata *metadata;
@property(nonatomic, strong, readonly) EPUBManifest *manifest;
@property(nonatomic, strong, readonly) EPUBSpine *spine;
@property(nonatomic, strong, readonly) NSArray<EPUBGuide*> *guides;
@property(nonatomic, strong, readonly) EPUBTableOfContents *tableOfContents;

@property(nonatomic, strong, readonly) NSString *title;
@property(nonatomic, strong, readonly) NSString *author;
@property(nonatomic, strong, readonly) NSString *publisher;
@property(nonatomic, strong, readonly) NSURL *cover;

- (instancetype)initWithEpub:(NSURL*)url;

- (instancetype)initWithDirectory:(NSURL*)directory
                 contentDirectory:(NSURL*)contentDirectory
                         metadata:(EPUBMetadata*)metadata
                         manifest:(EPUBManifest*)manifest
                            spine:(EPUBSpine*)spine
                  tableOfContents:(EPUBTableOfContents*)tableOfContents;
@end

NS_ASSUME_NONNULL_END
