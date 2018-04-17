//
//  Device.h
//  CrissCrossApp
//
//  Created by punit on 29/05/15.
//  Copyright (c) 2015 Parnit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Device : NSObject
@property BOOL isAppleDevice;
@property BOOL isConnected;
@property NSString *name;
@property NSString *address;
@property NSString *macAddress;

@end
