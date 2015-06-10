//
//  LC_Tools.h
//  LCFramework

//  Created by Licheng Guo . ( SUGGESTIONS & BUG titm@tom.com ) on 13-9-20.
//  Copyright (c) 2014年 Licheng Guo iOS developer ( http://nsobject.me ).All rights reserved.
//  Also see the copyright page ( http://nsobject.me/copyright.rtf ).
//
//

#define LC_BLOCK(returnType, name, param) typedef returnType (^name) param

#define SELF self

/** AppDelegate */
#define LC_APPDELEGATE ((AppDelegate *)[UIApplication sharedApplication].delegate)
/* It will call self = [super init] and return self */
#define LC_SUPER_INIT(x)  \
@try { \
if(self = [super init]) \
{ \
x \
} \
else \
{ \
} \
return self; } \
@catch (NSException * exception) { \
ERROR(@"Init failed : %@",[self class]); } \
@finally { }
/** KeyWindow */
#define LC_KEYWINDOW ((UIView*)[UIApplication sharedApplication].keyWindow)
//** Device width */
#define LC_DEVICE_WIDTH  ([[UIScreen mainScreen] bounds].size.width)
/** Device height */
#define LC_DEVICE_HEIGHT (([[UIScreen mainScreen] bounds].size.height)-20) /* I reduced 20px .*/

/** Random number */
#define LC_RANDOM(from,to) ((int)(from + (arc4random() % (to - from + 1))))

/** CGRectMake */
#define LC_RECT(x,y,w,h)        CGRectMake(x,y,w,h)
#define LC_RECT_CREATE(x,y,w,h) CGRectMake(x,y,w,h)

/** CGSizeMake */
#define LC_SIZE(w,h)            CGSizeMake(w,h)
#define LC_SIZE_CREATE(w,h)     CGSizeMake(w,h)

/** CGPointMake */
#define LC_POINT(x,y)    CGPointMake(x,y)
#define LC_POINT_CREATE(x,y)    CGPointMake(x,y)

/** String with format */
#define LC_NSSTRING_FORMAT(s,...) [NSString stringWithFormat:s,##__VA_ARGS__]

/** String is invalid */
#define LC_NSSTRING_IS_INVALID(s) ( !s || s.length <= 0 || [s isEqualToString:@"(null)"] || [s isKindOfClass:[NSNull class]])

/** String from number */
#define LC_NSSTRING_FROM_NUMBER(number) [NSString stringWithFormat:@"%@",number]

/** String from int */
#define LC_NSSTRING_FROM_INT(int) [NSString stringWithFormat:@"%@",@(int)]

/** String from number */
#define LC_NSSTRING_FROM_INGERGER(number) [NSString stringWithFormat:@"%@",@(number)]

/** Create navigation. */
#if __has_feature(objc_arc)
#define LC_UINAVIGATION(viewController) [[LCUINavigationController alloc] initWithRootViewController:viewController]
#else
#define LC_UINAVIGATION(viewController) [[[LCUINavigationController alloc] initWithRootViewController:viewController] autorelease]
#endif

/** UIColor */
#define LC_RGB(R,G,B) [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:1.0f]
#define LC_RGBA(R,G,B,A)	[UIColor colorWithRed:R/255.0f green:G/255.0f blue:B/255.0f alpha:A]
#define LC_HEX_RGB(V)		[UIColor fromHexValue:V]
#define LC_HEX_RGBA(V, A)	[UIColor fromHexValue:V alpha:A]
#define LC_SHORT_RGB(V)	    [UIColor fromShortHexValue:V]


/** StretchableImageWithLeftCapWidth */
#define LC_IMAGE_STRETCHABLE(image,capWidth,capHeight) [image stretchableImageWithLeftCapWidth:capWidth topCapHeight:capHeight]


/** Fast animations */
#define LC_FAST_ANIMATIONS(duration,animationsBlock) [UIView animateWithDuration:duration animations:animationsBlock]

LC_BLOCK(void, LCAnimationsFinishedBlock, (BOOL finished));

/** Fast animations */
#define LC_FAST_ANIMATIONS_F(duration,animationsBlock,LCAnimationsFinishedBlock)                             \
[UIView animateWithDuration:duration                    \
animations:animationsBlock             \
completion:LCAnimationsFinishedBlock]

/** Fast animations */
#define LC_FAST_ANIMATIONS_O_F(duration,UIViewAnimationOptions,animationsBlock,LCAnimationsFinishedBlock)    \
[UIView animateWithDuration:duration                    \
delay:0                           \
options:UIViewAnimationOptions      \
animations:animationsBlock             \
completion:LCAnimationsFinishedBlock]


#define LC_LABEL_FIT_SIZE(label) [label.text sizeWithFont:label.font   \
constrainedToSize:CGSizeMake(label.frame.size.width, CGFLOAT_MAX)  \
lineBreakMode:label.lineBreakMode];



/** Remove from superview */
#define LC_REMOVE_FROM_SUPERVIEW(v,setToNull) if(v){[v removeFromSuperview];    \
if(setToNull == YES){             \
v = nil;                   \
}}



/** __block self */
#if __has_feature(objc_arc)
#define LC_BLOCK_SELF __weak typeof(self) nRetainSelf = self
#else
#define LC_BLOCK_SELF __block typeof(self) nRetainSelf = self
#endif

/** GCD asynchronous (异步) */
#define LC_GCD_ASYNCHRONOUS(priority,aBlock) [LCGCD dispatchAsync:priority block:aBlock]
/** GCD synchronous (同步) */
#define LC_GCD_SYNCHRONOUS(block) [LCGCD dispatchAsyncInMainQueue:block]


#define LC_TIME_CONSUMING_START mach_timebase_info_data_t lctimeinfo; uint64_t lctimestart = mach_absolute_time ();
#define LC_TIME_CONSUMING_END uint64_t lctimeend = mach_absolute_time ();  \
uint64_t lctimeelapsed = lctimeend - lctimestart; \
uint64_t lctimenanos = lctimeelapsed * lctimeinfo.numer / lctimeinfo.denom; \
ERROR(@"Time-consuming : %f s",(CGFloat)lctimenanos/NSEC_PER_SEC);

#define LC_PROPERTY(x) @property(nonatomic,x)

#define LC_FOR(i, count, x) for(NSInteger i = 0; i < count ; i++){x};

#define LC_IF_VALID(target, x) if(target){x};
#define LC_IF_INVALID(target, x) if(!target){x};


#define LC_STATIC_STRING_SET(_name) static NSString * const _name = @#_name

#ifdef __IPHONE_6_0

#define UILineBreakMode NSLineBreakMode
#define UILineBreakModeWordWrap			NSLineBreakByWordWrapping
#define UILineBreakModeCharacterWrap	NSLineBreakByCharWrapping
#define UILineBreakModeClip				NSLineBreakByClipping
#define UILineBreakModeHeadTruncation	NSLineBreakByTruncatingHead
#define UILineBreakModeTailTruncation	NSLineBreakByTruncatingTail
#define UILineBreakModeMiddleTruncation	NSLineBreakByTruncatingMiddle

#define UITextAlignment NSTextAlignment
#define UITextAlignmentLeft				NSTextAlignmentLeft
#define UITextAlignmentCenter			NSTextAlignmentCenter
#define UITextAlignmentRight			NSTextAlignmentRight

#endif

#ifndef	weakly
#if __has_feature(objc_arc)
#define weakly( x )	autoreleasepool{} __weak __typeof__(x) __weak_##x##__ = x;
#else	// #if __has_feature(objc_arc)
#define weakly( x )	autoreleasepool{} __block __typeof__(x) __block_##x##__ = x;
#endif	// #if __has_feature(objc_arc)
#endif	// #ifndef	weakify

#ifndef	normally
#if __has_feature(objc_arc)
#define normally( x )	try{} @finally{} __typeof__(x) x = __weak_##x##__;
#else	// #if __has_feature(objc_arc)
#define normally( x )	try{} @finally{} __typeof__(x) x = __block_##x##__;
#endif	// #if __has_feature(objc_arc)
#endif	// #ifndef	@normalize

#if __has_feature(objc_arc)

#define LC_PROP_RETAIN strong
#define LC_RETAIN(x) (x)
#define LC_RELEASE(x)
#define LC_AUTORELEASE(x) (x)
#define LC_BLOCK_COPY(x) (x)
#define LC_BLOCK_RELEASE(x)
#define LC_SUPER_DEALLOC()
#define LC_AUTORELEASE_POOL_START() @autoreleasepool {
#define LC_AUTORELEASE_POOL_END() }

#else

#define LC_PROP_RETAIN retain
#define LC_RETAIN(x) ([(x) retain])
#define LC_RELEASE(x) ([(x) release])
#define LC_RELEASE_ABSOLUTE(x) if(x){[x release]; x = nil;}

#define LC_AUTORELEASE(x) ([(x) autorelease])
#define LC_SUPER_DEALLOC() ([super dealloc])
#define LC_AUTORELEASE_POOL_START() NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
#define LC_AUTORELEASE_POOL_END() [pool release];

#endif

#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1
#define kCGImageAlphaPremultipliedLast  (kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast)
#else
#define kCGImageAlphaPremultipliedLast  kCGImageAlphaPremultipliedLast
#endif

#define LC_OVERWRITE_GETTER()

#define LC_ST_PROPERTY( __name ) \
- (NSString *)__name; \
+ (NSString *)__name;

#define LC_IMP_PROPERTY( __name ) \
- (NSString *)__name \
{ \
return (NSString *)[[self class] __name]; \
} \
+ (NSString *)__name \
{ \
return [NSString stringWithFormat:@"%s", #__name]; \
}





#define LC_CATEGORY_PROPERTY(__class, __name) \
\
@interface __class (LCCategory$##__name) \
\
- (NSString *)__name; \
+ (NSString *)__name; \
\
@end \
\
@implementation __class (LCCategory$##__name) \
\
- (NSString *)__name \
{ \
    return (NSString *)[[self class] __name]; \
} \
+ (NSString *)__name \
{ \
    return [NSString stringWithFormat:@"%s", #__name]; \
} \
\
@end \

