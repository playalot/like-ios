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

@class LCSignal;

#undef  LC_ST_SIGNAL
#define LC_ST_SIGNAL(__class, __name)	 LC_CATEGORY_PROPERTY(__class, __name)

LC_BLOCK(LCSignal *, LCSignalSend, (NSString * name));
LC_BLOCK(LCSignal *, LCSignalSendTo, (NSString * name, id to));

@protocol LCSignalProtocol <NSObject>

LC_PROPERTY(readonly) LCSignalSend SEND;
LC_PROPERTY(readonly) LCSignalSendTo SEND_TO;

@end

#pragma mark -

@interface LCSignal : NSObject

LC_PROPERTY(assign) id from;
LC_PROPERTY(retain) id to;
LC_PROPERTY(copy) NSString * name;

LC_PROPERTY(strong) id object;
LC_PROPERTY(assign) NSInteger tag;
LC_PROPERTY(strong) NSString * tagString;
LC_PROPERTY(assign) BOOL breakSend;

+(LCSignal *) signal;

@end
