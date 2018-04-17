//
//  PeerFinder.h
//  ConnectMeApp
//
//  Created by punit on 29/05/15.
//  Copyright (c) 2015 Parnit. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol PeerFinderDelegate <NSObject>

@optional
- (void)scanLANDidFindNewAdrress:(NSString *)address havingHostName:(NSString *)hostName;
- (void)scanLANDidFinishScanning;
@end

@interface PeerFinder : NSObject

@property(nonatomic,weak) id<PeerFinderDelegate> delegate;

- (id)initWithDelegate:(id<PeerFinderDelegate>)delegate;
- (void)startScan;
- (void)stopScan;

@end
