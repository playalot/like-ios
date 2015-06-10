//
//  EGOImageLoadConnection.m
//  EGOImageLoading
//
//  Created by Shaun Harrison on 12/1/09.
//  Copyright (c) 2009-2010 enormego
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "LCUIImageLoadConnection.h"
#import "LCUIImageCache.h"

@interface LCImageLoadConnection ()<ASIHTTPRequestDelegate,ASIProgressDelegate>

@end

@implementation LCImageLoadConnection


- (id)initWithImageURL:(NSString *)url delegate:(id)delegate
{
	if((self = [super init])) {
        
		self.imageURL = url;
		self.delegate = delegate;
		self.timeoutInterval = 60;
	}
	
	return self;
}

- (void)start
{
    self.request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:self.imageURL]];
    self.request.downloadDestinationPath = [LCUIImageCache.singleton.fileCache fileNameForKey:[self.imageURL MD5]];
    self.request.timeOutSeconds = self.timeoutInterval;
    self.request.delegate = self;
    self.request.downloadProgressDelegate = self;
    
    [self.request startAsynchronous];
}

- (void)cancel
{
	[self.request clearDelegatesAndCancel];
}

-(NSData *) responseData
{
    if (self.request){
        
        return self.request.responseData;
    }
    
    return nil;
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    if([self.delegate respondsToSelector:@selector(imageLoadConnectionDidFinishLoading:)]){
        
        [self.delegate imageLoadConnectionDidFinishLoading:self];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    if([self.delegate respondsToSelector:@selector(imageLoadConnection:didFailWithError:)]){
        
        [self.delegate imageLoadConnection:self didFailWithError:request.error];
    }
}

- (void)setProgress:(float)newProgress
{
    if ([self.delegate respondsToSelector:@selector(imageLoadConnectionDidReciveDataWithProgress:connection:)]) {
        
        [self.delegate imageLoadConnectionDidReciveDataWithProgress:newProgress connection:self];
    }
}

- (void)dealloc
{
	_delegate = nil;
    
    _request.delegate = nil;
    [_request clearDelegatesAndCancel];
}

@end
