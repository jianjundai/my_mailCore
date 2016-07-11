//
//  MailTableViewCell.m
//  mailcoreDemo
//
//  Created by XuRuiBang on 16/6/7.
//  Copyright © 2016年 ios－dai. All rights reserved.
//

#import "MailTableViewCell.h"

@interface MailTableViewCell()

@end

@implementation MailTableViewCell


- (void)awakeFromNib{
    _imgBtn.layer.masksToBounds = YES;
    _imgBtn.layer.cornerRadius = 20; //圆角
    _imgBtn.layer.borderWidth = 1;
    [_imgBtn setBackgroundColor:[UIColor whiteColor]];
    [_imgBtn setTitleColor:[UIColor colorWithRed:23/255.0 green:138/255.0 blue:218/255.0 alpha:1.0]  forState:UIControlStateNormal];
    _imgBtn.layer.borderColor = [[UIColor colorWithRed:23/255.0 green:138/255.0 blue:218/255.0 alpha:1.0] CGColor];
    
}

@end
