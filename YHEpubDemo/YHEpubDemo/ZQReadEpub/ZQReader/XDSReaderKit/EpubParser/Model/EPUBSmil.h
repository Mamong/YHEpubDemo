//
//  EPUBSmil.h
//  YHEpubDemo
//
//  Created by tryao on 2023/3/1.
//  Copyright © 2023 survivorsfyh. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class EPUBSmilText, EPUBSmilAudio, EPUBSmilVideo;

@interface EPUBSmil : NSObject

@property(nonatomic, strong) NSArray *contents;//seq or par

@end


@interface EPUBSmilSeq : NSObject
@property(nonatomic, strong) NSString *id;
@property(nonatomic, strong) NSString *textref;
@property(nonatomic, strong) NSArray<NSString*> *type;
@property(nonatomic, strong) NSArray *contents;//seq or par

@end

@interface EPUBSmilPar : NSObject
@property(nonatomic, strong) NSString *id;
@property(nonatomic, strong) NSArray<NSString*> *type;
@property(nonatomic, strong) EPUBSmilText *text;
@property(nonatomic, strong) EPUBSmilAudio *audio;
@property(nonatomic, strong) EPUBSmilVideo *video;
@end

@interface EPUBSmilElem : NSObject
@property(nonatomic, strong) NSString *id;
@property(nonatomic, strong) NSString *src;
@end

@interface EPUBSmilText : EPUBSmilElem
@end

@interface EPUBSmilVideo : EPUBSmilElem
@end

@interface EPUBSmilAudio : EPUBSmilElem
@property(nonatomic, assign) double clipBegin;
@property(nonatomic, assign) double clipEnd;
@end

NS_ASSUME_NONNULL_END
