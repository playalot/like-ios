//
//  LKNewPostViewController.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/18.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKNewPostViewController.h"
#import "LKFileUploader.h"
#import "LKInputView.h"
#import "LKRecommendTagsView.h"
#import "LKPost.h"
#import "LKCameraViewController.h"
#import "LKNewPostUploadCenter.h"
#import "LKCameraRollViewController.h"
#import "LKLocationManager.h"
#import "JTSImageViewController.h"
#import "LKTime.h"
#import "LCObserver.h"
#import "LKSearchPlacesViewController.h"

@interface LKNewPostViewController ()

LC_PROPERTY(strong) LCUIImageView * preview;
LC_PROPERTY(strong) UIImage * image;

LC_PROPERTY(strong) LKRecommendTagsView * selectedTags;
LC_PROPERTY(strong) LCUILabel * recommendLabel;
LC_PROPERTY(strong) LKRecommendTagsView * recommendTags;

LC_PROPERTY(strong) LKInputView * inputView;

LC_PROPERTY(strong) LCObserver * frameObserver;
LC_PROPERTY(strong) LCUIButton * locationButton;

LC_PROPERTY(strong) CLLocation * location;
LC_PROPERTY(strong) NSString * locationName;

@property (nonatomic, strong) NSMutableArray *suggests;


@end

@implementation LKNewPostViewController

- (void)dealloc {
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setNavigationBarHidden:NO animated:animated];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.inputView resignFirstResponder];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(instancetype) initWithImage:(UIImage *)image
{
    if (self = [super init]) {
        
        self.image = image;
        
        [LKLocationManager new];
    }
    
    return self;
}

-(void) viewDidLoad
{
    [super viewDidLoad];
}

-(void) buildUI
{
    // 格式化当前日期
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = kCFDateFormatterMediumStyle;
    
    self.title = [formatter stringFromDate:[NSDate date]];
    
    
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.tableView.bounces = NO;
    [self.tableView addTapGestureRecognizer:self selector:@selector(dismissKeyboard)];
    
    
    [self setNavigationBarButton:LCUINavigationBarButtonTypeLeft image:[UIImage imageNamed:@"NavigationBarBack.png" useCache:YES] selectImage:nil];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:LKColor.color andSize:CGSizeMake(LC_DEVICE_WIDTH, 64)] forBarMetrics:UIBarMetricsDefault];
    
    
    // 图片预览
    self.preview = LCUIImageView.view;
    self.preview.contentMode = UIViewContentModeScaleAspectFill;
    self.preview.viewFrameWidth = 100;
    self.preview.viewFrameHeight = 100;
    self.preview.viewFrameX = LC_DEVICE_WIDTH - self.preview.viewFrameWidth - 10;
    self.preview.viewFrameY = 10;
    self.preview.clipsToBounds = YES;
    self.preview.image = self.image;
    self.preview.userInteractionEnabled = YES;
    [self.preview addTapGestureRecognizer:self selector:@selector(previewTapAction)];
    self.view.ADD(self.preview);
    
    
    [self setNavigationBarButton:LCUINavigationBarButtonTypeRight title:LC_LO(@"发布") titleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.8]];
    
    
    // 顶部提示label
    self.recommendLabel = LCUILabel.view;
    self.recommendLabel.viewFrameX = 10;
    self.recommendLabel.viewFrameY = 10;
    self.recommendLabel.viewFrameWidth = LC_DEVICE_WIDTH - self.recommendLabel.viewFrameX * 2 - 120;
    self.recommendLabel.viewFrameHeight = 15;
    self.recommendLabel.text = LC_LO(@"添加相应标签，只晒给懂你的人");
    self.recommendLabel.font = LK_FONT(13);
    self.recommendLabel.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    self.recommendLabel.contentMode = UIViewContentModeBottom;
    self.recommendLabel.adjustsFontSizeToFitWidth = YES;
    [self.recommendLabel addTapGestureRecognizer:self selector:@selector(becomeFirstResponserAction)];
    self.view.ADD(self.recommendLabel);
    
    
    // 标签所在的view
    UIView * becomeFirstResponser = UIView.view;
    becomeFirstResponser.viewFrameX = 10;
    becomeFirstResponser.viewFrameY = self.recommendLabel.viewBottomY;
    becomeFirstResponser.viewFrameWidth = self.recommendLabel.viewFrameWidth;
    becomeFirstResponser.viewFrameHeight = 120;
    [becomeFirstResponser addTapGestureRecognizer:self selector:@selector(becomeFirstResponserAction)];
    self.view.ADD(becomeFirstResponser);
    
    
    // 选择列表
    self.selectedTags = LKRecommendTagsView.view;
    self.selectedTags.viewFrameY = self.recommendLabel.viewBottomY;
    self.selectedTags.viewFrameWidth = LC_DEVICE_WIDTH - 20 - self.preview.viewFrameWidth;
    self.selectedTags.highlight = YES;
    self.selectedTags.tapRemove = YES;
    self.view.ADD(self.selectedTags);
    
    // 推荐列表
    self.recommendTags = LKRecommendTagsView.view;
    self.recommendTags.viewFrameY = self.selectedTags.viewBottomY;
    self.recommendTags.viewFrameWidth = LC_DEVICE_WIDTH;
    self.recommendTags.highlight = NO;
    self.view.ADD(self.recommendTags);

    
    @weakly(self);
    
    self.selectedTags.itemDidTap = ^(LKRecommendTagItem * item, NSInteger type){
      
        @normally(self);
        
        [self.recommendTags.tags addObjectsFromArray:self.suggests.copy];
        
        [self.recommendTags reloadData:YES];
        
        [self updateSubviewsLayout];
    };
    
    UIView * line = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TalkLine.png" useCache:YES]];
    line.viewFrameWidth = LC_DEVICE_WIDTH;
    line.tag = 100;
    self.recommendTags.ADD(line);
    
    
    // 加载推荐数据
    [self.recommendTags loadRecommendTags];
    
    
    // 点击之后把item加到selectedTags上 然后重新布局
    self.recommendTags.itemDidTap = ^(LKRecommendTagItem * item, NSInteger type){
      
        @normally(self);
        
        if ([self checkOnSelectedTags:item.tagValue.tag]) {
            
            [self showTopMessageErrorHud:LC_LO(@"该标签已经存在")];
        }
        else{
            
            if (type == 1) {
                
                // 点击的是预置标签
                [UIView animateWithDuration:0.25 animations:^{
                    
                    self.recommendTags.alpha = 0;
                    
                } completion:^(BOOL finished) {
                    
                    NSMutableArray * tags = [self.recommendTags.tags mutableCopy];
                    
                    for (NSInteger i = 0; i < self.recommendTags.tags.count; i++) {
                        
                        __LKTagS * tag = self.recommendTags.tags[i];
                        
                        if (tag.type == 1) {
                            
                            if (self.suggests.count < 16) {
                                
                                [self.suggests addObject:tag];
                            }
                            
                            [tags removeObject:tag];
                            
                        }
                    }
                    
                    self.recommendTags.tags = tags;
                    [self.recommendTags reloadData:YES];
                    
                    [UIView animateWithDuration:0.25 animations:^{
                       
                        self.recommendTags.alpha = 1;
                        
                    }];
                    
                }];
            }
            
            [self addNewTag:item.tagLabel.text];
        }
    };
    
    self.recommendTags.itemDidLoad = ^(){
        
        @normally(self);
        
        [self updateSubviewsLayout];
    };
    
    
    [self updateSubviewsLayout];

    
    self.inputView = LKInputView.view;
    self.inputView.viewFrameY = self.view.viewFrameHeight - 64 - self.inputView.viewFrameHeight;
    self.inputView.dismissButton.image = nil;
    self.inputView.dismissButton.buttonImage = nil;
    self.inputView.dismissButton.title = LC_LO(@"添加");
    self.inputView.dismissButton.titleFont = LK_FONT(13);
    self.inputView.dismissButton.titleColor = LC_RGBA(0, 0, 0, 0.5);
    self.view.ADD(self.inputView);
    
    self.inputView.sendAction = ^(NSString * string){
        
        @normally(self);
        
        if ([self checkOnSelectedTags:string]) {
            
            [self showTopMessageErrorHud:LC_LO(@"该标签已经存在")];
        }
        else{
            
            if([self addNewTag:string]){
                
                self.inputView.textField.text = @"";
            }
        }
    };
    
    self.inputView.willDismiss = ^(NSString * string){
        
    };
    
    
    UIView * locationBackground = UIView.view;
    locationBackground.backgroundColor = [UIColor whiteColor];
    locationBackground.viewFrameY = self.inputView.viewFrameY - 53;
    locationBackground.viewFrameWidth = LC_DEVICE_WIDTH;
    locationBackground.viewFrameHeight = 53;
    self.view.ADD(locationBackground);
    
    
    self.locationButton = LCUIButton.view;
    self.locationButton.viewFrameX = 10;
    self.locationButton.viewFrameY = 10;
    self.locationButton.viewFrameWidth = LC_DEVICE_WIDTH / 2 - 10;
    self.locationButton.viewFrameHeight = 33;
    self.locationButton.backgroundColor = LKColor.backgroundColor;
    self.locationButton.cornerRadius = 4;
    self.locationButton.titleFont = LK_FONT(13);
    self.locationButton.titleColor = LC_RGB(153, 153, 153);
    self.locationButton.title = LC_LO(@"我的位置...");
    self.locationButton.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 5);
    self.locationButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    [self.locationButton addTarget:self action:@selector(choosePlaces) forControlEvents:UIControlEventTouchUpInside];
    locationBackground.ADD(self.locationButton);
    
    
    self.frameObserver = [LCObserver observerForObject:self.inputView keyPath:@"frame" block:^{
       
        @normally(self);
        
        LC_FAST_ANIMATIONS(0.15, ^{
            
            locationBackground.viewFrameY = self.inputView.viewFrameY - 53;
        });
    }];
}

#pragma mark -

-(void) setLocation:(CLLocation *)location andName:(NSString *)name
{
    self.locationButton.title = name;
    self.location = location;
    self.locationName = name;
}

-(void) removeLocation
{
    self.locationButton.title = LC_LO(@"我的位置...");
    self.location = nil;
    self.locationName = nil;
}

#pragma mark -

-(void) becomeFirstResponserAction
{
    if (self.inputView.isFirstResponder) {
        
        [self.inputView resignFirstResponder];
    }
    else{
        
        [self.inputView becomeFirstResponder];
    }
}

-(void) handleNavigationBarButton:(LCUINavigationBarButtonType)type
{
    if (type == LCUINavigationBarButtonTypeLeft) {
        
        [self pop];
    }
    else{
        
        [self finishIt];
    }
}

-(void) updateSubviewsLayout
{
    LC_FAST_ANIMATIONS(0.15, ^{
    
        CGFloat y = self.selectedTags.viewBottomY + 15;
        
        self.recommendTags.viewFrameY = y < self.preview.viewBottomY + 15 ? self.preview.viewBottomY + 15 : y;
    });
}


-(BOOL) addNewTag:(NSString *)tagString
{
    if (tagString.trim.length == 0) {
        
        [self showTopMessageErrorHud:LC_LO(@"标签不能为空")];
        return NO;
    }
    
    if (tagString.length > 12) {
        
        [self showTopMessageErrorHud:LC_LO(@"标签长度不能大于12位")];
        return NO;
    }
    
    __LKTagS * tag = [[__LKTagS alloc] init];
    tag.tag = tagString;
    
    [self.selectedTags.tags addObject:tag];
    
    
    if (self.selectedTags.tags.count == 1) {
        
        LC_FAST_ANIMATIONS(0.25, ^{
            
            [self.selectedTags reloadData:NO];
        });
    }
    else{
        
        [self.selectedTags reloadData:NO];
    }

    [self updateSubviewsLayout];
    
    [self.inputView resignFirstResponder];
    
    return YES;
}

-(BOOL) checkOnSelectedTags:(NSString *)tag
{
    for (LKTag * oTag in self.selectedTags.tags) {
        
        if ([oTag.tag isEqualToString:tag]) {
            
            return YES;
        }
    }
    
    return NO;
}

-(void) finishIt
{
    NSMutableArray * location = [NSMutableArray array];
    
    if (self.location) {
        [location addObject:[NSNumber numberWithDouble:self.location.coordinate.latitude]];
        [location addObject:[NSNumber numberWithDouble:self.location.coordinate.longitude]];
    }
    
    [LKNewPostUploadCenter uploadImage:self.image tags:self.selectedTags.tags location:location place:self.locationName];
    
    [self dismissAction];
}

/**
 *  点击预览图片执行
 */
-(void) previewTapAction
{
    [self.inputView resignFirstResponder];
    
    
    JTSImageInfo * info = [[JTSImageInfo alloc] init];
    info.image = self.image;
    info.referenceRect = self.preview.frame;
    info.referenceView = self.preview.superview;
    info.fromView = self.preview;
    

    JTSImageViewController *imageViewer = [[JTSImageViewController alloc] initWithImageInfo:info
                                                                                       mode:JTSImageViewControllerMode_Image
                                                                            backgroundStyle:JTSImageViewControllerBackgroundOption_Blurred];
    
    [imageViewer showFromViewController:self transition:JTSImageViewControllerTransition_FromOriginalPosition];
}

-(void) pop
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) dismissAction
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [self postNotification:LKCameraViewControllerDismiss];
    [self postNotification:LKCameraRollViewControllerDismiss];
    
}

-(void) dismissKeyboard
{
    [self.inputView resignFirstResponder];
}

-(void) choosePlaces
{
    @weakly(self);

    if (self.location) {
        
        [LKActionSheet showWithTitle:nil buttonTitles:@[LC_LO(@"更改位置") ,LC_LO(@"移除位置")] didSelected:^(NSInteger index) {
         
            @normally(self);

            if (index == 0) {
                
                LKSearchPlacesViewController * search = [LKSearchPlacesViewController viewController];
                
                search.didSelected = ^(NSString * name, CLLocation * location){
                    
                    @normally(self);
                    
                    [self setLocation:location andName:name];
                };
                
                [self presentViewController:LC_UINAVIGATION(search) animated:YES completion:nil];
            }
            else if (index == 1){
                
                [self removeLocation];
            }
        }];
    }
    else{
        
        LKSearchPlacesViewController * search = [LKSearchPlacesViewController viewController];
        
        search.didSelected = ^(NSString * name, CLLocation * location){
            
            @normally(self);
            
            [self setLocation:location andName:name];
        };
        
        [self presentViewController:LC_UINAVIGATION(search) animated:YES completion:nil];
    }
}

#pragma mark - ***** 懒加载 *****
- (NSMutableArray *)suggests {
    
    if (_suggests == nil) {
        _suggests = [NSMutableArray array];
    }
    return _suggests;
}

@end
