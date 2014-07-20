@interface PTPreferences : NSObject {
	NSArray *_modes;
	NSDictionary *_preferences;
}

@property (readonly) NSDictionary *preferences;
@property (readonly) NSArray *modes;

- (NSString*)modeForIndex:(int)index;
- (NSString*)valueForSpecifier:(NSString*)specifier mode:(NSString*)mode;
- (UIImage*)iconForMode:(NSString*)mode;
- (UIColor*)tintColorForMode:(NSString*)mode;
- (NSArray*)trackTexts;

@end