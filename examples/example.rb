# -*- encoding: utf-8 -*-
require 'multiforecast-client'
require 'pp'

### Create a Multi GrowthForecast Client, the parameter is balancing rule and the base URI of GrowthForecast
### dirpath => GrowthForecast
client = MultiForecast::Client.new({
  'app1/' => 'http://localhost:5125',
  'app2/' => 'http://localhost:5000',
})

pp 'Create a graph (Post a number)'
client.post_graph('app1/2xx_count', { 'number' => 0 })
client.post_graph('app1/3xx_count', { 'number' => 0 })
pp client.post_graph('app2/2xx_count', { 'number' => 0 }) #=>
# {"error"=>0,
#  "data"=>
#   {"number"=>0,
#    "llimit"=>-1000000000,
#    "mode"=>"gauge",
#    "stype"=>"AREA",
#    "adjustval"=>"1",
#    "meta"=>"",
#    "service_name"=>"mgclient",
#    "gmode"=>"gauge",
#    "color"=>"#33cc99",
#    "created_at"=>"2013/05/20 17:57:57",
#    "section_name"=>"mgclient",
#    "ulimit"=>1000000000,
#    "id"=>2,
#    "graph_name"=>"app2%2F2xx_count",
#    "description"=>"",
#    "sulimit"=>100000,
#    "unit"=>"",
#    "sort"=>0,
#    "updated_at"=>"2013/05/20 17:57:57",
#    "adjust"=>"*",
#    "type"=>"AREA",
#    "sllimit"=>-100000,
#    "md5"=>"c81e728d9d4c2f636f067f89cc14862c"}}

pp 'List graphs. All graphs from multiple growthforecasts are shown'
pp client.list_graph #=>
# [{"graph_name"=>"app1%2F3xx_count",
#   "service_name"=>"mgclient",
#   "section_name"=>"mgclient",
#   "id"=>2,
#   "gfuri"=>"http://localhost:5125",
#   "path"=>"app1/3xx_count"},
#  {"graph_name"=>"app1%2F2xx_count",
#   "service_name"=>"mgclient",
#   "section_name"=>"mgclient",
#   "id"=>1,
#   "gfuri"=>"http://localhost:5125",
#   "path"=>"app1/2xx_count"},
#  {"service_name"=>"mgclient",
#   "graph_name"=>"app2%2F2xx_count",
#   "section_name"=>"mgclient",
#   "id"=>2,
#   "gfuri"=>"http://localhost:5000",
#   "path"=>"app2/2xx_count"}]

pp 'List graphs by filtering by dirpath app1/'
pp client.list_graph('app1/') #=>
# [{"graph_name"=>"app1%2F3xx_count",
#   "service_name"=>"mgclient",
#   "section_name"=>"mgclient",
#   "id"=>2,
#   "gfuri"=>"http://localhost:5125",
#   "path"=>"app1/3xx_count"},
#  {"graph_name"=>"app1%2F2xx_count",
#   "service_name"=>"mgclient",
#   "section_name"=>"mgclient",
#   "id"=>1,
#   "gfuri"=>"http://localhost:5125",
#   "path"=>"app1/2xx_count"}]

pp 'Get a graph property'
pp client.get_graph('app2/2xx_count') #=>
# {"number"=>0,
#  "llimit"=>-1000000000,
#  "mode"=>"gauge",
#  "stype"=>"AREA",
#  "adjustval"=>"1",
#  "meta"=>"",
#  "service_name"=>"mgclient",
#  "gmode"=>"gauge",
#  "color"=>"#33cc99",
#  "created_at"=>"2013/05/20 17:57:57",
#  "section_name"=>"mgclient",
#  "ulimit"=>1000000000,
#  "id"=>2,
#  "graph_name"=>"app2%2F2xx_count",
#  "description"=>"",
#  "sulimit"=>100000,
#  "unit"=>"",
#  "sort"=>0,
#  "updated_at"=>"2013/05/20 17:57:57",
#  "adjust"=>"*",
#  "type"=>"AREA",
#  "sllimit"=>-100000,
#  "md5"=>"c81e728d9d4c2f636f067f89cc14862c",
#  "gfuri"=>"http://localhost:5000",
#  "path"=>"app2/2xx_count"}

pp 'Get a graph image uri'
pp client.get_graph_uri('app2/2xx_count', '3h') #=>
# "http://localhost:5125/graph/mgclient/mgclient/app1%2F2xx_count?t=3h"

pp 'Delete a complex graph'
pp client.delete_graph('app2/2xx_count') #=>
# {"location"=>"http://localhost:5000/list/mgclient/mgclient", "error"=>0}

pp 'Create a complex graph'
# Source graphs of a complex graph must exist on *a* GrowthForecast
from_graphs= [
  {"path"=>'app1/2xx_count', "gmode" => 'gauge', "stack" => true, "type" => 'AREA'},
  {"path"=>'app1/3xx_count', "gmode" => 'gauge', "stack" => true, "type" => 'AREA'},
]
to_complex = {
  'path' => 'app1/complex',
  "description"  => "response time count",
  "sort"         => 10,
}
pp client.create_complex(from_graphs, to_complex) #=>
# {"location"=>"http://localhost:5125/list/mgclient/mgclient", "error"=>0}

pp 'Get a complex graph'
pp client.get_complex(to_complex['path']) #=>
# {"number"=>0,
#  "complex"=>true,
#  "created_at"=>"2013/05/20 18:00:09",
#  "service_name"=>"mgclient",
#  "section_name"=>"mgclient",
#  "id"=>1,
#  "graph_name"=>"app1%2Fcomplex",
#  "data"=>
#   [{"gmode"=>"gauge", "stack"=>false, "type"=>"AREA", "graph_id"=>1},
#    {"gmode"=>"gauge", "stack"=>true, "type"=>"AREA", "graph_id"=>2}],
#  "sumup"=>false,
#  "description"=>"response time count",
#  "sort"=>10,
#  "updated_at"=>"2013/05/20 18:00:09",
#  "gfuri"=>"http://localhost:5125",
#  "path"=>"app1/complex"}

pp 'Get a complex graph image uri'
pp client.get_complex_uri(to_complex['path'], '3h') #=>
# "http://localhost:5125/complex/graph/mgclient/mgclient/app1%2Fcomplex?t=3h"

pp 'List complex graphs'
pp client.list_complex #=>
# [{"service_name"=>"mgclient", "graph_name"=>"app1%2Fcomplex", "section_name"=>"mgclient", "id"=>1, "gfuri"=>"http://localhost:5125", "path"=>"app1/complex"}]

pp 'List complex graphs by filetering by dirpath app1/'
pp client.list_complex('app1/')

pp 'Delete a complex graph'
pp client.delete_complex(to_complex['path']) #=>
# {"location"=>"http://localhost:5125/list/mgclient/mgclient", "error"=>0}

