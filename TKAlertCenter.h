#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class TKAlertView;

@interface TKAlertCenter : NSObject {

	NSMutableArray *alerts;
	BOOL active;
	TKAlertView *alertView;
	CGRect alertFrame;
	
}

+ (TKAlertCenter*) defaultCenter;

- (void) postAlertWithMessage:(NSString*)message image:(UIImage*)image;
- (void) postAlertWithMessage:(NSString *)message;

@end





