//
//  MailModel.h
//  mailcoreDemo
//
//  Created by XuRuiBang on 16/6/17.
//  Copyright © 2016年 ios－dai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MailModel : NSObject

@property (nullable, nonatomic, retain) NSString *username;
@property (nullable, nonatomic, retain) NSNumber *uid;
@property (nullable, nonatomic, retain) NSNumber *flags;
@property (nullable, nonatomic, retain) NSString *displayName;
@property (nullable, nonatomic, retain) NSDate *date;
@property (nullable, nonatomic, retain) NSString *subject;
@property (nullable, nonatomic, retain) NSString *body;

@end
