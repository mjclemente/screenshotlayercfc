# screenshotlayercfc
A CFML wrapper for the Screenshotlayer API

This project borrows heavily from the API framework built by [jcberquist](https://github.com/jcberquist) with [stripecfc](https://github.com/jcberquist/stripecfc).

# Getting Started

	screenshotlayer = new path.to.screenshotlayer( access_key = 'xxx' );
	
	//make sure that the url argument is full (including http protocol)
	screenshot = screenshotlayer.getScreenshot( url = 'https://github.com' );
	
	if ( screenshot.success ) {
		//the second option is the location you would like the screenshot image written to
		imageWrite( screenshot.image, "screenshot.png" );
	} else {
		//you probably want more elegant error handling than this
		writeDump(screenshot);
	}

# Result

Calls to the API return a struct with the following keys:

| Key |  Returned on Success? | Returned on Failure? | Description |
|---|---|---|---|
| success | yes | yes | Boolean indicator of the success or failure of the call. Use this to determine what other keys are available. |
| image | yes | no | The screenshot, as a ColdFusion image object. You'll probably want to write this to a file. |
| error | no | yes | The [error object returned by the API](https://screenshotlayer.com/documentation#error_codes), it contains three additional keys: "code", "info", and "type".   |
| api_request_time | yes | yes | Time the request took |
| status_code | yes | yes | HTTP status code returned |
| status_text | yes | yes | HTTP status text returned |
| raw | yes | yes | This is an optional key that defaults to being off. You can turn it on during development to provide additional information about the call made to the API, and the response. To enable it, include `includeRaw = true` when the component is init. |
	
# Options

The documentation for Screenshotlayer.com's API is here: https://screenshotlayer.com/documentation

All the options have been implemented in the getScreenshot method: 

	getScreenshot( required string url, boolean fullpage, numeric width, string viewport = "1440x900", format = "PNG", string css_url, numeric delay, numeric ttl = "2592000", boolean force, string placeholder, string user_agent, string accept_lang = "en-US", string export )

# HTTPS Endpoint

If you are a paying customer, you can use their secure endpoint. Just override the default API url when you init the component:
	
	screenshotlayer = new path.to.screenshotlayer( access_key = 'xxx', baseUrl = 'https://api.screenshotlayer.com/api/capture' );
	
# URL Encryption

If you have a secret key set on your account, to enable the API's URL encryption, the key is passed in as an additional argument when you init the component:

	screenshotlayer = new path.to.screenshotlayer( access_key = 'xxx', secret_key = 'xxx' );
