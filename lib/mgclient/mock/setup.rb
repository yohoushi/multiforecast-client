# -*- encoding: utf-8 -*-

shared_context "setup_mgclient" do
  include_context "stub_list_graph" if ENV['MOCK'] == 'on'
  let(:graphs) { mgclient.list_graph }
  let(:graph) { graphs.first }
  let(:from_graphs) do
    [
      graphs[0],
      graphs[1],
    ]
  end
  let(:to_complex) do
    {
      "path" => "app name/host name/complex graph test",
      "description"  => "complex graph test",
      "sort"         => 10
    }
  end

  include_context "stub_post_graph" if ENV['MOCK'] == 'on'
  include_context "stub_delete_graph" if ENV['MOCK'] == 'on'
  before(:all) {
    mgclient.delete_graph("app name/host name/<1sec count") rescue nil
    mgclient.delete_graph("app name/host name/<2sec count") rescue nil
    mgclient.post_graph("app name/host name/<1sec count", { 'number' => 0 }) rescue nil
    mgclient.post_graph("app name/host name/<2sec count", { 'number' => 0 }) rescue nil
  }
  after(:all) {
    mgclient.delete_graph("app name/host name/<1sec count") rescue nil
    mgclient.delete_graph("app name/host name/<2sec count") rescue nil
  }
end
