//
//  UIImage+QMUI.m
//  qmui
//
//  Created by ZhoonChen on 15/7/20.
//  Copyright (c) 2015年 QMUI Team. All rights reserved.
//

#import "UIImage+QMUI.h"
//#import "QMUICommonDefines.h"
//#import "QMUIConfiguration.h"
//#import "QMUIHelper.h"
//#import "UIBezierPath+QMUI.h"
//#import "UIColor+QMUI.h"
#import <Accelerate/Accelerate.h>
#import <objc/runtime.h>

@implementation UIImage (QMUI)

+ (UIImage *)qmui_imageWithStrokeColor:(UIColor *)strokeColor size:(CGSize)size path:(UIBezierPath *)path addClip:(BOOL)addClip {
    size = CGSizeFlatted(size);
    CGContextInspectSize(size);
    UIImage *resultImage = nil;
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextInspectContext(context);
    CGContextSetStrokeColorWithColor(context, strokeColor.CGColor);
    if (addClip) [path addClip];
    [path stroke];
    resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImage;
}

+ (UIImage *)qmui_imageWithStrokeColor:(UIColor *)strokeColor size:(CGSize)size lineWidth:(CGFloat)lineWidth cornerRadius:(CGFloat)cornerRadius {
    CGContextInspectSize(size);
    // 往里面缩一半的lineWidth，应为stroke绘制线的时候是往两边绘制的
    // 如果cornerRadius为0的时候使用bezierPathWithRoundedRect:cornerRadius:会有问题，左上角老是会多出一点，所以区分开
    UIBezierPath *path;
    CGRect rect = CGRectInset(CGRectMake(0, 0, size.width, size.height), lineWidth / 2, lineWidth / 2);
    if (cornerRadius > 0) {
        path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:cornerRadius];
    } else {
        path = [UIBezierPath bezierPathWithRect:rect];
    }
    [path setLineWidth:lineWidth];
    return [UIImage qmui_imageWithStrokeColor:strokeColor size:size path:path addClip:NO];
}


+ (UIImage *)qmui_imageWithStrokeColor:(UIColor *)strokeColor size:(CGSize)size lineWidth:(CGFloat)lineWidth borderPosition:(QMUIImageBorderPosition)borderPosition {
    CGContextInspectSize(size);
    if (borderPosition == QMUIImageBorderPositionAll) {
        return [UIImage qmui_imageWithStrokeColor:strokeColor size:size lineWidth:lineWidth cornerRadius:0];
    } else {
        // TODO 使用bezierPathWithRoundedRect:byRoundingCorners:cornerRadii:这个系统接口
        UIBezierPath* path = [UIBezierPath bezierPath];
        if ((QMUIImageBorderPositionBottom & borderPosition) == QMUIImageBorderPositionBottom) {
            [path moveToPoint:CGPointMake(0, size.height - lineWidth / 2)];
            [path addLineToPoint:CGPointMake(size.width, size.height - lineWidth / 2)];
        }
        if ((QMUIImageBorderPositionTop & borderPosition) == QMUIImageBorderPositionTop) {
            [path moveToPoint:CGPointMake(0, lineWidth / 2)];
            [path addLineToPoint:CGPointMake(size.width, lineWidth / 2)];
        }
        if ((QMUIImageBorderPositionLeft & borderPosition) == QMUIImageBorderPositionLeft) {
            [path moveToPoint:CGPointMake(lineWidth / 2, 0)];
            [path addLineToPoint:CGPointMake(lineWidth / 2, size.height)];
        }
        if ((QMUIImageBorderPositionRight & borderPosition) == QMUIImageBorderPositionRight) {
            [path moveToPoint:CGPointMake(size.width - lineWidth / 2, 0)];
            [path addLineToPoint:CGPointMake(size.width - lineWidth / 2, size.height)];
        }
        [path setLineWidth:lineWidth];
        [path closePath];
        return [UIImage qmui_imageWithStrokeColor:strokeColor size:size path:path addClip:NO];
    }
}

@end
