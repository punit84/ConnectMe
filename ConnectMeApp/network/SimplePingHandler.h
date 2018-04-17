//
//  SimplePingHandler.h
//  ConnectMeApp
//
//  Created by punit on 29/05/15.
//  Copyright (c) 2015 Parnit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SimplePingHandler : NSObject

+ (void)ping:(NSString*)address target:(id)target sel:(SEL)sel;

@end
