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

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *statusImageView;
@property (weak, nonatomic) IBOutlet UILabel *statusTextView;

@end

@implementation ViewController
// Change NSURLSession to ApproovURLSession
NSURLSession* defaultSession;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Change NSURLSession to ApproovURLSession
    defaultSession = [NSURLSession sessionWithConfiguration:NSURLSessionConfiguration.defaultSessionConfiguration];
}
// check unprotected hello endpoint
- (IBAction)checkHello:(id)sender {
    NSURL* helloURL = [[NSURL alloc] initWithString:@"https://shapes.approov.io/v1/hello"];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.statusImageView.image = [UIImage imageNamed:@"approov"];
        self.statusTextView.text = @"Checking connectivity...";
    });
    
    NSURLSessionDataTask* task = [defaultSession dataTaskWithURL:helloURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
        NSString* message;
        UIImage* image;
        
        // analyze response
        if(error == nil){
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
            long code = httpResponse.statusCode;
            if(code == 200){
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
            message = @"Unknown networking error";
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

// check Approov-protected shapes endpoint
- (IBAction)checkShape:(id)sender {
    NSURL* shapesURL = [[NSURL alloc] initWithString:@"https://shapes.approov.io/v2/shapes"];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.statusImageView.image = [UIImage imageNamed:@"approov"];
        self.statusTextView.text = @"Checking app authenticity...";
    });
    
    NSURLSessionDataTask* task = [defaultSession dataTaskWithURL:shapesURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
        NSString* message;
        UIImage* image;
        
        // analyze response
        if(error == nil){
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
            long code = httpResponse.statusCode;
            if(code == 200){
                // successful http response
                message = @"200: Approoved!";
                // unmarshal the JSON response
                NSError* error;
                NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
                if(error != nil){
                    NSLog(@"%@: %@", shapesURL, @"Error unmarshaling JSON from response");
                    message = @"Error unmarshaling JSON from response";
                    image = [UIImage imageNamed: @"confused"];
                } else {
                    if([jsonDict objectForKey:@"shape"] != nil){
                        NSString* shape = [jsonDict objectForKey:@"shape"];
                        if([shape.lowercaseString isEqualToString:@"circle"]){
                            image = [UIImage imageNamed:@"Circle"];
                        } else if([shape.lowercaseString isEqualToString:@"rectangle"]){
                            image = [UIImage imageNamed:@"Rectangle"];
                        } else if([shape.lowercaseString isEqualToString:@"square"]){
                            image = [UIImage imageNamed:@"Square"];
                        } else if([shape.lowercaseString isEqualToString:@"triangle"]){
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
            message = @"Unknown networking error";
            image = [UIImage imageNamed: @"confused"];
        }
        
        NSLog(@"%@: %@", shapesURL, message);
        
        // Display the image on screen using the main queue
        dispatch_async(dispatch_get_main_queue(), ^{
            self.statusImageView.image = image;
            self.statusTextView.text = message;
        });
    }];
    [task resume];
}

@end
