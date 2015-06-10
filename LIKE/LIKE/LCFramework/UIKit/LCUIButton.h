//
//  LC_UIButton.h
//  LCFramework

//  Created by Licheng Guo . ( SUGGESTIONS & BUG titm@tom.com ) on 13-9-16.
//  Copyright (c) 2014年 Licheng Guo iOS developer ( http://nsobject.me ).All rights reserved.
//  Also see the copyright page ( http://nsobject.me/copyright.rtf ).
//
//

@interface LCUIButton : UIButton

LC_PROPERTY(strong) UIImage * image;
LC_PROPERTY(strong) UIImage * buttonImage;

LC_PROPERTY(strong) NSString * title;
LC_PROPERTY(strong) UIFont * titleFont;
LC_PROPERTY(strong) UIColor * titleColor;

@end
