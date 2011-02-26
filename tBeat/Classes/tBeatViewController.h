//
//  tBeatViewController.h
//  tBeat
//
//  Created by Niclas Helbro on 2/20/11.
//  Copyright 2011 Saddleback College. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "SA_OAuthTwitterController.h"

@class SA_OAuthTwitterEngine;

@interface tBeatViewController : UIViewController <SA_OAuthTwitterControllerDelegate> {
	IBOutlet UITextView *twitterText;
	IBOutlet UIButton *tweetButton;
	MPMusicPlayerController *musicPlayer; 
	SA_OAuthTwitterEngine *_engine;
	BOOL twitterTextSendable;
}

@property(nonatomic,retain) IBOutlet UITextView *twitterText;
@property (nonatomic, retain) UIButton *tweetButton;
@property (nonatomic, retain) MPMusicPlayerController *musicPlayer;

// When button is pressed
-(IBAction) buttonClicked: (id) sender;
-(void)setTwitterTextAccordingToPlaybackState;

@end

