//
//  MailHomeVC.m
//  Midea-connect
//原生邮箱
//  Created by ios－dai on 16/6/6.
//  Copyright © 2016年 Midea. All rights reserved.
//
#define Kscreenwidth [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height

#define NUMBER_OF_MESSAGES_TO_LOAD		10
#define ShowButtonTag  100
#define ShowLabelTag  200

#define Blue_Color [UIColor colorWithRed:2/255.0 green:136/255.0 blue:221/255.0 alpha:1.0]
#define Gray_Color [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0]



#import "MailHomeVC.h"
#import <MailCore/MailCore.h>
#import "MailDataObject.h"
#import "MailSendVC.h"
#import "MailSearchVC.h"
#import "SVProgressHUD.h"
//#import <Ry.h>
//#import "MainUtils.h"

@interface MailHomeVC ()

@property (nonatomic, strong) MCOIMAPOperation *imapCheckOp;
@property (nonatomic, strong) MCOIMAPSession *imapSession;
@property (nonatomic, strong) MCOIMAPFetchMessagesOperation *imapMessagesFetchOp;


@property (nonatomic, strong) NSArray *messages;
@property (nonatomic) NSInteger totalNumberOfInboxMessages;


//@property (nonatomic,strong) Zilla *zillaSDK;
@end

@implementation MailHomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = YES;
    
    
    //加载view
    _headerView=[[MailHeaderView alloc]initWithFrame:CGRectMake(0, 0, Kscreenwidth, 112)];
      [self.view addSubview:_headerView];
    [self.view bringSubviewToFront:_headerView];
    [_headerView.middleButton addTarget:self action:@selector(clickMiddelButton) forControlEvents:UIControlEventTouchUpInside];
    _mailTableView = [[MailView alloc]initWithFrame:CGRectMake(0, 113, Kscreenwidth, kScreenHeight - 112)];
    _mailTableView.btnArray = @[@"标记",@"移动至",@"删除"];
    _mailTableView.folder = @"INBOX";
    [self.view addSubview:_mailTableView];
    [self creatShowView];
    
    //按钮事件
    [_headerView.editButton addTarget:self action:@selector(clickEditButton) forControlEvents: UIControlEventTouchUpInside];
    _isEdit=NO;
    
     [_headerView.backButton addTarget:self action:@selector(clickBackButton) forControlEvents: UIControlEventTouchUpInside];
    
     [_headerView.allChoiceButton addTarget:self action:@selector(clickAllChoiceButtonn) forControlEvents: UIControlEventTouchUpInside];
    
     [_headerView.searchButton addTarget:self action:@selector(clickSearchButton) forControlEvents: UIControlEventTouchUpInside];
    
    [_headerView.sendButton addTarget:self action:@selector(clickSendButton) forControlEvents: UIControlEventTouchUpInside];
    

    
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    self.tabBarController.tabBar.hidden = YES;
    
    
//    if(self.isFromMidea){
//       
//        if([MailDataObject getInstance].userName.length>0&&[MailDataObject getInstance].passWord.length>0){
//           [self changeShowViewIndex:0];
//
//        }
//        else{
//            
//            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"温馨提示"
//                                                            message:@"请输入正式环境邮箱密码"
//                                                           delegate:self
//                                                  cancelButtonTitle:@"取消"
//                                                  otherButtonTitles:@"确定", nil];
//            // 基本输入框，显示实际输入的内容
//           alert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
//            UITextField *tf = [alert textFieldAtIndex:0];
//            tf.text=[MailDataObject getInstance].userName;
//           
//        
//                     [alert show];
//        }
//        
//        
//    }
//
    
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.tabBarController.tabBar.hidden = NO;
    self.isFromMidea=NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
}

#pragma mark -发送邮件
-(void)clickSendButton{
    MailSendVC *sendVc=[[MailSendVC alloc]init];
    sendVc.sendType=MailSendDefault;
    UINavigationController *nav=[[UINavigationController alloc]initWithRootViewController:sendVc];
    [self presentViewController:nav animated:YES completion:nil];
}
#pragma mark-点击搜索
-(void)clickSearchButton{
    MailSearchVC* searchVC = [[MailSearchVC alloc]init];
    [self.navigationController pushViewController:searchVC animated:YES];
    
}
#pragma mark-点击返回
-(void)clickBackButton{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - 点击全选
-(void)clickAllChoiceButtonn{
    [self.mailTableView chooseAllCell:YES];
    
}
#pragma mark - 点击编辑(取消)按钮
-(void)clickEditButton{
    if(_isEdit){
        //由编辑状态->取消
        _isEdit=NO;
        [_headerView.editButton setTitle:@"编辑" forState:UIControlStateNormal];
        _headerView.backButton.hidden=NO;
        _headerView.allChoiceButton.hidden=YES;
        _headerView.middleButton.userInteractionEnabled = YES;
        
        [self.mailTableView chooseAllCell:NO];
        self.mailTableView.isEdit = NO;
        [self.mailTableView exitEditView];
        [self.mailTableView chooseAllCell:NO];

    }else{
        //
        _isEdit=YES;
        [_headerView.editButton setTitle:@"取消" forState:UIControlStateNormal];
        _headerView.backButton.hidden=YES;
        _headerView.allChoiceButton.hidden=NO;
        _headerView.middleButton.userInteractionEnabled = NO;
        
        self.mailTableView.isEdit = YES;
        [self.mailTableView popEditView];
//        self.mailTableView.mailTableView.editing = YES;
    }
    
    
}
#pragma mark-点击中间按钮
-(void)clickMiddelButton{
    
    if(_isShow){
    //从展现到收起
        _isShow=NO;
        _showBGView.hidden=NO;
        [UIView animateWithDuration:0.5 animations:^{
            _showView.frame=CGRectMake(0, -214, Kscreenwidth, 214);
        } completion:^(BOOL finished) {
             _showBGView.hidden=YES;
             _headerView.pointImageView.image=[UIImage imageNamed:@"mail_other_03-1"];
        }];
       
    
    }
    else{
     //弹出
        _isShow=YES;
        _showBGView.hidden=NO;
        [UIView animateWithDuration:0.5 animations:^{
            _showView.frame=CGRectMake(0, 65, Kscreenwidth, 214);
        } completion:^(BOOL finished) {
            _headerView.pointImageView.image=[UIImage imageNamed:@"mail_other_1_03"];
        }];

    }
    
    

}

-(void)clickShowButton:(UIButton*)bton{
    [self changeShowViewIndex:bton.tag-ShowButtonTag];
    
    [UIView animateWithDuration:0.5 animations:^{
        _showView.frame=CGRectMake(0, -214, Kscreenwidth, 214);
    } completion:^(BOOL finished) {
        _showBGView.hidden=YES;
        _isShow=NO;
        _headerView.pointImageView.image=[UIImage imageNamed:@"mail_other_03-1"];

    }];
    
    
}
-(void)handleSingleTapFrom{
    [UIView animateWithDuration:0.5 animations:^{
        _showView.frame=CGRectMake(0, -214, Kscreenwidth, 214);
    } completion:^(BOOL finished) {
        _showBGView.hidden=YES;
        _isShow=NO;
        _headerView.pointImageView.image=[UIImage imageNamed:@"mail_other_03-1"];

    }];

}
#pragma mark-选择不同邮箱界面
-(void)creatShowView{
    
    _isShow=NO;
    _showBGView=[[UIView alloc]initWithFrame:CGRectMake(0, 65, Kscreenwidth, kScreenHeight-65)];
    _showBGView.backgroundColor=[UIColor blackColor];
    _showBGView.alpha=0.3;
    [self.view addSubview:_showBGView];
     _showBGView.hidden=YES;
    UITapGestureRecognizer * singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapFrom)];
    singleRecognizer.numberOfTapsRequired = 1; // 单击
    [_showBGView addGestureRecognizer:singleRecognizer];
    
    showTitleArray=@[@"收件箱",@"红旗邮件",@"草稿箱",@"已发送",@"已删除",@"垃圾邮件",@"病毒邮件"];
    
    _showView=[[UIView alloc]initWithFrame:CGRectMake(0, -214, Kscreenwidth, 214)];
    _showView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:_showView];
    _showView.userInteractionEnabled=YES;
    
    for(int i=0;i<7;i++){
       
        UIButton *showButton;
        UILabel *showLB;
        float kw=(Kscreenwidth-200)/5;
        if(i<4){
            showButton=[[UIButton alloc]initWithFrame:CGRectMake(kw+(kw+50)*i, 16, 50, 50)];
            showLB=[[UILabel alloc]initWithFrame:CGRectMake(showButton.frame.origin.x-15, 16+60, 80, 24)];
        }
        else{
        
            showButton=[[UIButton alloc]initWithFrame:CGRectMake(kw+(kw+50)*(i-4), 114, 50, 50)];
            showLB=[[UILabel alloc]initWithFrame:CGRectMake(showButton.frame.origin.x-15, 114+60, 80, 24)];
        }
        [showButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"mail_nomal_0%d",i+1]] forState:UIControlStateNormal];
        [showButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"mail_gray_3_0%d",i+1]] forState:UIControlStateHighlighted];
        [_showView addSubview:showButton];
        showButton.tag=ShowButtonTag+i;
        
        showLB.text=[showTitleArray objectAtIndex:i];
        showLB.textColor=Gray_Color;
        showLB.tag=ShowLabelTag+i;
        showLB.textAlignment=NSTextAlignmentCenter;
        [_showView addSubview:showLB];
        
        [showButton addTarget:self action:@selector(clickShowButton:) forControlEvents:UIControlEventTouchUpInside];
    
    }
     [self changeShowViewIndex:0];

}
-(void)changeShowViewIndex:(NSInteger)index{
    if ((index == 5)||(index == 6)) {
        self.headerView.editButton.hidden = YES;
    } else {
        self.headerView.editButton.hidden = NO;
    }
    //改变中间的位置
    self.headerView.middleLB.text=[showTitleArray objectAtIndex:index];
    
    CGSize lbSize =[[showTitleArray objectAtIndex:index] boundingRectWithSize:CGSizeMake(200, 24) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]} context:nil].size;
    self.headerView.middleLB.frame=CGRectMake(0, 0, lbSize.width, 24);
    self.headerView.middleLB.center=CGPointMake(Kscreenwidth/2, 40);
    self.headerView.pointImageView.center=CGPointMake( self.headerView.middleLB.frame.origin.x+ self.headerView.middleLB.frame.size.width+6, 40);
    self.headerView.pointImageView.image=[UIImage imageNamed:@"mail_other_03-1"];
    
    NSArray* folderArr = @[@"INBOX",@"INBOX",@"Drafts",@"Sent Items",@"Trash",@"Junk E-mail",@"Virus Items"];
    _mailTableView.folder = folderArr[index];
    if (index == 1) {
        _mailTableView.isRedFlag = YES;
    } else {
        _mailTableView.isRedFlag = NO;
    }
    //@[@"标记",@"移动至",@"删除"]
    NSArray* btnArray = @[@[@"标记",@"移动至",@"删除"],
                          @[@"标记",@"删除"],
                          @[@"标记",@"移动至",@"删除"],
                          @[@"标记",@"移动至",@"删除"],
                          @[@"标记",@"移动至",@"彻底删除"],
                          @[],
                          @[]
                          ];
    _mailTableView.btnArray = btnArray[index];
    
    [_mailTableView pullDatawithInt:0];
    
    for(int i=0;i<7;i++){
       
        UIButton *showButton=[_showView viewWithTag:ShowButtonTag+i];
        UILabel *showLB=[_showView viewWithTag:ShowLabelTag+i];
        if(i==index){
            [showButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"mail_blue_3_0%d",i+1]] forState:UIControlStateNormal];
            showLB.textColor=Blue_Color;
        }else{
         [showButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"mail_nomal_0%d",i+1]] forState:UIControlStateNormal];
         showLB.textColor=Gray_Color;
        }
    
    }
    
    
}

#pragma mark-UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{

     UITextField *tf0 = [alertView textFieldAtIndex:0];
     NSString *userNmae=tf0.text;
    
    UITextField *tf1 = [alertView textFieldAtIndex:1];
    NSString *passWordStr=tf1.text;
    if(buttonIndex==1){
       
        if(![self validateEmail:userNmae]){
            [SVProgressHUD showErrorWithStatus:@"请输入正确的邮箱地址"];
            
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                            message:@"请输入正式环境邮箱密码"
                                                           delegate:self
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles:@"确定", nil];
            // 基本输入框，显示实际输入的内容
             alert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
             UITextField *tf = [alert textFieldAtIndex:0];
             tf.text=userNmae;
             UITextField *tf1 = [alertView textFieldAtIndex:1];
             tf1.text=passWordStr;
            [alert show];

            
            return;
        }
      
        
        /**/
        [SVProgressHUD showWithStatus:@"正在登录..."];
        [[MailDataObject getInstance]loadAccountWithUsername:userNmae password:passWordStr oauth2Token:nil andErrorBlock:^(NSError *error) {
            [SVProgressHUD dismiss];
            if(error){
                [SVProgressHUD showErrorWithStatus:@"邮箱登录失败"];
                
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                                message:@"请输入正式环境邮箱密码"
                                                               delegate:self
                                                      cancelButtonTitle:@"取消"
                                                      otherButtonTitles:@"确定", nil];
                // 基本输入框，显示实际输入的内容
                alert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
                UITextField *tf = [alert textFieldAtIndex:0];
                tf.text=userNmae;
                UITextField *tf1 = [alertView textFieldAtIndex:1];
                tf1.text=passWordStr;
                [alert show];

                
                
            }else{
                [MailDataObject getInstance].userName=userNmae;
                [MailDataObject getInstance].passWord=passWordStr;
                
                 [self changeShowViewIndex:0];
        
                
//                [[MailDataObject getInstance] loadLastNMessages:0 withFolder:INBOX andCompletionBlock:^(NSError * _Nullable error, NSArray * _Nullable messages, MCOIndexSet * _Nullable vanishedMessages) {
//                    {
//                        _mailTableView.dataSourceArray = [NSMutableArray arrayWithArray:messages];
//                                [_mailTableView.mailTableView reloadData];
//                       
//                        
//
//                    }
//                
//                
//                }];
                
            
            }
            
        }];
        
    
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }

}

-(BOOL) validateEmail:(NSString *)emailName
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:emailName];
}


@end
