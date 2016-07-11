//
//  MailDAO.m
//  mailcoreDemo
//
//  Created by XuRuiBang on 16/6/17.
//  Copyright © 2016年 ios－dai. All rights reserved.
//

#import "MailDAO.h"
#import "MailDataObject.h"
@implementation MailDAO
static MailDAO *sharedManager = nil;

+ (MailDAO*)sharedManager{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        
        sharedManager = [[self alloc] init];
        [sharedManager managedObjectContext];
        
    });
    return sharedManager;
}

- (int)create:(MailModel*)model{
    
    NSManagedObjectContext *cxt = [self managedObjectContext];
    
    Mail *mail = [NSEntityDescription insertNewObjectForEntityForName:@"Mail" inManagedObjectContext:cxt];
    [mail setValue:model.username forKey:@"username"];
    [mail setValue:model.uid forKey:@"uid"];
    [mail setValue:model.flags forKey:@"flags"];
    [mail setValue:model.displayName forKey:@"displayName"];
    [mail setValue:model.date forKey:@"date"];
    [mail setValue:model.subject forKey:@"subject"];
    [mail setValue:model.body forKey:@"body"];

    
    NSError *savingError = nil;
    if ([self.managedObjectContext save:&savingError]){
        NSLog(@"插入数据成功");
    } else {
        NSLog(@"插入数据失败");
        return -1;
    }
    
    return 0;
}

- (NSMutableArray* /*MailModel* */)getMailByKey:(NSString*)username{
    NSManagedObjectContext *cxt = [self managedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"Mail" inManagedObjectContext:cxt];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"username = %@",username];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *listData = [cxt executeFetchRequest:request error:&error];
    NSMutableArray* arr = [NSMutableArray array];
    if ([listData count] > 0) {
        for (Mail *mail in listData) {
            MailModel *mailModel = [[MailModel alloc] init];
            mailModel.username = mail.username;
            mailModel.uid = mail.uid;
            mailModel.flags = mail.flags;
            mailModel.displayName = mail.displayName;
            mailModel.date = mail.date;
            mailModel.subject = mail.subject;
            mailModel.body = mail.body;
            [arr addObject:mailModel];
        }
        [arr sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            if ([[obj1 valueForKey:@"date"]timeIntervalSinceDate:[obj2 valueForKey:@"date"]]) {
                return obj1;
            } else {
                return obj2;
            }
            
        }];
        return arr;
    }
    return nil;
}

- (NSMutableDictionary* )getUidByKey:(NSString*)username{
    NSManagedObjectContext *cxt = [self managedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"Mail" inManagedObjectContext:cxt];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"username = %@",username];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *listData = [cxt executeFetchRequest:request error:&error];
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    if ([listData count] > 0) {
        for (Mail *mail in listData) {
            [dic setValue:mail.flags forKey:[NSString stringWithFormat:@"%@",mail.uid]];
        }
        return dic;
    }
    return nil;
}

- (MailModel*)getMailByUsername:(NSString*)username withUid:(NSNumber*)uid{
    NSManagedObjectContext *cxt = [self managedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"Mail" inManagedObjectContext:cxt];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"(username = %@)AND(uid = %@)",username,uid];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *listData = [cxt executeFetchRequest:request error:&error];
    Mail* mail = [listData lastObject];
    MailModel* mailModel = [[MailModel alloc]init];
    mailModel.username = mail.username;
    mailModel.uid = mail.uid;
    mailModel.flags = mail.flags;
    mailModel.displayName = mail.displayName;
    mailModel.date = mail.date;
    mailModel.subject = mail.subject;
    mailModel.body = mail.body;

    
    return mailModel;

}

-(void)insertOneContacts:(NSArray*)oneModelArray{

     NSManagedObjectContext *cxt = [self managedObjectContext];

   [cxt performBlock:^{
       for(int i=0;i<oneModelArray.count;i++){
               ContactsModel *oneContactsModel=[oneModelArray objectAtIndex:i];
               Contacts *contacts = [NSEntityDescription insertNewObjectForEntityForName:@"Contacts" inManagedObjectContext:cxt];
               [contacts setValue:[MailDataObject getInstance].userName forKey:@"userName"];
               [contacts setValue:oneContactsModel.disPlayName forKey:@"disPlayName"];
               [contacts setValue:oneContactsModel.mailBox forKey:@"mailBox"];
           if(![oneContactsModel.disPlayName isEqual:oneContactsModel.mailBox]){
               //常用联系人
               [contacts setValue:[NSNumber numberWithInteger:1] forKey:@"contactsType"];
           }else{
              [contacts setValue:[NSNumber numberWithInteger:0] forKey:@"contactsType"];
           }
           
               NSError *savingError = nil;
               if ([cxt save:&savingError]){
                   NSLog(@"oneContactsModel插入数据成功");
               } else {
                   NSLog(@"oneContactsModel插入数据失败");
                   
               }
               
           }
    }];

    
}

-(void)getAllContactsResultBlock:(void(^)(NSArray* resultArray))resultBlock{
    
    NSManagedObjectContext *cxt = [self managedObjectContext];
    [cxt performBlock:^{
        NSEntityDescription *entityDescription = [NSEntityDescription
                                                  entityForName:@"Contacts" inManagedObjectContext:cxt];
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                  @"userName = %@",[MailDataObject getInstance].userName];
        [request setPredicate:predicate];
        
        NSError *error = nil;
        NSArray *listData = [cxt executeFetchRequest:request error:&error];
        NSMutableArray* arr = [[NSMutableArray alloc]initWithCapacity:0];
        if ([listData count] > 0) {
            for (Contacts *oneContacts in listData) {
                ContactsModel *oneContactsModel=[[ContactsModel alloc]init];
                oneContactsModel.userName=oneContacts.userName;
                oneContactsModel.disPlayName=oneContacts.disPlayName;
                oneContactsModel.mailBox=oneContacts.mailBox;
                [arr addObject:oneContactsModel];
            }
            
            resultBlock(arr);
        }
        else{
            resultBlock(nil);

        }
        
    }];
}
-(void)getFrequentContactsResultBlock:(void(^)(NSArray* resultArray))resultBlock{
    
    NSManagedObjectContext *cxt = [self managedObjectContext];
    [cxt performBlock:^{
        NSEntityDescription *entityDescription = [NSEntityDescription
                                                  entityForName:@"Contacts" inManagedObjectContext:cxt];
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                  @"(username = %@)AND(contactsType = %d)",[MailDataObject getInstance].userName,[NSNumber numberWithInteger:contactsTypeFrequent]];
        [request setPredicate:predicate];
        
        NSError *error = nil;
        NSArray *listData = [cxt executeFetchRequest:request error:&error];
        NSMutableArray* arr = [[NSMutableArray alloc]initWithCapacity:0];
        if ([listData count] > 0) {
            for (Contacts *oneContacts in listData) {
                ContactsModel *oneContactsModel=[[ContactsModel alloc]init];
                oneContactsModel.userName=oneContacts.userName;
                oneContactsModel.disPlayName=oneContacts.disPlayName;
                oneContactsModel.mailBox=oneContacts.mailBox;
                [arr addObject:oneContactsModel];
            }
            
            resultBlock(arr);
        }
        else{
            resultBlock(nil);
            
        }
        
    }];
}
-(BOOL)isExistMailBox:(NSString*)mailBox{
    NSManagedObjectContext *cxt = [self managedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"Contacts" inManagedObjectContext:cxt];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"(userName = %@)AND(mailBox = %@)",[MailDataObject getInstance].userName,mailBox];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *listData = [cxt executeFetchRequest:request error:&error];
    
    if ([listData count] > 0) {
        
        return YES;
    }
    return NO;
}



@end
