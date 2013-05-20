//
//  RFIAHelper.h
//  incrediVid
//
//  Created by Rony Fadel on 5/19/13.
//
//

#import "IAPHelper.h"

@interface RFIAPHelper : IAPHelper
+ (RFIAPHelper *)sharedInstance;
+ (BOOL)isPro;
@property (retain) SKProduct *upgradeToProProduct;
@end

