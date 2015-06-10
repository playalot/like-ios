//
//  LKPostTagsDetailModel.h
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/20.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LCHTTPRequestModel.h"

LC_BLOCK(void, LKPostTagsDetailModelRequestFinished, (LKHttpRequestResult * result, NSString * error));

@interface LKPostTagsDetailModel : LCHTTPRequestModel

LC_PROPERTY(strong) NSMutableArray * associatedTags;
LC_PROPERTY(strong) NSMutableArray * tags;
LC_PROPERTY(assign) NSInteger page;

LC_PROPERTY(copy) LKPostTagsDetailModelRequestFinished requestFinished;

-(void) loadDataWithPostID:(NSNumber *)postID getMore:(BOOL)getMore;

@end
