//
//  LKHotTagsPage.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/7/15.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKHotTagsPage.h"
#import "LKHotTagsScrollView.h"
#import "LKTag.h"
#import "LKHotUserView.h"
#import "CHTCollectionViewWaterfallLayout.h"
#import "LKSearchResultCollectionViewCell.h"
#import "LKMoreContentButton.h"

// test

#define CELL_IDENTIFIER @"WaterfallCell"
#define HEADER_IDENTIFIER @"WaterfallHeader"
#define FOOTER_IDENTIFIER @"WaterfallFooter"


@interface LKHotTagsPage () <UICollectionViewDataSource, UICollectionViewDelegate, CHTCollectionViewDelegateWaterfallLayout>

LC_PROPERTY(strong) LKTag * tagValue;

LC_PROPERTY(assign) BOOL loadFinished;
LC_PROPERTY(assign) BOOL loading;

LC_PROPERTY(strong) NSArray * posts;

LC_PROPERTY(strong) CHTCollectionViewWaterfallLayout * layout;

LC_PROPERTY(strong) LKHotUserView * hotUsersView;

@end

@implementation LKHotTagsPage

-(void) dealloc
{
    [self cancelAllRequests];
}

-(instancetype) initWithTag:(LKTag *)tag
{
    CHTCollectionViewWaterfallLayout * layout = [[CHTCollectionViewWaterfallLayout alloc] init];
    
    layout.sectionInset = UIEdgeInsetsMake(0, 5, 5, 5);
    layout.headerHeight = 92;
    layout.footerHeight = 70;
    layout.minimumColumnSpacing = 5;
    layout.minimumInteritemSpacing = 5;
    layout.columnCount = 2;

    
    if (self = [super initWithFrame:CGRectZero collectionViewLayout:layout]) {
        
        self.tagValue = tag;

        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.dataSource = self;
        self.delegate = self;
        self.backgroundColor = [UIColor clearColor];
        
        
        [self registerClass:[LKSearchResultCollectionViewCell class]
            forCellWithReuseIdentifier:CELL_IDENTIFIER];
        
        [self registerClass:[LKHotUserView class] forSupplementaryViewOfKind:CHTCollectionElementKindSectionHeader withReuseIdentifier:HEADER_IDENTIFIER];

        [self registerClass:[LKMoreContentButton class] forSupplementaryViewOfKind:CHTCollectionElementKindSectionFooter withReuseIdentifier:FOOTER_IDENTIFIER];
        
        self.alpha = 0;
        
    }
    
    return self;
}

-(void) show
{
    if (self.loading || self.loadFinished) {
        return;
    }

    [self sendNetWorkRequest];
}

- (void)sendNetWorkRequest {
    
    // request
    //
    LKHttpRequestInterface * interface = [LKHttpRequestInterface interfaceType:[NSString stringWithFormat:@"explore/tag/%@",self.tagValue.tag.URLCODE()]].AUTO_SESSION();
    
    @weakly(self);
    
    [self request:interface complete:^(LKHttpRequestResult *result) {
        
        @normally(self);
        
        if (result.state == LKHttpRequestStateFinished) {
            
            NSArray * usersDic = result.json[@"data"][@"hot_users"];
            
            NSMutableArray * users = [NSMutableArray array];
            
            for (NSDictionary * user in usersDic) {
                
                [users addObject:[LKUser objectFromDictionary:user]];
            }
            
            self.hotUsersView.hotUsers = users;
            
            NSArray * postsDic = result.json[@"data"][@"posts"];
            
            NSMutableArray * posts = [NSMutableArray array];
            
            for (NSDictionary * post in postsDic) {
                
                [posts addObject:[LKPost objectFromDictionary:post]];
            }
            
            self.posts = posts;
            
            [self reloadData];
            
            LC_FAST_ANIMATIONS(0.25, ^{
                
                self.alpha = 1;
            });
            
            self.loading = NO;
            self.loadFinished = YES;
        }
        else if (result.state == LKHttpRequestStateFailed){
            
            self.loading = NO;
            self.loadFinished = NO;
        }
        
    }];
    
}


#pragma mark -

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.posts.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    LKSearchResultCollectionViewCell * cell = (LKSearchResultCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];

    cell.post = self.posts[indexPath.row];
        
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView * reusableView = nil;
    
    if ([kind isEqualToString:CHTCollectionElementKindSectionHeader]) {
        
        reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind  withReuseIdentifier:HEADER_IDENTIFIER forIndexPath:indexPath];
        
        self.hotUsersView = (LKHotUserView *)reusableView;
    }
    else if ([kind isEqualToString:CHTCollectionElementKindSectionFooter]){
        
        reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind  withReuseIdentifier:FOOTER_IDENTIFIER forIndexPath:indexPath];
        
        [((LKMoreContentButton *)reusableView) setTagValue:self.tagValue];
    }
    
    return reusableView;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [LKSearchResultCollectionViewCell sizeWithPost:self.posts[indexPath.row]];
}

-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGPoint offset = scrollView.contentOffset;
    CGSize contentSize = scrollView.contentSize;
    
    if (offset.y > (contentSize.height - 2 * LC_DEVICE_HEIGHT)) {
        
        // 发送网络请求
        [self sendNetWorkRequest];
    }
}

@end
