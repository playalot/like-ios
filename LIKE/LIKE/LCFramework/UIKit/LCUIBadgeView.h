//
//  LC_UIBadgeView.h
//  LCFramework

//  Created by Licheng Guo . ( SUGGESTIONS & BUG titm@tom.com ) on 13-9-21.
//  Copyright (c) 2014年 Licheng Guo iOS developer ( http://nsobject.me ).All rights reserved.
//  Also see the copyright page ( http://nsobject.me/copyright.rtf ).
//
//

#import <UIKit/UIKit.h>

@interface LCUIBadgeView : UIView

LC_PROPERTY(strong) UIView * badgeView;
LC_PROPERTY(strong) NSString * valueString;

LC_PROPERTY(assign) BOOL hiddenWhenEmpty;
LC_PROPERTY(assign) BOOL kawaii;

-(instancetype) initWithFrame:(CGRect)frame valueString:(NSString *)valueString;

@end
