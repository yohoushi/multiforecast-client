require 'spec_helper'

describe Mg::Client do
  include Mg::ConversionRule
  include_context "setup_graph"
  id_keys      = %w[gfuri path id service_name section_name graph_name]
  graph_keys   = %w[number llimit mode stype adjustval gmode color created_at ulimit description
                   sulimit unit sort updated_at adjust type sllimit meta md5]
  complex_keys = %w[number complex created_at service_name section_name id graph_name data sumup
                   description sort updated_at]

  context "#list_graph" do
    include_context "stub_list_graph" if ENV['MOCK'] == 'on'
    subject { graphs }
    its(:size) { should > 0 }
    id_keys.each {|key| its(:first) { should have_key(key) } }
  end

  context "#get_graph" do
    include_context "stub_get_graph" if ENV['MOCK'] == 'on'
    subject { mgclient.get_graph(graph["path"]) }
    id_keys.each {|key| it { subject[key].should == graph[key] } }
    graph_keys.each {|key| it { subject.should have_key(key) } }
  end

  context "#post_graph" do
    include_context "stub_post_graph" if ENV['MOCK'] == 'on'
    include_context "stub_get_graph" if ENV['MOCK'] == 'on'
    params = {
      'number' => 0,
    }
    subject { mgclient.post_graph(graph["path"], params) }
    it { subject["error"].should == 0 }
    params.keys.each {|key| it { subject["data"][key].should == params[key] } }
  end

  context "#delete_graph" do
    include_context "stub_post_graph" if ENV['MOCK'] == 'on'
    include_context "stub_delete_graph" if ENV['MOCK'] == 'on'
    let(:graph) { { 'path' => "app name/host name/delete:test" } }
    before  { mgclient.post_graph(graph['path'], { 'number' => 0 }) }
    subject { mgclient.delete_graph(graph['path']) }
    it { subject["error"].should == 0 }
  end

  context "#edit_graph" do
    include_context "stub_edit_graph" if ENV['MOCK'] == 'on'
    params = {
      'sort' => 19,
      'adjust' => '/',
      'adjustval' => '1000000',
      'unit' => 'sec',
      'color'  => "#000000"
    }
    before do
      @before = mgclient.get_graph(graph["path"])
      @response = mgclient.edit_graph(graph["path"], params)
      @after = mgclient.get_graph(graph["path"])
    end
    it { @response["error"].should == 0 }
    # @todo: how to stub @after?
    unless ENV['MOCK'] == 'on'
      (id_keys + graph_keys - params.keys - %w[meta md5]).each {|key| it { @after[key].should == @before[key] } }
      params.keys.each {|key| it { @after[key].should == params[key] } }
    end
  end

  describe "complex" do
    context "#create_complex" do
      include_context "stub_create_complex" if ENV['MOCK'] == 'on'
      include_context "stub_delete_complex" if ENV['MOCK'] == 'on'
      let(:from_graphs) { graphs }
      let(:to_complex) { { 'path' => 'cerate_complex_test' } }
      subject { mgclient.create_complex(from_graphs, to_complex) }
      it { subject["error"].should == 0 }
      after { mgclient.delete_complex(to_complex["path"]) }
    end

    context "#get_complex" do
      include_context "setup_complex"
      include_context "stub_get_complex" if ENV['MOCK'] == 'on'
      subject { mgclient.get_complex(to_complex['path']) }
      complex_keys.each {|key| it { subject.should have_key(key) } }
    end
  end
end

