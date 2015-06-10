//
//  LC_UIPropertyPicker.h
//  LCFramework
//
//  Created by Licheng Guo . ( SUGGESTIONS & BUG titm@tom.com ) on 13-9-21.
//  Copyright (c) 2014年 Licheng Guo iOS developer ( http://nsobject.me ).All rights reserved.
//  Also see the copyright page ( http://nsobject.me/copyright.rtf ).
//

@class LCUIPropertyPicker;

LC_BLOCK(void, LCUIPropertyPickerDidSelected, (NSInteger index, NSString * value));
LC_BLOCK(LCUIPropertyPicker *, LCUIPropertyPickerParameterArray, (NSArray * array));
LC_BLOCK(LCUIPropertyPicker *, LCUIPropertyPickerParameterString, (NSString * string));
LC_BLOCK(LCUIPropertyPicker *, LCUIPropertyPickerShow, ());
LC_BLOCK(LCUIPropertyPicker *, LCUIPropertyPickerHide, ());

@interface LCUIPropertyPicker : UIView

LC_PROPERTY(strong) UIToolbar * toolbar;
LC_PROPERTY(strong) UIPickerView * picker;
LC_PROPERTY(strong) LCUILabel * titleLabel;
LC_PROPERTY(strong) LCUIButton * sureButton;
LC_PROPERTY(strong) LCUIButton * cancelButton;

LC_PROPERTY(strong) NSArray * propertys;

LC_PROPERTY(readonly) LCUIPropertyPickerParameterArray PROPERTY;
LC_PROPERTY(readonly) LCUIPropertyPickerParameterString TITLE;
LC_PROPERTY(readonly) LCUIPropertyPickerShow SHOW;
LC_PROPERTY(readonly) LCUIPropertyPickerHide HIDE;

LC_PROPERTY(copy) LCUIPropertyPickerDidSelected DID_SELECTED;

-(void) show;
-(void) hide;

@end
