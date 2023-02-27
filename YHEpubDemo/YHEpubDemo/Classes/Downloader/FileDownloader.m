//
//  FileDownloader.m
//  YHEpubDemo
//
//  Created by tryao on 2023/2/26.
//  Copyright © 2023 survivorsfyh. All rights reserved.
//

#import "FileDownloader.h"

@interface FileDownloader ()<NSURLSessionDownloadDelegate>
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;
@property (nonatomic, strong) NSData *resumData;
@property (nonatomic, strong) NSMutableArray *downloadItems;

@end

@implementation FileDownloader

+(instancetype)shared
{
    static FileDownloader *instance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        instance = [[FileDownloader alloc] init];
        instance.downloadItems = [NSMutableArray array];
    });
    return instance;
}

- (IBAction)pause {
    [self.downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        // 记录已下载的数据
        self.resumData = resumeData;
        // 把续传数据保存到沙盒中
        NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"123.tmp"];
        [self.resumData writeToFile:path atomically:YES];
        NSLog(@"%@", path);
        // 将下载任务置为空
        self.downloadTask = nil;
    }];
}

// 继续下载
- (IBAction)resume {
    // 从沙盒中获取续传数据
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"123.tmp"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        self.resumData = [NSData dataWithContentsOfFile:path];
    }

    if (self.resumData == nil) {
        return;
    }

    // 调用断点下载方法
    self.downloadTask = [self.session downloadTaskWithResumeData:self.resumData];
    [self.downloadTask resume];
    // 将续传数据置为空
    self.resumData = nil;
}


// 懒加载
- (NSURLSession *)session {
    if (_session == nil) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    }
    return _session;
}

// 下载，设置代理，获取进度
- (void)downloadFile:(FileItem*)file{
//    NSString *cookie = [FileDownloader readCurrentCookie:request.URL];
//    if (cookie) {
//        [request setValue:cookie forHTTPHeaderField:@"Cookie"];
//    }
    self.downloadTask = [self.session downloadTaskWithURL:[NSURL URLWithString:file.downloadURL]];
    file.identifier = self.downloadTask.taskIdentifier;
    [self.downloadItems addObject:file];
    // 开始下载
    [self.downloadTask resume];
}

- (void)setCookie:(NSArray*)cookies forUrl:(NSURL*)url
{
    [self.session.configuration.HTTPCookieStorage setCookies:cookies forURL:url mainDocumentURL:nil];
}

+(NSString *)readCurrentCookie:(NSURL*)url{
    if(!url) return @"";
    NSHTTPCookieStorage*cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSMutableString *cookieString = [[NSMutableString alloc] init];
    NSArray *cookies = [cookieJar cookiesForURL:url];

    for (NSHTTPCookie*cookie in cookies) {
        [cookieString appendFormat:@"%@=%@;",cookie.name,cookie.value];
    }
    //删除最后一个“；”
    if(cookieString.length>0)
        [cookieString deleteCharactersInRange:NSMakeRange(cookieString.length - 1, 1)];
    return cookieString;
}

#pragma mark - NSURLSessionDownloadDelegate
// 写数据
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    float process = totalBytesWritten * 1.0 / totalBytesExpectedToWrite;
    NSLog(@"%f,%lld", process,totalBytesExpectedToWrite);
}

// 断点下载数据
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
    NSLog(@"续传");
}

// 下载完成
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    NSLog(@"%@", [NSThread currentThread]);
    NSLog(@"下载完成 %@", location);

    FileItem *file = nil;
    for (FileItem *item in self.downloadItems) {
        if(item.identifier == downloadTask.taskIdentifier){
            file = item;
        }
    }

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    NSString *destination = [documentsDir stringByAppendingFormat:@"/downloads/%@",[file.name stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]]];

    NSURL *destURL = [NSURL fileURLWithPath:destination];

    NSError *error = nil;
    BOOL success = [[NSFileManager defaultManager] moveItemAtURL:location toURL:destURL error:&error];
    NSLog(@"");
}

@end
