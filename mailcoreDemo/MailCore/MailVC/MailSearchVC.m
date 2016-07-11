//
//  MailSearchVC.m
//  mailcoreDemo
//
//  Created by XuRuiBang on 16/6/16.
//  Copyright © 2016年 ios－dai. All rights reserved.
//

#import "MailSearchVC.h"
#import "MailDataObject.h"
#import "MailView.h"
#import "MailTableViewCell.h"
#import "Masonry.h"

@interface MailSearchVC ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *mSearchBar;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UISegmentedControl *mSegment;
@property (weak, nonatomic) IBOutlet UITableView *mTableView;
@property (strong,nonatomic)NSMutableDictionary* detailInfoDic;

@end

@implementation MailSearchVC{
    NSMutableArray* dataSourceArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setHidden:YES];
    
    [_cancelBtn addTarget:self action:@selector(cancelBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_mSegment addTarget:self action:@selector(segmentClick:) forControlEvents:UIControlEventValueChanged];
    _mTableView.delegate = self;
    _mTableView.dataSource = self;
    _mSearchBar.delegate = self;
    _detailInfoDic = [NSMutableDictionary dictionary];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)cancelBtnClick:(UIButton*)btn{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)segmentClick:(UISegmentedControl*)segment{
    [self searchMessage];
    [_mSearchBar resignFirstResponder];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    [self searchMessage];
    [searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self searchMessage];
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
}

- (void)searchMessage{
    MailDataObject* mailHttp = [MailDataObject getInstance];
    [mailHttp searchMailWithString:_mSearchBar.text withKind:_mSegment.selectedSegmentIndex with:^(NSError * _Nullable error, MCOIndexSet *searchResult) {
        MailDataObject* mailHttp = [MailDataObject getInstance];
        [mailHttp searchMessages:searchResult withFolder:@"INBOX" andCompletionBlock:^(NSError * _Nullable error, NSArray * _Nullable messages, MCOIndexSet * _Nullable vanishedMessages) {
            dataSourceArray = [NSMutableArray arrayWithArray:messages];
            [_mTableView reloadData];
        }];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataSourceArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 86;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MCOIMAPMessage* message = dataSourceArray[indexPath.row];
    static NSString *cellIdentifier = @"MailTableViewCell";
    MailTableViewCell *cell = (MailTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"MailTableViewCell" owner:nil options:nil][0];
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
    [cell.imgBtn setTitle:[message.header.from.displayName substringToIndex:1] forState:0];
    cell.sourcelab.text = message.header.from.displayName;
    
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





@end
