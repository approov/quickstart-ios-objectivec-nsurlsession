# Approov Quickstart: iOS ObjectiveC NSURLSession

This quickstart is written specifically for native iOS apps that are written in ObjectiveC and making the API calls using [`NSURLSession`](https://developer.apple.com/documentation/foundation/nsurlsession) that you wish to protect with Approov. If this is not your situation then check if there is a more relevant quickstart guide available.

This page provides all the steps for integrating Approov into your app. Additionally, a step-by-step tutorial guide using our [Shapes App Example](https://github.com/approov/quickstart-ios-objectivec-nsurlsession/blob/master/SHAPES-EXAMPLE.md) is also available.

To follow this guide you should have received an onboarding email for a trial or paid Approov account.

Note that the minimum requirement is iOS 12. You cannot use Approov in apps that support iOS versions older than this.

## ADDING APPROOV SERVICE DEPENDENCY
The Approov integration is available via [`CocoaPods`](https://cocoapods.org/). This allows inclusion into the project by simply specifying a dependency in the `Podfile` for the app:

```
target 'YourApplication' do
    use_frameworks!
    platform :ios, '12.0'
    pod 'approov-service-nsurlsession', '3.5.1'
end
```

This package is actually an open source wrapper layer that allows you to easily use Approov with `NSURLSession`. This has a further dependency to the closed source [Approov SDK](https://github.com/approov/approov-ios-sdk).

## USING APPROOV NSURLSESSION
The `ApproovNSURLSession` class mimics the interface of the `NSURLSession` class provided by Apple but includes Approov protection. The simplest way to use the `ApproovNSURLSession` is to find and replace all the `NSURLSession` with `ApproovNSURLSession`.

Additionally, the `ApproovService` needs to be initialized before any network request is made using `ApproovNSURLSession`. The `ApproovService` initialization requires a configuration string parameter replacing `<enter-your-config-string-here>`, which is a custom string that configures your Approov account access. This will have been provided in your Approov onboarding email (it will be something like `#123456#K/XPlLtfcwnWkzv99Wj5VmAxo4CrU267J1KlQyoz8Qo=`). An additional parameter is an `NSError *` reference which would provide any error messages if a failure occurs.

```ObjectiveC
#import "ApproovNSURLSession.h"

[ApproovService initialize:@"<enter-your-config-string-here>" error:&error];
NSURLSession *defaultSession = [ApproovNSURLSession sessionWithConfiguration:NSURLSessionConfiguration.defaultSessionConfiguration];
```

For API domains that are configured to be protected with an Approov token, this adds the `Approov-Token` header and pins the connection. This may also substitute header values when using secrets protection.

## CHECKING IT WORKS
Initially you won't have set which API domains to protect, so the interceptor will not add anything. It will have called Approov though and made contact with the Approov cloud service. You will see logging from Approov saying `UNKNOWN_URL`.

Your Approov onboarding email should contain a link allowing you to access [Live Metrics Graphs](https://approov.io/docs/latest/approov-usage-documentation/#metrics-graphs). After you've run your app with Approov integration you should be able to see the results in the live metrics within a minute or so. At this stage you could even release your app to get details of your app population and the attributes of the devices they are running upon.

## NEXT STEPS
To actually protect your APIs and/or secrets there are some further steps. Approov provides two different options for protection:

* [API PROTECTION](https://github.com/approov/quickstart-ios-objectivec-nsurlsession/blob/master/API-PROTECTION.md): You should use this if you control the backend API(s) being protected and are able to modify them to ensure that a valid Approov token is being passed by the app. An [Approov Token](https://approov.io/docs/latest/approov-usage-documentation/#approov-tokens) is short lived crytographically signed JWT proving the authenticity of the call.

* [SECRETS PROTECTION](https://github.com/approov/quickstart-ios-objectivec-nsurlsession/blob/master/SECRETS-PROTECTION.md): This allows app secrets, including API keys for 3rd party services, to be protected so that they no longer need to be included in the released app code. These secrets are only made available to valid apps at runtime.

Note that it is possible to use both approaches side-by-side in the same app.

See [REFERENCE](https://github.com/approov/quickstart-ios-objectivec-nsurlsession/blob/master/REFERENCE.md) for a complete list of all of the `ApproovService` methods.

## DELEGATES
Please note, that the `ApproovNSURLSession` implementation supports network delegates in much the same way the `NSURLSession` class does with one exception: we do not support a task specific delegate since we already implement a session delegate. Unfortunately, this means if you need to use a task specific delegate in order to provide specific authentication, like this:

```ObjectiveC
- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition,
    NSURLCredential *credential))completionHandler;
```

it will not be called. Instead, you can use the session level delegate:

```ObjectiveC
- (void)URLSession:(NSURLSession *)session
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition,
    NSURLCredential *credential))completionHandler
```
