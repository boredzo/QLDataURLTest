//
//  PRHThumbnailsWindowController.h
//  QLDataURL
//
//  Created by Peter Hosey on 2012-09-28.
//  Copyright (c) 2012 Peter Hosey. All rights reserved.
//

@interface PRHThumbnailsWindowController : NSWindowController

@property(copy) NSImage *synchronouslyObtainedThumbnailImage;
@property(copy) NSImage *dispatchObtainedThumbnailImage;

@end
