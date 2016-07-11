//
//  MailSendVC.h
//  mailcoreDemo
//
//  Created by ios－dai on 16/6/9.
//  Copyright © 2016年 ios－dai. All rights reserved.
//


typedef enum{
    MailSendDefault,  //默认写邮件
    MailSendFromDrafts,//草稿箱
    MailSendReply,      //回复
    MailSendReplyAll,           //回复全部
    MailSendForwarding,          //转发
    
} MailSendType;


#import <UIKit/UIKit.h>
#import "UITextField+WJ.h"

@interface MailSendVC : UIViewController<UITextFieldDelegate,WJTextFieldDelegate,UITextViewDelegate,UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstrant1;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstrant2;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heigthConstrant3;

@property (weak, nonatomic) IBOutlet UIView *view1;
@property (weak, nonatomic) IBOutlet UITextField *textFild1;
@property (weak, nonatomic) IBOutlet UIButton *addButton1;


@property (weak, nonatomic) IBOutlet UIView *view2;
@property (weak, nonatomic) IBOutlet UITextField *textFild2;
@property (weak, nonatomic) IBOutlet UIButton *addButton2;


@property (weak, nonatomic) IBOutlet UIView *view3;
@property (weak, nonatomic) IBOutlet UITextField *textFild3;
@property (weak, nonatomic) IBOutlet UIButton *addButton3;

@property (weak, nonatomic) IBOutlet UITextView *connectTextView;
@property (weak, nonatomic) IBOutlet UILabel *textViewLB;

@property (weak, nonatomic) IBOutlet UIButton *aadFileButton;
@property (weak, nonatomic) IBOutlet UILabel *fileLB;

@property (weak, nonatomic) IBOutlet UITextField *subjectTextFild;

@property (weak, nonatomic) IBOutlet UILabel *MideaConnectLB;

@property (weak, nonatomic) IBOutlet UILabel *subjectLB;
@property(nonatomic)MailSendType sendType ;  //草稿箱
@property (nonatomic, assign) uint32_t messageUid; //草稿箱id

@property(nonatomic,strong)NSDictionary *messageDict;//


@end
