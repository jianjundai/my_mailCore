//
//  MailSendVC.m
//  mailcoreDemo
//
//  Created by ios－dai on 16/6/9.
//  Copyright © 2016年 ios－dai. All rights reserved.
//

#import "MailSendVC.h"
#import "MailDataObject.h"
#import "Masonry.h"
#import "MailDefine.h"

#import "ZLPhotoActionSheet.h"
#import "ZLDefine.h"
#import "ZLCollectionCell.h"
#import "MailDAO.h"
#import "ContactsModel.h"
#import "MailGlobalData.h"
#import "SendSearchView.h"

#define Red_Namal_Color [UIColor colorWithRed:242/255.0 green:151/255.0 blue:161/255.0 alpha:0.9]
#define Red_Hight_Color [UIColor colorWithRed:234/255.0 green:61/255.0 blue:85/255.0 alpha:1]

#define Blue_Namal_Color [UIColor colorWithRed:196/255.0 green:224/255.0 blue:255/255.0 alpha:0.9]
#define Blue_Hight_Color [UIColor colorWithRed:72/255.0 green:138/255.0 blue:238/255.0 alpha:1]




#define kWrapTop  30
#define kbuttonHight 24
#define kButtonGrap 5.0
#define kSendImageButtonTag 200
#define DeleteButtonTag  100


//uibutton

@interface NSMutableArray (removeModel)
-(void)removeModelByObject:(NSString*)object;
@end
@implementation NSMutableArray (removeModel)
-(void)removeModelByObject:(NSString*)object{
    
    NSMutableArray *middleArray=self;
    for(int i=0;i<middleArray.count;i++){
        ContactsModel *oneModel=[middleArray objectAtIndex:i];
        if([oneModel.disPlayName isEqual:object]){
            [self removeObject:oneModel];
        }
        
    }
}
@end

@interface MailSendVC ()<SendSearchViewDelegate,UIActionSheetDelegate>
{
    NSMutableArray *errorMailArray;//错误邮箱个数
    
    NSMutableArray *toArray; //收件人
    NSString *deletString1;
    UIButton *lastButton1;//上一个button
    CGFloat leftWidth1;//button离左边的距离
    CGFloat viewHeight1;//view1的高度
    
    NSMutableArray *ccArray;  //抄送
    UIButton *lastButton2;//上一个button
    NSString *deletString2;
    CGFloat leftWidth2;//button离左边的距离
    CGFloat viewHeight2;//view1的高度

    
    NSMutableArray *bccArray;  //密送
    UIButton *lastButton3;//上一个button
    NSString *deletString3;
    CGFloat leftWidth3;//button离左边的距离
    CGFloat viewHeight3;//view1的高度
    
    
    
    NSString *mailSubject;//主题
    NSString *mailContent;//内容
    
    CGFloat textHeight;
    
    UIButton *addImageButton;
    NSMutableArray *secletButtonArray;
    
    SendSearchView *searchView;
    
    CGFloat allImageHight;
    
    BOOL  isFrist;
    
}
@property (nonatomic, strong) NSMutableArray<ZLSelectPhotoModel *> *lastSelectMoldels;
@property (nonatomic, strong) NSMutableArray *arrDataSources;

@end

@implementation MailSendVC
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //获取通讯录
    [[MailDAO sharedManager]getAllContactsResultBlock:^(NSArray *resultArray) {
        if(resultArray.count>0){
            [MailGlobalData getInstance].contactsArray=resultArray;
            for(ContactsModel *oneModel in resultArray){
                
               // NSLog(@"name=%@",oneModel.disPlayName);
              //  NSLog(@"box=%@",oneModel.mailBox);
            }
            
            
        }else{
            NSLog(@"通讯录为空");
            
            for(ContactsModel *oneModel in  [MailGlobalData getInstance].contactsArray){
                
               // NSLog(@"name=%@",oneModel.disPlayName);
               // NSLog(@"box=%@",oneModel.mailBox);
            }

        }
        
        
    }];

    
    //初始化数组
    secletButtonArray=[[NSMutableArray alloc]initWithCapacity:0];
    errorMailArray=[[NSMutableArray alloc]initWithCapacity:0];
    toArray=[[NSMutableArray alloc]initWithCapacity:0];
    lastButton1=nil;
  
    
    ccArray=[[NSMutableArray alloc]initWithCapacity:0];
    lastButton2=nil;
    
    bccArray=[[NSMutableArray alloc]initWithCapacity:0];
    lastButton3=nil;
    
    [self.navigationController.navigationBar setBarTintColor:Blue_Color];
    
    //titleview
    UILabel *titleLB=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 80, 40)];
    titleLB.text=@"写信";
    titleLB.textColor=[UIColor whiteColor];
    titleLB.textAlignment=NSTextAlignmentCenter;
    titleLB.font=[UIFont systemFontOfSize:22];
    self.navigationItem.titleView=titleLB;
    
    UIButton *leftButton=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    [leftButton setTitle:@"取消" forState:UIControlStateNormal];
    [leftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(clickCancleBarItem) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:leftButton];
    
    
    UIButton *rightButton=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    [rightButton setTitle:@"发送" forState:UIControlStateNormal];
    [rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(clickSendMial) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:rightButton];
    
    
    self.addButton2.hidden=YES;
    self.addButton3.hidden=YES;
    
    
    //搜索view
    searchView=[[SendSearchView alloc]initWithFrame:CGRectMake(0, 65, Kscreenwidth, kScreenHeight-65-252)];
    [self.view addSubview:searchView];
    [self.view bringSubviewToFront:searchView];
    searchView.hidden=YES;
    searchView.delegate=self;
    
    [_textFild1 addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [_textFild2 addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [_textFild3 addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    isFrist=YES;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(isFrist==NO){
        return;
    }
    isFrist=NO;
    allImageHight=0.0;
    if(self.sendType==MailSendFromDrafts){
     //草稿箱
        [MRProgressOverlayView showOverlayAddedTo:self.view title:@"请稍后..." mode:MRProgressOverlayViewModeIndeterminate animated:YES];
        
        [[MailDataObject getInstance]getDetailMessageHtmlWithUid:self.messageUid  withFolder:Drafts with:^(NSMutableDictionary *msgDic) {
            
            //收件人  抄送 密送
            NSArray *msgToArray=[msgDic objectForKey:@"addressTo"];
            if(msgToArray.count>0){
                [toArray addObjectsFromArray:msgToArray];
                for(int i=0;i<toArray.count;i++){
                    ContactsModel *oneModel=[toArray objectAtIndex:i];
                    NSString *titleString=oneModel.disPlayName;
                    [self performSelector:@selector(reviewNewRect1:) withObject:titleString afterDelay:0.1];
                }
                
            }
            
            NSArray *msgCcArray=[msgDic objectForKey:@"addressCc"];
            if(msgCcArray.count>0){
                [ccArray addObjectsFromArray:msgCcArray];
                for(int i=0;i<ccArray.count;i++){
                    ContactsModel *oneModel=[ccArray objectAtIndex:i];
                    NSString *titleString=oneModel.disPlayName;
                    [self performSelector:@selector(reviewNewRect2:) withObject:titleString afterDelay:0.1];
                }
                
            }
            
            NSArray *msgBccArray=[msgDic objectForKey:@"addressBcc"];
            if(msgBccArray.count>0){
                [bccArray addObjectsFromArray:msgBccArray];
                for(int i=0;i<bccArray.count;i++){
                    ContactsModel *oneModel=[bccArray objectAtIndex:i];
                    NSString *titleString=oneModel.disPlayName;
                    [self performSelector:@selector(reviewNewRect3:) withObject:titleString afterDelay:0.1];
                }
                
            }
            

            [self rplyMail:msgDic];
        }];
    
    
    }
    if(self.sendType==MailSendReply){
    //回复
        _subjectLB.text=@"回复:";
        ContactsModel *oneModel=[self.messageDict objectForKey:@"fromModel"];
        [toArray addObject:oneModel];
        NSString *titleString=oneModel.disPlayName;
        [self performSelector:@selector(reviewNewRect1:) withObject:titleString afterDelay:0.1];
        
     [self rplyMail:self.messageDict];
    }
    if(self.sendType==MailSendReplyAll){
        //回复全部
        _subjectLB.text=@"回复全部:";
        NSArray *msgToArray=[self.messageDict objectForKey:@"addressTo"];
        if(msgToArray.count>0){
            [toArray addObjectsFromArray:msgToArray];
        }
        ContactsModel *oneModel=[self.messageDict objectForKey:@"fromModel"];
        [toArray addObject:oneModel];
        for(int i=0;i<toArray.count;i++){
            ContactsModel *oneModel=[toArray objectAtIndex:i];
            NSString *titleString=oneModel.disPlayName;
            [self performSelector:@selector(reviewNewRect1:) withObject:titleString afterDelay:0.1];
        }

        
        NSArray *msgCcArray=[self.messageDict objectForKey:@"addressCc"];
        if(msgCcArray.count>0){
            [ccArray addObjectsFromArray:msgCcArray];
            for(int i=0;i<ccArray.count;i++){
                ContactsModel *oneModel=[ccArray objectAtIndex:i];
                NSString *titleString=oneModel.disPlayName;
                [self performSelector:@selector(reviewNewRect2:) withObject:titleString afterDelay:0.1];
            }
            
        }
        
        NSArray *msgBccArray=[self.messageDict objectForKey:@"addressBcc"];
        if(msgBccArray.count>0){
            [bccArray addObjectsFromArray:msgBccArray];
            for(int i=0;i<bccArray.count;i++){
                ContactsModel *oneModel=[bccArray objectAtIndex:i];
                NSString *titleString=oneModel.disPlayName;
                [self performSelector:@selector(reviewNewRect3:) withObject:titleString afterDelay:0.1];
            }
            
        }
        
        [self rplyMail:self.messageDict];
        
    }
    if(self.sendType==MailSendForwarding){
        //转发
         _subjectLB.text=@"转发:";
        
        [self rplyMail:self.messageDict];
        
    }
    
    NSLog(@"msgdic==%@",self.messageDict);
    
    
}

-(void)rplyMail:(NSDictionary*)msgDic{
    
    
    NSString *str1=[msgDic objectForKey:@"body"];
    NSArray *strArray=[str1 componentsSeparatedByString:@"<hr/>"];
    if(strArray.count>1){
        str1=[NSString stringWithFormat:@"%@</div>",[strArray objectAtIndex:0]];
        
    }
    
    NSMutableAttributedString *htmlStr=[[NSMutableAttributedString alloc]initWithData:[str1 dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType} documentAttributes:nil error:nil];
    
    _connectTextView.attributedText=htmlStr;
    _textViewLB.hidden=YES;
    
    _subjectTextFild.text=[msgDic objectForKey:@"subject"];//主题
    
    
    //文件图片
    NSArray *attachmentsArray=[msgDic objectForKey:@"attachments"];
    
    if(attachmentsArray.count>0){
        self.arrDataSources = [[NSMutableArray alloc]initWithCapacity:0];
        for(NSString *imageStr in attachmentsArray){
            
            NSString *tmpDirectory =NSTemporaryDirectory();
            NSString *filePath=[tmpDirectory stringByAppendingPathComponent:imageStr];
            //[NSURL fileURLWithPath:filePath];
            UIImage *image=[UIImage imageWithContentsOfFile:filePath];
            if(image){
                [ self.arrDataSources addObject:image];
            }
        }
        
        [self updateNeedSendImageView];
    }
    
    
    [MRProgressOverlayView dismissOverlayForView:self.view animated:YES];
    
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
   
}
#pragma mark-取消
-(void)clickCancleBarItem{
    
    [_textFild1 resignFirstResponder];
    [_textFild2 resignFirstResponder];
    [_textFild3 resignFirstResponder];
    [_subjectTextFild resignFirstResponder];
    [_connectTextView resignFirstResponder];
    if(toArray.count>0&&self.sendType==MailSendDefault){
        UIActionSheet *actonSheet=[[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除草稿" otherButtonTitles:@"保存草稿", nil];
        [actonSheet showInView:self.view];
        
        }
    else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark-发送邮件
-(void)clickSendMial{
   
    if([MailDataObject getInstance].progressView){
        return;
    }
    
    if(toArray.count==0){
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"收件人不能为空" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        //[MRProgressShow showErrorStay:@"收件人不能为空"];
        return;
    }
    
    mailSubject=_subjectTextFild.text;
    if(mailSubject.length==0){
//        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"邮件主题为空，您是否继续发送邮件" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"继续发送", nil];
//        [alertView show];
//         //[MRProgressShow showErrorStay:@"主题为空"];
//        return;
        
    }
   
    mailContent=_connectTextView.text;
    
    if(errorMailArray.count>0){
      // [MRProgressShow showErrorStay:@"邮箱格式不正确"];
        ContactsModel *oneModel=[errorMailArray objectAtIndex:0];
        NSString *errorString=[NSString stringWithFormat:@"%@的邮箱格式不正确！",oneModel.disPlayName];
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"邮件格式错误" message:errorString delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    
    [MailDataObject getInstance].progressView=[MRProgressOverlayView new];
    [MailDataObject getInstance].progressView.mode = MRProgressOverlayViewModeDeterminateHorizontalBar;
    [self.view addSubview:[MailDataObject getInstance].progressView];
    
        NSString *myEmail=[MailDataObject getInstance].userName;
        NSString *_passwordCopy=[MailDataObject getInstance].passWord;
    
    
        [[MailDataObject getInstance]sendEmail:@"smtp.midea.com"
                                     port:587
                                     userName:myEmail
                                      password:_passwordCopy
                                      fromDisplayName:@"戴建军"
                                      fromMaiBox:myEmail
                                       toArray:toArray
                                       ccArray:ccArray
                                       bccArray:bccArray
                                       subject:mailSubject
                                        content:mailContent
                                        file:self.arrDataSources
                                       resultBlock:^(NSError *error) {
    
                                           NSLog(@"error22222==%@",error);
                                     }];

    
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if(textField==_textFild1){
        self.addButton1.hidden=NO;
        self.addButton2.hidden=YES;
        self.addButton3.hidden=YES;
    }
    if(textField==_textFild2){
        self.addButton1.hidden=YES;
        self.addButton2.hidden=NO;
        self.addButton3.hidden=YES;
    }
    
    if(textField==_textFild3){
        self.addButton1.hidden=YES;
        self.addButton2.hidden=YES;
        self.addButton3.hidden=NO;
    }
    
    return YES;

}


- (void)textFieldDidEndEditing:(UITextField *)textField{
    if([textField.text isEqual:@""]){
        return;
    }
    ContactsModel *oneModel=[[ContactsModel alloc]init];
    oneModel.disPlayName=textField.text;
    oneModel.mailBox=textField.text;
    
    if(textField==_textFild1){
        [self setNewLayOut:lastButton1 InView:_view1 changeHeightConstrant:_heightConstrant1 andTitleString:textField.text andLeftWidth:leftWidth1 andViewHeight:viewHeight1];
        [toArray addObject:oneModel];
    }
    
    if(textField==_textFild2){
        [self setNewLayOut:lastButton2 InView:_view2 changeHeightConstrant:_heightConstrant2 andTitleString:textField.text andLeftWidth:leftWidth2 andViewHeight:viewHeight2];
        
        [ccArray addObject:oneModel];
    }
    if(textField==_textFild3){
        [self setNewLayOut:lastButton3 InView:_view3 changeHeightConstrant:_heigthConstrant3 andTitleString:textField.text andLeftWidth:leftWidth3 andViewHeight:viewHeight3];
        
        [bccArray addObject:oneModel];
    }
    if(![self validateEmail:textField.text andIsBox:YES]){
        [errorMailArray addObject:oneModel];
    }
    
    textField.text=@"";
  
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if([textField.text isEqual:@""]){
        return YES;
    }
    
    ContactsModel *oneModel=[[ContactsModel alloc]init];
    oneModel.disPlayName=textField.text;
    oneModel.mailBox=textField.text;

    if(textField==_textFild1){
        [self setNewLayOut:lastButton1 InView:_view1 changeHeightConstrant:_heightConstrant1 andTitleString:textField.text andLeftWidth:leftWidth1 andViewHeight:viewHeight1];
        
         [toArray addObject:oneModel];
    }
    
    if(textField==_textFild2){
        [self setNewLayOut:lastButton2 InView:_view2 changeHeightConstrant:_heightConstrant2 andTitleString:textField.text andLeftWidth:leftWidth2 andViewHeight:viewHeight2];
        
        [ccArray addObject:oneModel];
    }
    if(textField==_textFild3){
        [self setNewLayOut:lastButton3 InView:_view3 changeHeightConstrant:_heigthConstrant3 andTitleString:textField.text andLeftWidth:leftWidth3 andViewHeight:viewHeight3];
        
        [bccArray addObject:oneModel];
    }
    
    if(![self validateEmail:textField.text andIsBox:YES]){
        [errorMailArray addObject:oneModel];
    }

   
    textField.text=@"";
    
    return YES;
}


- (void)textFieldDidDeleteBackward:(UITextField *)textField{
    //按删除键
    if(textField==_textFild1){
        if(textField.text.length==0){
            if(deletString1){
                [self deleteButtonString:deletString1 inView:_view1];
                deletString1=nil;
            }else{
                ContactsModel *oneModel=[toArray lastObject];
                NSString *lastButtonStr=oneModel.disPlayName;
                for(UIView *subView in _view1.subviews){
                    if([subView isKindOfClass:[UIButton class]]){
                        UIButton *button=(UIButton*)subView;
                        if([button.titleLabel.text isEqual:lastButtonStr]){
                          
                            button.selected=YES;
                            if([self validateEmail:lastButtonStr andIsBox:NO]){
                                button.backgroundColor=Blue_Hight_Color;
                            }
                            else{
                                button.backgroundColor=Red_Hight_Color;
                            }
                            
                            deletString1=lastButtonStr;
                        }
                    }
                    
                }

                
            }
            
        }
        else{
            deletString1=nil;
        }
    }
    if(textField==_textFild2){
        if(textField.text.length==0){
            if(deletString2){
                [self deleteButtonString:deletString2 inView:_view2];
                deletString2=nil;
            }else{
                ContactsModel *oneModel=[ccArray lastObject];
                NSString *lastButtonStr=oneModel.disPlayName;
                for(UIView *subView in _view2.subviews){
                    if([subView isKindOfClass:[UIButton class]]){
                        UIButton *button=(UIButton*)subView;
                        if([button.titleLabel.text isEqual:lastButtonStr]){
                            
                            button.selected=YES;
                            
                            if([self validateEmail:lastButtonStr andIsBox:NO]){
                                button.backgroundColor=Blue_Hight_Color;
                            }
                            else{
                                button.backgroundColor=Red_Hight_Color;
                            }
                            
                            deletString2=lastButtonStr;
                        }
                    }
                    
                }
                
                
            }
            
        }
        else{
            deletString2=nil;
        }
    }
    
    if(textField==_textFild3){
        if(textField.text.length==0){
            if(deletString3){
                [self deleteButtonString:deletString3 inView:_view3];
                deletString3=nil;
            }else{
                ContactsModel *oneModel=[bccArray lastObject];
                NSString *lastButtonStr=oneModel.disPlayName;
                for(UIView *subView in _view3.subviews){
                    if([subView isKindOfClass:[UIButton class]]){
                        UIButton *button=(UIButton*)subView;
                        if([button.titleLabel.text isEqual:lastButtonStr]){
                            
                            button.selected=YES;
                            
                            if([self validateEmail:lastButtonStr andIsBox:NO]){
                                button.backgroundColor=Blue_Hight_Color;
                            }
                            else{
                                button.backgroundColor=Red_Hight_Color;
                            }
                            
                            deletString3=lastButtonStr;
                        }
                    }
                    
                }
                
                
            }
            
        }
        else{
            deletString3=nil;
        }
    }
   

}

-(void)setNewLayOut:(UIButton *)lastButton InView:(UIView*)view changeHeightConstrant:(NSLayoutConstraint*)heightConstrant andTitleString:(NSString*)titleString andLeftWidth:(CGFloat)leftWidth andViewHeight:(CGFloat)viewHeight{

    UIButton *button=[[UIButton alloc]init];
    [button setTitle:titleString forState:UIControlStateNormal];
    button.clipsToBounds=YES;
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = kbuttonHight/2; //圆角
    [view addSubview:button];
     CGFloat buttonWidth=button.intrinsicContentSize.width+20;
    button.selected=NO;
    
    if([self validateEmail:titleString andIsBox:NO]){
        button.backgroundColor=Blue_Namal_Color;
    }
    else{
        button.backgroundColor=Red_Namal_Color;
    }
    
    
    if(lastButton==nil){
        leftWidth=80;
        viewHeight=44;
     //第一个button
        if(buttonWidth>Kscreenwidth-100){
            buttonWidth=Kscreenwidth-100;
        }
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(view.mas_left).offset(80);
            make.top.mas_equalTo(view.mas_top).offset(10);
            make.height.mas_equalTo(kbuttonHight);
            make.width.mas_equalTo(buttonWidth);
        }];
        leftWidth=leftWidth+buttonWidth;
        viewHeight=viewHeight+kWrapTop;
        
       
    }else{
        if(leftWidth+buttonWidth<=Kscreenwidth-10){
          //不换行
            [button mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(lastButton.mas_right).offset(kButtonGrap);
                make.top.mas_equalTo(lastButton);
                make.height.mas_equalTo(kbuttonHight);
                make.width.mas_equalTo(buttonWidth);
            }];
            leftWidth=leftWidth+buttonWidth+kButtonGrap;
        }else{
            NSLog(@"viewHeight=%f",viewHeight);
            [button mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(view.mas_left).offset(10);
                make.top.mas_equalTo(view.mas_top).offset(10+(viewHeight-44));
                make.height.mas_equalTo(kbuttonHight);
                make.width.mas_equalTo(buttonWidth);
                
            }];

            leftWidth=10+buttonWidth+kButtonGrap;
            viewHeight=viewHeight+kWrapTop;
        }
        
    }
    
    [UIView animateWithDuration:.1
                     animations:^{
                         heightConstrant.constant=viewHeight;
                         [self.view layoutIfNeeded];
                     }];
    
    _mainScrollView.contentSize=CGSizeMake(Kscreenwidth, kScreenHeight-(44*3)+viewHeight1+viewHeight2+viewHeight3+allImageHight);
    
    if(view==_view1){
        lastButton1=button;
        leftWidth1=leftWidth;
        viewHeight1=viewHeight;
        [button addTarget:self action:@selector(clickView1Button:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    
    if(view==_view2){
        lastButton2=button;
        leftWidth2=leftWidth;
        viewHeight2=viewHeight;
        [button addTarget:self action:@selector(clickView2Button:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    
    if(view==_view3){
        lastButton3=button;
        leftWidth3=leftWidth;
        viewHeight3=viewHeight;
        [button addTarget:self action:@selector(clickView3Button:) forControlEvents:UIControlEventTouchUpInside];
        
    }


}
#pragma mark- 添加人按钮
- (IBAction)clickAadMemberButton:(id)sender {
    
}
#pragma mark - 添加文件
- (IBAction)clickAadFileButton:(id)sender {
    [self.textFild1 resignFirstResponder];
    [self.textFild2 resignFirstResponder];
    [self.textFild3 resignFirstResponder];
    [self.connectTextView resignFirstResponder];
    [self.subjectTextFild resignFirstResponder];
    
    ZLPhotoActionSheet *actionSheet = [[ZLPhotoActionSheet alloc] init];
    //设置照片最大选择数
    actionSheet.maxSelectCount = 100;
    //设置照片最大预览数
    actionSheet.maxPreviewCount = 30;
    weakify(self);
    [actionSheet showWithSender:self animate:YES lastSelectPhotoModels:self.lastSelectMoldels completion:^(NSArray<UIImage *> * _Nonnull selectPhotos, NSArray<ZLSelectPhotoModel *> * _Nonnull selectPhotoModels) {
        strongify(weakSelf);
        strongSelf.arrDataSources = [[NSMutableArray alloc]initWithArray:selectPhotos];
        strongSelf.lastSelectMoldels = [[NSMutableArray alloc]initWithArray:selectPhotoModels];
        NSLog(@"%@", selectPhotos);
        
        [self updateNeedSendImageView];
    }];

    
    
}
#pragma mark-处理buton点击事件
-(void)clickView1Button:(UIButton*)button{
    [self selectButton:button inView:_view1];
}
-(void)clickView2Button:(UIButton*)button{
     [self selectButton:button inView:_view2];
}

-(void)clickView3Button:(UIButton*)button{
    [self selectButton:button inView:_view3];
}

-(void)selectButton:(UIButton*)button inView:(UIView*)view{

    NSString *titleString=button.titleLabel.text;
    if(button.selected){
        if(view==_view1){
            
        }
        if(view==_view2){
           
        }
        if(view==_view3){
            
        }
        return;
    }
    
    UIButton *addButon;
    if(view==_view1){
        addButon=_addButton1;
        [_textFild1 becomeFirstResponder];
    }
    if(view==_view2){
        addButon=_addButton2;
         [_textFild2 becomeFirstResponder];
    }
    if(view==_view3){
        addButon=_addButton3;
        [_textFild3 becomeFirstResponder];
    }
    for(UIView *subView in view.subviews){
        if([subView isKindOfClass:[UIButton class]]){
            if(subView!=addButon){
                if(subView==button){
                    button.selected=YES;
                    if([self validateEmail:titleString andIsBox:NO]){
                        button.backgroundColor=Blue_Hight_Color;
                    }
                    else{
                        button.backgroundColor=Red_Hight_Color;
                    }
                    
                    if(view==_view1){
                        deletString1=titleString;
                    }
                    if(view==_view2){
                        deletString2=titleString;
                    }
                    if(view==_view3){
                        deletString3=titleString;
                    }

                }
                else{
                    UIButton *button2=(UIButton*)subView;
                    NSString *otherTitleStr=button2.titleLabel.text;
                    button2.selected=NO;
                    if([self validateEmail:otherTitleStr andIsBox:NO]){
                        button2.backgroundColor=Blue_Namal_Color;
                    }
                    else{
                        button2.backgroundColor=Red_Namal_Color;
                    }
                    
                }
            }
        }
        
    }
    
}

-(void)deleteButtonString:(NSString*)buttonString inView:(UIView*)view {
   [errorMailArray removeModelByObject:buttonString];
    if(view==_view1){
        [toArray removeModelByObject:buttonString];
        //从新生成位置
        lastButton1=nil;
        for(UIView *subView in _view1.subviews){
            if([subView isKindOfClass:[UIButton class]]){
                if(subView!=_addButton1){
                    [subView removeFromSuperview];
                }
            }
            
        }
        if(toArray.count==0){
            [UIView animateWithDuration:.3
                             animations:^{
                                 _heightConstrant1.constant=44;
                                 [self.view layoutIfNeeded];
                             }];
            
            
        }
        else{
            for(int i=0;i<toArray.count;i++){
                
                ContactsModel *oneModel=[toArray objectAtIndex:i];
                NSString *titleString=oneModel.disPlayName;
    
                [self performSelector:@selector(reviewNewRect1:) withObject:titleString afterDelay:0.1];
            }
        }
    }
    if(view==_view2){
        [ccArray removeModelByObject:buttonString];
        //从新生成位置
        lastButton2=nil;
        
        for(UIView *subView in _view2.subviews){
            if([subView isKindOfClass:[UIButton class]]){
                if(subView!=_addButton2){
                    [subView removeFromSuperview];
                }
            }
            
        }
        if(ccArray.count==0){
            [UIView animateWithDuration:.3
                             animations:^{
                                 _heightConstrant2.constant=44;
                                 [self.view layoutIfNeeded];
                             }];
        }
        else{
            for(int i=0;i<ccArray.count;i++){
                ContactsModel *oneModel=[ccArray objectAtIndex:i];
                NSString *titleString=oneModel.disPlayName;
                [self performSelector:@selector(reviewNewRect2:) withObject:titleString afterDelay:0.1];
            }
        }

    }
    if(view==_view3){
    
        [bccArray removeModelByObject:buttonString];
        //从新生成位置
        lastButton3=nil;
        
        for(UIView *subView in _view3.subviews){
            if([subView isKindOfClass:[UIButton class]]){
                if(subView!=_addButton3){
                    [subView removeFromSuperview];
                }
            }
            
        }
        if(bccArray.count==0){
            [UIView animateWithDuration:.3
                             animations:^{
                                 _heigthConstrant3.constant=44;
                                 [self.view layoutIfNeeded];
                             }];
        }
        else{
            for(int i=0;i<bccArray.count;i++){
                ContactsModel *oneModel=[bccArray objectAtIndex:i];
                NSString *titleString=oneModel.disPlayName;
                [self performSelector:@selector(reviewNewRect3:) withObject:titleString afterDelay:0.1];
            }
        }

    }
    _mainScrollView.contentSize=CGSizeMake(Kscreenwidth, kScreenHeight-(44*3)+viewHeight1+viewHeight2+viewHeight3+allImageHight);
}

-(void)reviewNewRect1:(NSString*)titelString{

     [self setNewLayOut:lastButton1 InView:_view1 changeHeightConstrant:_heightConstrant1 andTitleString:titelString andLeftWidth:leftWidth1 andViewHeight:viewHeight1];

}

-(void)reviewNewRect2:(NSString*)titelString{
    
    [self setNewLayOut:lastButton2 InView:_view2 changeHeightConstrant:_heightConstrant2 andTitleString:titelString andLeftWidth:leftWidth2 andViewHeight:viewHeight2];
    
}


-(void)reviewNewRect3:(NSString*)titelString{
    
    [self setNewLayOut:lastButton3 InView:_view3 changeHeightConstrant:_heigthConstrant3 andTitleString:titelString andLeftWidth:leftWidth3 andViewHeight:viewHeight3];
    
}


#pragma mark- UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    _textViewLB.hidden=YES;
    return YES;
}
- (void)textViewDidChange:(UITextView *)textView{
    if(textView.text.length==0){
      _textViewLB.hidden=NO;
    }else{
        _textViewLB.hidden=YES;
        
        CGRect textFrame=[[textView layoutManager]usedRectForTextContainer:[textView textContainer]];
        textHeight = textFrame.size.height;
        NSLog(@"textHeight=%f",textHeight);
    }


}
#pragma mark-添加图片view
-(void)updateNeedSendImageView{
    
    for(UIButton *button in secletButtonArray){
        [button removeFromSuperview];
    }
    NSUInteger countTeger=self.arrDataSources.count;
    if(countTeger==0){
        _fileLB.text=@"";
        [_aadFileButton setImage:[UIImage imageNamed:@"mail_other_37"] forState:UIControlStateNormal];
        return;
    }
    
    CGFloat imageViewTop=20;
    CGFloat imageWidth=Kscreenwidth/2-15;
    
    for(int i=0;i<countTeger;i++){
        
         UIButton   *sendImageButton=[[UIButton alloc]init];
            sendImageButton.layer.masksToBounds = YES;
            sendImageButton.layer.cornerRadius = 5; //圆角
            [[sendImageButton layer] setBorderWidth:1.0];//画线的宽度
            [[sendImageButton layer] setBorderColor:[UIColor grayColor].CGColor];//颜色
            [self.mainScrollView addSubview:sendImageButton];
            [secletButtonArray addObject:sendImageButton];
        
      
        if(i%2==0){
            //左边的
            [sendImageButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.MideaConnectLB.mas_bottom).offset(imageViewTop);
                make.left.mas_equalTo(self.mainScrollView.mas_left).offset(10);
                make.height.mas_equalTo(imageWidth);
                make.width.mas_equalTo(imageWidth);
            }];
            
        }else{
            //右边的
            
            [sendImageButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.MideaConnectLB.mas_bottom).offset(imageViewTop);
                make.right.mas_equalTo(self.mainScrollView.mas_right).offset(-10);
                make.height.mas_equalTo(imageWidth);
                make.width.mas_equalTo(imageWidth);
            }];
            imageViewTop=imageViewTop+imageWidth+5;

        }
        if(i<countTeger){
           UIImage *image=[self.arrDataSources objectAtIndex:i];
           [sendImageButton setImage:image forState:UIControlStateNormal];
            sendImageButton.tag=kSendImageButtonTag+i;
            
            NSData * imageData = UIImageJPEGRepresentation(image,1);
            NSUInteger length = [imageData length]/1024;
            
            UILabel *sizeLB=[[UILabel alloc]init];
            sizeLB.text=[NSString stringWithFormat:@" %lu KB",(unsigned long)length];
            sizeLB.textColor=[UIColor whiteColor];
            sizeLB.font=[UIFont systemFontOfSize:15];
            sizeLB.backgroundColor=Gray_Color;
            [sendImageButton addSubview:sizeLB];
            [sizeLB mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(sendImageButton);
                make.left.mas_equalTo(sendImageButton);
                make.width.mas_equalTo(sendImageButton);
                make.height.mas_equalTo(24);
                
            }];
            
            UIButton *deleteButton=[[UIButton alloc]init];
            [deleteButton setTitle:@"删除" forState:UIControlStateNormal];
           // [deleteButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            deleteButton.tag=DeleteButtonTag+i;
            [sendImageButton addSubview:deleteButton];
            [deleteButton addTarget:self action:@selector(deleteImageButton:) forControlEvents:UIControlEventTouchUpInside];
            
            [deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(sendImageButton);
                make.right.mas_equalTo(sendImageButton);
                make.width.mas_equalTo(50);
                make.height.mas_equalTo(24);
            }];
            
            
        }else if(i==countTeger){
            addImageButton=sendImageButton;
            addImageButton.backgroundColor=Gray_Color;
            
        }
        
    }
    
    if(countTeger%2!=0){
        imageViewTop=imageViewTop+imageWidth+5;
    }
    
    _mainScrollView.contentSize=CGSizeMake(Kscreenwidth, kScreenHeight-(44*3)+viewHeight1+viewHeight2+viewHeight3+imageViewTop);
    allImageHight=imageViewTop;
    
    _fileLB.text=[NSString stringWithFormat:@"%lu",(unsigned long)countTeger];
    [_aadFileButton setImage:[UIImage imageNamed:@"mail_other_28"] forState:UIControlStateNormal];
    
    
}

-(void)deleteImageButton:(UIButton*)bton{
    NSInteger indx=bton.tag-100;
    if(self.lastSelectMoldels.count==self.arrDataSources.count){
        [self.lastSelectMoldels removeObjectAtIndex:indx];
    }
    
    [self.arrDataSources removeObjectAtIndex:indx];
    if(self.arrDataSources.count==0){
        UIButton *button=(UIButton*)[_mainScrollView viewWithTag:kSendImageButtonTag+indx];
        [button removeFromSuperview];
        [self updateNeedSendImageView];
    }else{
        [self updateNeedSendImageView];
    }
    
}
#pragma mark - 检证邮箱
-(BOOL) validateEmail:(NSString *)emailName andIsBox:(BOOL)isBox
{
         NSString *email;
        email=emailName;
    if(isBox){
    //邮箱
    }
    else{
    //邮箱名
        for(ContactsModel *oneModel in  [MailGlobalData getInstance].contactsArray){
            if([oneModel.disPlayName isEqual:emailName]){
                email=oneModel.mailBox;
            }
        }

    }
       NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

#pragma mark-通讯录搜索
-(void)textFieldDidChange:(UITextField*)textFild{
    if(textFild.text.length>0){
        searchView.hidden=NO;
          searchView.searchTextFild.text=textFild.text;
         [searchView reloadDataTableViewBy:textFild.text];
         searchView.currTextFild=textFild;
    }
    else{
        searchView.hidden=YES;
    }
    if(textFild==_textFild1){
        searchView.serchLB.text=@"收件人";
    }
    if(textFild==_textFild2){
        searchView.serchLB.text=@"抄送：";
    }
    if(textFild==_textFild3){
        searchView.serchLB.text=@"密送：";
    }
   
}
#pragma mark - 
-(void)SelectTextFild:(UITextField*)textFild andModel:(ContactsModel*)oneModel{
    
    if(textFild==_textFild1){
        [self setNewLayOut:lastButton1 InView:_view1 changeHeightConstrant:_heightConstrant1 andTitleString:oneModel.disPlayName andLeftWidth:leftWidth1 andViewHeight:viewHeight1];
        
        [toArray addObject:oneModel];
    }
    
    if(textFild==_textFild2){
        [self setNewLayOut:lastButton2 InView:_view2 changeHeightConstrant:_heightConstrant2 andTitleString:oneModel.disPlayName andLeftWidth:leftWidth2 andViewHeight:viewHeight2];
        
        [ccArray addObject:oneModel];
    }
    if(textFild==_textFild3){
        [self setNewLayOut:lastButton3 InView:_view3 changeHeightConstrant:_heigthConstrant3 andTitleString:oneModel.disPlayName andLeftWidth:leftWidth3 andViewHeight:viewHeight3];
        
        [bccArray addObject:oneModel];
    }
    
        textFild.text=@"";


}
-(void)cancelSelect:(UITextField*)textFild andText:(NSString*)textString{
    textFild.text=textString;
    [textFild becomeFirstResponder];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{

}
#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
  
    if(buttonIndex==1){
      //保存草稿
        NSString *myEmail=[MailDataObject getInstance].userName;
        NSString *_passwordCopy=[MailDataObject getInstance].passWord;
        [[MailDataObject getInstance]saveEmailtoDraftFromDisplayName:myEmail fromMaiBox:_passwordCopy toArray:toArray ccArray:ccArray bccArray:bccArray subject:_subjectTextFild.text content:_connectTextView.text file:self.arrDataSources resultBlock:^(NSError *error) {
            NSLog(@"保存草稿箱＝%@",error);
        }];
         [self dismissViewControllerAnimated:YES completion:nil];
    }
    else if(buttonIndex==0){
         [self dismissViewControllerAnimated:YES completion:nil];
    }

}
@end
