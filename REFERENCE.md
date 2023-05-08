# Reference
This provides a reference for all of the static methods defined on `ApproovService`. These are available if you import as follows:

```ObjectiveC
#import "ApproovNSURLSession.h"
```

Various methods accept as out parameter an `NSError` and fill the object reference if there is a problem. The `NSError` generated contains a dictionary with the following defined keys in the `userInfo` map of the `NSError`:

* `message`: A descriptive error message.
* `type`: Type of the error which may be `general`, `network` or `rejection`. If the type is `network` then this indicates that the error was caused by a temporary networking issue, so an option should be provided to the user to retry.
* `rejectionARC`: Only provided for a `rejection` error type. Provides the [Attestation Response Code](https://approov.io/docs/latest/approov-usage-documentation/#attestation-response-code), which could be provided to the user for communication with your app support to determine the reason for failure, without this being revealed to the end user.
* `rejectionReasons`: Only provided for a `rejection` error type. If the [Rejection Reasons](https://approov.io/docs/latest/approov-usage-documentation/#rejection-reasons) feature is enabled, this provides a comma separated list of reasons why the app attestation was rejected.

## initialize
Initializes the Approov SDK and thus enables the Approov features. The `config` will have been provided in the initial onboarding or email or can be [obtained using the Approov CLI](https://approov.io/docs/latest/approov-usage-documentation/#getting-the-initial-sdk-configuration). This will generate an error if a second attempt is made at initialization with a different `config`.

```ObjectiveC
+ (void)initialize:(NSString *)configString error:(NSError **)error;
```

It is possible to pass an empty `config` string to indicate that no initialization is required. Only do this if you are also using a different Approov quickstart in your app (which will use the same underlying Approov SDK) and this will have been initialized first.

## setProceedOnNetworkFail
If `setProceedOnNetworkFail` is set to `YES` then this indicates that the networking should proceed anyway if it is not possible to obtain an Approov token due to a networking failure. If this is called then the backend API can receive calls without the expected Approov token header being added, or without header substitutions being made. This should only ever be used if there is some particular reason, perhaps due to local network conditions, that you believe that traffic to the Approov cloud service will be particularly problematic.

```ObjectiveC
+ (void)setProceedOnNetworkFailure:(BOOL)proceed;
```

Note that this should be used with *CAUTION* because it may allow a connection to be established before any dynamic pins have been received via Approov, thus potentially opening the channel to a MitM.

## setApproovTokenHeader
Allows to set the name of the header (`approovTokenHeader`) that the Approov token is added on. By default the token is provided on `Approov-Token` with no prefix.

```ObjectiveC
+ (void)setApproovTokenHeader:(NSString *)header;
```

## setApproovTokenPrefix
Sets an optional `prefix` String (such as "`Bearer `") placed before the Approov token iself. The `setApproovTokenPrefix` is not usually required so the default value is an empty string.

```ObjectiveC
+ (void)setApproovTokenPrefix:(NSString *)prefix;
```

## setBindingHeader
Variable that holds the name of a binding header that may be present on requests being made. This is for the [token binding](https://approov.io/docs/latest/approov-usage-documentation/#token-binding) feature. A header should be chosen whose value is unchanging for most requests (such as an Authorization header). If the `setBindHeader` is present, then a hash of the header value is included in the issued Approov tokens to bind them to the value. This may then be verified by the backend API integration.

```ObjectiveC
+ (void)setBindingHeader:(NSString *)header;
```

## addSubstitutionHeader
Adds the name of a header which should be subject to [secure strings](https://approov.io/docs/latest/approov-usage-documentation/#secure-strings) substitution. This means that if the `header` is present then the value will be used as a key to look up a secure string value which will be substituted into the header value instead. This allows easy migration to the use of secure strings. A `prefix` may be specified to deal with cases such as the use of "`Bearer `" prefixed before values in an authorization header. Set `prefix` to `nil` if it is not required.

```ObjectiveC
+ (void)addSubstitutionHeader:(NSString *)header requiredPrefix:(NSString *)prefix;
```

## removeSubstitutionHeader
Removes a `header` previously added using `addSubstitutionHeader`.

```ObjectiveC
+ (void)removeSubstitutionHeader:(NSString *)header;
```

## addSubstitutionQueryParam
Adds a key name for a query parameter that should be subject to secure strings substitution. This means that if the query parameter is present in a URL then the value will be used as a key to look up a secure string value which will be substituted as the query parameter value instead. This allows easy migration to the use of secure strings.

```ObjectiveC
+ (void)addSubstitutionQueryParam:(NSString *)key;
```

## removeSubstitutionQueryParam
Removes a query parameter key name previously added using `addSubstitutionQueryParam`.

```ObjectiveC
+ (void)removeSubstitutionQueryParam:(NSString *)key;
```

## addExclusionURLRegex
Adds an exclusion URL [regular expression](https://regex101.com/) via the `urlRegex` parameter. If a URL for a request matches this regular expression then it will not be subject to any Approov protection.

```ObjectiveC
+ (void)addExclusionURLRegex:(NSString *)urlRegex;
```

Note that this facility must be used with *EXTREME CAUTION* due to the impact of dynamic pinning. Pinning may be applied to all domains added using Approov, and updates to the pins are received when an Approov fetch is performed. If you exclude some URLs on domains that are protected with Approov, then these will be protected with Approov pins but without a path to update the pins until a URL is used that is not excluded. Thus you are responsible for ensuring that there is always a possibility of calling a non-excluded URL, or you should make an explicit call to fetchToken if there are persistent pinning failures. Conversely, use of those option may allow a connection to be established before any dynamic pins have been received via Approov, thus potentially opening the channel to a MitM.

## removeExclusionURLRegex
Removes an exclusion URL regular expression (`urlRegex`) previously added using `addExclusionURLRegex`.

```ObjectiveC
+ (void)removeExclusionURLRegex:(NSString *)urlRegex;
```

## prefetch
Performs a fetch to lower the effective latency of a subsequent token fetch or secure string fetch by starting the operation earlier so the subsequent fetch may be able to use cached data. This initiates the prefetch in a background thread.

```ObjectiveC
+ (void)prefetch;
```

## precheck
Performs a precheck to determine if the app will pass attestation. This requires [secure strings](https://approov.io/docs/latest/approov-usage-documentation/#secure-strings) to be enabled for the account, although no strings need to be set up. 

```ObjectiveC
+ (void)precheck:(NSError **)error;
```

This populates the `NSError` parameter if the precheck failed. This will likely require network access so may take some time to complete, and should not be called from the UI thread.

## getDeviceID
Gets the [device ID](https://approov.io/docs/latest/approov-usage-documentation/#extracting-the-device-id) used by Approov to identify the particular device that the SDK is running on. Note that different Approov apps on the same device will return a different ID. Moreover, the ID may be changed by an uninstall and reinstall of the app.

```ObjectiveC
+ (NSString *)getDeviceID;
```

This returns `nil` if there is an error obtaining the device ID.

## setDataHashInToken
Directly sets the [token binding](https://approov.io/docs/latest/approov-usage-documentation/#token-binding) hash to be included in subsequently fetched Approov tokens. If the hash is different from any previously set value then this will cause the next token fetch operation to fetch a new token with the correct payload data hash. The hash appears in the `pay` claim of the Approov token as a base64 encoded string of the SHA256 hash of the data. Note that the data is hashed locally and never sent to the Approov cloud service. This is an alternative to using `bindHeader` and you should not use both methods at the same time.

```ObjectiveC
+ (void)setDataHashInToken:(NSString *)data;
```

## fetchToken
Performs an Approov token fetch for the given `url`. This should be used in situations where it is not possible to use the `updateRequestHeaders` method to add the token. Note that the returned token should NEVER be cached by your app, you should call this function when it is needed.

```ObjectiveC
+ (NSString *)fetchToken:(NSString *)url error:(NSError **)error;
```

This populates the `NSError` parameter if there was a problem obtaining an Approov token. This may require network access so may take some time to complete, and should not be called from the UI thread.

## getMessageSignature
Gets the [message signature](https://approov.io/docs/latest/approov-usage-documentation/#message-signing) for the given `message`. This is returned as a base64 encoded signature. This feature uses an account specific message signing key that is transmitted to the SDK after a successful fetch if the facility is enabled for the account. Note that if the attestation failed then the signing key provided is actually random so that the signature will be incorrect. An Approov token should always be included in the message being signed and sent alongside this signature to prevent replay attacks.

```ObjectiveC
+ (NSString *)getMessageSignature:(NSString *)message;
```

This return `nil` if there was an error obtaining the signature.

## fetchSecureString
Fetches a [secure string](https://approov.io/docs/latest/approov-usage-documentation/#secure-strings) with the given `key` if `newDef` is `nil`. Returns `nil` if the `key` secure string is not defined. If `newDef` is not `nil` then a secure string for the particular app instance may be defined. In this case the new value is returned as the secure string. Use of an empty string for `newDef` removes the string entry. Note that the returned string should NEVER be cached by your app, you should call this function when it is needed.

```ObjectiveC
+ (NSString *)fetchSecureString:(NSString *)key newDef:(NSString *)newDef error:(NSError **)error;
```

This populates the `NSError` parameter if there was a problem obtaining the secure string. This may require network access so may take some time to complete, and should not be called from the UI thread.

## fetchCustomJWT
Fetches a [custom JWT](https://approov.io/docs/latest/approov-usage-documentation/#custom-jwts) with the given marshaled JSON `payload`.

```ObjectiveC
+ (NSString *)fetchCustomJWT:(NSString *)payload error:(NSError **)error;
```

This populates the `NSError` parameter if there was a problem obtaining the custom JWT. This may require network access so may take some time to complete, and should not be called from the UI thread.
