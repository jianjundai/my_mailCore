//
//  UITextField+WJ.h
//  mailcoreDemo
//
//  Created by ios－dai on 16/6/17.
//  Copyright © 2016年 ios－dai. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol WJTextFieldDelegate <UITextFieldDelegate>
@optional
- (void)textFieldDidDeleteBackward:(UITextField *)textField;
@end
@interface UITextField (WJ)
@property (weak, nonatomic) id<WJTextFieldDelegate> delegate;
@end
/**
 *  监听删除按钮
 *  object:UITextField
 */
extern NSString * const WJTextFieldDidDeleteBackwardNotification;