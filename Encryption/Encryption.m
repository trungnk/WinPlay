//
//  Encryption.m
//  GoVN
//

#import "Encryption.h"

@implementation Encryption

@synthesize username;
@synthesize password;
@synthesize passMd5;
@synthesize timeMd5;
@synthesize datasign;
@synthesize account;
@synthesize accountInfor;
@synthesize datasignData;
@synthesize requestData;

-(id)init {
	if(self = [super init]){
		username = @"";
		password = @"";
		passMd5 = @"";
		timeMd5 = @"";
		datasign = @"";
		datasignData = @"";
		account = @"";
		accountInfor = @"";
		key = @"";
	}
	return self;
}

//dealloc
-(void)dealloc {
	[username release];
	[password release];
	[datasign release];
	[accountInfor release];
	[super dealloc];
}

-(void)encrytion:(NSString *)userName AndPassword:(NSString *)pass{
	username = [[NSString alloc] initWithString:userName];
	password = [[NSString alloc] initWithString:pass];
	
	// encryption password
	passMd5 = [[self md5:(password != nil)?password:@""] lowercaseString];
	
	// encryption time
	NSDate *date = [NSDate date];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"dd mm:hh:ss ms"];
	
	timeMd5 = [[self md5:[dateFormatter stringFromDate:date]] lowercaseString];
	[dateFormatter release];
    
	//
	NSMutableString *tmpStr = [[NSMutableString alloc] init];
	[tmpStr appendString:username];
	[tmpStr appendString:passMd5];
	[tmpStr appendString:timeMd5];
	[tmpStr appendString:@"abc123"];
	
	// encryption 
	NSString *md5 = [[self md5:tmpStr] lowercaseString];
    [tmpStr release];
	datasign = [[NSString alloc] initWithString:[[self SHA1:md5] lowercaseString]];
}

-(void)trippleDes:(NSString *)userName AndPassword:(NSString *)pasw{
	username = [[NSString alloc] initWithString:userName];
	password = [[NSString alloc] initWithString:pasw];
	
	// encryption password
	passMd5 = [[self md5:(password != nil)?password:@""] lowercaseString];
	
	NSMutableString *info = [[NSMutableString alloc] init];
	[info appendString:username];
	[info appendString:@" "];
	[info appendString:passMd5];
	
	// encryption 
	datasign = [[NSString alloc] initWithString:[self SHA1:[info lowercaseString]]];
	key = [[datasign substringToIndex:24] lowercaseString];
	accountInfor = [[NSString alloc] initWithString:[self doCipher:[info lowercaseString] action:kCCEncrypt]];
	//NSLog(@"key : %@\n datasign :%@\n requestData : %@ \n accountInfor : %@ ", key, datasign, info, accountInfor);
}

-(void)trippleDes:(NSString *)requestdata{	
	// encryption 
	datasignData = [[[NSString alloc] initWithString:[self SHA1:requestdata]] lowercaseString];
	key = [datasignData substringToIndex:24];
	requestData = [[NSString alloc] initWithString:[self doCipher:requestdata action:kCCEncrypt]];
	//NSLog(@"key : %@\n datasignData :%@\n requestData : %@ \n requestData : %@ ", key, datasignData, requestdata, requestData);
}

// Function encryption
-(NSString *)md5:(NSString *)str{
	
	const char *cStr = [str UTF8String];
	
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	
	CC_MD5( cStr, strlen(cStr), result );
	
	return [NSString stringWithFormat: @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
			
			result[0], result[1],
			
			result[2], result[3],
			
			result[4], result[5],
			
			result[6], result[7],
			
			result[8], result[9],
			
			result[10], result[11],
			
			result[12], result[13],
			
			result[14], result[15]
			
			];
	
}

-(NSString *)SHA1:(NSString *)str {
	
	const char *cStr = [str UTF8String];
	
	unsigned char returnBuffer[CC_SHA1_DIGEST_LENGTH];
	
	CC_SHA1( cStr, strlen(cStr), returnBuffer );
	
	return [NSString stringWithFormat: @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
			
			returnBuffer[0], returnBuffer[1],
			
			returnBuffer[2], returnBuffer[3],
			
			returnBuffer[4], returnBuffer[5],
			
			returnBuffer[6], returnBuffer[7],
			
			returnBuffer[8], returnBuffer[9],
			
			returnBuffer[10], returnBuffer[11],
			
			returnBuffer[12], returnBuffer[13],
			
			returnBuffer[14], returnBuffer[15],
			
			returnBuffer[16], returnBuffer[17],
			
			returnBuffer[18], returnBuffer[19]
			];
}

// 3Des
-(NSString*)doCipher:(NSString*)plainText action:(CCOperation)encryptOrDecrypt { 
	const void *vplainText;
	size_t plainTextBufferSize;
	
	if (encryptOrDecrypt == kCCDecrypt) {
		NSData *EncryptData = [NSData dataWithBase64EncodedString:plainText];
		plainTextBufferSize = [EncryptData length];
		vplainText = [EncryptData bytes];
	}
	else {
		NSData *plainTextData = [plainText dataUsingEncoding: NSUTF8StringEncoding]; 
		plainTextBufferSize = [plainTextData length]; 
		vplainText = [plainTextData bytes];
	}
	
	CCCryptorStatus ccStatus;
	uint8_t *bufferPtr = NULL;
	size_t bufferPtrSize = 0;
	size_t movedBytes = 0;
	// uint8_t ivkCCBlockSize3DES;
	
	bufferPtrSize = (plainTextBufferSize + kCCBlockSize3DES) & ~(kCCBlockSize3DES - 1);
	bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t));
	memset((void *)bufferPtr, 0x0, bufferPtrSize);
	// memset((void *) iv, 0x0, (size_t) sizeof(iv));
	
	//NSString *key = @"123456789012345678901234";
	//NSString *initVec = @"init Vec";
	const void *vkey = (const void *)[key UTF8String];
	//const void *vinitVec = (const void *)[initVec UTF8String];
	
	ccStatus = CCCrypt(encryptOrDecrypt,
					   kCCAlgorithm3DES,
					   kCCOptionPKCS7Padding | kCCOptionECBMode,
					   vkey, 
					   kCCKeySize3DES,
					   nil,  //iv,
					   vplainText, //"Your Name", //plainText,
					   plainTextBufferSize,
					   (void *)bufferPtr,
					   bufferPtrSize,
					   &movedBytes);
	
	if (ccStatus == kCCSuccess);// NSLog(@"SUCCESS");
	else if (ccStatus == kCCParamError) return @"PARAM ERROR";
	else if (ccStatus == kCCBufferTooSmall) return @"BUFFER TOO SMALL";
	else if (ccStatus == kCCMemoryFailure) return @"MEMORY FAILURE";
	else if (ccStatus == kCCAlignmentError) return @"ALIGNMENT";
	else if (ccStatus == kCCDecodeError) return @"DECODE ERROR";
	else if (ccStatus == kCCUnimplemented) return @"UNIMPLEMENTED";
	
	NSString *result;
	
	if (encryptOrDecrypt == kCCDecrypt) {
		result = [[[NSString alloc] initWithData:[NSData dataWithBytes:(const void *)bufferPtr length:(NSUInteger)movedBytes] encoding:NSASCIIStringEncoding] autorelease];
	}
	else {
		NSData *myData = [NSData dataWithBytes:(const void *)bufferPtr length:(NSUInteger)movedBytes];
		result = [myData base64Encoding];
	}
	
	return result; 
}

@end
