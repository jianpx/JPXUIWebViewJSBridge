//
//  JPXUIWebViewJSBridge.h
//  WebViewJSBridge
//
//  Created by jianpx on 6/26/14.
//  Copyright (c) 2014 JPX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JPXUIWebViewJSBridge : NSObject
//routines is like this:[('^js-call://user/set.*$', 'setUser'), ('js-call://user/get.*$', 'getUser')]
@property (nonatomic, strong) NSArray *routines;

- (instancetype)initWithHandler:(id)handler;
- (BOOL)canHandleRequest:(NSURLRequest *)request error:(NSError **)error;
- (void)handleRequest:(NSURLRequest *)request error:(NSError **)error;

@end
