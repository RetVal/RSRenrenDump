//
//  RSAlbumLibrary.h
//  RSRenren
//
//  Created by Closure on 10/14/13.
//  Copyright (c) 2013 RetVal. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol RSAblumLibraryDelegate;

@interface RSAlbum : NSObject
@property (nonatomic, readonly, strong) NSString *name;
@property (nonatomic, readonly, strong) NSString *albumId;
@property (nonatomic, readonly, strong) NSString *photoNumber;
@property (nonatomic, readonly, assign) BOOL disabled; // default as NO
- (id)initWithProperty:(id)property;
@end

@interface RSAlbumLibrary : NSObject
- (id)initWithAnaylzer:(id)analyzer delegate:(id<RSAblumLibraryDelegate>)delegate;
- (void)start;
@end

@protocol RSAblumLibraryDelegate
@required
- (void)albumLibraray:(RSAlbumLibrary *)albumLibrary finishUpdate:(NSArray *)albums;
- (void)albumLibraray:(RSAlbumLibrary *)albumLibrary failedWithError:(NSError *)error;
@end