#import "Headers.h"
#import "PTPreferences.h"

static int nextValidIndex();
static void update (
    CFNotificationCenterRef center,
    void *observer,
    CFStringRef name,
    const void *object,
    CFDictionaryRef userInfo
);

static int currentIndex = 0;
static PTPreferences *PREFS = nil;
static BOOL powerDownTrackTextSet = NO;

static int nextValidIndex()
{
	BOOL firstValuePassed = NO;
	
    //Stop when the loop is complete (i has reached its initial value again)
	for (int i = (currentIndex + 1); i != currentIndex; i++)
	{
		if (i == [PREFS.modes count])
			i = 0; //Reset if we have reached the end of the modes list

		BOOL enabled = [[PREFS valueForSpecifier: @"enabled" mode: [PREFS modeForIndex: i]] boolValue];
		//Check if mode is enabled
		
		if (enabled)
			return i;
		
		firstValuePassed = YES;
	}
	return -1;
}

static void update (
    CFNotificationCenterRef center,
    void *observer,
    CFStringRef name,
    const void *object,
    CFDictionaryRef userInfo
)
{
	PREFS = [PTPreferences new];
}

%hook _UIActionSlider


%new
- (UIImageView*)knobImageView
{
	return MSHookIvar<UIImageView*>(self, "_knobImageView");
}

%new
- (void)setNewKnobImage:(UIImage*)image
{
	image = [image imageWithRenderingMode: UIImageRenderingModeAlwaysTemplate];
	[self knobImageView].image = image;
	[self knobImageView].tintColor = [PREFS tintColorForMode: [PREFS modeForIndex: currentIndex]];
}

%new
- (void)knobTapped
{
	int _nextValidIndex = nextValidIndex();
	if (!powerDownTrackTextSet)
	{
		[PREFS setPowerDownTrackText: self.trackText];
		powerDownTrackTextSet = YES;
	}
	
	if (_nextValidIndex != -1)
	{
		currentIndex = _nextValidIndex; //Switch indicies for next mode
		NSString *modeString = [PREFS modeForIndex: currentIndex];
	
		NSString *_trackText = [PREFS valueForSpecifier: @"string" mode: modeString];
		UIImage *_knobImage = [PREFS iconForMode: modeString];
	
		self.trackText = _trackText;
		[self setNewKnobImage: _knobImage];
	}
}

%end

%hook SBPowerDownController

- (void)activate
{
	%orig();
	
	//Getting access to the current instance we need
	SBPowerDownView *powerDownView = MSHookIvar<SBPowerDownView*>(self, "_powerDownView");
	_UIActionSlider *actionSlider = MSHookIvar<_UIActionSlider*>(powerDownView, "_actionSlider");
	
	UITapGestureRecognizer *knobTap = [[UITapGestureRecognizer alloc] initWithTarget: actionSlider 
			action:@selector(knobTapped)];
		knobTap.numberOfTapsRequired = 1;
		[[actionSlider _knobView] addGestureRecognizer: knobTap];
}

- (void)powerDown
{
	NSString *modeString = [PREFS modeForIndex: currentIndex];
	
	if ([modeString isEqualToString: @"PowerDown"])
		%orig;
	else if ([modeString isEqualToString: @"Reboot"])
		[[UIApplication sharedApplication] reboot];
	else if ([modeString isEqualToString: @"Respring"])
		[[UIApplication sharedApplication] terminateWithSuccess];
	else if ([modeString isEqualToString: @"SafeMode"])
		[[UIApplication sharedApplication] nonExistentMethod];
	else
		%orig;	
}

- (void)cancel
{
	currentIndex = 0; //Resets mode cycle
	%orig;
}

%end

%ctor {
	PREFS = [PTPreferences new];
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, update,
		 CFSTR("com.dpkgdan.powertap.settingsupdated"), NULL,
		  CFNotificationSuspensionBehaviorDeliverImmediately);
}