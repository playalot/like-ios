//
//  LC_AVAudioPlayer.m
//  LCFramework
//
//  Created by Licheng Guo . ( SUGGESTIONS & BUG titm@tom.com ) on 14-2-19.
//  Copyright (c) 2014年 LS Developer ( http://www.likesay.com ). All rights reserved.
//

#import "LCAVAudioPlayer.h"

@interface LCAVAudioPlayer ()<AVAudioPlayerDelegate>

@end

@implementation LCAVAudioPlayer

-(void) dealloc
{
    if (self.isPlaying) {
        [self stop];
    }
}

+ (LCAVAudioPlayer *) playerWithContentsOfPath:(NSString *)path
{
    LCAVAudioPlayer * player = [[LCAVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:path] error:nil];
    player.delegate = player;
    return player;
}

-(instancetype) init
{
    LC_SUPER_INIT({
       
        [self initSelf];
        
    });
}

-(instancetype) initWithContentsOfURL:(NSURL *)url error:(NSError **)outError
{
    self = [super initWithContentsOfURL:url error:outError];
    
    if (self) {
        
        [self initSelf];
    }
    
    return self;
}

-(void) initSelf
{
    ;
}

-(BOOL) play
{
    return [super play];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if (self.didFinishPlaying) {
        self.didFinishPlaying(self,flag);
    }
}

@end

