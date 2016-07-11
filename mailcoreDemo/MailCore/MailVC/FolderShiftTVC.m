//
//  FolderShiftTVC.m
//  mailcoreDemo
//
//  Created by XuRuiBang on 16/6/24.
//  Copyright © 2016年 ios－dai. All rights reserved.
//

#import "FolderShiftTVC.h"
#import "Masonry.h"
@interface FolderShiftTVC ()

@end

@implementation FolderShiftTVC{
    NSArray* labArray;
    NSArray* imgArray;
    NSArray* toArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = NO;
    self.title = @"选择邮箱";
    labArray = @[@"收件箱",@"草稿箱",@"已发送",@"已删除",@"垃圾邮件",@"病毒邮件",@"Archive"];
    imgArray = @[@"mail_nomal_01",@"mail_nomal_02",@"mail_nomal_03",@"mail_nomal_04",@"mail_nomal_05",@"mail_nomal_06",@"mail_nomal_07"];
    toArray = @[@"INBOX",@"Drafts",@"Sent Items",@"Trash",@"Junk E-mail",@"Virus Items",@"Archive"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"folder"];
    [self.tableView setSeparatorInset:UIEdgeInsetsMake(0,45,0,0)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 7;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"folder" forIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"folder"];
    }
    [cell.imageView setImage:[UIImage imageNamed:imgArray[indexPath.row]]];
    [cell.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(30, 30));
        make.centerY.mas_equalTo(cell);
        make.left.mas_equalTo(cell).offset(15);
    }];
    cell.textLabel.text = labArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    MailDataObject* mailHttp = [MailDataObject getInstance];
    [mailHttp moveFolderWithUid:_indexSet from:_sourceFolder to:toArray[indexPath.row] withBlock:^(NSError *error, NSDictionary *uidMapping) {
        if (!error) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
