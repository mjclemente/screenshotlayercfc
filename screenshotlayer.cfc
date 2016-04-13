component output="false" displayname="Screenshotlayer.cfc"  {

  public any function init( required string access_key, string secret_key = "", string baseUrl = "http://api.screenshotlayer.com/api/capture", numeric httpTimeout = 60, boolean includeRaw = true ) {

    structAppend( variables, arguments );
    return this;
  }

  public struct function getScreenshot( required string url, boolean fullpage, numeric width, string viewport = "1440x900", format = "PNG", string css_url, numeric delay, numeric ttl = "2592000", boolean force, string placeholder, string user_agent, string accept_lang = "en-US", string export ) {

    return apiCall( "?access_key=#variables.access_key#", setupParams( arguments ), "get" );
  }

  // PRIVATE FUNCTIONS
  private struct function apiCall( required string path, required struct params, string method = "get" )  {

    var fullApiPath = variables.baseUrl & path;
    var requestStart = getTickCount();

    //encryption here?
    if ( len( variables.secret_key ) ) {
      params["secret_key"] = lcase( hash( params.url & variables.secret_key ) );
    }

    var apiResponse = makeHttpRequest( urlPath = fullApiPath, params = params, method = method );

    var result = { "api_request_time" = getTickCount() - requestStart, "status_code" = listFirst( apiResponse.statuscode, " " ), "status_text" = listRest( apiResponse.statuscode, " " ) };
    if ( variables.includeRaw ) {
      result[ "raw" ] = { "method" = ucase( method ), "path" = fullApiPath, "params" = serializeJSON( params ), "response" = apiResponse.fileContent, "headers" = apiResponse.Responseheader };
    }

    if ( isObject( apiResponse.fileContent ) ) {
      structInsert( result, "image", imagenew( apiResponse.fileContent.toByteArray() ) );
      //provide error key in response, for more consistent handling
      structAppend( result, {"success" : "YES"}, true);
    } else {
      structAppend( result, deserializeJSON( apiResponse.fileContent ), true );
    }

    return result;
  }

  private any function makeHttpRequest( required string urlPath, required struct params, required string method ) {
    var http = new http( url = urlPath, method = method, timeout = variables.httpTimeout, file="screenshot.png" );

    // adding a user agent header so that Adobe ColdFusion doesn't get mad about empty HTTP posts
    http.addParam( type = "header", name = "User-Agent", value = "screenshotlayer.cfc" );

    var qs = [ ];

    for ( var param in params ) {

      arrayAppend( qs, lcase( param ) & "=" & encodeurl( params[param] ) );

    }

    http.setUrl( urlPath & "&" & arrayToList( qs, "&" ) );

    return http.send().getPrefix();
  }

  private struct function setupParams( required struct params ) {
    var filteredParams = { };
    var paramKeys = structKeyArray( params );
    for ( var paramKey in paramKeys ) {
      if ( structKeyExists( params, paramKey ) && !isNull( params[ paramKey ] ) ) {
        filteredParams[ paramKey ] = params[ paramKey ];
      }
    }

    return filteredParams;
  }

  private string function encodeurl( required string str ) {
    return replacelist( urlEncodedFormat( str, "utf-8" ), "%2D,%2E,%5F,%7E", "-,.,_,~" );
  }

}