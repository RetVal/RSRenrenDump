//
//  main.m
//  Black-kousu
//
//  Created by Closure on 11/24/13.
//  Copyright (c) 2013 RetVal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "RSCoreAnalyzer.h"
#import "RSAlbumLibrary.h"
#import "RSAccount.h"
#import "RSRemoteDataBase.h"
#import "RSLikeModel.h"

@class Service;
static Service *_service = nil;

@interface NSString (FilterServices)
- (NSString *)filter;
@end

@implementation NSString (FilterServices)

- (NSString *)filter {
    NSMutableString *filterString = [self mutableCopy];
    [filterString replaceOccurrencesOfString:@"340278563" withString:@"么么哒" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [filterString length])];
    return filterString;
}

@end

@interface Service : NSObject <RSCoreAnalyzerDelegate, RSAblumLibraryDelegate>
{
    RSCoreAnalyzer *_analyzer;
    RSAlbumLibrary *_library;
    RSAccount *_account;
    RSAlbum *_selectedAlbum;
}
@property (nonatomic, strong) RSCoreAnalyzer *analyzer;
@property (nonatomic, strong) RSAlbumLibrary *library;
@property (nonatomic, strong) RSAccount *account;
@property (nonatomic, strong) NSString *userContent;
@property (nonatomic, assign) NSTimeInterval step;
@property (nonatomic, strong) NSData *imageData;
@end

@implementation Service
+ (void)exitWithStatus:(NSInteger)statusCode {
    exit((int)statusCode);
}
- (id)initWithAccount:(RSAccount *)account {
    if (self = [super init]) {
        _account = account;
        _analyzer = [RSCoreAnalyzer analyzerWithAccount:[_account accountId] password:[_account password]];
        [_analyzer setDelegate:self];
    }
    return self;
}

- (void)start {
    [_analyzer startLogin];
}

- (void)loop {
    NSString *descriptionFormat = @"@马啸.r(359364053) %@ 抱好不送";
    NSString *userContent = @"";
    NSString *description = [NSString stringWithFormat:descriptionFormat, userContent];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [_analyzer uploadSyncImageData:_imageData description:description selectAblum:^id(NSArray *ablumList) {
            return _selectedAlbum;
        } complete:^(id photoId, BOOL success) {
            __block BOOL shouldContinue = YES;
            const NSTimeInterval step = _step;
            NSTimeInterval time = 12 * 60 * 60;
            NSUInteger idx = 0;
            while (shouldContinue && time > 0.00001)
            {
                @autoreleasepool {
                    [_analyzer publicImage:[_selectedAlbum albumId] photoId:photoId description:description complete:^(id photoId, BOOL success) {
                        if (!success) {
                            NSLog(@"JOB NO.%04ld FAILED!", idx);
                        } else {
                            NSLog(@"JOB NO.%04ld DONE.", idx);
                        }
                    }];
                    [NSThread sleepForTimeInterval:step];
                    time -= step;
                    idx++;
                }
            }
            CFRunLoopStop(CFRunLoopGetMain());
        }];
    });
}

- (IBAction)zan:(id)sender {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSUInteger begin = 0;
        NSUInteger limit = 0;
        NSUInteger count = 120;
        BOOL shouldContinue = YES;
        NSMutableArray *models = [[NSMutableArray alloc] init];
        NSString *userId = @"460184248";
        while (shouldContinue)
        {
            if (count <= begin) {
                shouldContinue = NO;
                break;
            }
            NSURLResponse *response = nil;
            NSData *data = nil;
            NSError *error = nil;
            //333092533
            data = [NSURLConnection sendSynchronousRequest:[RSRemoteDataBase remoteUpdateUser:userId count:limit analyer:_analyzer] returningResponse:&response error:&error];  // 个人主页 朕已阅
//            data = [RSRemoteDataBase remoteSyncInvokeUpdatePage:begin limit:limit count:count analyer:_analyzer response:&response error:&error]; // 新鲜事 朕已阅
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            if ([httpResponse statusCode] == 200)
                [models addObjectsFromArray:[_analyzer analyzeLikeModelWithData:data mode:RSRenrenAddLike]];
            else
                shouldContinue = NO;
            begin = [models count];
            limit++;
            
            
            NSLog(@"Collecting items for user(%@)... Loop = %ld, count = %ld", userId, limit, begin);
            [NSThread sleepForTimeInterval:1.25];
        }
        if ([models count])
        {
            [models enumerateObjectsUsingBlock:^(RSLikeModel *obj, NSUInteger idx, BOOL *stop) {
                if (idx > count) {
                    *stop = YES;
                    return ;
                }
                NSLog(@"Zan(%ld) for user(%@)", idx, userId);
                [obj action];
                [NSThread sleepForTimeInterval:2];
            }];
            
            NSLog(@"end");
            return ;
        }
    });
}

#pragma mark -
#pragma mark RSCoreAnalyzerDelegate

- (void)analyzer:(RSCoreAnalyzer *)analyzer LoginFailedWithError:(NSError *)error {
    NSLog(@"login failed! (%@)", error);
    [Service exitWithStatus:[error code]];
}

- (void)analyzerLoginSuccess:(RSCoreAnalyzer *)analyzer {
    NSLog(@"login success");
    [self zan:self];
//    _library = [[RSAlbumLibrary alloc] initWithAnaylzer:_analyzer delegate:self];
//    [_library start];
    
}

#pragma mark -
#pragma mark RSAlbumLibraryDelegate

- (void)albumLibraray:(RSAlbumLibrary *)albumLibrary failedWithError:(NSError *)error {
    NSLog(@"update album failed! Error = %@", error);
    [Service exitWithStatus:[error code]];
}

- (void)albumLibraray:(RSAlbumLibrary *)albumLibrary finishUpdate:(NSArray *)albums {
    NSLog(@"update album success!\nPlease type an index to select an album album = {");
    [albums enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        printf("\t(%02ld) => %s\n", idx, [[obj description] UTF8String]);
    }];
    printf("}\n");
    char buf[4096] = {0};
    fflush(stdin);
    int r = scanf("%s",buf);
    NSUInteger idx = atoi(buf);
    if (r && idx < [albums count])
        _selectedAlbum = albums[idx];
    else  {
        NSLog(@"Album is not valid");
        [Service exitWithStatus:1];
    }
    [self loop];
}
@end

void version() {
    NSLog(@"Black-kousu Version:1.0");
    [Service exitWithStatus:0];
}

void help() {
    NSLog(@"Black-kousu -a(your account id) -p(your password) -d (description) -f(feed interval) picture path");
    NSLog(@"Black-kousu -a 123@abc.com -p 123456 -d \"口肃I can I up\" -f 12 ~/Desktop/kousu.png");
    NSLog(@"Black-kousu |your account id| your password| your upload description| feed interval(hours)| picture path");
    [Service exitWithStatus:0];
}

void usage(id notification) {
    if (notification) NSLog(@"%@", notification);
    NSLog(@"Black-kousu |your account id| your password| your upload description| feed interval(hours)| picture path");
    NSLog(@"Black-kousu -a(your account id) -p(your password) -d (description) -f(feed interval) picture path");
    NSLog(@"Black-kousu -help");
    NSLog(@"Black-kousu -version");
    [Service exitWithStatus:0];
}

int main(int argc, const char * argv[])
{
    dispatch_queue_t queue = dispatch_queue_create("my-queue", nil);
    dispatch_async(queue, ^{
        NSLog(@"%@", [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.baidu.com"]] returningResponse:nil error:nil]);
        [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.baidu.com"]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            NSLog(@"");
        }];
    });
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate distantFuture]];
    return 0;
    @autoreleasepool {
        // insert code here...
        opterr = 0;
        int ch;
        NSString *accountName = nil;
        NSString *password = nil;
        NSString *description = @"";
        NSString *imagePath = nil;
        NSTimeInterval interval = 12.0f;
        while((ch = getopt(argc,(char* const*)argv,"a:p:d:f:version:help:?"))!= -1)
        {
            switch(ch)
            {
                case 'a':
                    accountName = [NSString stringWithUTF8String:(const char*)optarg];
                    break;
                case 'p':
                    password = [NSString stringWithUTF8String:(const char*)optarg];
                    break;
                case 'd':
                    description = [NSString stringWithUTF8String:(const char *)optarg];
                    break;
                case 'f':
                    interval = fabs(atof(optarg));
                    interval = interval < 12 && interval > 0.00001f ? : ((interval > 12) ? 12 : 2);
                    break;
                case 'v':
                case 'V':
                    version();
                case '?':
                case 'h':
                case 'H':
                    help();
                default:
                    break;
            }
        }
        if (!accountName || !password) {
            if (!accountName) usage(@"Account id is nil");
            if (!password) usage(@"Password is nil");
        }
        NSImage *image = nil;
        imagePath = [[NSString stringWithUTF8String:argv[argc - 1]] stringByStandardizingPath];
        BOOL isDirectory = NO;
        if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath isDirectory:&isDirectory] || isDirectory == YES) {
            usage(@"Image File can not pass the verification process.");
        }
        if (!(image = [[NSImage alloc] initWithData:[NSData dataWithContentsOfFile:imagePath]])) {
            usage(@"Image can not pass the verification process.");
        }
        
        NSLog(@"YoYo I CAN I UP! YES I CAN!");
        NSData *data = nil;
#if TARGET_OS_MAC
        NSData *imageData = [image TIFFRepresentation];
        NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
        [imageRep setSize:[image size]];
        data = [imageRep representationUsingType:NSPNGFileType properties:nil];
        if (!data) {
            NSDictionary *imageProps = nil;
            NSNumber *quality = [NSNumber numberWithFloat:.95];
            imageProps = [NSDictionary dictionaryWithObject:quality forKey:NSImageCompressionFactor];
            data = [imageRep representationUsingType:NSJPEGFileType properties:imageProps];
        }
#endif
        _service = [[Service alloc] initWithAccount:[[RSAccount alloc] initWithAccountId:accountName password:password]];
        [_service setImageData:data ? : [NSData dataWithContentsOfFile:imagePath]];
        [_service setStep:interval];
        [_service start];
    }
    CFRunLoopRun();
    return 0;
}

