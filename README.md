# JPXUIWebViewJSBridge
simplify invocation between Objective C and Javascript Code.

# Usage
Initialization
-----------------

    //self can be either ViewController or NSObject, it is the place that exposes Objective C methods to web.
    self.bridge = [[JPXUIWebViewJSBridge alloc] initWithHandler:self];


Config
--------
    //here, element in routines is an array, the first item of the element is url pattern, the second one is your exposed method implementation. 
    self.bridge.routines = @[@[@"^js-call://user/set.*$", @"setUser"],
                             @[@"^js-call://user/get.*$", @"getUser"]
                             ];


Invocation in UIWebViewDelegate
---------------------------------

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

Implementation of exposed Objective C method
---------------------------------------------

    - (void) methodName:(NSDictionary *)parametersFromWeb
    {
        ...
    }

# Compatibility
use ARC, iOS 5.0+ support.
