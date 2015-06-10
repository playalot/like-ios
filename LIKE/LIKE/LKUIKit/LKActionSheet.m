//
//  LKActionSheet.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/5/5.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKActionSheet.h"

@interface LKActionSheet () <TRActionSheetDelegate>

@end

@implementation LKActionSheet

+ (instancetype) showWithTitle:(NSString *)title
                  buttonTitles:(NSArray *)titles
                   didSelected:(LCUIActionSheetDidSelected)didSelected
{
    LKActionSheet * sheet = [[LKActionSheet alloc] initWithTitle:title buttonTitles:titles redButtonIndex:-1 delegate:nil];
    
    sheet.delegate = sheet;
    sheet.didSelected = didSelected;
    
    [sheet show];
    
    return sheet;
}

- (void)actionSheet:(TRActionSheet *)actionSheet didClickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (self.didSelected) {
        self.didSelected(buttonIndex);
    }
}

@end
