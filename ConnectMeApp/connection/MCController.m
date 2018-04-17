//
//  MCController.m
//
//  Created by punit on 28/05/15.
//  Copyright (c) 2015 Parnit. All rights reserved.
//

#import "MCController.h"

@interface MCController()


@end

@implementation MCController

#define kDefaultChannel 1
#define kMinChannel 1
#define kMaxChannel 6

NSInteger channel;
BOOL isConnecting;

#define CHALog(...) NSLog(__VA_ARGS__)
//#define CHALog(...)

MCController* sharedChannelController;

+(MCController*)sharedChannelController
{
    if(!sharedChannelController)
    {
        sharedChannelController = [[MCController alloc] init];
        //Setup connection
        sharedChannelController.connection = [[MCConnection alloc] initWithChannel:sharedChannelController.currentChannel];
    }
    
    return sharedChannelController;
}

-(id)init{
    self = [super init];
    
    if(self)
    {
        channel = kDefaultChannel;
    }
    
    return self;
}

//Pass delegate
-(void)setConnectionDelegate:(NSObject<MCConnectionDelegate>*)connectionDelegate{
    [sharedChannelController.connection setDelegate:connectionDelegate];
    
}

#pragma mark - channels
-(NSInteger)currentChannel
{
    return channel;
}

-(void)setCurrentChannel:(NSInteger)newChannel
{
    if(newChannel >= kMinChannel && newChannel <= kMaxChannel)
    {
        CHALog(@"MCController: change channel: %li", (long)newChannel);
        
        channel = newChannel;
        
        //Disconnect channel connection
        [_connection disconnect];
        
        //Hold ref to delegate
        NSObject<MCConnectionDelegate>* connectionDelegate = _connection.delegate;
        
        //Destroy
        _connection = nil;
        
        //Recreate
        _connection = [[MCConnection alloc] initWithChannel:channel];
        [_connection setDelegate:connectionDelegate];
        
        //Connect
        [_connection connect];
    }
}


#pragma mark - connection
-(void)connect
{
    CHALog(@"MCController: CONNECT");
    [_connection connect];
    
}
-(void)disconnect
{
    CHALog(@"MCController: DISCONNECT");
    [_connection disconnect];
}

-(void)sendMessageToAll:(NSString*)morse
{
    [_connection sendMessageToAll:morse];
}



@end
