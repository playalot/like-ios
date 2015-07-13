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

@interface LCImageLoadConnection ()

@end

@implementation LCImageLoadConnection


+(NSOperationQueue *) sharedImageRequestOperationQueue
{
    static NSOperationQueue * __sharedImageRequestOperationQueue = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        __sharedImageRequestOperationQueue = [[NSOperationQueue alloc] init];
        __sharedImageRequestOperationQueue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
    });
    
    return __sharedImageRequestOperationQueue;
}

+(AFImageResponseSerializer *) sharedImageResponseSerializer
{
    static AFImageResponseSerializer * __sharedImageResponseSerializer = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        __sharedImageResponseSerializer = [AFImageResponseSerializer serializer];
    });
    
    return __sharedImageResponseSerializer;
}

- (id)initWithImageURL:(NSString *)url delegate:(id)delegate
{
	if((self = [super init])) {
        
		self.imageURL = url;
		self.delegate = delegate;
		self.timeoutInterval = 60;
	}
	
	return self;
}

- (void)startDownload
{
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.imageURL]];
    request.timeoutInterval = self.timeoutInterval;
    
    self.requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    self.requestOperation.responseSerializer = [AFImageResponseSerializer serializer];
    
    __strong typeof(self) strongSelf = self;
    
    @weakly(self);
    
    [strongSelf.requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * operation, id responseObject) {

        @normally(self);
        
        self.responseImage = responseObject;
        self.responseData = self.requestOperation.responseData;
        
        [self requestFinished];
        
    } failure:^(AFHTTPRequestOperation * operation, NSError * error) {
        
        @normally(self);

        [self requestFailed:error];
    }];
    
    
    [strongSelf.requestOperation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
       
        @normally(self);

        CGFloat progress = ((CGFloat)totalBytesRead) / totalBytesExpectedToRead;
        
        [self setProgress:progress];
        
    }];
    
    
    //[self.requestOperation start];
    [[[self class] sharedImageRequestOperationQueue] addOperation:self.requestOperation];
}

- (void)cancel
{
	[self.requestOperation cancel];
}

- (void)requestFinished
{
    NSString * fullPath = [LCUIImageCache.singleton.fileCache fileNameForKey:[self.imageURL MD5]];

    [self.responseData writeToFile:fullPath atomically:YES];
    
    if([self.delegate respondsToSelector:@selector(imageLoadConnectionDidFinishLoading:)]){
        
        [self.delegate imageLoadConnectionDidFinishLoading:self];
    }
}

- (void)requestFailed:(NSError *)error
{
    if([self.delegate respondsToSelector:@selector(imageLoadConnection:didFailWithError:)]){
        
        [self.delegate imageLoadConnection:self didFailWithError:error];
    }
}

- (void)setProgress:(CGFloat)newProgress
{
    if ([self.delegate respondsToSelector:@selector(imageLoadConnectionDidReciveDataWithProgress:connection:)]) {
        
        [self.delegate imageLoadConnectionDidReciveDataWithProgress:newProgress connection:self];
    }
}

- (void)dealloc
{
	_delegate = nil;
    
    [self.requestOperation cancel];
    self.requestOperation = nil;
}

@end
