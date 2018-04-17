//
//  MCConnectionInfoViewController.h
//
//  Created by punit on 28/05/15.
//  Copyright (c) 2015 Parnit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MCConnectionInfoViewController : UIViewController

-(void)startedSearchingForPeers;
-(void)peerConnecting;
-(void)peerConnected;
-(void)peerDropped;

@end
