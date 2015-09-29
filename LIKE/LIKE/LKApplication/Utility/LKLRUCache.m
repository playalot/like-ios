//
//  LKLRUCache.m
//  LKLRUCache
//
//  Created by Jason Kaer on 15/7/11.
//  Copyright (c) 2015年 Jason Kaer. All rights reserved.
//

#import "LKLRUCache.h"
#import <UIKit/UIKit.h>

#pragma mark - Node

@interface LKLRUCacheNode : NSObject

@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) id value;
@property (nonatomic, weak) LKLRUCacheNode *previous;
@property (nonatomic, weak) LKLRUCacheNode *next;

- (instancetype)initWithKey:(NSString *)key  value:(id)value;

@end

@implementation LKLRUCacheNode


- (instancetype)initWithKey:(NSString *)key value:(id)value
{
    self = [super init];
    if (self) {
        self.key = [key copy];
        self.value = value;
    }
    
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"node %p, key : %@, value : %@", self, self.key, self.value];
}

@end
// ///////////////////////////////////////////////////////

#pragma mark - LinkList

@interface LKLRUCacheLinkList : NSObject

@property (nonatomic, weak) LKLRUCacheNode *head;
@property (nonatomic, weak) LKLRUCacheNode *tail;

- (void)addNodeToHead:(LKLRUCacheNode * )node;

- (void)removeNode:(LKLRUCacheNode *)node;


@end


@implementation LKLRUCacheLinkList

- (void)addNodeToHead:(LKLRUCacheNode *)node
{
    if (nil == self.head) {
        self.head = node;
        self.tail = node;
    }else{
        LKLRUCacheNode *temp = self.head;
        self.head.previous = node;
        self.head = node;
        self.head.next = temp;
    }
}

- (void)removeNode:(LKLRUCacheNode *)node
{
    if (node == self.head) {
        // delete head
        if (self.head.next != nil) {
            self.head = self.head.next;
            self.head.previous = nil;
        }else{
            self.head = nil;
            self.tail = nil;
        }
    } else if (node.next != nil){
        // delete middle node
        node.previous.next = node.next;
        node.next.previous = node.previous;
    } else {
        // delete tail
        node.previous.next = nil;
        self.tail = node.previous;
    }
}

- (NSString *)description
{
    NSMutableString *desc =  [[NSMutableString alloc]init];
    LKLRUCacheNode *current = self.head;
    
    while (current != nil) {
        [desc appendString:[NSString stringWithFormat:@"Key: %@, Value: %@ \n",current.key, current.value]];
        current = current.next;
    }
    
    return desc;
}

- (void)display
{
    NSLog(@"%@", self.description);
}

@end



/////////////////////////////////////////////////////////

#pragma mark - Cache

@interface LKLRUCache ()

@property (nonatomic, readwrite, assign) NSUInteger capacity;

@property (nonatomic, readwrite, assign) NSUInteger length;

@property (nonatomic, strong) LKLRUCacheLinkList *queue;

@property (nonatomic, strong) NSMutableDictionary *hashtable;

@property (nonatomic, strong) NSRecursiveLock *lock;

/**
 *  Clear all cache on memory warning .
 */
- (void)_clearCache;
@end



@implementation LKLRUCache

- (instancetype)init
{
    return [self initWithCapacity:0];
}

- (instancetype)initWithCapacity:(NSUInteger)capacity
{
    self = [super init];
    if (self) {
        _capacity  = capacity;
        _length    = 0;
        _queue     = [[LKLRUCacheLinkList alloc] init];
        _hashtable = [[NSMutableDictionary alloc] initWithCapacity:capacity];
        _lock      = [[NSRecursiveLock alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_clearCache)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidReceiveMemoryWarningNotification
                                                  object:nil];
}


- (id)objectForKey:(NSString *)key
{
    LKLRUCacheNode *node = nil;
    
    [self.lock lock];
    if ( (node = self.hashtable[key])) {
        [self.queue removeNode:node];
        [self.queue addNodeToHead:node];
    }
    [self.lock unlock];
    
    return node.value;
}


- (void)setObject:(id)object forKey:(NSString *)key
{
    [self.lock lock];
    if (self.hashtable[key]) {
        // Update node
        LKLRUCacheNode *node = self.hashtable[key];
        node.value = object;
        
        [self.queue removeNode:node];
        [self.queue addNodeToHead:node];
    } else {
        // Add new node
        LKLRUCacheNode *node = [[LKLRUCacheNode alloc] initWithKey:key value:object];
        if (self.length < self.capacity) {
            self.hashtable[key] = node;
            [self.queue addNodeToHead:node];
            self.length ++;
        }else{
            NSString *preTailKey = self.queue.tail.key;
            NSAssert(preTailKey != nil, @"preTailKey != nil");
            self.queue.tail = self.queue.tail.previous;
            [self.hashtable removeObjectForKey:preTailKey];
            
            if (self.queue.tail) {
                self.queue.tail.next = nil;
            }
            [self.queue addNodeToHead:node];
            self.hashtable[key] = node;
        }
    }
    [self.lock unlock];
}

- (void)removeObjectForKey:(NSString *)key
{
    NSParameterAssert(key!= nil && key !=  NULL);
    LKLRUCacheNode *node = nil;
    
    [self.lock lock];
    if ( (node = self.hashtable[key])) {
        [self.queue removeNode:node];
        [self.hashtable removeObjectForKey:key];
        self.length--;
    }
    [self.lock unlock];
}


- (NSString *)description
{
    return [NSString stringWithFormat:@"LRU Cache : capacity: %lu, length = %lu \n content : %@", (unsigned long)self.capacity,(unsigned long)self.length, self.queue.description];
}

- (void)show {
    NSArray *keyArray = [self.hashtable allKeys];
    NSArray *sortedArray = [keyArray sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    NSMutableString *cellStr = [NSMutableString string];
    for (NSString *key in sortedArray) {
        LKLRUCacheNode *node = self.hashtable[key];
        if (node) {
            [cellStr appendFormat:@"%@\n", key];
        }
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Precomputed Cells" message:cellStr delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}


#pragma mark - Private

- (void)_clearCache
{
    for (NSString *key in [self.hashtable allKeys]) {
        [self removeObjectForKey:key];
    }
}


@end







