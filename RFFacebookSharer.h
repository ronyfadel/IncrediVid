//
//  RFFacebookSharer.h
//  incrediVid
//
//  Created by Rony Fadel on 5/21/13.
//
//

#import <Foundation/Foundation.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>

typedef void (^AuthentificationCompletionHandler)(BOOL granted, NSError *error);
typedef void (^SharingCompletionHandler)(BOOL shared, NSError *error);

@interface RFFacebookSharer : NSObject
+ (BOOL)supportsNativeFacebookSharing;
- (void)authenticateWithCompletion:(AuthentificationCompletionHandler)completion;
- (void)share:(NSDictionary*)sharingInfo completion:(SharingCompletionHandler)completion;
@end
