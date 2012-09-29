//
//  PRHThumbnailsWindowController.m
//  QLDataURL
//
//  Created by Peter Hosey on 2012-09-28.
//  Copyright (c) 2012 Peter Hosey. All rights reserved.
//

#import "PRHThumbnailsWindowController.h"

#import "NSData+PRHDataURL.h"

#import <QuickLook/QuickLook.h>

@interface PRHThumbnailsWindowController ()

@end

@implementation PRHThumbnailsWindowController

- (id) init {
	return [self initWithWindowNibName:[self className]];
}

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];

	NSSize size = { 128.0, 128.0 };
	CGFloat scaleFactor = self.window.userSpaceScaleFactor;
	size.width *= scaleFactor;
	size.height *= scaleFactor;

	NSImage *sourceImage = [NSImage imageWithSize:size flipped:NO drawingHandler:^BOOL(NSRect dstRect) {
		NSBezierPath *circle = [NSBezierPath bezierPathWithOvalInRect:(NSRect){ NSZeroPoint, size }];
		[[NSColor redColor] set];
		[circle fill];
		return YES;
	}];
	NSData *sourceData = [sourceImage TIFFRepresentation];
	NSURL *dataURL = [sourceData dataURLWithMimeType_PRH:@"image/tiff"];

	//Try to generate thumbnails for said URL
	CGImageRef thumbnailCGImage = QLThumbnailImageCreate(kCFAllocatorDefault, (__bridge CFURLRef)dataURL, size, /*options*/ NULL);
	if (thumbnailCGImage) {
		self.synchronouslyObtainedThumbnailImage = [[NSImage alloc] initWithCGImage:thumbnailCGImage size:size];
		CFRelease(thumbnailCGImage);
	}

	QLThumbnailRef thumbnailAttempt = QLThumbnailCreate(kCFAllocatorDefault, (__bridge CFURLRef)dataURL, size, /*options*/ NULL);
	if (thumbnailAttempt) {
		thumbnailCGImage = QLThumbnailCopyImage(thumbnailAttempt);
		CFRelease(thumbnailAttempt);
	}
	if (thumbnailCGImage) {
		self.dispatchObtainedThumbnailImage	= [[NSImage alloc] initWithCGImage:thumbnailCGImage size:size];
		CFRelease(thumbnailCGImage);
	}

	thumbnailAttempt = QLThumbnailCreate(kCFAllocatorDefault, (__bridge CFURLRef)dataURL, size, /*options*/ NULL);
	if (thumbnailAttempt) {
		QLThumbnailDispatchAsync(thumbnailAttempt, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, /*flags*/ 0), ^{
			CGImageRef resultCGImage = QLThumbnailCopyImage(thumbnailAttempt);
			if (resultCGImage) {
				NSImage *resultImage = [[NSImage alloc] initWithCGImage:resultCGImage size:size];
				dispatch_async(dispatch_get_main_queue(), ^{
					self.dispatchObtainedThumbnailImage = resultImage;
				});

				CFRelease(resultCGImage);
			}

			CFRelease(thumbnailAttempt);
		});
	}
}

@end
