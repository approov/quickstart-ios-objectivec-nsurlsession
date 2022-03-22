# Secret Protection
You should use this option if you wish to protect access to 3rd party or managed APIs where you are not able to add an Approov token check to the backend. This allows client secrets, or API keys, used for access to be protected with Approov. Rather than build secrets into an app where they might be reverse engineered, they are only provided at runtime by Approov for apps that are pass Approov attestation. This substantially improves your protection and prevents these secrets being abused by attackers. Where you are able to modify the backend we recommend you use Token Protection for further enchanced flexibility and security.

This quickstart provides straightforward implementation if the secret is currently supplied in a request header to the API. The `ApproovURLSession` class used as a connection is able to automatically substitute in the secret for headers, but only if the app has passed the Approov attestation checks. If the app fails its checks then you can add a custom [rejection](#handling-rejections) handler.

These additional steps require access to the [Approov CLI](https://approov.io/docs/latest/approov-cli-tool-reference/), please follow the [Installation](https://approov.io/docs/latest/approov-installation/) instructions.

## ENABLING MANAGED TRUST ROOTS
Client secrets or API keys also need to be protected in transit. For 3rd party APIs you should not pin against their certificates since you are not in control of when they might changed. Instead the [Managed Trust Roots](https://approov.io/docs/latest/approov-usage-documentation/#managed-trust-roots) feature can be used to protect TLS.

Ensure managed trust roots are enabled using:

```
approov pin -setManagedTrustRoots on 
```

> Note that this command requires an [admin role](https://approov.io/docs/latest/approov-usage-documentation/#account-access-roles).

This ensures connections may only use official certificates, and blocks the use of self signed certificates that might be used by a Man-in-the-Middle (MitM) attacker.

## ADDING API DOMAINS
In order for secrets to be protected for particular API domains it is necessary to inform Approov about them. Execute the following command:

```
approov api -add <your-domain> -noApproovToken
```

This informs Approov that it should be active for the domain, but does not need to send Approov tokens for it. Adding the domain ensures that the channel will be protected against Man-in-the-Middle (MitM) attacks.

## MIGRATING THE SECRET INTO APPROOV
It is assumed that you already have some client secrets and/or API keys in your app that you would like to migrate for protection by Approov. To do this you first need to enable the [Secure Strings](https://approov.io/docs/latest/approov-usage-documentation/#secure-strings) feature:

```
approov secstrings -setEnabled
```

> Note that this command requires an [admin role](https://approov.io/docs/latest/approov-usage-documentation/#account-access-roles).

The quickstart integration works by allowing you to replace the secret in your app with a placeholder value instead, and then the placeholder value is mapped to the actual secret value automatically, if the app passes Approov attestation. The shipped app code will only contain the placeholder values.

If your app currently uses `<secret-value>` then replace it in your app with the value `<secret-placeholder>`. Choose a suitable placeholder name to reflect the type of the secret. The placeholder value will be added to requests in the normal way, but you should be using the Approov enabled networking client to perfom the substituion.

You must inform Approov that it should substitute `<secret-placeholder>` for `<secret-value>` in requests as follows:

```
approov secstrings -addKey <secret-placeholder> -predefinedValue <secret-value>
```
> Note that this command also requires an [admin role](https://approov.io/docs/latest/approov-usage-documentation/#account-access-roles).

You can add up to 16 different secret values to be substituted in this way.

If the secret value is provided on the header `<secret-header>` then it is necessary to notify the `ApproovService` that the header is subject to substitution. You do this by making the call once, after initialization:

```ObjectiveC
[YourApp.approovService addSubstitutionHeader:@"<secret-header>" requiredPrefix:nil];
```

With this in place, network calls using `ApproovURLSession` should replace the `<secret-placeholder>` with the `<secret-value>` as required when the app passes attestation.  Since the mapping lookup is performed on the placeholder value you have the flexibility of providing different secrets on different API calls, even if they passed with the same header name.

Since earlier released versions of the app may have already leaked the `<secret-value>`, you may wish to refresh the secret at some later point when any older version of the app is no longer in use. You can of course do this update over-the-air using Approov without any need to modify the app.

## REGISTERING APPS
In order for Approov to recognize the app as being valid it needs to be registered with the service. Change the directory to the top level of your app project and then register the app with Approov:

```
approov registration -add YourApp.ipa
```
Note, on Windows you need to substitute \ for / in the above command.

> **IMPORTANT:** The registration takes up to 30 seconds to propagate across the Approov Cloud Infrastructure, therefore don't try to run the app again before this time as elapsed. During development of your app you can ensure it [always passes](https://approov.io/docs/latest/approov-usage-documentation/#adding-a-device-security-policy) on your device to not have to register the APK each time you modify it.

[Managing Registrations](https://approov.io/docs/latest/approov-usage-documentation/#managing-registrations) provides more details for app registrations, especially for releases to the Apple Store. Of particular interest to iOS is the use of codesigning certificates that belong to different team identifiers.

## HANDLING REJECTIONS
If the app is not recognized as being valid by Approov then the `NSError` variable is returned from the network request and the API call is not completed. The secret value will never be communicated to the app in this case.

Your app can query the `NSError` message and check if it contains an `ARC` key in its dictionary which should provide more information regarding a possible reason for the failure, as explained in [Attestation Response Code](https://approov.io/docs/latest/approov-usage-documentation/#attestation-response-code). It would be possible to provide more information about the status of the device without revealing any details to the user.

If you wish to provide more direct feedback then enable the [Rejection Reasons](https://approov.io/docs/latest/approov-usage-documentation/#rejection-reasons) feature:

```
approov policy -setRejectionReasons on
```

> Note that this command requires an [admin role](https://approov.io/docs/latest/approov-usage-documentation/#account-access-roles).

You will then be able to use the `rejectionReasons` key in the `NSError` returned from the network call to obtain a comma separated list of [device properties](https://approov.io/docs/latest/approov-usage-documentation/#device-properties) responsible for causing the rejection.

## FURTHER OPTIONS

See [Getting Started With Approov](https://approov.io/docs/latest/approov-usage-documentation/#getting-started-with-approov) for information about additional Approov features you may wish to try.

The quickstart also provides the following additional methods:

### Header Prefixes
In some cases the value to be substituted on a header may be prefixed by some fixed string. A common case is the presence of `Bearer` included in an authorization header to indicate the use of a bearer token. In this case you can specify a prefix as follows:

```ObjectiveC
[YourApp.approovService addSubstitutionHeader:@"Authorization" requiredPrefix:@"Bearer "];
```

This causes the `Bearer` prefix to be stripped before doing the lookup for the substitution, and the `Bearer` prefix added to the actual secret value as part of the substitution.

### App Instance Secure Strings
As shown, it is possible to set predefined secret strings that are only communicated to passing apps. It is also possible to get and set secure string values for each app instance. These are never communicated to the Approov cloud service, but are encrypted at rest using keys which can only be retrieved by passing apps.

Use the the following method in `ApproovSDK`:

```ObjectiveC
-(NSString*)fetchSecureString:(NSString*)key newDefinition:(NSString*)newDef error:(NSError**)error
```

to lookup a secure string with the given `key`, returning `nil` if it is not defined. Note that you should never cache this value in your code. Approov does the caching for you in a secure way. You may define a new value for the `key` by passing a new value in `newDef` rather than `nil`. An empty string `newDef` is used to delete the secure string.

Note that this method may make networking calls so should never be called from the main UI thread. Any failure during the call should populate the `NSError` variable provided with failure reason in the `ApproovSDKError` key. If this is of type `ApproovTokenFetchStatusNoNetwork` then a retry should be performed as the issue is temporary and network related. If `ApproovTokenFetchStatusRejected` is shown then the app has not passed Approov attestation and some user feedback should be provided.

This method is also useful for providing runtime secrets protection when the values are not passed on headers.  

### Prefetching
If you wish to reduce the latency associated with substituting the first secret, then make this call immediately after creating `ApproovService`:

```ObjectiveC
[YourApp.approovService prefetchApproovToken];
```

This initiates the process of fetching the required information as a background task, so that it is available immediately when subsequently needed. Note the information will automatically expire after approximately 5 minutes.