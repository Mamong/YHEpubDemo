//
//  EPUBArchiveService.m
//  YHEpubDemo
//
//  Created by tryao on 2023/3/1.
//  Copyright © 2023 survivorsfyh. All rights reserved.
//

#import "EPUBArchiveService.h"
#import <SSZipArchive.h>

@implementation EPUBArchiveService

- (NSURL*)unarchive:(NSURL*)archive
{
    NSString *path = archive.path;
    NSString *zipFile_relativePath = [[path stringByDeletingPathExtension] lastPathComponent];
    zipFile_relativePath = [EPUB_EXTRACTION_FOLDER stringByAppendingString:zipFile_relativePath];
    zipFile_relativePath = [@"/" stringByAppendingString:zipFile_relativePath];
    /** 文件解压后存储路径*/
    NSString *destinationPath = [APP_SANDBOX_DOCUMENT_PATH stringByAppendingString:zipFile_relativePath];

    NSError *error;
    if ([SSZipArchive unzipFileAtPath:path toDestination:destinationPath overwrite:YES password:nil error:&error]) {
        NSLog(@"Zip EPub file success(%@): %@", path.lastPathComponent, destinationPath);
        return [NSURL fileURLWithPath:zipFile_relativePath];
    }
    else {
        NSLog(@"Zip EPub file error: %@", error);
        return  nil;
    }
}

@end
