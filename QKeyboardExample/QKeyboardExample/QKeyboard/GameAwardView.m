//
//  GameAwardView.m
//  dayanlive
//
//  Created by 古秀湖 on 2017/3/6.
//  Copyright © 2017年 dayanlive. All rights reserved.
//

#import "GameAwardView.h"
#import <YYText/YYText.h>
#import <Masonry.h>
#import "QMUIGridView.h"

@interface GiftView : UIView

@property (strong, nonatomic) UIImageView *giftImgView;
@property (strong, nonatomic) YYLabel *giftPriceLabel;
@property (strong, nonatomic) UILabel *jingyanLabel;
@property (strong, nonatomic) UIButton *button;

@property(nonatomic, copy) void (^didSelectGift)(NSInteger index);

@end

@interface GameAwardView ()

@property (strong, nonatomic) YYLabel *getLabel;

@property (strong, nonatomic) QMUIGridView *gridView;

@property NSInteger selectedGiftIndex;

@end

@implementation GameAwardView

- (instancetype)initWithFrame:(CGRect)frame andGetZuanshiCount:(NSInteger)zuanshicount{
    
    self = [super initWithFrame:CGRectMake(0, 0, 300, 380+45)];
    
    if (self) {
        
        [self buildViewWithCount:zuanshicount];
    }
    
    return self;
}

- (void)buildViewWithCount:(NSInteger)zuanshicount{
    
    //背景
    UIImageView *bgImgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"gw_mb_bg"]];
    [self addSubview:bgImgView];
    [bgImgView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.and.right.and.top.and.bottom.equalTo(self);
    }];
    
    //收益展示
    self.getLabel = [[YYLabel alloc]init];
    [self addSubview:self.getLabel];
    [self.getLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.and.right.equalTo(self);
        make.height.mas_equalTo(40);
        make.top.equalTo(self).with.offset(175);
    }];
    
    NSMutableAttributedString *text = [NSMutableAttributedString new];
    UIFont *font = [UIFont systemFontOfSize:16];
    {
        //钻石
        UIImage *image = [UIImage imageNamed:@"gw_Diamonds"];
        image = [UIImage imageWithCGImage:image.CGImage scale:2 orientation:UIImageOrientationUp];
        
        NSMutableAttributedString *attachText = [NSMutableAttributedString yy_attachmentStringWithContent:image contentMode:UIViewContentModeScaleAspectFill attachmentSize:CGSizeMake(39, 39) alignToFont:font alignment:YYTextVerticalAlignmentCenter];
        [text appendAttributedString:attachText];
        [text appendAttributedString:[[NSAttributedString alloc] initWithString:@"  " attributes:nil]];
    }
    {
        [text appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"+%d钻石",zuanshicount] attributes:nil]];
    }
    
    
    text.yy_font = font;
    self.getLabel.attributedText = text;
    self.getLabel.textVerticalAlignment = YYTextVerticalAlignmentCenter;
    self.getLabel.textAlignment = NSTextAlignmentCenter;
    self.getLabel.textColor = [UIColor colorWithRed:1.000 green:0.745 blue:0.004 alpha:1.00];
    
    //提示语
    UILabel *tipsLabel = [[UILabel alloc]init];
    [tipsLabel setText:@"打赏后运气更佳哦"];
    [tipsLabel setTextColor:[UIColor colorWithRed:0.200 green:0.200 blue:0.200 alpha:1.00]];
    [tipsLabel setFont:[UIFont systemFontOfSize:13]];
    [tipsLabel setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:tipsLabel];
    [tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.and.right.equalTo(self);
        make.height.mas_equalTo(15);
        make.top.equalTo(self.getLabel.mas_bottom).with.offset(30);
    }];
    
    //三个选项
    self.gridView = [[QMUIGridView alloc] init];
    self.gridView.columnCount = 3;
    self.gridView.rowHeight = 90;
    self.gridView.separatorWidth = [NTKeyboardPublicMethods pixelOne];
    self.gridView.separatorColor = [UIColor clearColor];
    self.gridView.separatorDashed = NO;
    [self addSubview:self.gridView];
    [self.gridView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(30);
        make.right.equalTo(self).with.offset(-40);
        make.height.mas_equalTo(92);
        make.top.equalTo(tipsLabel.mas_bottom).with.offset(10);
    }];
    
    // 将要布局的 item 以 addSubview: 的方式添加进去即可自动布局
    for (int i = 1; i <= 3; i++) {
        [self.gridView addSubview:[self generateButtonAtIndex:i]];
    }
    
    //关闭按钮
    UIImageView *closeBtnBgImgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"gw_Close"]];
    [self addSubview:closeBtnBgImgView];
    [closeBtnBgImgView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.centerX.equalTo(self);
        make.height.mas_equalTo(45);
        make.width.mas_equalTo(33);
        make.top.equalTo(self.mas_bottom);
    }];
    
    //确定按钮
    UIButton *sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [sureBtn setBackgroundImage:[UIImage imageNamed:@"gw_button"] forState:UIControlStateNormal];
    [sureBtn setTitle:@"打赏" forState:UIControlStateNormal];
    [sureBtn addTarget:self action:@selector(sureClick:) forControlEvents:UIControlEventTouchUpInside];
    [sureBtn setTintColor:[UIColor whiteColor]];
    sureBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [self addSubview:sureBtn];
    [sureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerX.equalTo(self);
        make.height.mas_equalTo(40);
        make.width.mas_equalTo(83);
        make.bottom.equalTo(closeBtnBgImgView.mas_top).with.offset(-15);
        
    }];
}

- (GiftView *)generateButtonAtIndex:(NSInteger)index{
    
    GiftView *giftView = [[GiftView alloc]init];
    giftView.tag = index;
    giftView.didSelectGift = ^(NSInteger tag){
      
        self.selectedGiftIndex = tag;
        
        for (UIView *tmpView in self.gridView.subviews) {
            if ([tmpView isKindOfClass:[GiftView class]]) {
                GiftView *git = (GiftView*)tmpView;
                if (git.tag != tag) {
                    [git.button setSelected:NO];
                }
            }
        }
    };
    
    if (index == 1) {
        [giftView.button setSelected:YES];
        self.selectedGiftIndex = 1;
        
        [giftView.giftImgView setImage:[UIImage imageNamed:@"gift_balloon"]];
        
        //价格
        NSMutableAttributedString *text = [NSMutableAttributedString new];
        UIFont *font = [UIFont systemFontOfSize:14];
        {
            [text appendAttributedString:[[NSAttributedString alloc] initWithString:@"8" attributes:nil]];
            [text appendAttributedString:[[NSAttributedString alloc] initWithString:@"  " attributes:nil]];
        }
        {
            //钻石
            UIImage *image = [UIImage imageNamed:@"game_price_diamonds"];
            image = [UIImage imageWithCGImage:image.CGImage scale:2 orientation:UIImageOrientationUp];
            
            NSMutableAttributedString *attachText = [NSMutableAttributedString yy_attachmentStringWithContent:image contentMode:UIViewContentModeScaleAspectFill attachmentSize:CGSizeMake(14, 14) alignToFont:font alignment:YYTextVerticalAlignmentCenter];
            [text appendAttributedString:attachText];
        }
        
        
        text.yy_font = font;
        giftView.giftPriceLabel.attributedText = text;
        giftView.giftPriceLabel.textVerticalAlignment = YYTextVerticalAlignmentCenter;
        giftView.giftPriceLabel.textAlignment = NSTextAlignmentCenter;
        giftView.giftPriceLabel.textColor = [UIColor colorWithRed:0.988 green:0.392 blue:0.137 alpha:1.00];
        
        //经验
        [giftView.jingyanLabel setText:@"+80点经验"];
    }else if (index == 2){
        
        [giftView.giftImgView setImage:[UIImage imageNamed:@"gift_banana"]];
        
        //价格
        NSMutableAttributedString *text = [NSMutableAttributedString new];
        UIFont *font = [UIFont systemFontOfSize:14];
        {
            [text appendAttributedString:[[NSAttributedString alloc] initWithString:@"6" attributes:nil]];
            [text appendAttributedString:[[NSAttributedString alloc] initWithString:@"  " attributes:nil]];
        }
        {
            //钻石
            UIImage *image = [UIImage imageNamed:@"game_price_diamonds"];
            image = [UIImage imageWithCGImage:image.CGImage scale:2 orientation:UIImageOrientationUp];
            
            NSMutableAttributedString *attachText = [NSMutableAttributedString yy_attachmentStringWithContent:image contentMode:UIViewContentModeScaleAspectFill attachmentSize:CGSizeMake(14, 14) alignToFont:font alignment:YYTextVerticalAlignmentCenter];
            [text appendAttributedString:attachText];
        }
        
        
        text.yy_font = font;
        giftView.giftPriceLabel.attributedText = text;
        giftView.giftPriceLabel.textVerticalAlignment = YYTextVerticalAlignmentCenter;
        giftView.giftPriceLabel.textAlignment = NSTextAlignmentCenter;
        giftView.giftPriceLabel.textColor = [UIColor colorWithRed:0.988 green:0.392 blue:0.137 alpha:1.00];
        
        //经验
        [giftView.jingyanLabel setText:@"+60点经验"];

    }else if (index == 3){
        [giftView.giftImgView setImage:[UIImage imageNamed:@"gift_Beer"]];
        
        //价格
        NSMutableAttributedString *text = [NSMutableAttributedString new];
        UIFont *font = [UIFont systemFontOfSize:14];
        {
            [text appendAttributedString:[[NSAttributedString alloc] initWithString:@"2" attributes:nil]];
            [text appendAttributedString:[[NSAttributedString alloc] initWithString:@"  " attributes:nil]];
        }
        {
            //钻石
            UIImage *image = [UIImage imageNamed:@"game_price_diamonds"];
            image = [UIImage imageWithCGImage:image.CGImage scale:2 orientation:UIImageOrientationUp];
            
            NSMutableAttributedString *attachText = [NSMutableAttributedString yy_attachmentStringWithContent:image contentMode:UIViewContentModeScaleAspectFill attachmentSize:CGSizeMake(14, 14) alignToFont:font alignment:YYTextVerticalAlignmentCenter];
            [text appendAttributedString:attachText];
        }
        
        
        text.yy_font = font;
        giftView.giftPriceLabel.attributedText = text;
        giftView.giftPriceLabel.textVerticalAlignment = YYTextVerticalAlignmentCenter;
        giftView.giftPriceLabel.textAlignment = NSTextAlignmentCenter;
        giftView.giftPriceLabel.textColor = [UIColor colorWithRed:0.988 green:0.392 blue:0.137 alpha:1.00];
        
        //经验
        [giftView.jingyanLabel setText:@"+20点经验"];

    }
    
    return giftView;
}


-(void)sureClick:(id)sender{
    
    NSLog(@"%d",self.selectedGiftIndex);
}

@end

@implementation GiftView

-(instancetype)init{
    
    self = [super init];
    if (self) {
        
        //礼物
        self.giftImgView = [[UIImageView alloc]init];
        [self.giftImgView setContentMode:UIViewContentModeCenter];
        [self addSubview:self.giftImgView];
        [self.giftImgView mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.left.and.right.and.top.equalTo(self);
            make.height.mas_equalTo(60);
        }];
        
        //价钱
        self.giftPriceLabel = [[YYLabel alloc]init];
        [self.giftPriceLabel setText:@"5"];
        [self.giftPriceLabel setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:self.giftPriceLabel];
        [self.giftPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.left.and.right.equalTo(self);
            make.height.mas_equalTo(15);
            make.top.equalTo(self.giftImgView.mas_bottom).with.offset(0);
        }];
        
        //经验
        self.jingyanLabel = [[UILabel alloc]init];
        [self.jingyanLabel setTextColor:[UIColor colorWithRed:0.463 green:0.475 blue:0.506 alpha:1.00]];
        [self.jingyanLabel setText:@"+500经验"];
        [self.jingyanLabel setTextAlignment:NSTextAlignmentCenter];
        [self.jingyanLabel setFont:[UIFont systemFontOfSize:13]];
        [self addSubview:self.jingyanLabel];
        [self.jingyanLabel mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.left.and.right.equalTo(self);
            make.height.mas_equalTo(15);
            make.top.equalTo(self.giftPriceLabel.mas_bottom).with.offset(2);
        }];
        
        //背景
        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.button setBackgroundImage:[[UIImage imageNamed:@"gw_gift_select_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10) resizingMode:UIImageResizingModeStretch] forState:UIControlStateSelected];
        [self addSubview:self.button];
        [self.button addTarget:self action:@selector(clickAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.button mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.left.and.right.and.top.and.bottom.equalTo(self);
        }];
    }
    
    return self;
}


-(void)clickAction:(UIButton*)btn{
    
    if (!btn.isSelected) {
        [btn setSelected:YES];
        
        if (self.didSelectGift) {
            self.didSelectGift(self.tag);
        }
    }
    
}

@end
