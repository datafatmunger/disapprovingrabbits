//
//  DisapprovingRabbitsViewController.h
//  DisapprovingRabbits
//
//  Created by James Bryan Graves on 8/7/10.
//  Copyright N/A 2010. All rights reserved.
//

#import "DisapprovingRabbitsImgSrcParser.h"

#import <iAd/iAd.h>
#import "FBConnect.h"

#import "Three20Network/Three20Network.h"
#import "Three20UI/Three20UI.h"
#import <UIKit/UIKit.h>

@interface DisapprovingRabbitsThumbsController : TTThumbsViewController
{

}

@end


@interface DisapprovingRabbitsViewController : TTPhotoViewController <DisapprovingRabbitsImgSrcParserDelegate
																		,ADBannerViewDelegate
																		,FBDialogDelegate
																		,FBSessionDelegate
																		,NSXMLParserDelegate
																		,UIPopoverControllerDelegate> {
	
	BOOL _loading;
	
	NSMutableArray* _stories;
	
	NSXMLParser* rssParser;
	NSMutableDictionary* item;
	NSString*  currentElement;
	NSMutableString* currentTitle;
	NSMutableString* currentDate;
	NSMutableString* currentSummary;
	NSMutableString* currentLink;
	
	NSMutableData* _receivedData;
																			
	UIPopoverController *popoverController;
	
	ADBannerView *_bannerView;
	UIImageView *_facebookImageView;
	Facebook *_facebook;
	NSArray *_permissions;																		
}
	
@property(nonatomic,retain)IBOutlet ADBannerView *bannerView;
@property(nonatomic,retain)Facebook *facebook;
@property(nonatomic,retain)UIPopoverController *popoverController;

-(IBAction)facebookClick;
-(void)reload;
-(void)sleep;


@end

