//
//  MCController.m


#import "MCConnection.h"
#import "AppDelegate.h"

using namespace std;

@interface MCConnection() <MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate, MCSessionDelegate>

@end

@implementation MCConnection

#define kMCServiceName @"find-neighbour"

#define kMCChannelNumber @"channel"


#define kMessageText @"MessageText"
#define kDeviceId @"DeviceID"

#define kMCFreq @"freq"

#define kRetryTime 10

BOOL isAdvertising = NO;
BOOL isBrowsing = NO;

-(id)initWithChannel:(NSInteger)channel{
    
    self = [super init];
    
    if(self)
    {
        //Get Peer ID
        MCPeerID *peerID = [self newPeerID];
        
        //Get Advertiser
        _advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:peerID discoveryInfo:@{kMCChannelNumber:[NSString stringWithFormat:@"%li", (long)channel]} serviceType:kMCServiceName];
        [_advertiser setDelegate:self];
        
        //Get Browser
        _browser = [[MCNearbyServiceBrowser alloc] initWithPeer:peerID serviceType:kMCServiceName];
        [_browser setDelegate:self];
        
        //Create session
        _sessionAdvertise = [[MCSession alloc] initWithPeer:peerID];
        [_sessionAdvertise setDelegate:self];
        
        _sessionBrowse = [[MCSession alloc] initWithPeer:peerID];
        [_sessionBrowse setDelegate:self];
        
        //Now advertise and browse
        isAdvertising = YES;
        [_advertiser startAdvertisingPeer];
        
        isBrowsing = YES;
        [_browser startBrowsingForPeers];
    }
    
    return self;
}

-(MCPeerID*)newPeerID{
    NSString *deviceName = [UIDevice currentDevice].name;
    
    //Replace deviceName if it's not valid for use
    if (!deviceName || deviceName.length <= 0) deviceName = [UIDevice currentDevice].model;
    else
    {
        const char* deviceNameStr = [deviceName UTF8String];
        if( sizeof(deviceNameStr) > 63)
        {
            deviceName = [UIDevice currentDevice].model;
        }
    }
  NSLog(@"Peer id is %@",deviceName);
    
    return [[MCPeerID alloc] initWithDisplayName:deviceName];
}

-(void)cancelDelayedSelectors{
    
    if(_advertiser) [NSObject cancelPreviousPerformRequestsWithTarget:_advertiser selector:@selector(startAdvertisingPeer) object:nil];
    
    if(_browser) [NSObject cancelPreviousPerformRequestsWithTarget:_browser selector:@selector(startBrowsingForPeers) object:nil];
}

#pragma mark - connection
-(void)connect
{
    NSLog(@"+ MCConnection: connect");
    [self cancelDelayedSelectors];
    
    if (_advertiser && !isAdvertising)
    {
        NSLog(@"MCConnection: connect adv");
        isAdvertising = YES;
        [_advertiser startAdvertisingPeer];
    }
    
    if(_browser && !isBrowsing)
    {
        NSLog(@"MCConnection: connect browse");
        isBrowsing = YES;
        [_browser startBrowsingForPeers];
    }
    
    if(_delegate && [_delegate respondsToSelector:@selector(startingToSearch)])
    {
        [_delegate startingToSearch];
    }
}

-(void)disconnect
{
    NSLog(@"+ MCConnection: disconnect");
    [self cancelDelayedSelectors];
    
    if(_advertiser && isAdvertising)
    {
        NSLog(@"MCConnection: disconnect adv");
        isAdvertising = NO;
        [_advertiser stopAdvertisingPeer];
    }
    
    if(_browser && isBrowsing)
    {
        NSLog(@"MCConnection: disconnect browse");
        isBrowsing = NO;
        [_browser stopBrowsingForPeers];
    }
}

#pragma mark - advertiser

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void(^)(BOOL accept, MCSession *session))invitationHandler
{
    NSLog(@"MCConnection: Advertiser got invite from: %@", peerID.displayName);
    
    //Refuse if they should be the client
    NSLog(@"Adv PEER-ID: %li , THIS PEER: %li", (long)peerID.hash, (long)_advertiser.myPeerID.hash);
    
/*    //Refuse if they should be the server
    if(peerID.hash <= advertiser.myPeerID.hash)
    {
        NSLog(@"MCConnection: adv - Peer should be server - no connect: %@", peerID.displayName);
        invitationHandler(NO, nil);
//        [_browser invitePeer:peerID toSession:_sessionBrowse withContext:nil timeout:0];
        return;
    }
 */   
    //Pass session for them to connect to
    NSLog(@"MCConnection: adv - Allowing peer to connect: %@", peerID.displayName);
    NSLog(@"Peer connect request a");
    invitationHandler(YES, _sessionAdvertise);
}

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error
{
    NSLog(@"MCConnection: adv - Error advertising peer: %@", error.localizedDescription);
    
    isAdvertising = NO;
    
    //Attempt to start advertising again later
    [NSObject cancelPreviousPerformRequestsWithTarget:_advertiser selector:@selector(startAdvertisingPeer) object:nil];
    [_advertiser performSelector:@selector(startAdvertisingPeer) withObject:nil afterDelay:kRetryTime];
}

#pragma mark - browser

// Found a nearby advertising peer
- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info
{
    if(_advertiser && _advertiser.discoveryInfo && [_advertiser.discoveryInfo objectForKey:kMCChannelNumber])
    {
        NSString *channelStr = [_advertiser.discoveryInfo objectForKey:kMCChannelNumber];
        
        if(channelStr.length > 0)
        {
            //Check for channel
            if(info && [info objectForKey:kMCChannelNumber])
            {
                NSString* peerChannelStr = [info objectForKey:kMCChannelNumber];
                
                if([peerChannelStr isEqualToString:channelStr])
                {
                    NSLog(@"MCConnection: browser - Found peer '%@' on channel '%@'", peerID.displayName, peerChannelStr);
                    
                    //Refuse if they should be the client
                    NSLog(@"BR PEER-ID: %li , THIS PEER: %li", (long)peerID.hash, (long)_advertiser.myPeerID.hash);
                    
                    if(peerID.hash > _advertiser.myPeerID.hash)
                    {
                        NSLog(@"MCConnection: browser - Peer should be client - no connect: %@", peerID.displayName);
                        
//                        if(![_sessionAdvertise.connectedPeers containsObject:peerID])
//                        {
//                            [_advertiser stopAdvertisingPeer];
//                            [_advertiser startAdvertisingPeer];
//                        }
//                        return;
                    }
                    
                    //Connect - max 30 seconds timeout by default - no context needed
                    NSLog(@"Peer connect request b");
                    NSLog(@"Inviting peer to connect: %@", peerID.displayName);
                  if(_delegate && [_delegate respondsToSelector:@selector(foundNewPeer::)])
                  {
                    [_delegate foundNewPeer:peerID.displayName :peerID.hash];
                  }
                  
                    [browser invitePeer:peerID toSession:_sessionBrowse withContext:nil timeout:0];
                }
                else
                {
                    NSLog(@"MCConnection: browser - Ignoring peer '%@' on channel '%@'", peerID.displayName, peerChannelStr);
                }
            }
            else
            {
                NSLog(@"MCConnection: browser - Error peer channel is nil");
            }
        }
        else
        {
            NSLog(@"MCConnection: browser - Error adv channel is nil");
        }
    }
    else
    {
        NSLog(@"MCConnection: browser - Error getting channel from adv.");
    }
}

// A nearby peer has stopped advertising
- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID
{
    //Do nothing - no change to UI
    NSLog(@"MCConnection: browser lost peer: %@", peerID.displayName);
}

// Browsing did not start due to an error
- (void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error
{
    NSLog(@"MCConnection: Error browsing for peers: %@", error.localizedDescription);
    
    isBrowsing = NO;
    
    //start browsing after delay
    [NSObject cancelPreviousPerformRequestsWithTarget:_browser selector:@selector(startBrowsingForPeers) object:nil];
    [_browser performSelector:@selector(startBrowsingForPeers) withObject:nil afterDelay:kRetryTime];
}

#pragma mark - session

// Remote peer changed state
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    if(session == _sessionBrowse)NSLog(@"Browse session: state");
    else NSLog(@"Adv session: state");
    
    switch (state) {
        case MCSessionStateConnected:
        {
             NSLog(@"MCConnection: Peer connected: %@", peerID.displayName);
            NSLog(@"Peer connected");
            
            //Inform UI of connection
            if(_delegate && [_delegate respondsToSelector:@selector(connectedToUserWithID:)])
            {
                [_delegate connectedToUserWithID:peerID.hash];
            }
        }
            break;
        case MCSessionStateConnecting:
        {
            //Do nothing in this state
            NSLog(@"MCConnection: Peer connecting: %@", peerID.displayName);
        }
            break;
        case MCSessionStateNotConnected:
        {
            
            NSLog(@"MCConnection: Peer disconnected: %@", peerID.displayName);
            
            //Inform UI of connection
            if(_delegate && [_delegate respondsToSelector:@selector(disconnectedFromUserWithID:)])
            {
                [_delegate disconnectedFromUserWithID:peerID.hash];
            }
        }
            break;
            
        default:
            break;
    }
}

// Received data from remote peer - pass to UI
- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    NSLog(@"**** Message received! ****");
    
    if(session == _sessionBrowse)NSLog(@"Browse session: received data");
    else NSLog(@"Adv session: received data");
    
    if(data && data.length > 0)
    {
        NSDictionary* dict = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        
        if([dict objectForKey:kMessageText])
        {
            NSString *morse = [dict objectForKey:kMessageText];
            NSString *deviceName = [dict objectForKey:kDeviceId];
          
            if(_delegate && [_delegate respondsToSelector:@selector(userWithID:didReceiveMessage:withName:)])
            {
              [_delegate userWithID:peerID.hash didReceiveMessage:morse withName:deviceName];

            }
        }
    }
}


/* UNUSED! */
- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID
{
    NSLog(@"MCConnection: Error - peer sending stream!");
}
- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{
    NSLog(@"MCConnection: Error - peer sending resource!");
  
  
  NSDictionary *dict = @{@"resourceName"  :   resourceName,
                         @"peerID"        :   peerID,
                         @"progress"      :   progress
                         };
  
  [[NSNotificationCenter defaultCenter] postNotificationName:@"MCDidStartReceivingResourceNotification"
                                                      object:nil
                                                    userInfo:dict];
  
  
  dispatch_async(dispatch_get_main_queue(), ^{
    [progress addObserver:self
               forKeyPath:@"fractionCompleted"
                  options:NSKeyValueObservingOptionNew
                  context:nil];
  });

}
- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error
{
    NSLog(@"MCConnection: Error - peer sent resource!");
}
/* END UNUSED! */



#pragma mark - transmission

-(void)sendMessageToAll:(NSString*)message{
  
  NSDictionary* payloadDict = @{kMessageText: message,kDeviceId:[[UIDevice currentDevice] name]};
    [self sendDictionary:payloadDict];
}

-(void)sendDictionary:(NSDictionary*)dict{
    
    NSData* payload = [NSKeyedArchiver archivedDataWithRootObject:dict];
    
    NSError *err = nil;
    
    BOOL success = NO;
    
    //Send to browser peers
    if(_sessionBrowse.connectedPeers.count > 0)
    {
        success = [_sessionBrowse sendData:payload toPeers:_sessionBrowse.connectedPeers withMode:MCSessionSendDataReliable error:&err];
        
        if(!success || err)
        {
            NSLog(@"MCConnection: Error sending data to browse peers: %@", err.localizedDescription);
        }
        
        err = nil;
    }
    
    //Send to advertiser peers
    if(_sessionAdvertise.connectedPeers.count > 0)
    {
        success = [_sessionAdvertise sendData:payload toPeers:_sessionAdvertise.connectedPeers withMode:MCSessionSendDataReliable error:&err];
        
        if(!success || err)
        {
            NSLog(@"MCConnection: Error sending data to Adv peers: %@", err.localizedDescription);
        }
    }
}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
  [[NSNotificationCenter defaultCenter] postNotificationName:@"MCReceivingProgressNotification"
                                                      object:nil
                                                    userInfo:@{@"progress": (NSProgress *)object}];
}


@end
