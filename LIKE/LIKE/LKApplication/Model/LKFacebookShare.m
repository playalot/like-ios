//
//  LKFacebookShare.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/6/17.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKFacebookShare.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface LKFacebookShare ()

LC_PROPERTY(copy) LKFacebookLoginComplete complete;

@end

@implementation LKFacebookShare


-(void) dealloc
{
    [self unobserveAllNotifications];
}

-(instancetype) init
{
    if (self = [super init]) {
        
        
        [self observeNotification:FBSDKProfileDidChangeNotification];

    }
    
    return self;
}

-(void)login:(LKFacebookLoginComplete)complete
{
    self.complete = complete;
    
    FBSDKLoginManager * manager = [[FBSDKLoginManager alloc] init];
    manager.defaultAudience = FBSDKDefaultAudienceEveryone;
    manager.loginBehavior = FBSDKLoginBehaviorNative;
    
    [manager logInWithReadPermissions:@[@"public_profile"] handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
       
        if (error) {

            self.complete(nil, nil, nil,LC_LO(@"发生错误"));
            
        } else if (result.isCancelled) {
            // Handle cancellations
        } else {
            
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            FBSDKAccessToken * token = [FBSDKAccessToken currentAccessToken];
            FBSDKProfile * profile = [FBSDKProfile currentProfile];

            if (token && profile) {
                
                self.complete(token.userID, token.tokenString, profile.name, nil);
            }
            else if(!token){
                
                self.complete(nil, nil, nil, LC_LO(@"发生错误"));
            }
        }
        
    }];
}

-(void) handleNotification:(NSNotification *)notification
{
    FBSDKAccessToken * token = [FBSDKAccessToken currentAccessToken];
    FBSDKProfile * profile = [FBSDKProfile currentProfile];
    
    self.complete(token.userID, token.tokenString, profile.name, nil);
    
}


@end
