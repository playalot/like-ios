//
//  LC_UILabel.m
//  LCFramework

//  Created by Licheng Guo . ( SUGGESTIONS & BUG titm@tom.com ) on 13-9-21.
//  Copyright (c) 2014年 Licheng Guo iOS developer ( http://nsobject.me ).All rights reserved.
//  Also see the copyright page ( http://nsobject.me/copyright.rtf ).
//
//

#import "LCUILabel.h"

@interface LCUILabel ()

LC_PROPERTY(strong) UILongPressGestureRecognizer * longPressGestureRecognizer;

@end

@implementation LCUILabel

- (void)setCopyEnbled:(BOOL)copyEnbled
{
    if (_copyEnbled != copyEnbled)
    {
        [self willChangeValueForKey:@"copyEnbled"];
        _copyEnbled = copyEnbled;
        [self didChangeValueForKey:@"copyEnbled"];
        
        self.userInteractionEnabled = copyEnbled;
        self.longPressGestureRecognizer.enabled = copyEnbled;
    }
}

- (id)init
{
	self = [super initWithFrame:CGRectZero];
    
	if (self){
        
        [self defaultConfig];
	}
    
	return self;
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
    
	if (self){
        
        [self defaultConfig];
	}
    
	return self;
}

-(void) defaultConfig
{
    self.font = [UIFont systemFontOfSize:12.0f];
    self.textColor = [UIColor whiteColor];
    self.backgroundColor = [UIColor clearColor];
    self.lineBreakMode = UILineBreakModeTailTruncation;
    self.userInteractionEnabled = YES;
}

-(UILongPressGestureRecognizer *) longPressGestureRecognizer
{
    if (!_longPressGestureRecognizer){
        
        _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector($longPressGestureRecognized:)];
        [self addGestureRecognizer:_longPressGestureRecognizer];
    }
    
    return _longPressGestureRecognizer;
}

- (void) $longPressGestureRecognized:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == self.longPressGestureRecognizer)
    {
        if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
        {
            //            NSAssert([self becomeFirstResponder], @"Sorry, UIMenuController will not work with %@ since it cannot become first responder", self);
            [self becomeFirstResponder];    // must be called even when NS_BLOCK_ASSERTIONS=0
            
            UIMenuController * copyMenu = [UIMenuController sharedMenuController];
            [copyMenu setTargetRect:self.bounds inView:self];
            copyMenu.arrowDirection = UIMenuControllerArrowDefault;
            [copyMenu setMenuVisible:YES animated:YES];
        }
    }
}

#pragma mark - UIResponder

- (BOOL)canBecomeFirstResponder
{
    return self.copyEnbled;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    BOOL retValue = NO;
    
    if (action == @selector(copy:))
    {
        if (self.copyEnbled)
        {
            retValue = YES;
        }
    }
    else
    {
        // Pass the canPerformAction:withSender: message to the superclass
        // and possibly up the responder chain.
        retValue = [super canPerformAction:action withSender:sender];
    }
    
    return retValue;
}

- (void)copy:(id)sender
{
    if (self.copyEnbled)
    {
        UIPasteboard * pasteboard = [UIPasteboard generalPasteboard];
        
        NSString * stringToCopy = self.text;
        
        [pasteboard setString:stringToCopy];
    }
}


-(void) setStrikeThroughLine:(BOOL)strikeThroughLine
{
    _strikeThroughLine = strikeThroughLine;
    
    [self setNeedsDisplay];
}


- (void)drawRect:(CGRect)rect
{
    if (self.strikeThroughLine)
    {
        CGSize contentSize = [self.text sizeWithFont:self.font constrainedToSize:self.frame.size];
        CGContextRef c = UIGraphicsGetCurrentContext();
        //CGFloat color[4] = {0.667, 0.667, 0.667, 1.0};
        CGContextSetStrokeColor(c, CGColorGetComponents(self.textColor.CGColor));
        CGContextSetLineWidth(c, 1);
        CGContextBeginPath(c);
        CGFloat halfWayUp = (self.bounds.size.height - self.bounds.origin.y) / 2.0;
        CGContextMoveToPoint(c, self.bounds.origin.x, halfWayUp );
        CGContextAddLineToPoint(c, self.bounds.origin.x + contentSize.width, halfWayUp);
        CGContextStrokePath(c);
    }
    
    [super drawRect:rect];
}

@end
