#import <Preferences/Preferences.h>

@interface PowerTapPrefsListController: PSListController {
}
@end


@implementation PowerTapPrefsListController

/* - (id)init
{
	if ((self = [super init]))
	{
		UIViewController *viewController = [UIViewController new];
		UITableView *tableView = [UITableView new];
	}
	return self;
} */

- (id)specifiers {
	if(!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"PowerTapPrefs" target:self];
	}
	
	return _specifiers;
}

-(void)openPaypalLink:(id)param
{
	 [[UIApplication sharedApplication] openURL:[NSURL URLWithString: 
	 @"https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=RZR4L777XGYF2&lc=US&item_name=Power%20Tap&currency_code=USD&bn=PP%2dDonationsBF%3abtn_donateCC_LG%2egif%3aNonHosted"]];
}

@end

// vim:ft=objc
