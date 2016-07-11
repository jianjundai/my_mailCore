//
//  MailGlobalData.m
//  mailcoreDemo
//
//  Created by ios－dai on 16/6/22.
//  Copyright © 2016年 ios－dai. All rights reserved.
//

#import "MailGlobalData.h"

@implementation MailGlobalData

static MailGlobalData* MailGlobalData_self = nil;
+(MailGlobalData*)getInstance{
    
    if (MailGlobalData_self == nil) {
        MailGlobalData_self = [[MailGlobalData alloc]init];
        
    }
    return MailGlobalData_self;
}

- (instancetype)init{
    self=[super init];
    if(self){
          
    
    }
    return self;

}

@end
