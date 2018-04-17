//
//  TextToSpeechConverter.m
//  ConnectMeApp
//
//  Created by Vranda on 28/05/15.
//  Copyright (c) 2015 Parnit. All rights reserved.
//

#import "TextToSpeechConverter.h"
#import "MCController.h"
#import <AudioToolbox/AudioToolbox.h>
#import <UIKit/UIKitDefines.h>
#import <UIKit/UIDevice.h>

@implementation TextToSpeechConverter

-(void) createSoundForText:(NSString *)text{

  [self setSpeakerEnabled];
    AVSpeechUtterance *utterance = [AVSpeechUtterance
                                    speechUtteranceWithString:text];
    utterance.volume=1.0;
    utterance.rate=AVSpeechUtteranceMinimumSpeechRate;
    AVSpeechSynthesizer *synth = [[AVSpeechSynthesizer alloc] init];
    [synth speakUtterance:utterance];
  [self vibratePhone];
  
}

-(void)setSpeakerEnabled
{
  UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
  
  AudioSessionSetProperty (
                           kAudioSessionProperty_OverrideAudioRoute,
                           sizeof (audioRouteOverride),
                           &audioRouteOverride
                           );
}


- (void)vibratePhone;
{
  AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);

  if([[UIDevice currentDevice].model isEqualToString:@"iPhone"])
  {
    AudioServicesPlaySystemSound (1352); //works ALWAYS as of this post
  }
  else
  {
    // Not an iPhone, so doesn't have vibrate
    // play the less annoying tick noise or one of your own
    AudioServicesPlayAlertSound (1105);
  }
}
@end
