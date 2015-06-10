//
//
//      _|          _|_|_|
//      _|        _|
//      _|        _|
//      _|        _|
//      _|_|_|_|    _|_|_|
//
//
//  Copyright (c) 2014-2015, Licheng Guo. ( http://nsobject.me )
//  http://github.com/titman
//
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.
//

#import "LCUISignal.h"

@implementation UIView (LCUISignal)

-(LCSignalSend) SEND
{
    LCSignalSend block = ^ LCSignal * (NSString * name){
      
        LCSignal * signal = [LCSignal signal];
        
        signal.from = self;
        signal.name = name;
        
        self.PERFORM_DELAY(@selector($send:), signal, 0);
        
        return signal;
    };
    
    return block;
}

-(LCSignalSendTo) SEND_TO
{
    LCSignalSendTo block = ^ LCSignal * (NSString * name , id to){
        
        LCSignal * signal = [LCSignal signal];
        
        signal.from = self;
        signal.name = name;
        signal.to = to;
        
        self.PERFORM_DELAY(@selector($send:), signal, 0);
        
        return signal;
    };
    
    return block;
}

-(void) $send:(LCSignal *)signal
{
    if(!signal){
        return;
    }
    
    NSString * selectorName = [NSString stringWithFormat:@"handleUISignal$%@:", signal.name];
    
    SEL selector = NSSelectorFromString(selectorName);
    
    if(signal.to){
        
        ((NSObject *)signal.to).PERFORM(selector, signal);
    }
    else{
        
        UIViewController * viewController = self.viewController;
        
        if (viewController) {
            
            viewController.PERFORM(selector, signal);
        }
        else{
            
            UIView * superView = self;
            
            while (superView) {
                
                superView.PERFORM(selector, signal);
                
                UIView * tmp = superView.superview;
                
                viewController = tmp.viewController;
                
                if (viewController) {
                    
                    if([viewController respondsToSelector:selector]){
                        
                        _Pragma("clang diagnostic push") \
                        _Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
                        [viewController performSelector:selector withObject:signal];
                        _Pragma("clang diagnostic pop") \

                    }
                    //viewController.PERFORM(selector, signal);
                    return;
                }
                
                superView = tmp;
            }
        }
    }
}

#pragma mark - 

- (UIViewController *)viewController
{
    UIResponder * nextResponder = [self nextResponder];
    
    if (nextResponder && [nextResponder isKindOfClass:[UIViewController class]]){
        
        return (UIViewController *)nextResponder;
    }
    
    return nil;
}

-(void) setSignalName:(NSString *)signalName
{
    if (signalName) {
 
        SEL selector = @selector($handleTapAction);
        
        if ([self isKindOfClass:[UIButton class]]) {
            
            [((UIButton *)self) removeTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
            [((UIButton *)self) addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
        }
        else{
            
            if (self.tapGestureRecognizer) {
                
                [self removeGestureRecognizer:self.tapGestureRecognizer];
            }
            
            [self addTapGestureRecognizer:self selector:selector];
        }
    }
    
    [LCAssociate setAssociatedObject:self value:signalName key:"LCUISignalName.key"];
}

-(NSString *) signalName
{
    return [LCAssociate getAssociatedObject:self key:"LCUISignalName.key"];
}

-(void) $handleTapAction
{
    if (self.signalName){
        
        self.SEND(self.signalName);
    }
}

@end