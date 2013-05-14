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
    NSURL *movieURL = [[notification userInfo] objectForKey:@"movieURL"];
    [self generateThumbnailWithURL:movieURL handler:^(CMTime requestedTime,
                                                      CGImageRef im,
                                                      CMTime actualTime,
                                                      AVAssetImageGeneratorResult result,
                                                      NSError *error) {
        if (result != AVAssetImageGeneratorSucceeded) {
            NSLog(@"couldn't generate thumbnail, error:%@", error);
        } else {
            [self->videos addObject:@{@"movieURL": movieURL,
                                     @"thumbnail": [UIImage imageWithCGImage:im]
                                    }];
        }
    }];
}

- (void)generateThumbnailWithURL:(NSURL*)movieURL handler:(AVAssetImageGeneratorCompletionHandler)handler
{
    AVURLAsset *asset=[[[AVURLAsset alloc] initWithURL:movieURL options:nil] autorelease];
    AVAssetImageGenerator *generator = [[[AVAssetImageGenerator alloc] initWithAsset:asset] autorelease];
    generator.appliesPreferredTrackTransform = TRUE;
    CMTime thumbTime = CMTimeMakeWithSeconds(0,30);
    CGSize maxSize = CGSizeMake(180, 180);
    generator.maximumSize = maxSize;
    [generator generateCGImagesAsynchronouslyForTimes:[NSArray arrayWithObject:[NSValue valueWithCMTime:thumbTime]] completionHandler:handler];
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
        
//        NSMutableArray* newVids = [[NSMutableArray alloc] init];
//        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//        NSString *documentsDirectory = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
//        
//        for (int i = 0; i < 7; ++i)
//        {
//            
//            NSURL* movieURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/incrediVids/%d.MOV",
//                                                       documentsDirectory,
//                                                       i+1]];
//            UIImage *thumbnail = [[self.videos objectAtIndex:i] objectForKey:@"thumbnail"];
//            [newVids addObject:@{@"movieURL": movieURL, @"thumbnail": thumbnail}];
//        }
//        
//        NSMutableData *data2 = [[NSMutableData alloc] init];
//        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data2];
//        [archiver encodeObject:newVids forKey:savingKey];
//        [archiver finishEncoding];
//        [data2 writeToFile:dataFilePath atomically:YES];
//        [archiver release];
//        [data2 release];

    }
    else
    {
        self->videos = [[NSMutableArray alloc] init];
    }
    
    NSLog(@"videos: %@", self->videos);

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
