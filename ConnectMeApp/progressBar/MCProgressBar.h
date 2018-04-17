//
//  MCProgressBar.h
//
//
//  Created by punit on 28/05/15.
//  Copyright (c) 2015 Parnit. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  MCProgressBar is iOS 7 style progress bar control.
 */
@interface MCProgressBar : UIView

/// @property animates - Indicates of the pattern layer is shown and animates
@property (nonatomic) BOOL animates;

/// @property progress - A value from 0.0 to 1.0 that indicates the progress of the operation
@property (nonatomic) CGFloat progress;

/// @property patternImage - The image that should be drawn over the fill
@property (nonatomic, strong) UIImage *patternImage;

/// @property animationDuration - The duration of
@property (nonatomic) CGFloat animationDuration;

@end
