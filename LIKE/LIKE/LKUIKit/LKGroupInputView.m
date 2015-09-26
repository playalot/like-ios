//
//  LKGroupInputView.m
//  LIKE
//
//  Created by Elkins.Zhao on 15/9/16.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKGroupInputView.h"
#import "LCUIKeyBoard.h"

@implementation LKGroupInputView

-(instancetype) init
{
    if (self = [super init]) {
        
        self.backgroundColor = [UIColor whiteColor];
        self.viewFrameWidth = LC_DEVICE_WIDTH;
        self.viewFrameHeight = 44;
        
        
        self.imageButton = LCUIButton.view;
        self.imageButton.viewFrameWidth = 32;
        self.imageButton.viewFrameHeight = 32;
        self.imageButton.viewFrameX = 5;
        self.imageButton.viewFrameY = self.viewFrameHeight - self.imageButton.viewFrameHeight - 5;
        self.imageButton.buttonImage = [UIImage imageNamed:@"KeyboardDismiss.png" useCache:YES];
        [self.imageButton addTarget:self action:@selector(chooseImage) forControlEvents:UIControlEventTouchUpInside];
        self.ADD(self.imageButton);
        
        self.dismissButton = LCUIButton.view;
        self.dismissButton.viewFrameWidth = 50;
        self.dismissButton.viewFrameHeight = self.viewFrameHeight;
        self.dismissButton.viewFrameX = self.viewFrameWidth - 50;
        self.dismissButton.buttonImage = [UIImage imageNamed:@"KeyboardDismiss.png" useCache:YES];
        [self.dismissButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        self.dismissButton.image = nil;
        self.dismissButton.buttonImage = nil;
        self.dismissButton.title = LC_LO(@"发布");
        self.dismissButton.titleFont = LK_FONT(13);
        self.dismissButton.titleColor = LC_RGBA(99, 99, 99, 1);
        self.ADD(self.dismissButton);
        
        
        self.textField = LCUITextField.view;
        self.textField.viewFrameX = self.imageButton.viewRightX + 5;
        self.textField.viewFrameY = 6;
        self.textField.viewFrameWidth = self.dismissButton.viewFrameX - self.textField.viewFrameX - 5;;
        self.textField.viewFrameHeight = 32;
        self.textField.leftContentPadding = 10;
        self.textField.rightContentPadding = 10;
        self.textField.placeholder = LC_LO(@"发表你的看法");
        self.textField.placeholderColor = LC_RGB(180, 180, 180);
        self.textField.font = LK_FONT(13);
        self.textField.returnKeyType = UIReturnKeyDone;
        self.textField.textColor = LKColor.color;
        self.textField.cornerRadius = 4;
        self.textField.layer.masksToBounds = NO;
        self.textField.borderColor = LC_RGB(230, 231, 232);
        self.textField.borderWidth = 0.5;
        self.ADD(self.textField);
        
        
        @weakly(self);
        
        self.textField.shouldReturn = ^BOOL(id value){
            
            @normally(self);
            
            if (self.textField.text.length) {
                
                if (self.sendAction) {
                    self.sendAction(self.textField.text);
                }
            }
            
            return YES;
            
        };
        
        self.textField.shouldBeginEditing = ^ BOOL (id value){
            
            @normally(self);
            
            [LCUIKeyBoard.singleton setAccessor:self];
            
            return YES;
        };
        
        self.textField.didBeginEditing = ^(id value){
            
            @normally(self);
            
            if (self.didShow) {
                self.didShow();
            }
        };
        
        self.textField.didEndEditing = ^(id value){
            
            @normally(self);
            
            if (self.willDismiss) {
                
                self.willDismiss(self.textField.text);
            }
        };
    }
    
    return self;
}

-(void) dismiss
{
    if (self.textField.text.length) {
        
        if (self.sendAction) {
            
            self.sendAction(self.textField.text);
        }
    }
}

-(BOOL) becomeFirstResponder
{
    [super becomeFirstResponder];
    
    return [self.textField becomeFirstResponder];
}

-(void) removeFromSuperview
{
    LCUIKeyBoard.singleton.PERFORM_DELAY(@selector(setAccessor:), nil, 0);
    
    [super removeFromSuperview];
}

-(BOOL) resignFirstResponder
{
    [super resignFirstResponder];
    
    BOOL result = [self.textField resignFirstResponder];
    
    if (result) {
        LCUIKeyBoard.singleton.PERFORM_DELAY(@selector(setAccessor:), nil, 0);
    }
    
    return result;
}

-(BOOL) isFirstResponder
{
    return [self.textField isFirstResponder];
}

- (void)chooseImage {
    
    NSLog(@"%s", __FUNCTION__);
}

@end
