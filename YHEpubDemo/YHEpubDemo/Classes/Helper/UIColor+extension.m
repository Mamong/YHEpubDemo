//
//  UIColor+extension.m
//  YHEpubDemo
//
//  Created by tryao on 2023/3/1.
//  Copyright © 2023 survivorsfyh. All rights reserved.
//

#import "UIColor+extension.h"

@implementation UIColor(extension)

- (BOOL)isLighterColor
{
    CGFloat red,green,blue,alpha;
    [self getRed:&red green:&green blue:&blue alpha:&alpha];
    return [UIColor isLighterColorWithRed:red green:green blue:blue];
}

+ (BOOL)isLighterColorWithHXB:(NSInteger)hexColor {
    float red = ((float)((hexColor & 0xFF0000) >> 16))/255.0;
    float green = ((float)((hexColor & 0xFF00) >> 8))/255.0;
    float blue = ((float)(hexColor & 0xFF))/255.0;
    return [self isLighterColorWithRed:red green:green blue:blue];
}

+ (BOOL)isLighterColorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue {
    BOOL isLighter = NO;
    if(red*0.299 + green*0.578 + blue*0.114 >= 192){
        //浅色
        isLighter = YES;
    }
    return isLighter;
}

- (UIColor *)lighterColor {
    if ([self isEqual:[UIColor whiteColor]]) {
        return [UIColor colorWithWhite:0.99 alpha:1.0];
    }
    if ([self isEqual:[UIColor blackColor]]) {
       return [UIColor colorWithWhite:0.01 alpha:1.0];
    }
    CGFloat hue, saturation, brightness, alpha, white;
    if ([self getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha]) {
        return [UIColor colorWithHue:hue
                          saturation:saturation
                          brightness:MIN(brightness * 1.3, 1.0)
                               alpha:alpha];
    } else if ([self getWhite:&white alpha:&alpha]) {
        return [UIColor colorWithWhite:MIN(white * 1.3, 1.0) alpha:alpha];
    }
    return nil;
}

- (UIColor *)darkerColor {
    if ([self isEqual:[UIColor whiteColor]]) {
        return [UIColor colorWithWhite:0.99 alpha:1.0];
    }
    if ([self isEqual:[UIColor blackColor]]) {
        return [UIColor colorWithWhite:0.01 alpha:1.0];
    }
    CGFloat hue, saturation, brightness, alpha, white;
    if ([self getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha]) {
        return [UIColor colorWithHue:hue
                          saturation:saturation
                          brightness:brightness * 0.75
                               alpha:alpha];
    } else if ([self getWhite:&white alpha:&alpha]) {
        return [UIColor colorWithWhite:MAX(white * 0.75, 0.0) alpha:alpha];
    }
    return nil;
}

@end
