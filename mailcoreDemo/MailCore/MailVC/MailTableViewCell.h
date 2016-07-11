//
//  MailTableViewCell.h
//  mailcoreDemo
//
//  Created by XuRuiBang on 16/6/7.
//  Copyright © 2016年 ios－dai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"
#import <MailCore/MailCore.h>


@interface MailTableViewCell : SWTableViewCell
@property (weak, nonatomic) IBOutlet UIButton *imgBtn;
@property (weak, nonatomic) IBOutlet UIImageView *bulePoint;
@property (weak, nonatomic) IBOutlet UILabel *sourcelab;
@property (weak, nonatomic) IBOutlet UIImageView *mark;
@property (weak, nonatomic) IBOutlet UIImageView *redFlag;
@property (weak, nonatomic) IBOutlet UILabel *dateLab;
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UILabel *detailLab;
@property (weak, nonatomic) IBOutlet UIImageView *nextImg;
@end
