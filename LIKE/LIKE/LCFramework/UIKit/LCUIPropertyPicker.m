//
//  LC_UIPropertyPicker.m
//  LCFramework
//
//  Created by Licheng Guo . ( SUGGESTIONS & BUG titm@tom.com ) on 13-9-21.
//  Copyright (c) 2014年 Licheng Guo iOS developer ( http://nsobject.me ).All rights reserved.
//  Also see the copyright page ( http://nsobject.me/copyright.rtf ).
//

#import "LCUIPropertyPicker.h"

@interface LCUIPropertyPicker ()<UIPickerViewDataSource,UIPickerViewDelegate>
{
    BOOL _added;
    
    UIButton * _cancelTopButton;
}

@end

@implementation LCUIPropertyPicker

-(id) init
{
    self = [super initWithFrame:CGRectMake(0, 0, LC_DEVICE_WIDTH, LC_DEVICE_HEIGHT+20)];
    if (self) {
        
        [self initSelf:CGRectMake(0, 0, LC_DEVICE_WIDTH, LC_DEVICE_HEIGHT+20)];
    }
    return self;
}

-(id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self initSelf:frame];
    }
    return self;
}

-(void) initSelf:(CGRect)frame
{
    _cancelTopButton = LCUIButton.view;
    _cancelTopButton.frame = CGRectMake(0, 0, LC_DEVICE_WIDTH, frame.size.height);
    [_cancelTopButton addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_cancelTopButton];
    
    self.picker = LC_AUTORELEASE([[UIPickerView alloc] init]);
    self.picker.delegate = self;
    self.picker.dataSource = self;
    self.picker.backgroundColor = [UIColor whiteColor];
    self.picker.showsSelectionIndicator = YES;
    [self addSubview:self.picker];
    
    
    self.picker.frame = CGRectMake(0, self.viewFrameHeight-_picker.viewFrameHeight, self.viewFrameWidth, _picker.viewFrameHeight);
    
    self.toolbar = LC_AUTORELEASE([[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, LC_DEVICE_WIDTH, 42)]);
    _toolbar.backgroundColor = [UIColor colorWithRed:248./255. green:248./255. blue:248./255. alpha:1];
    [self addSubview:_toolbar];
    
    
    self.cancelButton = LC_AUTORELEASE([[LCUIButton alloc] init]);
    self.cancelButton.frame = CGRectMake(0, 0, 61, 42);
    self.cancelButton.title = @"取消";
    self.cancelButton.titleFont = [UIFont systemFontOfSize:15];
    self.cancelButton.titleColor = LC_RGBA(51, 51, 51, 1);
    [self.cancelButton addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    [self.toolbar addSubview:self.cancelButton];
    
    
    self.sureButton = LC_AUTORELEASE([[LCUIButton alloc] init]);
    self.sureButton.frame = CGRectMake(frame.size.width-61, 0, 61, 42);
    self.sureButton.title = @"确定";
    self.sureButton.titleFont = [UIFont systemFontOfSize:15];
    self.sureButton.titleColor = LC_RGBA(51, 51, 51, 1);
    [self.sureButton addTarget:self action:@selector(sureAction) forControlEvents:UIControlEventTouchUpInside];
    [self.toolbar addSubview:self.sureButton];
}

-(void) setPropertys:(NSArray *)propertys
{
    _propertys = propertys;
    
    [self.picker reloadAllComponents];
}

-(LCUIPropertyPickerParameterArray) PROPERTY
{
    LCUIPropertyPickerParameterArray block = ^ LCUIPropertyPicker * (NSArray * value){
      
        self.propertys = value;
        return self;
    };
    
    return block;
}

-(LCUIPropertyPickerParameterString) TITLE
{
    LCUIPropertyPickerParameterString block = ^ LCUIPropertyPicker * (NSString * string){
        
        self.titleLabel.text = string;
        return self;
    };
    
    return block;
}

-(LCUIPropertyPickerShow) SHOW
{
    LCUIPropertyPickerShow block = ^ LCUIPropertyPicker * (){
      
        [self show];
        return self;
    };
    
    return block;
}

-(LCUIPropertyPickerHide) HIDE
{
    LCUIPropertyPickerHide block = ^ LCUIPropertyPicker * (){
        
        [self hide];
        return self;
    };
    
    return block;
}

- (void) show
{
    if (_added) {
        return;
    }
    
    _added = YES;
    
    self.alpha = 0;
    
    self.WIDTH(LC_DEVICE_WIDTH).HEIGHT(LC_DEVICE_HEIGHT + 20);
    self.picker.Y(self.viewFrameHeight - self.picker.viewFrameHeight).WIDTH(self.viewFrameWidth);
    self.toolbar.Y(self.viewFrameHeight - self.picker.viewFrameHeight - self.toolbar.viewFrameHeight);
    
    _cancelButton.WIDTH(self.viewFrameWidth).HEIGHT(self.toolbar.viewFrameY);

    [LC_KEYWINDOW addSubview:self];
    
    LC_FAST_ANIMATIONS(0.15, ^{
        
        self.alpha = 1;
    });
}

-(void) hide
{
    if (!_added) {
        return;
    }
    
    LC_FAST_ANIMATIONS_F(0.15, ^{
    
        self.alpha = 0;
    
    }, ^(BOOL isFinished){
        
        _added = NO;
        [self removeFromSuperview];
    });
    
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.propertys.count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.propertys[row];
}

-(void) cancelAction
{
    [self hide];
}

-(void) sureAction
{
    if (self.DID_SELECTED) {
        
        NSInteger selectRow = [self.picker selectedRowInComponent:0];
        self.DID_SELECTED(selectRow ,self.propertys[selectRow]);
    }
    
    [self hide];
}


@end
