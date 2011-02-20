//
//  tBeatAppDelegate.h
//  tBeat
//
//  Created by Niclas Helbro on 2/20/11.
//  Copyright 2011 Saddleback College. All rights reserved.
//

#import <UIKit/UIKit.h>

@class tBeatViewController;

@interface tBeatAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    tBeatViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet tBeatViewController *viewController;

@end

