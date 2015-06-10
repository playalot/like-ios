//
//  LC_UITapMaskView.h
//  WuxianchangPro
//
//  Created by Licheng Guo . ( SUGGESTIONS & BUG titm@tom.com ) on 13-11-1.
//  Copyright (c) 2013年 Wuxiantai Developer ( http://www.wuxiantai.com ). All rights reserved.
//


@class LCUIMaskView;

LC_BLOCK(void, LCUIMaskViewWillHide, (LCUIMaskView * maskView));

@interface LCUIMaskView : UIView

LC_PROPERTY(copy) LCUIMaskViewWillHide willHide;

-(void) show;
-(void) hide;
-(void) hide:(BOOL)animated;
@end
