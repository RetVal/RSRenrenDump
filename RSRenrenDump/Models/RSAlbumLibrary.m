//
//  RSAlbumLibrary.m
//  RSRenren
//
//  Created by Closure on 10/14/13.
//  Copyright (c) 2013 RetVal. All rights reserved.
//

#import "RSAlbumLibrary.h"
#import "RSCoreAnalyzer.h"

@implementation RSAlbum
- (id)initWithProperty:(id)property
{
    if (!property) return nil;
    if (self = [super init])
    {
        _disabled = NO;
        _albumId = property[@"id"];
        NSRange range = [property[@"name"] rangeOfString:@"(" options:NSBackwardsSearch];
        _name = [property[@"name"] substringWithRange:NSMakeRange(0, range.location)];
        _photoNumber = [property[@"name"] substringWithRange:NSMakeRange(range.location + range.length, [property[@"name"] length] - range.location - range.length - 1)];
        if ([property[@"disabled"] boolValue])
            _disabled = YES;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"name = %@, id = %@", _name, _albumId];
}

- (BOOL)isEqual:(RSAlbum *)object
{
    return [[object albumId] isEqualToString:_albumId];
}
@end

@interface RSAlbumLibrary()
@property (nonatomic, strong) RSCoreAnalyzer *analyzer;
@property (nonatomic, weak) id<RSAblumLibraryDelegate> delegate;
@end


@implementation RSAlbumLibrary
- (id)initWithAnaylzer:(id)analyzer delegate:(id<RSAblumLibraryDelegate>)delegate
{
    if (!analyzer || !delegate || ![analyzer isKindOfClass:[RSCoreAnalyzer class]]) return nil;
    if (self = [super init])
    {
        _analyzer = analyzer;
        _delegate = delegate;
    }
    return self;
}

- (void)start
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //    return [self _public:@"906004381" photoId:@"7489585138" description:@"description"];
        NSMutableDictionary *requestProperty = [[NSMutableDictionary alloc] init];
        NSMutableArray *albumCollection = [[NSMutableArray alloc] init];
        NSError *error = nil;
        NSString *urlString = @"http://upload.renren.com/addphotoPlain.do";
        NSXMLDocument *document = [[NSXMLDocument alloc] initWithContentsOfURL:[NSURL URLWithString:urlString] options:NSXMLDocumentTidyHTML error:&error];
        if (!document)
        {
            [_delegate albumLibraray:self failedWithError:nil];
            return;
        }
        NSXMLElement *body = [[document rootElement] elementsForName:@"body"][0];
        NSArray *subElements = [body elementsForName:@"div"];
        if (!subElements)
        {
            [_delegate albumLibraray:self failedWithError:nil];
            return;
        }
        if ([subElements count] != 4)
        {
            [_delegate albumLibraray:self failedWithError:nil];
            return;
        }
        if (![[[subElements[3] attributeForName:@"id"] objectValue] isEqualToString:@"container-for-buddylist"])
        {
            [_delegate albumLibraray:self failedWithError:nil];
            return;
        }
        NSXMLElement *div = subElements[3];
        div = [[[[[[[[div elementsForName:@"div"][0] elementsForName:@"div"][0] elementsForName:@"div"][0] elementsForName:@"div"][0] elementsForName:@"div"][0] elementsForName:@"div"][0] elementsForName:@"div"][0] elementsForName:@"div"][2];
        div = [div elementsForName:@"div"][1]; // single-column
        if (![[[div attributeForName:@"id"] objectValue] isEqualToString:@"single-column"])
        {
            [_delegate albumLibraray:self failedWithError:[NSError errorWithDomain:@"RSRenren" code:-100 userInfo:nil]];
            return;
        }
        NSXMLElement *form = [div elementsForName:@"form"][0];
        if (![[[form attributeForName:@"target"] objectValue] isEqualToString:@"uploadPlainIframe"])
        {
            [_delegate albumLibraray:self failedWithError:[NSError errorWithDomain:@"RSRenren" code:-101 userInfo:nil]];
            return;
        }
        requestProperty[@"method"] = [[form attributeForName:@"method"] objectValue];
        requestProperty[@"action"] = [[form attributeForName:@"action"] objectValue];
        requestProperty[@"enctype"] = [[form attributeForName:@"enctype"] objectValue];
        NSLog(@"%@", requestProperty);
        
        NSArray *albumlist = [[[[form elementsForName:@"p"][0] elementsForName:@"span"][0] elementsForName:@"select"][0] elementsForName:@"option"];
        for (NSXMLElement *album in albumlist)
        {
            NSMutableDictionary *dict = [@{@"id": [[album attributeForName:@"value"] objectValue], @"name" : [album objectValue]} mutableCopy];
            if ([[[album attributeForName:@"disabled"] objectValue] isEqualToString:@"disabled"]) dict[@"disabled"] = @(YES);
            
            [albumCollection addObject:[[RSAlbum alloc] initWithProperty:dict]];
        }
        [_delegate albumLibraray:self finishUpdate:albumCollection];
    });
}
@end
