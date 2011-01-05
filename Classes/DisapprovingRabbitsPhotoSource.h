//
//  DisapprovingRabbitsPhotoSource.h
//  DisapprovingRabbits
//
//  Created by James Bryan Graves on 8/7/10.
//  Copyright 2010 N/A. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Three20Network/Three20Network.h"
#import "Three20UI/Three20UI.h"

@interface DisapprovingRabbitsDataSource : TTThumbsDataSource {

}

@end


@interface DisapprovingRabbitsPhotoSource : TTURLRequestModel <TTPhotoSource> {
	NSString* _title;
	NSMutableArray* _photos;
	NSArray* _tempPhotos;
}

@property(nonatomic,retain)NSMutableArray* photos;

-(id)initWithStories:(NSArray*)stories;

@end

@interface DisapprovingRabbitsPhoto : NSObject <TTPhoto> {
	id<TTPhotoSource> _photoSource;
	NSString* _thumbURL;
	NSString* _smallURL;
	NSString* _URL;
	CGSize _size;
	NSInteger _index;
	NSString* _caption;
	NSString* _title;
}

@property(nonatomic,retain)NSString* url;
@property(nonatomic,retain)NSString* thumbURL;
@property(nonatomic,retain)NSString* title;

- (id)initWithURL:(NSString*)URL smallURL:(NSString*)smallURL size:(CGSize)size;

- (id)initWithURL:(NSString*)URL smallURL:(NSString*)smallURL size:(CGSize)size
		  caption:(NSString*)caption;

@end