//
//  EPUBTableOfContents.h
//  YHEpubDemo
//
//  Created by tryao on 2023/3/1.
//  Copyright © 2023 survivorsfyh. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EPUBTableOfContents : NSObject

@property(nonatomic, strong) NSString *label;
@property(nonatomic, strong) NSString *id;
@property(nonatomic, strong) NSString *item;
@property(nonatomic, strong) NSArray<EPUBTableOfContents*> *subTable;

@end

NS_ASSUME_NONNULL_END
