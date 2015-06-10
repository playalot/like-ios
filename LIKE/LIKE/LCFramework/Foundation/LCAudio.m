//
//  LC_Audio.m
//  LCFramework

//  Created by Licheng Guo . ( SUGGESTIONS & BUG titm@tom.com ) on 13-10-14.
//  Copyright (c) 2014年 Licheng Guo iOS developer ( http://nsobject.me ).All rights reserved.
//  Also see the copyright page ( http://nsobject.me/copyright.rtf ).
//
//

#import "LCAudio.h"
#import "LCAVAudioPlayer.h"

@implementation LCAudio

+(LCAVAudioPlayer *) playSoundName:(NSString *)soundName
{
    NSString * filePath = [[NSBundle mainBundle] pathForResource:soundName ofType:nil];
    
    return [LCAudio playSoundAtFile:filePath];
}

+(LCAVAudioPlayer *) playSoundAtFile:(NSString *)file
{
    if (LC_NSSTRING_IS_INVALID(file)) {
        return nil;
    }
    
    LCAVAudioPlayer * player = [LCAVAudioPlayer playerWithContentsOfPath:file];
    
    if (!player) {
        return nil;
    }
    
    BOOL result = [player prepareToPlay];
    
    if (!result) {
        return nil;
    }
    
    result = [player play];
    
    if (!result) {
        return nil;
    }
    
    return player;
}

+(BOOL) playSoundInAudioServices:(NSString *)soundName
{
    SystemSoundID soundID;
    NSURL * sample = [NSURL URLWithString:[[NSBundle mainBundle] pathForResource:soundName ofType:nil]];
    
    OSStatus err = AudioServicesCreateSystemSoundID((__bridge CFURLRef)sample, &soundID);
    
    if (err) {
        ERROR(@"Error occurred assigning system sound!");
        return NO;
    }

    AudioServicesPlaySystemSound(soundID);
    
    return YES;
}

+(void) vibration
{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

@end
