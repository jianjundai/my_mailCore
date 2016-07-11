//
//  MailHomeVC.h
//  Midea-connect
//
//  Created by ios－dai on 16/6/6.
//  Copyright © 2016年 Midea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MailHeaderView.h"
#import "MailView.h"
@interface MailHomeVC : UIViewController<UIAlertViewDelegate>
{
    NSArray *showTitleArray;
}

@property(nonatomic,retain)MailHeaderView *headerView;//头部
@property(nonatomic,retain)MailView *mailTableView ; //邮件表格

@property(nonatomic,retain)UIView *showView;
@property(nonatomic,retain)UIView *showBGView;
@property(nonatomic)BOOL isShow;//展示所有邮件


@property(nonatomic)BOOL isEdit;//是否正在编辑

@property(nonatomic)BOOL isFromMidea;

@end
