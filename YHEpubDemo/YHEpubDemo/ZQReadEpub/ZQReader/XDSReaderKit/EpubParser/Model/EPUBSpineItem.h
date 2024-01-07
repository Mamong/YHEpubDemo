//
//  EPUBSpineItem.h
//  YHEpubDemo
//
//  Created by tryao on 2023/3/1.
//  Copyright © 2023 survivorsfyh. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EPUBSpineItem : NSObject

@property(nonatomic, strong) NSString *id;
@property(nonatomic, strong) NSString *idref;
@property(nonatomic, assign) BOOL linear;

@end

NS_ASSUME_NONNULL_END
