//
//  _RSStoreCache.m
//  RSRenren
//
//  Created by Closure on 10/16/13.
//  Copyright (c) 2013 RetVal. All rights reserved.
//

#import "_RSStoreCache.h"

NSString * const _RSStoreCacheDefaultPath = @"_RSStoreCacheDefaultPath";


NSString * const __RSStoreCacheModelClass = @"Cache";

@interface _RSStoreCache() <NSCacheDelegate>
{
    NSMutableDictionary *_propertyOfStoreCache; // NSCache *_cache;
    NSCache *_cache;
    NSString *_storePath;
    NSString *_name;
    NSString *_fullCachePath;
}

//+ (BOOL)_verifyStoreCache:(NSString *)path named:(NSString *)name;
+ (BOOL)_initStoreCacheAtPath:(NSString *)path named:(NSString *)name;
@end

@implementation _RSStoreCache
- (id)init
{
    return [self initWithStorePath:_RSStoreCacheDefaultPath named:@"__RSDefaultStoreCacheName__" memorySize:30];
}

- (id)initWithStorePath:(NSString *)path named:(NSString *)cacheName memorySize:(NSUInteger)capacity
{
    if (self = [super init])
    {
        NSString *fullPath = nil;
        NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSAllDomainsMask, YES)[0];
        NSFileManager *defaultManager = [NSFileManager defaultManager];
        BOOL isDirectory = NO;
        if ([defaultManager fileExistsAtPath:[NSString stringWithFormat:@"%@/%@", path, cacheName] isDirectory:&isDirectory] && isDirectory)
        {
            
            _storePath = [NSString stringWithFormat:@"%@/%@", documentPath, path];
            _name = cacheName;
        }
        else if ([defaultManager fileExistsAtPath:fullPath = [NSString stringWithFormat:@"%@/%@/%@", documentPath, path, cacheName] isDirectory:&isDirectory] && isDirectory)
        {
            _storePath = [NSString stringWithFormat:@"%@/%@", documentPath, path];
            _name = cacheName;
        }
        else
        {
            // create store cache at path
            NSError *error = nil;
            BOOL result = [defaultManager createDirectoryAtPath:[NSString stringWithFormat:@"%@/%@", path, cacheName] withIntermediateDirectories:YES attributes:nil error:&error];
            
            if (!result && error)
            {
                error = nil;
                result = [defaultManager createDirectoryAtPath:fullPath withIntermediateDirectories:YES attributes:nil error:&error];
                if (result && error)
                {
                    NSLog(@"%@ error = %@", [_RSStoreCache class], error);
                    return nil;
                }
                else _storePath = [NSString stringWithFormat:@"%@/%@", documentPath, path];
            }
            else _storePath = [NSString stringWithFormat:@"%@/%@", documentPath, path];
            _name = cacheName;
            BOOL success = [_RSStoreCache _initStoreCacheAtPath: _storePath named:_name];
            if (!success)
            {
                NSLog(@"%@ init store cache failed!", [self class]);
                return nil;
            }
        }
        _fullCachePath = [[NSString alloc] initWithFormat:@"%@/%@", _storePath, _name];
        _cache = [[NSCache alloc] init];
        [_cache setCountLimit:20];
    }
    return self;
}

- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key
{
    return [self setObject:obj forKey:key];
}

- (id)objectForKeyedSubscript:(id)key
{
    return [self objectForKey:key];
}

- (id)objectForKey:(id<NSCopying>)key
{
    id object = [_cache objectForKey:key];
    if (!object)
    {
        NSLog(@"not in cache...");
        object = [UIImage imageWithData:[NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", _fullCachePath, key]]];
        if (object)
            self[key] = object;
    }
    else
    {
        NSLog(@"hit in cache!");
    }
    return object;
}

- (void)setObject:(id)object forKey:(id<NSCopying>)key
{
    [_cache setObject:object forKey:key cost:1];
}

- (void)writeObject:(id)object forKey:(id<NSCopying>)key
{
    NSString *path = [NSString stringWithFormat:@"%@/%@", _fullCachePath, key];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        if ([object isKindOfClass:[UIImage class]])
        {
            UIImage *imageObject = (UIImage *)object;
            [UIImagePNGRepresentation(imageObject) writeToFile:path atomically:YES];
        }
    }
}

+ (BOOL)_initStoreCacheAtPath:(NSString *)path named:(NSString *)name
{
    BOOL success = NO;
    NSError *error = nil;
    success = [[NSFileManager defaultManager] createDirectoryAtPath:[NSString stringWithFormat:@"%@/%@", path, name] withIntermediateDirectories:YES attributes:nil error:&error];
    if (!error && success) success = YES;
    return success;
}

- (void)cache:(NSCache *)cache willEvictObject:(id)obj
{
    NSLog(@"willEvictObject - %@", obj);
}

- (NSString *)storePath
{
    return _storePath;
}

- (NSString *)cacheName
{
    return _name;
}
@end
