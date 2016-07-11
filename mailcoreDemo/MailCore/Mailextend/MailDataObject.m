//
//  MailDataObject.m
//  mailcoreDemo
//
//  Created by ios－dai on 16/6/7.
//  Copyright © 2016年 ios－dai. All rights reserved.
//

#import "MailDataObject.h"
#import "MailDAO.h"

 #import <AudioToolbox/AudioToolbox.h>
#import "MailDefine.h"

#import "MailDataObject.h"
#import "MailGlobalData.h"
#import "ContactsModel.h"
#import "SVProgressHUD.h"

static SystemSoundID shake_sound_male_id = 0;
#define NUMBER_OF_MESSAGES_TO_LOAD		10

@implementation MailDataObject

static MailDataObject* MailDataObject_self = nil;
+(MailDataObject*)getInstance{

    if (MailDataObject_self == nil) {
        MailDataObject_self = [[MailDataObject alloc]init];
        
        
    }
    return MailDataObject_self;
}
-(id)init{
    self=[super init];
    if(self){
        _contantsMuArray=[[NSMutableArray alloc]initWithCapacity:0];
        _secondContantsMuArray=[[NSMutableArray alloc]initWithCapacity:0];
        
    }
    return self;
}

#pragma mark - 登录验证邮箱
- (void)loadAccountWithUsername:(NSString *)username
                       password:(NSString *)password
                    oauth2Token:(NSString *)oauth2Token
                  andErrorBlock:(void(^)(NSError *error))errorBlock
{
   
    self.imapSession = [[MCOIMAPSession alloc] init];
    NSArray *userNmaeArray=[username componentsSeparatedByString:@"@"];
    if(userNmaeArray.count==2){
        self.imapSession.hostname = [NSString stringWithFormat:@"imap.%@",[userNmaeArray objectAtIndex:1]];
    }
    else{
        // self.imapSession.hostname = @"imap.midea.com.cn";
    }
    
    self.imapSession.port = 993;
    self.imapSession.username = username;
    self.imapSession.password = password;
    [self.imapSession setCheckCertificateEnabled:NO];
    if (oauth2Token != nil) {
        self.imapSession.OAuth2Token = oauth2Token;
        self.imapSession.authType = MCOAuthTypeXOAuth2;
    }
    self.imapSession.connectionType = MCOConnectionTypeTLS;
    MailDataObject * __weak weakSelf = self;
    self.imapSession.connectionLogger = ^(void * connectionID, MCOConnectionLogType type, NSData * data) {
        @synchronized(weakSelf) {
            if (type != MCOConnectionLogTypeSentPrivate) {
                //                NSLog(@"event logged:%p %i withData: %@", connectionID, type, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            }
        }
    };
    
    self.messages = nil;
    self.totalNumberOfInboxMessages = -1;
    
    NSLog(@"checking account");
    self.imapCheckOp = [self.imapSession checkAccountOperation];
    [self.imapCheckOp start:^(NSError *error) {
        NSLog(@"finished checking account.");
         errorBlock(error);
         MailDataObject *strongSelf = weakSelf;
        strongSelf.imapCheckOp = nil;
        
         [self getMailFolder];
    }];
}

- (void)loadLastNMessages:(NSUInteger)nMessages withFolder:(NSString*)folder andCompletionBlock:(void (^)(NSError * __nullable error, NSArray * /* MCOIMAPMessage */ __nullable messages, MCOIndexSet * __nullable vanishedMessages))completionBlock
{
    
    nMessages=(nMessages+1)*10;
    
    MCOIMAPMessagesRequestKind requestKind = (MCOIMAPMessagesRequestKind)
    (MCOIMAPMessagesRequestKindHeaders | MCOIMAPMessagesRequestKindStructure |
     MCOIMAPMessagesRequestKindInternalDate | MCOIMAPMessagesRequestKindHeaderSubject |
     MCOIMAPMessagesRequestKindFlags);

    MCOIMAPFolderInfoOperation *inboxFolderInfo = [self.imapSession folderInfoOperation:folder];
    
    [inboxFolderInfo start:^(NSError *error, MCOIMAPFolderInfo *info)
     {
         BOOL totalNumberOfMessagesDidChange =
         
         self.totalNumberOfInboxMessages != [info messageCount];
         
         self.totalNumberOfInboxMessages = [info messageCount];
         
         NSUInteger numberOfMessagesToLoad =
         MIN(self.totalNumberOfInboxMessages, nMessages);
         
         if (numberOfMessagesToLoad == 0)
         {
             NSLog(@"已更新所有");
             completionBlock(error, @[],nil);
             return;
         }
         
         MCORange fetchRange;
         
         // If total number of messages did not change since last fetch,
         // assume nothing was deleted since our last fetch and just
         // fetch what we don't have
         if (!totalNumberOfMessagesDidChange && self.messages.count)
         {
             numberOfMessagesToLoad -= self.messages.count;
             
             fetchRange =
             MCORangeMake(self.totalNumberOfInboxMessages -
                          self.messages.count -
                          (numberOfMessagesToLoad - 1),
                          (numberOfMessagesToLoad - 1));
         }
         
         // Else just fetch the last N messages
         else
         {
             fetchRange =
             MCORangeMake(self.totalNumberOfInboxMessages -
                          (numberOfMessagesToLoad - 1),
                          (numberOfMessagesToLoad - 1));
         }
         
         self.imapMessagesFetchOp =
         [self.imapSession fetchMessagesByNumberOperationWithFolder:folder
                                                        requestKind:requestKind
                                                            numbers:
          [MCOIndexSet indexSetWithRange:fetchRange]];
         
         [self.imapMessagesFetchOp setProgress:^(unsigned int progress) {
             
         }];
         
         __weak MailDataObject *weakSelf = self;
         [self.imapMessagesFetchOp start:
          ^(NSError *error, NSArray *messages, MCOIndexSet *vanishedMessages)
          {
              MailDataObject *strongSelf = weakSelf;
              
              NSSortDescriptor *sort =
              [NSSortDescriptor sortDescriptorWithKey:@"header.date" ascending:NO];
              
              NSMutableArray *combinedMessages =
              [NSMutableArray arrayWithArray:messages];
              
              [combinedMessages addObjectsFromArray:strongSelf.messages];
              
              strongSelf.messages =
              [combinedMessages sortedArrayUsingDescriptors:@[sort]];
              
              completionBlock(error, strongSelf.messages,vanishedMessages);
              
              //存通讯录
              if(nMessages==10){
                
                      [self getContactsByMailHeader];
              
              }
           
              
          }];
     }];
}

- (void)loadLastUid:(NSUInteger)nMessages withFolder:(NSString*)folder andCompletionBlock:(void (^)(NSError * __nullable error, NSArray * /* MCOIMAPMessage */ __nullable messages, MCOIndexSet * __nullable vanishedMessages))completionBlock
{
    
    MCOIMAPMessagesRequestKind requestKind = (MCOIMAPMessagesRequestKind)
    (MCOIMAPMessagesRequestKindUid|MCOIMAPMessagesRequestKindFlags);
    
    //    NSString *inboxFolder = @"INBOX";
    MCOIMAPFolderInfoOperation *inboxFolderInfo = [self.imapSession folderInfoOperation:folder];
    
    [inboxFolderInfo start:^(NSError *error, MCOIMAPFolderInfo *info)
     {
         BOOL totalNumberOfMessagesDidChange =
         self.totalNumberOfInboxMessages != [info messageCount];
         
         self.totalNumberOfInboxMessages = [info messageCount];
         
         NSUInteger numberOfMessagesToLoad =
         MIN(self.totalNumberOfInboxMessages, nMessages);
         
         if (numberOfMessagesToLoad == 0)
         {
             //  self.isLoading = NO;
             return;
         }
         
         MCORange fetchRange;
         
         // If total number of messages did not change since last fetch,
         // assume nothing was deleted since our last fetch and just
         // fetch what we don't have
         if (!totalNumberOfMessagesDidChange && self.messages.count)
         {
             numberOfMessagesToLoad -= self.messages.count;
             
             fetchRange =
             MCORangeMake(self.totalNumberOfInboxMessages -
                          self.messages.count -
                          (numberOfMessagesToLoad - 1),
                          (numberOfMessagesToLoad - 1));
         }
         
         // Else just fetch the last N messages
         else
         {
             fetchRange =
             MCORangeMake(self.totalNumberOfInboxMessages -
                          (numberOfMessagesToLoad - 1),
                          (numberOfMessagesToLoad - 1));
         }
         
         self.imapMessagesFetchOp =
         [self.imapSession fetchMessagesByNumberOperationWithFolder:folder
                                                        requestKind:requestKind
                                                            numbers:
          [MCOIndexSet indexSetWithRange:fetchRange]];
         
         [self.imapMessagesFetchOp setProgress:^(unsigned int progress) {
             
         }];
         
         __weak MailDataObject *weakSelf = self;
         [self.imapMessagesFetchOp start:
          ^(NSError *error, NSArray *messages, MCOIndexSet *vanishedMessages)
          {
              MailDataObject *strongSelf = weakSelf;
              
              NSSortDescriptor *sort =
              [NSSortDescriptor sortDescriptorWithKey:@"header.date" ascending:NO];
              
              NSMutableArray *combinedMessages =
              [NSMutableArray arrayWithArray:messages];
              
              [combinedMessages addObjectsFromArray:strongSelf.messages];
              
              strongSelf.messages =
              [combinedMessages sortedArrayUsingDescriptors:@[sort]];
              
              completionBlock(error, strongSelf.messages,vanishedMessages);
              
          }];
     }];
}

- (void)getMessageWithInt:(NSUInteger)nMessages withFolder:(NSString*)folder andCompletionBlock:(void (^)(NSError * __nullable error, NSArray * /* MCOIMAPMessage */ __nullable messages, MCOIndexSet * __nullable vanishedMessages))completionBlock{
    [self loadLastUid:10 withFolder:folder andCompletionBlock:^(NSError * _Nullable error, NSArray * _Nullable messages, MCOIndexSet * _Nullable vanishedMessages) {
        //local uid
        MailDAO* mailDao = [MailDAO sharedManager];
        NSMutableDictionary* mDic = [mailDao getUidByKey:@"ruibang.xu@midea.com.cn"];//需要取用户名方法
        //server Uid
        for (MCOIMAPMessage* mUid in messages) {
            if ([[mDic allKeys]containsObject:[NSString stringWithFormat:@"%u",mUid.uid]]) {
                //取local message
                
            } else {
                //取server message
                
            }
        }
    }];
}
#pragma mark - 发送邮件和保存草稿箱
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

{
    
    [_progressView show:YES];
    
    MCOSMTPSession *smtpSession = [[MCOSMTPSession alloc]init];
    smtpSession.hostname = hosName;
    smtpSession.port = port;
    smtpSession.username = userName;
    smtpSession.password = password;
   // smtpSession.authType = (MCOAuthTypeSASLPlain | MCOAuthTypeSASLLogin);
    smtpSession.connectionType = MCOConnectionTypeTLS;
    
    MCOSMTPOperation *smtpOperation = [smtpSession loginOperation];
    [smtpOperation start:^(NSError * error) {
        if (error == nil) {
            NSLog(@"login account successed");
        } else {
            NSLog(@"login account failure: %@", error);
        }  
    }];
    
    //来自
    MCOMessageBuilder *builder = [[MCOMessageBuilder alloc]init];
    [[builder header] setFrom:[MCOAddress addressWithDisplayName:fromDisplayName mailbox:fromMaiBox]];
    
    //接收
    if(toArray){
        NSMutableArray *to = [[NSMutableArray alloc]init];
        for (ContactsModel *item in toArray) {
            [to addObject:[MCOAddress addressWithMailbox:item.mailBox]];
        }
        builder.header.to=to;
    }
    
    //抄送
    if(ccArray){
        NSMutableArray *cc = [[NSMutableArray alloc]init];
        for (ContactsModel *item in ccArray) {
            [cc addObject:[MCOAddress addressWithMailbox:item.mailBox]];
        }
        builder.header.cc=cc;
    }
    
    //密送
    if(bccArray){
        NSMutableArray *bcc = [[NSMutableArray alloc]init];
        for (ContactsModel *item in ccArray) {
            [bcc addObject:[MCOAddress addressWithMailbox:item.mailBox]];
        }
        builder.header.bcc=bcc;
    }
    //主题
    builder.header.subject=subject;
    
    //内容
    [builder setHTMLBody:content];
    
    //图片
    for(int i=0;i<fileArray.count;i++){
        
        UIImage *image=[fileArray objectAtIndex:i];
          NSData * imageData = UIImageJPEGRepresentation(image,1);
        
      [builder addAttachment:[MCOAttachment attachmentWithData:imageData filename:[NSString stringWithFormat:@"image_%d.jpg",i]]];
        
    }
  
    
    NSData *rfc822Data = [builder data];
    
    
    MCOSMTPSendOperation *sendOperation = [smtpSession sendOperationWithData:rfc822Data];
    
    sendOperation.shouldRunWhenCancelled = NO;
    //__weak MCOSMTPSendOperation *weakSend = sendOperation;
    sendOperation.progress = ^(unsigned int current, unsigned int maximum) {
        NSLog(@"Sending at %.2f", current*1.00  / maximum);
        [_progressView setProgress:current*1.00  / maximum animated:YES];
    };
    
    [sendOperation start:^(NSError *error) {
        if(error==nil){
            [self playSendSucceedVoice];
            [self performBlock:^{
                _progressView.mode = MRProgressOverlayViewModeCheckmark;
                _progressView.titleLabelText = @"发送成功";
                [self performBlock:^{
                    [_progressView dismiss:YES];
                    _progressView=nil;
                } afterDelay:0.5];
            } afterDelay:1.0];
        //保存到已发送
            [self createMDNSent:rfc822Data block:^(bool success) {
                if(success){
                    NSLog(@"保存到已发送成功");
                    }
               
            }];
        }
        else{
            [self performBlock:^{
                _progressView.mode = MRProgressOverlayViewModeCross;
                _progressView.titleLabelText = @"发送失败";
                [self performBlock:^{
                    [_progressView dismiss:YES];
                    _progressView=nil;
                } afterDelay:0.5];
            } afterDelay:1.0];
        }
        
        resultBlock(error);
    }];
}
-(void)saveEmailtoDraftFromDisplayName:(NSString*)fromDisplayName
                            fromMaiBox:(NSString*)fromMaiBox
                               toArray:(NSArray*)toArray
                               ccArray:(NSArray*)ccArray
                              bccArray:(NSArray*)bccArray
                               subject:(NSString*)subject
                               content:(NSString*)content
                                  file:(NSArray*)fileArray
                           resultBlock:(void(^)(NSError* error))resultBlock
{
    //来自
    MCOMessageBuilder *builder = [[MCOMessageBuilder alloc]init];
    [[builder header] setFrom:[MCOAddress addressWithDisplayName:fromDisplayName mailbox:fromMaiBox]];
    
    //接收
    if(toArray){
        NSMutableArray *to = [[NSMutableArray alloc]init];
        for (ContactsModel *item in toArray) {
            [to addObject:[MCOAddress addressWithMailbox:item.mailBox]];
        }
        builder.header.to=to;
    }
    
    //抄送
    if(ccArray){
        NSMutableArray *cc = [[NSMutableArray alloc]init];
        for (ContactsModel *item in ccArray) {
            [cc addObject:[MCOAddress addressWithMailbox:item.mailBox]];
        }
        builder.header.cc=cc;
    }
    
    //密送
    if(bccArray){
        NSMutableArray *bcc = [[NSMutableArray alloc]init];
        for (ContactsModel *item in ccArray) {
            [bcc addObject:[MCOAddress addressWithMailbox:item.mailBox]];
        }
        builder.header.bcc=bcc;
    }
    //主题
    builder.header.subject=subject;
    
    //内容
    [builder setHTMLBody:content];
    
    //图片
    for(int i=0;i<fileArray.count;i++){
        
        UIImage *image=[fileArray objectAtIndex:i];
        NSData * imageData = UIImageJPEGRepresentation(image,1);
        
        [builder addAttachment:[MCOAttachment attachmentWithData:imageData filename:[NSString stringWithFormat:@"image_%d.jpg",i]]];
        
    }
    
    NSData *rfc822Data = [builder data];
    if(rfc822Data){
        NSString *folder = [self.imapSession.defaultNamespace pathForComponents:@[@"草稿箱"]];
        MCOIMAPAppendMessageOperation *op = [self.imapSession appendMessageOperationWithFolder:folder messageData:rfc822Data flags:MCOMessageFlagDraft];
        [op start:^(NSError *error, uint32_t createdUID) {
            resultBlock(error);
            if (error) {
                NSLog(@"保存草稿箱失败=%@",error);
            }else{
                NSLog(@"保存草稿箱成功");
            }
        }];

    }

}
- (void)createMDNSent:(NSData *)data block:(void(^)(bool success))block
{
    NSString *folder = [self.imapSession.defaultNamespace pathForComponents:@[@"已发送"]];
    MCOIMAPAppendMessageOperation *op = [self.imapSession appendMessageOperationWithFolder:folder messageData:data flags:MCOMessageFlagMDNSent];
    [op start:^(NSError *error, uint32_t createdUID) {
        if (error) {
            block(false);
        }else{
            block(true);
        }
    }];
}



#pragma mark - update flag 已读 红旗 删除
- (void)updateFlags:(MCOMessageFlag)newFlags isAdd:(BOOL)i withUid:(MCOIndexSet*)indexSet inFolder:(NSString*)folder withBlock:(void(^)(NSError * error))completionBlock{
    BOOL deleted = newFlags & MCOMessageFlagDeleted;
    MCOIMAPStoreFlagsRequestKind kind;
    if (i) {
        kind = MCOIMAPStoreFlagsRequestKindAdd;
    } else {
        kind = MCOIMAPStoreFlagsRequestKindRemove;
    }
    MCOIMAPOperation *op = [_imapSession storeFlagsOperationWithFolder:folder
                                                                  uids:indexSet
                                                                  kind:kind
                                                                 flags:newFlags];
    //    [MCOIndexSet indexSetWithIndex:MESSAGE_UID]
    [op start:^(NSError * error) {
        if(!error) {
            NSLog(@"Updated flags!");
        } else {
            NSLog(@"Error updating flags:%@", error);
        }
        if (!deleted) {
            [SVProgressHUD dismiss];
        }
        completionBlock(error);
        if(deleted) {
            if (![folder isEqualToString:@"Drafts"] && ![folder isEqualToString:@"Trash"]) {
                MCOIMAPCopyMessagesOperation *op = [self.imapSession copyMessagesOperationWithFolder:folder uids:indexSet destFolder:@"Trash"];
                [op start:^(NSError *error, NSDictionary *uidMapping) {
                    MCOIMAPOperation *deleteOp = [_imapSession expungeOperation:folder];
                    [deleteOp start:^(NSError *error) {
                        [SVProgressHUD dismiss];
                        if(error) {
                            NSLog(@"Error expunging folder:%@", error);
                        } else {
                            NSLog(@"Successfully expunged folder");
                        }
                    }];
                }];
            }else{  
                MCOIMAPOperation *deleteOp = [_imapSession expungeOperation:folder];
                [deleteOp start:^(NSError *error) {
                    [SVProgressHUD dismiss];
                    if(error) {
                        NSLog(@"Error expunging folder:%@", error);
                    } else {
                        NSLog(@"Successfully expunged folder");
                    }
                }];
            }
        }
    }];
}

- (void)completeDeleteWithUid:(MCOIndexSet*)indexSet inFolder:(NSString*)folder withBlock:(void(^)(NSError * error))completionBlock{
    MCOIMAPOperation *op = [_imapSession storeFlagsOperationWithFolder:folder
                                                                  uids:indexSet
                                                                  kind:MCOIMAPStoreFlagsRequestKindAdd
                                                                 flags:MCOMessageFlagDeleted];
    [op start:^(NSError * _Nullable error) {
        if (!error) {
            MCOIMAPOperation* op2 = [_imapSession expungeOperation:folder];
            [op2 start:^(NSError * _Nullable error) {
                [SVProgressHUD dismiss];
                completionBlock(error);
            }];
        }
    }];
}
#pragma mark -  获取所有文件夹
- (void)getMailFolder{
    MCOIMAPFetchFoldersOperation *imapFetchFolderOp = [_imapSession fetchAllFoldersOperation];
    [imapFetchFolderOp start:^(NSError * error, NSArray * folders) {
        for (MCOIMAPFolder *fdr in folders) {
            NSArray * sections = [fdr.path componentsSeparatedByString:[NSString stringWithFormat:@"%c",fdr.delimiter]];
            NSString *folderName = [sections lastObject];
            const char *stringAsChar = [folderName cStringUsingEncoding:[NSString defaultCStringEncoding]];
            folderName = [NSString stringWithCString:stringAsChar encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingUTF7_IMAP)];
            
            NSLog (@"folder: %@",folderName);
        }
    }];
}

- (void)getDetailMessageHtmlWithUid:(int)uid withFolder:(NSString*)folder with:(void(^)(NSMutableDictionary*))successBlock{
  //  MCOIMAPFetchContentOperation *operation = [_imapSession fetchMessageByUIDOperationWithFolder:folder uid:uid];
    
    MCOIMAPFetchParsedContentOperation *operation = [_imapSession fetchParsedMessageOperationWithFolder:folder uid:uid urgent:YES];
    [operation start:^(NSError * __nullable error, MCOMessageParser * parser) {
        MCOMessageParser *messageParser = parser;
        NSLog(@"%@",messageParser.header);
        NSMutableArray* toArray = [NSMutableArray array];
        
        for (MCOAddress* address in messageParser.header.to) {
            [toArray addObject:[address.mailbox componentsSeparatedByString:@"@"][0]];
        }
        NSMutableArray* attachmentArr = [NSMutableArray array];
        for (MCOAttachment* part in messageParser.attachments) {
            [attachmentArr addObject:part.filename];
        }
        NSString *bodyStr=@"";
         NSString *fromStr=@"";
         NSString *subjectStr=@"";
        if([messageParser htmlBodyRendering]){
            bodyStr=[messageParser htmlBodyRendering];
        }
        if(messageParser.header.from.mailbox){
            fromStr=messageParser.header.from.mailbox;
        }
        if(messageParser.header.subject){
            subjectStr=messageParser.header.subject;
        }
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            for (MCOAttachment* part in messageParser.attachments) {
                NSData* attachmentData = [part data];
                NSString *tmpDirectory =NSTemporaryDirectory();
                NSString *filePath=[tmpDirectory stringByAppendingPathComponent:part.filename];
                [attachmentData writeToFile:filePath atomically:YES];
            }
        });
        
        NSMutableDictionary* dic = [NSMutableDictionary dictionary];
        [dic setObject:bodyStr forKey:@"body"];
        [dic setObject:fromStr forKey:@"from"];
        [dic setObject:toArray forKey:@"to"];
        [dic setObject:subjectStr forKey:@"subject"];
        [dic setObject:messageParser.header.date forKey:@"date"];
        [dic setObject:attachmentArr forKey:@"attachments"];
        [dic setObject:messageParser forKey:@"message"];
        [dic setObject:[NSString stringWithFormat:@"%d",uid] forKey:@"uid"];
        
        
        //回复
            ContactsModel *oneModel=[[ContactsModel alloc]init];
            oneModel.mailBox=messageParser.header.from.mailbox;;
            if(messageParser.header.from.displayName){
                oneModel.disPlayName=messageParser.header.from.displayName;
            }
            else{
                oneModel.disPlayName=messageParser.header.from.mailbox;
            }
             [dic setObject:oneModel forKey:@"fromModel"];
        
        //收件人
        NSMutableArray* addressToArray = [NSMutableArray array];
        for (MCOAddress* address in messageParser.header.to) {
            ContactsModel *oneModel=[[ContactsModel alloc]init];
            oneModel.mailBox=address.mailbox;
            if(address.displayName){
                oneModel.disPlayName=address.displayName;
            }
            else{
                oneModel.disPlayName=address.mailbox;
            }
            
            [addressToArray addObject:oneModel];
        }
        //抄送
        NSMutableArray* ccArray = [NSMutableArray array];
        for (MCOAddress* address in messageParser.header.cc) {
            ContactsModel *oneModel=[[ContactsModel alloc]init];
            oneModel.mailBox=address.mailbox;
            if(address.displayName){
                oneModel.disPlayName=address.displayName;
            }
            else{
                oneModel.disPlayName=address.mailbox;
            }
            
            [ccArray addObject:oneModel];
        }
        //密送
        NSMutableArray* bccArray = [NSMutableArray array];
        for (MCOAddress* address in messageParser.header.bcc) {
            
            ContactsModel *oneModel=[[ContactsModel alloc]init];
            oneModel.mailBox=address.mailbox;
            if(address.displayName){
                oneModel.disPlayName=address.displayName;
            }
            else{
                oneModel.disPlayName=address.mailbox;
            }
            
            [bccArray addObject:oneModel];
        }
        [dic setObject:addressToArray forKey:@"addressTo"];
        [dic setObject:ccArray forKey:@"addressCc"];
        [dic setObject:bccArray forKey:@"addressBcc"];
        
        successBlock(dic);
    }];
    
//    [operation start:^(NSError *error, NSData *data) {
//        MCOMessageParser *messageParser = [[MCOMessageParser alloc] initWithData:data];
//        NSLog(@"%@",messageParser.header);
//        NSMutableArray* toArray = [NSMutableArray array];
//        for (MCOAddress* address in messageParser.header.to) {
//            [toArray addObject:[address.mailbox componentsSeparatedByString:@"@"][0]];
//        }
//        NSMutableArray* attachmentArr = [NSMutableArray array];
//        for (MCOAttachment* part in messageParser.attachments) {
//            [attachmentArr addObject:part.filename];
//            NSData* attachmentData = [part data];
//            NSString *tmpDirectory =NSTemporaryDirectory();
//            NSString *filePath=[tmpDirectory stringByAppendingPathComponent:part.filename];
//            [attachmentData writeToFile:filePath atomically:YES];
//        }
//        NSMutableDictionary* dic = [NSMutableDictionary dictionary];
//        [dic setObject:[messageParser htmlBodyRendering] forKey:@"body"];
//        [dic setObject:messageParser.header.from.mailbox forKey:@"from"];
//        [dic setObject:toArray forKey:@"to"];
//        [dic setObject:messageParser.header.subject forKey:@"subject"];
//        [dic setObject:messageParser.header.date forKey:@"date"];
//        [dic setObject:attachmentArr forKey:@"attachments"];
//        [dic setObject:messageParser forKey:@"message"];
//        [dic setObject:[NSString stringWithFormat:@"%d",uid] forKey:@"uid"];
//        
//        
//        //收件人
//        NSMutableArray* addressToArray = [NSMutableArray array];
//        for (MCOAddress* address in messageParser.header.to) {
//            ContactsModel *oneModel=[[ContactsModel alloc]init];
//            oneModel.mailBox=address.mailbox;
//            if(address.displayName){
//                oneModel.disPlayName=address.displayName;
//            }
//            else{
//                oneModel.disPlayName=address.mailbox;
//            }
//            
//            [addressToArray addObject:oneModel];
//        }
//        //抄送
//        NSMutableArray* ccArray = [NSMutableArray array];
//        for (MCOAddress* address in messageParser.header.cc) {
//            ContactsModel *oneModel=[[ContactsModel alloc]init];
//            oneModel.mailBox=address.mailbox;
//            if(address.displayName){
//                oneModel.disPlayName=address.displayName;
//            }
//            else{
//                oneModel.disPlayName=address.mailbox;
//            }
//
//            [ccArray addObject:oneModel];
//        }
//        //密送
//        NSMutableArray* bccArray = [NSMutableArray array];
//        for (MCOAddress* address in messageParser.header.bcc) {
//            
//            ContactsModel *oneModel=[[ContactsModel alloc]init];
//            oneModel.mailBox=address.mailbox;
//            if(address.displayName){
//                oneModel.disPlayName=address.displayName;
//            }
//            else{
//                oneModel.disPlayName=address.mailbox;
//            }
//
//            [bccArray addObject:oneModel];
//        }
//        [dic setObject:addressToArray forKey:@"addressTo"];
//        [dic setObject:ccArray forKey:@"addressCc"];
//        [dic setObject:bccArray forKey:@"addressBcc"];
//        
//        successBlock(dic);
//    }];
}

- (void)searchMailWithString:(NSString*)string withKind:(NSInteger)kindInt with:(void(^)(NSError * __nullable error, MCOIndexSet * searchResult))successBlock{
    NSArray* arr = @[[NSNumber numberWithInteger:MCOIMAPSearchKindFrom],[NSNumber numberWithInteger:MCOIMAPSearchKindTo],[NSNumber numberWithInteger:MCOIMAPSearchKindSubject],[NSNumber numberWithInteger:MCOIMAPSearchKindAll]];
    MCOIMAPSearchOperation * op = [_imapSession searchOperationWithFolder:@"INBOX"
                                                                kind:[(NSNumber*)arr[kindInt]integerValue]
                                                        searchString:string];
    [op start:^(NSError * __nullable error, MCOIndexSet * searchResult) {
        successBlock(error,searchResult);
    }];
}




- (void)searchMessages:(MCOIndexSet*)messageSet withFolder:(NSString*)folder andCompletionBlock:(void (^)(NSError * __nullable error, NSArray * /* MCOIMAPMessage */ __nullable messages, MCOIndexSet * __nullable vanishedMessages))completionBlock
{
    MCOIMAPMessagesRequestKind requestKind = (MCOIMAPMessagesRequestKind)
    (MCOIMAPMessagesRequestKindHeaders | MCOIMAPMessagesRequestKindStructure |
     MCOIMAPMessagesRequestKindInternalDate | MCOIMAPMessagesRequestKindHeaderSubject |
     MCOIMAPMessagesRequestKindFlags);
    
    self.imapMessagesFetchOp =
    [self.imapSession fetchMessagesByNumberOperationWithFolder:folder
                                                   requestKind:requestKind
                                                       numbers:messageSet];
    
    [self.imapMessagesFetchOp setProgress:^(unsigned int progress) {
        
    }];
    
    __weak MailDataObject *weakSelf = self;
    [self.imapMessagesFetchOp start:
     ^(NSError *error, NSArray *messages, MCOIndexSet *vanishedMessages)
     {
         MailDataObject *strongSelf = weakSelf;
         
         NSSortDescriptor *sort =
         [NSSortDescriptor sortDescriptorWithKey:@"header.date" ascending:NO];
         
         NSMutableArray *combinedMessages =
         [NSMutableArray arrayWithArray:messages];
         
         [combinedMessages addObjectsFromArray:strongSelf.messages];
         
         strongSelf.messages =
         [combinedMessages sortedArrayUsingDescriptors:@[sort]];
         
         completionBlock(error, strongSelf.messages,vanishedMessages);
         
     }];
}

#pragma mark - 保存通讯录
-(void)getContactsByMailHeader{
        //第一页保存
       [[MailDAO sharedManager]getAllContactsResultBlock:^(NSArray *resultArray) {
           
           if(resultArray.count>0){
               [_contantsMuArray addObjectsFromArray:resultArray];
                [MailGlobalData getInstance].contactsArray=[NSArray arrayWithArray:_contantsMuArray];
               [_secondContantsMuArray removeAllObjects];
               //  后台执行：
               dispatch_async(dispatch_get_global_queue(0, 0), ^{
                   for (MCOIMAPMessage* message in self.messages) {
                       [self addDisPlayName:message.header.from.displayName andMailBox:message.header.from.mailbox];
                       
                       for(MCOAddress *address in message.header.to){
                           [self addDisPlayName:address.displayName andMailBox:address.mailbox];
                       }
                       for(MCOAddress *address in message.header.cc){
                           [self addDisPlayName:address.displayName andMailBox:address.mailbox];
                           
                       }
                       for(MCOAddress *address in message.header.bcc){
                           [self addDisPlayName:address.displayName andMailBox:address.mailbox];
                           
                       }
                   }
                   
                   dispatch_async(dispatch_get_main_queue(), ^{
                        NSLog(@"countI=%lu",(unsigned long)_contantsMuArray.count);
                       
                        NSLog(@"countI222=%lu",(unsigned long)_secondContantsMuArray.count);
                       
                       if(_secondContantsMuArray.count>0){
                           [MailGlobalData getInstance].contactsArray=[NSArray arrayWithArray:_contantsMuArray];
                           [[MailDAO sharedManager] insertOneContacts:_secondContantsMuArray];
                       
                       }
                           
                   });

                   
               });
               
           }
           else{
               
               //只在第一次获取
               NSArray *folderArray=@[INBOX,Drafts,Sent_Items,Trash];
               [_contantsMuArray removeAllObjects];
               
               for(int i=0;i<folderArray.count;i++){
                   NSString *folderString=[folderArray objectAtIndex:i];
                   MCOIMAPFolderStatusOperation * opINBOX = [_imapSession folderStatusOperation:folderString];
                   [opINBOX start:^(NSError *error, MCOIMAPFolderStatus * info) {
                       NSLog(@"messages count%@: %u", folderString,[info messageCount]);
                       int numberOfMessages = [info messageCount];
                       numberOfMessages -= 1;
                       MCORange fetchRange= MCORangeMake([info messageCount] - numberOfMessages, numberOfMessages);
                       
                       self.imapMessagesFetchOp =
                       [self.imapSession fetchMessagesByNumberOperationWithFolder:folderString
                                                                      requestKind:MCOIMAPMessagesRequestKindHeaders
                                                                          numbers:
                        [MCOIndexSet indexSetWithRange:fetchRange]];
                       
                       [self.imapMessagesFetchOp setProgress:^(unsigned int progress) {
                           // NSLog(@"progress=%d",progress);
                       }];
                       
                       
                       [self.imapMessagesFetchOp start:
                        ^(NSError *error, NSArray *messages, MCOIndexSet *vanishedMessages)
                        {
                            
                         dispatch_async(dispatch_get_global_queue(0, 0), ^{
                                
                                NSSortDescriptor *sort =
                                [NSSortDescriptor sortDescriptorWithKey:@"header.date" ascending:NO];
                                
                                NSMutableArray *combinedMessages =
                                [NSMutableArray arrayWithArray:messages];
                                NSArray  *headerMessage  =
                                [combinedMessages sortedArrayUsingDescriptors:@[sort]];
                                NSLog(@"headerMessagecunt==%lu",(unsigned long)headerMessage.count);
                             
                                for (MCOIMAPMessage* message in headerMessage) {
                                    [self addDisPlayName:message.header.from.displayName andMailBox:message.header.from.mailbox];
                                    
                                    
                                    for(MCOAddress *address in message.header.to){
                                         [self addDisPlayName:address.displayName andMailBox:address.mailbox];
                                    }
                                    for(MCOAddress *address in message.header.cc){
                                    [self addDisPlayName:address.displayName andMailBox:address.mailbox];
                                        
                                    }
                                    for(MCOAddress *address in message.header.bcc){
                                         [self addDisPlayName:address.displayName andMailBox:address.mailbox];
                                        
                                    }
                                }
                             
                             
                             static int countI=0;
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 countI++;
                                 
                                 NSLog(@"countI=%d==%lu",countI,(unsigned long)_contantsMuArray.count);
                                 if(countI==4){
                                     [MailGlobalData getInstance].contactsArray=[NSArray arrayWithArray:_contantsMuArray];
                                     
                                     [[MailDAO sharedManager] insertOneContacts:_contantsMuArray];
                                     
                                 }
                                 
                             });
                             
                            });
                            
                            
                        }];
                       
                   }];
                   
               }
               
           }

       }];
    

}
#pragma mark-
- (void)performBlock:(void(^)())block afterDelay:(NSTimeInterval)delay {
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), block);
}

-(void)playSendSucceedVoice{
    
    NSString *path = [[NSBundle mainBundle]pathForResource:@"sendSuccess" ofType:@"wav"];
    if (path) {
        //注册声音到系统
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path],&shake_sound_male_id);
        AudioServicesPlaySystemSound(shake_sound_male_id);
        AudioServicesPlaySystemSound(shake_sound_male_id);
        //如果无法再下面播放，可以尝试在此播放
    }
    AudioServicesPlaySystemSound(shake_sound_male_id);
    //播放注册的声音，（此句代码，可以在本类中的任意位置调用，不限于本方法中）
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);   //让手机震动
}

#pragma mark - 移动至文件夹
- (void)moveFolderWithUid:(MCOIndexSet*)indexSet from:(NSString*)source to:(NSString*)dest withBlock:(void(^)(NSError * error,NSDictionary * uidMapping))completionBlock{
    MCOIMAPCopyMessagesOperation * op = [_imapSession copyMessagesOperationWithFolder:source
                                                                                 uids:indexSet
                                                                           destFolder:dest];
    
    [op start:^(NSError * __nullable error, NSDictionary * uidMapping) {
//        NSLog(@"moved to folder with UID mapping %@", uidMapping);
//        completionBlock(error,uidMapping);
        MCOIMAPOperation *op2 = [_imapSession storeFlagsOperationWithFolder:source
                                                                      uids:indexSet
                                                                      kind:MCOIMAPStoreFlagsRequestKindAdd
                                                                     flags:MCOMessageFlagDeleted];
        [op2 start:^(NSError * _Nullable error) {
            if (!error) {
                MCOIMAPOperation *deleteOp = [_imapSession expungeOperation:source];
                [deleteOp start:^(NSError *error) {
                    if(error) {
                        NSLog(@"Error expunging folder:%@", error);
                    } else {
                        NSLog(@"Successfully expunged folder");
                    }
                    completionBlock(error,uidMapping);
                }];
            }
            
        }];

    }];
}

- (void)getRedFlagMessage:(NSArray*)messageArray withBlock:(void(^)(NSArray* arr))completionBlock{
    NSMutableArray* redFlagArr = [NSMutableArray array];
    for (int i = 0; i < messageArray.count; i++) {
        MCOIMAPMessage* message = messageArray[i];
        if (message.flags&1<<2) {
            [redFlagArr addObject:message];
        }
    }
    completionBlock(redFlagArr);
}
-(BOOL)addDisPlayName:(NSString*)name andMailBox:(NSString*)mailBox{
    if(mailBox){
        if([mailBox hasPrefix:@"jianjun.dai@midea.com"]){
            return NO;
        }
        if(mailBox.length<3){
            return NO;
        }
        for(int i=0;i<_contantsMuArray.count;i++){
            ContactsModel *oneMoldel=[_contantsMuArray objectAtIndex:i];
            if([oneMoldel.mailBox isEqual:mailBox]){
                return NO;
            }
            
        }
        
        ContactsModel *oneMoldel=[[ContactsModel alloc]init];
        if(name){
            oneMoldel.disPlayName=name;
        }
        else{
            oneMoldel.disPlayName=mailBox;
        }
        oneMoldel.mailBox=mailBox;
        oneMoldel.userName=self.userName;
        [_contantsMuArray addObject:oneMoldel];
        [_secondContantsMuArray addObject:oneMoldel];
        return YES;
        
    }
    return NO;
}

@end
