//
//  EPUBArchiveService.h
//  YHEpubDemo
//
//  Created by tryao on 2023/3/1.
//  Copyright © 2023 survivorsfyh. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EPUBArchiveService : NSObject

- (NSURL*)unarchive:(NSURL*)archive;

@end

NS_ASSUME_NONNULL_END
