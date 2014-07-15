# JPXUIWebViewJSBridge
simplify invocation between Objective C and Javascript Code.

# Background
Guys know that the magic of Javascript can invoke Objective C code lies in

    - (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType

Generally Speaking, we will implement code like this to achieve:

    - (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
    {
      if ([request.URL.absoluteString hasPrefix:@"js-call://user/set"]) {
        NSDictionary *parameters = [self parseQueryString:request.URL.absoluetString];
        [self executeSomeObjectiveCCodeWithParameters:parameters];
        return NO;
      } else if ([request.URL.absoluteString hasPrefix:@"js-call://user/get"]) {
        NSDictionary *parameters = [self parseQueryString:request.URL.absoluetString];
        [self executeSomeObjectiveCCodeWithParameters:parameters];
        return NO;
      } else if (...) {
        ...
      }
      return YES;
    }

So, there will be a lot of ```if ... else if ... else ``` code. And the exposed methods can not be aware at a glance.
That is Why I create JPXUIWebViewJSBridge to handle this embarrassment.
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

Invocation in web(javascript)
---------------------------------
    //example only.
    function execute(url)
    {
         var iframe = document.createElement("IFRAME");
         iframe.setAttribute("src", url);
         document.documentElement.appendChild(iframe);
         iframe.parentNode.removeChild(iframe);
         iframe = null;
    }
    execute('js-call://user/set?uid=1&name=jpx');

# Compatibility
use ARC, iOS 5.0+ support.
