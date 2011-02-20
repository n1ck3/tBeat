//
//  tBeat_AppDelegate.h
//  tBeat_
//
//  Created by Niclas Helbro on 2/20/11.
//  Copyright 2011 Saddleback College. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface tBeat_AppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
    UIWindow *window;
    UITabBarController *tabBarController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

@end
