//
//  EPUBParser.h
//  YHEpubDemo
//
//  Created by tryao on 2023/3/1.
//  Copyright © 2023 survivorsfyh. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EPUBDocument, EPUBParser, EPUBSpine, CXMLElement, EPUBParser, EPUBMetadata, EPUBManifest, EPUBSpine, EPUBTableOfContents;

@protocol EPUBParserProtocol <NSObject>

- (EPUBDocument*)parseDocument:(NSURL*)url;

@end

@protocol EPUBParserDelegate <NSObject>

- (void)parser:(EPUBParser*)parser didBeginParsingDocumentAt:(NSURL*)path;
- (void)parser:(EPUBParser*)parser didUnzipArchiveTo:(NSURL*)directory;
- (void)parser:(EPUBParser*)parser didLocateContentAt:(NSURL*)directory;
- (void)parser:(EPUBParser*)parser didFinishParsingMetadata:(EPUBMetadata*)metadata;
- (void)parser:(EPUBParser*)parser didFinishParsingManifest:(EPUBManifest*)manifest;
- (void)parser:(EPUBParser*)parser didFinishParsingSpine:(EPUBSpine*)spine;
- (void)parser:(EPUBParser*)parser didFinishParsingTableOfContents:(EPUBTableOfContents*)tableOfContents;
- (void)parser:(EPUBParser*)parser didFinishParsingDocumentAt:(NSURL*)path;
- (void)parser:(EPUBParser*)parser didFailParsingDocumentAt:(NSURL*)path withError:(NSError*)error;

@end

@protocol EPUBParsable <NSObject>

- (NSURL*)unzipArchiveAt:(NSURL*)path error:(NSError**)error;
- (EPUBSpine*)getSpine:(CXMLElement*)xmlElement;
- (EPUBMetadata*)getMetadata:(CXMLElement*)xmlElement;
- (EPUBManifest*)getManifest:(CXMLElement*)xmlElement;
- (EPUBTableOfContents*)getTableOfContents:(CXMLElement*)xmlElement;

@end

NS_ASSUME_NONNULL_BEGIN

@interface EPUBParser : NSObject<EPUBParserProtocol, EPUBParsable>

//- (XDSEpubKitBookType)bookTypeForBaseURL:(NSURL *)baseURL;
//
//- (XDSEpubKitBookEncryption)contentEncryptionForBaseURL:(NSURL *)baseURL;
//
//- (NSURL *)rootFileForBaseURL:(NSURL *)baseURL;
//
//- (NSString *)coverPathComponentFromDocument:(DDXMLDocument *)document;
//
//
//
//- (BOOL)isRTLFromDocument:(DDXMLDocument *)document;
//
//
//- (NSArray *)guideFromDocument:(DDXMLDocument *)document;

@property (nonatomic, weak) id<EPUBParserDelegate> delegate;

- (EPUBDocument*)parseDocument:(NSURL*)url;

@end

NS_ASSUME_NONNULL_END
