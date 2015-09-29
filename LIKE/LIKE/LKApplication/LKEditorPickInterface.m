//
//  LKEditorPickInterface.m
//  LIKE
//
//  Created by Elkins.Zhao on 15/9/29.
//  Copyright © 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKEditorPickInterface.h"

@implementation LKEditorPickInterface

- (NSString *)requestUrl {
    return @"/v1/explore/editorpick";
}

- (id)requestArgument {
    if (self.timestamp)
        return @{@"ts": self.timestamp};
    return nil;
}

- (NSNumber *)next {
    return self.responseJSONObject[@"data"][@"next"];
}

- (NSArray *)posts {
    return self.responseJSONObject[@"data"][@"posts"];
}

@end
