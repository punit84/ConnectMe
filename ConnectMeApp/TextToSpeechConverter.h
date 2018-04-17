//
//  TextToSpeechConverter.h
//  ConnectMeApp
//
//  Created by Vranda on 28/05/15.
//  Copyright (c) 2015 Parnit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface TextToSpeechConverter : NSObject

-(void) createSoundForText:(NSString *)text;

@end
