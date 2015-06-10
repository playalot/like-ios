//
//  LC_AVAudioPlayer.h
//  LCFramework
//
//  Created by Licheng Guo . ( SUGGESTIONS & BUG titm@tom.com ) on 14-2-19.
//  Copyright (c) 2014年 LS Developer ( http://www.likesay.com ). All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@class LCAVAudioPlayer;

LC_BLOCK(void, LCAVAudioPlayerDidFinishPlaying, (LCAVAudioPlayer * player, BOOL flag));

@interface LCAVAudioPlayer : AVAudioPlayer

LC_PROPERTY(copy) LCAVAudioPlayerDidFinishPlaying didFinishPlaying;

+ (instancetype) playerWithContentsOfPath:(NSString *)path;

@end
