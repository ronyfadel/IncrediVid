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

- (void)authenticateWithCompletion:(AuthentificationCompletionHandler)completion
{
    if (!self.accountStore) {
        self.accountStore = [[ACAccountStore alloc] init];
    }
    ACAccountType *accountTypeFacebook = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    NSArray *permissions = @[@"email", @"publish_stream"];
    NSString *facebookAudience = ACFacebookAudienceFriends;
    
    NSDictionary *options = @{ACFacebookAppIdKey: @"578010692220043",
                              ACFacebookPermissionsKey: permissions,
                              ACFacebookAudienceKey: facebookAudience};
    [self.accountStore requestAccessToAccountsWithType:accountTypeFacebook
                                          options:options
                                       completion:^(BOOL granted, NSError *error)
     {
         if(granted) {
             NSArray *accounts = [self.accountStore accountsWithAccountType:accountTypeFacebook];
             self.facebookAccount = [accounts lastObject];
         }
         completion(granted, error);
     }];
}

- (void)share:(NSDictionary*)sharingInfo completion:(SharingCompletionHandler)completion
{
    NSURL *videoURL = [sharingInfo objectForKey:@"videoURL"];
    NSData *videoData = [NSData dataWithContentsOfFile:videoURL.path];
    
    NSDictionary *parameters = @{@"title": [sharingInfo objectForKey:@"title"]};
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
