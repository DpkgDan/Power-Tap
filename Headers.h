#import <UIKit/UIKit.h>
#import "substrate.h"

@interface _UIActionSlider : UIView

@property (readwrite) NSString *trackText;
@property (readwrite) UIImage *knobImage;

- (UIView*)_knobView;
- (void)setNewKnobImage:(UIImage*)image;
- (void)knobTapped;

@end

@interface UIApplication (PowerOptions)

- (void)reboot;
- (void)terminateWithSuccess;
- (void)nonExistantMethod;

@end