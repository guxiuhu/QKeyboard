//
//  PublicMethods.m
//  NTKeyboard
//
//  Created by 古秀湖 on 16/5/9.
//  Copyright © 2016年 南天. All rights reserved.
//

#import "NTKeyboardPublicMethods.h"
#import <Security/Security.h>
#import <CommonCrypto/CommonCryptor.h>
#import "GTMBase64.h"
#import <UIKit/UIKit.h>

@implementation NTKeyboardPublicMethods

/**
 *  读取bundle里面的图片
 *
 *  @param filename 图片名称
 *
 *  @return 路径
 */
+(NSString*)getKaYiKaImageBundlePath:(NSString *)filename {
    
    
    NSBundle *libBundle = [NSBundle bundleWithPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"NTKeyboardBundle.bundle"]];
    
    if (libBundle && filename) {
        
        NSString *path = [[libBundle resourcePath] stringByAppendingPathComponent:filename];
        
        path = [path stringByAppendingString:@".png"];
        
        return path;
        
    }
    
    return nil;
}
#pragma mark - 授权校验
+(BOOL)checkAuthorize{
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"NTAuthorize" ofType:nil ];
    NSFileManager *manager = [NSFileManager defaultManager];
    
    if ([manager fileExistsAtPath:filePath]) {
        
        NSError *error = nil;
        NSString *str = [NSString stringWithContentsOfURL:[NSURL fileURLWithPath:filePath] encoding:NSUTF8StringEncoding error:&error];
        
        if (error) {
            
            return NO;
            
        } else {
            
            NSString *resultStr = [self decrypt3des:str andKey:@"$gzntd2&2016$iosandroid$" andIv:nil];
            
            if (resultStr) {
                
                NSData *JSONData = [resultStr dataUsingEncoding:NSUTF8StringEncoding];
                NSError *jsonError = nil;
                id resultObj = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingMutableLeaves error:&jsonError];
                if (jsonError) {
                    return NO;
                }else{
                    
                    if ([resultObj isKindOfClass:[NSDictionary class]]) {
                        
                        //先判断平台
                        if ([@"ios" isEqualToString:[resultObj objectForKey:@"platform"]]) {
                            //平台通过
                            //再bundle id
                            NSString *bundleid = [[NSBundle mainBundle]bundleIdentifier];
                            if ([bundleid isEqualToString:[resultObj objectForKey:@"bundleid"]]) {
                                //bundle id通过
                                
                                //比较过期时间
                                NSTimeZone* GTMzone = [NSTimeZone timeZoneForSecondsFromGMT:0];
                                
                                NSDateFormatter *df = [[NSDateFormatter alloc] init];
                                [df setDateFormat:@"yyyy-MM-dd"];
                                [df setTimeZone:GTMzone];
                                NSDate *currentDate = [NSDate date];
                                NSDate *authorizeDate = [[NSDate alloc] init];
                                authorizeDate = [df dateFromString:[resultObj objectForKey:@"validity_peroid"]];
                                
                                NSComparisonResult result = [currentDate compare:authorizeDate];
                                if (result == NSOrderedAscending) {
                                    return YES;
                                }else{
                                    return NO;
                                }
                                
                            }else{
                                
                                return NO;
                            }
                            
                        }else{
                            
                            return NO;
                        }
                        
                    }else{
                        
                        return NO;
                    }
                }
                
            }else{
                
                return NO;
            }
            
        }
        
    } else {
        
        return NO;
    }
}

// 3des解密方法
+ (NSString*)decrypt3des:(NSString*)text andKey:(NSString*)gkey andIv:(NSString*)gIv{
    
    NSData *encryptData = [GTMBase64 decodeData:[text dataUsingEncoding:NSUTF8StringEncoding]];
    size_t plainTextBufferSize = [encryptData length];
    const void *vplainText = [encryptData bytes];
    
    CCCryptorStatus ccStatus;
    uint8_t *bufferPtr = NULL;
    size_t bufferPtrSize = 0;
    size_t movedBytes = 0;
    bufferPtrSize = (plainTextBufferSize + kCCBlockSize3DES) & ~(kCCBlockSize3DES - 1);
    bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t));
    memset((void *)bufferPtr, 0x0, bufferPtrSize);
    const void *vkey = (const void *) [gkey UTF8String];
    const void *vinitVec = (const void *) [gIv UTF8String];
    
    ccStatus = CCCrypt(kCCDecrypt,
                       kCCAlgorithm3DES,
                       kCCOptionPKCS7Padding,
                       vkey,
                       kCCKeySize3DES,
                       vinitVec,
                       vplainText,
                       plainTextBufferSize,
                       (void *)bufferPtr,
                       bufferPtrSize,
                       &movedBytes);
    
    NSString *result = [[NSString alloc] initWithData:[NSData dataWithBytes:(const void *)bufferPtr
                                                                     length:(NSUInteger)movedBytes] encoding:NSUTF8StringEncoding];
    return result;
}


+(void)authorizeFail{
    
    UIAlertView *alerView = [[UIAlertView alloc]initWithTitle:@"警告" message:@"对不起，您的授权未通过" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
    [alerView show];
    
}

static CGFloat pixelOne = -1.0f;
+ (CGFloat)pixelOne {
    if (pixelOne < 0) {
        pixelOne = 1 / [[UIScreen mainScreen] scale];
    }
    return pixelOne;
}

+ (void)inspectContextSize:(CGSize)size {
    if (size.width < 0 || size.height < 0) {
        NSAssert(NO, @"QMUI CGPostError, %@:%d %s, 非法的size：%@\n%@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, __PRETTY_FUNCTION__, NSStringFromCGSize(size), [NSThread callStackSymbols]);
    }
}

+ (void)inspectContextIfInvalidatedInDebugMode:(CGContextRef)context {
    if (!context) {
        // crash了就找zhoon或者molice
        NSAssert(NO, @"QMUI CGPostError, %@:%d %s, 非法的context：%@\n%@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, __PRETTY_FUNCTION__, context, [NSThread callStackSymbols]);
    }
}

+ (BOOL)inspectContextIfInvalidatedInReleaseMode:(CGContextRef)context {
    if (context) {
        return YES;
    }
    return NO;
}

/**
 生成随机数据

 @param array 数据
 @return 随机数组
 */
+(NSMutableArray *)randomWithArray:(NSMutableArray *)array{
    
    if (![NTKeyboardPublicMethods checkAuthorize]) {
        
        [NTKeyboardPublicMethods authorizeFail];
    }
    
    NSMutableArray *newArray = [NSMutableArray new];
    NSUInteger length = [array count];
    for (NSUInteger i = 0;i<length;i++) {
        NSUInteger newLength =[array count];
        if (newLength == 1) {
            break;
        }
        NSUInteger rand = arc4random() % (newLength-1);
        NSString *temp = [array objectAtIndex:rand];
        
        [array removeObjectAtIndex:rand];
        [array insertObject:[array objectAtIndex:0] atIndex:rand];
        
        [array removeObjectAtIndex:0];
        [newArray addObject:temp];
        
        
    }
    return newArray;
}

@end
