//
//  GalleryViewController.m
//  incrediVid
//
//  Created by Rony Fadel on 5/1/13.
//
//

#import "GalleryViewController.h"

@interface GalleryViewController ()
@property IBOutlet UILabel *galleryLabel, *emptyGalleryLabel;
@end

@implementation GalleryViewController
@synthesize galleryLabel, emptyGalleryLabel;

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIFont* latoBlack = [UIFont fontWithName:@"Lato-Black" size:34.0];
    self.galleryLabel.font = latoBlack;
    self.emptyGalleryLabel.font = latoBlack;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissView:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

@end
