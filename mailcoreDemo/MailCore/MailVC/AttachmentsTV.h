//
//  AttachmentsTV.h
//  mailcoreDemo
//
//  Created by XuRuiBang on 16/6/21.
//  Copyright © 2016年 ios－dai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuickLook/QuickLook.h>

@interface AttachmentsTV : UITableView<UITableViewDelegate,UITableViewDataSource,QLPreviewControllerDelegate,QLPreviewControllerDataSource,QLPreviewItem>
@property(nonatomic,strong)NSMutableArray* attachmentsArray;
- (CGFloat)attachmentsHeight;
@end
