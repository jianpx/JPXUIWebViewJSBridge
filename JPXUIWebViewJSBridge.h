//
//  JPXUIWebViewJSBridge.h
//  WebViewJSBridge
//
//  Created by jianpx on 6/26/14.
//  Copyright (c) 2014 JPX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JPXUIWebViewJSBridge : NSObject
//routines is like this:[(r'^mkey://alarm/set.*$', 'set_alarm'), (r'mkey://alarm/cancle.*$', 'cancle_alarm')]
@property (nonatomic, strong) NSArray *routines;

- (instancetype)initWithHandler:(id)handler;
- (BOOL)canHandleRequest:(NSURLRequest *)request error:(NSError **)error;
- (void)handleRequest:(NSURLRequest *)request error:(NSError **)error;

@end
