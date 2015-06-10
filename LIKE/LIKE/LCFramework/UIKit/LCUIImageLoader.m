//
//  EGOImageLoader.m
//  EGOImageLoading
//
//  Created by Shaun Harrison on 9/15/09.
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

#import "LCUIImageLoader.h"
#import "LCUIImageLoadConnection.h"
#import "LCUIImageCache.h"

@interface LCUIImageLoader ()

@end

@implementation LCUIImageLoader

- (instancetype)init
{
	if((self = [super init])){
        
		self.connectionsLock = [[NSLock alloc] init];
		self.currentConnections = [NSMutableDictionary dictionary];
	}
	
	return self;
}

- (LCImageLoadConnection *)loadingConnectionForURL:(NSString *)url
{
	LCImageLoadConnection * connection = [self.currentConnections objectForKey:url];
    
	if(!connection) return nil;
    
	else return connection;
}

- (void)cleanUpConnection:(LCImageLoadConnection*)connection
{
    connection.delegate = nil;

	if(!connection.imageURL) return;
		
	[self.connectionsLock lock];
    
	[self.currentConnections removeObjectForKey:connection.imageURL];

    [self.connectionsLock unlock];
}

- (BOOL)isLoadingImageURL:(NSString *)url
{
    return [self loadingConnectionForURL:url] ? YES : NO;
}

- (void)clearCacheForURL:(NSString *)url
{
    [LCUIImageCache.singleton removeImageWithKey:url];
}

- (void)cancelLoadForURL:(NSString *)url
{
	LCImageLoadConnection * connection = [self loadingConnectionForURL:url];
    
	[NSObject cancelPreviousPerformRequestsWithTarget:connection selector:@selector(start) object:nil];
    
	[connection cancel];
    
	[self cleanUpConnection:connection];
}

- (LCImageLoadConnection *)loadImageForURL:(NSString *)url
{
	LCImageLoadConnection * connection;
	
	if((connection = [self loadingConnectionForURL:url])){
        
		return connection;
        
	} else {
        
		connection = [[LCImageLoadConnection alloc] initWithImageURL:url delegate:self];
	
		[self.connectionsLock lock];
		[self.currentConnections setObject:connection forKey:url];
		[self.connectionsLock unlock];
        
		[connection performSelector:@selector(start) withObject:nil afterDelay:0];
		
		return connection;
	}
}

- (void)loadImageForURL:(NSString *)url observer:(NSObject *)observer
{
	if(!url) return;
	
	if([observer respondsToSelector:@selector(handleNotification:)]){
        
        if (!LC_NSSTRING_IS_INVALID(url)) {
            [observer observeNotification:LCImageLoaderNotificationLoaded(url)];
            [observer observeNotification:LCImageLoaderNotificationLoadFailed(url)];
            [observer observeNotification:LCImageLoaderNotificationLoadRecived(url)];
        }
	}

	[self loadImageForURL:url];
}

- (UIImage*)imageForURL:(NSString *)url shouldLoadWithObserver:(NSObject *)observer
{
	if(!url) return nil;
	
    UIImage * anImage = [LCUIImageCache.singleton imageWithKey:url];
    
	if(anImage)
    {
		return anImage;
	}
    else
    {
		[self loadImageForURL:url observer:observer];
		return nil;
	}
}

- (void)removeObserver:(NSObject *)observer
{
	[[NSNotificationCenter defaultCenter] removeObserver:observer name:nil object:self];
}

- (void)removeObserver:(NSObject *)observer forURL:(NSString *)url
{
    if (!LC_NSSTRING_IS_INVALID(url)) {
        [observer unobserveNotification:LCImageLoaderNotificationLoaded(url)];
        [observer unobserveNotification:LCImageLoaderNotificationLoadFailed(url)];
        [observer unobserveNotification:LCImageLoaderNotificationLoadRecived(url)];
    }
}

- (BOOL)hasLoadedImageURL:(NSString *)url
{
	return [LCUIImageCache.singleton hasCachedWithKey:url];
}

#pragma mark -

- (void)imageLoadConnectionDidReciveDataWithProgress:(CGFloat)progress connection:(LCImageLoadConnection *)connection
{
    NSNotification* notification = [NSNotification notificationWithName:LCImageLoaderNotificationLoadRecived(connection.imageURL) object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@(progress),@"progress",connection.imageURL,@"imageURL",nil]];
    
    [[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:YES];
}

- (void)imageLoadConnectionDidFinishLoading:(LCImageLoadConnection *)connection
{
    if (![self checkResult:connection.request]) {
        
        [self imageLoadConnection:connection didFailWithError:connection.request.error];
        return;
    }
        
    NSString * fullPath = [LCUIImageCache.singleton.fileCache fileNameForKey:[connection.imageURL MD5]];

    UIImage * anImage = [UIImage imageWithContentsOfFile:fullPath];
    
	if(!anImage) {
        
		NSError * error = [NSError errorWithDomain:connection.imageURL code:406 userInfo:nil];
		
		NSNotification* notification = [NSNotification notificationWithName:LCImageLoaderNotificationLoadFailed(connection.imageURL)
																	 object:self
																   userInfo:[NSDictionary dictionaryWithObjectsAndKeys:error,@"error",connection.imageURL,@"imageURL",nil]];
		
        [[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:YES];
		
	} else {
        
        [LCUIImageCache.singleton saveImageToMemoryCache:anImage key:connection.imageURL];
        //[LCUIImageCache.singleton saveImageDataToFileCache:connection.responseData key:connection.imageURL];

		NSNotification* notification = [NSNotification notificationWithName:LCImageLoaderNotificationLoaded(connection.imageURL)
																	 object:self
																   userInfo:[NSDictionary dictionaryWithObjectsAndKeys:anImage,@"image",connection.imageURL,@"imageURL",nil]];
		
        [[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:YES];
		
	}
	
	[self cleanUpConnection:connection];
}

-(BOOL) checkResult:(ASIHTTPRequest *)request
{
    NSInteger length = [request.responseHeaders[@"Content-Length"] integerValue];

    NSInteger dataLength = request.responseData.length;

    if(dataLength < length && dataLength != 0){

        ERROR(@"Image is broken! ( ContentLength:%d, ActualLength:%d )",length,dataLength);
        return NO;
    }

    return YES;
}

- (void)imageLoadConnection:(LCImageLoadConnection *)connection didFailWithError:(NSError *)error {

	NSNotification * notification = [NSNotification notificationWithName:LCImageLoaderNotificationLoadFailed(connection.imageURL)
																 object:self
															   userInfo:[NSDictionary dictionaryWithObjectsAndKeys:error,@"error",connection.imageURL,@"imageURL",nil]];
	
    [[NSNotificationCenter defaultCenter] postNotification:notification];

	[self cleanUpConnection:connection];
}

#pragma mark -

-(void) dealloc
{
    
}

@end