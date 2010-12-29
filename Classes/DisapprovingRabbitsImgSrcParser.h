//
//  DisapprovingRabbitsImgSrcParser.h
//  DisapprovingRabbits
//
//  Created by James Bryan Graves on 8/7/10.
//  Copyright 2010 N/A. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DisapprovingRabbitsImgSrcParser;

@protocol DisapprovingRabbitsImgSrcParserDelegate

-(void)parser:(DisapprovingRabbitsImgSrcParser*)parser imageSrcFound:(NSString*)src index:(NSInteger)index;

@end



@interface DisapprovingRabbitsImgSrcParser : NSObject {
	
	id<DisapprovingRabbitsImgSrcParserDelegate> _delegate;
	
	NSInteger _index;
	NSString* _html;
	
	NSXMLParser* htmlParser;
	NSMutableDictionary* item;
}

@property(nonatomic,retain)id<DisapprovingRabbitsImgSrcParserDelegate> delegate;

-(id)initWithString:(NSString*)html index:(NSInteger)index;
-(void)parse;

@end