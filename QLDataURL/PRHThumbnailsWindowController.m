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
#import <Quartz/Quartz.h>

@interface PRHThumbnailsWindowController () <QLPreviewPanelDataSource>

@property NSSize imageSize;
@property(copy) NSURL *imageDataURL;

@end

@implementation PRHThumbnailsWindowController

- (id) init {
	return [self initWithWindowNibName:[self className]];
}

- (id)initWithWindow:(NSWindow *)window
{
	self = [super initWithWindow:window];
	if (self) {
		NSSize size = { 128.0, 128.0 };
		self.imageSize = size;

		NSImage *sourceImage = [NSImage imageWithSize:size flipped:NO drawingHandler:^BOOL(NSRect dstRect) {
			NSBezierPath *circle = [NSBezierPath bezierPathWithOvalInRect:(NSRect){ NSZeroPoint, self.imageSize }];
			[[NSColor redColor] set];
			[circle fill];
			return YES;
		}];
		NSData *sourceData = [sourceImage TIFFRepresentation];
		self.imageDataURL = [sourceData dataURLWithMimeType_PRH:@"image/tiff"];
	}
	
	return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];

	NSDictionary *options = @{ (__bridge NSString *)kQLThumbnailOptionScaleFactorKey: @(self.window.userSpaceScaleFactor) };

	//Try to generate thumbnails for said URL
	CGImageRef thumbnailCGImage = QLThumbnailImageCreate(kCFAllocatorDefault, (__bridge CFURLRef)self.imageDataURL, self.imageSize, (__bridge CFDictionaryRef)options);
	if (thumbnailCGImage) {
		self.synchronouslyObtainedThumbnailImage = [[NSImage alloc] initWithCGImage:thumbnailCGImage size:self.imageSize];
		CFRelease(thumbnailCGImage);
	}

	QLThumbnailRef thumbnailAttempt = QLThumbnailCreate(kCFAllocatorDefault, (__bridge CFURLRef)self.imageDataURL, self.imageSize, (__bridge CFDictionaryRef)options);
	if (thumbnailAttempt) {
		thumbnailCGImage = QLThumbnailCopyImage(thumbnailAttempt);
		if (thumbnailCGImage) {
			self.dispatchObtainedThumbnailImage = [[NSImage alloc] initWithCGImage:thumbnailCGImage size:self.imageSize];
			CFRelease(thumbnailCGImage);
		}

		CFRelease(thumbnailAttempt);
	}

	thumbnailAttempt = QLThumbnailCreate(kCFAllocatorDefault, (__bridge CFURLRef)self.imageDataURL, self.imageSize, (__bridge CFDictionaryRef)options);
	if (thumbnailAttempt) {
		QLThumbnailDispatchAsync(thumbnailAttempt, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, /*flags*/ 0), ^{
			CGImageRef resultCGImage = QLThumbnailCopyImage(thumbnailAttempt);
			if (resultCGImage) {
				NSImage *resultImage = [[NSImage alloc] initWithCGImage:resultCGImage size:self.imageSize];
				dispatch_async(dispatch_get_main_queue(), ^{
					self.dispatchObtainedThumbnailImage = resultImage;
				});

				CFRelease(resultCGImage);
			}

			CFRelease(thumbnailAttempt);
		});
	}

	QLPreviewPanel *previewPanel = [QLPreviewPanel sharedPreviewPanel];
	[previewPanel makeKeyAndOrderFront:nil];
}

- (BOOL) acceptsPreviewPanelControl:(QLPreviewPanel *)panel {
	return YES;
}
- (void) beginPreviewPanelControl:(QLPreviewPanel *)panel {
	panel.dataSource = self;
}
- (void) endPreviewPanelControl:(QLPreviewPanel *)panel {
	panel.dataSource = nil;
}

- (NSInteger) numberOfPreviewItemsInPreviewPanel:(QLPreviewPanel *)panel {
	return 1L;
}

- (id <QLPreviewItem>) previewPanel:(QLPreviewPanel *)panel previewItemAtIndex:(NSInteger)idx {
	return self.imageDataURL;
}

@end
