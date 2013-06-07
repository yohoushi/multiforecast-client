# -*- encoding: utf-8 -*-

base_uri = 'http://localhost:5125'

shared_context "stub_list_graph" do
  def list_graph_example
    [
      {"gfuri"=>'http://localhost:5125',
       "path"=>"app name/host name/<1sec count",
       "service_name"=>"mfclient",
       "section_name"=>"app%20name%2Fhost%20name",
       "graph_name"=>"<1sec count",
       "id"=>1},
      {"gfuri"=>'http://localhost:5125',
       "path"=>"app name/host name/<2sec count",
       "service_name"=>"mfclient",
       "section_name"=>"app+name%2Fhost+name",
       "graph_name"=>"<2sec count",
        "id"=>2},
    ]
  end

  proc = Proc.new do
    # WebMock.allow_net_connect!
    stub_request(:get, "#{base_uri}/json/list/graph").to_return(:status => 200, :body => list_graph_example.to_json)
  end
  before(:each, &proc)
end

shared_context "stub_get_graph" do
  def graph_example
    {
      "gfuri"=>"http://localhost:5125",
      "path"=>"app name/host name/<1sec count",
      "number"=>0,
      "llimit"=>-1000000000,
      "mode"=>"gauge",
      "stype"=>"AREA",
      "adjustval"=>"1",
      "meta"=>"",
      "service_name"=>"mfclient",
      "gmode"=>"gauge",
      "color"=>"#cc6633",
      "created_at"=>"2013/02/02 00:41:11",
      "section_name"=>"app%20name%2Fhost%20name",
      "ulimit"=>1000000000,
      "id"=>1,
      "graph_name"=>"<1sec count",
      "description"=>"",
      "sulimit"=>100000,
      "unit"=>"",
      "sort"=>0,
      "updated_at"=>"2013/02/02 02:32:10",
      "adjust"=>"*",
      "type"=>"AREA",
      "sllimit"=>-100000,
      "md5"=>"3c59dc048e8850243be8079a5c74d079"
    }
  end

  proc = Proc.new do
    stub_request(:get, "#{base_uri}/api/#{gfpath(graph['path'])}").
    to_return(:status => 200, :body => graph_example.to_json)
  end
  before(:each, &proc)
end

shared_context "stub_post_graph" do
  include_context "stub_get_graph"
  proc = Proc.new do
    stub_request(:post, "#{base_uri}/api/#{gfpath(graph['path'])}").
    to_return(:status => 200, :body => { "error" => 0, "data" => graph_example }.to_json)
  end
  before(:each, &proc)
end

shared_context "stub_delete_graph" do
  proc = Proc.new do
    stub_request(:post, "#{base_uri}/delete/#{gfpath(graph['path'])}").
    to_return(:status => 200, :body => { "error" => 0 }.to_json)
  end
  before(:each, &proc)
end

shared_context "stub_edit_graph" do
  include_context "stub_get_graph"

  proc = Proc.new do
    stub_request(:post, "#{base_uri}/json/edit/graph/#{graph['id']}").
    to_return(:status => 200, :body => { "error" => 0 }.to_json)
  end
  before(:each, &proc)
end

shared_context "stub_list_complex" do
  def list_complex_example
    [
      {"gfuri"=>"http://localhost:5125",
       "path"=>"app name/host name/complex graph test",
       "service_name"=>"mfclient",
       "section_name"=>"app%20name%2Fhost%20name",
       "graph_name"=>"<1sec count",
       "id"=>1},
    ]
  end

  proc = Proc.new do
    stub_request(:get, "#{base_uri}/json/list/complex").
    to_return(:status => 200, :body => list_complex_example.to_json)
  end
  before(:each, &proc)
end

shared_context "stub_get_complex" do
  def complex_example
    {"gfuri"=>"http://localhost:5125",
     "path"=>"app name/host name/complex graph test",
     "service_name"=>"mfclient",
     "section_name"=>"app%20name%2Fhost%20name",
     "graph_name"=>"complex graph test",
     "number"=>0,
     "complex"=>true,
     "created_at"=>"2013/05/20 15:08:28",
     "id"=>1,
     "data"=>
    [{"gmode"=>"gauge", "stack"=>false, "type"=>"AREA", "graph_id"=>218},
     {"gmode"=>"gauge", "stack"=>true, "type"=>"AREA", "graph_id"=>217}],
    "sumup"=>false,
    "description"=>"complex graph test",
    "sort"=>10,
    "updated_at"=>"2013/05/20 15:08:28"}
  end

  proc = Proc.new do
    stub_request(:get, "#{base_uri}/json/complex/#{gfpath(to_complex['path'])}").
    to_return(:status => 200, :body => complex_example.to_json)
  end
  before(:each, &proc)
end

shared_context "stub_delete_complex" do
  proc = Proc.new do
    stub_request(:post, "#{base_uri}/json/delete/complex/#{gfpath(to_complex['path'])}").
    to_return(:status => 200, :body => { "error" => 0 }.to_json)
  end
  before(:each, &proc)
end

shared_context "stub_create_complex" do
  include_context "stub_list_complex"

  proc = Proc.new do
    list_graph_example.each do |graph|
      stub_request(:get, "#{base_uri}/api/#{gfpath(graph['path'])}").
      to_return(:status => 200, :body => graph.to_json)
    end

    stub_request(:post, "#{base_uri}/json/create/complex").
    to_return(:status => 200, :body => { "error" => 0 }.to_json)
  end
  before(:each, &proc)
end

