//
//  SimplePingHandler.m
//  ConnectMeApp
//
//  Created by punit on 29/05/15.
//  Copyright (c) 2015 Parnit. All rights reserved.
//

#import "SimplePingHandler.h"
#import "SimplePing.h"


@interface SimplePingHandler()
@property(nonatomic,retain) SimplePing* simplePing;
@property(nonatomic,retain) id target;
@property(nonatomic,assign) SEL sel;
- (id)initWithAddress:(NSString*)address target:(id)_target sel:(SEL)_sel;
- (void)go;
@end

@implementation SimplePingHandler
@synthesize simplePing, target, sel;

#pragma mark - Run it

// Pings the address, and calls the selector when done. Selector must take a NSnumber which is a bool for success
+ (void)ping:(NSString*)address target:(id)target sel:(SEL)sel {
  // The helper retains itself through the timeout function
  [[[SimplePingHandler alloc] initWithAddress:address target:target sel:sel]  go];
}

#pragma mark - Init/dealloc

- (void)dealloc {
  self.simplePing = nil;
  self.target = nil;
  //[super dealloc];
}

- (id)initWithAddress:(NSString*)address target:(id)_target sel:(SEL)_sel {
  if (self = [self init]) {
   // self.simplePing = [SimplePing];
      //[self.simplePing hostName:address];
    self.simplePing.delegate = self;
    self.target = _target;
    self.sel = _sel;
  }
  return self;
}

#pragma mark - Go

- (void)go {
  [self.simplePing start];
  [self performSelector:@selector(endTime) withObject:nil afterDelay:1]; // This timeout is what retains the ping helper
}

#pragma mark - Finishing and timing out

// Called on success or failure to clean up
- (void)killPing {
  [self.simplePing stop];
  //[[self.simplePing retain] autorelease]; // In case, higher up the call stack, this got called by the simpleping object itself
  self.simplePing = nil;
}

- (void)successPing {
  [self killPing];
  [target performSelector:sel withObject:[NSNumber numberWithBool:YES]];
}

- (void)failPing:(NSString*)reason {
  [self killPing];
  [target performSelector:sel withObject:[NSNumber numberWithBool:NO]];
}

// Called 1s after ping start, to check if it timed out
- (void)endTime {
  if (self.simplePing) { // If it hasn't already been killed, then it's timed out
    [self failPing:@"timeout"];
  }
}

#pragma mark - Pinger delegate

// When the pinger starts, send the ping immediately
- (void)simplePing:(SimplePing *)pinger didStartWithAddress:(NSData *)address {
  [self.simplePing sendPingWithData:nil];
}

- (void)simplePing:(SimplePing *)pinger didFailWithError:(NSError *)error {
  [self failPing:@"didFailWithError"];
}

- (void)simplePing:(SimplePing *)pinger didFailToSendPacket:(NSData *)packet error:(NSError *)error {
  // Eg they're not connected to any network
  [self failPing:@"didFailToSendPacket"];
}

- (void)simplePing:(SimplePing *)pinger didReceivePingResponsePacket:(NSData *)packet {
  //  NSLog(@"packet received %@",packet);
  //  NSString* newStr = [[NSString alloc] initWithData:packet encoding:NSUTF16LittleEndianStringEncoding];
  //  NSDictionary *JSON =
  //  [NSJSONSerialization JSONObjectWithData: packet
  //                                  options: NSJSONReadingMutableContainers
  //                                    error: nil];
  //  NSLog(@"%@",JSON);
  [self successPing];
}

@end
