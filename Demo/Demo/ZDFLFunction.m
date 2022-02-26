//
//  ZDFLFunction.m
//  Demo
//
//  Created by Zero.D.Saber on 2022/2/27.
//  Copyright © 2022 Zero.D.Saber. All rights reserved.
//

#import "ZDFLFunction.h"

@implementation ZDFLFunction

@end


UIColor *ZD_RandomColor(void) {
    CGFloat hue = (arc4random() % 256 / 256.0);
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}
