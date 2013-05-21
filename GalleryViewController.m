//
//  GalleryViewController.m
//  incrediVid
//
//  Created by Rony Fadel on 5/1/13.
//
//

#import "GalleryViewController.h"
#import "RFVideoCollection.h"
#import <QuartzCore/QuartzCore.h>

@interface GalleryViewController ()
@property IBOutlet UILabel *galleryLabel, *emptyGalleryLabel;
@property IBOutlet UIButton *doneButton;
@property IBOutlet UIScrollView* galleryScrollView;
@property (retain)SharingViewController *sharingViewController;
@end

@implementation GalleryViewController

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
    // remove all subviews from scroll view first
    for (UIView* subview in self.galleryScrollView.subviews) {
        [subview removeFromSuperview];
    }

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
            NSDictionary *videoInfo = [videos objectAtIndex:(i * numberOfColumns + j)];
            NSURL *thumbnailImagePath = [videoInfo objectForKey:@"smallThumbnail"];
            UIImage* thumbnailImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:thumbnailImagePath]];
            
            UIButton *thumbnailButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [thumbnailButton setBackgroundImage:thumbnailImage forState:UIControlStateNormal];
            [thumbnailButton addTarget:self action:@selector(thumbnailClicked:) forControlEvents:UIControlEventTouchUpInside];
            thumbnailButton.tag = i * numberOfColumns + j;
            thumbnailButton.layer.cornerRadius = 6;
            thumbnailButton.layer.masksToBounds = YES;
            
//            NSLog(@"x: %d y: %d w: %d h: %d", (pixelsBetweenThumbnails + thumbnailEdgeSize) * j,
//                                              (pixelsBetweenThumbnails + thumbnailEdgeSize) * i,
//                                              thumbnailEdgeSize,
//                                              thumbnailEdgeSize);
            
            thumbnailButton.frame = CGRectMake((pixelsBetweenThumbnails + thumbnailEdgeSize) * j + pixelsBetweenThumbnails,
                                             (pixelsBetweenThumbnails + thumbnailEdgeSize) * i + pixelsBetweenThumbnails,
                                             thumbnailEdgeSize,
                                             thumbnailEdgeSize);
            
            float duration = [[videoInfo objectForKey:@"duration"] floatValue];
            int minutes = (int)duration / 60;
            int seconds = (int)duration - minutes * 60;
            NSString* durationString = [NSString stringWithFormat:@"%02d:%02d  ", minutes, seconds];
            
            UILabel *durationLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                                0.8 * thumbnailButton.bounds.size.height,
                                                                                thumbnailButton.bounds.size.width,
                                                                                0.2 * thumbnailButton.bounds.size.height)] autorelease];

            durationLabel.text = durationString;
            durationLabel.font = [UIFont fontWithName:@"Lato-Black" size:10.0];
            durationLabel.textColor = [UIColor whiteColor];
            durationLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
            durationLabel.textAlignment = NSTextAlignmentRight;
//            durationLabel.textAlignment = nste
            
            [thumbnailButton addSubview:durationLabel];
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
    
    self.sharingViewController = [[SharingViewController alloc]
                                  initWithNibName:@"SharingViewController"
                                  bundle:[NSBundle mainBundle]
                                  videoInfo:videoInfo];
    self.sharingViewController.delegate = self;
    
    [self.sharingViewController presentRFModalViewController:self.view];
}

- (void)modalViewControllerDismissed
{
    [self drawGallery];
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
