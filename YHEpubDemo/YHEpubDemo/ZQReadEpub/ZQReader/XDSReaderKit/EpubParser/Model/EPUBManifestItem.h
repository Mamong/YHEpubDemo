//
//  EPUBManifestItem.h
//  YHEpubDemo
//
//  Created by tryao on 2023/3/1.
//  Copyright © 2023 survivorsfyh. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSString* EPUBMediaType NS_STRING_ENUM;

FOUNDATION_EXPORT EPUBMediaType const EPUBMediaTypeGif;
FOUNDATION_EXPORT EPUBMediaType const EPUBMediaTypeJpeg;
FOUNDATION_EXPORT EPUBMediaType const EPUBMediaTypePng;
FOUNDATION_EXPORT EPUBMediaType const EPUBMediaTypeSvg;
FOUNDATION_EXPORT EPUBMediaType const EPUBMediaTypeXhtml;
FOUNDATION_EXPORT EPUBMediaType const EPUBMediaTypeJavascript;
FOUNDATION_EXPORT EPUBMediaType const EPUBMediaTypeOpf2;
FOUNDATION_EXPORT EPUBMediaType const EPUBMediaTypeOpenType;
FOUNDATION_EXPORT EPUBMediaType const EPUBMediaTypeWoff;
FOUNDATION_EXPORT EPUBMediaType const EPUBMediaTypeMediaOverlays;
FOUNDATION_EXPORT EPUBMediaType const EPUBMediaTypePls;
FOUNDATION_EXPORT EPUBMediaType const EPUBMediaTypeMp3;
FOUNDATION_EXPORT EPUBMediaType const EPUBMediaTypeMp4;
FOUNDATION_EXPORT EPUBMediaType const EPUBMediaTypeCss;
FOUNDATION_EXPORT EPUBMediaType const EPUBMediaTypeWoff2;
FOUNDATION_EXPORT EPUBMediaType const EPUBMediaTypeUnknown;


@interface EPUBManifestItem : NSObject

@property(nonatomic, strong) NSString *id;
@property(nonatomic, strong) NSString *href;
@property(nonatomic, strong) EPUBMediaType mediaType;
@property(nonatomic, strong) NSString *properties;
@property(nonatomic, strong) NSString *mediaOverlay;//指向smil文件id

@end

NS_ASSUME_NONNULL_END
