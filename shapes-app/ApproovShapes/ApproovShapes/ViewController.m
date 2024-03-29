// MIT License
//
// Copyright (c) 2016-present, Critical Blue Ltd.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files
// (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge,
// publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR
// ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH
// THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


#import "ViewController.h"

// *** UNCOMMENT THE LINE BELOW TO USE APPROOV
//#import "ApproovNSURLSession.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *statusImageView;
@property (weak, nonatomic) IBOutlet UILabel *statusTextView;

@end

@implementation ViewController

// Hello URL endpoint
NSString* helloEndpoint = @"https://shapes.approov.io/v1/hello";

// Header name holding Api-Key value
NSString* apiKeyHeader = @"Api-Key";

// session to be used for requests
NSURLSession* defaultSession;

// *** COMMENT THE LINE BELOW FOR APPROOV API PROTECTION
NSString* shapesEndpoint = @"https://shapes.approov.io/v1/shapes";

// *** UNCOMMENT THE LINE BELOW FOR APPROOV API PROTECTION
//NSString* shapesEndpoint = @"https://shapes.approov.io/v3/shapes";

// *** COMMENT THE LINE BELOW IF USING APPROOV SECRETS PROTECTION
NSString* apiSecretKey = @"yXClypapWNHIifHUWmBIyPFAm";

// *** UNCOMMENT THE LINE BELOW IF USING APPROOV SECRETS PROTECTION
//NSString* apiSecretKey = @"shapes_api_key_placeholder";

- (void)viewDidLoad {
    [super viewDidLoad];
    // *** COMMENT THE LINE BELOW TO USE APPROOV
    defaultSession = [NSURLSession sessionWithConfiguration:NSURLSessionConfiguration.defaultSessionConfiguration];
    
    // *** UNCOMMENT THE LINES BELOW TO USE APPROOV
    /*NSError* error;
    [ApproovService initialize:@"<enter-you-config-string-here>" error:&error];
    if (error != nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.statusImageView.image = [UIImage imageNamed:@"approov"];
            self.statusTextView.text = @"Error initializing ApproovService";
        });
    }
    defaultSession = [ApproovNSURLSession sessionWithConfiguration:NSURLSessionConfiguration.defaultSessionConfiguration];*/
    
    // *** UNCOMMENT THE LINE BELOW TO USE APPROOV SECRETS PROTECTION
    //[ApproovService addSubstitutionHeader:apiKeyHeader requiredPrefix:@""];
}

// check unprotected hello endpoint
- (IBAction)checkHello:(id)sender {
    NSURL* helloURL = [[NSURL alloc] initWithString:helloEndpoint];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.statusImageView.image = [UIImage imageNamed:@"approov"];
        self.statusTextView.text = @"Checking connectivity...";
    });
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:helloURL];
    NSURLSessionDataTask* task = [defaultSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
        NSString* message;
        UIImage* image;
        
        // analyze response
        if (error == nil) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
            long code = httpResponse.statusCode;
            if (code == 200) {
                // successful http response
                message = @"200: OK";
                image = [UIImage imageNamed: @"hello"];
            } else {
                // unexpected http response
                NSString* reason = [NSHTTPURLResponse localizedStringForStatusCode:code];
                message = [NSString stringWithFormat:@"%ld:%@",code,reason];
                image = [UIImage imageNamed: @"confused"];
            }
        } else {
            // other networking failure
            message = error.localizedDescription;
            image = [UIImage imageNamed: @"confused"];
        }
        NSLog(@"%@: %@", helloURL, message);
        
        // Display the image on screen using the main queue
        dispatch_async(dispatch_get_main_queue(), ^{
            self.statusImageView.image = image;
            self.statusTextView.text = message;
        });
    }];
    [task resume];
}

// check shapes endpoint
- (IBAction)checkShape:(id)sender {
    NSURL* shapesURL = [[NSURL alloc] initWithString:shapesEndpoint];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.statusImageView.image = [UIImage imageNamed:@"approov"];
        self.statusTextView.text = @"Getting a shape...";
    });
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:shapesURL];
    [request addValue:apiSecretKey forHTTPHeaderField:apiKeyHeader];
    NSURLSessionDataTask* task = [defaultSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
        NSString* message;
        UIImage* image;
        
        // analyze response
        if (error == nil) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
            long code = httpResponse.statusCode;
            if (code == 200) {
                // successful http response
                message = @"200";
                NSLog(@"Data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                // unmarshal the JSON response
                NSError* error;
                NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
                if (error != nil) {
                    NSLog(@"%@: %@", shapesURL, @"Error unmarshaling JSON from response");
                    message = @"Error unmarshaling JSON from response";
                    image = [UIImage imageNamed: @"confused"];
                } else {
                    if ([jsonDict objectForKey:@"status"] != nil)
                        message = [jsonDict objectForKey:@"status"];
                    if ([jsonDict objectForKey:@"shape"] != nil) {
                        NSString* shape = [jsonDict objectForKey:@"shape"];
                        if([shape.lowercaseString isEqualToString:@"circle"]){
                            image = [UIImage imageNamed:@"Circle"];
                        } else if ([shape.lowercaseString isEqualToString:@"rectangle"]) {
                            image = [UIImage imageNamed:@"Rectangle"];
                        } else if ([shape.lowercaseString isEqualToString:@"square"]) {
                            image = [UIImage imageNamed:@"Square"];
                        } else if ([shape.lowercaseString isEqualToString:@"triangle"]) {
                            image = [UIImage imageNamed:@"Triangle"];
                        } else {
                            NSLog(@"%@: %@ %@", shapesURL, @"JSON contains unknown shape: ", shape.lowercaseString);
                            message = [@"JSON contains unknown shape: " stringByAppendingFormat:@"%@", shape.lowercaseString];
                            image = [UIImage imageNamed:@"confused"];
                        }
                    } else {
                        NSLog(@"%@: %@", shapesURL, @"JSON lacks shape key");
                        message = @"JSON lacks shape key";
                        image = [UIImage imageNamed: @"confused"];
                    }
                }
            } else {
                // unexpected http response
                NSString* reason = [NSHTTPURLResponse localizedStringForStatusCode:code];
                message = [NSString stringWithFormat:@"%ld:%@",code,reason];
                image = [UIImage imageNamed: @"confused"];
            }
        } else {
            // other networking failure
            message = error.localizedDescription;
            image = [UIImage imageNamed: @"confused"];
        }
        NSLog(@"%@: %@", shapesURL, message);
        
        // display the image on screen using the main queue
        dispatch_async(dispatch_get_main_queue(), ^{
            self.statusImageView.image = image;
            self.statusTextView.text = message;
        });
    }];
    [task resume];
}

@end
