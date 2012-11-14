//
//  Socket.h
//  TNTT
//
//  Created by Crazy on 19/06/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SocketDelegate;

@interface Socket : NSObject<NSStreamDelegate> {
	NSInputStream *inStream;
	NSOutputStream *outStream;
	
	id<SocketDelegate>delegate;	
	NSString *stService;
	NSUserDefaults *prefs;
}

@property(assign) id<SocketDelegate>delegate;

-(void)initNetworkCommunication;
-(void)freeUp;
-(void)connectWithService:(NSString *)service 
				   param1:(NSString *)param1 
				   param2:(NSString *)param2 
				   param3:(NSString *)param3;

@end

@protocol SocketDelegate<NSObject>
@optional
-(void)result:(int)success messages:(NSString *)messages;
@end
