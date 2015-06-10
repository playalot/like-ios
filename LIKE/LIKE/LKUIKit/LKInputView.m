//
//  IFInputView.m
//  IFAPP
//
//  Created by Leer on 15/3/17.
//  Copyright (c) 2015年 Licheng Guo . ( http://nsobject.me ). All rights reserved.
//

#import "LKInputView.h"
#import "LCUIKeyBoard.h"

@interface LKInputView()

@end

@implementation LKInputView

-(instancetype) init
{
    if (self = [super init]) {
        
//        UIView * view = UIView.view.WIDTH(LC_DEVICE_WIDTH).HEIGHT(1).COLOR([LKColor.color colorWithAlphaComponent:0.5]);
//        self.ADD(view);
        
        
        self.tintColor = [UIColor whiteColor];
        self.viewFrameWidth = LC_DEVICE_WIDTH;
        self.viewFrameHeight = 44;
        
        
        self.dismissButton = LCUIButton.view;
        self.dismissButton.viewFrameWidth = 50;
        self.dismissButton.viewFrameHeight = self.viewFrameHeight;
        self.dismissButton.viewFrameX = self.viewFrameWidth - 50;
        self.dismissButton.buttonImage = [UIImage imageNamed:@"KeyboardDismiss.png" useCache:YES];
        [self.dismissButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        self.dismissButton.image = nil;
        self.dismissButton.buttonImage = nil;
        self.dismissButton.title = @"添加";
        self.dismissButton.titleFont = LK_FONT(13);
        self.dismissButton.titleColor = LC_RGBA(99, 99, 99, 1);
        self.ADD(self.dismissButton);
        

        self.textField = LCUITextField.view;
        self.textField.viewFrameX = 10;
        self.textField.viewFrameY = 6;
        self.textField.viewFrameWidth = self.viewFrameWidth - 50 - 15;
        self.textField.viewFrameHeight = 32;
        self.textField.leftContentPadding = 10;
        self.textField.rightContentPadding = 10;
        self.textField.placeholder = LC_LO(@"添加标签（最多12个字）");
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

@end
