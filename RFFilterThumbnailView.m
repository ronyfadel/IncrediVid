//
//  RFFilterThumbnailVIew.m
//  incrediVid
//
//  Created by Rony Fadel on 5/19/13.
//
//

#import <QuartzCore/QuartzCore.h>
#import "RFFilterThumbnailView.h"

@interface RFFilterThumbnailView ()
@property (assign) UIButton* thumbnailButton;
@end

@implementation RFFilterThumbnailView

- (id)initWithFrame:(CGRect)frame info:(NSDictionary*)info
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupWithInfo:(NSDictionary*)info];
    }
    return self;
}

- (void)setupWithInfo:(NSDictionary*)info
{
    NSInteger tag = [[info objectForKey:@"tag"] intValue];
    NSString* imageFileName = [info objectForKey:@"imageFileName"];
    NSString* imageTitle = [info objectForKey:@"imageTitle"];
    BOOL hasButton = [[info objectForKey:@"hasButton"] boolValue];
    id delegate = [info objectForKey:@"delegate"];
    
    NSLog(@"XXX: imageFileName -->    %@", imageFileName);
    
    UIColor *glowingColor = [UIColor colorWithRed:(62.f / 255.f) green:(132 / 255.f) blue:(255.f / 255.f) alpha:1];

    self.backgroundColor = [UIColor clearColor];
    self.layer.shadowOffset = CGSizeMake(0, 0);
    self.layer.shadowOpacity = 1;
    self.layer.shadowColor = glowingColor.CGColor;
    self.layer.shadowPath = [[UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:4] CGPath];
    self.layer.shadowRadius = 0;

    UIButton *thumbnailButton = [UIButton buttonWithType:UIButtonTypeCustom];
    if (! hasButton) {
        thumbnailButton.userInteractionEnabled = NO;
    }

    thumbnailButton.tag = tag;
    thumbnailButton.frame = self.bounds;
    thumbnailButton.layer.cornerRadius = 4.f;
    thumbnailButton.layer.masksToBounds = YES;
    thumbnailButton.layer.borderColor = glowingColor.CGColor;
    
    [thumbnailButton addTarget:delegate action:@selector(newFilterChosen:) forControlEvents:UIControlEventTouchUpInside];
    [thumbnailButton setBackgroundImage:[UIImage imageNamed:imageFileName] forState:UIControlStateNormal];
    
    UILabel *filterName = [[[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                    0.6f * self.frame.size.width,
                                                                    self.frame.size.width,
                                                                    0.2f * self.frame.size.width)] autorelease];
    filterName.text = imageTitle;
    filterName.font = [UIFont fontWithName:@"Lato-Black" size:12.0];
    filterName.textColor = [UIColor whiteColor];
    filterName.backgroundColor = [UIColor clearColor];
    filterName.textAlignment = NSTextAlignmentCenter;
    [thumbnailButton addSubview:filterName];
    
    self.thumbnailButton = thumbnailButton;
    [self addSubview:thumbnailButton];
}

- (void)highlight:(BOOL)y
{
    if (y) {
        self.layer.shadowRadius = 6;
        self.thumbnailButton.layer.borderWidth = 2;
    } else {
        self.layer.shadowRadius = 0;
        self.thumbnailButton.layer.borderWidth = 0;
    }
}

@end
