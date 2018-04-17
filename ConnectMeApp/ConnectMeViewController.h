//
//  FirstViewController.h
//  ConnectMeApp
//
//  Created by punit on 28/05/15.
//  Copyright (c) 2015 Parnit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCConnection.h"
#import "MCConnectionInfoViewController.h"
#import "PeerFinder.h"
#import "Device.h"
#import "MCController.h"

@interface ConnectMeViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,MCConnectionDelegate,PeerFinderDelegate>
@property(nonatomic,retain) MCConnectionInfoViewController *bar;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property(nonatomic, retain) IBOutlet UIBarButtonItem *fileShareButton;
@end

