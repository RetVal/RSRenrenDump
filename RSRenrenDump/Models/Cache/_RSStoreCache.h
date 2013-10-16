//
//  _RSStoreCache.h
//  RSRenren
//
//  Created by Closure on 10/16/13.
//  Copyright (c) 2013 RetVal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface _RSStoreCache : NSObject
- (id)init;
- (id)initWithStorePath:(NSString *)path named:(NSString *)cacheName memorySize:(NSUInteger)capacity;

- (NSString *)storePath;
- (NSString *)cacheName;

- (void)setObject:(id)object forKey:(id<NSCopying>)key;
- (id)objectForKey:(id<NSCopying>)key;

- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key;
- (id)objectForKeyedSubscript:(id)key;

- (void)writeObject:(id)object forKey:(id<NSCopying>)key;

@end
