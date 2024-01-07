//
//  EPUBDocument.m
//  YHEpubDemo
//
//  Created by tryao on 2023/3/1.
//  Copyright © 2023 survivorsfyh. All rights reserved.
//

#import "EPUBDocument.h"
#import "EPUBMetadata.h"
#import "EPUBCreator.h"
#import "EPUBManifest.h"
#import "EPUBManifestItem.h"

@implementation EPUBDocument

- (instancetype)initWithEpub:(NSURL*)url
{

}

- (instancetype)initWithDirectory:(NSURL*)directory
                 contentDirectory:(NSURL*)contentDirectory
                         metadata:(EPUBMetadata*)metadata
                         manifest:(EPUBManifest*)manifest
                            spine:(EPUBSpine*)spine
                  tableOfContents:(EPUBTableOfContents*)tableOfContents
{
    if(self = [super init]){
        _directory = directory;
        _contentDirectory = contentDirectory;
        _metadata = metadata;
        _manifest = manifest;
        _spine = spine;
        _tableOfContents = tableOfContents;
    }
    return self;
}

- (NSString*)title
{
    return self.metadata.title;
}

- (NSString*)author
{
    return self.metadata.creator.name;
}

- (NSString*)publisher
{
    return self.metadata.publisher;
}

- (NSURL*)cover
{
    NSString *coverId = self.metadata.coverId;
    NSString *path = self.manifest.items[coverId].path;
    if(!path){
        return nil;
    }
    return [self.contentDirectory URLByAppendingPathComponent:path];
}

@end
