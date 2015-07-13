//
//  LKCameraRollViewController.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/6/19.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKCameraRollViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "LKCameraRollCell.h"
#import "LKPhotoRollCell.h"
#import "LKImageCropperViewController.h"
#import "LKCameraViewController.h"
#import "LKUIImagePickerViewController.h"

@interface __LKUICollectionViewLayout : UICollectionViewFlowLayout

@end

@implementation __LKUICollectionViewLayout

-(NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray * attributes = [[super layoutAttributesForElementsInRect:rect] mutableCopy];
    
    
    //从第二个循环到最后一个
    for(int i = 1; i < [attributes count]; ++i) {
        //当前attributes
        UICollectionViewLayoutAttributes *currentLayoutAttributes = attributes[i];
        //上一个attributes
        UICollectionViewLayoutAttributes *prevLayoutAttributes = attributes[i - 1];
        //我们想设置的最大间距，可根据需要改
        NSInteger maximumSpacing = 0;
        //前一个cell的最右边
        NSInteger origin = CGRectGetMaxX(prevLayoutAttributes.frame);
        //如果当前一个cell的最右边加上我们想要的间距加上当前cell的宽度依然在contentSize中，我们改变当前cell的原点位置
        //不加这个判断的后果是，UICollectionView只显示一行，原因是下面所有cell的x值都被加到第一行最后一个元素的后面了
        if(origin + maximumSpacing + currentLayoutAttributes.frame.size.width < self.collectionViewContentSize.width) {
            CGRect frame = currentLayoutAttributes.frame;
            frame.origin.x = origin + maximumSpacing;
            currentLayoutAttributes.frame = frame;
        }
    }
    
    return attributes;
}

@end

@interface LKCameraRollViewController () <UICollectionViewDataSource,UICollectionViewDelegate>

LC_PROPERTY(strong) ALAssetsLibrary * assetLibrary;
LC_PROPERTY(strong) NSMutableArray * datasource;
LC_PROPERTY(strong) UICollectionView * collectionView;

@end

@implementation LKCameraRollViewController

-(void) dealloc
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:YES];
    [self unobserveAllNotifications];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setNavigationBarHidden:NO animated:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
}


-(instancetype) init
{
    if (self = [super init]) {
        
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        
        [self observeNotification:LKCameraRollViewControllerDismiss];
    }
    
    return self;
}

-(void) handleNotification:(NSNotification *)notification
{
    if ([notification is:LKCameraRollViewControllerDismiss]) {
        
        [self.navigationController popToRootViewControllerAnimated:NO];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    

    self.assetLibrary = [[ALAssetsLibrary alloc] init];
    self.datasource = [NSMutableArray array];
    
    
    [self getCameraRolls];
    
    
    self.title = LC_LO(@"相机相册");
    
    [self setNavigationBarButton:LCUINavigationBarButtonTypeLeft title:LC_LO(@"取消") titleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.8]];
    [self setNavigationBarButton:LCUINavigationBarButtonTypeRight title:LC_LO(@"相册") titleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.8]];
    
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:LKColor.color andSize:CGSizeMake(LC_DEVICE_WIDTH, 64)] forBarMetrics:UIBarMetricsDefault];

    
    __LKUICollectionViewLayout * layout = [[__LKUICollectionViewLayout alloc] init];
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, LC_DEVICE_WIDTH, LC_DEVICE_HEIGHT + 20 - 64) collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.view.ADD(self.collectionView);
    
    [self.collectionView registerClass:[LKCameraRollCell class] forCellWithReuseIdentifier:@"Camera"];
    [self.collectionView registerClass:[LKPhotoRollCell class]  forCellWithReuseIdentifier:@"Photo"];

}

-(void) handleNavigationBarButton:(LCUINavigationBarButtonType)type
{
    if (type == LCUINavigationBarButtonTypeLeft) {
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else{
        
        [self photos];
    }
}

-(void) getCameraRolls
{
    @weakly(self);
    
    ALAssetsLibraryAccessFailureBlock failureblock = ^(NSError * error){
        
        if (error) {
            
            [self showTopMessageErrorHud:LC_LO(@"无法访问相册，可能是因为您拒绝了相册的访问权限")];
        }
    };
    
    ALAssetsGroupEnumerationResultsBlock groupEnumerAtion = ^(ALAsset *result,NSUInteger index, BOOL *stop){
        
        @normally(self);
        
        if (result != NULL) {
            
            if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                
                [self.datasource insertObject:result.defaultRepresentation.url atIndex:0];
            }
        }
    };
    
    ALAssetsLibraryGroupsEnumerationResultsBlock libraryGroupsEnumeration = ^(ALAssetsGroup * group, BOOL* stop){
        
        @normally(self);

        if (group != nil) {
            
            [group enumerateAssetsUsingBlock:groupEnumerAtion];

            [self.collectionView reloadData];
        }
    };
    
    
    
    
    [self.assetLibrary enumerateGroupsWithTypes:ALAssetsGroupAll
                           usingBlock:libraryGroupsEnumeration
                         failureBlock:failureblock];
    
}

-(void) photos
{
    LKUIImagePickerViewController * picker = [[LKUIImagePickerViewController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.allowsEditing = NO;
    picker.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    picker.navigationBar.tintColor = [UIColor whiteColor];
    
    [picker.navigationBar setBackgroundImage:[UIImage imageWithColor:[LKColor.color colorWithAlphaComponent:1] andSize:LC_SIZE(LC_DEVICE_WIDTH, 64)] forBarMetrics:UIBarMetricsDefault];
    
    NSMutableDictionary * dictText = [NSMutableDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,LK_FONT_B(18),NSFontAttributeName,nil];
    [picker.navigationBar setTitleTextAttributes:dictText];
    
    [self presentViewController:picker animated:YES completion:nil];
    
    
    picker.finalizationBlock = ^(id _picker, NSDictionary * imageInfo){
        
        LKImageCropperViewController * cropper = [[LKImageCropperViewController alloc] initWithImage:imageInfo[@"UIImagePickerControllerOriginalImage"]];
        
        [cropper showBackButton];
        
        [_picker pushViewController:cropper animated:YES];
        
    };
    
    picker.cancellationBlock = ^(UIImagePickerController * _picker){
        
        [_picker dismissViewControllerAnimated:YES completion:nil];
        
    };
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.datasource.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        
        LKCameraRollCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Camera" forIndexPath:indexPath];
        
        return cell;
        
    }else {
        
        LKPhotoRollCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Photo" forIndexPath:indexPath];
        
        NSURL * url = self.datasource[indexPath.row - 1];

        [self.assetLibrary assetForURL:url resultBlock:^(ALAsset *asset){
            
            cell.image = [UIImage imageWithCGImage:asset.thumbnail];
            
        }failureBlock:^(NSError * error) {
            
        }];
        
        return cell;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = (LC_DEVICE_WIDTH - 5.) / 4.;
    
    return CGSizeMake(width, width);
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(2.5, 2.5, 0, 0);
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPat
{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        
        [self.navigationController pushViewController:[LKCameraViewController viewController] animated:YES];
    }
    else{
        
        NSURL * url = self.datasource[indexPath.row - 1];
        
        [self.assetLibrary assetForURL:url resultBlock:^(ALAsset *asset){
            
            UIImage * image = [[UIImage alloc] initWithCGImage:asset.defaultRepresentation.fullResolutionImage scale:asset.defaultRepresentation.scale orientation:(UIImageOrientation)asset.defaultRepresentation.orientation];
            
            [self selectedImage:image];
            
        }failureBlock:^(NSError * error) {
            
        }];
    }
}

-(void) selectedImage:(UIImage *)image
{
    LKImageCropperViewController * cropper = [[LKImageCropperViewController alloc] initWithImage:image];
    
    [cropper showBackButton];
    
    [self.navigationController pushViewController:cropper animated:YES];

}

@end