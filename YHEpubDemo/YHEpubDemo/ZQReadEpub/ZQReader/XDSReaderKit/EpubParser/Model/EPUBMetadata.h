//
//  EPUBMetadata.h
//  YHEpubDemo
//
//  Created by tryao on 2023/3/1.
//  Copyright © 2023 survivorsfyh. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class EPUBCreator;

@interface EPUBMetadata : NSObject

@property(nonatomic, strong) EPUBCreator *contributor;
@property(nonatomic, strong) NSString *coverage;
@property(nonatomic, strong) EPUBCreator *creator;
@property(nonatomic, strong) NSString *date;
@property(nonatomic, strong) NSString *description_;
@property(nonatomic, strong) NSString *format;
@property(nonatomic, strong) NSString *identifier;
@property(nonatomic, strong) NSString *language;
@property(nonatomic, strong) NSString *publisher;
@property(nonatomic, strong) NSString *relation;
@property(nonatomic, strong) NSString *rights;
@property(nonatomic, strong) NSString *source;
@property(nonatomic, strong) NSString *subject;
@property(nonatomic, strong) NSString *title;
@property(nonatomic, strong) NSString *type;
@property(nonatomic, strong) NSString *coverId;

//选中的样式类名，例如朗读时的选中
//@property(nonatomic, strong) NSString *activeClass;

@end

NS_ASSUME_NONNULL_END
