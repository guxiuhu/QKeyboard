//
//  ViewController.m
//  QKeyboardExample
//
//  Created by 古秀湖 on 2016/10/20.
//  Copyright © 2016年 南天. All rights reserved.
//

#import "ViewController.h"
#import "QKeyboard.h"
#import "GameAwardView.h"
#import <PopupKit.h>

@interface ViewController ()<QKeyBoardViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showKeyboard:)];
    [self.view setUserInteractionEnabled:YES];
    
    [self.view addGestureRecognizer:tap];
    
}

- (void)showKeyboard:(id)sender {
    
//    GameAwardView *award = [[GameAwardView alloc]initWithFrame:CGRectZero];
//    
//    PopupView *pop = [PopupView popupViewWithContentView:award];
//    [pop show];
//
//    return;
    
    QKeyboard *keyboard = [[QKeyboard alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 255) andKeyboardType:LETTER andLetterRandom:NO andSignRandom:NO andNumRandom:YES];
    [keyboard setM_delegate:self];

    [keyboard showPop];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
