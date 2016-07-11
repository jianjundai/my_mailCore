//
//  UITextField+WJ.m
//  mailcoreDemo
//
//  Created by ios－dai on 16/6/17.
//  Copyright © 2016年 ios－dai. All rights reserved.
//

#import "UITextField+WJ.h"
#import <objc/runtime.h>
NSString * const WJTextFieldDidDeleteBackwardNotification = @"com.whojun.textfield.did.notification";
@implementation UITextField (WJ)

+ (void)load {
    //交换2个方法中的IMP
    Method method1 = class_getInstanceMethod([self class], NSSelectorFromString(@"deleteBackward"));
    Method method2 = class_getInstanceMethod([self class], @selector(wj_deleteBackward));
    method_exchangeImplementations(method1, method2);
}

- (void)wj_deleteBackward {
    [self wj_deleteBackward];
    
    if ([self.delegate respondsToSelector:@selector(textFieldDidDeleteBackward:)])
    {
        id <WJTextFieldDelegate> delegate  = (id<WJTextFieldDelegate>)self.delegate;
        [delegate textFieldDidDeleteBackward:self];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:WJTextFieldDidDeleteBackwardNotification object:self];
}


@end
