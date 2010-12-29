//
//  DisapprovingRabbitsImgSrcParser.m
//  DisapprovingRabbits
//
//  Created by James Bryan Graves on 8/7/10.
//  Copyright 2010 N/A. All rights reserved.
//

#import "DisapprovingRabbitsImgSrcParser.h"


@implementation DisapprovingRabbitsImgSrcParser

@synthesize delegate = _delegate;

-(id)initWithString:(NSString*)html index:(NSInteger)index {
	if(self = [super init]) {
		_html = html;
		_index = index;
	}
	return self;
}

-(void)parse {
    htmlParser = [[NSXMLParser alloc] initWithData:[_html dataUsingEncoding: NSASCIIStringEncoding]];
    [htmlParser setDelegate:self];
    [htmlParser setShouldProcessNamespaces:NO];
    [htmlParser setShouldReportNamespacePrefixes:NO];
    [htmlParser setShouldResolveExternalEntities:NO];
	
    [htmlParser parse];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
	if ([elementName isEqualToString:@"img"]) {
		[parser abortParsing];
		[_delegate parser:self imageSrcFound:[attributeDict objectForKey:@"src"] index:_index];
	}
}

-(void)dealloc {
	[_html release], _html = nil;
	[htmlParser release], htmlParser = nil;
	[item release], item = nil;
	[super dealloc];
}

@end
