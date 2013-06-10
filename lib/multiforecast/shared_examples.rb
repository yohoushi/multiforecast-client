shared_examples_for 'custom_graph_uri_params' do
  it { subject.should match(/(\?|&)t=c(&|$)/) }
  it { subject.should match(/(\?|&)from=#{Regexp.escape(URI.escape(from.to_s))}(&|$)/) }
  it { subject.should match(/(\?|&)to=#{Regexp.escape(URI.escape(to.to_s))}(&|$)/) }
  it { subject.should match(/(\?|&)width=#{width}(&|$)/) }
  it { subject.should match(/(\?|&)height=#{height}(&|$)/) }
end
