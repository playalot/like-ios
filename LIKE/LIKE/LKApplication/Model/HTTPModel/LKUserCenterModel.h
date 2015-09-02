//
//  LKUserCenterModel.h
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/15.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LCHTTPRequestModel.h"

typedef NS_ENUM(NSInteger, LKUserCenterModelType)
{
    LKUserCenterModelTypePhotos,
    LKUserCenterModelTypeFocus,
    LKUserCenterModelTypeFans,
    LKUserCenterModelTypeFavor
};

LC_BLOCK(void, LKUserCenterModelRequestFinished, (LKUserCenterModelType type, LKHttpRequestResult * result, NSString * error));

@interface LKUserCenterModel : LCHTTPRequestModel

LC_PROPERTY(strong) NSMutableArray *photoArray;
LC_PROPERTY(strong) NSMutableArray *focusArray;
LC_PROPERTY(strong) NSMutableArray *fansArray;
LC_PROPERTY(strong) NSMutableArray *favorArray;

LC_PROPERTY(copy) LKUserCenterModelRequestFinished requestFinished;

-(void) getDataAtFirstPage:(BOOL)isFirstPage type:(LKUserCenterModelType)type uid:(NSNumber *)uid;

-(NSMutableArray *) dataWithType:(LKUserCenterModelType)type;

-(BOOL) canLoadMoreWithType:(LKUserCenterModelType)type;

@end
