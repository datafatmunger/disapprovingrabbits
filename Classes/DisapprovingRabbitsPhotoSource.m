//
//  DisapprovingRabbitsPhotoSource.m
//  DisapprovingRabbits
//
//  Created by James Bryan Graves on 8/7/10.
//  Copyright 2010 N/A. All rights reserved.
//

#import "DisapprovingRabbitsPhotoSource.h"


@implementation DisapprovingRabbitsPhotoSource

@synthesize photos = _photos;
@synthesize title = _title;

-(id)initWithStories:(NSArray*)stories {
	if (self = [super init]) {
		NSMutableArray* newPhotos = [NSMutableArray array];
		
		for (int i = 0; i < stories.count; ++i) {
			NSDictionary* story = [stories objectAtIndex:i];
			if ((NSNull*)story != [NSNull null] && [story objectForKey:@"imageURL"] != nil) {
				DisapprovingRabbitsPhoto* photo = [[[DisapprovingRabbitsPhoto alloc]
													initWithURL:[story objectForKey:@"imageURL"]
													smallURL:[story objectForKey:@"imageURL"]
													size:CGSizeMake(800, 600)] autorelease];
				photo.caption = [NSString stringWithFormat:@"%@: %@", [story objectForKey:@"title"], [story objectForKey:@"summary"]];
				photo.title = [story objectForKey:@"title"];
				[newPhotos addObject:photo];
			}
		}
		
		[newPhotos addObjectsFromArray:_tempPhotos];
		TT_RELEASE_SAFELY(_tempPhotos);
		
		[_photos release], _photos = [newPhotos mutableCopy];
		
		for (int i = 0; i < _photos.count; ++i) {
			id<TTPhoto> photo = [_photos objectAtIndex:i];
			if ((NSNull*)photo != [NSNull null]) {
				photo.photoSource = self;
				photo.index = i;
			}
		}
		
		//[_delegates perform:@selector(modelDidFinishLoad:) withObject:self];
	}
	return self;
}

- (BOOL)isLoading {
	return NO;
}

-(BOOL)isLoaded {
	return !!_photos;
}

-(NSInteger)numberOfPhotos {
	return _photos.count;
}

-(NSInteger)maxPhotoIndex {
	return _photos.count - 1;
}

-(id<TTPhoto>)photoAtIndex:(NSInteger)index {
	if (index < _photos.count) {
		id photo = [_photos objectAtIndex:index];
		if (photo == [NSNull null]) {
			return nil;
		} else {
			return photo;
		}
	} else {
		return nil;
	}
}

- (void)dealloc {
    [_title release], _title = nil;
    [_photos release], _photos = nil;
	[_tempPhotos release], _tempPhotos = nil;
	[super dealloc];
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation DisapprovingRabbitsPhoto

@synthesize photoSource = _photoSource,
size = _size,
index = _index,
caption = _caption,
url = _URL,
thumbURL = _thumbURL,
title = _title;

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithURL:(NSString*)URL smallURL:(NSString*)smallURL size:(CGSize)size {
	return [self initWithURL:URL smallURL:smallURL size:size caption:nil];
}

- (id)initWithURL:(NSString*)URL smallURL:(NSString*)smallURL size:(CGSize)size
		  caption:(NSString*)caption {
	if (self = [super init]) {
		_photoSource = nil;
		_URL = [[URL copy] retain];
		_smallURL = [smallURL copy];
		_thumbURL = [smallURL copy];
		_size = size;
		_caption = [caption copy];
		_index = NSIntegerMax;
	}
	return self;
}

- (void)dealloc {
	TT_RELEASE_SAFELY(_URL);
	TT_RELEASE_SAFELY(_smallURL);
	TT_RELEASE_SAFELY(_thumbURL);
	TT_RELEASE_SAFELY(_caption);
	[super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTPhoto

- (NSString*)URLForVersion:(TTPhotoVersion)version {
	if (version == TTPhotoVersionLarge) {
		return _URL;
	} else if (version == TTPhotoVersionMedium) {
		return _URL;
	} else if (version == TTPhotoVersionSmall) {
		return _smallURL;
	} else if (version == TTPhotoVersionThumbnail) {
		return _thumbURL;
	} else {
		return nil;
	}
}

@end
