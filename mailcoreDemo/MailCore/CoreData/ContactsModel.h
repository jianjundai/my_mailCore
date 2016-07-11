//
//  ContactsModel.h
//  mailcoreDemo
//
//  Created by ios－dai on 16/6/23.
//  Copyright © 2016年 ios－dai. All rights reserved.
//
typedef enum {
    contactsTypeDefault = 0,
    contactsTypeFrequent = 1,//常用联系人
    contactsTypeRecent = 2//最近联系人（最近发生邮件的联系人）
}contactsType;


#import <Foundation/Foundation.h>

@interface ContactsModel : NSObject
@property (nullable, nonatomic, retain) NSString *disPlayName;
@property (nullable, nonatomic, retain) NSString *mailBox;
@property (nullable, nonatomic, retain) NSString *userName;
@property(nonatomic)contactsType oneContactsType;

@end
