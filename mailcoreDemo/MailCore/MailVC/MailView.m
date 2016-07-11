//
//  MailView.m
//  mailcoreDemo
//
//  Created by XuRuiBang on 16/6/7.
//  Copyright © 2016年 ios－dai. All rights reserved.
//

#import "MailView.h"
#import "MailTableViewCell.h"
#import "MailDataObject.h"
#import "Masonry.h"
#import "MailMessageVC.h"
#import "MailDAO.h"
#import "MJRefresh.h"
#import "FolderShiftTVC.h"
#import "MailSendVC.h"
#import "SVProgressHUD.h"


#define Kscreenwidth [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height

@interface MailView ()
@property (strong,nonatomic)NSMutableDictionary* detailInfoDic;
@property (strong,nonatomic)NSMutableArray* chooseArr;

@end
@implementation MailView{
    BOOL isChooseAllCell;
    UIView* editview;
    NSInteger i;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        i = 0;
        _mailTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) style:UITableViewStylePlain];
        _mailTableView.delegate = self;
        _mailTableView.dataSource = self;
        [self addSubview:_mailTableView];
        
        editview = [[UIView alloc]init];
        CGRect rect = CGRectMake(0,kScreenHeight, Kscreenwidth, 50);
        [editview setFrame:rect];
        [editview setBackgroundColor:[UIColor colorWithRed:248/255.0 green:248/255.0 blue:248/255.0 alpha:1.0]];
        [self addSubview:editview];
        
        _detailInfoDic = [NSMutableDictionary dictionary];
        _chooseArr = [NSMutableArray array];
        
        _mailTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [self pullDatawithInt:i];
        }];
        _mailTableView.mj_footer = [MJRefreshAutoFooter footerWithRefreshingBlock:^{
            i++;
            [self pullDatawithInt:i];
        }];
    }
    return self;
}

- (UIViewController*)viewController {
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController*)nextResponder;
        }
    }
    return nil;
}

//- (void)pullData{
//    MailDataObject* mailCtrl = [MailDataObject getInstance];
//    
//    [mailCtrl loadLastNMessages:10 andCompletionBlock:^(NSError * _Nullable error, NSArray * _Nullable messages, MCOIndexSet * _Nullable vanishedMessages) {
//        _dataSourceArray = [NSMutableArray arrayWithArray:messages];
//        [_mailTableView reloadData];
//    }];
//    
//}

- (void)pullDatawithInt:(NSInteger)num{
//    [self readDataBase];
    
    MailDataObject* mailCtrl = [MailDataObject getInstance];
    NSString *myEmail=mailCtrl.userName;
    NSString *_passwordCopy=mailCtrl.passWord;
    [mailCtrl loadAccountWithUsername:myEmail password:_passwordCopy oauth2Token:nil andErrorBlock:^(NSError *error) {
        if (!error) {
            [mailCtrl loadLastNMessages:num withFolder:_folder andCompletionBlock:^(NSError * _Nullable error, NSArray * _Nullable messages, MCOIndexSet * _Nullable vanishedMessages) {
                    _dataSourceArray = [NSMutableArray arrayWithArray:messages];
                    if (_isRedFlag) {
                        [mailCtrl getRedFlagMessage:_dataSourceArray withBlock:^(NSArray *arr) {
                            _dataSourceArray = [NSMutableArray arrayWithArray:arr];
                            [_mailTableView reloadData];
                        }];
                    }
                    if (_btnArray.count != 0) {
                        [self setEditViewWith:_btnArray];
                    }
//                    MailDAO* mailDAO = [MailDAO sharedManager];
//                    MailModel* mailModel = [[MailModel alloc]init];
//                    for (MCOIMAPMessage* message in _dataSourceArray) {
//                        mailModel.username = myEmail;
//                        mailModel.uid = [NSNumber numberWithInt:message.uid];
//                        mailModel.flags = [NSNumber numberWithInt:message.flags];
//                        mailModel.displayName = message.header.from.displayName;
//                        mailModel.date = message.header.date;
//                        mailModel.subject = message.header.subject;
//                        mailModel.body = @"";
//                        [mailDAO create:mailModel];
//                    }
                    [_mailTableView reloadData];
                    [_mailTableView.mj_header endRefreshing];
                    [_mailTableView.mj_footer endRefreshing];

                
            }];
        }
    }];
}

//- (void)readDataBase{
//    MailDAO* mailDAO = [MailDAO sharedManager];
//    MailModel* mailModel = [[MailModel alloc]init];
//    mailModel = [mailDAO findById:@"ruibang.xu@midea.com.cn"];
//    NSLog(@"%@",mailModel);
//}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataSourceArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 86;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MCOIMAPMessage* message = _dataSourceArray[indexPath.row];
    static NSString *cellIdentifier = @"MailTableViewCell";
    MailTableViewCell *cell = (MailTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"MailTableViewCell" owner:nil options:nil][0];
    }
    
    if ([_chooseArr containsObject:[NSString stringWithFormat:@"%u",message.uid]]) {
        cell.backgroundColor = [UIColor colorWithRed:230/255.0 green:243/255.0 blue:250/255.0 alpha:1.0];
    }else{
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    [cell.imgBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(cell.contentView).offset(10);
        make.left.mas_equalTo(cell.contentView).offset(10);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    [cell.bulePoint mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(cell.contentView).offset(10);
        make.left.mas_equalTo(cell.imgBtn.mas_right).offset(9);
        make.size.mas_equalTo(CGSizeMake(9, 9));
    }];
    [cell.sourcelab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(cell.bulePoint.mas_centerY);
        make.height.mas_equalTo(20);
        make.width.mas_lessThanOrEqualTo(150);
        if (message.flags&1<<0) {
            make.left.mas_equalTo(cell.imgBtn.mas_right).offset(9);
        }else{
            make.left.mas_equalTo(cell.bulePoint.mas_right).offset(7);
        }
    }];
    [cell.mark mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(cell.sourcelab.mas_centerY);
        make.left.mas_equalTo(cell.sourcelab.mas_right);
        make.size.mas_equalTo(CGSizeMake(16, 16));
    }];
    [cell.nextImg mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(cell.mas_centerY);
        make.right.mas_equalTo(cell.contentView).offset(-5);
        make.size.mas_equalTo(CGSizeMake(10, 21));
    }];
    [cell.dateLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(cell.contentView).offset(-22);
        make.centerY.mas_equalTo(cell.sourcelab);
        make.size.mas_equalTo(CGSizeMake(60, 20));
    }];
    [cell.redFlag mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(cell.dateLab.mas_left).offset(-5);
        make.centerY.mas_equalTo(cell.dateLab);
        make.size.mas_equalTo(CGSizeMake(16, 16));
    }];
    [cell.titleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(cell.dateLab.mas_bottom).offset(2);
        make.left.mas_equalTo(cell.imgBtn.mas_right).offset(9);
        make.right.mas_equalTo(cell.nextImg.mas_left).offset(-13);
        make.height.mas_equalTo(20);
    }];
    [cell.detailLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(cell.titleLab.mas_bottom).offset(0);
        make.left.mas_equalTo(cell.titleLab).offset(0);
        make.right.mas_equalTo(cell.contentView).offset(-23);
        make.bottom.mas_equalTo(cell.contentView);
    }];
    
    NSString* bulePointStr = @"";
    NSString* redflagStr = @"";
    if (message.flags&1<<0) {
        [cell.bulePoint setHidden:YES];
        bulePointStr = @"标为未读";
    }else{
        [cell.bulePoint setHidden:NO];
        bulePointStr = @"标为已读";
    }
    if (message.flags&1<<2) {
        [cell.redFlag setHidden:NO];
        redflagStr = @"取消红旗";
    }else{
        [cell.redFlag setHidden:YES];
        redflagStr = @"标为红旗";
    }
    if (message.attachments.count) {
        [cell.mark setHidden:NO];
    }else{
        [cell.mark setHidden:YES];
    }
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:187/255.0 green:188/255.0 blue:189/255.0 alpha:1.0]
                                                title:bulePointStr];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:208/255.0 green:208/255.0 blue:207/255.0 alpha:1.0]
                                                title:redflagStr];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:234/255.0 green:81/255.0 blue:62/255.0 alpha:1.0f]
                                                title:@"删除"];
    cell.rightUtilityButtons = rightUtilityButtons;
    
    cell.delegate = self;
    NSString* fromStr = message.header.from.displayName;
    if (!fromStr.length) {
        fromStr = message.header.from.mailbox;
    }
    [cell.imgBtn setTitle:[fromStr substringToIndex:1] forState:0];
    cell.sourcelab.text = fromStr;
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];//yyyy-MM-dd HH:mm:ss
    NSString* date1 = [dateFormatter stringFromDate:[NSDate date]];
    NSString* date2 = [dateFormatter stringFromDate:message.header.date];
    if ([date1 isEqualToString:date2]) {
        [dateFormatter setDateFormat:@"HH:mm"];
    } else {
        [dateFormatter setDateFormat:@"MM月dd日"];
    }
    cell.dateLab.text = [dateFormatter stringFromDate:message.header.date];
    
    cell.titleLab.text = message.header.subject;
    
    NSString* uidStr = [NSString stringWithFormat:@"%u",message.uid];
    if ([_detailInfoDic valueForKey:uidStr]) {
        cell.detailLab.text = [_detailInfoDic valueForKey:uidStr];
    } else {
        MCOIMAPMessageRenderingOperation * messageRenderingOperation=[[MailDataObject getInstance].imapSession plainTextBodyRenderingOperationWithMessage:message folder:@"INBOX"];
        [messageRenderingOperation start:^(NSString * plainTextBodyString, NSError * error) {
            cell.detailLab.text = plainTextBodyString;
            //字典缓存
            [_detailInfoDic setValue:plainTextBodyString forKey:uidStr];
        }];
    }
  
    return cell;
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index{
    [SVProgressHUD show];
    NSIndexPath *cellIndexPath = [self.mailTableView indexPathForCell:cell];
    MCOIMAPMessage* message = _dataSourceArray[cellIndexPath.row];
    MCOIndexSet* set = [MCOIndexSet indexSetWithIndex:message.uid];
    MailDataObject* mailCtrl = [MailDataObject getInstance];
    switch (index) {
        case 0:{
            if (message.flags&MCOMessageFlagSeen) {
                [mailCtrl updateFlags:MCOMessageFlagSeen isAdd:NO withUid:set inFolder:_folder withBlock:^(NSError *error) {
                    [self pullDatawithInt:i];
                }];
            } else {
                [mailCtrl updateFlags:MCOMessageFlagSeen isAdd:YES withUid:set inFolder:_folder withBlock:^(NSError *error) {
                    [self pullDatawithInt:i];
                }];
            }
        }
            break;
        case 1:{
            if (message.flags&MCOMessageFlagFlagged) {
                [mailCtrl updateFlags:MCOMessageFlagFlagged isAdd:NO withUid:set inFolder:_folder withBlock:^(NSError *error) {
                    [self pullDatawithInt:i];
                }];
            }else{
                [mailCtrl updateFlags:MCOMessageFlagFlagged isAdd:YES withUid:set inFolder:_folder withBlock:^(NSError *error) {
                    [self pullDatawithInt:i];
                }];
            }
        }
            break;
        case 2:{
            [mailCtrl updateFlags:MCOMessageFlagDeleted isAdd:YES withUid:set inFolder:_folder withBlock:^(NSError *error) {
                [self pullDatawithInt:i];
            }];
        }
            break;
        default:
            break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    MailTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selected = NO;
    MCOIMAPMessage* message = _dataSourceArray[indexPath.row];
    if (_isEdit) {
        NSString* uidStr = [NSString stringWithFormat:@"%u",message.uid];
        if ([_chooseArr containsObject:uidStr]) {
            [_chooseArr removeObject:uidStr];
            cell.backgroundColor = [UIColor whiteColor];
        } else {
            [_chooseArr addObject:uidStr];
            cell.backgroundColor = [UIColor colorWithRed:230/255.0 green:243/255.0 blue:250/255.0 alpha:1.0];
        }
    }else{
        // detail message
        if([_folder isEqual:Drafts]){
            MailSendVC *sendVc=[[MailSendVC alloc]init];
            sendVc.sendType=MailSendFromDrafts;;
            sendVc.messageUid=message.uid;
            UINavigationController *nav=[[UINavigationController alloc]initWithRootViewController:sendVc];
            [[self viewController] presentViewController:nav animated:YES completion:nil];
            
        }else{
            
            [SVProgressHUD showWithStatus:@"加载中..."];
            [[MailDataObject getInstance]getDetailMessageHtmlWithUid:message.uid  withFolder:_folder with:^(NSMutableDictionary *msgDic) {
                NSLog(@"msee==%@",[msgDic objectForKey:@"message"]);
                MailMessageVC* messageVC = [[MailMessageVC alloc]init];
                messageVC.messageDic = msgDic;
                messageVC.folder = _folder;
                [SVProgressHUD dismiss];
                UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
                [[self viewController].navigationItem setBackBarButtonItem:backItem];
                [[self viewController].navigationController pushViewController:messageVC animated:YES];
            }];
 
        }
    
          }
}

- (void)chooseAllCell:(BOOL)isChoose{
    if (isChoose) {
        for (MCOIMAPMessage* message in _dataSourceArray) {
            NSString* uid = [NSString stringWithFormat:@"%u",message.uid];
            [_chooseArr addObject:uid];
        }
        _chooseArr = [NSMutableArray arrayWithArray:[[NSSet setWithArray:_chooseArr] allObjects]];
        
    } else {
        _chooseArr = [NSMutableArray array];
        
    }
    [_mailTableView reloadData];
}

#pragma mark -

- (void)setEditViewWith:(NSArray*)array{
    for (UIView* view in editview.subviews) {
        [view removeFromSuperview];
    }
    if (array.count == 2) {
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGColorRef colorref = CGColorCreate(colorSpace,(CGFloat[]){216/255.0,216/255.0,216/255.0,1});
        UIButton* btn1 = [[UIButton alloc]init];
        [btn1 setTitle:array[0] forState:0];
        [btn1 setTitleColor:[UIColor colorWithRed:116/255.0 green:116/255.0 blue:116/255.0 alpha:1.0] forState:0];
        [btn1.layer setCornerRadius:2];
        [btn1.layer setBorderWidth:1.0];
        [btn1.layer setBorderColor:colorref];
        btn1.titleLabel.font = [UIFont systemFontOfSize:13];
        UIButton* btn2 = [[UIButton alloc]init];
        [btn2 setTitle:array[1] forState:0];
        [btn2 setTitleColor:[UIColor colorWithRed:216/255.0 green:216/255.0 blue:216/255.0 alpha:1.0] forState:0];
        [btn2.layer setCornerRadius:2];
        [btn2.layer setBorderWidth:1.0];
        [btn2.layer setBorderColor:colorref];
        btn2.titleLabel.font = [UIFont systemFontOfSize:13];
        [btn2 setBackgroundColor:[UIColor colorWithRed:236/255.0 green:80/255.0 blue:62/255.0 alpha:1.0]];
        [editview addSubview:btn1];
        [editview addSubview:btn2];
        [btn1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(editview);
            make.height.mas_equalTo(30);
            make.left.mas_equalTo(editview).offset(20);
            make.width.mas_equalTo(94);
        }];
        [btn2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(editview);
            make.height.mas_equalTo(30);
            make.right.mas_equalTo(editview).offset(-20);
            make.width.mas_equalTo(94);
        }];
        [btn1 addTarget:self action:@selector(clickEditViewButton:) forControlEvents:UIControlEventTouchUpInside];
        [btn2 addTarget:self action:@selector(clickEditViewButton:) forControlEvents:UIControlEventTouchUpInside];
    }else if (array.count == 3){
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGColorRef colorref = CGColorCreate(colorSpace,(CGFloat[]){216/255.0,216/255.0,216/255.0,1});
        UIButton* btn1 = [[UIButton alloc]init];
        [btn1 setTitle:array[0] forState:0];
        [btn1 setTitleColor:[UIColor colorWithRed:116/255.0 green:116/255.0 blue:116/255.0 alpha:1.0] forState:0];
        [btn1.layer setCornerRadius:2];
        [btn1.layer setBorderWidth:1.0];
        [btn1.layer setBorderColor:colorref];
        btn1.titleLabel.font = [UIFont systemFontOfSize:13];

        UIButton* btn2 = [[UIButton alloc]init];
        [btn2 setTitle:array[1] forState:0];
        [btn2 setTitleColor:[UIColor colorWithRed:116/255.0 green:116/255.0 blue:116/255.0 alpha:1.0] forState:0];
        [btn2.layer setCornerRadius:2];
        [btn2.layer setBorderWidth:1.0];
        [btn2.layer setBorderColor:colorref];
        btn2.titleLabel.font = [UIFont systemFontOfSize:13];

        UIButton* btn3 = [[UIButton alloc]init];
        [btn3 setTitle:array[2] forState:0];
        [btn3 setTitleColor:[UIColor colorWithRed:216/255.0 green:216/255.0 blue:216/255.0 alpha:1.0] forState:0];
        [btn3.layer setCornerRadius:2];
        [btn3.layer setBorderWidth:1.0];
        [btn3.layer setBorderColor:colorref];
        [btn3 setBackgroundColor:[UIColor colorWithRed:236/255.0 green:80/255.0 blue:62/255.0 alpha:1.0]];
        btn3.titleLabel.font = [UIFont systemFontOfSize:13];

        [editview addSubview:btn1];
        [editview addSubview:btn2];
        [editview addSubview:btn3];
        [btn1 addTarget:self action:@selector(clickEditViewButton:) forControlEvents:UIControlEventTouchUpInside];
        [btn2 addTarget:self action:@selector(clickEditViewButton:) forControlEvents:UIControlEventTouchUpInside];
        [btn3 addTarget:self action:@selector(clickEditViewButton:) forControlEvents:UIControlEventTouchUpInside];

        [btn1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(editview);
            make.height.mas_equalTo(30);
            make.left.mas_equalTo(editview).offset(8);
            make.width.mas_equalTo(94);
        }];
        [btn2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(editview);
            make.height.mas_equalTo(30);
            make.centerX.mas_equalTo(editview);
            make.width.mas_equalTo(94);
        }];
        [btn3 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(editview);
            make.height.mas_equalTo(30);
            make.right.mas_equalTo(editview).offset(-8);
            make.width.mas_equalTo(94);
        }];
        
    }
    
}

- (void)popEditView{
    [UIView animateWithDuration:0.5 animations:^{
        _mailTableView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - 50);
        editview.frame = CGRectMake(0,self.frame.size.height - 50, self.frame.size.width, 50);
    }];
}

- (void)exitEditView{
    [UIView animateWithDuration:0.5 animations:^{
        _mailTableView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        editview.frame = CGRectMake(0,self.frame.size.height, self.frame.size.width, 50);
    }];
    _chooseArr = [NSMutableArray array];
}

- (void)clickEditViewButton:(UIButton*)btn{
    if ([btn.titleLabel.text isEqualToString:@"标记"]) {
        [self markEditView];
    }
    if ([btn.titleLabel.text isEqualToString:@"移动至"]) {
        [self moveEditView];
    }
    if ([btn.titleLabel.text isEqualToString:@"删除"]) {
        [self deleteEditView];
    }
    if ([btn.titleLabel.text isEqualToString:@"彻底删除"]) {
        [self completeDeleteEditView];
    }
    
}

- (void)markEditView{
    //标记
    if (!_chooseArr.count) {
        //请选择邮件！
        [SVProgressHUD showWithStatus:@"请选择邮件！"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    } else {
        MCOIndexSet* set = [MCOIndexSet indexSet];
        for (NSString* uid in _chooseArr) {
            [set addIndex:[uid intValue]];
        }
        MailDataObject* mailCtrl = [MailDataObject getInstance];
        
        UIAlertController* alt = [UIAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
        [alt addAction:[UIAlertAction actionWithTitle:@"标记已读" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [SVProgressHUD show];
            [mailCtrl updateFlags:MCOMessageFlagSeen isAdd:YES withUid:set inFolder:_folder withBlock:^(NSError *error) {
                [self pullDatawithInt:i];
            }];
        }]];
        [alt addAction:[UIAlertAction actionWithTitle:@"标记未读" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [SVProgressHUD show];
            [mailCtrl updateFlags:MCOMessageFlagSeen isAdd:NO withUid:set inFolder:_folder withBlock:^(NSError *error) {
                [self pullDatawithInt:i];
            }];
        }]];
        [alt addAction:[UIAlertAction actionWithTitle:@"标记红旗" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [SVProgressHUD show];
            [mailCtrl updateFlags:MCOMessageFlagFlagged isAdd:YES withUid:set inFolder:_folder withBlock:^(NSError *error) {
                [self pullDatawithInt:i];
            }];
        }]];
        [alt addAction:[UIAlertAction actionWithTitle:@"取消红旗" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [SVProgressHUD show];
            [mailCtrl updateFlags:MCOMessageFlagFlagged isAdd:NO withUid:set inFolder:_folder withBlock:^(NSError *error) {
                [self pullDatawithInt:i];
            }];
        }]];
        [alt addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [[self viewController]presentViewController:alt animated:YES completion:nil];
    }
    
    

}

- (void)moveEditView{
    if (!_chooseArr.count) {
        //请选择邮件！
        [SVProgressHUD showWithStatus:@"请选择邮件！"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
        return;
    }
    //移动至
    MCOIndexSet* set = [MCOIndexSet indexSet];
    for (NSString* uid in _chooseArr) {
        [set addIndex:[uid intValue]];
    }
    FolderShiftTVC* folderTVC = [[FolderShiftTVC alloc]init];
    folderTVC.sourceFolder = _folder;
    folderTVC.indexSet = set;
    [[self viewController].navigationController pushViewController:folderTVC animated:YES];
}

- (void)deleteEditView{
    if (!_chooseArr.count) {
        //请选择邮件！
        [SVProgressHUD showWithStatus:@"请选择邮件！"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
        return;
    }
    //删除
    [SVProgressHUD show];
    MCOIndexSet* set = [MCOIndexSet indexSet];
    for (NSString* uid in _chooseArr) {
        [set addIndex:[uid intValue]];
    }
    MailDataObject* mailCtrl = [MailDataObject getInstance];
    [mailCtrl updateFlags:MCOMessageFlagDeleted isAdd:YES withUid:set inFolder:_folder withBlock:^(NSError *error) {
        [self pullDatawithInt:i];
    }];
    
}

- (void)completeDeleteEditView{
    if (!_chooseArr.count) {
        //请选择邮件！
        [SVProgressHUD showWithStatus:@"请选择邮件！"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
        return;
    }
    //彻底删除
    MCOIndexSet* set = [MCOIndexSet indexSet];
    for (NSString* uid in _chooseArr) {
        [set addIndex:[uid intValue]];
    }
    MailDataObject* mailCtrl = [MailDataObject getInstance];
    [mailCtrl updateFlags:MCOMessageFlagDeleted isAdd:YES withUid:set inFolder:_folder withBlock:^(NSError *error) {
        [self pullDatawithInt:i];
    }];
}


@end
