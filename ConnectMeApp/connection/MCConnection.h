//
//  MCConnection.h

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import <MultipeerConnectivity/MCNearbyServiceAdvertiser.h>
#import <MultipeerConnectivity/MCNearbyServiceBrowser.h>

@class MCConnection;
@protocol MCConnectionDelegate

-(void)connectingToUserWithID:(NSInteger)userID;
-(void)connectedToUserWithID:(NSInteger)userID;
-(void)disconnectedFromUserWithID:(NSInteger)userID;
-(void)startingToSearch;
-(void)userWithID:(NSInteger)userID didReceiveMessage:(NSString*)morse withName:(NSString *)deviceName;
-(void)userWithID:(NSInteger)userID didSendLetter:(NSString*)letter;
-(void)foundNewPeer:(NSString *)peerID :(NSInteger)userID;
@end

@interface MCConnection : NSObject
@property(nonatomic,assign) NSObject<MCConnectionDelegate>*delegate;

@property(nonatomic, retain) MCNearbyServiceAdvertiser *advertiser;
@property(nonatomic, retain) MCNearbyServiceBrowser *browser;
@property(nonatomic, retain) MCSession *sessionAdvertise;
@property(nonatomic, retain) MCSession *sessionBrowse;

-(id)initWithChannel:(NSInteger)channel;

-(void)sendMessageToAll:(NSString*)message;

-(void)connect;
-(void)disconnect;
@end
