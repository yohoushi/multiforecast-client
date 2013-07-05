require 'spec_helper'

describe MultiForecast::ConversionRule do
  include MultiForecast::ConversionRule

  describe "#service_name" do
    context "4 or more levels" do
      let(:path) { 'a/b/c/d' }
      subject { service_name(path) }
      it { should == 'mfclient' }
    end

    context "2 levels" do
      let(:path) { 'a/b' }
      subject { service_name(path) }
      it { should == 'mfclient' }
    end

    context "1 level" do
      let(:path) { 'a' }
      subject { service_name(path) }
      it { should == 'mfclient' }
    end

    context "3 levels (special)" do
      let(:path) { 'a/b/c' }
      subject { service_name(path) }
      it { should == 'a' }
    end
  end

  describe "#section_name" do
    context "4 or more levels" do
      let(:path) { 'a/b/c/d' }
      subject { section_name(path) }
      it { should == 'a%2Fb%2Fc' }
    end

    context "2 levels" do
      let(:path) { 'a/b' }
      subject { section_name(path) }
      it { should == 'a' }
    end

    context "1 level" do
      let(:path) { 'a' }
      subject { section_name(path) }
      it { should == '%2E' }
    end

    context "whitespace" do
      let(:path) { 'a b/c' }
      subject { section_name(path) }
      it { should == 'a%20b' }
    end

    context "dot" do
      let(:path) { 'a.b/c' }
      subject { section_name(path) }
      it { should == 'a%2Eb' }
    end

    context "3 levels (special)" do
      let(:path) { 'a/b/c' }
      subject { section_name(path) }
      it { should == 'b' }
    end
  end

  describe "#graph_name" do
    context "4 or more levels" do
      let(:path) { 'a/b/c/d' }
      subject { graph_name(path) }
      it { should == 'd' }
    end

    context "2 levels" do
      let(:path) { 'a/b' }
      subject { graph_name(path) }
      it { should == 'b' }
    end

    context "1 level" do
      let(:path) { 'a' }
      subject { graph_name(path) }
      it { should == 'a' }
    end

    context "whitespace" do
      let(:path) { 'a/b c' }
      subject { graph_name(path) }
      it { should == 'b c' }
    end

    context "dot" do
      let(:path) { 'a/b.c' }
      subject { graph_name(path) }
      it { should == 'b.c' }
    end

    context "3 levels (special)" do
      let(:path) { 'a/b/c' }
      subject { graph_name(path) }
      it { should == 'c' }
    end
  end

  describe "#path" do
    subject { path(service_name(path1), section_name(path1), graph_name(path1)) }

    context "4 or more levels" do
      let(:path1) { 'a/b/c/d' }
      it { should == path1 }
    end

    context "2 levels" do
      let(:path1) { 'a/b' }
      it { should == path1 }
    end

    context "1 level" do
      let(:path1) { 'c' }
      it { should == path1 }
    end

    context "whitespace section" do
      let(:path1) { 'a b/c' }
      it { should == path1 }
    end

    context "dot section" do
      let(:path1) { 'a.b/c' }
      it { should == path1 }
    end

    context "whitespace graph" do
      let(:path1) { 'a/b c' }
      it { should == path1 }
    end

    context "dot graph" do
      let(:path1) { 'a/b.c' }
      it { should == path1 }
    end

    context "3 levels (special)" do
      let(:path1) { 'a/b/c' }
      it { should == path1 }
    end
  end
end

