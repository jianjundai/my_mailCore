//
//  Contacts+CoreDataProperties.h
//  mailcoreDemo
//
//  Created by ios－dai on 16/6/23.
//  Copyright © 2016年 ios－dai. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Contacts.h"

NS_ASSUME_NONNULL_BEGIN

@interface Contacts (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *disPlayName;
@property (nullable, nonatomic, retain) NSString *mailBox;
@property (nullable, nonatomic, retain) NSString *userName;
@property (nullable, nonatomic, retain) NSNumber *contactsType;
@end

NS_ASSUME_NONNULL_END
