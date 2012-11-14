//
//  Socket.m
//  TNTT
//
//  Created by Crazy on 19/06/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Socket.h"
#import "AppDelegate.h"

#import "Encryption.h"

#define kBufferSize			3000

#define AUTHEN				@"Authentication"
#define TOP_PETS			@"GetCurrentTopPets"
#define SESSION_DATA		@"GetCurrentSessionsData"
#define BET_ACCOUNT			@"GetBetOfAccount"
#define SET_BET				@"SetBet"
#define	ROOM_SESSION		@"GetRoomsInGameSession"
#define	ROOM_SESSION2		@"GetRoomsInGameSession2"
#define	BET_ROOM			@"BetInRoom"
#define RESULT_ROOM         @"GetResultInRoom"
#define VCOIN               @"GetVCoin"
#define BET_AWARDS          @"GetBetAwards"
#define ROOM_HISTORY        @"GetRoomHistory"
#define INPUT_CARD          @"PartnerInputCard"
#define GET_APPS            @"GetApps"
#define APP_DETAIL          @"GetAppDetail"
#define SMS_ODP             @"GetSmsODP"

@implementation Socket

@synthesize delegate;


-(id)init
{
	if(self = [super init])
    {
		[self initNetworkCommunication];
		stService = @"";
        prefs = [NSUserDefaults standardUserDefaults];
	}
	return self;
}

//
static int offset = 0;
static int offIndex = 0;
static int size = 0;
static int remain = 0;

-(void)connectWithService:(NSString *)service 
				   param1:(NSString *)param1 
				   param2:(NSString *)param2 
				   param3:(NSString *)param3
{
    @try {
        NSMutableData *bufferData = [[NSMutableData alloc] init];
        NSMutableString *str = [[NSMutableString alloc] init];
            
        [str appendString:@"w1"];
        
        Encryption *encrytion = [[Encryption alloc] init];
        [str appendString:[encrytion md5:[NSString stringWithFormat:@"%@%@", @"w1", [encrytion md5:@"123"]]]];
        
        
        int dataLength = [str length];
        dataLength = CFSwapInt32HostToBig(dataLength);
        
        [bufferData appendBytes:&dataLength length:sizeof(int)];
        NSData *writeData = [str dataUsingEncoding:NSUTF8StringEncoding];
        [bufferData appendData:writeData];
        
        int sendLength = [bufferData length];
        int written = [outStream write:[bufferData bytes] maxLength:sendLength];        
        
        [bufferData release];
        [str release];
        
        if (written == -1 || written != sendLength)
        {

        }
    }
    @catch (NSException *exception){
    }
    @finally{
        
    }
}

-(void)initNetworkCommunication
{
	CFReadStreamRef readStream;
	CFWriteStreamRef writeStream;
	
	// CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)@"117.103.198.174", 41357, &readStream, &writeStream);
    CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)@"210.211.99.81", 1369, &readStream, &writeStream);
	
    CFReadStreamSetProperty(readStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
    CFWriteStreamSetProperty(writeStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
    
	inStream = (NSInputStream *)readStream;
	outStream = (NSOutputStream *)writeStream;
	
    [inStream retain];
    [inStream retain];
    
	[inStream setDelegate:self];
	[outStream setDelegate:self];
	
	[inStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[outStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	
	if ([inStream streamStatus] == NSStreamStatusNotOpen) 
		[inStream open]; 
	
	if ([outStream streamStatus] == NSStreamStatusNotOpen) 
		[outStream open];	
}

-(void)freeUp
{
	[inStream close]; 
	[inStream removeFromRunLoop:[NSRunLoop currentRunLoop]
						forMode:NSDefaultRunLoopMode];
	inStream.delegate = nil; 
	[inStream release]; 
	
	[outStream close]; 
	[outStream removeFromRunLoop:[NSRunLoop currentRunLoop]
						 forMode:NSDefaultRunLoopMode];
	outStream.delegate = nil; 
	[outStream release];
}

-(void)dealloc
{
	[self freeUp];	
	[super dealloc];
}

- (void) stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode
{
    switch(eventCode)
    {
        case NSStreamEventOpenCompleted:
			// ready ?
			break; 
			
		case NSStreamEventHasBytesAvailable:
            if (stream == inStream)
            {
                NSMutableData *data = [[NSMutableData alloc] init];
                if ([inStream hasBytesAvailable])
                {
                    uint8_t buffer[kBufferSize];
					int bytesRead = [inStream read:(buffer + offset) maxLength:kBufferSize];
                    [data appendBytes:buffer length:bytesRead];
                    NSString *respond = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    NSLog(@"%@", respond);
                }
                [data release];
            }     
            break;
			
		case NSStreamEventErrorOccurred:
            [stream close];
            [stream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            

			break;
			
        case NSStreamEventHasSpaceAvailable: 
            if (stream == outStream)
            {                

            } 
            break; 
						
        case NSStreamEventEndEncountered: 
			[stream close];
            [stream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            [stream release];
            stream = nil;
            break;
            
        case NSStreamEventNone:
            if([delegate respondsToSelector:@selector(result:messages:)])
                [delegate result:0 messages:@"Không thể kết nối tới máy chủ TNTT!"];
            break;
			
        default: 
            break; 
    } 
}

@end
