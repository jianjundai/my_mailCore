//
//  SendSearchView.m
//  mailcoreDemo
//
//  Created by ios－dai on 16/6/24.
//  Copyright © 2016年 ios－dai. All rights reserved.
//

#import "SendSearchView.h"
#import "MailDefine.h"
#import "MailGlobalData.h"
@implementation SendSearchView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _searchRusltArray=[[NSMutableArray alloc]init];
        
        UINavigationBar *navbar=[[UINavigationBar alloc]initWithFrame:CGRectMake(0, 0, Kscreenwidth, 44)];
        [self addSubview:navbar];
        _serchLB=[[UILabel alloc]initWithFrame:CGRectMake(10, 7, 70, 30)];
        _serchLB.text=@"收件人：";
        [self addSubview:_serchLB];
        
        _searchTextFild=[[UITextField alloc]initWithFrame:CGRectMake(80, 7, Kscreenwidth-120, 30)];
        [self addSubview:_searchTextFild];
        _searchTextFild.returnKeyType=UIReturnKeyNext;
        _searchTextFild.delegate=self;
        
        
        _seatchAddButton=[[UIButton alloc]initWithFrame:CGRectMake(Kscreenwidth-34, 10, 24, 24)];
        [_seatchAddButton setImage:[UIImage imageNamed:@"mail_other_25"] forState:UIControlStateNormal];
        [navbar addSubview:_seatchAddButton];
        
        _searchTableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 44, Kscreenwidth, self.frame.size.height-44)];
        [self addSubview:_searchTableView];
        _searchTableView.delegate=self;
        _searchTableView.dataSource=self;
        _searchTableView.backgroundColor=[UIColor groupTableViewBackgroundColor];
        
        [_searchTextFild addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        
    }
    return self;
}

#pragma mark -  <UITableViewDelegate,UITableViewDataSource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return self.searchRusltArray.count;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"myCell"];
    
    
    if(cell==nil){
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"myCell"];
    }
  
    ContactsModel *oneModel=[self.searchRusltArray objectAtIndex:indexPath.row];
    cell.textLabel.text=oneModel.disPlayName;
    cell.detailTextLabel.text=oneModel.mailBox;

    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ContactsModel *oneModel=[_searchRusltArray objectAtIndex:indexPath.row];
    if(self.delegate&&[self.delegate respondsToSelector:@selector(SelectTextFild:andModel:)]){
        
        [self.delegate SelectTextFild:self.currTextFild andModel:oneModel];
    
    }
    self.hidden=YES;
}

#pragma mark-通讯录搜索

-(void)textFieldDidChange:(UITextField*)textFild{
    
    NSString *textStr=textFild.text;
    if(textFild.text.length>0){
        
        NSLog(@"textStr==%@",textStr);
        [self reloadDataTableViewBy:textStr];
    }
}
-(void)reloadDataTableViewBy:(NSString*)textStr{
    
    [_searchRusltArray removeAllObjects];
    
    for ( ContactsModel *oneModel in [MailGlobalData getInstance].contactsArray) {
        if([oneModel.mailBox containsString:textStr]||[oneModel.disPlayName containsString:textStr]){
            [_searchRusltArray addObject:oneModel];
        }
    }
    if(_searchRusltArray.count==0){
        [self.searchTextFild resignFirstResponder];
       //没有搜到
        self.hidden=YES;
        if(self.delegate&&[self.delegate respondsToSelector:@selector(cancelSelect:andText:)]){
            
            [self.delegate cancelSelect:self.currTextFild andText:textStr];
            
        }
        
    }
    else{
         [_searchTableView reloadData];
    }
    
}

#pragma mark- UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    //没有搜到
    self.hidden=YES;
    if(self.delegate&&[self.delegate respondsToSelector:@selector(cancelSelect:andText:)]){
        
        [self.delegate cancelSelect:self.currTextFild andText:textField.text];
        
    }
    return YES;
}


- (void)textFieldDidDeleteBackward:(UITextField *)textField{
    //没有搜到
    self.hidden=YES;
    if(self.delegate&&[self.delegate respondsToSelector:@selector(cancelSelect:andText:)]){
        
        [self.delegate cancelSelect:self.currTextFild andText:textField.text];
        
    }

}


@end
