# Approov Quickstart: iOS ObjectiveC NSURLSession

This quickstart is written specifically for native iOS apps that are written in ObjectiveC and making the API calls using [`NSURLSession`](https://developer.apple.com/documentation/foundation/nsurlsession) that you wish to protect with Approov. If this is not your situation then check if there is a more relevant quickstart guide available.

This quickstart provides the basic steps for integrating Approov into your app. A more detailed step-by-step guide using a [Shapes App Example](https://github.com/approov/quickstart-ios-objectivec-nsurlsession/blob/master/SHAPES-EXAMPLE.md) is also available.

To follow this guide you should have received an onboarding email for a trial or paid Approov account.

## ADDING APPROOV SERVICE DEPENDENCY
The Approov integration is available via [`CocoaPods`](https://cocoapods.org/). This allows inclusion into the project by simply specifying a dependency in the `Podfile` for the app:

```
target 'YourApplication' do
    use_frameworks!
    platform :ios, '10.0'
    pod 'approov-service-nsurlsession', '3.0.0', :source => "https://github.com/approov/approov-service-nsurlsession.git"
    pod 'approov-ios-sdk', '3.0.0', :source => "https://github.com/approov/approov-ios-sdk.git"
end
```

This package is actually an open source wrapper layer that allows you to easily use Approov with `NSURLSession`. This has a further dependency to the closed source [Approov SDK](https://github.com/approov/approov-ios-sdk).

## USING APPROOV NSURLSESSION
The `ApproovURLSession` class mimics the interface of the `NSURLSession` class provided by Apple but includes an additional ApproovSDK attestation call. The simplest way to use the `ApproovURLSession` is to find and replace all the `NSURLSession` with `ApproovURLSession`.

Additionally, the `ApproovService` needs to be initialized before any network request is made using `ApproovURLSession`. The `ApproovService` initialization requires a configuration string parameter replacing `<enter-your-config-string-here>`, which is a custom string that configures your Approov account access. This will have been provided in your Approov onboarding email (it will be something like `#123456#K/XPlLtfcwnWkzv99Wj5VmAxo4CrU267J1KlQyoz8Qo=`). An additional parameter is an `NSError` reference which would provide any error messages if a failure occurs.

```ObjectiveC
ApproovService *approovService = [ApproovService sharedInstance:@"<enter-your-config-string-here>" error:&error];
if (error != nil) {
    ApproovURLSession* defaultSession = [ApproovURLSession sessionWithConfiguration:NSURLSessionConfiguration.defaultSessionConfiguration];
}
```

For API domains that are configured to be protected with an Approov token, this adds the `Approov-Token` header and pins the connection. This may also substitute header values when using secret protection.
Please note on the above code, the `ApproovService` is instantiated and the error condition is checked for and only in case of no failure, the netwok session and later actual requests are performed. Failure to initialise the `ApproovService` should cancel any network requests since lack of initialization is generaly considered fatal.

## ERROR MESSAGES
The `ApproovService` adds additional information to the error parameter passed as argument in all the `ApproovURLSession` network calls. The additional information allows further troubleshooting and suggest if a retry should be attempted after certain time or user interaction has been requested. The error key pair values used by the `ApproovService` are:

* ApproovServiceError    which contains a string with the error message
* RejectionReasons       if the command line option is enabled (approov policy -setRejectionReasons on) you will obtain a list of rejections as string values
* ARC                    allows inspection of [Attestation Response Code](https://approov.io/docs/latest/approov-usage-documentation/#getting-an-attestation-response-code) which is a base32 encoded string, if the feature is enabled 
* RetryLastOperation     string (either `YES` or `NO`) which indicates if there might be a reasonable chance of the operation succeeding if it is reattempted later

## CHECKING IT WORKS
Initially you won't have set which API domains to protect, so the interceptor will not add anything. It will have called Approov though and made contact with the Approov cloud service. You will see logging from Approov saying `UNKNOWN_URL`.

Your Approov onboarding email should contain a link allowing you to access [Live Metrics Graphs](https://approov.io/docs/latest/approov-usage-documentation/#metrics-graphs). After you've run your app with Approov integration you should be able to see the results in the live metrics within a minute or so. At this stage you could even release your app to get details of your app population and the attributes of the devices they are running upon.
