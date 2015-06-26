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
#import "LKHomeViewController.h"
#import "LKCameraViewController.h"
#import "LKNewPostUploadCenter.h"
#import "LKCameraRollViewController.h"

@interface LKNewPostViewController ()

LC_PROPERTY(strong) LCUIImageView * preview;
LC_PROPERTY(strong) UIImage * image;

LC_PROPERTY(strong) UIScrollView * scrollView;

LC_PROPERTY(strong) LKRecommendTagsView * selectedTags;
LC_PROPERTY(strong) LCUILabel * recommendLabel;
LC_PROPERTY(strong) LKRecommendTagsView * recommendTags;

LC_PROPERTY(strong) LKInputView * inputView;

@end

@implementation LKNewPostViewController

-(void) dealloc
{
    
}

-(instancetype) initWithImage:(UIImage *)image
{
    if (self = [super init]) {
        
        self.image = image;
    }
    
    return self;
}

-(void) viewDidLoad
{
    [super viewDidLoad];
}

-(void) buildUI
{
    self.view.backgroundColor = LKColor.whiteColor;
    
    
    self.preview = LCUIImageView.view;
    self.preview.contentMode = UIViewContentModeScaleAspectFill;
    self.preview.viewFrameWidth = LC_DEVICE_WIDTH;
    self.preview.viewFrameHeight = LC_DEVICE_WIDTH * (3. / 4.);
    self.preview.clipsToBounds = YES;
    self.preview.image = self.image;
    self.preview.userInteractionEnabled = YES;
    [self.preview addTapGestureRecognizer:self selector:@selector(previewTapAction)];
    self.view.ADD(self.preview);
    
    
    LCUIButton * dismissButton = LCUIButton.view;
    dismissButton.viewFrameWidth = 37 / 3 + 40;
    dismissButton.viewFrameHeight = 61 / 3 + 40;
    dismissButton.buttonImage = [UIImage imageNamed:@"NavigationBarBackShadow.png" useCache:YES];
    dismissButton.showsTouchWhenHighlighted = YES;
    [dismissButton addTarget:self action:@selector(pop) forControlEvents:UIControlEventTouchUpInside];
    self.view.ADD(dismissButton);
    
    
    LCUIButton * finishButton = LCUIButton.view;
    finishButton.viewFrameWidth = 75 / 3 + 40;
    finishButton.viewFrameHeight = 52 / 3 + 40;
    finishButton.viewFrameX = LC_DEVICE_WIDTH - finishButton.viewFrameWidth;
    finishButton.buttonImage = [UIImage imageNamed:@"PostDidFinish.png" useCache:YES];
    finishButton.showsTouchWhenHighlighted = YES;
    [finishButton addTarget:self action:@selector(finishIt) forControlEvents:UIControlEventTouchUpInside];
    self.view.ADD(finishButton);
    
    
    self.scrollView = UIScrollView.view;
    self.scrollView.viewFrameY = self.preview.viewBottomY;
    self.scrollView.viewFrameWidth = self.view.viewFrameWidth;
    self.scrollView.viewFrameHeight = self.view.viewFrameHeight - self.scrollView.viewFrameY - 44;
    self.scrollView.contentSize = LC_SIZE(self.view.viewFrameWidth, self.scrollView.viewFrameHeight * 2);
    self.view.ADD(self.scrollView);
    
    
    // 选择列表
    self.selectedTags = LKRecommendTagsView.view;
    self.selectedTags.viewFrameWidth = LC_DEVICE_WIDTH;
    self.selectedTags.backgroundColor = LKColor.backgroundColor;
    self.selectedTags.highlight = YES;
    self.scrollView.ADD(self.selectedTags);
    
    @weakly(self);
    
    self.selectedTags.itemDidTap = ^(LKRecommendTagItem * item){
      
        @normally(self);
        
        [self updateScrollSubviewsLayout];
    };
    
    
    self.recommendLabel = LCUILabel.view;
    self.recommendLabel.viewFrameX = 10;
    self.recommendLabel.viewFrameY = self.selectedTags.viewBottomY;
    self.recommendLabel.viewFrameWidth = LC_DEVICE_WIDTH - self.recommendLabel.viewFrameX * 2;
    self.recommendLabel.viewFrameHeight = 15;
    self.recommendLabel.text = LC_LO(@"点击添加标签，让更多同类发现你");
    self.recommendLabel.font = LK_FONT(13);
    self.recommendLabel.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    self.recommendLabel.contentMode = UIViewContentModeBottom;
    self.scrollView.ADD(self.recommendLabel);
    
    
    // 推荐列表
    self.recommendTags = LKRecommendTagsView.view;
    self.recommendTags.viewFrameY = self.selectedTags.viewBottomY;
    self.recommendTags.viewFrameWidth = LC_DEVICE_WIDTH;
    self.recommendTags.highlight = NO;
    self.scrollView.ADD(self.recommendTags);
    
    
    // 加载推荐数据
    [self.recommendTags loadRecommendTags];
    
    
    // 点击之后把item加到selectedTags上 然后重新布局
    self.recommendTags.itemDidTap = ^(LKRecommendTagItem * item){
      
        @normally(self);
        
        [self addNewTag:item.tagLabel.text];
    };
    
    self.recommendTags.itemDidLoad = ^(){
        
        @normally(self);
        
        [self updateScrollSubviewsLayout];
    };
    
    
    [self updateScrollSubviewsLayout];

    
    self.inputView = LKInputView.view;
    self.inputView.viewFrameY = self.view.viewFrameHeight - self.inputView.viewFrameHeight;
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
            
            [self addNewTag:string];
            
            self.inputView.textField.text = @"";
        }
        
        
    };
    
    self.inputView.willDismiss = ^(NSString * string){
        
    };
}

-(void) updateScrollSubviewsLayout
{
    LC_FAST_ANIMATIONS(0.25, ^{
    
        self.recommendLabel.viewFrameY = self.selectedTags.viewBottomY + 10;
        self.recommendTags.viewFrameY = self.recommendLabel.viewBottomY;
        self.scrollView.contentSize = LC_SIZE(LC_DEVICE_WIDTH, self.recommendTags.viewBottomY);

    });
}


-(void) addNewTag:(NSString *)tagString
{
    if (tagString.trim.length == 0) {
        
        [self showTopMessageErrorHud:LC_LO(@"标签不能为空")];
        return;
    }
    
    if (tagString.length > 12) {
        
        [self showTopMessageErrorHud:LC_LO(@"标签长度不能大于12位")];
        return;
    }
    
    LKTag * tag = [[LKTag alloc] init];
    tag.tag = tagString;
    
    [self.selectedTags.tags addObject:tag];
    
    
    if (self.selectedTags.tags.count == 1) {
        
        LC_FAST_ANIMATIONS(0.25, ^{
            
            [self.selectedTags reloadData];
        });
    }
    else{
        
        [self.selectedTags reloadData];
    }

    
    
    [self updateScrollSubviewsLayout];
    
    
    [self.inputView resignFirstResponder];
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
    [LKNewPostUploadCenter uploadImage:self.image tags:self.selectedTags.tags];
    
    [self dismissAction];
}

-(void) previewTapAction
{
    [self.inputView resignFirstResponder];
}

-(void) pop
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) dismissAction
{
    [self dismissViewControllerAnimated:NO completion:nil];

    [self postNotification:LKCameraViewControllerDismiss];
    [self postNotification:LKCameraRollViewControllerDismiss];
}

@end
