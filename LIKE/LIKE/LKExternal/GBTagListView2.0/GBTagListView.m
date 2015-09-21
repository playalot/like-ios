//
//  GBTagListView.m
//  升级版流式标签支持点击
//
//  Created by 张国兵 on 15/8/16.
//  Copyright (c) 2015年 zhangguobing. All rights reserved.
//

#import "GBTagListView.h"
#define HORIZONTAL_PADDING 20.0f
#define VERTICAL_PADDING   4.0f
#define LABEL_MARGIN       10.0f
#define BOTTOM_MARGIN      10.0f
#define KBtnTag            1000
#define R_G_B_16(rgbValue)\
\
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 \
alpha:1.0]

@implementation GBTagListView
-(id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        
        totalHeight = 0;
        self.frame = frame;
        _tagArr = [[NSMutableArray alloc]init];
        self.backgroundColor = [UIColor cyanColor];
    }
    return self;
}
-(void)setTagWithTagArray:(NSArray*)arr{
    
    previousFrame = CGRectZero;
    [_tagArr addObjectsFromArray:arr];
    [arr enumerateObjectsUsingBlock:^(NSString*str, NSUInteger idx, BOOL *stop) {
        
        LCUIButton *tagBtn = [LCUIButton buttonWithType:UIButtonTypeCustom];
        
        tagBtn.frame=CGRectZero;
        
        //        if(_signalTagColor){
        //            //可以单一设置tag的颜色
        //            tagBtn.backgroundColor=_signalTagColor;
        //        }else{
        //            //tag颜色多样
        //            tagBtn.backgroundColor=[UIColor colorWithRed:random()%255/255.0 green:random()%255/255.0 blue:random()%255/255.0 alpha:1];
        //        }
        //        if(_canTouch){
        //
        //            tagBtn.userInteractionEnabled=YES;
        //
        //        }else{
        //
        //            tagBtn.userInteractionEnabled=NO;
        //        }
        
        tagBtn.backgroundColor = LKColor.color;
        
        tagBtn.userInteractionEnabled = NO;
        //        [tagBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        tagBtn.titleLabel.font = LK_FONT_B(11);
        
        [tagBtn setTitle:str forState:UIControlStateNormal];
        tagBtn.tag = KBtnTag + idx;
        tagBtn.layer.cornerRadius = 9;
        tagBtn.clipsToBounds = YES;
        NSDictionary *attrs = @{NSFontAttributeName : LK_FONT_B(11)};
        CGSize Size_str = [str sizeWithAttributes:attrs];
        Size_str.width += HORIZONTAL_PADDING;
        Size_str.height += VERTICAL_PADDING;
        
        CGRect newRect = CGRectZero;
        
        if (previousFrame.origin.x + previousFrame.size.width + Size_str.width + LABEL_MARGIN > self.bounds.size.width) {
            
            newRect.origin = CGPointMake(10, previousFrame.origin.y + Size_str.height + BOTTOM_MARGIN);
            totalHeight += Size_str.height + BOTTOM_MARGIN;
        }
        else {
            
            newRect.origin = CGPointMake(previousFrame.origin.x + previousFrame.size.width + LABEL_MARGIN, previousFrame.origin.y);
        }
        
        newRect.size = Size_str;
        [tagBtn setFrame:newRect];
        previousFrame = tagBtn.frame;
        [self setHight:self andHight:totalHeight+Size_str.height + BOTTOM_MARGIN];
        [self addSubview:tagBtn];
        
    }];
    
//    self.backgroundColor = LKColor.backgroundColor;
}

#pragma mark-改变控件高度
- (void)setHight:(UIView *)view andHight:(CGFloat)hight
{
    CGRect tempFrame = view.frame;
    tempFrame.size.height = hight;
    view.frame = tempFrame;
}
//-(void)tagBtnClick:(UIButton*)button{
//    button.selected=!button.selected;
//    if(button.selected==YES){
//        
//        button.backgroundColor=[UIColor orangeColor];
//    }else if (button.selected==NO){
//        button.backgroundColor=[UIColor whiteColor];
//    }
//    
//    [self didSelectItems];
//    
//    
//}
//-(void)didSelectItems{
//    
//    NSMutableArray*arr=[[NSMutableArray alloc]init];
//    for(UIView*view in self.subviews){
//        
//        if([view isKindOfClass:[UIButton class]]){
//            
//            UIButton*tempBtn=(UIButton*)view;
//            if (tempBtn.selected==YES) {
//                [arr addObject:_tagArr[tempBtn.tag-KBtnTag]];
//            }
//            
//        }
//        
//    }
//
//    self.didselectItemBlock(arr);
//    
//}
@end
