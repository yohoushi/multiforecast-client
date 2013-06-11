shared_examples_for 'graph_uri_unit_is_c' do
  it { subject.should match(/(\?|&)t=c(&|$)/) }
end

shared_examples_for 'graph_uri_unit_is_sc' do
  it { subject.should match(/(\?|&)t=sc(&|$)/) }
end

shared_examples_for 'graph_uri_custom_params' do
  it { subject.should match(/(\?|&)from=#{Regexp.escape(URI.escape(from.to_s))}(&|$)/) }
  it { subject.should match(/(\?|&)to=#{Regexp.escape(URI.escape(to.to_s))}(&|$)/) }
  it { subject.should match(/(\?|&)width=#{width}(&|$)/) }
  it { subject.should match(/(\?|&)height=#{height}(&|$)/) }
end
