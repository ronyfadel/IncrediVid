//
//  RFIAPHelper.m
//  incrediVid
//
//  Created by Rony Fadel on 5/19/13.
//
//

#import "RFIAPHelper.h"

@interface RFIAPHelper ()
@end

@implementation RFIAPHelper


+ (RFIAPHelper *)sharedInstance
{
    static dispatch_once_t once;
    static RFIAPHelper * sharedInstance;
    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects:
                                      @"com.ronyfadel.incrediVid.incrediVidPRO",
                                      nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
        
        [sharedInstance requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
            if (success) {
                sharedInstance.upgradeToProProduct = [products objectAtIndex:0];
            } else {NSLog(@"abysmal fail");}
        }];
    });
    return sharedInstance;
}

+ (BOOL)isPro
{
    return [[self sharedInstance] productPurchased:@"com.ronyfadel.incrediVid.incrediVidPRO"];
}

@end
