//
//  LKPostDetailTagCell.h
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/20.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LCUITableViewCell.h"
#import "LKTag.h"
#import "LKTagsView.h"

LC_BLOCK(void, LKPostDetailCellDidRemoved, (NSIndexPath * indexPath));
LC_BLOCK(void, LKPostDetailCellTagLikeChanged, (LKTag * tag));
LC_BLOCK(void, LKPostDetailCellShowLikesAction, (LKTag * tag));
LC_BLOCK(void, LKPostDetailCellCommentIconAction, (LKTag * tag));
LC_BLOCK(void, LKPostDetailCellReplyCommentAction, (LKTag * tag, LKComment * replyComment));

@interface LKPostDetailCell : LCUITableViewCell

LC_PROPERTY(copy) LKPostDetailCellShowLikesAction showLikesAction;
LC_PROPERTY(copy) LKPostDetailCellCommentIconAction commentAction;
LC_PROPERTY(copy) LKPostDetailCellReplyCommentAction replyAction;
LC_PROPERTY(copy) LKValueChanged showMoreAction;

LC_PROPERTY(copy) LKPostDetailCellTagLikeChanged didChanged;
LC_PROPERTY(copy) LKPostDetailCellDidRemoved didRemoved;

LC_PROPERTY(copy) LKTagItemViewRequest willRequest;

LC_PROPERTY(strong) LKTag * tagDetail;

+(CGFloat) height:(LKTag *)tag;


LC_ST_SIGNAL(PushUserCenter);

@end

