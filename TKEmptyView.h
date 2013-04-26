#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

typedef enum {
	TKEmptyViewImageHeart,
	TKEmptyViewImageMusicNote,
    TKEmptyViewImageStation,
} TKEmptyViewImage;

@interface TKEmptyView : UIView {	
	UILabel *titleLabel, *subtitleLabel;
	UIImageView *imageView;
}

@property (retain,nonatomic) UIImageView *imageView;
@property (retain,nonatomic) UILabel *titleLabel;
@property (retain,nonatomic) UILabel *subtitleLabel;

- (id) initWithFrame:(CGRect)frame 
				mask:(UIImage*)image 
			   title:(NSString*)titleString 
			subtitle:(NSString*)subtitleString;


- (id) initWithFrame:(CGRect)frame 
	  emptyViewImage:(TKEmptyViewImage)image 
			   title:(NSString*)titleString 
			subtitle:(NSString*)subtitleString;


- (void) setImage:(UIImage*)image;
- (void) setEmptyImage:(TKEmptyViewImage)image;


@end

