//
//  SharingViewController.m
//  incrediVid
//
//  Created by Rony Fadel on 5/2/13.
//
//

#import <QuartzCore/QuartzCore.h>
#import "ProUpgradeViewController.h"
#import "RFFilterThumbnailView.h"
#import "RFIAPHelper.h"
#import "TKAlertCenter.h"


@interface ProUpgradeViewController ()
@property (retain) IBOutletCollection(UIButton) NSArray *buttons;
@property (retain) IBOutletCollection(UILabel) NSArray *labels;
@property IBOutlet UIButton *upgradeToProButton;
@end

@implementation ProUpgradeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIFont* latoBlackLarge = [UIFont fontWithName:@"Lato-Black" size:27.0];
    UIFont* latoBlack = [UIFont fontWithName:@"Lato-Black" size:24.0];
    UIFont* latoBlackSmall = [UIFont fontWithName:@"Lato-Black" size:22.0];
    self.titleLabel.font = latoBlack;
    NSLog(@"%@", self.labels);
    for (UILabel* label in self.labels) {
        label.font = latoBlackSmall;
        label.adjustsFontSizeToFitWidth = YES;
    }
    
    for (UIButton* button in self.buttons) {
        button.titleLabel.adjustsFontSizeToFitWidth = YES;
        button.titleLabel.font = latoBlackSmall;
        button.layer.cornerRadius = 6;
    }
    self.upgradeToProButton.titleLabel.font = latoBlackLarge;
    
    RFFilterThumbnailView *thumbnailView = [[[RFFilterThumbnailView alloc] initWithFrame:CGRectMake(8, 69, 63, 63)
                                                                                   info:@{@"tag": @0,
                                                                                        @"imageFileName":@"filter-4.png",
                                                                                        @"imageTitle": @"normal",
                                                                                        @"hasButton": @NO}] autorelease];
    
    RFFilterThumbnailView *thumbnailView2 = [[[RFFilterThumbnailView alloc] initWithFrame:CGRectMake(80.5, 69, 63, 63)
                                                                                   info:@{@"tag": @0,
                                                                                        @"imageFileName":@"filter-5.png",
                                                                                        @"imageTitle": @"zoonie",
                                                                                        @"hasButton": @NO}] autorelease];

    RFFilterThumbnailView *thumbnailView3 = [[[RFFilterThumbnailView alloc] initWithFrame:CGRectMake(153, 69, 63, 63)
                                                                                   info:@{@"tag": @0,
                                                                                        @"imageFileName":@"filter-6.png",
                                                                                        @"imageTitle": @"vintage",
                                                                                        @"hasButton": @NO}] autorelease];


    [self.holderView addSubview:thumbnailView];
    [self.holderView addSubview:thumbnailView2];
    [self.holderView addSubview:thumbnailView3];
    
    RFIAPHelper *iAPHelperInstance = [RFIAPHelper sharedInstance];
    
    if (iAPHelperInstance.upgradeToProProduct) {
        NSNumberFormatter *numberFormatter = [[[NSNumberFormatter alloc] init] autorelease];
        [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [numberFormatter setLocale:iAPHelperInstance.upgradeToProProduct.priceLocale];
        NSString *formattedPriceString = [numberFormatter stringFromNumber:iAPHelperInstance.upgradeToProProduct.price];
        
        [self.upgradeToProButton setTitle:[NSString stringWithFormat:@"%@ (%@)", self.upgradeToProButton.titleLabel.text,
                                           formattedPriceString]
                                 forState:UIControlStateNormal];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
}

- (IBAction)upgradeToPro
{
    NSLog(@"upgrading to pro");
    RFIAPHelper *iAPHelperInstance = [RFIAPHelper sharedInstance];

    if (iAPHelperInstance.upgradeToProProduct) {
        [iAPHelperInstance buyProduct:iAPHelperInstance.upgradeToProProduct];
    } else {
        [iAPHelperInstance requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
            if (success) {
                iAPHelperInstance.upgradeToProProduct = [products objectAtIndex:0];
                [iAPHelperInstance buyProduct:iAPHelperInstance.upgradeToProProduct];
            } else {
                [[TKAlertCenter defaultCenter] postAlertWithMessage:@"Error: Please try to upgrade Later"];
            }
        }];
    }
}

- (IBAction)restorePurchases
{
    [[RFIAPHelper sharedInstance] restoreCompletedTransactions];
}

@end
