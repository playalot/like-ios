//
// Copyright (c) 2011 Five-technology Co.,Ltd.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "LCEncryptorAES.h"
#import "LCJSONUtility.h"

@implementation LCEncryptorAES

#pragma mark -
#pragma mark Initialization and deallcation


#pragma mark -
#pragma mark Praivate


#pragma mark -
#pragma mark API

+ (NSData*)generateIv
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        srand((unsigned)time(NULL));
    });
    
    char cIv[FBENCRYPT_BLOCK_SIZE];
    for (int i=0; i < FBENCRYPT_BLOCK_SIZE; i++) {
        cIv[i] = rand() % 256;
    }
    return [NSData dataWithBytes:cIv length:FBENCRYPT_BLOCK_SIZE];
}

+ (NSData*)encryptData:(NSData*)data key:(NSData*)key iv:(NSData*)iv;
{
    NSData* result = nil;

    // setup key
    unsigned char cKey[FBENCRYPT_KEY_SIZE];
	bzero(cKey, sizeof(cKey));
    [key getBytes:cKey length:FBENCRYPT_KEY_SIZE];
	
    // setup iv
    char cIv[FBENCRYPT_BLOCK_SIZE];
    bzero(cIv, FBENCRYPT_BLOCK_SIZE);
    if (iv) {
        [iv getBytes:cIv length:FBENCRYPT_BLOCK_SIZE];
    }
    
    // setup output buffer
	size_t bufferSize = [data length] + FBENCRYPT_BLOCK_SIZE;
	void *buffer = malloc(bufferSize);

    // do encrypt
	size_t encryptedSize = 0;
	CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          FBENCRYPT_ALGORITHM,
                                          kCCOptionPKCS7Padding,
                                          cKey,
                                          FBENCRYPT_KEY_SIZE,
                                          cIv,
                                          [data bytes],
                                          [data length],
                                          buffer,
                                          bufferSize,
										  &encryptedSize);
	if (cryptStatus == kCCSuccess) {
		result = [NSData dataWithBytesNoCopy:buffer length:encryptedSize];
	} else {
        free(buffer);
        LCLog(@"[ERROR] failed to encrypt|CCCryptoStatus: %d", cryptStatus);
    }
	
	return result;
}

+ (NSData*)decryptData:(NSData*)data key:(NSData*)key iv:(NSData*)iv;
{
    NSData* result = nil;

    // setup key
    unsigned char cKey[FBENCRYPT_KEY_SIZE];
	bzero(cKey, sizeof(cKey));
    [key getBytes:cKey length:FBENCRYPT_KEY_SIZE];

    // setup iv
    char cIv[FBENCRYPT_BLOCK_SIZE];
    bzero(cIv, FBENCRYPT_BLOCK_SIZE);
    if (iv) {
        [iv getBytes:cIv length:FBENCRYPT_BLOCK_SIZE];
    }
    
    // setup output buffer
	size_t bufferSize = [data length] + FBENCRYPT_BLOCK_SIZE;
	void *buffer = malloc(bufferSize);
	
    // do decrypt
	size_t decryptedSize = 0;
	CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          FBENCRYPT_ALGORITHM,
                                          kCCOptionPKCS7Padding,
										  cKey,
                                          FBENCRYPT_KEY_SIZE,
                                          cIv,
                                          [data bytes],
                                          [data length],
                                          buffer,
                                          bufferSize,
                                          &decryptedSize);
	
	if (cryptStatus == kCCSuccess) {
		result = [NSData dataWithBytesNoCopy:buffer length:decryptedSize];
	} else {
        free(buffer);
        LCLog(@"[ERROR] failed to decrypt| CCCryptoStatus: %d", cryptStatus);
    }

	return result;
}

+ (NSData*)encryptString:(NSString *)dataStr keyString:(NSString *)keyStr ivString:(NSString *)ivStr {
    NSData* data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
    NSData* key = [keyStr dataUsingEncoding:NSUTF8StringEncoding];
    NSData* iv = [ivStr dataUsingEncoding:NSUTF8StringEncoding];
    return [LCEncryptorAES encryptData:data key:key iv:iv];
}

+ (NSString*)decryptData:(NSData *)data keyString:(NSString *)keyStr ivString:(NSString *)ivStr {
    NSData* key = [keyStr dataUsingEncoding:NSUTF8StringEncoding];
    NSData* iv = [ivStr dataUsingEncoding:NSUTF8StringEncoding];
    NSData* decrpytedData = [LCEncryptorAES decryptData:data key:key iv:iv];
    return [[NSString alloc] initWithData:decrpytedData encoding:NSUTF8StringEncoding];
}

+ (NSData *)encryptDataFromObject:(id)dataDic keyString:(NSString *)keyStr ivString:(NSString *)ivStr {
    NSString *dataStr = [LCJSONUtility stringFromJSONObject:dataDic];
    return [LCEncryptorAES encryptString:dataStr keyString:keyStr ivString:ivStr];
}

+ (id)decryptObjectFromData:(NSData *)data keyString:(NSString *)keyStr ivString:(NSString *)ivStr {
    NSString *dataStr = [LCEncryptorAES decryptData:data keyString:keyStr ivString:ivStr];
    return [LCJSONUtility objectFromJSONString:dataStr];
}

@end
