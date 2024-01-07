//
//  EPUBGuide.h
//  YHEpubDemo
//
//  Created by tryao on 2023/3/1.
//  Copyright © 2023 survivorsfyh. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EPUBReference : NSObject
@property(nonatomic, strong) NSString *type;
@property(nonatomic, strong) NSString *href;
@property(nonatomic, strong) NSString *title;
@end


NS_ASSUME_NONNULL_END
