//
//  SendSearchView.h
//  mailcoreDemo
//
//  Created by ios－dai on 16/6/24.
//  Copyright © 2016年 ios－dai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactsModel.h"
@protocol SendSearchViewDelegate <NSObject>
-(void)SelectTextFild:(UITextField*)textFild andModel:(ContactsModel*)oneModel;

-(void)cancelSelect:(UITextField*)textFild andText:(NSString*)textString;

@end


@interface SendSearchView : UIView<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
@property (nonatomic, weak) id<SendSearchViewDelegate>delegate;
@property(nonatomic,strong)UITextField *currTextFild;  //当前的TextFild：收件人／抄送／密送


@property(nonatomic,retain)NSMutableArray *searchRusltArray;

@property(nonatomic,retain)UILabel *serchLB;
@property(nonatomic,retain)UITextField *searchTextFild;
@property(nonatomic,retain)UIButton *seatchAddButton;

@property(nonatomic,retain)UITableView *searchTableView;

-(void)reloadDataTableViewBy:(NSString*)textStr;



@end
