//
//  iCloudDocument.m
//  YHEpubDemo
//
//  Created by tryao on 2023/2/28.
//  Copyright © 2023 survivorsfyh. All rights reserved.
//

#import "iCloudDocument.h"

@implementation iCloudDocument

- (BOOL)loadFromContents:(id)contents ofType:(NSString *)typeName error:(NSError * _Nullable __autoreleasing *)outError
{
    self.data = [contents copy];

    return YES;
}

- (nullable id)contentsForType:(NSString *)typeName error:(NSError * _Nullable __autoreleasing *)outError
{
    if(!self.data)
    {
        self.data = [[NSData alloc] init];
    }

    return self.data;
}

@end
