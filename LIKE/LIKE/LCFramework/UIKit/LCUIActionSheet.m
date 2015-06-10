//
//  LC_UIActionSheet.m
//  LCFramework

//  Created by Licheng Guo . ( SUGGESTIONS & BUG titm@tom.com ) on 13-9-21.
//  Copyright (c) 2014年 Licheng Guo iOS developer ( http://nsobject.me ).All rights reserved.
//  Also see the copyright page ( http://nsobject.me/copyright.rtf ).
//
//

#import "LCUIActionSheet.h"

@interface LCUIActionSheet () <UIActionSheetDelegate>

@end

@implementation LCUIActionSheet

-(void) showInView:(UIView *)view animated:(BOOL)animated
{
    self.delegate = self;
    
    [super showInView:LC_KEYWINDOW];
}

-(void) showInView:(UIView *)theView
{
    self.delegate = self;
    
    [super showInView:LC_KEYWINDOW];
}

-(LCUIActionSheetParameterString) ADD
{
    LCUIActionSheetParameterString block = ^ LCUIActionSheet * (NSString * title){
    
        [self addButtonWithTitle:title];
        return self;
    };
    
    return block;;
}

-(LCUIActionSheetParameterString) TITLE
{
    LCUIActionSheetParameterString block = ^ LCUIActionSheet * (NSString * title){
        
        self.title = title;
        return self;
    };
    
    return block;
}

-(LCUIActionSheetShow) SHOW
{
    LCUIActionSheetShow block = ^ LCUIActionSheet * (UIView * inView){
        
        self.delegate = self;
        self.cancelButtonIndex = self.numberOfButtons - 1;
        
        [self showInView:inView animated:YES];
        return self;
    };
    
    return block;
}

-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (self.DID_SELECTED) {
        self.DID_SELECTED(buttonIndex);
    }
}

@end
