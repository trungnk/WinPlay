//
//  Encryption.h
//  GoVN
//
//  Created by NGUYENTHIET on 5/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import "NSData-Base64.h"

@interface Encryption : NSObject {
	NSString *username;
	NSString *password;
	NSString *passMd5;
	NSString *timeMd5;
	NSString *datasign;
	NSString *account;
	NSString *accountInfor;
	NSString *key;
	NSString *datasignData;
	NSString *requestData;
}
@property(retain) NSString *username;
@property(retain) NSString *password;
@property(retain) NSString *passMd5;
@property(retain) NSString *timeMd5;
@property(retain) NSString *datasign;
@property(retain) NSString *account;
@property(retain) NSString *accountInfor;
@property(retain) NSString *datasignData;
@property(retain) NSString *requestData;

-(void)encrytion:(NSString *)userName AndPassword:(NSString *)password;
-(void)trippleDes:(NSString *)accountStr AndPassword:(NSString *)password;
-(void)trippleDes:(NSString *)requestData;
-(NSString *)md5:(NSString *)str;
-(NSString *)SHA1:(NSString *)str;
-(NSString*)doCipher:(NSString*)plainText action:(CCOperation)encryptOrDecrypt;

@end
