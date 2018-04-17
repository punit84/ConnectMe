//
//  MCController.h
//
//  Created by punit on 28/05/15.
//  Copyright (c) 2015 Parnit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCConnection.h"


@interface MCController : NSObject{
  
}
@property(nonatomic, retain) MCConnection* connection;

@property(nonatomic, assign) NSObject<MCConnectionDelegate> *connectionDelegate;

+(MCController*)sharedChannelController;

-(NSInteger)currentChannel;
-(void)setCurrentChannel:(NSInteger)newChannel;

-(void)connect;
-(void)disconnect;

-(void)sendMessageToAll:(NSString*)morse;

@end
