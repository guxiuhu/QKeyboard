//
//  QKeyboard.m
//  QKeyboardExample
//
//  Created by 古秀湖 on 2016/10/20.
//  Copyright © 2016年 南天. All rights reserved.
//

#import "QKeyboard.h"
#import "PopupView.h"
#import "Masonry.h"
#import "QMUIGridView.h"
#import "UIImage+QMUI.h"
#import "NTKeyboardPublicMethods.h"
#import "QUIButton.h"

#define kLabelBoldFontSize16_5 [UIFont systemFontOfSize:16.5]

#define QKB_TEXT_COLOR [UIColor colorWithRed:0.102 green:0.102 blue:0.102 alpha:1.00]

@interface QKeyboard ()

@property (strong, nonatomic) PopupView *pop;

@property (strong, nonatomic) UIView *headerView;

@property (nonatomic,retain) NSMutableArray *keyBtnsAry;
@property (nonatomic,retain) NSMutableArray *keyBtnTitlesAry;

@property (nonatomic, strong) UIView *keboardContainerView;

@property NSInteger currentKeyboardType;

@end

@implementation QKeyboard

/**
 初始化方法
 
 @param frame 布局
 @param keyboardType 键盘类型
 @param letterRandom 字母是否需要随机键盘
 @param signRandom 符号是否需要随机键盘
 @param numRandom 数字是否需要随机键盘
 @return 实例
 */
- (id)initWithFrame:(CGRect)frame andKeyboardType:(NSInteger)keyboardType andLetterRandom:(BOOL)letterRandom andSignRandom:(BOOL)signRandom andNumRandom:(BOOL)numRandom{
    
    self = [super initWithFrame:frame];
    if (self) {
        
        if (![NTKeyboardPublicMethods checkAuthorize]) {
            
            [NTKeyboardPublicMethods authorizeFail];
            return self;
        }
        
        self.letterRandom = letterRandom;
        self.signRandom = signRandom;
        self.numRandom = numRandom;
        
        //头部工具栏
        self.headerView = [[UIView alloc]init];
        [self.headerView setBackgroundColor:[UIColor colorWithRed:0.902 green:0.902 blue:0.902 alpha:1.00]];
        [self addSubview:self.headerView];
        [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.and.right.and.top.equalTo(self);
            make.height.mas_equalTo(44);
        }];
        
        QUIButton *closeKbBtn = [[QUIButton alloc]init];
        [closeKbBtn setImage:[UIImage imageWithContentsOfFile:[NTKeyboardPublicMethods getKaYiKaImageBundlePath:@"close_keyboard"]] forState:UIControlStateNormal];
        [closeKbBtn addTarget:self action:@selector(closeKeyboardAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.headerView addSubview:closeKbBtn];
        [closeKbBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.width.mas_equalTo(19+15*2);
            make.height.mas_equalTo(44);
            make.centerY.equalTo(self.headerView);
            make.right.equalTo(self.headerView);
        }];
        
        UIImageView *lineView = [[UIImageView alloc]initWithImage:[self createImageWithColor:[UIColor colorWithRed:0.757 green:0.757 blue:0.757 alpha:1.00]]];
        [self.headerView addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.width.mas_equalTo(1);
            make.height.mas_equalTo(27);
            make.centerY.equalTo(self.headerView);
            make.right.equalTo(closeKbBtn.mas_left);
        }];
        
        //标题
        UILabel *tiplabel = [[UILabel alloc]init];
        [tiplabel setText:@"安全键盘"];
        [tiplabel setTextAlignment:NSTextAlignmentCenter];
        [self.headerView addSubview:tiplabel];
        [tiplabel mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.top.and.bottom.equalTo(self.headerView);
            make.left.equalTo(self.headerView).with.offset(50);
            make.right.equalTo(lineView.mas_left);
        }];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(dismissPop:) name:UIDeviceOrientationDidChangeNotification object:nil];
        
        self.keyBtnsAry = [[NSMutableArray alloc] init];
        self.keyBtnTitlesAry = [[NSMutableArray alloc] init];
        
        self.currentKeyboardType = 2;
        
        //键盘容器
        self.keboardContainerView = [[UIView alloc]init];
        [self.keboardContainerView setBackgroundColor:[UIColor colorWithRed:0.800 green:0.800 blue:0.800 alpha:1.00]];
        [self addSubview:self.keboardContainerView];
        
        switch (keyboardType) {
            case NUMBER:
            {
                //数字
                [self numberKeyBoradView];
            }
                break;
            case LETTER:
            {
                //字母
                [self letterKeyBoradView];
            }
                break;
            default:
            {
                //符号
                [self signKeyBoradView];
            }
                break;
        }
        
    }
    return self;
}

-(void)showPop{
    
    if (![NTKeyboardPublicMethods checkAuthorize]) {
        
        [NTKeyboardPublicMethods authorizeFail];
        return;
        
    }
    
    self.pop = [PopupView popupViewWithContentView:self showType:PopupViewShowTypeBounceInFromBottom dismissType:PopupViewDismissTypeFadeOut maskType:PopupViewMaskTypeClear shouldDismissOnBackgroundTouch:YES shouldDismissOnContentTouch:NO];
    
    PopupViewLayout layout = PopupViewLayoutMake(PopupViewHorizontalLayoutCenter, PopupViewVerticalLayoutBottom);
    [self.pop showWithLayout:layout];
    
}

-(void)hideKeyboard{
    
    if (![NTKeyboardPublicMethods checkAuthorize]) {
        
        [NTKeyboardPublicMethods authorizeFail];
        return;
        
    }
    
    if (self.pop) {
        [self.pop dismiss:YES];
    }
}

-(BOOL)isKeyboardIsShowing{
    
    if (![NTKeyboardPublicMethods checkAuthorize]) {
        
        [NTKeyboardPublicMethods authorizeFail];
        return NO;
        
    }
    
    if (self.pop) {
        
        if ([self.pop isBeingShown]) {
            return YES;
        }
        
        if ([self.pop isShowing]) {
            return YES;
        }
    }
    
    return NO;
}

-(void)dismissPop:(id)sender{
    
    if (![NTKeyboardPublicMethods checkAuthorize]) {
        
        [NTKeyboardPublicMethods authorizeFail];
        return;
        
    }
    [self.pop dismiss:YES];
}

#pragma mark - 初始化数字键盘数据和数字键盘按钮

/**
 初始化数字键盘数据和数字键盘按钮
 */
- (void)numberKeyBoradView{
    
    if (![NTKeyboardPublicMethods checkAuthorize]) {
        
        [NTKeyboardPublicMethods authorizeFail];
        return;
        
    }
    
    [self.keboardContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        
        make.left.and.right.and.bottom.equalTo(self);
        make.top.equalTo(self.headerView.mas_bottom).with.offset(0);
    }];
    
    QMUIGridView *gridView = [[QMUIGridView alloc] init];
    gridView.columnCount = 3;
    gridView.rowHeight = (self.keboardContainerView.frame.size.height-3)/4;
    gridView.separatorWidth = [NTKeyboardPublicMethods pixelOne];
    gridView.separatorColor = [UIColor lightGrayColor];
    gridView.separatorDashed = NO;
    [self.keboardContainerView addSubview:gridView];
    
    
    NSMutableArray *numAry = [[NSMutableArray alloc] initWithObjects:@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"11", nil];
    if (self.numRandom) {
        numAry = [NTKeyboardPublicMethods randomWithArray:numAry];
    }

    // 将要布局的 item 以 addSubview: 的方式添加进去即可自动布局
    for (int i = 1; i <= 12; i++) {
        [gridView addSubview:[self generateButtonAtIndex:i andNumberAry:numAry]];
    }
    
    [gridView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.and.right.and.top.and.bottom.equalTo(self.keboardContainerView);
    }];
}

- (QUIButton *)generateButtonAtIndex:(NSInteger)index andNumberAry:(NSMutableArray*)numAry{
    
    QUIButton *button = [QUIButton buttonWithType:UIButtonTypeCustom];
    [button setTitleColor:[UIColor colorWithRed:0.012 green:0.012 blue:0.012 alpha:1.00] forState:UIControlStateNormal];
    [button setBackgroundImage:[self createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    
    button.tag = index;

    if (index <= 9) {
        [button setTitle:[numAry objectAtIndex:index] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(btnSelectAction:) forControlEvents:UIControlEventTouchUpInside];
    }else if (index == 10){
        [button setTitle:@"abc" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(changeToLetterKeyboard) forControlEvents:UIControlEventTouchUpInside];
    }else if (index == 11){
        
        [button setTitle:[numAry objectAtIndex:0] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(btnSelectAction:) forControlEvents:UIControlEventTouchUpInside];
    }else if (index == 12){
        
        [button setImage:[UIImage imageWithContentsOfFile:[NTKeyboardPublicMethods getKaYiKaImageBundlePath:@"key_del"]] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return button;
}

#pragma mark - 初始化字母键盘数据和字母键盘按钮
/**
 初始化字母键盘数据和字母键盘按钮
 */
- (void)letterKeyBoradView{
    
    if (![NTKeyboardPublicMethods checkAuthorize]) {
        
        [NTKeyboardPublicMethods authorizeFail];
        return;
        
    }

    for (UIView *subView in self.keboardContainerView.subviews) {
        [subView removeFromSuperview];
    }
    
    [self.keboardContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        
        make.left.and.right.and.bottom.equalTo(self);
        make.top.equalTo(self.headerView.mas_bottom).with.offset(0);
    }];
    
    [self.keyBtnsAry removeAllObjects];
    
    //计算按键的高度
    CGFloat keyHeight = (self.frame.size.height - 44 - 4 - 6 - 10 *3 + 5)/4;
    
    //切换到符号键盘
    QUIButton *signSwitchBtn = [QUIButton buttonWithType:UIButtonTypeCustom];
    signSwitchBtn.clipsToBounds = YES;
    signSwitchBtn.layer.cornerRadius = 8;
    [signSwitchBtn setBackgroundImage:[self createImageWithColor:[UIColor colorWithRed:0.702 green:0.702 blue:0.702 alpha:1.00]] forState:UIControlStateNormal];
    [signSwitchBtn setTitle:@"#+=" forState:UIControlStateNormal];
    [signSwitchBtn setTitleColor:QKB_TEXT_COLOR forState:UIControlStateNormal];
    [signSwitchBtn addTarget:self action:@selector(changeToSignKeyboard) forControlEvents:UIControlEventTouchUpInside];
    [self.keboardContainerView addSubview:signSwitchBtn];
    [signSwitchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.height.mas_equalTo(keyHeight-5);
        make.width.mas_equalTo(56);
        make.right.equalTo(self.keboardContainerView).with.offset(-12);
        make.bottom.equalTo(self.keboardContainerView).with.offset(-4);
    }];
    
    //切换字母和数字键盘的按钮
    QUIButton *numSwithBtn = [QUIButton buttonWithType:UIButtonTypeCustom];
    numSwithBtn.clipsToBounds = YES;
    numSwithBtn.layer.cornerRadius = 8;
    [numSwithBtn setBackgroundImage:[self createImageWithColor:[UIColor colorWithRed:0.702 green:0.702 blue:0.702 alpha:1.00]] forState:UIControlStateNormal];
    [numSwithBtn addTarget:self action:@selector(changeToNumKeyboard) forControlEvents:UIControlEventTouchUpInside];
    [numSwithBtn setTitle:@"123" forState:UIControlStateNormal];
    [numSwithBtn setTitleColor:QKB_TEXT_COLOR forState:UIControlStateNormal];
    [self.keboardContainerView addSubview:numSwithBtn];
    [numSwithBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.height.mas_equalTo(keyHeight-5);
        make.width.mas_equalTo(56);
        make.left.equalTo(self.keboardContainerView).with.offset(12);
        make.bottom.equalTo(self.keboardContainerView).with.offset(-4);
        
    }];
    
    //空格
    QUIButton *spaceBtn = [QUIButton buttonWithType:UIButtonTypeCustom];
    spaceBtn.tag = 1014;
    
    UIImage *originImage = [UIImage qmui_imageWithStrokeColor:QKB_TEXT_COLOR size:CGSizeMake([UIScreen mainScreen].bounds.size.width/3, 10) lineWidth:2 borderPosition:QMUIImageBorderPositionLeft|QMUIImageBorderPositionRight|QMUIImageBorderPositionBottom];
    
    [spaceBtn setBackgroundImage:[self createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [spaceBtn setImage:originImage forState:UIControlStateNormal];
    spaceBtn.layer.cornerRadius = 8;
    [spaceBtn addTarget:self action:@selector(spaceAction:) forControlEvents:UIControlEventTouchUpInside];
    [spaceBtn setClipsToBounds:YES];
    [self.keboardContainerView addSubview:spaceBtn];
    [spaceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.height.mas_equalTo(keyHeight-5);
        make.right.equalTo(signSwitchBtn.mas_left).offset(-10);
        make.left.equalTo(numSwithBtn.mas_right).offset(10);
        make.bottom.equalTo(self.keboardContainerView).with.offset(-4);
    }];
    
    //大小写切换
    QUIButton *m_charBtn = [QUIButton buttonWithType:UIButtonTypeCustom];
    m_charBtn.layer.cornerRadius = 8;
    [m_charBtn setClipsToBounds:YES];
    [m_charBtn setImage:[UIImage imageWithContentsOfFile:[NTKeyboardPublicMethods getKaYiKaImageBundlePath:@"letter_upchar"]] forState:UIControlStateSelected];
    [m_charBtn setImage:[UIImage imageWithContentsOfFile:[NTKeyboardPublicMethods getKaYiKaImageBundlePath:@"letter_lowchar"]] forState:UIControlStateNormal];
    [m_charBtn setBackgroundImage:[self createImageWithColor:[UIColor colorWithRed:0.702 green:0.702 blue:0.702 alpha:1.00]] forState:UIControlStateNormal];
    [m_charBtn addTarget:self action:@selector(upAndLowerAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.keboardContainerView addSubview:m_charBtn];
    [m_charBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.height.mas_equalTo(keyHeight);
        make.width.mas_equalTo(39);
        make.left.equalTo(self.keboardContainerView).offset(15);
        make.bottom.equalTo(signSwitchBtn.mas_top).offset(-10);
        
    }];
    
    //删除按钮
    QUIButton *deleteBtn = [QUIButton buttonWithType:UIButtonTypeCustom];
    deleteBtn.layer.cornerRadius = 8;
    [deleteBtn setClipsToBounds:YES];
    [deleteBtn setImage:[UIImage imageWithContentsOfFile:[NTKeyboardPublicMethods getKaYiKaImageBundlePath:@"key_del"]] forState:UIControlStateNormal];
    [deleteBtn setBackgroundImage:[self createImageWithColor:[UIColor colorWithRed:0.702 green:0.702 blue:0.702 alpha:1.00]] forState:UIControlStateNormal];
    [deleteBtn addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.keboardContainerView addSubview:deleteBtn];
    [deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.height.mas_equalTo(keyHeight);
        make.width.mas_equalTo(39);
        make.right.equalTo(self.keboardContainerView).offset(-13);
        make.bottom.equalTo(signSwitchBtn.mas_top).offset(-10);
        
    }];
    
    
    //字母们
    NSInteger tagIndex = 10;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    for (int i = 0; i < 3; i++){
        switch (i) {
            case 0:
            {
                CGFloat space = 5;
                
                CGFloat numberKeyWidth = (screenWidth - space*11) / 10;
                
                for (int j = 0; j < 10; j++) {
                    
                    QUIButton *keyBtn = [QUIButton buttonWithType:UIButtonTypeCustom];
                    keyBtn.clipsToBounds = YES;
                    keyBtn.layer.cornerRadius = 8;
                    [keyBtn setBackgroundImage:[self createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
                    [keyBtn setTitleColor:QKB_TEXT_COLOR forState:UIControlStateNormal];
                    [keyBtn setTag:tagIndex];
                    [keyBtn.titleLabel setFont:[UIFont systemFontOfSize:25]];
                    [keyBtn addTarget:self action:@selector(btnSelectAction:) forControlEvents:UIControlEventTouchUpInside];
                    [self.keyBtnsAry addObject:keyBtn];
                    [self.keboardContainerView addSubview:keyBtn];
                    [keyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                        
                        make.width.mas_equalTo(numberKeyWidth);
                        make.height.mas_equalTo(keyHeight);
                        make.top.equalTo(self.keboardContainerView).with.offset(4);
                        make.left.equalTo(self.keboardContainerView).with.offset(5+j*(numberKeyWidth+5));
                        
                    }];
                    
                    tagIndex++;
                }
                break;
            }
                
            case 1:
            {
                CGFloat space = 5;
                CGFloat leftrightSpace = 20;
                
                CGFloat numberKeyWidth = (screenWidth -leftrightSpace*2 - space*8) / 9;
                
                for (int j = 0; j < 9; j++) {
                    QUIButton *keyBtn = [QUIButton buttonWithType:UIButtonTypeCustom];
                    keyBtn.clipsToBounds = YES;
                    keyBtn.layer.cornerRadius = 8;
                    [keyBtn setBackgroundImage:[self createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
                    [keyBtn setTitleColor:QKB_TEXT_COLOR forState:UIControlStateNormal];
                    [keyBtn setTag:tagIndex];
                    [keyBtn.titleLabel setFont:[UIFont systemFontOfSize:25]];
                    [keyBtn addTarget:self action:@selector(btnSelectAction:) forControlEvents:UIControlEventTouchUpInside];
                    [self.keyBtnsAry addObject:keyBtn];
                    [self.keboardContainerView addSubview:keyBtn];
                    [keyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                        
                        make.width.mas_equalTo(numberKeyWidth);
                        make.height.mas_equalTo(keyHeight);
                        make.top.equalTo(self.keboardContainerView).with.offset(4+keyHeight+10);
                        make.left.equalTo(self.keboardContainerView).with.offset(24+j*(numberKeyWidth+5));
                        
                    }];
                    
                    tagIndex++;
                    
                }
                break;
            }
                
            case 2:
            {
                CGFloat numberKeyWidth = (screenWidth - 13*2 -39*2 -5*2 - 4*6) / 7;
                
                for (int j = 0; j < 7; j++) {
                    
                    //初始化第三行
                    QUIButton *keyBtn = [QUIButton buttonWithType:UIButtonTypeCustom];
                    keyBtn.clipsToBounds = YES;
                    keyBtn.layer.cornerRadius = 8;
                    [keyBtn setBackgroundImage:[self createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
                    [keyBtn setTitleColor:QKB_TEXT_COLOR forState:UIControlStateNormal];
                    [keyBtn setTag:tagIndex];
                    [keyBtn addTarget:self action:@selector(btnSelectAction:) forControlEvents:UIControlEventTouchUpInside];
                    [keyBtn.titleLabel setFont:[UIFont systemFontOfSize:25]];
                    [self.keboardContainerView addSubview:keyBtn];
                    [keyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.width.mas_equalTo(numberKeyWidth);
                        make.height.mas_equalTo(keyHeight);
                        make.centerY.equalTo(m_charBtn);
                        make.left.equalTo(m_charBtn.mas_right).with.offset(5+j*(numberKeyWidth+4));
                    }];
                    
                    [self.keyBtnsAry addObject:keyBtn];
                    tagIndex++;
                }
                break;
            }
            default:
                break;
        }
        
    }
    
    //设置键
    NSMutableArray *lowSpchar = [[NSMutableArray alloc] initWithObjects:@"q",@"w",@"e",@"r",@"t",@"y",@"u",@"i",@"o",@"p",@"a",@"s",@"d",@"f",@"g",@"h",@"j",@"k",@"l",@"z",@"x",@"c",@"v",@"b",@"n",@"m", nil];
    
    if (self.letterRandom) {
        self.keyBtnTitlesAry = [NSMutableArray arrayWithArray:[NTKeyboardPublicMethods randomWithArray:lowSpchar]];
        
    }else{
        self.keyBtnTitlesAry = [NSMutableArray arrayWithArray:lowSpchar];
    }

    for (int i = 0; i < [self.keyBtnTitlesAry count]; i++) {
        if (i < [self.keyBtnsAry count]) {
            QUIButton *btn = [self.keyBtnsAry objectAtIndex:i];
            [btn setTitle:[self.keyBtnTitlesAry objectAtIndex:i] forState:UIControlStateNormal];
        }
    }
    
}

#pragma mark - 初始化符号键盘数据和符号键盘按钮
/**
 初始化符号键盘数据和符号键盘按钮
 */
- (void)signKeyBoradView{
    
    if (![NTKeyboardPublicMethods checkAuthorize]) {
        
        [NTKeyboardPublicMethods authorizeFail];
        return;
        
    }

    for (UIView *subView in self.keboardContainerView.subviews) {
        [subView removeFromSuperview];
    }
    
    [self.keboardContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        
        make.left.and.right.and.bottom.equalTo(self);
        make.top.equalTo(self.headerView.mas_bottom).with.offset(0);
    }];
    
    [self.keyBtnsAry removeAllObjects];
    
    //计算按键的高度
    CGFloat keyHeight = (self.frame.size.height - 44 - 4 - 6 - 10 *3 + 5)/4;
    
    
    //切换到字母键盘
    QUIButton *letterSwitchBtn = [QUIButton buttonWithType:UIButtonTypeCustom];
    letterSwitchBtn.clipsToBounds = YES;
    letterSwitchBtn.layer.cornerRadius = 8;
    [letterSwitchBtn setBackgroundImage:[self createImageWithColor:[UIColor colorWithRed:0.702 green:0.702 blue:0.702 alpha:1.00]] forState:UIControlStateNormal];
    [letterSwitchBtn setTitle:@"abc" forState:UIControlStateNormal];
    [letterSwitchBtn setTitleColor:QKB_TEXT_COLOR forState:UIControlStateNormal];
    [letterSwitchBtn addTarget:self action:@selector(changeToLetterKeyboard) forControlEvents:UIControlEventTouchUpInside];
    [self.keboardContainerView addSubview:letterSwitchBtn];
    [letterSwitchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.height.mas_equalTo(keyHeight-5);
        make.width.mas_equalTo(56);
        make.right.equalTo(self.keboardContainerView).with.offset(-12);
        make.bottom.equalTo(self.keboardContainerView).with.offset(-4);
    }];
    
    //切换数字键盘的按钮
    QUIButton *numSwithBtn = [QUIButton buttonWithType:UIButtonTypeCustom];
    numSwithBtn.clipsToBounds = YES;
    numSwithBtn.layer.cornerRadius = 8;
    [numSwithBtn setBackgroundImage:[self createImageWithColor:[UIColor colorWithRed:0.702 green:0.702 blue:0.702 alpha:1.00]] forState:UIControlStateNormal];
    [numSwithBtn setTitle:@"123" forState:UIControlStateNormal];
    [numSwithBtn addTarget:self action:@selector(changeToNumKeyboard) forControlEvents:UIControlEventTouchUpInside];
    [numSwithBtn setTitleColor:QKB_TEXT_COLOR forState:UIControlStateNormal];
    [self.keboardContainerView addSubview:numSwithBtn];
    [numSwithBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.height.mas_equalTo(keyHeight-5);
        make.width.mas_equalTo(56);
        make.left.equalTo(self.keboardContainerView).with.offset(12);
        make.bottom.equalTo(self.keboardContainerView).with.offset(-4);
        
    }];
    
    //空格
    QUIButton *spaceBtn = [QUIButton buttonWithType:UIButtonTypeCustom];
    spaceBtn.tag = 1014;
    UIImage *originImage = [UIImage qmui_imageWithStrokeColor:QKB_TEXT_COLOR size:CGSizeMake([UIScreen mainScreen].bounds.size.width/3, 10) lineWidth:2 borderPosition:QMUIImageBorderPositionLeft|QMUIImageBorderPositionRight|QMUIImageBorderPositionBottom];
    
    [spaceBtn setBackgroundImage:[self createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [spaceBtn setImage:originImage forState:UIControlStateNormal];
    spaceBtn.layer.cornerRadius = 8;
    [spaceBtn addTarget:self action:@selector(spaceAction:) forControlEvents:UIControlEventTouchUpInside];
    [spaceBtn setClipsToBounds:YES];
    [self.keboardContainerView addSubview:spaceBtn];
    [spaceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.height.mas_equalTo(keyHeight-5);
        make.right.equalTo(letterSwitchBtn.mas_left).offset(-10);
        make.left.equalTo(numSwithBtn.mas_right).offset(10);
        make.bottom.equalTo(self.keboardContainerView).with.offset(-4);
    }];
    
    //删除按钮
    QUIButton *deleteBtn = [QUIButton buttonWithType:UIButtonTypeCustom];
    deleteBtn.layer.cornerRadius = 8;
    [deleteBtn setClipsToBounds:YES];
    [deleteBtn addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
    [deleteBtn setImage:[UIImage imageWithContentsOfFile:[NTKeyboardPublicMethods getKaYiKaImageBundlePath:@"key_del"]] forState:UIControlStateNormal];
    [deleteBtn setBackgroundImage:[self createImageWithColor:[UIColor colorWithRed:0.702 green:0.702 blue:0.702 alpha:1.00]] forState:UIControlStateNormal];
    [self.keboardContainerView addSubview:deleteBtn];
    [deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.height.mas_equalTo(keyHeight);
        make.width.mas_equalTo(39);
        make.right.equalTo(self.keboardContainerView).offset(-15);
        make.bottom.equalTo(letterSwitchBtn.mas_top).offset(-10);
        
    }];
    
    
    //符号们
    NSInteger tagIndex = 10;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    for (int i = 0; i < 3; i++){
        switch (i) {
            case 0:
            {
                CGFloat space = 5;
                
                CGFloat numberKeyWidth = (screenWidth - space*11) / 10;
                
                for (int j = 0; j < 10; j++) {
                    
                    QUIButton *keyBtn = [QUIButton buttonWithType:UIButtonTypeCustom];
                    keyBtn.clipsToBounds = YES;
                    keyBtn.layer.cornerRadius = 8;
                    [keyBtn setBackgroundImage:[self createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
                    [keyBtn setTitleColor:QKB_TEXT_COLOR forState:UIControlStateNormal];
                    [keyBtn setTag:tagIndex];
                    [keyBtn.titleLabel setFont:[UIFont systemFontOfSize:25]];
                    [keyBtn addTarget:self action:@selector(btnSelectAction:) forControlEvents:UIControlEventTouchUpInside];
                    [self.keyBtnsAry addObject:keyBtn];
                    [self.keboardContainerView addSubview:keyBtn];
                    [keyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                        
                        make.width.mas_equalTo(numberKeyWidth);
                        make.height.mas_equalTo(keyHeight);
                        make.top.equalTo(self.keboardContainerView).with.offset(4);
                        make.left.equalTo(self.keboardContainerView).with.offset(5+j*(numberKeyWidth+5));
                        
                    }];
                    
                    tagIndex++;
                }
                break;
            }
                
            case 1:
            {
                CGFloat space = 5;
                
                CGFloat numberKeyWidth = (screenWidth - space*11) / 10;
                
                for (int j = 0; j < 10; j++) {
                    QUIButton *keyBtn = [QUIButton buttonWithType:UIButtonTypeCustom];
                    keyBtn.clipsToBounds = YES;
                    keyBtn.layer.cornerRadius = 8;
                    [keyBtn setBackgroundImage:[self createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
                    [keyBtn setTitleColor:QKB_TEXT_COLOR forState:UIControlStateNormal];
                    [keyBtn setTag:tagIndex];
                    [keyBtn.titleLabel setFont:[UIFont systemFontOfSize:25]];
                    [keyBtn addTarget:self action:@selector(btnSelectAction:) forControlEvents:UIControlEventTouchUpInside];
                    [self.keyBtnsAry addObject:keyBtn];
                    [self.keboardContainerView addSubview:keyBtn];
                    [keyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                        
                        make.width.mas_equalTo(numberKeyWidth);
                        make.height.mas_equalTo(keyHeight);
                        make.top.equalTo(self.keboardContainerView).with.offset(4+keyHeight+10);
                        make.left.equalTo(self.keboardContainerView).with.offset(5+j*(numberKeyWidth+5));
                        
                    }];
                    
                    tagIndex++;
                    
                }
                break;
            }
                
            case 2:
            {
                CGFloat numberKeyWidth = (screenWidth - 15 -36 -23 - 11 - 5*7) / 8;
                
                for (int j = 0; j < 8; j++) {
                    
                    //初始化第三行
                    QUIButton *keyBtn = [QUIButton buttonWithType:UIButtonTypeCustom];
                    keyBtn.clipsToBounds = YES;
                    keyBtn.layer.cornerRadius = 8;
                    [keyBtn setBackgroundImage:[self createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
                    [keyBtn setTitleColor:QKB_TEXT_COLOR forState:UIControlStateNormal];
                    [keyBtn setTag:tagIndex];
                    [keyBtn addTarget:self action:@selector(btnSelectAction:) forControlEvents:UIControlEventTouchUpInside];
                    [keyBtn.titleLabel setFont:[UIFont systemFontOfSize:25]];
                    [self.keboardContainerView addSubview:keyBtn];
                    [keyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.width.mas_equalTo(numberKeyWidth);
                        make.height.mas_equalTo(keyHeight);
                        make.centerY.equalTo(deleteBtn);
                        make.left.equalTo(self.keboardContainerView).with.offset(23+j*(numberKeyWidth+5));
                    }];
                    
                    [self.keyBtnsAry addObject:keyBtn];
                    tagIndex++;
                }
                break;
            }
                
            default:
                break;
        }
        
    }
    
    //设置键
    NSMutableArray *specialSpchar = [[NSMutableArray alloc] initWithObjects:@"[",@"]",@"{",@"}",@"#",@"%",@"^",@"*",@"+",@"=",@"_",@"\\", @"|",@"~",@"<",@">",@"€",@"£",@"¥",@".",@",",@"?",@"!",@"'",@"\"",@"`",@"&",@"@",nil];
    
    if (self.signRandom) {
        self.keyBtnTitlesAry = [NSMutableArray arrayWithArray:[NTKeyboardPublicMethods randomWithArray:specialSpchar]];

    }else{
        self.keyBtnTitlesAry = [NSMutableArray arrayWithArray:specialSpchar];
    }
    
    for (int i = 0; i < [self.keyBtnTitlesAry count]; i++) {
        if (i < [self.keyBtnsAry count]) {
            QUIButton *btn = [self.keyBtnsAry objectAtIndex:i];
            [btn setTitle:[self.keyBtnTitlesAry objectAtIndex:i] forState:UIControlStateNormal];
        }
    }
    
}

#pragma mark - 获取按键的值

/**
 切换大小写和数字和符号
 
 @param btn 按键
 */
-(void)upAndLowerAction:(QUIButton*)btn{
    
    if (![NTKeyboardPublicMethods checkAuthorize]) {
        
        [NTKeyboardPublicMethods authorizeFail];
        return;
        
    }

    if ([btn isSelected]) {
        
        NSMutableArray *lowSpchar = [[NSMutableArray alloc] initWithObjects:@"q",@"w",@"e",@"r",@"t",@"y",@"u",@"i",@"o",@"p",@"a",@"s",@"d",@"f",@"g",@"h",@"j",@"k",@"l",@"z",@"x",@"c",@"v",@"b",@"n",@"m", nil];
        
        if (self.letterRandom) {
            self.keyBtnTitlesAry = [NSMutableArray arrayWithArray:[NTKeyboardPublicMethods randomWithArray:lowSpchar]];
            
        }else{
            self.keyBtnTitlesAry = [NSMutableArray arrayWithArray:lowSpchar];
        }

        [btn setSelected:NO];
    }else{
        
        NSMutableArray *spchar = [[NSMutableArray alloc] initWithObjects:@"Q",@"W",@"E",@"R",@"T",@"Y",@"U",@"I",@"O",@"P",@"A",@"S",@"D",@"F",@"G",@"H",@"J",@"K",@"L",@"Z",@"X",@"C",@"V",@"B",@"N",@"M", nil];
        
        if (self.letterRandom) {
            self.keyBtnTitlesAry = [NSMutableArray arrayWithArray:[NTKeyboardPublicMethods randomWithArray:spchar]];
            
        }else{
            self.keyBtnTitlesAry = [NSMutableArray arrayWithArray:spchar];
        }

        [btn setSelected:YES];
    }
    
    for (int i = 0; i < [self.keyBtnTitlesAry count]; i++) {
        if (i < [self.keyBtnsAry count]) {
            QUIButton *btn = [self.keyBtnsAry objectAtIndex:i];
            [btn setTitle:[self.keyBtnTitlesAry objectAtIndex:i] forState:UIControlStateNormal];
        }
    }
}

/**
 切换到符号键盘
 */
-(void)changeToSignKeyboard{
    
    if (![NTKeyboardPublicMethods checkAuthorize]) {
        
        [NTKeyboardPublicMethods authorizeFail];
        return;
        
    }

    [self signKeyBoradView];
}

/**
 切换到字母键盘
 */
-(void)changeToLetterKeyboard{
    
    if (![NTKeyboardPublicMethods checkAuthorize]) {
        
        [NTKeyboardPublicMethods authorizeFail];
        return;
        
    }

    [self letterKeyBoradView];
}

/**
 切换到数字键盘
 */
-(void)changeToNumKeyboard{
    
    if (![NTKeyboardPublicMethods checkAuthorize]) {
        
        [NTKeyboardPublicMethods authorizeFail];
        return;
        
    }

    [self numberKeyBoradView];
}

/**
 获取按键的值
 
 @param btn 按键
 */
-(void)btnSelectAction:(QUIButton*)btn{
    
    if (![NTKeyboardPublicMethods checkAuthorize]) {
        
        [NTKeyboardPublicMethods authorizeFail];
        return;
        
    }

    NSString *keyValue = btn.titleLabel.text;
    
    NSLog(@"按键的值是: %@",keyValue);
    
    if (self.m_delegate != nil && [self.m_delegate respondsToSelector:@selector(didSelectKeyButton:)]) {
        [self.m_delegate didSelectKeyButton:keyValue];
    }
}

/**
 删除
 
 @param btn 按键
 */
-(void)deleteAction:(QUIButton*)btn{
    
    if (![NTKeyboardPublicMethods checkAuthorize]) {
        
        [NTKeyboardPublicMethods authorizeFail];
        return;
        
    }

    NSLog(@"删除");
    
    if (self.m_delegate != nil && [self.m_delegate respondsToSelector:@selector(didSelectDeleteButton)]) {
        [self.m_delegate didSelectDeleteButton];
    }
}

/**
 收起键盘
 
 @param btn 按键
 */
-(void)closeKeyboardAction:(QUIButton*)btn{
    
    if (![NTKeyboardPublicMethods checkAuthorize]) {
        
        [NTKeyboardPublicMethods authorizeFail];
        return;
        
    }

    [self.pop dismiss:YES];
    
    if (self.m_delegate != nil && [self.m_delegate respondsToSelector:@selector(didCloseKeyBoard)]) {
        [self.m_delegate didCloseKeyBoard];
    }
    
}


/**
 点击了空格
 
 @param btn 按键
 */
-(void)spaceAction:(QUIButton*)btn{
    
    NSLog(@"空格");
    
    if (![NTKeyboardPublicMethods checkAuthorize]) {
        
        [NTKeyboardPublicMethods authorizeFail];
        return;
        
    }
    
    if ([self.m_delegate respondsToSelector:@selector(didSelectSpaceButton)]) {
        [self.m_delegate didSelectSpaceButton];
    }
    
}

-(UIImage*) createImageWithColor:(UIColor*) color{
    
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

@end
