//
//  PRHAppDelegate.m
//  QLDataURL
//
//  Created by Peter Hosey on 2012-09-28.
//  Copyright (c) 2012 Peter Hosey. All rights reserved.
//

#import "PRHAppDelegate.h"

#import "PRHThumbnailsWindowController.h"

@implementation PRHAppDelegate
{
	PRHThumbnailsWindowController *wc;
}

- (void)applicationWillFinishLaunching:(NSNotification *)notification {
	wc = [PRHThumbnailsWindowController new];
	[wc showWindow:nil];
}
- (void) applicationWillTerminate:(NSNotification *)notification {
	[wc close];
	wc = nil;
}

@end
