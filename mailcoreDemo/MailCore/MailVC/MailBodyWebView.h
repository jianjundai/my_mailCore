//
//  MailBodyWebView.h
//  mailcoreDemo
//
//  Created by XuRuiBang on 16/6/23.
//  Copyright © 2016年 ios－dai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MailCore/MailCore.h>

@interface MailBodyWebView : UIWebView<UIWebViewDelegate>
@property(nonatomic,strong)NSString* html;
@property(nonatomic,strong)MCOAbstractMessage* message;
@end
