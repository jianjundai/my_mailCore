//
//  MailHeaderView.m
//  mailcoreDemo
//
//  Created by ios－dai on 16/6/7.
//  Copyright © 2016年 ios－dai. All rights reserved.
//

#import "MailHeaderView.h"
#define Kscreenwidth [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height
#define Blue_Color [UIColor colorWithRed:2/255.0 green:136/255.0 blue:221/255.0 alpha:1.0]
#define Gray_Color [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0]


@implementation MailHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.userInteractionEnabled=YES;
        
        UIView *navgationView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, Kscreenwidth, 65)];
        navgationView.backgroundColor=Blue_Color;
        [self addSubview:navgationView];
        [self bringSubviewToFront:navgationView];
        navgationView.userInteractionEnabled=YES;
        [self bringSubviewToFront:navgationView];
        
        
        _backButton=[[UIButton alloc]initWithFrame:CGRectMake(15, 28, 48, 21)];
        [_backButton setImage:[UIImage imageNamed:@"Mail_Back"] forState:UIControlStateNormal];
        [navgationView addSubview:_backButton];
        
        _allChoiceButton=[[UIButton alloc]initWithFrame:CGRectMake(15, 28, 48, 21)];
        [_allChoiceButton setTitle:@"全选" forState:UIControlStateNormal];
        [navgationView addSubview:_allChoiceButton];
        [_allChoiceButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _allChoiceButton.hidden=YES;
        
        
        
        _editButton=[[UIButton alloc]initWithFrame:CGRectMake(Kscreenwidth-48-15, 28, 48, 21)];
        [_editButton setTitle:@"编辑" forState:UIControlStateNormal];
        [_editButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [navgationView addSubview:_editButton];
       
    
        //中间的收件箱
        
        NSString *tileString=@"收件箱";
        CGSize lbSize =[tileString boundingRectWithSize:CGSizeMake(200, 24) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]} context:nil].size;
        _middleLB=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, lbSize.width, 24)];
        _middleLB.text=tileString;
        _middleLB.center=CGPointMake(self.frame.size.width/2, 40);
        _middleLB.textAlignment=NSTextAlignmentCenter;
        _middleLB.textColor=[UIColor whiteColor];
        _middleLB.font=[UIFont systemFontOfSize:16];
        [navgationView addSubview:_middleLB];
        
        _pointImageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 12, 6)];
        _pointImageView.center=CGPointMake(_middleLB.frame.origin.x+_middleLB.frame.size.width+6, 40);
        _pointImageView.image=[UIImage imageNamed:@"mail_other_03-1"];
        [navgationView addSubview:_pointImageView];
        
        
        
        _middleButton=[[UIButton alloc]initWithFrame:CGRectMake((Kscreenwidth-120)/2, 26, 120, 30)];
        _middleButton.backgroundColor=[UIColor clearColor];
        [navgationView addSubview:_middleButton];
        [_middleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
       
        
        
        
        
        UIImageView *searchImageView=[[UIImageView alloc]initWithFrame:CGRectMake(10, 80, 16, 16)];
        searchImageView.image=[UIImage imageNamed:@"mail_other_30-34"];
        [self addSubview:searchImageView];
        
        UILabel *searchLB=[[UILabel alloc]initWithFrame:CGRectMake(40, 65, 100, 47)];
        searchLB.text=@"搜索邮件";
        searchLB.font=[UIFont systemFontOfSize:18];
        searchLB.textColor=[UIColor colorWithRed:140/255.0 green:140/255.0 blue:140/255.0 alpha:1.0];
        [self addSubview:searchLB];
        
        _searchButton=[[UIButton alloc]initWithFrame:CGRectMake(0, 65, self.frame.size.width-80, 47)];
        _searchButton.backgroundColor=[UIColor clearColor];
        [self addSubview:_searchButton];
        
       
        
        _sendButton=[[UIButton alloc]initWithFrame:CGRectMake(self.frame.size.width-40, 79, 19, 19)];
        [_sendButton setImage:[UIImage imageNamed:@"mail_other_55"] forState:UIControlStateNormal];
        [self addSubview:_sendButton];
        
        UIView *line=[[UIView alloc]initWithFrame:CGRectMake(0, self.frame.size.height-0.5, self.frame.size.width, 0.5)];
        line.backgroundColor=Gray_Color;
        [self addSubview:line];
    }
    return self;
}




@end
