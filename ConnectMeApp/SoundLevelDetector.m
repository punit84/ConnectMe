//
//  ActionDetector.m
//  ConnectMeApp
//
//  Created by punit on 28/05/15.
//  Copyright (c) 2015 Parnit. All rights reserved.
//

#import "SoundLevelDetector.h"
#import <UIKit/UIKit.h>
#import "MCController.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>

@interface SoundLevelDetector (){
  AVAudioRecorder *recorder;
  NSTimer *levelTimer;
  double lowPassResults;
  NSTimeInterval lastTime;
  
}

@end

@implementation SoundLevelDetector

-(void)initMicBlow{
  
  NSURL *url = [NSURL fileURLWithPath:@"/dev/null"];
  
  NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSNumber numberWithFloat: 44100.0],                 AVSampleRateKey,
                            [NSNumber numberWithInt: kAudioFormatAppleLossless], AVFormatIDKey,
                            [NSNumber numberWithInt: 1],                         AVNumberOfChannelsKey,
                            [NSNumber numberWithInt: AVAudioQualityMax],         AVEncoderAudioQualityKey,
                            nil];
  
  NSError *error;
  
  
  recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
  
  if (recorder) {
    [recorder prepareToRecord];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    recorder.meteringEnabled = YES;
    [recorder record];
    levelTimer = [NSTimer scheduledTimerWithTimeInterval: 0.03 target: self selector: @selector(levelTimerCallback:) userInfo: nil repeats: YES];
  } else
    NSLog([error description]);
}


-(void)showAlertSound
{
  UIAlertView *alertView = [[UIAlertView alloc]
                            initWithTitle:@"Sound Demo"
                            message:@"Sound Detected"
                            delegate:nil
                            cancelButtonTitle:@"OK"
                            otherButtonTitles:nil];
  [alertView show];
}

- (BOOL)canBecomeFirstResponder
{
  return YES;
}

- (void)levelTimerCallback:(NSTimer *)timer {
  [recorder updateMeters];
  
  const double ALPHA = 0.05;
  double peakPowerForChannel = pow(10, (0.05 * [recorder peakPowerForChannel:0]));
  lowPassResults = ALPHA * peakPowerForChannel + (1.0 - ALPHA) * lowPassResults;
 // NSLog(@"the value is %@", [NSDecimalNumber numberWithDouble:lowPassResults]);
  if (lowPassResults > 0.75){
    NSLog(@"Mic blow detected");
   // [self showAlertSound];
    NSTimeInterval currentTime= [[NSDate date] timeIntervalSince1970];
    if (currentTime-lastTime<2) {
      NSLog(@"ignoring this event");
      return;
      
    }else{
      NSLog(@"sending this event");
      
      lastTime= currentTime;
    }
    NSString *msg= [NSString stringWithFormat:@"Help!  %@. He is screaming out loud",[[UIDevice currentDevice] name] ];

    [[MCController sharedChannelController] sendMessageToAll:msg];
      
  }
}

-(void)showAlert
{
  UIAlertView *alertView = [[UIAlertView alloc]
                            initWithTitle:@"ShakeGesture Demo"
                            message:@"Shake Detected"
                            delegate:nil
                            cancelButtonTitle:@"OK"
                            otherButtonTitles:nil];
  [alertView show];
}



@end
