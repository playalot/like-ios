//
//  LKLoginViewController.m
//  LIKE
//
//  Created by Leer on 15/4/10.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKLoginViewController.h"
#import "LKUserInfoModel.h"
#import "LKWelcome.h"
#import "LKCountryCodeViewController.h"
#import "LKSinaShare.h"
#import "LKWeChatShare.h"
#import "LKFacebookShare.h"
#import "LKTimestampEncryption.h"
#import "LKISOCountryCodes.h"
#import "WXApi.h"
#import "WeiboSDK.h"
#import <SMS_SDK/SMS_SDK.h>
#import <SMS_SDK/CountryAndAreaCode.h>
#import "LKChooseTagView.h"

typedef NS_ENUM(NSInteger, LKOtherLoginType)
{
    LKOtherLoginTypeWechat = 0,     // 微信登录
    LKOtherLoginTypeWeibo,           // 微博登录
    LKOtherLoginTypeQQ,             // QQ登录
    LKOtherLoginTypeFacebook,       // Facebook登录
};

@interface LKLoginViewController ()
/**
 *  时间戳
 */
LC_PROPERTY(assign) NSInteger timeInterval;

/**
 *  国家代号
 */
LC_PROPERTY(strong) LCUILabel * countryCode;
/**
 *  国家名称
 */
LC_PROPERTY(strong) LCUILabel * countryName;
/**
 *  电话号码输入框
 */
LC_PROPERTY(strong) LCUITextField * phoneField;
/**
 *  验证码输入框
 */
LC_PROPERTY(strong) LCUITextField * codeField;
/**
 *  获取验证码按钮
 */
LC_PROPERTY(strong) LCUIButton * codeButton;
/**
 *  登录按钮
 */
LC_PROPERTY(strong) LCUIButton * loginButton;
/**
 *  遮罩层
 */
LC_PROPERTY(strong) LCUIButton * maskView;

LC_PROPERTY(strong) NSString * sesstionToken;
LC_PROPERTY(strong) NSString * refreshToken;
/**
 *  过期日期
 */
LC_PROPERTY(strong) NSNumber * expiresIn;
/**
 *  用户信息模型
 */
LC_PROPERTY_MODEL(LKUserInfoModel, userInfoModel);
/**
 *  背景图
 */
LC_PROPERTY(strong) LCUIImageView * backgroundView;

@end

@implementation LKLoginViewController

-(void) dealloc
{
    [self cancelAllRequests];
}

+(BOOL) needLoginOnViewController:(UIViewController *)viewController
{
    if (LKLocalUser.singleton.isLogin) {
        return NO;
    }
    else{
        
        LKLoginViewController * login = LKLoginViewController.viewController;
        
        for (UIView * view in login.view.subviews) {

            if (view != login.backgroundView) {

                view.alpha = 0;
            }
        }

        [login performSelector:@selector(beginAnimation) withObject:0 afterDelay:0.01];
        
        // 弹出时的动画风格为交叉溶解风格
        login.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        // 背景虚化
        [login currentWindowBlur:viewController];
        
        [[LCUIApplication sharedInstance] presentViewController:login animation:YES];
        
        return YES;
    }
}

-(instancetype) init
{
    if (self = [super init]) {
        
        // 弹出时的动画风格为交叉溶解风格
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    }
    
    return self;
}

-(void) currentWindowBlur:(UIViewController *)viewController
{
    if (!viewController) {
        return;
    }
    
    UIImage * image = [[self snapshotFromParentmostViewController:viewController] imageWithBlurValue:15];
    
    [self.backgroundView removeFromSuperview];
    
    self.backgroundView = [LCUIImageView viewWithImage:image];
    self.backgroundView.viewFrameWidth = LC_DEVICE_WIDTH;
    self.backgroundView.viewFrameHeight = (LC_DEVICE_HEIGHT + 20);
    self.backgroundView.center = self.view.center;
    [self.view insertSubview:self.backgroundView atIndex:0];
    
    
    UIView * mask = UIView.view.COLOR([[UIColor blackColor] colorWithAlphaComponent:0.35]);
    mask.frame = self.backgroundView.bounds;
    self.backgroundView.ADD(mask);
    
    
    
    self.backgroundView.alpha = 0;
    
    LC_FAST_ANIMATIONS(1, ^{
        
        self.backgroundView.alpha = 1;
        
    });
}


-(void) beginAnimation
{
    LC_FAST_ANIMATIONS(1, ^{
        
        for (UIView * view in self.view.subviews) {
            
            if (view != self.backgroundView) {
                
                view.alpha = 1;
            }
        }
        
    });
    
    //    [UIView animateWithDuration:1 delay:5 options:UIViewAnimationOptionCurveLinear animations:^{
    //
    //
    //
    //    } completion:^(BOOL finished) {
    //        ;
    //    }];
}


- (UIImage *)snapshotFromParentmostViewController:(UIViewController *)viewController
{
    UIViewController *presentingViewController = viewController.view.window.rootViewController;
    
    while (presentingViewController.presentedViewController) presentingViewController = presentingViewController.presentedViewController;
    
    UIGraphicsBeginImageContextWithOptions(LC_KEYWINDOW.bounds.size, YES, [UIScreen mainScreen].scale);
    [LC_KEYWINDOW drawViewHierarchyInRect:LC_KEYWINDOW.bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

-(void) viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    self.tableView.scrollEnabled = NO;
    self.userInfoModel = LKUserInfoModel.new.OBSERVER(self);
    
    @weakly(self);
    
    self.userInfoModel.requestFinished = ^(LKHttpRequestResult * result, NSString * error){
        
        @normally(self);
        
        if (error) {
            
            [self showTopMessageErrorHud:error];
        }
        else{
            
            self.maskView.hidden = YES;
            
            NSMutableDictionary * dic =  [self.userInfoModel.rawUserInfo mutableCopy];
            
            
            [LKLocalUser login:dic];
            LKLocalUser.singleton.sessionToken = self.sesstionToken;
            LKLocalUser.singleton.refreshToken = self.refreshToken;
            LKLocalUser.singleton.expiresIn = [NSString stringWithFormat:@"%@", self.expiresIn];
            
            
            // 如果是第一次登陆,选择兴趣标签
            BOOL firstStart = [[NSUserDefaults standardUserDefaults] boolForKey:@"firstStart"];
            
            // 判断是否是初次启动
            if (!firstStart) {
            
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstStart"];
                [[NSUserDefaults standardUserDefaults] synchronize];

                LKChooseTagView *chooseView = [LKChooseTagView chooseTagView];
                [UIApplication sharedApplication].keyWindow.ADD(chooseView);
            }
            
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    };
}

-(void) buildUI
{
    @weakly(self);
    
    self.tableView.didTap = ^(){
        
        @normally(self);
        
        [self.phoneField resignFirstResponder];
        [self.codeField resignFirstResponder];
    };
    
    // 背景视图
    self.backgroundView = [LCUIImageView viewWithImage:[[LKWelcome image] imageWithBlurValue:15]];
    self.backgroundView.viewFrameWidth = LC_DEVICE_WIDTH * 1.5;
    self.backgroundView.viewFrameHeight = (LC_DEVICE_HEIGHT + 20) * 1.5;
    self.backgroundView.center = self.view.center;
    self.view.ADD(self.backgroundView);
    
    // 遮罩层
    UIView * mask = UIView.view.COLOR([[UIColor blackColor] colorWithAlphaComponent:0.35]);
    mask.frame = self.backgroundView.bounds;
    self.backgroundView.ADD(mask);
    
    // like logo
    LCUIImageView * icon = [LCUIImageView viewWithImage:UIImage.IMAGE(@"LikeIcon.png")];
    icon.viewFrameX = self.view.viewMidWidth - icon.viewMidWidth;
    icon.viewFrameY = 50;
    self.view.ADD(icon);
    
    // country.
    UIView * countryBack = UIView.view.Y(icon.viewBottomY + 30).WIDTH(LC_DEVICE_WIDTH).HEIGHT(35).COLOR([[UIColor whiteColor] colorWithAlphaComponent:0.05]);
    [countryBack addTapGestureRecognizer:self selector:@selector(chooseCountryCode)];
    self.view.ADD(countryBack);
    
    // 实质上就是创建label设置frame并添加到view中
    self.countryCode = LCUILabel.view;
    self.countryCode.viewFrameWidth = 80;
    self.countryCode.viewFrameHeight = countryBack.viewFrameHeight;
    self.countryCode.font = LK_FONT(13);
    self.countryCode.textColor = [UIColor whiteColor];
    self.countryCode.textAlignment = UITextAlignmentCenter;
    countryBack.ADD(self.countryCode);
    
    // 添加国家名称
    self.countryName = LCUILabel.view;
    self.countryName.viewFrameX = self.countryCode.viewRightX + 30;
    self.countryName.viewFrameWidth = 200;
    self.countryName.viewFrameHeight = countryBack.viewFrameHeight;
    self.countryName.font = LK_FONT(13);
    self.countryName.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
    countryBack.ADD(self.countryName);
    
    // 更多国家
    LCUIImageView * countryMore = [LCUIImageView viewWithImage:[[[UIImage imageNamed:@"PullLoaderSmallArrow.png" useCache:YES] imageWithTintColor:LKColor.color] scaleToWidth:15]];
    countryMore.viewFrameY = countryBack.viewMidHeight - countryMore.viewMidHeight;
    countryMore.viewFrameX = LC_DEVICE_WIDTH - countryMore.viewFrameWidth - 15;
    countryBack.ADD(countryMore);
    
    
    // phone.
    UIView * phoneBack = UIView.view.Y(countryBack.viewBottomY + 1).WIDTH(LC_DEVICE_WIDTH).HEIGHT(40).COLOR([[UIColor whiteColor] colorWithAlphaComponent:0.05]);
    self.view.ADD(phoneBack);
    
    
    UIImageView * phoneIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PhoneIcon.png" useCache:YES]];
    phoneIcon.viewFrameX = 30;
    phoneIcon.viewFrameY = phoneBack.viewMidHeight - phoneIcon.viewMidHeight;
    phoneBack.ADD(phoneIcon);
    
    self.countryCode.viewCenterX = phoneIcon.viewCenterX;
    
    self.phoneField = LCUITextField.view;
    self.phoneField.viewFrameY = 0;
    self.phoneField.viewFrameX = phoneIcon.viewRightX + 30;
    self.phoneField.viewFrameWidth = LC_DEVICE_WIDTH - self.phoneField.viewFrameX - 30;
    self.phoneField.viewFrameHeight = 40;
    self.phoneField.font = LK_FONT(13);
    self.phoneField.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
    self.phoneField.placeholder = LC_LO(@"输入手机号码");
    self.phoneField.placeholderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
    self.phoneField.returnKeyType = UIReturnKeyNext;
    self.phoneField.keyboardType = UIKeyboardTypeNumberPad;
    self.phoneField.clearButtonMode = UITextFieldViewModeWhileEditing;
    phoneBack.ADD(self.phoneField);
    
    self.phoneField.shouldReturn = ^ BOOL (id value){
        
        @normally(self);
        
        [self.phoneField resignFirstResponder];
        return YES;
    };
    
    self.countryName.viewFrameX = self.phoneField.viewFrameX;
    
    // code.
    UIView * codeBack = UIView.view.Y(phoneBack.viewBottomY + 1).WIDTH(LC_DEVICE_WIDTH).HEIGHT(40).COLOR([[UIColor whiteColor] colorWithAlphaComponent:0.05]);
    self.view.ADD(codeBack);
    
    
    UIImageView * codeIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CodeIcon.png" useCache:YES]];
    codeIcon.viewFrameX = 30;
    codeIcon.viewFrameY = codeBack.viewMidHeight - codeIcon.viewMidHeight;
    codeBack.ADD(codeIcon);
    
    
    self.codeField = LCUITextField.view;
    self.codeField.viewFrameX = codeIcon.viewRightX + 30;
    self.codeField.viewFrameWidth = LC_DEVICE_WIDTH - self.codeField.viewFrameX - 100;
    self.codeField.viewFrameHeight = 40;
    self.codeField.font = LK_FONT(13);
    self.codeField.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
    self.codeField.placeholder = LC_LO(@"输入验证码");
    self.codeField.placeholderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
    self.codeField.returnKeyType = UIReturnKeyJoin;
    self.codeField.keyboardType = UIKeyboardTypeNumberPad;
    self.codeField.clearButtonMode = UITextFieldViewModeWhileEditing;
    codeBack.ADD(self.codeField);
    
    self.codeField.shouldReturn = ^ BOOL (id value){
        
        @normally(self);
        
        [self.codeField resignFirstResponder];
        [self getCode];
        return YES;
    };
    
    self.codeButton = LCUIButton.view;
    self.codeButton.viewFrameWidth = 100;
    self.codeButton.viewFrameHeight = 40;
    self.codeButton.viewFrameX = LC_DEVICE_WIDTH - self.codeButton.viewFrameWidth;
    self.codeButton.title = LC_LO(@"获取验证码");
    self.codeButton.titleColor = [UIColor whiteColor];
    self.codeButton.titleFont = LK_FONT(13);
    self.codeButton.showsTouchWhenHighlighted = YES;
    [self.codeButton addTarget:self action:@selector(getCode) forControlEvents:UIControlEventTouchUpInside];
    codeBack.ADD(self.codeButton);
    
    // login.
    self.loginButton = LCUIButton.view;
    self.loginButton.viewFrameWidth = 110;
    self.loginButton.viewFrameHeight = 30;
    self.loginButton.viewFrameY = codeBack.viewBottomY + 30;
    self.loginButton.viewCenterX = self.view.viewMidWidth;
    self.loginButton.cornerRadius = 30 / 2;
    self.loginButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.2];
    self.loginButton.title = LC_LO(@"进入like");
    self.loginButton.titleFont = LK_FONT(13);
    self.loginButton.titleColor = [UIColor whiteColor];
    self.loginButton.showsTouchWhenHighlighted = YES;
    [self.loginButton addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    self.view.ADD(self.loginButton);
    
    // 用户使用协议
    LCUILabel * agreement = LCUILabel.view;
    agreement.viewFrameY = self.loginButton.viewBottomY + 20;
    agreement.viewFrameWidth = self.view.viewFrameWidth;
    agreement.viewFrameHeight = 20;
    agreement.viewFrameX = LC_DEVICE_WIDTH / 2 - agreement.viewMidWidth;
    agreement.textAlignment = UITextAlignmentCenter;
    agreement.font = LK_FONT(10);
    agreement.text = LC_LO(@"用户使用协议");
    agreement.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    [agreement addTapGestureRecognizer:self selector:@selector(agreement)];
    self.view.ADD(agreement);
    
    // third login.
    LCUILabel * thirdLoginTip = LCUILabel.view;
    thirdLoginTip.font = LK_FONT(10);
    thirdLoginTip.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    thirdLoginTip.text = LC_LO(@"社交账号快速登录");
    thirdLoginTip.FIT();
    thirdLoginTip.viewCenterX = self.view.viewMidWidth;
    thirdLoginTip.viewCenterY = self.view.viewFrameHeight - 115;
    self.view.ADD(thirdLoginTip);
    
    // 第三方登录图片
    NSMutableArray * loginImages = [NSMutableArray array];
    
    if ([WXApi isWXAppInstalled]) {
        
        [loginImages addObject:@"WeChatLogin"];
    }
    
    if ([WeiboSDK isWeiboAppInstalled]) {
        
        [loginImages addObject:@"WeiboLogin"];
    }
    // 若安装了微博,默认会显示Facebook
    if ([WeiboSDK isWeiboAppInstalled]) {
        
        [loginImages addObject:@"FacebookLogin"];
    }
    
    CGFloat loginButtonX = (LC_DEVICE_WIDTH - (85 * loginImages.count)) / 2;
    
    for (NSInteger i = 0; i<loginImages.count; i++) {
        
        LCUIButton * loginButton = LCUIButton.view;
        loginButton.viewFrameWidth = 85;
        loginButton.viewFrameHeight = 35;
        loginButton.viewFrameX = loginButtonX + loginButton.viewFrameWidth * i;
        loginButton.viewFrameY = thirdLoginTip.viewBottomY + 20;
        loginButton.buttonImage = [[UIImage imageNamed:loginImages[i] useCache:YES] scaleToWidth:35];
        loginButton.showsTouchWhenHighlighted = YES;
        loginButton.tagString = loginImages[i];
        [loginButton addTarget:self action:@selector(otherLogin:) forControlEvents:UIControlEventTouchUpInside];
        self.view.ADD(loginButton);
        
    }
    
    // 游客访问
    LCUIButton * visitor = LCUIButton.view;
    visitor.viewFrameWidth = 100;
    visitor.viewCenterX = self.view.viewMidWidth - 15;
    visitor.viewFrameY = self.view.viewFrameHeight - 40;
    visitor.viewFrameHeight = 20;
    visitor.title = LC_LO(@"游客访问     ");
    visitor.titleFont = LK_FONT(10);
    visitor.titleColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    [visitor addTarget:self action:@selector(dismissAction) forControlEvents:UIControlEventTouchUpInside];
    visitor.buttonImage = [[[UIImage imageNamed:@"VisitorIcon.png" useCache:YES] scaleToWidth:13] imageWithTintColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5]];
    visitor.imageEdgeInsets = UIEdgeInsetsMake(0, 80, 0, 0);
    self.view.ADD(visitor);
    
    // 用button添加一个遮罩层
    self.maskView = LCUIButton.view;
    self.maskView.viewFrameWidth = LC_DEVICE_WIDTH;
    self.maskView.viewFrameHeight = LC_DEVICE_HEIGHT + 20;
    self.maskView.hidden = YES;
    self.view.ADD(self.maskView);
    
    // 设置本地化地区代码
    [self setTheLocalAreaCode];
}

/**
 *  选择国家代号
 */
-(void) chooseCountryCode
{
    LKCountryCodeViewController * countryCode = [LKCountryCodeViewController viewController];
    
    @weakly(self);
    
    countryCode.didSelectedRow = ^(NSString * countryCode){
        
        @normally(self);
        
        NSArray * subString = [countryCode componentsSeparatedByString:@"+"];
        
        self.countryName.text = subString[0];
        self.countryCode.text = [NSString stringWithFormat:@"+%@", subString[1]];
    };
    
    [self presentViewController:LC_UINAVIGATION(countryCode) animated:YES completion:nil];
}

/**
 *  设置本地化地区代码
 */
-(void)setTheLocalAreaCode
{
    NSLocale * locale = [NSLocale currentLocale];
    
    NSDictionary * dictCodes = [NSDictionary dictionaryWithObjectsAndKeys:@"972", @"IL",
                                @"93", @"AF", @"355", @"AL", @"213", @"DZ", @"1", @"AS",
                                @"376", @"AD", @"244", @"AO", @"1", @"AI", @"1", @"AG",
                                @"54", @"AR", @"374", @"AM", @"297", @"AW", @"61", @"AU",
                                @"43", @"AT", @"994", @"AZ", @"1", @"BS", @"973", @"BH",
                                @"880", @"BD", @"1", @"BB", @"375", @"BY", @"32", @"BE",
                                @"501", @"BZ", @"229", @"BJ", @"1", @"BM", @"975", @"BT",
                                @"387", @"BA", @"267", @"BW", @"55", @"BR", @"246", @"IO",
                                @"359", @"BG", @"226", @"BF", @"257", @"BI", @"855", @"KH",
                                @"237", @"CM", @"1", @"CA", @"238", @"CV", @"345", @"KY",
                                @"236", @"CF", @"235", @"TD", @"56", @"CL", @"86", @"CN",
                                @"61", @"CX", @"57", @"CO", @"269", @"KM", @"242", @"CG",
                                @"682", @"CK", @"506", @"CR", @"385", @"HR", @"53", @"CU",
                                @"537", @"CY", @"420", @"CZ", @"45", @"DK", @"253", @"DJ",
                                @"1", @"DM", @"1", @"DO", @"593", @"EC", @"20", @"EG",
                                @"503", @"SV", @"240", @"GQ", @"291", @"ER", @"372", @"EE",
                                @"251", @"ET", @"298", @"FO", @"679", @"FJ", @"358", @"FI",
                                @"33", @"FR", @"594", @"GF", @"689", @"PF", @"241", @"GA",
                                @"220", @"GM", @"995", @"GE", @"49", @"DE", @"233", @"GH",
                                @"350", @"GI", @"30", @"GR", @"299", @"GL", @"1", @"GD",
                                @"590", @"GP", @"1", @"GU", @"502", @"GT", @"224", @"GN",
                                @"245", @"GW", @"595", @"GY", @"509", @"HT", @"504", @"HN",
                                @"36", @"HU", @"354", @"IS", @"91", @"IN", @"62", @"ID",
                                @"964", @"IQ", @"353", @"IE", @"972", @"IL", @"39", @"IT",
                                @"1", @"JM", @"81", @"JP", @"962", @"JO", @"77", @"KZ",
                                @"254", @"KE", @"686", @"KI", @"965", @"KW", @"996", @"KG",
                                @"371", @"LV", @"961", @"LB", @"266", @"LS", @"231", @"LR",
                                @"423", @"LI", @"370", @"LT", @"352", @"LU", @"261", @"MG",
                                @"265", @"MW", @"60", @"MY", @"960", @"MV", @"223", @"ML",
                                @"356", @"MT", @"692", @"MH", @"596", @"MQ", @"222", @"MR",
                                @"230", @"MU", @"262", @"YT", @"52", @"MX", @"377", @"MC",
                                @"976", @"MN", @"382", @"ME", @"1", @"MS", @"212", @"MA",
                                @"95", @"MM", @"264", @"NA", @"674", @"NR", @"977", @"NP",
                                @"31", @"NL", @"599", @"AN", @"687", @"NC", @"64", @"NZ",
                                @"505", @"NI", @"227", @"NE", @"234", @"NG", @"683", @"NU",
                                @"672", @"NF", @"1", @"MP", @"47", @"NO", @"968", @"OM",
                                @"92", @"PK", @"680", @"PW", @"507", @"PA", @"675", @"PG",
                                @"595", @"PY", @"51", @"PE", @"63", @"PH", @"48", @"PL",
                                @"351", @"PT", @"1", @"PR", @"974", @"QA", @"40", @"RO",
                                @"250", @"RW", @"685", @"WS", @"378", @"SM", @"966", @"SA",
                                @"221", @"SN", @"381", @"RS", @"248", @"SC", @"232", @"SL",
                                @"65", @"SG", @"421", @"SK", @"386", @"SI", @"677", @"SB",
                                @"27", @"ZA", @"500", @"GS", @"34", @"ES", @"94", @"LK",
                                @"249", @"SD", @"597", @"SR", @"268", @"SZ", @"46", @"SE",
                                @"41", @"CH", @"992", @"TJ", @"66", @"TH", @"228", @"TG",
                                @"690", @"TK", @"676", @"TO", @"1", @"TT", @"216", @"TN",
                                @"90", @"TR", @"993", @"TM", @"1", @"TC", @"688", @"TV",
                                @"256", @"UG", @"380", @"UA", @"971", @"AE", @"44", @"GB",
                                @"1", @"US", @"598", @"UY", @"998", @"UZ", @"678", @"VU",
                                @"681", @"WF", @"967", @"YE", @"260", @"ZM", @"263", @"ZW",
                                @"591", @"BO", @"673", @"BN", @"61", @"CC", @"243", @"CD",
                                @"225", @"CI", @"500", @"FK", @"44", @"GG", @"379", @"VA",
                                @"852", @"HK", @"98", @"IR", @"44", @"IM", @"44", @"JE",
                                @"850", @"KP", @"82", @"KR", @"856", @"LA", @"218", @"LY",
                                @"853", @"MO", @"389", @"MK", @"691", @"FM", @"373", @"MD",
                                @"258", @"MZ", @"970", @"PS", @"872", @"PN", @"262", @"RE",
                                @"7", @"RU", @"590", @"BL", @"290", @"SH", @"1", @"KN",
                                @"1", @"LC", @"590", @"MF", @"508", @"PM", @"1", @"VC",
                                @"239", @"ST", @"252", @"SO", @"47", @"SJ", @"963", @"SY",
                                @"886", @"TW", @"255", @"TZ", @"670", @"TL", @"58", @"VE",
                                @"84", @"VN", @"1", @"VG", @"1", @"VI", nil];
    
    NSString * tt = [locale objectForKey:NSLocaleCountryCode];
    NSString * defaultCode = [dictCodes objectForKey:tt];
    NSString * defaultCountryName = [locale displayNameForKey:NSLocaleCountryCode value:tt];
    
    if (!defaultCode || !defaultCountryName) {
        
        defaultCode = @"86";
        defaultCountryName = @"China";
    }
    
    self.countryCode.text = [NSString stringWithFormat:@"+%@", defaultCode];
    self.countryName.text = defaultCountryName;
    
}

/**
 *  dismiss modal出的登录控制器
 */
-(void) dismissAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

/**
 *  用户使用协议
 */
-(void) agreement
{
    LCUIWebViewController * web = [[LCUIWebViewController alloc] initWithURL:[NSURL URLWithString:@"http://terms.likeorz.com"]];
    [self presentViewController:LC_UINAVIGATION(web) animated:YES completion:nil];
    
    // UIBarMetricsDefault：用竖着（拿手机）时UINavigationBar的标准的尺寸来显示UINavigationBar
    [web.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:LKColor.color andSize:CGSizeMake(LC_DEVICE_WIDTH, 64)] forBarMetrics:UIBarMetricsDefault];
}

/**
 *  获取验证码
 */
-(void) getCode
{
    if (![self $check:YES]) {
        return;
    }
    
    [self cancelAllRequests];
    
    self.codeButton.userInteractionEnabled = NO;
    self.codeButton.title = LC_LO(@"获取中...");
    
    
    // 使用mob来进行短信验证
    NSString *countryCode = [self.countryCode.text substringFromIndex:1];
    [SMS_SDK getVerificationCodeBySMSWithPhone:self.phoneField.text
                                          zone:countryCode
                                        result:^(SMS_SDKError *error)
     {
         if (error)
         {
             UIAlertView *alert = [[UIAlertView alloc]
                                initWithTitle:NSLocalizedString(@"codesenderrtitle", nil)
                                      message:[NSString
                             stringWithFormat:@"状态码：%zi",error.errorCode]
                                     delegate:self
                            cancelButtonTitle:NSLocalizedString(@"sure", nil)
                            otherButtonTitles:nil, nil];
             [alert show];
             
         } else {
             
             [self $beginTimer];
             self.codeButton.userInteractionEnabled = YES;
         }
     }];
    
//    LKHttpRequestInterface * interface = [LKHttpRequestInterface interfaceType:@"sendSmsCode"].POST_METHOD();
//    
//    [interface addParameter:[LKTimestampEncryption encryption:[[NSDate date] timeIntervalSince1970]] key:@"token"];
//    [interface addParameter:self.phoneField.text key:@"mobile"];
//    [interface addParameter:[LKISOCountryCodes countryWithCode:self.countryCode.text] key:@"zone"];
//    
//    @weakly(self);
//    
//    [self request:interface complete:^(LKHttpRequestResult * result) {
//        
//        @normally(self);
//        
//        if (result.state == LKHttpRequestStateFinished) {
//            
//            [self $beginTimer];
//            
//            self.codeButton.userInteractionEnabled = YES;
//        }
//        else if (result.state == LKHttpRequestStateFailed){
//            
//            [self showTopMessageErrorHud:result.error];
//            
//            self.codeButton.title = LC_LO(@"获取验证码");
//            self.codeButton.userInteractionEnabled = YES;
//        }
//    }];
}

/**
 *  登录主界面
 */
-(void) login
{
    if (![self $check:NO]) {
        return;
    }
    
    self.maskView.hidden = NO;
    self.loginButton.title = LC_LO(@"登录中...");
    self.loginButton.userInteractionEnabled = NO;
        
    
    LKHttpRequestInterface * interface = [LKHttpRequestInterface interfaceType:@"authenticate/mobile/mob"].POST_METHOD();
    
//    [interface addParameter:[LKISOCountryCodes countryWithCode:self.countryCode.text] key:@"zone"];
    NSString *countryCode = [self.countryCode.text stringByReplacingOccurrencesOfString:@"+" withString:@""];
    [interface addParameter:countryCode key:@"zone"];
    [interface addParameter:self.phoneField.text key:@"mobile"];
    [interface addParameter:self.codeField.text key:@"code"];
    
    @weakly(self);
    
    [self request:interface complete:^(LKHttpRequestResult * result) {
        
        @normally(self);
        
        if (result.state == LKHttpRequestStateFinished) {
            
            self.loginButton.userInteractionEnabled = YES;
            //self.loginButton.title = @"进入Like";
            
            self.sesstionToken = result.json[@"data"][@"session_token"];
            self.refreshToken = result.json[@"data"][@"refresh_token"];
            self.expiresIn = result.json[@"data"][@"expires_in"];
            
            [self.userInfoModel getUserInfo:result.json[@"data"][@"user_id"]];
        }
        else if (result.state == LKHttpRequestStateFailed){
            
            self.loginButton.userInteractionEnabled = YES;
            self.loginButton.title = LC_LO(@"进入like");
            
            self.maskView.hidden = YES;
            [self showTopMessageErrorHud:result.error];
        }
    }];
}

/**
 *  第三方登录
 */
-(void) otherLogin:(UIView *)view
{
    @weakly(self);
    
    if ([view.tagString isEqualToString:@"WeChatLogin"]) {
        
        [LKWeChatShare.singleton login:^(NSString *uid, NSString *accessToken, NSString *error) {
            
            @normally(self);
            
            if (!error) {
                
                [self loginWithUID:uid accessToken:accessToken nick:@"" type:LKOtherLoginTypeWechat];
            }
            else{
                
                [self showTopMessageErrorHud:error];
            }
            
        }];
        
    }
    else if ([view.tagString isEqualToString:@"WeiboLogin"]) {
        
        [LKSinaShare.singleton login:^(NSString *uid, NSString *accessToken, NSString *error) {
            
            @normally(self);
            
            if (!error) {
                
                [self loginWithUID:uid accessToken:accessToken nick:@"" type:LKOtherLoginTypeWeibo];
            }
            else{
                
                [self showTopMessageErrorHud:error];
            }
            
        }];
    }
    else if ([view.tagString isEqualToString:@"FacebookLogin"]){
        
        [LKFacebookShare.singleton login:^(NSString *uid, NSString *accessToken, NSString * nick, NSString *error) {
            
            @normally(self);
            
            if (!error) {
                
                [self loginWithUID:uid accessToken:accessToken nick:nick ? nick : @"" type:LKOtherLoginTypeFacebook];
            }
            else{
                
                [self showTopMessageErrorHud:error];
            }
            
        }];
        
        
    };
}

/**
 *  给定uid/accessToken/nick/type进行第三方登录操作
 *
 *  @param uid         用户身份证明
 *  @param accessToken 访问令牌
 *  @param nick        昵称
 *  @param type        登录的账户类型
 */
-(void) loginWithUID:(NSString *)uid accessToken:(NSString *)accessToken nick:(NSString *)nick type:(LKOtherLoginType)type
{
    NSString * typeString = @"";
    
    if (type == LKOtherLoginTypeWeibo) {
        typeString = @"weibo";
    }
    else if (type == LKOtherLoginTypeWechat){
        typeString = @"wechat";
    }
    else if (type == LKOtherLoginTypeFacebook){
        typeString = @"facebook";
    }
    
    LKHttpRequestInterface * interface = [LKHttpRequestInterface interfaceType:[NSString stringWithFormat:@"authenticate/%@",typeString]].POST_METHOD();
    
    [interface addParameter:uid key:@"uid"];
    [interface addParameter:accessToken key:@"access_token"];
    // 对时间戳进行编码
    [interface addParameter:[LKTimestampEncryption encryption:[[NSDate date] timeIntervalSince1970]] key:@"token"];
    [interface addParameter:nick key:@"nickname"];
    
    @weakly(self);
    
    [self request:interface complete:^(LKHttpRequestResult * result) {
        
        @normally(self);
        
        if (result.state == LKHttpRequestStateFinished) {
            
            self.sesstionToken = result.json[@"data"][@"session_token"];
            self.refreshToken = result.json[@"data"][@"refresh_token"];
            self.expiresIn = result.json[@"data"][@"expires_in"];
            
            [self.userInfoModel getUserInfo:result.json[@"data"][@"user_id"]];
        }
        else if (result.state == LKHttpRequestStateFailed){
            
            [self showTopMessageErrorHud:result.error];
        }
        
    }];
}

LC_HANDLE_TIMER(timer)
{
    if ([timer is:@"CodeTimer"]) {
        
        self.timeInterval -= 1;
        
        if (self.timeInterval <= 0) {
            
            [self $restoreTimer];
            return;
        }
        
        self.codeButton.title = LC_NSSTRING_FORMAT(@"%@%@", @(self.timeInterval), LC_LO(@"s'后重新发送"));
    }
}

/**
 *  获取验证码开始计时
 */
-(void) $beginTimer
{
    self.timeInterval = 60;
    
    self.codeButton.userInteractionEnabled = NO;
    
    self.codeButton.title = [NSString stringWithFormat:@"60%@", LC_LO(@"s'后重新发送")];
    [self fireTimer:@"CodeTimer" timeInterval:1 repeat:YES];
}

/**
 *  重置计时
 */
-(void) $restoreTimer
{
    self.codeButton.userInteractionEnabled = YES;
    self.codeButton.title = LC_LO(@"获取验证码");
    [self cancelAllTimers];
}

/**
 *  检查格式是否正确
 */
-(BOOL) $check:(BOOL)codeOrLogin
{
    [self.phoneField resignFirstResponder];
    [self.codeField resignFirstResponder];
    
    if (self.phoneField.text.length == 0) {
        
        [self showTopMessageErrorHud:LC_LO(@"请输入手机号码")];
        return NO;
    }
    
    if (self.phoneField.text.length <= 4) {
        
        [self showTopMessageErrorHud:LC_LO(@"手机号码格式不正确")];
        return NO;
    }
    
    if (!codeOrLogin) {
        
        if (self.codeField.text.length <= 0) {
            
            [self showTopMessageErrorHud:LC_LO(@"请输入手机验证码")];
            return NO;
        }
    }
    
    return YES;
}

@end
