//
//  GalleryViewController.m
//  incrediVid
//
//  Created by Rony Fadel on 5/1/13.
//
//

#import "GalleryViewController.h"
#import "RFVideoCollection.h"
#import "SharingViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface GalleryViewController ()
@property IBOutlet UILabel *galleryLabel, *emptyGalleryLabel;
@property IBOutlet UIButton *doneButton;
@end

@implementation GalleryViewController
@synthesize galleryLabel, emptyGalleryLabel;

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIFont* latoBlack = [UIFont fontWithName:@"Lato-Black" size:34.0];
    self.galleryLabel.font = latoBlack;
    self.emptyGalleryLabel.font = latoBlack;
    UIFont* doneButtonFont = [UIFont fontWithName:@"Lato-Black" size:18.0];
    self.doneButton.titleLabel.font = doneButtonFont;
    self.doneButton.layer.cornerRadius = 4;
    
    [self drawGallery];
}

- (void)drawGallery
{
    RFVideoCollection* videoCollection = [RFVideoCollection sharedCollection];
    NSArray *videos = videoCollection.videos;
    NSUInteger videosCount = [videos count];
    self.emptyGalleryLabel.hidden = (videosCount != 0);
    
    int view_width = self.view.bounds.size.width;
    int numberOfColumns = 4;
    int numberOfRows = (int)ceilf( videosCount * 1.f / numberOfColumns );
    int pixelsBetweenThumbnails = 11;
    int thumbnailEdgeSize = (view_width - pixelsBetweenThumbnails * (numberOfColumns + 1)) / numberOfColumns;
    
    for (int i = 0; i < numberOfRows; ++i) {
        for (int j = 0; j < ( (i == numberOfRows - 1) ? videosCount - i * numberOfColumns : numberOfColumns); ++j)
        {
            UIImage *thumbnailImage = (UIImage*)[[videos objectAtIndex:(i * numberOfColumns + j)] objectForKey:@"thumbnail"];
            UIButton *thumbnailButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [thumbnailButton setImage:thumbnailImage forState:UIControlStateNormal];
            [thumbnailButton addTarget:self action:@selector(thumbnailClicked:) forControlEvents:UIControlEventTouchUpInside];
            thumbnailButton.tag = i * numberOfColumns + j;
            thumbnailButton.imageView.layer.cornerRadius = 6;
            
//            NSLog(@"x: %d y: %d w: %d h: %d", (pixelsBetweenThumbnails + thumbnailEdgeSize) * j,
//                                              (pixelsBetweenThumbnails + thumbnailEdgeSize) * i,
//                                              thumbnailEdgeSize,
//                                              thumbnailEdgeSize);
            
            thumbnailButton.frame = CGRectMake((pixelsBetweenThumbnails + thumbnailEdgeSize) * j + pixelsBetweenThumbnails,
                                             (pixelsBetweenThumbnails + thumbnailEdgeSize) * i + pixelsBetweenThumbnails,
                                             thumbnailEdgeSize,
                                             thumbnailEdgeSize);
            [self.galleryScrollView addSubview:thumbnailButton];
        }
    }
    
    CGFloat contentHeight = (thumbnailEdgeSize + pixelsBetweenThumbnails) * numberOfRows + pixelsBetweenThumbnails;
    self.galleryScrollView.contentSize = CGSizeMake(1, contentHeight);
}

- (void)thumbnailClicked:(id)sender
{
    NSInteger videoIndex = ((UIButton*)sender).tag;
    NSDictionary *videoInfo = [[RFVideoCollection sharedCollection].videos objectAtIndex:videoIndex];
    
    NSLog(@"videoInfo: %@", videoInfo);
    
    SharingViewController* sharingViewController = [[SharingViewController alloc]
                                                    initWithNibName:@"SharingViewController"
                                                    bundle:[NSBundle mainBundle]
                                                    videoInfo:videoInfo];
    [sharingViewController addToView:self.view];
    [self.view addSubview:sharingViewController.view];
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
