//
//  LKBaseInterface.h
//  LIKE
//
//  Created by huangweifeng on 9/21/15.
//  Copyright © 2015 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LCBaseRequest.h"

@interface LKBaseInterface : LCBaseRequest

- (NSInteger)errorCode;

- (NSString *)errorMessage;

@end
