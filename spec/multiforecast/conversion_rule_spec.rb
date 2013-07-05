require 'spec_helper'

describe MultiForecast::ConversionRule do
  include MultiForecast::ConversionRule

  describe "#section_name" do
    context "default" do
      let(:path) { 'a/b/c' }
      subject { section_name(path) }
      it { should == 'a%2Fb' }
    end

    context "whitespace" do
      let(:path) { 'a b/c' }
      subject { section_name(path) }
      it { should == 'a%20b' }
    end

    context "no section" do
      let(:path) { 'c' }
      subject { section_name(path) }
      it { should == '%2E' }
    end

    context "dot" do
      let(:path) { 'a.b/c' }
      subject { section_name(path) }
      it { should == 'a%2Eb' }
    end
  end

  describe "#graph_name" do
    context "default" do
      let(:path) { 'a/b/c' }
      subject { graph_name(path) }
      it { should == 'c' }
    end

    context "whitespace" do
      let(:path) { 'a/b c' }
      subject { graph_name(path) }
      it { should == 'b c' }
    end

    context "no section" do
      let(:path) { 'c' }
      subject { graph_name(path) }
      it { should == 'c' }
    end

    context "dot" do
      let(:path) { 'a/b.c' }
      subject { graph_name(path) }
      it { should == 'b.c' }
    end
  end

  describe "#path" do
    subject { path(service_name(path1), section_name(path1), graph_name(path1)) }

    context "default" do
      let(:path1) { 'a/b/c' }
      it { should == path1 }
    end

    context "whitespace section" do
      let(:path1) { 'a b/c' }
      it { should == path1 }
    end

    context "no section" do
      let(:path1) { 'c' }
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
  end
end

