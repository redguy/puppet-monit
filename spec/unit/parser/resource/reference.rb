#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/../../../spec_helper'

describe Puppet::Parser::Resource::Reference do
    before do
        @type = Puppet::Parser::Resource::Reference
    end

    it "should require a type" do
        proc { @type.new(:title => "yay") }.should raise_error(Puppet::DevError)
    end

    it "should require a title" do
        proc { @type.new(:type => "file") }.should raise_error(Puppet::DevError)
    end

    it "should know when it models a builtin type" do
        ref = @type.new(:type => "file", :title => "/tmp/yay")
        ref.builtin?.should be_true
        ref.builtintype.should equal(Puppet::Type.type(:file))
    end

    it "should return a relationship-style resource reference when asked" do
        ref = @type.new(:type => "file", :title => "/tmp/yay")
        ref.to_ref.should == ["file", "/tmp/yay"]
    end

    it "should return a resource reference string when asked" do
        ref = @type.new(:type => "file", :title => "/tmp/yay")
        ref.to_s.should == "File[/tmp/yay]"
    end
end

describe Puppet::Parser::Resource::Reference, " when modeling defined types" do
    before do
        @type = Puppet::Parser::Resource::Reference

        @parser = Puppet::Parser::Parser.new :Code => ""
        @definition = @parser.newdefine "mydefine"
        @class = @parser.newclass "myclass"
        @nodedef = @parser.newnode("mynode")[0]
        @node = Puppet::Node.new("yaynode")

        @compile = Puppet::Parser::Compile.new(@node, @parser)
    end

    it "should be able to model definitions" do
        ref = @type.new(:type => "mydefine", :title => "/tmp/yay", :scope => @compile.topscope)
        ref.builtin?.should be_false
        ref.definedtype.should equal(@definition)
    end

    it "should be able to model classes" do
        ref = @type.new(:type => "class", :title => "myclass", :scope => @compile.topscope)
        ref.builtin?.should be_false
        ref.definedtype.should equal(@class)
    end

    it "should be able to model nodes" do
        ref = @type.new(:type => "node", :title => "mynode", :scope => @compile.topscope)
        ref.builtin?.should be_false
        ref.definedtype.object_id.should  == @nodedef.object_id
    end
end
