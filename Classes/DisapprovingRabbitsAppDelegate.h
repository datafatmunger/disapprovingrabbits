//
//  DisapprovingRabbitsAppDelegate.h
//  DisapprovingRabbits
//
//  Created by James Bryan Graves on 8/7/10.
//  Copyright N/A 2010. All rights reserved.
//

#import "Three20UI/Three20UI.h"
#import <UIKit/UIKit.h>

@class DisapprovingRabbitsViewController;

@interface DisapprovingRabbitsAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	TTNavigationController *navigationController;
	DisapprovingRabbitsViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet TTNavigationController *navigationController;
@property (nonatomic, retain) IBOutlet DisapprovingRabbitsViewController *viewController;

@end

