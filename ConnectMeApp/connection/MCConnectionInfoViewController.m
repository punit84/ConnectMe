//
//  MCConnectionInfoViewController.m
//
//  Created by punit on 28/05/15.
//  Copyright (c) 2015 Parnit. All rights reserved.
//


#import "MCProgressBar.h"
#import "MCConnectionInfoViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface MCConnectionInfoViewController ()

@property(nonatomic, retain) MCProgressBar *progressView;

@end

@implementation MCConnectionInfoViewController

//#define COLog(...) NSLog(__VA_ARGS__)
#define COLog(...)

#define kAnimationDuration 2.0f
#define kAnimationFadeDuration 0.3f

-(id)init{
    
    self = [super init];
    
    if(self)
    {
        //Create view at top for tapping
        UIView *topView = [[UIView alloc] initWithFrame:[UIApplication sharedApplication].statusBarFrame];
        
        _progressView = [[MCProgressBar alloc] initWithFrame:topView.bounds];
        [_progressView setTintColor:[UIColor lightGrayColor]];
        [_progressView setAlpha:0.0f];
        [topView addSubview:_progressView];

        [self setView:topView];
        
        
        //Custom resizing on rotation - autoresize not working for this badger!
        [[NSNotificationCenter defaultCenter] addObserverForName:UIDeviceOrientationDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
            [_progressView.superview setFrame:[UIApplication sharedApplication].statusBarFrame];
            [_progressView setBounds:topView.bounds];
            
        }];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareChange{
    [_progressView setAlpha:1.0f];
    
    [_progressView.layer removeAllAnimations];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    [self performSelector:@selector(stopAnimating) withObject:nil afterDelay:kAnimationDuration];
}

-(void)startedSearchingForPeers
{
    COLog(@"> SEARCHING");
    [_progressView setTintColor:[UIColor lightGrayColor]];
    [self prepareChange];
}

-(void)peerConnecting
{
     COLog(@"> CONNECTING");
    [_progressView setTintColor:[[UIColor purpleColor] colorWithAlphaComponent:0.4f]];
    [self prepareChange];
}

-(void)peerConnected
{
     COLog(@"> CONNECTED");
    [_progressView setTintColor:[[UIColor greenColor] colorWithAlphaComponent:0.4f]];
    [self prepareChange];
}

-(void)peerDropped
{
     COLog(@"> DROPPED");
    [_progressView setTintColor:[[UIColor redColor] colorWithAlphaComponent:0.4f]];
    [self prepareChange];
}



-(void)stopAnimating
{
    COLog(@"> FADE");
    [UIView animateWithDuration:kAnimationFadeDuration animations:^{
        [_progressView setAlpha:0.0f];
    } completion:^(BOOL finished) {
        COLog(@"> DONE");
        [_progressView setTintColor:[UIColor lightGrayColor]];
        [_progressView setAlpha:0.0f];
    }];

}
@end
