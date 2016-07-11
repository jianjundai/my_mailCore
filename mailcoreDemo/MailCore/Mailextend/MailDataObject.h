//
//  MailDataObject.h
//  mailcoreDemo
//
//  Created by ios－dai on 16/6/7.
//  Copyright © 2016年 ios－dai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MailCore/MailCore.h>
#import <UIKit/UIKit.h>

#import "MRProgressOverlayView.h"

//声明一个无返回值的block
//typedef void(^updateBlock)(NSError *error);

@interface MailDataObject : NSObject

@property (nonatomic, strong) MRProgressOverlayView *progressView;

@property (nonatomic, strong) MCOIMAPOperation *imapCheckOp;
@property (nonatomic, strong) MCOIMAPSession *imapSession;
@property (nonatomic, strong) MCOIMAPFetchMessagesOperation *imapMessagesFetchOp;


@property (nonatomic, strong) NSArray *messages;
@property (nonatomic) NSInteger totalNumberOfInboxMessages;


@property(nonatomic,strong)NSString *userName;
@property(nonatomic,strong)NSString *passWord;

@property(nonatomic,strong)NSMutableArray *secondContantsMuArray;//新增加的
@property(nonatomic,strong)NSMutableArray *contantsMuArray; //第一次获取的


+(MailDataObject*)getInstance;

//登录收件箱
- (void)loadAccountWithUsername:(NSString *)username
                       password:(NSString *)password
                    oauth2Token:(NSString *)oauth2Token
                    andErrorBlock:(void(^)(NSError *error))errorBlock;

/*
 发送邮件
 */
-(void)sendEmail:(NSString*)hosName
            port:(int)port
        userName:(NSString*)userName
        password:(NSString*)password
 fromDisplayName:(NSString*)fromDisplayName
      fromMaiBox:(NSString*)fromMaiBox
         toArray:(NSArray*)toArray
         ccArray:(NSArray*)ccArray
        bccArray:(NSArray*)bccArray
         subject:(NSString*)subject
         content:(NSString*)content
         file:(NSArray*)fileArray
     resultBlock:(void(^)(NSError* error))resultBlock;
/*
 保存到草稿箱
 */
-(void)saveEmailtoDraftFromDisplayName:(NSString*)fromDisplayName
                            fromMaiBox:(NSString*)fromMaiBox
                               toArray:(NSArray*)toArray
                               ccArray:(NSArray*)ccArray
                              bccArray:(NSArray*)bccArray
                               subject:(NSString*)subject
                               content:(NSString*)content
                                  file:(NSArray*)fileArray
                               resultBlock:(void(^)(NSError* error))resultBlock;





/*
 获取数据
 nMessages：最新数据条数
 */
- (void)loadLastNMessages:(NSUInteger)nMessages withFolder:(NSString*)folder andCompletionBlock:(void (^)(NSError * __nullable error, NSArray * /* MCOIMAPMessage */ __nullable messages, MCOIndexSet * __nullable vanishedMessages))completionBlock;
- (void)loadLastUid:(NSUInteger)nMessages withFolder:(NSString*)folder andCompletionBlock:(void (^)(NSError * __nullable error, NSArray * /* MCOIMAPMessage */ __nullable messages, MCOIndexSet * __nullable vanishedMessages))completionBlock;
- (void)getMessageWithInt:(NSUInteger)nMessages withFolder:(NSString*)folder andCompletionBlock:(void (^)(NSError * __nullable error, NSArray * /* MCOIMAPMessage */ __nullable messages, MCOIndexSet * __nullable vanishedMessages))completionBlock;

- (void)updateFlags:(MCOMessageFlag)newFlags isAdd:(BOOL)i withUid:(MCOIndexSet*)indexSet inFolder:(NSString*)folder withBlock:(void(^)(NSError * error))completionBlock;
- (void)completeDeleteWithUid:(MCOIndexSet*)indexSet inFolder:(NSString*)folder withBlock:(nullable void(^)(NSError * error))completionBlock;

- (void)getMailFolder;

- (void)getDetailMessageHtmlWithUid:(int)uid withFolder:(NSString*)folder with:(void(^)(NSMutableDictionary*))successBlock;
- (void)searchMailWithString:(NSString*)string withKind:(NSInteger)kindInt with:(void(^)(NSError * __nullable error, MCOIndexSet * searchResult))successBlock;
- (void)searchMessages:(MCOIndexSet*)messageSet withFolder:(NSString*)folder andCompletionBlock:(void (^)(NSError * __nullable error, NSArray * /* MCOIMAPMessage */ __nullable messages, MCOIndexSet * __nullable vanishedMessages))completionBlock;
//移动至文件夹
- (void)moveFolderWithUid:(MCOIndexSet*)indexSet from:(NSString*)source to:(NSString*)dest withBlock:(void(^)(NSError * error,NSDictionary * uidMapping))completionBlock;
- (void)getRedFlagMessage:(NSArray*)messageArray withBlock:(void(^)(NSArray* arr))completionBlock;




@end
