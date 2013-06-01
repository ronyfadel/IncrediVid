//
//  RFFacebookSharer.m
//  incrediVid
//
//  Created by Rony Fadel on 5/21/13.
//
//

#import "RFFacebookSharer.h"

@interface RFFacebookSharer ()
@property(retain) ACAccountStore *accountStore;
@property(retain) ACAccount *facebookAccount;
@end

@implementation RFFacebookSharer

+ (BOOL)supportsNativeFacebookSharing
{
    BOOL isiOS6OrAbove = [[[UIDevice currentDevice] systemVersion] compare:@"6.0" options:NSNumericSearch] != NSOrderedAscending;    
    return isiOS6OrAbove;
}

- (void)authenticateWithCompletion:(AuthentificationCompletionHandler)completion
{
    if (!self.accountStore) {
        self.accountStore = [[ACAccountStore alloc] init];
    }
    ACAccountType *facebookAccountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    __block NSArray *permissions = @[@"read_stream", @"email"];
    __block NSDictionary *options = @{ACFacebookAppIdKey: @"578010692220043",
                                      ACFacebookPermissionsKey: permissions,
                                      ACFacebookAudienceKey: ACFacebookAudienceFriends};
    
    [self.accountStore requestAccessToAccountsWithType:facebookAccountType
                                               options:options
                                            completion:^(BOOL granted, NSError *error)
     {
         if (granted) {
             permissions = @[@"publish_stream"];
             options = @{ACFacebookAppIdKey: @"578010692220043",
                         ACFacebookPermissionsKey: permissions,
                         ACFacebookAudienceKey: ACFacebookAudienceFriends};
             [self.accountStore requestAccessToAccountsWithType:facebookAccountType
                                                        options:options
                                                     completion:^(BOOL granted, NSError *error){
                                                         if (granted) {
                                                             NSArray *accounts = [self.accountStore accountsWithAccountType:facebookAccountType];
                                                             self.facebookAccount = [accounts lastObject];
                                                         }
                                                         completion(granted, error);
                                                     }];
         } else {
             completion(granted, error);
         }
     }];
}

- (void)share:(NSDictionary*)sharingInfo completion:(SharingCompletionHandler)completion
{
    NSURL *videoURL = [sharingInfo objectForKey:@"videoURL"];
    NSString *title = [sharingInfo objectForKey:@"videoTitle"];
    NSData *videoData = [NSData dataWithContentsOfFile:videoURL.path];
    
    NSDictionary *parameters = @{@"title": title};
    NSURL *feedURL = [NSURL URLWithString:@"https://graph.facebook.com/me/videos"];
    SLRequest *feedRequest = [SLRequest
                              requestForServiceType:SLServiceTypeFacebook
                              requestMethod:SLRequestMethodPOST
                              URL:feedURL
                              parameters:parameters];
    
    [feedRequest addMultipartData:videoData
                         withName:@"source"
                             type:@"video/quicktime"
                         filename:[videoURL absoluteString]];
    
    feedRequest.account = self.facebookAccount;
    
    [feedRequest performRequestWithHandler:^(NSData *responseData,
                                             NSHTTPURLResponse *urlResponse,
                                             NSError *error)
     {
         error ? completion(NO, error) : completion(YES, nil);
     }];
}

- (void)dealloc
{
    [self.facebookAccount release];
    [self.accountStore release];
    [super dealloc];
}


@end
