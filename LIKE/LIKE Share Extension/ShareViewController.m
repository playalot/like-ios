//
//  ShareViewController.m
//  LIKE Share Extension
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/6/2.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "ShareViewController.h"

@interface ShareViewController ()

@end

@implementation ShareViewController

- (BOOL)isContentValid {

    NSExtensionItem * imageItem = [self.extensionContext.inputItems firstObject];
    
    if(!imageItem){
        
        return NO;
    }
    NSItemProvider * imageItemProvider = [[imageItem attachments] firstObject];
    
    if(!imageItemProvider){
        
        return NO;
    }
    
    return YES;
}

- (void)didSelectPost {
    // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
    
    // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
    [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
}

- (NSArray *)configurationItems {
    // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
    return @[];
}

@end
