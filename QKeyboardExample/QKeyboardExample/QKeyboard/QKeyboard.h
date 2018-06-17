//
//  QKeyboard.h
//  QKeyboardExample
//
//  Created by 古秀湖 on 2016/10/20.
//  Copyright © 2016年 南天. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    NUMBER = 0,
    LETTER = 1,
    SIGN = 2,
}QKeyBoardType;

@protocol QKeyBoardViewDelegate <NSObject>

@optional
- (void)didSelectKeyButton:(NSString *)keyValue;//点击键盘获取值
- (void)didCloseKeyBoard;
- (void)didSelectSpaceButton;
- (void)didSelectDeleteButton;
@end

@interface QKeyboard : UIView

-(void)showPop;

-(void)hideKeyboard;

-(BOOL)isKeyboardIsShowing;

@property (nonatomic,assign)NSObject<QKeyBoardViewDelegate> *m_delegate;

@property BOOL letterRandom;
@property BOOL signRandom;
@property BOOL numRandom;


/**
 初始化方法

 @param frame 布局
 @param keyboardType 键盘类型
 @param letterRandom 字母是否需要随机键盘
 @param signRandom 符号是否需要随机键盘
 @param numRandom 数字是否需要随机键盘
 @return 实例
 */
- (id)initWithFrame:(CGRect)frame andKeyboardType:(NSInteger)keyboardType andLetterRandom:(BOOL)letterRandom andSignRandom:(BOOL)signRandom andNumRandom:(BOOL)numRandom;

@end
