//
//  LC_UITableViewCell.m
//  LCFramework

//  Created by Licheng Guo . ( SUGGESTIONS & BUG titm@tom.com ) on 13-9-20.
//  Copyright (c) 2014年 Licheng Guo iOS developer ( http://nsobject.me ).All rights reserved.
//  Also see the copyright page ( http://nsobject.me/copyright.rtf ).
//
//

#import "LCUITableViewCell.h"

@implementation LCUITableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        
        [self buildUI];
    }
    
    return self;
}

-(void) buildUI
{
    
}

-(void) setSelectedViewColor:(UIColor *)selectedViewColor
{
    self.selectionStyle = UITableViewCellSelectionStyleDefault;

    UIView * view = UIView.view;
    view.backgroundColor = selectedViewColor;
    self.selectedBackgroundView = view;
}

-(UIColor *) selectedViewColor
{
    return self.selectedBackgroundView.backgroundColor;
}

@end
