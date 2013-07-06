# multiforecast-client

testing ruby: 1.9.2, 1.9.3, 2.0.0; GrowthForecast: >= 0.62 (Jun 27, 2013 released)

## About multiforecast-client

`multiforecast-client` is a Multiple GrowthForecast Client, aimed to be used for [Yohoushi](https://github.com/yohoushi/yohoushi) visualization tool.

Features

- Possible to send http requests to multiple growthforecasts seemlessly
- Enables to create graphs whose levels are more than 3.
- CRUD graphs
- Get graph image uri

## USAGE

### Library

Create a client.

```ruby
require 'multiforecast-client'
client = MultiForecast::Client.new('mapping' => {
  'foo/' => 'http://localhost:5125',
  ''     => 'http://localhost:5000'
})
```

The first `post_graph` posts a number to the first GrowthForecast.
The second `post_graph` posts a number to the second GrowthForecast because the specified path did not match with the first mapping rule 'foo/'.
Notice that the pattern matching is processed from top as ruby's hash is an ordered hash.

```ruby
client.post_graph('foo/b/c/d', { 'number' => 0 })
client.post_graph('bar/b/c/d', { 'number' => 0 })
```

See [examples](./examples) for more.

### CLI

`multiforecast-client` also provides a CLI named `multiforecast`.

Generate a config file template to store a mapping rule:

```
$ multiforecast genearte config
Generated multiforecast.yml
$ cat multiforecast.yml
---
mapping:
  '': http://localhost:5125
short_metrics: true
```

Post a number and create a graph:

```
$ multiforecast post '{"number":0}' 'foo/a/b/c' -c multiforecast.yml
```

Delete a graph or graphs under a path:

```
$ multiforecast delete 'foo/' -c multiforecast.yml
```

See help for more:

```
$ multiforecast help
```

## INSIDE: How to treat graphs of more than 3 levels

Although GrowthForecast can treat only graphs of 3 leveled path, MultiForecast can handle graphs of more than 3 levels.
This feature is achieved by converting a given path to GrowthForecast's `service_name/section_name/graph_name` path as follows:

    service_name = 'multiforecast'
    section_name = CGI.escape(File.dirname(path)).gsub('+', '%20').gsub('.', '%2E')
    graph_name   = File.basename(path)

As a viewer for these converted path, [Yohoushi](https://github.com/yohoushi/yohoushi) is ready for you.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new [Pull Request](../../pull/new/master)

## Copyright

Copyright (c) 2013 Naotoshi SEO. See [LICENSE](LICENSE) for details.
