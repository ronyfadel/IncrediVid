//
//  RFVideoCollection.h
//  incrediVid
//
//  Created by Rony Fadel on 5/10/13.
//
//

#import <Foundation/Foundation.h>

@interface RFVideoCollection : NSObject

@property (nonatomic, readonly) NSArray* videos;

+ (RFVideoCollection*)sharedCollection;
- (void)addVideoFromNotification:(NSDictionary*)userInfo;

@end
