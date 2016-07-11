//
//  ViewController.m
//  mailcoreDemo
//
//  Created by ios－dai on 16/6/7.
//  Copyright © 2016年 ios－dai. All rights reserved.
//

#import "ViewController.h"
#import "MailHomeVC.h"
#import "MailDataObject.h"
#import "MRProgressOverlayView.h"

@interface ViewController ()
{
    MRProgressOverlayView *progressView;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     NSUserDefaults  *userDefaults=[NSUserDefaults standardUserDefaults];
    NSString *userName=[userDefaults objectForKey:@"userDefault_userName"];
     NSString *password=[userDefaults objectForKey:@"userDefault_passWord"];
    
    if(userName){
        self.userNameTfd.text=userName;
    }
    if(password){
        self.passWordTfd.text=password;
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
}

- (IBAction)login:(id)sender {
    
    NSString *userName=self.userNameTfd.text;
    NSString *passWord=self.passWordTfd.text;
    
    if(userName.length>0&&passWord.length>0){
    progressView=[MRProgressOverlayView showOverlayAddedTo:self.view title:@"正在登陆..." mode:MRProgressOverlayViewModeDeterminateCircular animated:YES];
    [[MailDataObject getInstance] loadAccountWithUsername:userName password:passWord oauth2Token:nil andErrorBlock:^(NSError *error) {
         [progressView dismiss:YES];
        if(error==nil){
            [MailDataObject getInstance].userName=userName;
            [MailDataObject getInstance].passWord=passWord;
            
              NSUserDefaults  *userDefaults=[NSUserDefaults standardUserDefaults];
            [userDefaults setObject:userName forKey:@"userDefault_userName"];
            [userDefaults setObject:passWord forKey:@"userDefault_passWord"];
            [userDefaults synchronize];
            
            MailHomeVC *mailVC=[[MailHomeVC alloc]init];
            [self.navigationController pushViewController:mailVC animated:YES];
        
        }
        else{
            
            NSString *errorString=[NSString stringWithFormat:@"%@",error];
            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"登陆失败" message:errorString delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
            
        }
        
        
    }];
    }
    
   
    
}
@end
