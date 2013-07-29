shared_examples_for 'graph_uri_long_metrics' do
  it { subject.should match(/(\?|&)t=c(&|$)/) }
  it_should_behave_like 'graph_uri_params_fromto'
  it_should_behave_like 'graph_uri_params_widthheight'
end

shared_examples_for 'graph_uri_short_metrics' do
  it { subject.should match(/(\?|&)t=sc(&|$)/) }
  it_should_behave_like 'graph_uri_params_fromto'
  it_should_behave_like 'graph_uri_params_widthheight'
end

shared_examples_for 'graph_uri_params' do
  it_should_behave_like 'graph_uri_params_term'
  it_should_behave_like 'graph_uri_params_widthheight'
end

shared_examples_for 'graph_uri_params_term' do
  it { subject.should match(/(\?|&)t=#{params['t']}(&|$)/) }
end

shared_examples_for 'graph_uri_params_widthheight' do
  it { subject.should match(/(\?|&)width=#{params['width'].to_s}(&|$)/) }
  it { subject.should match(/(\?|&)height=#{params['height'].to_s}(&|$)/) }
end

shared_examples_for 'graph_uri_params_fromto' do
  it { subject.should match(/(\?|&)from=#{Regexp.escape(URI.escape(params['from'].to_s))}(&|$)/) }
  it { subject.should match(/(\?|&)to=#{Regexp.escape(URI.escape(params['to'].to_s))}(&|$)/) }
end

shared_examples_for 'graph_uri_empty_params' do
  it { subject.should_not match(/(\?|&)/) }
end
