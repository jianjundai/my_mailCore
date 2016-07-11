//
//  MailView.h
//  mailcoreDemo
//
//  Created by XuRuiBang on 16/6/7.
//  Copyright © 2016年 ios－dai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"
#import <MailCore/MailCore.h>

@interface MailView : UIView<UITableViewDelegate,UITableViewDataSource,SWTableViewCellDelegate>{
}

@property(nonatomic,strong) UITableView *mailTableView;
@property(nonatomic,strong) NSMutableArray* dataSourceArray;
@property (nonatomic, strong) MCOIMAPSession *imapSession;
@property (nonatomic) BOOL isEdit;
@property (nonatomic,strong) NSString* folder;//数据源文件夹
@property (nonatomic,strong) NSArray* btnArray;//编辑按钮
@property (nonatomic) BOOL isRedFlag;


- (void)chooseAllCell:(BOOL)isChoose;
- (void)popEditView;
- (void)exitEditView;
- (void)pullDatawithInt:(NSInteger)num;
@end
