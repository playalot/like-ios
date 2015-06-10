//
//  NSString+LCExtension.h
//  LCFramework

//  Created by Licheng Guo . ( SUGGESTIONS & BUG titm@tom.com ) on 13-9-16.
//  Copyright (c) 2014年 Licheng Guo iOS developer ( http://nsobject.me ).All rights reserved.
//  Also see the copyright page ( http://nsobject.me/copyright.rtf ).
//
//

#pragma mark -

LC_BLOCK(NSString *, NSStringAppendBlock, (id format, ...));
LC_BLOCK(NSString *, NSStringReplaceBlock, (NSString * string, NSString * string2));
LC_BLOCK(BOOL, NSStringEqualBlock, (NSString * string));
LC_BLOCK(BOOL, NSStringValidBlock, ());

LC_BLOCK(NSMutableString *, NSMutableStringAppendBlock, (id format, ...));
LC_BLOCK(NSMutableString *, NSMutableStringReplaceBlock, (NSString * string, NSString * string2));

#pragma mark -

@interface NSString (LCExtension)

LC_PROPERTY(readonly) NSStringAppendBlock		APPEND;
LC_PROPERTY(readonly) NSStringAppendBlock		LINE;
LC_PROPERTY(readonly) NSStringReplaceBlock	REPLACE;
LC_PROPERTY(readonly) NSStringEqualBlock	    EQUAL;
LC_PROPERTY(readonly) NSStringValidBlock	    VALID;

LC_PROPERTY(readonly) NSData * data;

LC_PROPERTY(readonly) NSString * MD5;
LC_PROPERTY(readonly) NSData * MD5Data;

LC_PROPERTY(readonly) NSString * SHA1;


+ (NSString *) UUID;

+ (NSString *)stringWithBytes:(unsigned long long)bytes;

- (NSArray *)allURLs;

- (NSString *)urlByAppendingDict:(NSDictionary *)params;
- (NSString *)urlByAppendingArray:(NSArray *)params;
- (NSString *)urlByAppendingKeyValues:(id)first, ...;

+ (NSString *)queryStringFromDictionary:(NSDictionary *)dict;
+ (NSString *)queryStringFromArray:(NSArray *)array;
+ (NSString *)queryStringFromKeyValues:(id)first, ...;

- (NSString *)URLEncoding;
- (NSString *)URLDecoding;

- (NSString *)trim;
- (NSString *)unwrap;

- (BOOL)match:(NSString *)expression;
- (BOOL)matchAnyOf:(NSArray *)array;

- (BOOL)empty;
- (BOOL)notEmpty;

- (BOOL)is:(NSString *)other;
- (BOOL)isNot:(NSString *)other;

- (BOOL)isValueOf:(NSArray *)array;
- (BOOL)isValueOf:(NSArray *)array caseInsens:(BOOL)caseInsens;

- (BOOL)isTelephone;
- (BOOL)isUserName;
- (BOOL)isPassword;
- (BOOL)isEmail;
- (BOOL)isUrl;

- (void) doNothing;

-(NSString *) stringByAppendingString:(NSString *)string;

#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
- (CGSize)sizeWithFont:(UIFont *)font byWidth:(CGFloat)width;
- (CGSize)sizeWithFont:(UIFont *)font byHeight:(CGFloat)height;
- (CGFloat)widthWithFont:(UIFont *)font byHeight:(CGFloat)height;
- (CGFloat)heightWithFont:(UIFont *)font byWidth:(CGFloat)width;

#endif	// #if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)

@end

#pragma mark -

@interface NSMutableString(LCExtension)

@property (nonatomic, readonly) NSMutableStringAppendBlock	APPEND;
@property (nonatomic, readonly) NSMutableStringAppendBlock	LINE;
@property (nonatomic, readonly) NSMutableStringReplaceBlock	REPLACE;

@end

