//
//  RFVideoCollection.m
//  incrediVid
//
//  Created by Rony Fadel on 5/10/13.
//
//

#import "RFVideoCollection.h"
#import <AVFoundation/AVFoundation.h>

static NSString* savingKey = @"videos";

static NSString* get_file_path_for_name(NSString* file_name)
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:file_name];
}

@interface RFVideoCollection () {
    NSMutableArray *videos;
}

@end

static RFVideoCollection *sharedVideoCollection = nil;

@implementation RFVideoCollection
@synthesize videos;

- (id)init
{
    if (self = [super init]) {
        // video collection
        [self loadCollection];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(saveCollection)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:[UIApplication sharedApplication]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(addVideoFromNotification:)
                                                     name:@"Recording Did Stop"
                                                   object:nil];
    }
    return self;
}

- (NSArray*)videos
{
    return videos;
}

- (void)addVideoFromNotification:(NSNotification*)notification
{
    NSLog(@"in addVideoFromNotification:");
    NSURL *videoURL = [[notification userInfo] objectForKey:@"videoURL"];
    NSURL *temporaryThumbnailURL = [NSURL URLWithString:[[NSBundle mainBundle] pathForResource:@"Icon" ofType:@"png"]];

    // getting time
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:videoURL];
    float duration = CMTimeGetSeconds(playerItem.duration);
    
    // making the first temporary dictionary
    NSDictionary *videoInfo = @{@"videoURL": videoURL,
                                @"duration": [NSNumber numberWithFloat:duration],
                                @"largeThumbnail": temporaryThumbnailURL,
                                @"smallThumbnail": temporaryThumbnailURL};
    int index = [self->videos count];
    [self->videos addObject:videoInfo];
    
    // generate thumbnail
    AVURLAsset *asset=[[[AVURLAsset alloc] initWithURL:videoURL options:nil] autorelease];
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform = TRUE;
    CMTime thumbTime = CMTimeMakeWithSeconds(0,1);
    CGSize maxSize = CGSizeMake(180, 180);
    generator.maximumSize = maxSize;
    [generator generateCGImagesAsynchronouslyForTimes:[NSArray arrayWithObject:[NSValue valueWithCMTime:thumbTime]]
                                    completionHandler:^(CMTime requestedTime,
                                                        CGImageRef im,
                                                        CMTime actualTime,
                                                        AVAssetImageGeneratorResult result,
                                                        NSError *error) {
                                        if (error) {
                                            NSLog(@"couldn't generate thumbnail, error:%@", error);
                                        } else {
                                            
                                            NSURL* largeThumbnailPath = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", videoURL, @".large_thumbnail.png"]];
                                            NSURL* smallThumbnailPath = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", videoURL, @".small_thumbnail.png"]];
                                            
                                            // saving large thumbnail
                                            UIImage *largeThumbnail = [UIImage imageWithCGImage:im];
                                            NSData *largeThumbnailPNGRepresentation = UIImagePNGRepresentation(largeThumbnail);
                                            [largeThumbnailPNGRepresentation writeToURL:largeThumbnailPath atomically:YES];
                                            
                                            CGSize destinationSize = CGSizeMake(40, 40);
                                            UIGraphicsBeginImageContext(destinationSize);
                                            [largeThumbnail drawInRect:CGRectMake(0,0,destinationSize.width,destinationSize.height)];
                                            UIImage *smallThumbnail = UIGraphicsGetImageFromCurrentImageContext();
                                            UIGraphicsEndImageContext();
                                            // saving small thumbnail
                                            NSData *smallThumbnailPNGRepresentation = UIImagePNGRepresentation(smallThumbnail);
                                            [smallThumbnailPNGRepresentation writeToURL:smallThumbnailPath atomically:YES];
                                            
                                            NSDictionary *videoInfo = @{@"videoURL": videoURL,
                                                                        @"duration": [NSNumber numberWithFloat:duration],
                                                                        @"largeThumbnail": largeThumbnailPath,
                                                                        @"smallThumbnail": smallThumbnailPath};

                                            [self->videos replaceObjectAtIndex:index withObject:videoInfo];
                                            [[NSNotificationCenter defaultCenter] postNotificationName:@"Thumbnail Ready" object:nil userInfo:videoInfo];
                                        }}];
}

#pragma mark File Management
- (void)saveCollection
{
    NSString *dataFilePath = get_file_path_for_name(savingKey);
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:self.videos forKey:savingKey];
    [archiver finishEncoding];
    [data writeToFile:dataFilePath atomically:YES];
    [archiver release];
    [data release];
}

- (void)loadCollection
{
    NSString *dataFilePath = get_file_path_for_name(savingKey);
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:dataFilePath])
    {
        NSData* data = [[NSMutableData alloc] initWithContentsOfFile:dataFilePath];
        NSKeyedUnarchiver* unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        self->videos = [[unarchiver decodeObjectForKey:savingKey] mutableCopy];
        [unarchiver finishDecoding];
        [unarchiver release];
        [data release];
    }
    else
    {
        self->videos = [[NSMutableArray alloc] init];
    }
}

- (void)deleteVideoWithInfo:(NSDictionary*)videoInfo
{
    [self->videos removeObject:videoInfo];
}

#pragma mark Singleton Methods

+ (RFVideoCollection*)sharedCollection
{
    @synchronized([RFVideoCollection class]) {
        if (sharedVideoCollection == nil) {
            sharedVideoCollection = [[super allocWithZone:NULL] init];
        }
    }
    return sharedVideoCollection;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [[self sharedCollection] retain];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;  //denotes an object that cannot be released
}

- (oneway void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;
}

- (void)dealloc
{
    [self->videos release];
    [super dealloc];
}
@end
