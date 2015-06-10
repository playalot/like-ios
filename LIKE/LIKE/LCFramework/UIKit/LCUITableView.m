//
//  LC_UITableView.m
//  LCFramework

//  Created by Licheng Guo . ( SUGGESTIONS & BUG titm@tom.com ) on 13-9-20.
//  Copyright (c) 2014年 Licheng Guo iOS developer ( http://nsobject.me ).All rights reserved.
//  Also see the copyright page ( http://nsobject.me/copyright.rtf ).
//
//

#import "LCUITableView.h"

@implementation LCUITableView

-(void) reloadData
{
    if (self.willReload) {
        self.willReload();
    }
    
    [super reloadData];
}

-(id) autoCreateDequeueReusableCellWithIdentifier:(NSString *)identifier andClass:(Class)cellClass
{
    id cell =  [self dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[cellClass alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
    return cell;
}

-(id) autoCreateDequeueReusableCellWithIdentifier:(NSString *)identifier
                                         andClass:(Class)cellClass
                                configurationCell:(void (^)(id configurationCell))configurationCell
{
    id cell =  [self dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        
        cell = [[cellClass alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        configurationCell(cell);
    }
    
    return cell;
}


- (void)scrollToBottomAnimated:(BOOL)animated {

    NSInteger sections = [self numberOfSections];
    
    if (sections == 0){
        return;
    }
    
    NSInteger rows = [self numberOfRowsInSection:sections-1];
    
    if (rows > 0){
        
        [self scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rows - 1 inSection:sections - 1]
                                     atScrollPosition:UITableViewScrollPositionBottom
                                             animated:animated];
    }
}


+ (void) _roundCornersForSelectedBackgroundViewForTableView:(UITableView *)tableView cell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    
    NSUInteger rows = [tableView numberOfRowsInSection:indexPath.section];
    
    if (rows == 1) {
        
        [[self class] roundCorners:UIRectCornerAllCorners forView:cell.selectedBackgroundView];
        
    } else if (indexPath.row == 0) {
        
        [[self class] roundCorners:UIRectCornerTopLeft | UIRectCornerTopRight forView:cell.selectedBackgroundView];
        
    } else if (indexPath.row == rows-1) {
        
        [[self class] roundCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight forView:cell.selectedBackgroundView];
        
    } else {
        
        [[self class] roundCorners:0 forView:cell.selectedBackgroundView];
        
    }
    
}

+ (void)roundCornersForSelectedBackgroundViewForGroupTableView:(UITableView *)tableView cell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    
    if(tableView.style != UITableViewStyleGrouped){
        return;
    }
    
    if (IOS7_OR_LATER) {
        return;
    }
    
    [[self class] _roundCornersForSelectedBackgroundViewForTableView:tableView cell:cell indexPath:indexPath];
}

+ (void)roundCorners:(UIRectCorner)corners forView:(UIView *)view
{
    UIBezierPath * maskPath = [UIBezierPath bezierPathWithRoundedRect:view.bounds
                              
                                                   byRoundingCorners:corners
                              
                                                         cornerRadii:CGSizeMake(10.0, 10.0)];
    CAShapeLayer * maskLayer = [CAShapeLayer layer];
    
    maskLayer.frame = view.bounds;
    
    maskLayer.path = maskPath.CGPath;
    
    view.layer.mask = maskLayer;
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    if (self.didTap) {
        self.didTap();
    }
}

- (void)setBackgroundViewColor:(UIColor *)color
{
    _backgroundViewColor = color;
    
    UIView * background = UIView.view;
    background.viewSize = LC_SIZE(LC_DEVICE_WIDTH, LC_DEVICE_HEIGHT);
    background.backgroundColor = color;
    
    self.backgroundView = background;
}

@end
