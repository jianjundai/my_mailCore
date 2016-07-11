//
//  Mail+CoreDataProperties.h
//  mailcoreDemo
//
//  Created by XuRuiBang on 16/6/17.
//  Copyright © 2016年 ios－dai. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Mail.h"

NS_ASSUME_NONNULL_BEGIN

@interface Mail (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *username;
@property (nullable, nonatomic, retain) NSNumber *uid;
@property (nullable, nonatomic, retain) NSNumber *flags;
@property (nullable, nonatomic, retain) NSString *displayName;
@property (nullable, nonatomic, retain) NSDate *date;
@property (nullable, nonatomic, retain) NSString *subject;
@property (nullable, nonatomic, retain) NSString *body;

@end

NS_ASSUME_NONNULL_END
