//
//  MailBodyWebView.m
//  mailcoreDemo
//
//  Created by XuRuiBang on 16/6/23.
//  Copyright © 2016年 ios－dai. All rights reserved.
//

#import "MailBodyWebView.h"
#import "MCOCIDURLProtocol.h"

static NSString * mainJavascript = @"\
var imageElements = function() {\
var imageNodes = document.getElementsByTagName('img');\
return [].slice.call(imageNodes);\
};\
\
var findCIDImageURL = function() {\
var images = imageElements();\
\
var imgLinks = [];\
for (var i = 0; i < images.length; i++) {\
var url = images[i].getAttribute('src');\
if (url.indexOf('cid:') == 0 || url.indexOf('x-mailcore-image:') == 0)\
imgLinks.push(url);\
}\
return JSON.stringify(imgLinks);\
};\
\
var replaceImageSrc = function(info) {\
var images = imageElements();\
\
for (var i = 0; i < images.length; i++) {\
var url = images[i].getAttribute('src');\
if (url.indexOf(info.URLKey) == 0) {\
images[i].setAttribute('src', info.LocalPathKey);\
break;\
}\
}\
};\
";

@implementation MailBodyWebView{
//    UIWebView * _webView;
    NSString * _folder;
    MCOAbstractMessage * _message;
//    id <MCOMessageViewDelegate> _delegate;
    BOOL _prefetchIMAPImagesEnabled;
    BOOL _prefetchIMAPAttachmentsEnabled;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    [self setAutoresizingMask:(UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth)];
    [self setDelegate:self];
    [self setScalesPageToFit:YES];
    self.scrollView.scrollEnabled = NO;
    
    return self;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    //
    [self _loadImages];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSURLRequest *responseRequest = [self webView:webView resource:nil willSendRequest:request redirectResponse:nil fromDataSource:nil];
    
    if(responseRequest == request) {
        return YES;
    } else {
        [webView loadRequest:responseRequest];
        return NO;
    }
}

- (NSURLRequest *)webView:(UIWebView *)sender resource:(id)identifier willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse fromDataSource:(id)dataSource
{
//    if ([[[request URL] scheme] isEqualToString:@"x-mailcore-msgviewloaded"]) {
//        [self _loadImages];
//    }
    
    return request;
}

- (void) _loadImages
{
    
    NSString * result = [self stringByEvaluatingJavaScriptFromString:@"findCIDImageURL()"];
    
    NSLog(@"-----加载网页中的图片-----");
    
    NSLog(@"%@", result);
    
    if (result==nil || [result isEqualToString:@""]) {
        
        return;
        
    }
    
    NSData * data = [result dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *error = nil;
    
    NSArray * imagesURLStrings = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    
    
    
    for(NSString * urlString in imagesURLStrings) {
        
        MCOAbstractPart * part =nil;
        
        NSURL * url;
        
        
        
        url = [NSURL URLWithString:urlString];
        
        if ([MCOCIDURLProtocol isCID:url]) {
            
            part = [self _partForCIDURL:url];
            
        }
        
        else if ([MCOCIDURLProtocol isXMailcoreImage:url]) {
            
            NSString * specifier = [url resourceSpecifier];
            
            NSString * partUniqueID = specifier;
            
            part = [self _partForUniqueID:partUniqueID];
            
        }
        
        
        
        if (part == nil)
            
            continue;
        
        NSString * partUniqueID = [part uniqueID];
        
        
        
        MCOAttachment * attachment = (MCOAttachment *) [_message partForUniqueID:partUniqueID];
        
        NSData * data =[attachment data];
        
        
        
        if (data!=nil) {
            
            
            
            //获取文件路径
            
            NSString *tmpDirectory =NSTemporaryDirectory();
            
            NSString *filePath=[tmpDirectory stringByAppendingPathComponent : attachment.filename ];
            
            NSFileManager *fileManger=[NSFileManager defaultManager];
            
            
            
            if (![fileManger fileExistsAtPath:filePath]) {//不存在就去请求加载
                
                NSData *attachmentData=[attachment data];
                
                [attachmentData writeToFile:filePath atomically:YES];
                
                NSLog(@"资源：%@已经下载至%@", attachment.filename,filePath);
                
            }
            
            
            
            NSURL * cacheURL = [NSURL fileURLWithPath:filePath];
            
            
            
            NSDictionary * args =@{@"URLKey": urlString,@"LocalPathKey": cacheURL.absoluteString};
            
            NSString * jsonString = [self _jsonEscapedStringFromDictionary:args];
            
            
            
            NSString * replaceScript = [NSString stringWithFormat:@"replaceImageSrc(%@)", jsonString];
            
            [self stringByEvaluatingJavaScriptFromString:replaceScript];
            
            
            
            
            
        }
        
        
        
    }
    
}



- (MCOAbstractPart *) _partForCIDURL:(NSURL *)url
{
    return [_message partForContentID:[url resourceSpecifier]];
}

- (MCOAbstractPart *) _partForUniqueID:(NSString *)partUniqueID
{
    return [_message partForUniqueID:partUniqueID];
}

- (NSString *) _jsonEscapedStringFromDictionary:(NSDictionary *)dictionary
{
    NSData * json = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:nil];
    NSString * jsonString = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
    return jsonString;
}

@end
