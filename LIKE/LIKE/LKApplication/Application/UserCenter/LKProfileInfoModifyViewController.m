//
//  LKProfileInfoModifyViewController.m
//  LIKE
//
//  Created by Elkins.Zhao on 15/10/12.
//  Copyright © 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKProfileInfoModifyViewController.h"
#import "UIImageView+WebCache.h"
#import "LKModifyUserInfoModel.h"
#import "LKUploadAvatarAndCoverModel.h"

@interface LKProfileInfoModifyViewController ()

LC_PROPERTY(strong) LCUIImageView *head;
LC_PROPERTY(strong) LCUITextField *nickField;

@end

@implementation LKProfileInfoModifyViewController

- (void)buildUI {
    
    [self buildNavigationBar];
}

- (void)buildNavigationBar {
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:LKColor.color andSize:CGSizeMake(LC_DEVICE_WIDTH, 64)] forBarMetrics:UIBarMetricsDefault];
    [self setNavigationBarButton:LCUINavigationBarButtonTypeLeft image:[UIImage imageNamed:@"NavigationBarBack.png" useCache:YES] selectImage:nil];
    self.title = LC_LO(@"个人设置");
}

- (void)handleNavigationBarButton:(LCUINavigationBarButtonType)type {
    if (type == LCUINavigationBarButtonTypeLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - ***** TableView DataSource *****
- (NSInteger)tableView:(LCUITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 2;
}

- (LCUITableViewCell *)tableView:(LCUITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LCUITableViewCell *cell = nil;
    
    if (indexPath.row == 0) {
        
        cell = [tableView autoCreateDequeueReusableCellWithIdentifier:@"Head" andClass:[LCUITableViewCell class] configurationCell:^(LCUITableViewCell * configurationCell) {
            
            configurationCell.backgroundColor = [UIColor clearColor];
            configurationCell.contentView.backgroundColor = [UIColor clearColor];
            
            LCUILabel *label = LCUILabel.view;
            label.viewFrameX = 18;
            label.viewFrameWidth = LC_DEVICE_WIDTH;
            label.viewFrameHeight = 55;
            label.font = LK_FONT(13);
            label.textColor = LC_RGB(51, 51, 51);
            label.tag = 1002;
            label.text = LC_LO(@"修改头像");
            configurationCell.ADD(label);
            
            
            self.head = LCUIImageView.view;
            self.head.viewFrameWidth = 40;
            self.head.viewFrameHeight = 40;
            self.head.viewFrameX = LC_DEVICE_WIDTH - 40 - 18;
            self.head.viewFrameY = (55 - self.head.viewFrameHeight) * 0.5;
            self.head.cornerRadius = 20;
            self.head.image = nil;
            [self.head sd_setImageWithURL:[NSURL URLWithString:LKLocalUser.singleton.user.avatar] placeholderImage:nil];
            configurationCell.ADD(self.head);
            
            
            UIView *line = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TalkLine.png" useCache:YES]];
            line.viewFrameWidth = LC_DEVICE_WIDTH;
            line.viewFrameY = 55 - line.viewFrameHeight;
            configurationCell.ADD(line);
            
        }];
    } else if (indexPath.row == 1) {
        
        cell = [tableView autoCreateDequeueReusableCellWithIdentifier:@"Nick" andClass:[LCUITableViewCell class] configurationCell:^(LCUITableViewCell * configurationCell) {
            
            configurationCell.backgroundColor = [UIColor clearColor];
            configurationCell.contentView.backgroundColor = [UIColor clearColor];
            
            LCUILabel *label = LCUILabel.view;
            label.viewFrameX = 18;
            label.viewFrameWidth = LC_DEVICE_WIDTH;
            label.viewFrameHeight = 55;
            label.font = LK_FONT(13);
            label.textColor = LC_RGB(51, 51, 51);
            label.tag = 1002;
            label.text = LC_LO(@"修改昵称");
            configurationCell.ADD(label);
            
            
            self.nickField = LCUITextField.view;
            self.nickField.viewFrameX = LC_DEVICE_WIDTH / 2 + 10;
            self.nickField.viewFrameWidth = LC_DEVICE_WIDTH / 2 - 30;
            self.nickField.viewFrameHeight = 55;
            self.nickField.font = LK_FONT(12);
            self.nickField.textColor = LC_RGB(112, 112, 112);
            self.nickField.textAlignment = UITextAlignmentRight;
            self.nickField.text = LKLocalUser.singleton.user.name;
            self.nickField.returnKeyType = UIReturnKeyDone;
            configurationCell.ADD(self.nickField);
            
            @weakly(self);
            
            self.nickField.shouldReturn = ^BOOL(id value){
                
                @normally(self);
                
                if (self.nickField.text.length <= 0) {
                    
                    return NO;
                }
                
                [self.nickField resignFirstResponder];
                
                [LKModifyUserInfoModel setNewName:self.nickField.text requestFinished:^(NSString *error) {
                    
                    if (!error) {
                        
//                        [self.fromViewController.userInfoModel getUserInfo:self.fromViewController.user.id];
                    }
                }];
                
                return YES;
            };
            
            
            UIView *line = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TalkLine.png" useCache:YES]];
            line.viewFrameWidth = LC_DEVICE_WIDTH;
            line.viewFrameY = 55 - line.viewFrameHeight;
            configurationCell.ADD(line);
        }];
    }/* else if (indexPath.row == 2) {
        
        cell = [tableView autoCreateDequeueReusableCellWithIdentifier:@"Head" andClass:[LCUITableViewCell class] configurationCell:^(LCUITableViewCell * configurationCell) {
            
            configurationCell.backgroundColor = [UIColor clearColor];
            configurationCell.contentView.backgroundColor = [UIColor clearColor];
            
            LCUILabel *label = LCUILabel.view;
            label.viewFrameX = 18;
            label.viewFrameWidth = LC_DEVICE_WIDTH;
            label.viewFrameHeight = 55;
            label.font = LK_FONT(13);
            label.textColor = LC_RGB(51, 51, 51);
            label.tag = 1002;
            label.text = LC_LO(@"个人介绍");
            configurationCell.ADD(label);
            
            
            LCUIImageView *indicatorView = LCUIImageView.view;
            indicatorView.viewFrameWidth = 11;
            indicatorView.viewFrameHeight = 20;
            indicatorView.viewFrameX = LC_DEVICE_WIDTH - 11 - 18;
            indicatorView.viewFrameY = (55 - indicatorView.viewFrameHeight) * 0.5;
            indicatorView.image = [UIImage imageNamed:@"RightArrow.png" useCache:YES];
            configurationCell.ADD(indicatorView);
            
            
            UIView *line = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TalkLine.png" useCache:YES]];
            line.viewFrameWidth = LC_DEVICE_WIDTH;
            line.viewFrameY = 55 - line.viewFrameHeight;
            configurationCell.ADD(line);
            
        }];
    }*/
    return cell;
}

#pragma mark - ***** TableView Delegate *****
- (CGFloat)tableView:(LCUITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 55;
}

- (void)tableView:(LCUITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.nickField resignFirstResponder];
    
    if (indexPath.row == 0) {
        
        @weakly(self);
        
        [LKUploadAvatarAndCoverModel chooseAvatorImage:^(NSString *error, UIImage *resultImage) {
            
            @normally(self);
            
            if (!error) {
                
                self.head.image = resultImage;
//                [self.fromViewController.userInfoModel getUserInfo:self.fromViewController.user.id];
            }
            else{
                
                [self showTopMessageErrorHud:error];
            }
            
        }];
        
    } else if (indexPath.row == 1) {
        
        [self.nickField becomeFirstResponder];
    }
}

@end
