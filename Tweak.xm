#import "Headers.h"
#import "PreferencesDictionary.h"

static int nextValidIndex();
static void update (
    CFNotificationCenterRef center,
    void *observer,
    CFStringRef name,
    const void *object,
    CFDictionaryRef userInfo
);

static int currentIndex = 0;
static PreferencesDictionary *PREFS = nil;

static int nextValidIndex()
{
	BOOL firstValuePassed = NO;
									//Stop when the loop is complete (i has reached its initial value again)
	for (int i = (currentIndex + 1); !((i == currentIndex) && firstValuePassed); i++)
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
	PREFS = [PreferencesDictionary new];
}

%hook _UIActionSlider

- (void)setKnobImage:(UIImage*)image
{
	%orig();
	
	UITapGestureRecognizer *knobTap = [[UITapGestureRecognizer alloc] initWithTarget: self 
		action:@selector(knobTapped)];
	knobTap.numberOfTapsRequired = 1;
	[[self _knobView] addGestureRecognizer: knobTap];
}

%new
- (void)setNewKnobImage:(UIImage*)image
{
	UIImageView *knobImageView = MSHookIvar<UIImageView*>(self, "_knobImageView");
	knobImageView.image = image;
	knobImageView.tintColor = [PREFS tintColorForMode: [PREFS modeForIndex: currentIndex]];
}

%new
- (void)knobTapped
{
	int _nextValidIndex = nextValidIndex();
	
	//Prevents toggling on other sliders (i.e. "slide to answer")
	if (([[PREFS trackTexts] containsObject: self.trackText]) && (_nextValidIndex != -1))
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
		[[UIApplication sharedApplication] nonExistantMethod];
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
	PREFS = [PreferencesDictionary new];
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, update,
		 CFSTR("com.dpkgdan.powertap.settingsupdated"), NULL,
		  CFNotificationSuspensionBehaviorDeliverImmediately);
}