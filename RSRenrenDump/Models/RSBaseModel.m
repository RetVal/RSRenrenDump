//
//  RSBaseModel.m
//  RSDumpRenren
//
//  Created by RetVal on 5/24/13.
//  Copyright (c) 2013 RetVal. All rights reserved.
//

#import "RSBaseModel.h"

@implementation RSBaseModel
- (NSString *)description
{
    if (_schoolName == nil) return [NSString stringWithFormat:@"name : %@, home page : %@, image : %@", _name, _homePageURL, _imageURL];
    return [NSString stringWithFormat:@"name : %@(%@), home page : %@, image : %@", _name, _schoolName, _homePageURL, _imageURL];
}

- (id)serialization
{
    if (_schoolName == nil)
        return @{_kCAHomePageLinkKey : [_homePageURL absoluteString],
                 _kCAHeadImageLinkKey : [_imageURL absoluteString],
                 _kCANameKey : _name,
                 _kCAPopularityKey : [NSNumber numberWithUnsignedInteger:_popularity],
                 _kCAAccountKey : _account};
    return @{_kCAHomePageLinkKey : [_homePageURL absoluteString],
             _kCAHeadImageLinkKey : [_imageURL absoluteString],
             _kCANameKey : _name,
             _kCAPopularityKey : [NSNumber numberWithUnsignedInteger:_popularity],
             _kCAAccountKey : _account,
             _kCASchoolKey : _schoolName};
}

- (id)initWithSerialization:(id)serialization
{
    if (self = [super init])
    {
        [self setSchoolName:[serialization objectForKey:_kCASchoolKey]];
        [self setName:[serialization objectForKey:_kCANameKey]];
        [self setImageURL:[[NSURL alloc] initWithString:[serialization objectForKey:_kCAHeadImageLinkKey]]];
        [self setHomePageURL:[[NSURL alloc] initWithString:[serialization objectForKey:_kCAHomePageLinkKey]]];
        [self setAccount:[serialization objectForKey:_kCAAccountKey]];
        [self setPopularity:[[serialization objectForKey:_kCAPopularityKey] unsignedIntegerValue]];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:[_homePageURL absoluteString] forKey:_kCAHomePageLinkKey];
    [aCoder encodeObject:[_imageURL absoluteString] forKey:_kCAHeadImageLinkKey];
    [aCoder encodeObject:_name forKey:_kCANameKey];
    [aCoder encodeObject:@(_popularity) forKey:_kCAPopularityKey];
    [aCoder encodeObject:_account forKey:_kCAAccountKey];
    [aCoder encodeObject:_schoolName ?: @"" forKey:_kCASchoolKey];
//    [aCoder encodeObject:_image forKey:_kCAHeadImage];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init])
    {
        _homePageURL = [[NSURL alloc] initWithString:[aDecoder decodeObjectForKey:_kCAHomePageLinkKey]];
        _imageURL = [[NSURL alloc] initWithString:[aDecoder decodeObjectForKey:_kCAHeadImageLinkKey]];
        _name = [aDecoder decodeObjectForKey:_kCANameKey];
        _popularity = [[aDecoder decodeObjectForKey:_kCAPopularityKey] unsignedIntegerValue];
        _account = [aDecoder decodeObjectForKey:_kCAAccountKey];
        _schoolName = [aDecoder decodeObjectForKey:_kCASchoolKey];
//        _image = [aDecoder decodeObjectForKey:_kCAHeadImage];
    }
    return self;
}
@end
