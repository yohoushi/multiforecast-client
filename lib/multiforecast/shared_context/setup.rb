# -*- encoding: utf-8 -*-
shared_context "let_graph" do
  include_context "stub_list_graph" if ENV['MOCK'] == 'on'
  let(:graphs) { mfclient.list_graph }
  let(:graph) { graphs.first }
end

shared_context "setup_graph" do
  include_context "let_graph"
  include_context "stub_post_graph" if ENV['MOCK'] == 'on'
  include_context "stub_delete_graph" if ENV['MOCK'] == 'on'
  before(:all) {
    mfclient.delete_graph("app name/host name/<1sec count") rescue nil
    mfclient.delete_graph("app name/host name/<2sec count") rescue nil
    mfclient.post_graph("app name/host name/<1sec count", { 'number' => 0 }) rescue nil
    mfclient.post_graph("app name/host name/<2sec count", { 'number' => 0 }) rescue nil
  }
  after(:all) {
    mfclient.delete_graph("app name/host name/<1sec count") rescue nil
    mfclient.delete_graph("app name/host name/<2sec count") rescue nil
  }
end

shared_context "let_complex" do
  include_context "setup_graph"
  let(:from_graphs) do
    [
      {
        "path" => graphs[0]["path"],
        "gmode" => "gauge",
        "stack" => false,
        "type" => "AREA",
      },
      {
        "path" => graphs[1]["path"],
        "gmode" => "gauge",
        "stack" => false,
        "type" => "AREA"
      },
    ]
  end
  let(:to_complex) do
    {
      "path" => "app name/host name/complex graph test",
      "description"  => "complex graph test",
      "sort"         => 10
    }
  end
end

shared_context "setup_complex" do
  include_context "let_complex"
  include_context "stub_create_complex" if ENV['MOCK'] == 'on'
  include_context "stub_delete_complex" if ENV['MOCK'] == 'on'
  before do
    mfclient.delete_complex(to_complex["path"]) rescue nil
    mfclient.create_complex(from_graphs, to_complex) rescue nil
  end
  after do
    mfclient.delete_complex(to_complex["path"]) rescue nil
  end
end
