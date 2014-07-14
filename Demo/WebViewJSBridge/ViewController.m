//
//  ViewController.m
//  WebViewJSBridge
//
//  Created by jianpx on 6/26/14.
//  Copyright (c) 2014 JPX. All rights reserved.
//

#import "ViewController.h"
#import "JPXUIWebViewJSBridge.h"

@interface ViewController ()
@property (strong, nonatomic) UIWebView *webview;
@property (nonatomic, strong) JPXUIWebViewJSBridge *bridge;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.webview = [[UIWebView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.view addSubview:self.webview];
    self.webview.delegate = self;
    NSString *filePath =[[NSBundle mainBundle] pathForResource:@"test" ofType:@"html"];
    NSString *htmlString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    [self.webview loadHTMLString:htmlString baseURL:nil];

    self.bridge = [[JPXUIWebViewJSBridge alloc] initWithHandler:self];
    self.bridge.routines = @[@[@"^js-call://user/set.*$", @"setUser"],
                             @[@"^js-call://user/get.*$", @"getUser"]
                             ];
}

- (void)setUser:(NSDictionary *)parameters
{
    NSLog(@"setUser called!, paramters:%@", parameters);
    if (parameters[@"callback"]) {
        NSString *callbackFunc = [NSString stringWithFormat:@"%@('%@', '%@');", parameters[@"callback"], parameters[@"id"], parameters[@"info"]];
        [self.webview stringByEvaluatingJavaScriptFromString:callbackFunc];
    }
}

- (void)getUser:(NSDictionary *)parameters
{
    NSLog(@"getUser called!, parameters:%@", parameters);
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSError *error;
    BOOL canHandleRequest = [self.bridge canHandleRequest:request error:&error];
    if (canHandleRequest) {
        [self.bridge handleRequest:request error:&error];
        NSLog(@"error1:%@", [error localizedDescription]);
        return NO;
    } else {
        NSLog(@"error2:%@", [error localizedDescription]);
    }
    return YES;
}

@end
