//
//  tBeatViewController.h
//  tBeat
//
//  Created by Niclas Helbro on 2/20/11.
//  Copyright 2011 Saddleback College. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface tBeatViewController : UIViewController {
	IBOutlet UITextView *twitterText;
	MPMusicPlayerController *musicPlayer; 
}

@property(nonatomic,retain) IBOutlet UITextView *twitterText;
@property (nonatomic, retain) MPMusicPlayerController *musicPlayer;

// When button is pressed
-(IBAction) buttonClicked: (id) sender;
-(void)setTwitterTextAccordingToPlaybackState;

@end

