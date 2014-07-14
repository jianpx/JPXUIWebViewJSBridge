//
//  JPXUIWebViewJSBridge.m
//  WebViewJSBridge
//
//  Created by jianpx on 6/26/14.
//  Copyright (c) 2014 JPX. All rights reserved.
//

#import "JPXUIWebViewJSBridge.h"

@interface JPXUIWebViewJSBridge()
@property (nonatomic, strong) id handler;

@end


NSString * const JPXUIWebViewJSBridgeErrorDomain = @"JPXUIWebViewJSBridgeErrorDomain";
const NSInteger JPXUIWebViewJSBridgeErrorCode = 1;


@implementation JPXUIWebViewJSBridge

- (instancetype)initWithHandler:(id)handler
{
    self = [super init];
    if (self) {
        self.handler = handler;
    }
    return self;
}

- (BOOL)canHandleRequest:(NSURLRequest *)request error:(NSError **)error
{
    NSInteger matchIndex = [self findMatchIndexOfURLScheme:request.URL.absoluteString error:error];
    if (matchIndex == NSNotFound) {
        *error = [NSError errorWithDomain:JPXUIWebViewJSBridgeErrorDomain
                                     code:JPXUIWebViewJSBridgeErrorCode
                                 userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"can not match any of your url pattern", @"")}];
    }
    return !(matchIndex == NSNotFound) ;
}

- (NSInteger)findMatchIndexOfURLScheme:(NSString *)url error:(NSError **)error
{
    NSPredicate *p = nil;
    NSInteger matchIndex = NSNotFound;
    for (NSUInteger i = 0; i < self.routines.count; i++) {
        if (![self.routines[i] isKindOfClass:[NSArray class]]) {
            *error = [NSError errorWithDomain:JPXUIWebViewJSBridgeErrorDomain
                                         code:JPXUIWebViewJSBridgeErrorCode
                                     userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"element in routines is not NSArray", @"")}];
            break;
        }
        NSArray *routinePair = self.routines[i];
        if (routinePair.count != 2) {
            *error = [NSError errorWithDomain:JPXUIWebViewJSBridgeErrorDomain
                                         code:JPXUIWebViewJSBridgeErrorCode
                                     userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"element in routines should be NSArray that contains 2 items", @"")}];
            break;
        }
        NSString *pattern = routinePair[0];
        p = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
        if ([p evaluateWithObject:url]) {
            matchIndex = i;
        }
    }
    return matchIndex;
}

- (NSString *)getQueryStringInURL:(NSString *)url
{
    NSURL *_url = [NSURL URLWithString:url];
    return _url.query;
}

- (NSDictionary *)dictionaryFromQueryString:(NSString *)queryString
{
    NSArray *urlComponents = [queryString componentsSeparatedByString:@"&"];
    if (urlComponents.count <= 0) {
        return nil;
    }
    NSMutableDictionary *queryDict = [NSMutableDictionary dictionary];
    for (NSString *keyValuePair in urlComponents) {
        NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
        if ([pairComponents[1] isKindOfClass:[NSString class]]) {
            [queryDict setObject:[pairComponents[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                          forKey:pairComponents[0]];
        } else {
            [queryDict setObject:pairComponents[1] forKey:pairComponents[0]];
        }
    }
    return [queryDict copy];
}

- (void)handleRequest:(NSURLRequest *)request error:(NSError **)error
{
    NSString *url = request.URL.absoluteString;
    NSInteger matchIndex = [self findMatchIndexOfURLScheme:url error:error];
    NSDictionary *errorUserInfo = nil;
    if (matchIndex == NSNotFound) {
        errorUserInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"url pattern not found!", @"")};
        *error = [NSError errorWithDomain:JPXUIWebViewJSBridgeErrorDomain
                                     code:JPXUIWebViewJSBridgeErrorCode
                                 userInfo:errorUserInfo];
        NSLog(@"error:can not find one url that matches your url pattern");
        return;
    }
    NSString *handlerName = self.routines[matchIndex][1];
    if (!handlerName) {
        errorUserInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"handler of match url pattern is nil!", @"")};
        *error = [NSError errorWithDomain:JPXUIWebViewJSBridgeErrorDomain
                                     code:JPXUIWebViewJSBridgeErrorCode
                                 userInfo:errorUserInfo];
        NSLog(@"error:pass nil handler!");
        return;
    }
    NSString *queryString = [self getQueryStringInURL:url];
    NSDictionary *parameters = [self dictionaryFromQueryString:queryString];
    //selector signature should be: (void) methodName:(NSDictionary *)parameters
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"%@:", handlerName]);
    if (![self.handler respondsToSelector:selector]) {
        NSString *e = [NSString stringWithFormat:@"method:%@ of handler:%@ not define!", handlerName, NSStringFromClass([self.handler class])];
        errorUserInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(e, @"")};
        *error = [NSError errorWithDomain:JPXUIWebViewJSBridgeErrorDomain
                                     code:JPXUIWebViewJSBridgeErrorCode
                                 userInfo:errorUserInfo];
        return;
    }

    //the following will cause this warning:performSelector may cause a leak because its selector is unknown, solve it with:http://stackoverflow.com/a/20058585/544251
    //[self.handler performSelector:selector withObject:parameters];
    IMP imp = [self.handler methodForSelector:selector];
    void (*func)(id, SEL, NSDictionary *) = (void *)imp;
    func(self.handler, selector, parameters);
}
@end
