//
//  LKTagLikesViewController.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/21.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKTagLikesViewController.h"
#import "LKTagLikesCell.h"
#import "LKUserCenterViewController.h"

@interface LKTagLikesViewController ()

LC_PROPERTY(strong) LKTag * tag;
LC_PROPERTY(strong) NSMutableArray * datasource;

@end

@implementation LKTagLikesViewController

-(void) dealloc
{
    [self cancelAllRequests];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:animated];

    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:[LKColor.color colorWithAlphaComponent:0.98] andSize:LC_SIZE(LC_DEVICE_WIDTH, 64)] forBarMetrics:UIBarMetricsDefault];
    
    [self setNavigationBarHidden:NO animated:animated];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

-(instancetype) initWithTag:(LKTag *)tag
{
    if (self = [super init]) {
        
        self.tag = tag;
    }
    
    return self;
}

-(void) buildUI
{
    self.title = self.tag.tag;
    
    [self setNavigationBarButton:LCUINavigationBarButtonTypeLeft image:[UIImage imageNamed:@"NavigationBarBack.png" useCache:YES] selectImage:nil];
    
    self.tableView.backgroundViewColor = LKColor.backgroundColor;
    
    @weakly(self);
    
    [self setPullLoaderStyle:LCUIPullLoaderStyleHeader beginRefresh:^(LCUIPullLoaderDiretion diretion) {
     
        @normally(self);
        
        [self loadData:diretion];
        
    }];
    
    [self loadData:LCUIPullLoaderDiretionTop];
}

-(void) loadData:(LCUIPullLoaderDiretion)diretion
{
    LKHttpRequestInterface * interface = [LKHttpRequestInterface interfaceType:[NSString stringWithFormat:@"mark/%@/likes", self.tag.id]].AUTO_SESSION();
    
    @weakly(self);
    
    [self request:interface complete:^(LKHttpRequestResult *result) {
       
        @normally(self);
        
        if (result.state == LKHttpRequestStateFinished) {
            
            NSArray * array = result.json[@"data"][@"likes"];
            
            NSMutableArray * users = [NSMutableArray array];
            
            for (NSDictionary * dic in array) {
                
                [users addObject:[LKUser objectFromDictionary:dic[@"user"]]];
            }
            
            self.datasource = users;
            
            [self.pullLoader endRefresh];
            [self reloadData];
        }
        else if (result.state == LKHttpRequestStateFailed){
            
            [self.pullLoader endRefresh];
            [self showTopMessageErrorHud:result.error];
        }
        
    }];
}

-(void) handleNavigationBarButton:(LCUINavigationBarButtonType)type
{
    if (type == LCUINavigationBarButtonTypeLeft) {
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - 

LC_HANDLE_UI_SIGNAL(PushUserInfo, signal)
{
    [LKUserCenterViewController pushUserCenterWithUser:signal.object navigationController:self.navigationController];
}

#pragma mark -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(LCUITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LKTagLikesCell * cell = [tableView autoCreateDequeueReusableCellWithIdentifier:@"Cell" andClass:[LKTagLikesCell class]];

    [cell setTagValue:self.tag andLikes:self.datasource];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat padding = 10;
    NSInteger maxCount = 0;
    
    for (NSInteger i = 0; i < 999; i++) {
        
        CGFloat width = padding * (i + 1) + 33 * i + padding;
        
        if (width > LC_DEVICE_WIDTH) {
            
            maxCount = i - 1;
            break;
        }
    }
    
    CGFloat inv = (LC_DEVICE_WIDTH - (maxCount * 33)) / (maxCount + 1);
    
    NSInteger line = self.datasource.count / maxCount + 1;
    
    return 58 + 36 + (line * 33) + (line * inv);
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ;
}

@end
