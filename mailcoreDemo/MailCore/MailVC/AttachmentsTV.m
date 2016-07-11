//
//  AttachmentsTV.m
//  mailcoreDemo
//
//  Created by XuRuiBang on 16/6/21.
//  Copyright © 2016年 ios－dai. All rights reserved.
//

#import "AttachmentsTV.h"
#import "Masonry.h"

@implementation AttachmentsTV

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
//        self = (AttachmentsTV*)[[UITableView alloc]initWithFrame:frame style:UITableViewStylePlain];
        self.scrollEnabled = NO;
        self.separatorInset = UIEdgeInsetsMake(0, 15, 0, 15);
        self.delegate = self;
        self.dataSource = self;
        [self registerClass:[UITableViewCell class] forCellReuseIdentifier:@"attachments"];

    }
    return self;
}

- (CGFloat)attachmentsHeight{
    CGFloat cellHeight = 44;
    return  cellHeight*(_attachmentsArray.count + 1);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _attachmentsArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"attachments" forIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"attachments"];
    }
    [cell.imageView setImage:[UIImage imageNamed:@"mail_other_82"]];
    UILabel* textLab = [[UILabel alloc]init];
    textLab.text = _attachmentsArray[indexPath.row];
    textLab.font = [UIFont systemFontOfSize:13.0];
    [cell addSubview:textLab];
    [textLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(cell).offset(45);
        make.top.mas_equalTo(cell).offset(6);
        make.height.mas_equalTo(18);
    }];
    UILabel* detailLab = [[UILabel alloc]init];
    NSString *tmpDirectory =NSTemporaryDirectory();
    NSString *filePath=[tmpDirectory stringByAppendingPathComponent:_attachmentsArray[indexPath.row]];
    NSData* attachmentData = [NSData dataWithContentsOfFile:filePath];
    detailLab.text = [NSString stringWithFormat:@"%luB",attachmentData.length/1024];
    detailLab.font = [UIFont systemFontOfSize:13.0];
    [cell addSubview:detailLab];
    [detailLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(cell).offset(45);
        make.bottom.mas_equalTo(cell).offset(-6);
        make.height.mas_equalTo(16);
    }];
    UIButton* infoBtn = [[UIButton alloc]init];
    [infoBtn setImage:[UIImage imageNamed:@"mail_other_60"] forState:0];
    [cell addSubview:infoBtn];
    [infoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(cell).offset(-15);
        make.centerY.mas_equalTo(cell);
    }];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    QLPreviewController* qlPC = [[QLPreviewController alloc]init];
    qlPC.delegate = self;
    qlPC.dataSource = self;
    qlPC.title = _attachmentsArray[indexPath.row];
    [[self viewController].navigationController pushViewController:qlPC animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller{
    return 1;
}

- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index{
    NSString *tmpDirectory =NSTemporaryDirectory();
    NSString *filePath=[tmpDirectory stringByAppendingPathComponent:controller.title];
    return [NSURL fileURLWithPath:filePath];
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
    
@end
