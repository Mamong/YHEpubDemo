//
//  EPUBSpine.h
//  YHEpubDemo
//
//  Created by tryao on 2023/3/1.
//  Copyright © 2023 survivorsfyh. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSString* EPUBPageProgressionDirection NS_STRING_ENUM;

FOUNDATION_EXPORT EPUBPageProgressionDirection const EPUBPageProgressionDirectionLTR;

FOUNDATION_EXPORT EPUBPageProgressionDirection const EPUBPageProgressionDirectionRTL;

@class EPUBSpineItem;

@interface EPUBSpine : NSObject

@property(nonatomic, strong) NSString *id;
@property(nonatomic, strong) NSString *toc;
@property(nonatomic, strong) EPUBPageProgressionDirection pageProgressionDirection;
@property(nonatomic, strong) NSArray<EPUBSpineItem*> *items;

@end

NS_ASSUME_NONNULL_END
