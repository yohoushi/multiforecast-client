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
```

Post a number and create a graph:

```
$ multiforecast post '{"number":0}' 'foo/a/b/c' -c multiforecast.yml
```

Delete a graph or graphs under a base path:

```
$ multiforecast delete 'foo/' -c multiforecast.yml
```

Change the color of graphs under a base path:

```
$ multiforecast color -k '2xx_count:#1111cc' '3xx_count:#11cc11' -b 'foo/' -c multiforecast.yml
```

Create complex graphs under a base path:

```
$ multiforecast create_complex -f 2xx_count 3xx_count -t status_count -b 'foo/' -c multiforecast.yml
```

See help for more:

```
$ multiforecast help
```

## Tips

### Debug Print

Following codes print http requests and resposes to STDOUT

```ruby
client = MultiForecast::Client.new('mapping' => {
  'foo/' => 'http://localhost:5125',
  ''     => 'http://localhost:5000'
})
client.debug_dev = STDOUT # IO object
```

## INSIDE: How to treat graphs of more than 3 levels

Although GrowthForecast can treat only graphs of 3 leveled path, MultiForecast can handle graphs of more than 3 levels.
This feature is achieved by converting a given path string to `service_name/section_name/graph_name` path of GrowthForecast as follows:

    service_name = 'multiforecast'
    section_name = CGI.escape(File.dirname(path)).gsub('+', '%20').gsub('.', '%2E')
    graph_name   = File.basename(path)

As a viewer for such converted graphs, you can use [Yohoushi](https://github.com/yohoushi/yohoushi) visualization tool.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new [Pull Request](../../pull/new/master)

## Copyright

Copyright (c) 2013 Naotoshi SEO. See [LICENSE](LICENSE) for details.
