//
//  GalleryViewController.m
//  incrediVid
//
//  Created by Rony Fadel on 5/1/13.
//
//

#import "GalleryViewController.h"
#import "RFVideoCollection.h"

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
    int numberOfRows = videosCount / numberOfColumns;
    int pixelsBetweenThumbnails = 5;
    int thumbnailEdgeSize = (view_width - pixelsBetweenThumbnails * (numberOfColumns + 1)) / pixelsBetweenThumbnails;
    
    for (int i = 0; i < numberOfRows; ++i) {
        for (int j = 0; j < numberOfColumns; ++j) {
            UIImage *thumbnailImage = (UIImage*)[[videos objectAtIndex:(i * numberOfColumns + j)] objectForKey:@"thumbnail"];
            UIImageView *thumbnailView = [[[UIImageView alloc] initWithImage:thumbnailImage] autorelease];
            thumbnailView.frame = CGRectMake((pixelsBetweenThumbnails + thumbnailEdgeSize) * j,
                                             (pixelsBetweenThumbnails + thumbnailEdgeSize) * i,
                                             thumbnailEdgeSize,
                                             thumbnailEdgeSize);
            [self.view addSubview:thumbnailView];
        }
    }
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
