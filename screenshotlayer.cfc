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
      structInsert( result, "image", apiResponse.fileContent );
      //provide error key in response, for more consistent handling
      structAppend( result, {"success" : "YES"}, true);
    } else {
      structAppend( result, deserializeJSON( apiResponse.fileContent ), true );
    }

    return result;
  }

  private any function makeHttpRequest( required string urlPath, required struct params, required string method ) {
    var http = new http( url = urlPath, method = method, timeout = variables.httpTimeout );

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
      //maybe add line to exclude false params and check to see if the param itself is valid (only if invalid params throw errors)
      if ( structKeyExists( params, paramKey ) && !isNull( params[ paramKey ] ) ) {
        filteredParams[ paramKey ] = params[ paramKey ];
      }
    }

    return filteredParams;
  }

  private any function getValidatedParam( required string paramName, required any paramValue, boolean validate = true ) {
    // only simple values
    if ( !isSimpleValue( paramValue ) ) throwError( "'#paramName#' is not a simple value." );

    // if not validation just result trimmed value
    if ( !validate ) {
      return trim( paramValue );
    }

    // integer
    if ( arrayFindNoCase( variables.integerFields, paramName ) ) {
      if ( !isInteger( paramValue ) ) {
        throwError( "field '#paramName#' requires an integer value" );
      }
      return paramValue;
    }
    // numeric
    if ( arrayFindNoCase( variables.numericFields, paramName ) ) {
      if ( !isNumeric( paramValue ) ) {
        throwError( "field '#paramName#' requires a numeric value" );
      }
      return paramValue;
    }

    // boolean
    if ( arrayFindNoCase( variables.booleanFields, paramName ) ) {
      return ( paramValue ? "true" : "false" );
    }

    // timestamp
    if ( arrayFindNoCase( variables.timestampFields, paramName ) ) {
      return parseUTCTimestampField( paramValue, paramName );
    }

    // default is string
    return trim( paramValue );
  }

  private string function encodeurl( required string str ) {
    return replacelist( urlEncodedFormat( str, "utf-8" ), "%2D,%2E,%5F,%7E", "-,.,_,~" );
  }

  private void function throwError( required string errorMessage ) {
    throw( type = "Screenshotlayer", message = "(screenshotlayer.cfc) " & errorMessage );
  }

}