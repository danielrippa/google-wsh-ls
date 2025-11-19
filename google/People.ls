
  do ->

    { create-instance } = dependency 'value.Instance'
    { create-oauth-client } = dependency 'google.OAuth'

    create-google-people-client = (access-token) ->

      client = create-oauth-client access-token, 'https://people.googleapis.com/v1'

      create-instance do

        list-contacts: method: (page-size = 100, page-token = '', fields-to-return = 'names,emailAddresses,phoneNumbers') ->

          query = pageSize: page-size, personFields: fields-to-return, pageToken: page-token
          client.get '/people/me/connections', { query }

        get-person: method: (resource-name, fields-to-return = 'names,emailAddresses,phoneNumbers,addresses,organizations') ->

          client.get "/#resource-name", query: personFields: fields-to-return

        get-search-contacts-page: method: (text-to-search-for, page-size = 30, page-token, fields-to-return = 'names,emailAdddresses,phoneNumbers') ->

          query = query: text-to-search-for, pageSize: page-size, read-mask: fields-to-return ; if pageToken => query <<< { pageToken: page-token }

          client.get '/people:searchContacts', { query }

        search-contacts: method: (text-to-search-for, fields-to-return = 'names,emailAddresses,phoneNumbers') ->

          all-results = [] ; page-token = void

          loop

            { json } = @get-search-contacts-page text-to-search-for, 100, page-token, fields-to-return

            { results, totalItems, nextPageToken } = json

            if results => all-results = all-results ++ results

            page-token = nextPageToken ; break unless page-token

          all-results

        create-contact: method: (contact-data) -> client.post '/people:createContact', contact-data

        update-contact: method: (resource-name, contact-data, fields-to-update) -> client.patch '/#resource-name:updateContact', contact-data, query: updatePersonFields: fields-to-update

        delete-contact: method: (resource-name) -> client.delete "/#resource-name:deleteContact"

    {
      create-google-people-client
    }
