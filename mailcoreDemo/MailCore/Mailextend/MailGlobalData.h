//
//  MailGlobalData.h
//  mailcoreDemo
//
//  Created by ios－dai on 16/6/22.
//  Copyright © 2016年 ios－dai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MailGlobalData : NSObject
+(MailGlobalData*)getInstance;

//通讯录
@property(nonatomic,retain)NSArray *contactsArray;

//草稿箱
@property(nonatomic,retain)NSArray *toArray;  //收件人





@end
