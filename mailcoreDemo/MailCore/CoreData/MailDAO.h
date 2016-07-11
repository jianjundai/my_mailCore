//
//  MailDAO.h
//  mailcoreDemo
//
//  Created by XuRuiBang on 16/6/17.
//  Copyright © 2016年 ios－dai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoredataDAO.h"
#import "Mail.h"
#import "MailModel.h"
#import "Contacts.h"
#import "ContactsModel.h"

@interface MailDAO :CoredataDAO
+ (MailDAO*)sharedManager;
-(int)create:(MailModel*)model;
-(MailModel*)getMailByKey:(NSString*)username;
- (NSMutableDictionary* )getUidByKey:(NSString*)username;
- (MailModel*)getMailByUsername:(NSString*)username withUid:(NSNumber*)uid;

//通讯录
-(void)insertOneContacts:(NSArray*)oneModelArray;
//获取所有联系人
-(void)getAllContactsResultBlock:(void(^)(NSArray* resultArray))resultBlock;

//获取常用联系人
-(void)getFrequentContactsResultBlock:(void(^)(NSArray* resultArray))resultBlock;


-(BOOL)isExistMailBox:(NSString*)mailBox;

@end
