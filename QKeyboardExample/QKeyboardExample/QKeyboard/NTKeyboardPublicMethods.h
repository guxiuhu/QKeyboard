//
//  PublicMethods.h
//  NTKeyboard
//
//  Created by 古秀湖 on 16/5/9.
//  Copyright © 2016年 南天. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define ScreenScale ([[UIScreen mainScreen] scale])

/**
 *  基于指定的倍数，对传进来的 floatValue 进行像素取整。若指定倍数为0，则表示以当前设备的屏幕倍数为准。
 *
 *  例如传进来 “2.1”，在 2x 倍数下会返回 2.5（0.5pt 对应 1px），在 3x 倍数下会返回 2.333（0.333pt 对应 1px）。
 */
CG_INLINE CGFloat
flatSpecificScale(CGFloat floatValue, CGFloat scale) {
    scale = scale == 0 ? ScreenScale : scale;
    CGFloat flattedValue = ceil(floatValue * scale) / scale;
    return flattedValue;
}

/**
 *  基于当前设备的屏幕倍数，对传进来的 floatValue 进行像素取整。
 *
 *  注意如果在 Core Graphic 绘图里使用时，要注意当前画布的倍数是否和设备屏幕倍数一致，若不一致，不可使用 flat() 函数，而应该用 flatSpecificScale
 */
CG_INLINE CGFloat
flat(CGFloat floatValue) {
    return flatSpecificScale(floatValue, 0);
}

/// 将一个CGSize像素对齐
CG_INLINE CGSize
CGSizeFlatted(CGSize size) {
    return CGSizeMake(flat(size.width), flat(size.height));
}

/// 判断一个size是否为空（宽或高为0）
CG_INLINE BOOL
CGSizeIsEmpty(CGSize size) {
    return size.width <= 0 || size.height <= 0;
}

@interface NTKeyboardPublicMethods : NSObject

/**
 *  读取bundle里面的图片
 *
 *  @param filename 图片名称
 *
 *  @return 路径
 */
+(NSString*)getKaYiKaImageBundlePath:(NSString *)filename;
#pragma mark - 授权校验
+(BOOL)checkAuthorize;

+(void)authorizeFail;

/// 获取一像素的大小
+ (CGFloat)pixelOne;

/// 判断size是否超出范围
+ (void)inspectContextSize:(CGSize)size;

/// context是否合法
+ (void)inspectContextIfInvalidatedInDebugMode:(CGContextRef _Nonnull)context;
+ (BOOL)inspectContextIfInvalidatedInReleaseMode:(CGContextRef _Nonnull)context;

/**
 生成随机数据
 
 @param array 数据
 @return 随机数组
 */
+(NSMutableArray *)randomWithArray:(NSMutableArray *)array;

@end
