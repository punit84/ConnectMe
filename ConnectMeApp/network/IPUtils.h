//
//  IPUtils.h
//  ConnectMeApp
//
//  Created by punit on 29/05/15.
//  Copyright (c) 2015 Parnit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IPUtils : NSObject


+ (NSString*)ipToMac:(NSString*)ipAddress;
+ (NSString*)getDefaultGatewayIp;

@end
