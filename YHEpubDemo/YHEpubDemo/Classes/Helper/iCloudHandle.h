//
//  iCloudHandle.h
//  YHEpubDemo
//
//  Created by tryao on 2023/2/28.
//  Copyright © 2023 survivorsfyh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CloudKit/CloudKit.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface iCloudHandle : NSObject

#pragma mark - key-value storage

+ (void)setUpKeyValueICloudStoreWithKey:(NSString *)key value:(NSString *)value;
+ (NSString *)getKeyValueICloudStoreWithKey:(NSString *)key;

#pragma mark - iCloud Document

//获取地址
+ (NSURL *)getUbiquityContauneURLWithFileName:(NSString *)fileName;
//创建文档
+ (void)createDocumentWithFileName:(NSString *)fileName content:(NSString *)content;
//修改文档 实际上是overwrite重写
+ (void)overwriteDocumentWithFileName:(NSString *)fileName content:(NSString *)content;
//删除文档
+ (void)removeDocumentWithFileName:(NSString *)fileName;
//获取最新的数据
+ (void)getNewDocument:(NSMetadataQuery *)myMetadataQuery;


#pragma mark - Cloud Kit

//保存数据
+ (void)saveCloudKitModelWithTitle:(NSString *)title content:(NSString *)content photoImage:(UIImage *)image;
//查询数据
+ (void)queryCloudKitData;
//删除数据
+ (void)removeCloudKitDataWithRecordID:(CKRecordID *)recordID;
//查询单条数据
+ (void)querySingleRecordWithRecordID:(CKRecordID *)recordID;
//修改数据
+ (void)changeCloudKitWithTitle:(NSString *)title content:(NSString *)content photoImage:(UIImage *)image RecordID:(CKRecordID *)recordID;

@end

NS_ASSUME_NONNULL_END
