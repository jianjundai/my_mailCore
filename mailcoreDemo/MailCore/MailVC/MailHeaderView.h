//
//  MailHeaderView.h
//  mailcoreDemo
//
//  Created by ios－dai on 16/6/7.
//  Copyright © 2016年 ios－dai. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface MailHeaderView : UIView


@property(nonatomic,strong)UIButton *backButton;  //返回按钮
@property(nonatomic,retain)UIButton *allChoiceButton;  //全选按钮
@property(nonatomic,retain)UIButton *editButton;  //编辑取消

@property(nonatomic,retain)UIButton *middleButton;  //中间button
@property(nonatomic,retain)UIImageView *pointImageView;//中间的尖
@property(nonatomic,retain)UILabel *middleLB;

@property(nonatomic,retain)UIButton *sendButton;


@property(nonatomic,strong)UIButton *searchButton;//搜索


@end
