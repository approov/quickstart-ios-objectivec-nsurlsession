# Approov Quickstart: iOS ObjectiveC NSURLSession

This quickstart is written specifically for native iOS apps that are written in ObjectiveC and making the API calls using [`NSURLSession`](https://developer.apple.com/documentation/foundation/nsurlsession) that you wish to protect with Approov. If this is not your situation then check if there is a more relevant quickstart guide available.

This quickstart provides the basic steps for integrating Approov into your app. A more detailed step-by-step guide using a [Shapes App Example](https://github.com/approov/quickstart-ios-objc-nsurlsession/blob/master/SHAPES-EXAMPLE.md) is also available.

To follow this guide you should have received an onboarding email for a trial or paid Approov account.

## ADDING APPROOVSERVICE DEPENDENCY
The Approov integration is available via [`CocoaPods`](https://cocoapods.org/). This allows inclusion into the project by simply specifying a dependency in the `Podfile` for the app:

```
target 'YourApplication' do
    use_frameworks!
    platform :ios, '10.0'
    pod 'approov-service-nsurlsession', '2.7.0', :source => "https://github.com/approov/approov-service-nsurlsession.git"
    pod 'approov-ios-sdk', '2.7.0', :source => "https://github.com/approov/approov-ios-sdk.git"
end
```

This package is actually an open source wrapper layer that allows you to easily use Approov with `NSURLSession`. This has a further dependency to the closed source [Approov SDK](https://github.com/approov/approov-ios-sdk).

## USING APPROOVNSURLSESSION
The `ApproovURLSession` class mimics the interface of the `NSURLSession` class provided by Apple but includes an additional ApproovSDK attestation call. The simplest way to use the `ApproovURLSession` is to find and replace all the `NSURLSession` with `ApproovURLSession`. Additionally, the Approov SDK needs to be initialized before use. The `<enter-your-config-string-here>` is a custom string that configures your Approov account access. This will have been provided in your Approov onboarding email (it will be something like `#123456#K/XPlLtfcwnWkzv99Wj5VmAxo4CrU267J1KlQyoz8Qo=`).

```ObjectiveC
ApproovURLSession* defaultSession = [ApproovURLSession sessionWithConfiguration:NSURLSessionConfiguration.defaultSessionConfiguration configString:@"<enter-your-config-string-here>"];
```

## CHECKING IT WORKS
Initially you won't have set which API domains to protect, so the interceptor will not add anything. It will have called Approov though and made contact with the Approov cloud service. You will see logging from Approov saying `UNKNOWN_URL`.

Your Approov onboarding email should contain a link allowing you to access [Live Metrics Graphs](https://approov.io/docs/latest/approov-usage-documentation/#metrics-graphs). After you've run your app with Approov integration you should be able to see the results in the live metrics within a minute or so. At this stage you could even release your app to get details of your app population and the attributes of the devices they are running upon.

However, to actually protect your APIs there are some further steps you can learn about in [Next Steps](https://github.com/approov/quickstart-ios-objc-nsurlsession/blob/master/NEXT-STEPS.md).
