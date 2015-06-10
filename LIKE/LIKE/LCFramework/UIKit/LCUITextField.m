//
//  LC_UITextField.h
//  LCFramework

//  Created by Licheng Guo . ( SUGGESTIONS & BUG titm@tom.com ) on 13-9-16.
//  Copyright (c) 2014年 Licheng Guo iOS developer ( http://nsobject.me ).All rights reserved.
//  Also see the copyright page ( http://nsobject.me/copyright.rtf ).
//
//

#import "LCUITextField.h"


@interface LCUITextFieldHandle : NSObject<UITextFieldDelegate>

LC_PROPERTY(assign) LCUITextField * textField;
LC_PROPERTY(assign) NSInteger maxLength;

@end

@implementation LCUITextFieldHandle

- (BOOL)textFieldShouldBeginEditing:(LCUITextField *)textField
{
    if (textField.shouldBeginEditing) {
        return textField.shouldBeginEditing((LCUITextField *)textField);
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(LCUITextField *)textField
{
    if (textField.didBeginEditing) {
        textField.didBeginEditing((LCUITextField *)textField);
    }
}

- (BOOL)textFieldShouldEndEditing:(LCUITextField *)textField
{
    if (textField.shouldEndEditing) {
        return textField.shouldEndEditing((LCUITextField *)textField);
    }
    
    return YES;
}

- (void)textFieldDidEndEditing:(LCUITextField *)textField
{
    if (textField.didEndEditing) {
        textField.didEndEditing((LCUITextField *)textField);
    }
}

- (BOOL)textField:(LCUITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.shouldChangeCharacters) {
        return textField.shouldChangeCharacters((LCUITextField *)textField, range, string);
    }
    
    if ([string isEqualToString:@""]) {
        return YES;
    }
    
    if (self.maxLength == 0) {
        return YES;
    }
    
//    NSString * new = [textField.text stringByReplacingCharactersInRange:range withString:string];
//    NSInteger res = self.maxLength - [new length];
//    if(res >= 0)
//    {
//        return YES;
//    }
//    else
//    {
//        NSRange rg = {0,[string length]+res};
//        if (rg.length>0)
//        {
//            NSString * s = [string substringWithRange:rg];
//            [textField setText:[textField.text stringByReplacingCharactersInRange:range withString:s]];
//        }
//        return NO;
//    }
    
    return YES;
}

- (BOOL)textFieldShouldClear:(LCUITextField *)textField
{
    if (textField.shouldClear) {
        return textField.shouldClear((LCUITextField *)textField);
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(LCUITextField *)textField
{
    if (textField.shouldReturn) {
        return textField.shouldReturn((LCUITextField *)textField);
    }
    
    return YES;
}


@end

@interface LCUITextField ()<UITextFieldDelegate>

LC_PROPERTY(strong) LCUITextFieldHandle * handle;

@end

@implementation LCUITextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        [self initSelf];
    }
    return self;
}

-(id) init
{
    LC_SUPER_INIT({
        
        [self initSelf];
    })
}

-(void) initSelf
{
    self.handle = [[LCUITextFieldHandle alloc] init];
    self.handle.maxLength = self.maxLength;
    self.delegate = self.handle;
    self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
}

-(void) setMaxLength:(NSInteger)maxLength
{
    _maxLength = maxLength;
    self.handle.maxLength = self.maxLength;
}

-(void) setLeftView:(UIView *)leftView
{
    self.leftViewMode = UITextFieldViewModeAlways;
    
    [super setLeftView:leftView];
}

-(void) setRightView:(UIView *)rightView
{
    self.rightViewMode = UITextFieldViewModeAlways;
    
    [super setRightView:rightView];
}

-(void) setLeftContentPadding:(CGFloat)leftContentPadding
{
    _leftContentPadding = leftContentPadding;
    
    UIView * view = UIView.view;
    view.viewFrameWidth = leftContentPadding;
    view.viewFrameHeight = self.viewFrameHeight;
    
    self.leftView = view;
}

-(void) setRightContentPadding:(CGFloat)rightContentPadding
{
    _rightContentPadding = rightContentPadding;
    
    UIView * view = UIView.view;
    view.viewFrameWidth = rightContentPadding;
    view.viewFrameHeight = self.viewFrameHeight;
    
    self.rightView = view;
}

-(void) setPlaceholderColor:(UIColor *)placeholderColor
{
    _placeholderColor = placeholderColor;
    
    self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.placeholder attributes:@{NSForegroundColorAttributeName:placeholderColor}];
}


@end
