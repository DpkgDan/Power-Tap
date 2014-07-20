#import "Headers.h"

static UIImage *rebootKnobImage = nil;
static BOOL powerDownMode = YES;

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
	UIImage *newKnobImage = [image imageWithRenderingMode: UIImageRenderingModeAlwaysTemplate];
	knobImageView.image = newKnobImage;
	
	if (powerDownMode)
		knobImageView.tintColor = [UIColor redColor];
	else
		knobImageView.tintColor = [UIColor orangeColor];
}

%new
- (void)knobTapped
{
	if (!rebootKnobImage)
		rebootKnobImage = [UIImage imageWithContentsOfFile:
		@"/Library/Application Support/Slide to Reboot/RebootKnob.png"];
	if (powerDownMode){
		powerDownMode = NO;
		self.trackText = @"slide to reboot";
		[self setNewKnobImage: rebootKnobImage];
	} else {
		powerDownMode = YES;
		self.trackText = @"slide to power off";
		[self setNewKnobImage: [UIImage imageNamed: @"PowerDownKnob"]];
	}
}

%end

%hook SBPowerDownController

- (void)powerDown
{
	if (powerDownMode)
		%orig;
	else
		[[UIApplication sharedApplication] reboot];
}

%end