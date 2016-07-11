//
//  MailMessageTVC.m
//  mailcoreDemo
//
//  Created by XuRuiBang on 16/6/20.
//  Copyright © 2016年 ios－dai. All rights reserved.
//

#import "MailMessageVC.h"
#import "Masonry.h"
#import "AttachmentsTV.h"
#import <MailCore/MailCore.h>
#import "MailBodyWebView.h"
#import "MailDataObject.h"
#import "FolderShiftTVC.h"
#import "MailSendVC.h"
#import "SVProgressHUD.h"

#define Kscreenwidth [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height

static NSString * mainJavascript = @"\
var imageElements = function() {\
var imageNodes = document.getElementsByTagName('img');\
return [].slice.call(imageNodes);\
};\
\
var findCIDImageURL = function() {\
var images = imageElements();\
\
var imgLinks = [];\
for (var i = 0; i < images.length; i++) {\
var url = images[i].getAttribute('src');\
if (url.indexOf('cid:') == 0 || url.indexOf('x-mailcore-image:') == 0)\
imgLinks.push(url);\
}\
return JSON.stringify(imgLinks);\
};\
\
var replaceImageSrc = function(info) {\
var images = imageElements();\
\
for (var i = 0; i < images.length; i++) {\
var url = images[i].getAttribute('src');\
if (url.indexOf(info.URLKey) == 0) {\
images[i].setAttribute('src', info.LocalPathKey);\
break;\
}\
}\
};\
";

@interface MailMessageVC ()<UIWebViewDelegate,UITableViewDelegate,UITableViewDataSource>


@end

@implementation MailMessageVC{
    BOOL isUnfold;
    float cellHeight;
    float webHeight;
    float attachmentsHeight;
    MailBodyWebView * _webView;
    UITableView* _tableView;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect rect = self.view.frame;
    rect.size.height = rect.size.height - 45;
    _tableView = [[UITableView alloc]initWithFrame:rect style:UITableViewStyleGrouped];
    _tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, _tableView.bounds.size.width, 0.01f)];
    [self.view addSubview:_tableView];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.allowsSelection = NO;
    _tableView.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBarHidden = NO;
    self.title = @"邮件详情";
    [self setFlagBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setFlagBar{
    
    UIView* flagView = [[UIView alloc]init];
    [self.view addSubview:flagView];
    [flagView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view);
        make.right.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.view);
        make.height.mas_equalTo(45);
    }];
    UIButton* btn1 = [[UIButton alloc]init];
    UIButton* btn2 = [[UIButton alloc]init];
    UIButton* btn3 = [[UIButton alloc]init];
    UIButton* btn4 = [[UIButton alloc]init];
    [flagView addSubview:btn1];
    [flagView addSubview:btn2];
    [flagView addSubview:btn3];
    [flagView addSubview:btn4];
    [btn1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(flagView);
        make.top.mas_equalTo(flagView);
        make.bottom.mas_equalTo(flagView);
        make.width.mas_equalTo(Kscreenwidth/4);
    }];
    [btn2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(btn1.mas_right);
        make.top.mas_equalTo(flagView);
        make.bottom.mas_equalTo(flagView);
        make.width.mas_equalTo(Kscreenwidth/4);
    }];
    [btn3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(btn2.mas_right);
        make.top.mas_equalTo(flagView);
        make.bottom.mas_equalTo(flagView);
        make.width.mas_equalTo(Kscreenwidth/4);
    }];
    [btn4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(btn3.mas_right);
        make.top.mas_equalTo(flagView);
        make.bottom.mas_equalTo(flagView);
        make.width.mas_equalTo(Kscreenwidth/4);
    }];
    flagView.backgroundColor = [UIColor colorWithRed:239/255.0 green:239/255.0 blue:239/255.0 alpha:1.0];
    [btn1 setImage:[UIImage imageNamed:@"mail_other_73"] forState:0];
    [btn2 setImage:[UIImage imageNamed:@"mail_other_75"] forState:0];
    [btn3 setImage:[UIImage imageNamed:@"mail_other_78"] forState:0];
    [btn4 setImage:[UIImage imageNamed:@"mail_other_80"] forState:0];
    [btn1 setTag:21];
    [btn2 setTag:22];
    [btn3 setTag:23];
    [btn4 setTag:24];
    [btn1 addTarget:self action:@selector(clickFlagBtn:) forControlEvents:UIControlEventTouchUpInside];
    [btn2 addTarget:self action:@selector(clickFlagBtn:) forControlEvents:UIControlEventTouchUpInside];
    [btn3 addTarget:self action:@selector(clickFlagBtn:) forControlEvents:UIControlEventTouchUpInside];
    [btn4 addTarget:self action:@selector(clickFlagBtn:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)clickFlagBtn:(UIButton*)btn{
    MCOIndexSet* set = [MCOIndexSet indexSet];
    [set addIndex:[_messageDic[@"uid"] intValue]];
    MailDataObject* mailCtrl = [MailDataObject getInstance];
    switch (btn.tag) {
        case 21:
        {
            [SVProgressHUD showWithStatus:@"标记红旗"];
            [mailCtrl updateFlags:MCOMessageFlagFlagged isAdd:YES withUid:set inFolder:_folder  withBlock:^(NSError *error) {
                if (!error) {
                    //
                }
            }];
        }
            break;
        case 22:
        {
            UIAlertController* alt = [UIAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
            [alt addAction:[UIAlertAction actionWithTitle:@"回复" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                MailSendVC *sendVc=[[MailSendVC alloc]init];
                sendVc.sendType=MailSendReply;
                sendVc.messageDict=self.messageDic;
                UINavigationController *nav=[[UINavigationController alloc]initWithRootViewController:sendVc];
                [self presentViewController:nav animated:YES completion:nil];
                
                
                
               
            }]];
            [alt addAction:[UIAlertAction actionWithTitle:@"回复全部" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                MailSendVC *sendVc=[[MailSendVC alloc]init];
                sendVc.sendType=MailSendReplyAll;
                sendVc.messageDict=self.messageDic;
                UINavigationController *nav=[[UINavigationController alloc]initWithRootViewController:sendVc];
                [self presentViewController:nav animated:YES completion:nil];
                
                

                
            }]];
            [alt addAction:[UIAlertAction actionWithTitle:@"转发" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                MailSendVC *sendVc=[[MailSendVC alloc]init];
                sendVc.sendType=MailSendForwarding;
                sendVc.messageDict=self.messageDic;
                UINavigationController *nav=[[UINavigationController alloc]initWithRootViewController:sendVc];
                [self presentViewController:nav animated:YES completion:nil];
                

                
            }]];
            [alt addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
            [self presentViewController:alt animated:YES completion:nil];
        }
            break;
        case 23:
        {
            [SVProgressHUD showWithStatus:@"删除邮件"];
            [mailCtrl updateFlags:MCOMessageFlagDeleted isAdd:YES withUid:set inFolder:_folder  withBlock:^(NSError *error) {
                if (!error) {
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }];
        }
            break;
        case 24:
        {
            UIAlertController* alt = [UIAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
            [alt addAction:[UIAlertAction actionWithTitle:@"移动" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                FolderShiftTVC* folderTVC = [[FolderShiftTVC alloc]init];
                folderTVC.sourceFolder = _folder;
                folderTVC.indexSet = set;
                [self.navigationController pushViewController:folderTVC animated:YES];
            }]];
            [alt addAction:[UIAlertAction actionWithTitle:@"彻底删除" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [SVProgressHUD showWithStatus:@"彻底删除邮件"];
                [mailCtrl completeDeleteWithUid:set inFolder:_folder withBlock:^(NSError *error) {
                    if (!error) {
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                }];
            }]];
            [alt addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];

        }
            break;
        default:
            break;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat i = 44.0;
    if ((indexPath.row == 1)&&(isUnfold)) {
        i = cellHeight;//UITableViewAutomaticDimension
    }
    if (indexPath.row == 2) {
        i = webHeight;
    }
    if (indexPath.row == 3) {
        i = attachmentsHeight;
    }
    
    return i;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"mailMessage"];
    //    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mailMessage" forIndexPath:indexPath];
    //    if (!cell) {
    //        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"mailMessage"];
    //    }
    UITableViewCell *cell = [[UITableViewCell alloc]init];
    if (indexPath.row == 0) {
        UILabel* sendLab = [[UILabel alloc]init];
        [cell addSubview:sendLab];
        sendLab.text = @"发件人：";
        sendLab.textColor = [UIColor lightGrayColor];
        [sendLab mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(cell).offset(10);
            make.centerY.mas_equalTo(cell);
            make.height.mas_equalTo(30);
        }];
        UIButton* senderBtn = [[UIButton alloc]init];
        [cell addSubview:senderBtn];//
        [self buttonRender:senderBtn];
        [senderBtn setTitle:_messageDic[@"from"] forState:0];
        [senderBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(sendLab.mas_right).offset(5);
            make.centerY.mas_equalTo(cell);
            make.height.mas_equalTo(30);
            make.width.mas_equalTo(senderBtn.intrinsicContentSize.width + 10);
        }];
    }else if (indexPath.row == 1){
        if (!isUnfold) {
            UILabel* toLab = [[UILabel alloc]init];
            toLab.text = @"收件人：";
            toLab.textColor = [UIColor lightGrayColor];
            [cell addSubview:toLab];
            [toLab mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(30);
                make.left.mas_equalTo(cell).offset(10);
                make.top.mas_equalTo(cell).offset(7);
                make.width.mas_equalTo(68);
            }];
            
            NSArray* toArray = _messageDic[@"to"];
            UIView* lastView = toLab;
            __block CGFloat width = 78.0 ;
            __block CGFloat y = 7;
            int kContentMargin = 5;
            int kLeftOffset = 10;
            int kTopOffset = 3;
            int kButtonHeight = 30;
            int kCellHeight = kButtonHeight + kTopOffset * 2;
            __block int j = 0;
            for (int i = 0; i < toArray.count; i++) {
                UIButton* btn = [[UIButton alloc]init];
                [btn setTitle:toArray[i] forState:0];
                [cell addSubview:btn];
                [self buttonRender:btn];
                [btn mas_remakeConstraints:^(MASConstraintMaker *make) {
                    if ((width + btn.intrinsicContentSize.width + kContentMargin * 2 + kLeftOffset) < Kscreenwidth - 20) {
                        make.left.mas_equalTo(lastView.mas_right).offset(kLeftOffset);
                        width = width + btn.intrinsicContentSize.width + kContentMargin * 2 + kLeftOffset;
                        make.top.mas_equalTo(cell).offset(y);
                        make.height.mas_equalTo(kButtonHeight);
                        make.width.mas_equalTo(btn.intrinsicContentSize.width + kContentMargin * 2);
                    }else{
                        j = 1;
                        [btn removeFromSuperview];//bug
                        
                    }
                    
                }];
                lastView = btn;
                if (j == 1) {
                    break;
                }
            }
            
            UIButton* expandBtn = [[UIButton alloc]init];
            [cell addSubview:expandBtn];
            [expandBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(cell).offset(-10);
                make.centerY.mas_equalTo(cell);
                make.size.mas_equalTo(CGSizeMake(22, 10));
            }];
            [expandBtn setImage:[UIImage imageNamed:@"mail_other_58"] forState:0];
            expandBtn.tag = 10;
            [expandBtn addTarget:self action:@selector(expendBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        } else {
            UILabel* toLab = [[UILabel alloc]init];
            toLab.text = @"收件人：";
            toLab.textColor = [UIColor lightGrayColor];
            [cell addSubview:toLab];
            [toLab mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(30);
                make.left.mas_equalTo(cell).offset(10);
                make.top.mas_equalTo(cell).offset(7);
                make.width.mas_equalTo(68);
            }];
            
            NSArray* toArray = _messageDic[@"to"];
            UIView* lastView = toLab;
            __block CGFloat width = 78.0 ;
            __block CGFloat y = 7;
            int kContentMargin = 5;
            int kLeftOffset = 10;
            int kTopOffset = 3;
            int kButtonHeight = 30;
            int kCellHeight = kButtonHeight + kTopOffset * 2;
            for (int i = 0; i < toArray.count; i++) {
                UIButton* btn = [[UIButton alloc]init];
                [btn setTitle:toArray[i] forState:0];
                [cell addSubview:btn];
                [self buttonRender:btn];
                [btn mas_remakeConstraints:^(MASConstraintMaker *make) {
                    if ((width + btn.intrinsicContentSize.width + kContentMargin * 2 + kLeftOffset) < Kscreenwidth) {
                        make.left.mas_equalTo(lastView.mas_right).offset(kLeftOffset);
                        width = width + btn.intrinsicContentSize.width + kContentMargin * 2 + kLeftOffset;
                    }else{
                        make.left.mas_equalTo(cell).offset(kLeftOffset);
                        width = btn.intrinsicContentSize.width + kContentMargin * 2 + kLeftOffset;
                        y = y + kCellHeight;
                        cellHeight = y + kCellHeight;//test
                        
                    }
                    make.top.mas_equalTo(cell).offset(y);
                    make.height.mas_equalTo(kButtonHeight);
                    make.width.mas_equalTo(btn.intrinsicContentSize.width + kContentMargin * 2);
                    if (i == 0) {
                        make.top.mas_equalTo(cell).offset(y);
                    }
                }];
                lastView = btn;
            }
            //            [cell mas_makeConstraints:^(MASConstraintMaker *make) {
            //                make.left.mas_equalTo(scrView);
            //                make.right.mas_equalTo(scrView);
            //                make.top.mas_equalTo(scrView).offset(45);
            //                make.height.mas_equalTo(44 + y);
            //            }];
            
            UIButton* expandBtn = [[UIButton alloc]init];
            [cell addSubview:expandBtn];
            [expandBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                if ((width + expandBtn.intrinsicContentSize.width + kContentMargin * 2 + kLeftOffset) < Kscreenwidth) {
                    make.left.mas_equalTo(lastView.mas_right).offset(kLeftOffset);
                    width = width + expandBtn.intrinsicContentSize.width + kContentMargin * 2 + kLeftOffset;
                }else{
                    make.left.mas_equalTo(cell).offset(kLeftOffset);
                    width = expandBtn.intrinsicContentSize.width + kContentMargin * 2 + kLeftOffset;
                    y = y + kCellHeight;
                    cellHeight = y;
                }
                make.top.mas_equalTo(cell).offset(y);
                make.height.mas_equalTo(kButtonHeight);
                make.width.mas_equalTo(expandBtn.intrinsicContentSize.width + kContentMargin * 2);
                
            }];
            [expandBtn setImage:[UIImage imageNamed:@"mail_other_59"] forState:0];
            expandBtn.tag = 11;
            [expandBtn addTarget:self action:@selector(expendBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            
        }
    }else if (indexPath.row == 2){
        _webView = [[MailBodyWebView alloc]init];
        _webView.message = _messageDic[@"message"];
        //去附件
        NSString* bodyHtml = _messageDic[@"body"];
        NSArray* bodyArr = [bodyHtml componentsSeparatedByString:@"<hr/>"];
        bodyHtml = bodyArr[0];
        
        NSMutableString * html = [NSMutableString string];
        [html appendFormat:@"<html><head><script>%@</script></head>"
         @"<body>%@</body><iframesrc='x-mailcore-msgviewloaded:' style='width: 0px; height: 0px; border:none;'>"
         @"</iframe></html>", mainJavascript,bodyHtml];
        [_webView loadHTMLString:html baseURL:nil];
        [cell addSubview:_webView];
        _webView.scrollView.scrollEnabled = NO;
        //        webHeight = webView.scrollView.contentSize.height;
        webHeight = [[_webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight"]floatValue];
        //        UIView* webDocView = webView.scrollView.subviews.lastObject;
        //        if([webDocView isKindOfClass:[NSClassFromString(@"UIWebDocumentView")class]]){
        //            webHeight = webDocView.frame.size.height;
        //        }
        
        [_webView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(cell);
            make.right.mas_equalTo(cell);
            make.top.mas_equalTo(cell);
            make.height.mas_equalTo(webHeight);
        }];
        
        
    }else if (indexPath.row == 3){
        NSMutableArray *attachments = [[NSMutableArray alloc]initWithArray:_messageDic[@"attachments"]];
        if (attachments.count != 0) {
            AttachmentsTV* attTV = [[AttachmentsTV alloc]init];//WithFrame:self.view.frame
            attTV.attachmentsArray = [[NSMutableArray alloc]initWithArray:_messageDic[@"attachments"]];
            attachmentsHeight = [attTV attachmentsHeight];
            UIView* mView = [[UIView alloc]init];
            [mView.layer setCornerRadius:5.0];
            [mView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
            [mView.layer setBorderWidth:1.0];
            [cell addSubview:mView];
            [mView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(cell).offset(15);
                make.right.mas_equalTo(cell).offset(-15);
                make.top.mas_equalTo(cell).offset(10);
                make.bottom.mas_equalTo(cell).offset(-10);
            }];
            [mView addSubview:attTV];
            [attTV mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(mView);
                make.right.mas_equalTo(mView);
                make.top.mas_equalTo(mView);
                make.bottom.mas_equalTo(mView);
            }];
        }
    }
    
    return cell;
}

//- (void)webViewDidFinishLoad:(UIWebView *)webView{
//    webHeight = webView.scrollView.contentSize.height;
//    [self .tableView reloadData];
//}


- (void)expendBtnClick:(UIButton*)btn{
    if (btn.tag == 10) {
        isUnfold = YES;
    }else if (btn.tag == 11){
        isUnfold = NO;
    }
    [_tableView reloadData];
}

- (void)buttonRender:(UIButton*)btn{
    [btn setTitleColor:[UIColor darkGrayColor] forState:0];
    [btn setBackgroundColor:[UIColor colorWithRed:234/255.0 green:242/255.0 blue:245/255.0 alpha:1.0]];
    [btn.layer setCornerRadius:15.0];
    [btn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    btn.contentHorizontalAlignment = 0;
    [btn.layer setBorderWidth:1.0];
    [btn.layer setBorderColor:[UIColor colorWithRed:38/255.0 green:152/255.0 blue:241/255.0 alpha:1.0].CGColor];
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
