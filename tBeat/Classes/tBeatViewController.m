//
//  tBeatViewController.m
//  tBeat
//
//  Created by Niclas Helbro on 2/20/11.
//  Copyright 2011 Saddleback College. All rights reserved.
//

#import "tBeatViewController.h"
#import "SA_OAuthTwitterEngine.h"

#define kOAuthConsumerKey				@"aYYW3aVNyuOd0mZXwGvjQ"
#define kOAuthConsumerSecret			@"NeqlwlnT2NpS7ipQG3hBs6NnhLNJT2dEz4H43MVtM"

@implementation tBeatViewController

@synthesize twitterText;
@synthesize musicPlayer;
@synthesize tweetButton;


- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller {
    
	[self dismissModalViewControllerAnimated:YES];
}


- (IBAction)showInfo:(id)sender {    
	
	FlipsideViewController *controller = [[FlipsideViewController alloc] initWithNibName:@"FlipsideView" bundle:nil];
	controller.delegate = self;
	
	controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:controller animated:YES];
	
	[controller release];
}

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
		twitterText.text = @"No song is currently playing. Please start a song and then start the program to tweet.";
		[tweetButton setEnabled: FALSE];
	}
	else 
	{
		[self composeTwitterText: currentItem];
		
	}
	
}

- (void) composeTwitterText: (MPMediaItem *) musicItem
{
	
	NSString *artistSpaces = [musicItem valueForProperty:MPMediaItemPropertyArtist];
	NSString *artistNoSpaces = [artistSpaces stringByReplacingOccurrencesOfString:@" " withString:@"+"];
	
	NSString *titleSpaces = [musicItem valueForProperty:MPMediaItemPropertyTitle];
	NSString *titleNoSpaces = [titleSpaces stringByReplacingOccurrencesOfString:@" " withString:@"+"];
	
	NSString *rating = [[musicItem valueForProperty:MPMediaItemPropertyRating] stringValue];
	
	NSString *longGoogleUrl = [NSString stringWithFormat:
														 @"http://tinyurl.com/api-create.php?url=http://google.com/search?btnI=1&q=youtube+%@+%@",
														 artistNoSpaces, titleNoSpaces];
	
	NSURL *tinyUrl = [NSURL URLWithString: longGoogleUrl];
	NSString *link = [NSString stringWithContentsOfURL:tinyUrl encoding:NSASCIIStringEncoding error:nil];
	
	[tweetButton setEnabled: TRUE];
	
	twitterText.text = [NSString stringWithFormat:
											@"Listening to %@ by %@, %@/5. %@ #tBeat", 
											titleSpaces, artistSpaces, rating, link];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

	NSLog(@"viewDidLoad()");
	[tweetButton setEnabled: FALSE];
	
	musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
	
	// Set the start text..
	[self setTwitterTextAccordingToPlaybackState];
	
	// Subscribe for notifications of playback changes
	// TODO: Put this in a separate function.
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
		[tweetButton setEnabled: FALSE];
	}
}

// When the now-playing item changes, update the media item artwork and the now-playing label.
- (void) handleNowPlayingItemChanged: (id) notification 
{
	[self setTwitterTextAccordingToPlaybackState]; 
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	
	[[NSNotificationCenter defaultCenter]
		removeObserver: self
		name:           MPMusicPlayerControllerNowPlayingItemDidChangeNotification
		object:         musicPlayer];
	
	[[NSNotificationCenter defaultCenter]
	 removeObserver: self
	 name:           MPMusicPlayerControllerPlaybackStateDidChangeNotification
	 object:         musicPlayer];
	[musicPlayer endGeneratingPlaybackNotifications];
	
	[musicPlayer release];
	[twitterText release];
	
	[_engine release];
	[super dealloc];
}




-(IBAction) buttonClicked:(id) sender {
	// TODO: Code here should connect to Twitter and send a tweet, use the text
	// in the twitterText variable.
	if(tweetButton.isEnabled)
	{
		if ([_engine isAuthorized])
		{
			[_engine sendUpdate: [NSString stringWithFormat: twitterText.text]];
			twitterText.text = @"Tweet sent!";
			[tweetButton setEnabled: FALSE];
		}
		else {
			// TODO: Show alert popup that you have to link twitter account.
			UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Not authenticated with twitter"
														message:@"Click the 'i' and link with twitter."
														delegate:nil
														cancelButtonTitle:@"OK"
														otherButtonTitles:nil] autorelease];
			[alert show];
		}
	}
}


-(IBAction) chooseSongButtonClicked:(id) sender {
	MPMediaPickerController *picker = [[MPMediaPickerController alloc] initWithMediaTypes: MPMediaTypeMusic];
	if(picker != nil) // TODO: Not needed to check against nil, remove this (wont work in simulator though)
	{
		[picker setDelegate: self];
		[picker setAllowsPickingMultipleItems: NO];                        
		picker.prompt = NSLocalizedString (@"Add song to tweet", "Prompt in media item picker");
	
		[self presentModalViewController: picker animated: YES];
		[picker release];
	}
}

- (void) mediaPicker: (MPMediaPickerController *) mediaPicker didPickMediaItems: (MPMediaItemCollection *) collection 
{
	[self dismissModalViewControllerAnimated: YES];

	// Get song from collection
	MPMediaItem *mediaItem = [collection representativeItem];
	if(mediaItem)
	{
		[self composeTwitterText: mediaItem];
	}

}

- (void) mediaPickerDidCancel: (MPMediaPickerController *) mediaPicker 
{
	[self dismissModalViewControllerAnimated: YES];
}


@end
