//
//  tBeatViewController.m
//  tBeat
//
//  Created by Niclas Helbro on 2/20/11.
//  Copyright 2011 Saddleback College. All rights reserved.
//

#import "tBeatViewController.h"
#import "SA_OAuthTwitterEngine.h"

#define kOAuthConsumerKey				@"OPNhSkLw7brs5vt00uwEyQ"							//REPLACE ME
#define kOAuthConsumerSecret			@"zYC7IHRYBJG34Rdxo2DrCK3xIWJJAErx67wwPpayyg"		//REPLACE ME

@implementation tBeatViewController

@synthesize twitterText;
@synthesize musicPlayer;


//=============================================================================================================================
#pragma mark SA_OAuthTwitterEngineDelegate
- (void) storeCachedTwitterOAuthData: (NSString *) data forUsername: (NSString *) username {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	[defaults setObject: data forKey: @"authData"];
	[defaults synchronize];
}

- (NSString *) cachedTwitterOAuthDataForUsername: (NSString *) username {
	return [[NSUserDefaults standardUserDefaults] objectForKey: @"authData"];
}

//=============================================================================================================================
#pragma mark SA_OAuthTwitterControllerDelegate
- (void) OAuthTwitterController: (SA_OAuthTwitterController *) controller authenticatedWithUsername: (NSString *) username {
	NSLog(@"Authenicated for %@", username);
}

- (void) OAuthTwitterControllerFailed: (SA_OAuthTwitterController *) controller {
	NSLog(@"Authentication Failed!");
}

- (void) OAuthTwitterControllerCanceled: (SA_OAuthTwitterController *) controller {
	NSLog(@"Authentication Canceled.");
}

//=============================================================================================================================
#pragma mark TwitterEngineDelegate
- (void) requestSucceeded: (NSString *) requestIdentifier {
	NSLog(@"Request %@ succeeded", requestIdentifier);
}

- (void) requestFailed: (NSString *) requestIdentifier withError: (NSError *) error {
	NSLog(@"Request %@ failed with error: %@", requestIdentifier, error);
}

//=============================================================================================================================
#pragma mark ViewController Stuff

- (void) viewDidAppear: (BOOL)animated {
	if (_engine) return;
	_engine = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate: self];
	_engine.consumerKey = kOAuthConsumerKey;
	_engine.consumerSecret = kOAuthConsumerSecret;
	
	UIViewController			*controller = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine: _engine delegate: self];
	
	if (controller) 
		[self presentModalViewController: controller animated: YES];
	else {
		[_engine sendUpdate: [NSString stringWithFormat: @"Already Updated. %@", [NSDate date]]];
	}
	
}

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Sets the twitter text depending if a song is playing or not.
-(void)setTwitterText 
{
	MPMediaItem *currentItem = musicPlayer.nowPlayingItem;
	if(currentItem == nil)
	{
		twitterText.text = @"No song is currently playing. Please start a song and then restart the program to tweet.";
	}
	else {
		// TODO: Do refactor this mess
		twitterText.text = @"Now playing ";
		twitterText.text = [twitterText.text stringByAppendingString: [currentItem valueForProperty:MPMediaItemPropertyArtist]];
		twitterText.text = [twitterText.text stringByAppendingString:@" with the song "];
		twitterText.text = [twitterText.text stringByAppendingString: [currentItem valueForProperty:MPMediaItemPropertyTitle]];
		twitterText.text = [twitterText.text stringByAppendingString:@". Rating: "];
		twitterText.text = [twitterText.text stringByAppendingString: [[currentItem valueForProperty:MPMediaItemPropertyRating] stringValue]];
		twitterText.text = [twitterText.text stringByAppendingString:@"/5."];
	}
	
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

	musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
	
	// Set the start text..
	[self setTwitterTextAccordingToPlaybackState];
	
	// Subscribe for notifications of playback changes
	// TODO: Put this in a separate function. Should it be called from somewhere else than viewDidLoad()?
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	
	[notificationCenter
	 addObserver: self
	 selector:    @selector (handleNowPlayingItemChanged:)
	 name:        MPMusicPlayerControllerNowPlayingItemDidChangeNotification
	 object:      musicPlayer];
	
	
	[notificationCenter
	 addObserver: self
	 selector:    @selector (handlePlaybackStateChanged:)
	 name:        MPMusicPlayerControllerPlaybackStateDidChangeNotification
	 object:      musicPlayer];
	
	[musicPlayer beginGeneratingPlaybackNotifications];
}


// When the playback state changes, we get called here
- (void) handlePlaybackStateChanged: (id) notification 
{	
	[self setTwitterTextAccordingToPlaybackState];
}


- (void) setTwitterTextAccordingToPlaybackState
{
	MPMusicPlaybackState playbackState = [musicPlayer playbackState];

	if (playbackState == MPMusicPlaybackStatePlaying) 
	{
		[self setTwitterText];
	} 
	else if (playbackState == MPMusicPlaybackStateStopped ||
						playbackState == MPMusicPlaybackStatePaused ||
						playbackState == MPMusicPlaybackStateInterrupted) 
	{
		twitterText.text = @"Music is stopped or paused, you will get to choose a song from the library in a coming release.";		
	}
}

// When the now-playing item changes, update the media item artwork and the now-playing label.
- (void) handleNowPlayingItemChanged: (id) notification 
{
	[self setTwitterTextAccordingToPlaybackState]; // TODO: should this really call on setTwitterTextAccordingToPlaybackState or setTwitterText?
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
	return NO;
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	twitterText.text = @"viewDidUnload";
	/*
	[[NSNotificationCenter defaultCenter]
	 removeObserver: self
	 name:           MPMusicPlayerControllerNowPlayingItemDidChangeNotification
	 object:         musicPlayer];
	
	[[NSNotificationCenter defaultCenter]
	 removeObserver: self
	 name:           MPMusicPlayerControllerPlaybackStateDidChangeNotification
	 object:         musicPlayer];
	 [musicPlayer endGeneratingPlaybackNotifications];
	*/
}


- (void)dealloc {
    [_engine release];
    [super dealloc];
    //[musicPlayer dealloc]; TODO: should this be done?
}

-(IBAction) buttonClicked:(id) sender {
	// TODO: Code here should connect to Twitter and send a tweet, use the text
	// in the twitterText variable.
	
	// Test: Change the text while when the button is pressed, verify that the 
	// twitterText variable is availble here and that we can change it as well
	// as seeing that we can update the text field. 
	
	// twitterText.text = @"Button pressed! Functionality for tweeting is yet to be done though.";
}

@end
