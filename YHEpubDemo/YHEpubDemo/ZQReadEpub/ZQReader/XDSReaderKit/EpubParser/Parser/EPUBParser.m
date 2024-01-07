//
//  EPUBParser.m
//  YHEpubDemo
//
//  Created by tryao on 2023/3/1.
//  Copyright © 2023 survivorsfyh. All rights reserved.
//

#import "EPUBParser.h"
#import "EPUBDocument.h"

@interface EPUBParser ()



@end


@implementation EPUBParser

- (instancetype)init
{
    if(self = [super init]){

    }
}

- (EPUBDocument*)parseDocument:(NSURL*)path
{
    if([self.delegate respondsToSelector:@selector(parser:didBeginParsingDocumentAt:)]){
        [self.delegate parser:self didBeginParsingDocumentAt:path];
    }
    NSURL *directory = path;
    BOOL isDirectory = NO;
    NSError *error = nil;
    [[NSFileManager defaultManager] fileExistsAtPath:path.path isDirectory:&isDirectory];
    if(!isDirectory){
        directory = [self unzipArchiveAt:path error:&error];
    }

    if([self.delegate respondsToSelector:@selector(parser:didUnzipArchiveTo:)]){
        [self.delegate parser:self didUnzipArchiveTo:directory];
    }


    if([self.delegate respondsToSelector:@selector(parser:didFinishParsingDocumentAt:)]){
        [self.delegate parser:self didFinishParsingDocumentAt:path];
    }

    return [EPUBDocument alloc] initWithDirectory:directory contentDirectory:conte metadata:<#(nonnull EPUBMetadata *)#> manifest:<#(nonnull EPUBManifest *)#> spine:<#(nonnull EPUBSpine *)#> tableOfContents:<#(nonnull EPUBTableOfContents *)#>
}


#pragma mark - EPUBParsable
- (NSURL*)unzipArchiveAt:(NSURL*)path error:(NSError**)error
{

}

- (EPUBSpine*)getSpine:(CXMLElement*)xmlElement
{

}

- (EPUBMetadata*)getMetadata:(CXMLElement*)xmlElement
{

}

- (EPUBManifest*)getManifest:(CXMLElement*)xmlElement
{

}

- (EPUBTableOfContents*)getTableOfContents:(CXMLElement*)xmlElement
{
    
}
@end
