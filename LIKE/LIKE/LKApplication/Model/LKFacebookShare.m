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

@interface LKFacebookShare ()

LC_PROPERTY(copy) LKFacebookLoginComplete complete;

@end

@implementation LKFacebookShare

-(void)login:(LKFacebookLoginComplete)complete
{
    self.complete = complete;
    
    FBSDKLoginManager * manager = [[FBSDKLoginManager alloc] init];
    manager.defaultAudience = FBSDKDefaultAudienceEveryone;
    manager.loginBehavior = FBSDKLoginBehaviorNative;
    
    [manager logInWithReadPermissions:@[@"public_profile"] handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
       
        if (error) {

            self.complete(nil, nil, LC_LO(@"发生错误"));
            
        } else if (result.isCancelled) {
            // Handle cancellations
        } else {
            
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            FBSDKAccessToken * token = [FBSDKAccessToken currentAccessToken];
            
            if (token) {
                
                NSLog(@"%@",token.tokenString);
                NSLog(@"%@",token.userID);
                
                self.complete(token.userID, token.tokenString, nil);
            }
            else{
                
                self.complete(nil, nil, LC_LO(@"发生错误"));
            }
        }
        
    }];
}

@end
