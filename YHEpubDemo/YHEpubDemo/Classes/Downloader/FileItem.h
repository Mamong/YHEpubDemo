//
//  FileItem.h
//  YHEpubDemo
//
//  Created by tryao on 2023/2/26.
//  Copyright © 2023 survivorsfyh. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FileItem : NSObject

@property (nullable, nonatomic, strong) NSNumber *averageSpeed;
@property (nullable, nonatomic, strong) NSString *category;
@property (nullable, nonatomic, strong) NSDate *categoryCreatedTime;
@property (nullable, nonatomic, strong) NSString *categoryId;
@property (nullable, nonatomic, strong) NSDate *createdTime;
@property (nullable, nonatomic, strong) NSNumber *downloadedSize;
@property (nullable, nonatomic, strong) NSString *downloadURL;
@property (nullable, nonatomic, strong) NSDate *finishTime;
@property (nonatomic, assign)           NSUInteger identifier;
@property (nullable, nonatomic, strong) NSNumber *isNewDownload;
@property (nullable, nonatomic, strong) NSString *name;
@property (nullable, nonatomic, strong) NSNumber *progress;
@property (nullable, nonatomic, strong) NSData *resumeData;
@property (nullable, nonatomic, strong) NSNumber *searchPathDirectory;
@property (nullable, nonatomic, strong) NSString *sessionIdentifier;
@property (nullable, nonatomic, strong) NSNumber *sortIndex;
@property (nullable, nonatomic, strong) NSDate *startTime;
@property (nullable, nonatomic, strong) NSNumber *state;
@property (nullable, nonatomic, strong) NSString *targetPath;
@property (nullable, nonatomic, strong) NSString *taskDescription;
@property (nullable, nonatomic, strong) NSNumber *taskIdentifier;
@property (nullable, nonatomic, strong) NSNumber *totalSize;
@property (nullable, nonatomic, strong) NSDate *updatedTime;
@property (nullable, nonatomic, strong) NSString *userId;
@end

NS_ASSUME_NONNULL_END
