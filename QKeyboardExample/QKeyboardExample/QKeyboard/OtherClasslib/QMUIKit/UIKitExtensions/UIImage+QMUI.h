//
//  UIImage+QMUI.h
//  qmui
//
//  Created by ZhoonChen on 15/7/20.
//  Copyright (c) 2015年 QMUI Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "NTKeyboardPublicMethods.h"

#define CGContextInspectSize(size) [NTKeyboardPublicMethods inspectContextSize:size]

#ifdef DEBUG
    #define CGContextInspectContext(context) [NTKeyboardPublicMethods inspectContextIfInvalidatedInDebugMode:context]
#else
    #define CGContextInspectContext(context) if(![NTKeyboardPublicMethods inspectContextIfInvalidatedInReleaseMode:context]){return nil;}
#endif

typedef NS_ENUM(NSInteger, QMUIImageShape) {
    QMUIImageShapeOval,                 // 椭圆
    QMUIImageShapeTriangle,             // 三角形
    QMUIImageShapeDisclosureIndicator,  // 列表cell右边的箭头
    QMUIImageShapeCheckmark,            // 列表cell右边的checkmark
    QMUIImageShapeNavBack,              // 返回按钮的箭头
    QMUIImageShapeNavClose              // 导航栏的关闭icon
};

typedef NS_OPTIONS(NSInteger, QMUIImageBorderPosition) {
    QMUIImageBorderPositionAll      = 0,
    QMUIImageBorderPositionTop      = 1 << 0,
    QMUIImageBorderPositionLeft     = 1 << 1,
    QMUIImageBorderPositionBottom   = 1 << 2,
    QMUIImageBorderPositionRight    = 1 << 3,
};

@interface UIImage (QMUI)

/**
 *  创建一个带边框路径，没有背景色的路径图片（可以是任意一条边，也可以是多条组合；只能创建矩形的border，不能添加圆角）
 *
 *  @param strokeColor        路径的颜色
 *  @param size               图片的大小
 *  @param lineWidth          路径的大小
 *  @param borderPosition     图片的路径位置，上左下右
 *
 *  @return 带路径，没有背景色的UIImage
 */
+ (UIImage *)qmui_imageWithStrokeColor:(UIColor *)strokeColor size:(CGSize)size lineWidth:(CGFloat)lineWidth borderPosition:(QMUIImageBorderPosition)borderPosition;

@end
