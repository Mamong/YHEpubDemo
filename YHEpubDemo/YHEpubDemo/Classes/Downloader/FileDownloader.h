//
//  FileDownloader.h
//  YHEpubDemo
//
//  Created by tryao on 2023/2/26.
//  Copyright © 2023 survivorsfyh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface FileDownloader : NSObject

+(instancetype)shared;

- (void)downloadFile:(FileItem*)file;

- (void)setCookie:(NSArray*)cookies forUrl:(NSURL*)url;
@end

NS_ASSUME_NONNULL_END
