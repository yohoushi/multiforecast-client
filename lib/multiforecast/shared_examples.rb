shared_examples_for 'graph_uri_long_metrics' do
  it { subject.should match(/(\?|&)t=c(&|$)/) }
end

shared_examples_for 'graph_uri_short_metrics' do
  it { subject.should match(/(\?|&)t=sc(&|$)/) }
end

shared_examples_for 'graph_uri_params' do
  it { subject.should match(/(\?|&)t=#{params['t']}(&|$)/) }
  it { subject.should match(/(\?|&)from=#{Regexp.escape(URI.escape(params['from']))}(&|$)/) }
  it { subject.should match(/(\?|&)to=#{Regexp.escape(URI.escape(params['to']))}(&|$)/) }
  it { subject.should match(/(\?|&)width=#{params['width']}(&|$)/) }
  it { subject.should match(/(\?|&)height=#{params['height']}(&|$)/) }
end
