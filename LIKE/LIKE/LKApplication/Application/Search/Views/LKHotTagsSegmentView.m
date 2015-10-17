//
//  LKHotTagsSegmentView.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/7/15.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKHotTagsSegmentView.h"
#import "LKTag.h"

@interface LKHotTagsSegmentView ()

LC_PROPERTY(strong) NSMutableArray *itemArray;
LC_PROPERTY(strong) UIScrollView *scrollView;
LC_PROPERTY(strong) UIView *line;
LC_PROPERTY(strong) LCUIButton *buttonView;

@end

@implementation LKHotTagsSegmentView

-(instancetype) init {
    if (self = [super initWithFrame:CGRectMake(0, 0, LC_DEVICE_WIDTH, 42)]) {
        self.itemArray = [NSMutableArray array];
        self.backgroundColor = LKColor.backgroundColor;
        self.alpha = 0;
    }
    return self;
}

-(void) loadHotTags {
    LKHttpRequestInterface * interface = [LKHttpRequestInterface interfaceType:@"tag/hot"].AUTO_SESSION();
    @weakly(self);
    
    [self request:interface complete:^(LKHttpRequestResult *result) {
        
        @normally(self);
        
        if (result.state == LKHttpRequestStateFinished) {
            
            NSArray * array = result.json[@"data"];
            
            NSMutableArray * tags = [NSMutableArray array];
            
            for (NSDictionary * dic in array) {
                
                LKTag * tag = [LKTag objectFromDictionary:dic];
                [tags addObject:tag];
            }
            
            [self setHotTags:tags];
            
            if (self.itemDidLoad) {
                self.itemDidLoad(tags);
            }
            
            LC_FAST_ANIMATIONS(0.25, ^{
               
                self.alpha = 1;
            });
        }
        else if (result.state == LKHttpRequestStateFailed){
            
        }
        
    }];
}

-(void) setHotTags:(NSArray *)tags
{
    self.scrollView = UIScrollView.view;
    self.scrollView.frame = self.bounds;
    self.scrollView.backgroundColor = LKColor.backgroundColor;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.ADD(self.scrollView);
    
    
    int i = 0;
    
    CGFloat padding = 30;
    
    UIView * preview = nil;
    
    for (LKTag *tag in tags) {
        
        CGSize itemSize = [tag.tag sizeWithFont:LK_FONT(14) byHeight:self.viewFrameHeight];
        
        LCUIButton *button = LCUIButton.view;
        button.title = tag.tag;
        [button setTitleColor:LC_RGB(70, 62, 56) forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [button setBackgroundImage:[[UIImage imageNamed:@"HotTagButton_Gray.png" useCache:YES] stretchableImageWithLeftCapWidth:itemSize.width * 0.5 topCapHeight:13] forState:UIControlStateNormal];
        [button setBackgroundImage:[[UIImage imageNamed:@"HotTagButton_Red.png" useCache:YES] stretchableImageWithLeftCapWidth:itemSize.width * 0.5 topCapHeight:13] forState:UIControlStateSelected];
        button.layer.cornerRadius = 6;
        button.layer.masksToBounds = YES;
        button.titleFont = LK_FONT(14);
        button.tag = i + 100;
        [button addTarget:self action:@selector(menuItemAction:) forControlEvents:UIControlEventTouchUpInside];
        button.viewFrameX = preview.viewRightX + 5;
        button.viewFrameY = 8;
        button.viewFrameWidth = itemSize.width + padding;
        button.viewFrameHeight = self.viewFrameHeight - 16;
        
        if (i == 0) {
            button.selected = YES;
            self.buttonView = button;
        }
        
        self.scrollView.ADD(button);
        [self.itemArray addObject:button];

        
        if (!LC_NSSTRING_IS_INVALID(tag.image)) {
            
//            LCUIImageView * imageView = LCUIImageView.view;
//            imageView.viewFrameX = button.viewFrameX + 5;
//            imageView.viewFrameY = button.viewFrameY + 5;
//            imageView.viewFrameWidth = button.viewFrameWidth - 10;
//            imageView.viewFrameHeight = button.viewFrameHeight - 10;
//            imageView.url = tag.image;
//            imageView.cornerRadius = imageView.viewMidHeight;
//            [self.scrollView insertSubview:imageView belowSubview:button];
//            
//            UIView * view = UIView.view;
//            view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
//            view.frame = imageView.bounds;
//            imageView.ADD(view);
//            
//            button.titleColor = [UIColor whiteColor];
        }
        
        
        
        preview = button;
        
        i++;
    }
    
    self.scrollView.contentSize = CGSizeMake(preview.viewRightX + padding, self.viewFrameHeight);
    
    
    self.line = UIView.view;
    self.line.backgroundColor = LKColor.color;
    self.line.viewFrameWidth = [self.itemArray[0] frame].size.width - 20;
    self.line.viewFrameX = [self.itemArray[0] frame].origin.x + 10;
    self.line.viewFrameHeight = 2;
    self.line.tag = 99999;
    self.line.viewFrameY = self.viewFrameHeight - self.line.viewFrameHeight;
//    self.scrollView.ADD(self.line);
    
    [self menuItemAction:self.itemArray[0]];
}

-(void) setSelectIndex:(NSInteger)index
{
    _selectIndex = index;
    
    self.buttonView.selected = NO;
    LCUIButton *view = self.FIND(index + 100);
    self.buttonView = view;
    view.selected = YES;
    
    LKValueChanged block = [self.itemDidTap copy];
    self.itemDidTap = nil;
    
    [self menuItemAction:view];
    
    self.itemDidTap = block;
}

-(void) menuItemAction:(LCUIButton *)button
{
    NSInteger index = button.tag - 100;
    
    if (self.itemArray.count < index) {
        return;
    }
    
    CGFloat contentWidth = self.scrollView.contentSize.width;
    
    if (contentWidth <= self.viewFrameWidth) {
        return;
    }

    [self scrollRectToVisibleCenteredOn:button.frame animated:YES];
    
    
    LC_FAST_ANIMATIONS(0.25, ^{
       
        self.line.viewFrameWidth = button.viewFrameWidth - 20;
        self.line.viewFrameX = button.viewFrameX + 10;
    });
    
    if (self.itemDidTap) {
        self.itemDidTap(@(button.tag - 100));
    }
    
    _selectIndex = button.tag - 100;
}

-(void)scrollRectToVisibleCenteredOn:(CGRect)visibleRect
                            animated:(BOOL)animated
{
    CGRect centeredRect = CGRectMake(visibleRect.origin.x + visibleRect.size.width/2.0 - self.frame.size.width/2.0,
                                     visibleRect.origin.y + visibleRect.size.height/2.0 - self.frame.size.height/2.0,
                                     self.frame.size.width,
                                     self.frame.size.height);
    
    [self.scrollView scrollRectToVisible:centeredRect animated:animated];
}

@end
