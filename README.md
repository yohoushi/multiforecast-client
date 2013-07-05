# multiforecast-client

testing ruby: 1.9.2, 1.9.3, 2.0.0; GrowthForecast: >= 0.62 (Jun 27, 2013 released)

## About multiforecast-client

`multiforecast-client` is a Multiple GrowthForecast Client. 

Features

- Possible to send http requests to multiple growthforecasts seemlessly
- Enables to create graphs whose levels are more than 3.
- CRUD graphs
- Get graph image uri

## USAGE

Create a client. NOTE: ruby's hash is an ordered hash. 

    client = MultiForecast::Client.new(mapping: {
      'foo/' => 'http://localhost:5125',
      ''     => 'http://localhost:5000'
    })

The first `post_graph` posts a number to the first GrowthForecast.
The second `post_graph` posts a number to the second GrowthForecast because the specified path did not match with the first mapping rule 'foo/'.

    client.post_graph('foo/b/c/d', { 'number' => 0 })
    client.post_graph('bar/b/c/d', { 'number' => 0 })

See [examples](./examples) for more.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new [Pull Request](../../pull/new/master)

## Copyright

Copyright (c) 2013 Naotoshi SEO. See [LICENSE](LICENSE) for details.
