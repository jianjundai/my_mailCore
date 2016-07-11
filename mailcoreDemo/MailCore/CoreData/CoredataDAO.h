//
//  CoredataDAO.h
//  mailcoreDemo
//
//  Created by XuRuiBang on 16/6/17.
//  Copyright © 2016年 ios－dai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoredataDAO : NSObject
//被管理的对象上下文
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
//被管理的对象模型
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
//持久化存储协调者
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory;

@end
