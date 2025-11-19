
  do ->

    { create-error-context } = dependency 'prelude.error.Context'
    { create-instance } = dependency 'value.Instance'
    { create-http-client, create-json-http-client, form-request } = dependency 'net.HttpClient'

    { value-as-string } = dependency 'prelude.reflection.Value'

    { create-error } = create-error-context 'google.OAuth'

    api-error-message = (status, content) ->

      error-message = "API request failed: #status"
      { error: { message } } = eval "(#content)" ;  if message => error-message += " - #message"
      error-message

    check-response = (result) ->

      { ok, status, content } = result ; unless ok => throw create-error api-error-message status, content
      result

    create-oauth-client = (access-token, base-url) ->

      full-url = (relative-url) -> "#base-url#relative-url"

      oauth-options = (options) -> { ...options, headers: { ...options.headers, 'Authorization': "Bearer #access-token" } }

      http = create-json-http-client!

      create-instance do

        get: method: (relative-url, options) -> http.get (full-url relative-url), (oauth-options options) |> check-response
        post: method: (relative-url, data, options) -> http.post (full-url relative-url), data, (oauth-options options) |> check-response
        patch: method: (relative-url, data, options) -> http.patch (full-url relative-url), data, (oauth-options options) |> check-response
        delete: method: (relative-url, options) -> http.delete (full-url relative-url), (oauth-options options) |> check-response

    {
      create-oauth-client
    }