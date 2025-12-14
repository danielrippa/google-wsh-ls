
  do ->

    { create-error-context } = dependency 'prelude.error.Context'
    { create-url-builder, urls-from-url-builder } = dependency 'net.URL'
    { map-array-items } = dependency 'value.Array'
    { create-http-client } = dependency 'net.http.Client'

    { argtype, create-error } = create-error-context 'google.auth.OAuth'

    #

    oob-uri = <[ urn ietf wg oauth 2.0 oob ]> * ':'

    #

    get-apis-auth-url-builder = -> create-url-builder 'www.googleapis.com', secure: yes, path: <[ auth ]>
    get-oauth-url-builder = -> create-url-builder 'accounts.google.com', secure: yes, path: <[ o oauth2 auth ]>

    [ oauth-token-url, oauth-device-code-url, oauth-tokeninfo-url ] = urls-from-url-builder (create-url-builder 'oauth2.googleapis.com', secure: yes), [ <[ token ]> <[ device code ]> <[ tokeninfo ]> ]

    build-scopes-urls = (scopes) -> urls-from-url-builder get-apis-auth-url-builder!, map-array-items scopes, -> [it]

    #

    get-auth-code-url = (client-id, scopes) ->

      scope = (build-scopes-urls scopes) * ' '

      query = client_id: client-id, redirect_uri: oob-uri, scope: scope, response_type: 'code', access_type: 'offline'

      get-oauth-url-builder!clone-with { query } .as-string!

    #

    get-token-response-for-auth-code = (client-id, client-secret, auth-code) ->

      query = client_id: client-id, client_secret: client-secret, code: auth-code, grant-type: 'authorization_code', redirect_uri: oob-uri

      { ok, status, content } = create-http-client!form oauth-token-url, query
      unless ok => create-error "Token exchange failed: #status - #content"

      { access_token: access-token, refresh_token: refresh-token, expires_in: expires-in, token_type: token-type } = eval "(#content)"

      { access-token, refresh-token, expires-in, token-type }

    {
      get-auth-code-url,
      get-token-response-for-auth-code
    }