//
//  IAPHelper.m
//  incrediVid
//
//  Created by Rony Fadel on 5/19/13.
//
//
#import "IAPHelper.h"
#import <StoreKit/StoreKit.h>

@interface IAPHelper () <SKProductsRequestDelegate, SKPaymentTransactionObserver>
@property (retain) SKProductsRequest *productsRequest;
@property RequestProductsCompletionHandler _completionHandler;
@property (retain) NSSet * productIdentifiers;
@property (retain) NSMutableSet * purchasedProductIdentifiers;
@end

@implementation IAPHelper
//@synthesize _productsRequest, 

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers {
    
    if ((self = [super init])) {
        
        // Store product identifiers
        self.productIdentifiers = productIdentifiers;
        
        // Check for previously purchased products
        self.purchasedProductIdentifiers = [NSMutableSet set];
        for (NSString * productIdentifier in _productIdentifiers) {
            BOOL productPurchased = [[NSUserDefaults standardUserDefaults] boolForKey:productIdentifier];
            if (productPurchased) {
                [self.purchasedProductIdentifiers addObject:productIdentifier];
                NSLog(@"Previously purchased: %@", productIdentifier);
            } else {
                NSLog(@"Not purchased: %@", productIdentifier);
            }
        }
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
}

- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler {
    
    // 1
    self._completionHandler = [completionHandler copy];
    
    // 2
    self.productsRequest = [[[SKProductsRequest alloc] initWithProductIdentifiers:_productIdentifiers] autorelease];
    self.productsRequest.delegate = self;
    [self.productsRequest start];
}

#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    NSArray * skProducts = response.products;
    self._completionHandler(YES, skProducts);
    self._completionHandler = nil;
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    _productsRequest = nil;
    self._completionHandler(NO, nil);
    self._completionHandler = nil;
}

#pragma mark - Buying
- (BOOL)productPurchased:(NSString *)productIdentifier {
    return [_purchasedProductIdentifiers containsObject:productIdentifier];
}

- (void)buyProduct:(SKProduct *)product {
    NSLog(@"Buying %@...", product.productIdentifier);
    
    SKPayment * payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction * transaction in transactions) {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    };
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"completeTransaction...");
    
    [self provideContentForProductIdentifier:transaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"restoreTransaction...");
    
    [self provideContentForProductIdentifier:transaction.originalTransaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    
    NSLog(@"failedTransaction...");
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        NSLog(@"Transaction error: %@", transaction.error.localizedDescription);
    }
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

// Add to top of file
//NSString *const IAPHelperProductPurchasedNotification = @"IAPHelperProductPurchasedNotification";

// Add new method
- (void)provideContentForProductIdentifier:(NSString *)productIdentifier {
    NSLog(@"providing content for product identifier");
    [_purchasedProductIdentifiers addObject:productIdentifier];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:productIdentifier];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"IAPHelperProductPurchasedNotification" object:productIdentifier userInfo:nil];
}

- (void)restoreCompletedTransactions {
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)dealloc
{
    [self.productsRequest release];
    [self.productIdentifiers release];
    [self.purchasedProductIdentifiers release];
    [super dealloc];
}

@end
