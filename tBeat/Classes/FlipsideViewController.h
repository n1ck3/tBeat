//
//  FlipsideViewController.h
//  test
//
//  Created by Niclas Helbro on 2/26/11.
//  Copyright 2011 Saddleback College. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FlipsideViewControllerDelegate;

@interface FlipsideViewController : UIViewController {
	id <FlipsideViewControllerDelegate> delegate;
	IBOutlet UIButton *unlinkTwitterButton;
}

@property (nonatomic, retain) UIButton *unlinkTwitterButton;
@property (nonatomic, assign) id <FlipsideViewControllerDelegate> delegate;
- (IBAction) unlinkTwitterButtonClicked:(id) sender;
- (IBAction)done:(id)sender;
@end


@protocol FlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller;
@end

//- (IBAction) unlinkTwitterButtonClicked:(id) sender;
