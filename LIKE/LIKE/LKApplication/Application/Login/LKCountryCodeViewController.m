//
//  LKCountryCodeViewController.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/6/15.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKCountryCodeViewController.h"

@interface LKCountryCodeViewController ()

LC_PROPERTY(strong) NSDictionary * datasource;
LC_PROPERTY(strong) NSMutableArray * keys;

@end

@implementation LKCountryCodeViewController

-(instancetype) init
{
    if (self = [super init]) {
        
        NSString * path = [[NSBundle mainBundle] pathForResource:@"country" ofType:@"plist"];
        
        self.datasource = [[NSDictionary alloc] initWithContentsOfFile:path];

        self.keys = [[[self.datasource allKeys] sortedArrayUsingSelector:@selector(compare:)] mutableCopy];
    }
    
    return self;
}

-(void) buildUI
{
    self.title = LC_LO(@"选择国家");
    
    [self setNavigationBarButton:LCUINavigationBarButtonTypeLeft image:[UIImage imageNamed:@"NavigationBarBack.png" useCache:YES] selectImage:nil];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:LKColor.color andSize:LC_SIZE(LC_DEVICE_WIDTH, 64)] forBarMetrics:UIBarMetricsDefault];
    
    self.tableView.sectionIndexColor = LKColor.color;
    self.tableView.rowHeight = 44;
}

-(void) handleNavigationBarButton:(LCUINavigationBarButtonType)type
{
    if (type == LCUINavigationBarButtonTypeLeft) {
        
        [self dismissOrPopViewController];
    }
}


#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.keys count];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString * key = self.keys[section];
    
    return [self.datasource[key] count];
}

- (LCUITableViewCell *)tableView:(LCUITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LCUITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (!cell) {
        
        cell = [[LCUITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
        
        UIView * line = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TalkLine.png" useCache:YES]];
        line.viewFrameWidth = LC_DEVICE_WIDTH;
        line.viewFrameY = 44 - line.viewFrameHeight;
        cell.ADD(line);
    }
    
    cell.textLabel.font = LK_FONT(13);
    cell.detailTextLabel.font = LK_FONT(13);
    
    NSString * key = self.keys[indexPath.section];
    
    NSArray * nameSection = self.datasource[key];
    
    NSArray * subString = [nameSection[indexPath.row] componentsSeparatedByString:@"+"];

    NSString * country = subString[0];
    NSString * code = subString[1];

    cell.textLabel.text = country;
    cell.detailTextLabel.text=[NSString stringWithFormat:@"+%@", code];
    
    return cell;
}

-(CGFloat) tableView:(LCUITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.keys[section];
}

-(CGFloat) tableView:(LCUITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}


- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return self.keys;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.didSelectedRow) {
        
        NSString * key = self.keys[indexPath.section];
        
        NSArray * nameSection = self.datasource[key];
    
        self.didSelectedRow(nameSection[indexPath.row]);
    }
    
    [self dismissOrPopViewController];
}


@end
