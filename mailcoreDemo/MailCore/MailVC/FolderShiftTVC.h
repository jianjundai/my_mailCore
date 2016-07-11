//
//  FolderShiftTVC.h
//  mailcoreDemo
//
//  Created by XuRuiBang on 16/6/24.
//  Copyright © 2016年 ios－dai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MailDataObject.h"

@interface FolderShiftTVC : UITableViewController
@property (strong,nonatomic)NSString* sourceFolder;
@property (strong,nonatomic)MCOIndexSet* indexSet;
@end
