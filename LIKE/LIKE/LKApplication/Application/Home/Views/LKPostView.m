//
//  LKPostView.m
//  LIKE
//
//  Created by huangweifeng on 9/24/15.
//  Copyright © 2015 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKPostView.h"
#import "LKTag.h"
#import "ADTickerLabel.h"
#import "LKLikeTagItemView.h"

#define TAG_LEFT_PADDING 10.0f
#define TAG_RIGHT_PADDING 10.0f
#define TAG_TOP_PADDING 5.0f
#define TAG_BOTTOM_PADDING 5.0f

#define TAT_INNER_HORIZONTAL_MARGIN 3.0f
#define TAT_INNER_VERTICAL_MARGIN 3.0f

#define TAG_HORIZONTAL_INTERVAL 10.0f
#define TAG_VERTICAL_INTERVAL 5.0f

#define TAG_FONT_SIZE 14

@interface LKPostView ()

LC_PROPERTY(strong) LCUIImageView *head;
LC_PROPERTY(strong) LCUILabel *title;
LC_PROPERTY(strong) ADTickerLabel *likes;
LC_PROPERTY(strong) LCUILabel *likesTip;

LC_PROPERTY(strong) NSMutableArray *tagBoundList;

@end

@implementation LKPostView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.tagList = [NSMutableArray array];
        self.tagBoundList = [NSMutableArray array];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setTagList:(NSMutableArray *)tagList {
    _tagList = tagList;
    
    for (LKTag *tag in tagList) {
        [self.tagBoundList addObject:[NSValue valueWithCGRect:[self getTextBoundForTag:tag.tag]]];
    }
}

- (void)drawRect:(CGRect)rect {
    CGFloat curX = TAG_LEFT_PADDING;
    CGFloat curY = TAG_TOP_PADDING;
    CGFloat lineMaxHeight = 0;
    
    for (NSInteger i = 0; i < self.tagBoundList.count; ++i) {
        
        LKTag *tag = self.tagList[i];
        NSValue *bound = self.tagBoundList[i];
        CGRect rectangle = [bound CGRectValue];
        
        rectangle.size.width += TAT_INNER_HORIZONTAL_MARGIN * 2;
        rectangle.size.height += TAT_INNER_VERTICAL_MARGIN * 2;
        
        if (rectangle.size.width + TAG_LEFT_PADDING + TAG_RIGHT_PADDING > self.frame.size.width) {
            continue;
        }
        
        if ((curX + rectangle.size.width + TAG_RIGHT_PADDING) > self.frame.size.width) {
            curY += lineMaxHeight + TAG_VERTICAL_INTERVAL;
            curX = TAG_LEFT_PADDING;
            lineMaxHeight = 0;
        }
        
        rectangle.origin.x = curX;
        rectangle.origin.y = curY;
        
        LKLikeTagItemView *likeTagItemView = [[LKLikeTagItemView alloc] initWithFrame:rectangle];
        self.ADD(likeTagItemView);
        
        // draw table
//        CGContextRef context = UIGraphicsGetCurrentContext();
//        CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 0.5);
//        CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.5, 0.5);
//        CGContextFillRect(context, rectangle);
//        
//        UIFont* font = [UIFont systemFontOfSize:TAG_FONT_SIZE];
//        UIColor* textColor = [UIColor redColor];
//        NSDictionary* stringAttrs = @{NSFontAttributeName : font, NSForegroundColorAttributeName : textColor };
//        NSAttributedString* attrStr = [[NSAttributedString alloc] initWithString:tag.tag attributes:stringAttrs];
//        [attrStr drawAtPoint:CGPointMake(rectangle.origin.x + TAT_INNER_HORIZONTAL_MARGIN, rectangle.origin.y + TAT_INNER_VERTICAL_MARGIN)];
        
        lineMaxHeight = MAX(lineMaxHeight, rectangle.size.height);
        curX += rectangle.size.width + TAG_HORIZONTAL_INTERVAL;
    }
}

- (CGRect)getTextBoundForTag:(NSString *)tag {
    UIFont *font = [UIFont systemFontOfSize:TAG_FONT_SIZE];
    CGSize size = CGSizeMake(300,2000);
    NSDictionary *stringAttributes = [NSDictionary dictionaryWithObject:font forKey: NSFontAttributeName];
    CGSize labelsize = [tag boundingRectWithSize:size
                                         options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin
                                      attributes:stringAttributes context:nil].size;
    
    return CGRectMake(0, 0, labelsize.width, labelsize.height);
}

@end
