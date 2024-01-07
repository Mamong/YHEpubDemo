//
//  EPUBManifest.h
//  YHEpubDemo
//
//  Created by tryao on 2023/3/1.
//  Copyright © 2023 survivorsfyh. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class EPUBManifestItem;

@interface EPUBManifest : NSObject

@property(nonatomic, strong) NSString *id;
@property(nonatomic, strong) NSDictionary<NSString*,EPUBManifestItem*> *items;

@end

NS_ASSUME_NONNULL_END
