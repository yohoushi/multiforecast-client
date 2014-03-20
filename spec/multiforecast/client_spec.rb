require 'spec_helper'

describe MultiForecast::Client do
  include_context "setup_graph"
  id_keys      = %w[base_uri path id service_name section_name graph_name]
  graph_keys   = %w[number llimit mode stype adjustval gmode color created_at ulimit description
                   sulimit unit sort updated_at adjust type sllimit meta md5]
  complex_keys = %w[number complex created_at service_name section_name id graph_name data sumup
                   description sort updated_at]

  context "#initialize" do
    context "typical" do
      subject { MultiForecast::Client.new('mapping' => {'app1/' => 'http://localhost:5125'}) }
      it { subject.instance_variable_get(:@mapping).keys.first.should == 'app1/' }
    end

    context "leading / of mapping path should be stripped" do
      subject { MultiForecast::Client.new('mapping' => {'/app1/' => 'http://localhost:5125'}) }
      it { subject.instance_variable_get(:@mapping).keys.first.should == 'app1/' }
    end
  end

  context "options" do
    context "debug_dev" do
      context 'default' do
        subject { MultiForecast::Client.new('mapping' => {'app1/' => 'http://localhost:5125'}) }
        it { expect(subject.debug_dev).to be_nil }
      end

      context 'STDOUT' do
        subject { MultiForecast::Client.new('mapping' => {'app1/' => 'http://localhost:5125'}, 'debug_dev' => STDOUT) }
        it { expect(subject.debug_dev).to eql(STDOUT) }
      end
    end

    context "short_metrics" do
      context 'default' do
        subject { MultiForecast::Client.new('mapping' => {'app1/' => 'http://localhost:5125'}) }
        it { expect(subject.short_metrics).to eql(true) }
      end
      context 'false' do
        subject { MultiForecast::Client.new('mapping' => {'app1/' => 'http://localhost:5125'}, 'short_metrics' => false) }
        it { expect(subject.short_metrics).to eql(false) }
      end
      context 'true' do
        subject { MultiForecast::Client.new('mapping' => {'app1/' => 'http://localhost:5125'}, 'short_metrics' => true) }
        it { expect(subject.short_metrics).to eql(true) }
      end
    end
  end

  context "#list_graph" do
    include_context "stub_list_graph" if ENV['MOCK'] == 'on'
    subject { multiforecast.list_graph }
    its(:size) { should > 0 }
    id_keys.each {|key| its(:first) { should have_key(key) } }
  end

  context "#list_graph(regexp)" do
    include_context "stub_list_graph" if ENV['MOCK'] == 'on'
    let(:graph) { multiforecast.list_graph.first }
    subject { multiforecast.list_graph('', Regexp.new(graph['graph_name'])) }
    its(:size) { should > 0 }
    id_keys.each {|key| its(:first) { should have_key(key) } }
  end

  context "#get_graph" do
    include_context "stub_get_graph" if ENV['MOCK'] == 'on'
    subject { multiforecast.get_graph(graph["path"]) }
    id_keys.each {|key| it { subject[key].should == graph[key] } }
    graph_keys.each {|key| it { subject.should have_key(key) } }
  end

  context "#post_graph" do
    include_context "stub_post_graph" if ENV['MOCK'] == 'on'
    include_context "stub_get_graph" if ENV['MOCK'] == 'on'
    params = {
      'number' => 0,
    }
    subject { multiforecast.post_graph(graph["path"], params) }
    it { subject["error"].should == 0 }
    params.keys.each {|key| it { subject["data"][key].should == params[key] } }
  end

  context "#delete_graph" do
    include_context "stub_post_graph" if ENV['MOCK'] == 'on'
    include_context "stub_delete_graph" if ENV['MOCK'] == 'on'
    let(:graph) { { 'path' => "app name/host name/delete:test" } }
    before  { multiforecast.post_graph(graph['path'], { 'number' => 0 }) }
    subject { multiforecast.delete_graph(graph['path']) }
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
      @before = multiforecast.get_graph(graph["path"])
      @response = multiforecast.edit_graph(graph["path"], params)
      @after = multiforecast.get_graph(graph["path"])
    end
    it { @response["error"].should == 0 }
    # @todo: how to stub @after?
    unless ENV['MOCK'] == 'on'
      (id_keys + graph_keys - params.keys - %w[meta md5]).each {|key| it { @after[key].should == @before[key] } }
      params.keys.each {|key| it { @after[key].should == params[key] } }
    end
  end

  describe "complex" do
    describe "before create" do
      include_context "let_complex"
      context "#create_complex" do
        include_context "stub_create_complex" if ENV['MOCK'] == 'on'
        include_context "stub_delete_complex" if ENV['MOCK'] == 'on'
        subject { multiforecast.create_complex(from_graphs, to_complex) }
        it { subject["error"].should == 0 }
        after { multiforecast.delete_complex(to_complex["path"]) }
      end
    end

    describe "after create" do
      include_context "setup_complex"
      context "#get_complex" do
        include_context "stub_get_complex" if ENV['MOCK'] == 'on'
        subject { multiforecast.get_complex(to_complex['path']) }
        complex_keys.each {|key| it { subject.should have_key(key) } }
      end
    end
  end

  describe "graph_uri_term" do
    let(:params) do
      {
        't' => 'h',
        'width' => 500,
        'height' => 300,
      }
    end
    context "#get_graph_uri" do
      subject { multiforecast.get_graph_uri(graph["path"], params) }
      it_should_behave_like 'graph_uri_params'
    end
    context "#get_complex_uri" do
      subject { multiforecast.get_complex_uri(graph["path"], params) }
      it_should_behave_like 'graph_uri_params'
    end
  end

  describe "graph_uri_empty" do
    let(:params) { {} }
    context "#get_graph_uri" do
      subject { multiforecast.get_graph_uri(graph["path"], params) }
      it_should_behave_like 'graph_uri_empty_params'
    end
    context "#get_complex_uri" do
      subject { multiforecast.get_complex_uri(graph["path"], params) }
      it_should_behave_like 'graph_uri_empty_params'
    end
  end

  describe "graph_uri_nil" do
    let(:params) { nil }
    context "#get_graph_uri" do
      subject { multiforecast.get_graph_uri(graph["path"], params) }
      it_should_behave_like 'graph_uri_empty_params'
    end
    context "#get_complex_uri" do
      subject { multiforecast.get_complex_uri(graph["path"], params) }
      it_should_behave_like 'graph_uri_empty_params'
    end
  end

  describe "graph_uri_fromto" do
    shared_context "short_period" do
      before { now = Time.now; Time.stub(:now) { now } }
      let(:params) do
        {
          'width' => 500,
          'height' => 300,
          'from' => Time.now - 60 * 60 * 24 * 2,
          'to'   => Time.now,
        }
      end
    end
    shared_context "long_period" do
      before { now = Time.now; Time.stub(:now) { now } }
      let(:params) do
        {
          'width' => 500,
          'height' => 300,
          'from' => (Time.now - 60 * 60 * 24 * 3).strftime("%F %T %z"),
          'to'   => Time.now.strftime("%F %T %z"),
        }
      end
    end

    context "#get_graph_uri" do
      subject { multiforecast_2.get_graph_uri(graph["path"], params) }
      context "short_metrics is true and short period" do
        let(:multiforecast_2) { multiforecast }
        include_context "short_period"
        it_should_behave_like 'graph_uri_short_metrics'
      end
      context "short_metrics is true and long period" do
        let(:multiforecast_2) { multiforecast }
        include_context "long_period"
        it_should_behave_like 'graph_uri_long_metrics'
      end
      context "short_metrics is false and short period" do
        let(:multiforecast_2) { multiforecast.tap{|s| s.short_metrics = false } }
        include_context "short_period"
        it_should_behave_like 'graph_uri_long_metrics'
      end
    end

    context "#get_complex_uri" do
      subject { multiforecast_2.get_complex_uri(graph["path"], params) }
      context "short_metrics is true and short period" do
        let(:multiforecast_2) { multiforecast }
        include_context "short_period"
        it_should_behave_like 'graph_uri_short_metrics'
      end
      context "short_metrics is true and long period" do
        let(:multiforecast_2) { multiforecast }
        include_context "long_period"
        it_should_behave_like 'graph_uri_long_metrics'
      end
      context "short_metrics is false and short period" do
        let(:multiforecast_2) { multiforecast.tap{|s| s.short_metrics = false } }
        include_context "short_period"
        it_should_behave_like 'graph_uri_long_metrics'
      end
    end
  end
end

