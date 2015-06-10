//
//  NSObject+LCPerformSelector.h
//  LCFrameworkDemo
//
//  Created by Licheng Guo . http://nsobject.me/ on 15/4/2.
//  Copyright (c) 2015年 Licheng Guo . http://nsobject.me/. All rights reserved.
//

LC_BLOCK(id, LCPerformSelector, (SEL selector, id object));
LC_BLOCK(void, LCPerformSelectorDelay, (SEL selector, id object, NSTimeInterval delay));

@interface NSObject (LCPerformSelector)

LC_PROPERTY(readonly) LCPerformSelector PERFORM;
LC_PROPERTY(readonly) LCPerformSelectorDelay PERFORM_DELAY;

@end
