//
//  LC_Localized.m
//  LCFramework

//  Created by Licheng Guo . ( SUGGESTIONS & BUG titm@tom.com ) on 13-10-14.
//  Copyright (c) 2014年 Licheng Guo iOS developer ( http://nsobject.me ).All rights reserved.
//  Also see the copyright page ( http://nsobject.me/copyright.rtf ).
//
//

#import "LCLocalized.h"
#import "NCChineseConverter.h"

@implementation LCLocalized

+ (NSString *) localizedStringForKey:(NSString *)key
{
    return [LCLocalized localizedStringForKey:key defaultString:key];
}

static NSString * __currentLangueage = nil;

+ (NSString *)localizedStringForKey:(NSString *)key defaultString:(NSString *)defaultString
{
    static NSBundle * bundle = nil;
    
    @synchronized(self){
    
        if (bundle == nil)
        {
            NSString * bundlePath = [[NSBundle mainBundle] pathForResource:@"LCInternationalization" ofType:@"bundle"];
            bundle = [NSBundle bundleWithPath:bundlePath] ?: [NSBundle mainBundle];
            
            for (NSString * language in [NSLocale preferredLanguages])
            {
                if ([[bundle localizations] containsObject:language])
                {
                    bundlePath = [bundle pathForResource:language ofType:@"lproj"];
                    bundle = [NSBundle bundleWithPath:bundlePath];
                    break;
                }
            }
        }
    }
    
    if (!__currentLangueage) {
        
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        
        NSArray * allLanguages = [defaults objectForKey:@"AppleLanguages"];
        
        __currentLangueage =  [allLanguages objectAtIndex:0];
    }
    
    defaultString = [bundle localizedStringForKey:key value:defaultString table:nil];
    
    if ([__currentLangueage isEqualToString:@"zh-Hant"]) {
        
        defaultString = [[NCChineseConverter sharedInstance] convert:defaultString withDict:NCChineseConverterDictTypezh2TW];
    }
    else if ([__currentLangueage isEqualToString:@"zh-HK"]){
        
        defaultString = [[NCChineseConverter sharedInstance] convert:defaultString withDict:NCChineseConverterDictTypezh2HK];
    }
    
    return [[NSBundle mainBundle] localizedStringForKey:key value:defaultString table:nil];
}

@end
