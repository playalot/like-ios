//
//  LKRebindPhoneViewController.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/6/18.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKRebindPhoneViewController.h"
#import "LKTimestampEncryption.h"
#import "LKISOCountryCodes.h"
#import "LKCountryCodeViewController.h"

@interface LKRebindPhoneViewController ()

LC_PROPERTY(strong) LCUILabel * countryCode;
LC_PROPERTY(strong) LCUILabel * countryName;
LC_PROPERTY(strong) LCUITextField * phoneField;
LC_PROPERTY(strong) LCUITextField * codeField;
LC_PROPERTY(strong) LCUIButton * codeButton;
LC_PROPERTY(strong) LCUIButton * sureButton;

LC_PROPERTY(assign) NSInteger timeInterval;

@end

@implementation LKRebindPhoneViewController

-(void) dealloc
{
    [self cancelAllRequests];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setNavigationBarHidden:NO animated:animated];
}

-(void) buildUI
{
    self.title = LC_LO(@"账号绑定");

    [self setNavigationBarButton:LCUINavigationBarButtonTypeLeft image:[UIImage imageNamed:@"NavigationBarBack.png" useCache:YES] selectImage:nil];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:LKColor.color andSize:CGSizeMake(LC_DEVICE_WIDTH, 64)] forBarMetrics:UIBarMetricsDefault];
    
    
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    
    self.countryCode = LCUILabel.view;
    self.countryCode.viewFrameWidth = 80;
    self.countryCode.viewFrameHeight = 200 / 3;
    self.countryCode.font = LK_FONT(13);
    self.countryCode.textColor = LC_RGB(51, 51, 51);
    self.countryCode.textAlignment = UITextAlignmentCenter;
    [self.countryCode addTapGestureRecognizer:self selector:@selector(chooseCountryCode)];
    self.view.ADD(self.countryCode);
    
    
    self.countryName = LCUILabel.view;
    self.countryName.viewFrameX = self.countryCode.viewRightX + 30;
    self.countryName.viewFrameWidth = 200;
    self.countryName.viewFrameHeight = 200 / 3;
    self.countryName.font = LK_FONT(13);
    self.countryName.textColor = LC_RGB(51, 51, 51);
    [self.countryName addTapGestureRecognizer:self selector:@selector(chooseCountryCode)];
    self.view.ADD(self.countryName);

    
    LCUIImageView * countryMore = [LCUIImageView viewWithImage:[[[UIImage imageNamed:@"PullLoaderSmallArrow.png"] imageWithTintColor:LKColor.color] scaleToWidth:15]];
    countryMore.viewFrameY = self.countryName.viewMidHeight - countryMore.viewMidHeight;
    countryMore.viewFrameX = LC_DEVICE_WIDTH - countryMore.viewFrameWidth - 15;
    self.view.ADD(countryMore);
    
    
    UIView * line = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TalkLine.png" useCache:YES]];
    line.viewFrameWidth = LC_DEVICE_WIDTH - 40;
    line.viewFrameX = 20;
    line.viewFrameY = self.countryName.viewBottomY - line.viewFrameHeight;
    self.view.ADD(line);

    
    [self setTheLocalAreaCode];
    
    
    UIImageView * phoneIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PhoneIcon.png" useCache:YES]];
    phoneIcon.viewFrameX = 30;
    phoneIcon.viewFrameY = self.countryName.viewBottomY + (200 / 3 / 2 - phoneIcon.viewMidHeight);
    self.view.ADD(phoneIcon);
    
    
    self.countryCode.viewCenterX = phoneIcon.viewCenterX;
    
    
    self.phoneField = LCUITextField.view;
    self.phoneField.viewFrameY = self.countryName.viewBottomY;
    self.phoneField.viewFrameX = phoneIcon.viewRightX + 30;
    self.phoneField.viewFrameWidth = LC_DEVICE_WIDTH - self.phoneField.viewFrameX - 30;
    self.phoneField.viewFrameHeight = 200 / 3;
    self.phoneField.font = LK_FONT(13);
    self.phoneField.textColor = LC_RGB(51, 51, 51);
    self.phoneField.placeholder = LC_LO(@"输入手机号码");
    self.phoneField.placeholderColor = LC_RGB(180, 180, 180);
    self.phoneField.returnKeyType = UIReturnKeyNext;
    self.phoneField.keyboardType = UIKeyboardTypeNumberPad;
    self.phoneField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.view.ADD(self.phoneField);
    
    @weakly(self);
    
    self.phoneField.shouldReturn = ^ BOOL (id value){
        
        @normally(self);
        
        [self.phoneField resignFirstResponder];
        return YES;
    };
    
    
    self.countryName.viewFrameX = self.phoneField.viewFrameX;
    
    
    UIView * line1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TalkLine.png" useCache:YES]];
    line1.viewFrameWidth = LC_DEVICE_WIDTH - 40;
    line1.viewFrameX = 20;
    line1.viewFrameY = self.phoneField.viewBottomY - line.viewFrameHeight;
    self.view.ADD(line1);
    
    
    
    UIImageView * codeIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CodeIcon.png" useCache:YES]];
    codeIcon.viewFrameX = 30;
    codeIcon.viewFrameY = self.phoneField.viewBottomY + (self.phoneField.viewMidHeight - codeIcon.viewMidHeight);
    self.view.ADD(codeIcon);
    
    
    self.codeField = LCUITextField.view;
    self.codeField.viewFrameY = self.phoneField.viewBottomY;
    self.codeField.viewFrameX = codeIcon.viewRightX + 30;
    self.codeField.viewFrameWidth = LC_DEVICE_WIDTH - self.codeField.viewFrameX - 100;
    self.codeField.viewFrameHeight = self.phoneField.viewFrameHeight;
    self.codeField.font = LK_FONT(13);
    self.codeField.textColor = LC_RGB(51, 51, 51);
    self.codeField.placeholder = LC_LO(@"输入验证码");
    self.codeField.placeholderColor = LC_RGB(180, 180, 180);
    self.codeField.returnKeyType = UIReturnKeyJoin;
    self.codeField.keyboardType = UIKeyboardTypeNumberPad;
    self.codeField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.view.ADD(self.codeField);
    
    self.codeField.shouldReturn = ^ BOOL (id value){
        
        @normally(self);
        
        [self.codeField resignFirstResponder];
        [self getCode];
        return YES;
    };
    
    
    self.codeButton = LCUIButton.view;
    self.codeButton.viewFrameY = self.codeField.viewFrameY;
    self.codeButton.viewFrameWidth = 100;
    self.codeButton.viewFrameHeight = self.codeField.viewFrameHeight;
    self.codeButton.viewFrameX = LC_DEVICE_WIDTH - self.codeButton.viewFrameWidth - 10;
    self.codeButton.title = LC_LO(@"获取验证码");
    self.codeButton.titleColor = LC_RGB(51, 51, 51);
    self.codeButton.titleFont = LK_FONT(13);
    self.codeButton.showsTouchWhenHighlighted = YES;
    [self.codeButton addTarget:self action:@selector(getCode) forControlEvents:UIControlEventTouchUpInside];
    self.view.ADD(self.codeButton);


    UIView * line2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TalkLine.png" useCache:YES]];
    line2.viewFrameWidth = LC_DEVICE_WIDTH - 40;
    line2.viewFrameX = 20;
    line2.viewFrameY = self.codeField.viewBottomY - line.viewFrameHeight;
    self.view.ADD(line2);
    
    
    self.sureButton = LCUIButton.view;
    self.sureButton.viewFrameX = 50;
    self.sureButton.viewFrameY = self.codeField.viewBottomY + 30;
    self.sureButton.viewFrameWidth = LC_DEVICE_WIDTH - 100;
    self.sureButton.viewFrameHeight = 40;
    self.sureButton.title = LC_LO(@"确定修改手机号");
    self.sureButton.titleColor = [UIColor whiteColor];
    self.sureButton.titleFont = LK_FONT(13);
    self.sureButton.backgroundColor = LKColor.color;
    self.sureButton.cornerRadius = 4;
    self.sureButton.showsTouchWhenHighlighted = YES;
    [self.sureButton addTarget:self action:@selector(sure) forControlEvents:UIControlEventTouchUpInside];
    self.view.ADD(self.sureButton);
}

-(void) handleNavigationBarButton:(LCUINavigationBarButtonType)type
{
    if (type == LCUINavigationBarButtonTypeLeft) {
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

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

-(void) sure
{
    if (![self $check:YES]) {
        return;
    }
    
    self.sureButton.title = LC_LO(@"修改中...");
    self.sureButton.userInteractionEnabled = NO;
    
    LKHttpRequestInterface * interface = [LKHttpRequestInterface interfaceType:@"link/mobile"].POST_METHOD();
    
    [interface addParameter:[LKISOCountryCodes countryWithCode:self.countryCode.text] key:@"zone"];
    [interface addParameter:self.phoneField.text key:@"mobile"];
    [interface addParameter:self.codeField.text key:@"code"];
    
    @weakly(self);
    
    [self request:interface complete:^(LKHttpRequestResult * result) {
        
        @normally(self);
        
        if (result.state == LKHttpRequestStateFinished) {
            
            self.sureButton.userInteractionEnabled = YES;
            
            [self.navigationController popViewControllerAnimated:YES];
        }
        else if (result.state == LKHttpRequestStateFailed){
            
            self.sureButton.userInteractionEnabled = YES;
            self.sureButton.title = LC_LO(@"确定修改手机号");
            
            [self showTopMessageErrorHud:result.error];
        }
    }];
}

-(void) getCode
{
    if (![self $check:YES]) {
        return;
    }
    
    [self cancelAllRequests];
    
    self.codeButton.userInteractionEnabled = NO;
    self.codeButton.title = LC_LO(@"获取中...");
    
    
    LKHttpRequestInterface * interface = [LKHttpRequestInterface interfaceType:@"sendSmsCode"].POST_METHOD();
    
    [interface addParameter:[LKTimestampEncryption encryption:[[NSDate date] timeIntervalSince1970]] key:@"token"];
    [interface addParameter:self.phoneField.text key:@"mobile"];
    [interface addParameter:[LKISOCountryCodes countryWithCode:self.countryCode.text] key:@"zone"];
    
    @weakly(self);
    
    [self request:interface complete:^(LKHttpRequestResult * result) {
        
        @normally(self);
        
        if (result.state == LKHttpRequestStateFinished) {
            
            [self $beginTimer];
            
            self.codeButton.userInteractionEnabled = YES;
        }
        else if (result.state == LKHttpRequestStateFailed){
            
            [self showTopMessageErrorHud:result.error];
            
            self.codeButton.title = LC_LO(@"获取验证码");
            self.codeButton.userInteractionEnabled = YES;
        }
    }];
}


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

-(void) $beginTimer
{
    self.timeInterval = 60;
    
    self.codeButton.userInteractionEnabled = NO;
    
    self.codeButton.title = [NSString stringWithFormat:@"60%@", LC_LO(@"s'后重新发送")];
    [self fireTimer:@"CodeTimer" timeInterval:1 repeat:YES];
}

-(void) $restoreTimer
{
    self.codeButton.userInteractionEnabled = YES;
    self.codeButton.title = LC_LO(@"获取验证码");
    [self cancelAllTimers];
}


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
