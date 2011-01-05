//
//  DisapprovingRabbitsViewController.m
//  DisapprovingRabbits
//
//  Created by James Bryan Graves on 8/7/10.
//  Copyright N/A 2010. All rights reserved.
//

#import "DisapprovingRabbitsAppDelegate.h"
#import "DisapprovingRabbitsPhotoSource.h"
#import "DisapprovingRabbitsViewController.h"

static NSString* kAppId = @"158131707534769";

@implementation DisapprovingRabbitsThumbsController

- (void)updateTableLayout {
	if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
		self.tableView.contentInset = UIEdgeInsetsMake(4, 0, 0, 0);
		self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, 0);
	} else {
		[super updateTableLayout];
	}
}

- (id<TTTableViewDataSource>)createDataSource {
	return [[[DisapprovingRabbitsDataSource alloc] initWithPhotoSource:_photoSource delegate:self] autorelease];
}

@end

@implementation DisapprovingRabbitsViewController

@synthesize bannerView = _bannerView;
@synthesize facebook = _facebook;
@synthesize popoverController;

-(NSString*)flattenHTML:(NSString *)html {
	
    NSScanner* theScanner = [NSScanner scannerWithString:html];
    NSString* text = nil;
	
    while ([theScanner isAtEnd] == NO) {
        [theScanner scanUpToString:@"<" intoString:NULL];
        [theScanner scanUpToString:@">" intoString:&text];
        html = [html stringByReplacingOccurrencesOfString:
				[NSString stringWithFormat:@"%@>", text]
											   withString:@""];
    }
	html = [html stringByReplacingOccurrencesOfString:@"."
										   withString:@". "];
	html = [html stringByReplacingOccurrencesOfString:@"?"
										   withString:@"? "];
	html = [html stringByReplacingOccurrencesOfString:@"!"
										   withString:@"! "];
	html = [html stringByReplacingOccurrencesOfString:@":"
										   withString:@": "];
    return html;
}

-(void)parseXMLFileAtURL:(NSString *)URL {
	TTURLRequest* request = [TTURLRequest requestWithURL:URL delegate:self];
	request.cacheExpirationAge = 60 * 60 * 3; // seconds, 3 hours cache valid
	
	// TTURLImageResponse is just one of a set of response types you can use.
	// Also available are TTURLDataResponse and TTURLXMLResponse.
	request.response = [[[TTURLDataResponse alloc] init] autorelease];
	
	[request send];
}


#pragma mark -
#pragma mark TTURLRequestDelegate

- (void)requestDidStartLoad:(TTURLRequest*)request {
}

- (void)requestDidFinishLoad:(TTURLRequest*)request {
	if(_loading) {
		TTURLDataResponse* dataResponse = request.response;
		rssParser = [[NSXMLParser alloc] initWithData:dataResponse.data];
		[rssParser setDelegate:self];
		[rssParser setShouldProcessNamespaces:NO];
		[rssParser setShouldReportNamespacePrefixes:NO];
		[rssParser setShouldResolveExternalEntities:NO];
		[rssParser parse];
	}
}

- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error {
	//NSAssert(NO, @"Failed to load, try again.");
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"No Internet!"
													message:@"Failed to load, try again."
												   delegate:nil
										  cancelButtonTitle:NSLocalizedString(@"Ok", @"Ok")
										  otherButtonTitles:nil];
	[alert show];
	[alert release];
}

- (void)request:(TTURLRequest*)request didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge*)challenge {
	//NSAssert(NO, @"Needs authentication.");
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error!"
													message:@"Rabbits RSS not available."
												   delegate:nil
										  cancelButtonTitle:NSLocalizedString(@"Ok", @"Ok")
										  otherButtonTitles:nil];
	[alert show];
	[alert release];
}

- (void)requestDidCancelLoad:(TTURLRequest*)request {
	//NSAssert(NO, @"Request cancelled.");
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error!"
													message:@"RSS request was cancelled."
												   delegate:nil
										  cancelButtonTitle:NSLocalizedString(@"Ok", @"Ok")
										  otherButtonTitles:nil];
	[alert show];
	[alert release];
}

#pragma mark -
#pragma mark NSXMLParser delegate

-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	NSString * errorString = [NSString stringWithFormat:@"Unable to download story feed from web site (Error code %i )", [parseError code]];
	NSLog(@"error parsing XML: %@", errorString);
	
	UIAlertView * errorAlert = [[UIAlertView alloc] initWithTitle:@"Error loading content" message:errorString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[errorAlert show];
	[errorAlert release];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{			
	currentElement = [elementName copy];
	if ([elementName isEqualToString:@"item"]) {
		item = [[NSMutableDictionary alloc] init];
		currentTitle = [[NSMutableString alloc] init];
		currentDate = [[NSMutableString alloc] init];
		currentSummary = [[NSMutableString alloc] init];
		currentLink = [[NSMutableString alloc] init];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{     
	if ([elementName isEqualToString:@"item"]) {
		[item setObject:currentTitle forKey:@"title"];
		[item setObject:currentLink forKey:@"link"];
		[item setObject:[self flattenHTML:currentSummary] forKey:@"summary"];
		[item setObject:currentDate forKey:@"date"];
		
		[_stories addObject:[NSMutableDictionary dictionaryWithDictionary:item]];
		
		DisapprovingRabbitsImgSrcParser* htmlParser = [[[DisapprovingRabbitsImgSrcParser alloc] initWithString:currentSummary index:_stories.count - 1] autorelease];
		htmlParser.delegate = self;
		[htmlParser parse];
		
		
	}	
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
	if ([currentElement isEqualToString:@"title"]) {
		[currentTitle appendString:string];
	} else if ([currentElement isEqualToString:@"link"]) {
		[currentLink appendString:string];
	} else if ([currentElement isEqualToString:@"description"]) {
		[currentSummary appendString:string];
	} else if ([currentElement isEqualToString:@"pubDate"]) {
		[currentDate appendString:string];
	}
}

-(void)done {
	
	for(NSDictionary *story in _stories) {
		NSLog(@"Story --");
		for(NSString *key in [story allKeys]) {
			NSString *value = [story objectForKey:key];
			
			NSLog(@"%@ : %@", key, value);
		}
		NSLog(@"\n\n\n");
	}

	self.photoSource = [[DisapprovingRabbitsPhotoSource alloc] initWithStories:_stories];
	[self showLoading:NO];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
	_loading = NO;
	// call reloadData on main thread or the connection will never succeed
	[self performSelectorOnMainThread:@selector(done) withObject:nil waitUntilDone:NO];
}

-(void)parser:(DisapprovingRabbitsImgSrcParser*)parser imageSrcFound:(NSString*)src index:(NSInteger)index {
	NSMutableDictionary* story = [_stories objectAtIndex:index];
	[story setValue:src forKey:@"imageURL"];
	//!!! do not reloadData from here since you are in a separated thread!!!
	//[self performSelectorOnMainThread:@selector(done) withObject:nil waitUntilDone:NO];
}

-(void)showADBanner {
	[UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^(void){		
		_bannerView.frame = CGRectMake(_bannerView.frame.origin.x,
									   self.navigationController.navigationBar.frame.size.height + 20,
									   _bannerView.frame.size.width,
									   _bannerView.frame.size.height);
	} completion:nil];
}

-(void)hideADBanner {
	[UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^(void){
		_bannerView.frame = CGRectMake(_bannerView.frame.origin.x,
									   0 - [UIApplication sharedApplication].statusBarFrame.size.height - _bannerView.frame.size.height,
									   _bannerView.frame.size.width,
									   _bannerView.frame.size.height);
	} completion:nil];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
-(void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	_stories = [[NSMutableArray alloc] init];
	[self parseXMLFileAtURL:@"http://feeds.feedburner.com/DisapprovingRabbits"];
	[self showEmpty:NO];
	[self showLoading:YES];
}

-(void)viewDidLoad {
	[super viewDidLoad];
	
	self.statusBarStyle = UIStatusBarStyleBlackTranslucent;
    self.navigationBarStyle = UIBarStyleBlackTranslucent;
    self.navigationBarTintColor = nil;
    self.wantsFullScreenLayout = YES;
    self.hidesBottomBarWhenPushed = YES;
	
	self.defaultImage = [UIImage imageNamed:@"bg.png"];
	
	_toolbar.tintColor = [UIColor blackColor];
	
	_loading = YES;
	
	_permissions =  [[NSArray arrayWithObjects: 
					  @"read_stream", @"offline_access",nil] retain];
	
	self.view.autoresizesSubviews = YES;
	self.view.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
	
	_bannerView = [[ADBannerView alloc] init];
	_bannerView.requiredContentSizeIdentifiers = [NSSet setWithObjects:ADBannerContentSizeIdentifierLandscape,
																		ADBannerContentSizeIdentifierPortrait,
																		nil];
	_bannerView.delegate = self;
	[self.view addSubview:_bannerView];
	[self hideADBanner];
	
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
		_bannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierLandscape;
	} else {
		_bannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
	}

}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	if([self isShowingChrome])
		[self showADBanner];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

-(void)reload {
	[currentTitle release], currentTitle = [[NSMutableString alloc] init];
	[currentDate release], currentDate = [[NSMutableString alloc] init];
	[currentSummary release], currentSummary = [[NSMutableString alloc] init];
	[currentLink release], currentLink = [[NSMutableString alloc] init];
	_loading = YES;
	[_stories release], _stories = [[NSMutableArray alloc] init];
	[self parseXMLFileAtURL:@"http://feeds.feedburner.com/DisapprovingRabbits"];
}

-(void)sleep {
	currentTitle = nil;
	currentDate = nil;
	currentSummary = nil;
	currentLink = nil;
	_loading = NO;
	_stories = nil;
}

- (void)didMoveToPhoto:(id<TTPhoto>)photo fromPhoto:(id<TTPhoto>)fromPhoto {
	//self.photoSource.title = ((DisapprovingRabbitsPhoto*)photo).title;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)publishStream {
	SBJSON *jsonWriter = [[SBJSON new] autorelease];
	
	NSDictionary* actionLinks = [NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:
														   @"Disapproving Rabbits", @"text",
														   @"http://www.disapprovingrabbits.com/", @"href",
														   nil], nil];
	
	NSDictionary *mediaDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
									 @"image", @"type",
									 ((DisapprovingRabbitsPhoto*)self.centerPhoto).url, @"src", 
									 @"http://www.disapprovingrabbits.com", @"href",
									 nil];
	NSArray *mediaArray = [NSArray arrayWithObject:mediaDictionary];
	
	NSString *actionLinksStr = [jsonWriter stringWithObject:actionLinks];
	NSDictionary* attachment = [NSDictionary dictionaryWithObjectsAndKeys:
								((DisapprovingRabbitsPhoto*)self.centerPhoto).title, @"name",
								self.centerPhoto.caption, @"caption",
								@"http://www.disapprovingrabbits.com", @"href",
								mediaArray, @"media",
								nil];
	
	NSString *attachmentStr = [jsonWriter stringWithObject:attachment];
	NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								   @"Share on Facebook",  @"user_message_prompt",
								   actionLinksStr, @"action_links",
								   attachmentStr, @"attachment",
								   nil];
	[_facebook dialog:@"stream.publish"
			andParams:params
		  andDelegate:self];
}

-(IBAction)facebookClick {
	if(!_facebook) {
		_facebook = [[Facebook alloc] initWithAppId:kAppId];
		[_facebook authorize:_permissions delegate:self];
	} else {
		[self publishStream];
	}
}

#pragma mark -
#pragma mark FBSessionDelegate

-(void) fbDidLogin {
	NSLog(@"Did login");
	[self publishStream];
}

- (void)fbDidNotLogin:(BOOL)cancelled {
	NSLog(@"Did not login");
}

-(void) fbDidLogout {
	NSLog(@"Did not logout");
}

- (void)dialogDidComplete:(FBDialog*)dialog{
	NSLog(@"publish successfully");
}

-(void)dealloc {

	_bannerView.delegate = nil;
	[_bannerView release], _bannerView = nil;
	[popoverController release], popoverController = nil;
	
	[_stories release], _stories = nil;
	
	[rssParser release], rssParser = nil;
	[item release], item = nil;
	[currentElement release], currentElement = nil;
	[currentTitle release], currentTitle = nil;
	[currentDate release], currentDate = nil;
	[currentSummary release], currentSummary = nil;
	[currentLink release], currentLink = nil;
	[super dealloc];
}

#pragma mark -
#pragma mark ADBannerViewDelegate

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
	[self hideADBanner];
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner {
	if([self isShowingChrome])
		[self showADBanner];
}

#pragma mark -
#pragma mark TTPhotoViewController

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showBarsAnimationDidStop {
	[super showBarsAnimationDidStop];
	[self showADBanner];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)hideBarsAnimationDidStop {
	[super hideBarsAnimationDidStop];
	[self hideADBanner];
}

- (TTThumbsViewController*)createThumbsViewController {
	return [[[DisapprovingRabbitsThumbsController alloc] initWithDelegate:self] autorelease];
}

- (void)showThumbnails {
	NSString* URL = [self URLForThumbnails];
	if (!_thumbsController) {
		// The photo source had no URL mapping in TTURLMap, so we let the subclass show the thumbs
		_thumbsController = [[self createThumbsViewController] retain];
		_thumbsController.photoSource = _photoSource;
	}
	
	if ([self.navigationController isKindOfClass:[TTNavigationController class]]) {
		[(TTNavigationController*)self.navigationController
		 pushViewController: _thumbsController
		 animatedWithTransition: UIViewAnimationTransitionCurlDown];
	} else {
		if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
			if(!self.popoverController) {
				UIPopoverController *controller = [[UIPopoverController alloc] initWithContentViewController:_thumbsController];
				self.popoverController = controller;          
				popoverController.delegate = self;
				[popoverController presentPopoverFromBarButtonItem:self.navigationItem.rightBarButtonItem
										  permittedArrowDirections:UIPopoverArrowDirectionUp
														  animated:YES];
				[controller release];
			} else {
				[self.popoverController dismissPopoverAnimated:YES];
				self.popoverController = nil;
			}
		} else {
			[self.navigationController pushViewController:_thumbsController animated:YES];
		}
    }
}

#pragma mark -
#pragma mark UIPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
	self.popoverController = nil;
}

@end
