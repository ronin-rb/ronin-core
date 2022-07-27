require 'spec_helper'
require 'ronin/core/params/mixin'

describe Ronin::Core::Params::Mixin do
  describe "Boolean" do
    it "must equal Ronin::Core::Params::Types::Boolean" do
      expect(described_class::Boolean).to be(Ronin::Core::Params::Types::Boolean)
    end
  end

  describe "Enum" do
    it "must equal Ronin::Core::Params::Types::Enum" do
      expect(described_class::Enum).to be(Ronin::Core::Params::Types::Enum)
    end
  end

  describe ".params" do
    subject { test_class }

    context "and when params is not set in the class" do
      module TestParamsMixin
        class WithEmptyParams
          include Ronin::Core::Params::Mixin
        end
      end

      let(:test_class) { TestParamsMixin::WithEmptyParams }

      it "must default to {}" do
        expect(subject.params).to eq({})
      end
    end

    context "and when param is called in the class" do
      module TestParamsMixin
        class WithParams
          include Ronin::Core::Params::Mixin

          param :foo, desc: 'Foo param'
        end
      end

      let(:test_class) { TestParamsMixin::WithParams }

      it "must return the set params" do
        expect(subject.params).to_not be_empty
        expect(subject.params[:foo]).to be_kind_of(Ronin::Core::Params::Param)
        expect(subject.params[:foo].name).to eq(:foo)
      end
    end

    context "but when params are set in the superclass" do
      module TestParamsMixin
        class BaseClassWithParams
          include Ronin::Core::Params::Mixin

          param :foo, desc: 'Foo param'
        end

        class OnlyInheritsParams < BaseClassWithParams
        end
      end

      let(:test_class) { TestParamsMixin::OnlyInheritsParams }

      it "must return the params set in the superclass" do
        expect(subject.params).to_not be_empty
        expect(subject.params[:foo]).to be_kind_of(Ronin::Core::Params::Param)
        expect(subject.params[:foo].name).to eq(:foo)
      end

      context "and when additional params are defined in a sub-class" do
        module TestParamsMixin
          class AdditionalParamsDefinedInSubClass < BaseClassWithParams
            param :bar, desc: 'Additional param'
          end
        end

        let(:test_class) { TestParamsMixin::AdditionalParamsDefinedInSubClass }
        let(:superclass) { TestParamsMixin::BaseClassWithParams }

        it "must return both the params defined in the superclass and sub-class" do
          expect(subject.params).to_not be_empty
          expect(subject.params[:foo]).to be_kind_of(Ronin::Core::Params::Param)
          expect(subject.params[:foo].name).to eq(:foo)

          expect(subject.params[:bar]).to be_kind_of(Ronin::Core::Params::Param)
          expect(subject.params[:bar].name).to eq(:bar)
        end

        it "must not modify the .params in the superclass" do
          expect(superclass.params).to_not have_key(:bar)
        end
      end
    end
  end

  describe ".param" do
    context "when only given required arguments" do
      module TestParamsMixin
        class DefaultParam
          include Ronin::Core::Params::Mixin

          param :foo, desc: 'Foo param'
        end
      end

      subject { TestParamsMixin::DefaultParam }

      it "must define a param with the given name and description" do
        expect(subject.params[:foo]).to be_kind_of(Ronin::Core::Params::Param)
        expect(subject.params[:foo].name).to be(:foo)
        expect(subject.params[:foo].desc).to eq('Foo param')
      end
    end

    context "when also given the type argument" do
      context "and it's a Ruby core class" do
        module TestParamsMixin
          class ParamWithCoreClassType
            include Ronin::Core::Params::Mixin

            param :foo, Integer, desc: 'Foo param'
          end
        end

        subject { TestParamsMixin::ParamWithCoreClassType }

        it "must map the core class to a Ronin::Core::Params::Types:: class" do
          expect(subject.params[:foo].type).to be_kind_of(Ronin::Core::Params::Types::Integer)
        end
      end

      context "and it's a Ronin::Core::Params::Types:: instance" do
        module TestParamsMixin
          class ParamWithTypeInstance
            include Ronin::Core::Params::Mixin

            param :foo, Enum[:bar, :baz], desc: 'Foo param'
          end
        end

        subject { TestParamsMixin::ParamWithTypeInstance }

        it "must define a param with the given Ronin::Core::Params::Types:: instance" do
          expect(subject.params[:foo].type).to be_kind_of(Ronin::Core::Params::Types::Enum)
        end
      end

      context "and when given additional keyword arguments" do
        module TestParamsMixin
          class ParamWithTypeAndAdditionalKwargs
            include Ronin::Core::Params::Mixin

            param :foo, Integer, desc: 'Foo param', min: 1, max: 10
          end
        end

        subject { TestParamsMixin::ParamWithTypeAndAdditionalKwargs }

        it "must pass them to the Ronin::Core::Params::Types:: class'es #initialize method" do
          expect(subject.params[:foo].type.min).to eq(1)
          expect(subject.params[:foo].type.max).to eq(10)
        end
      end
    end

    context "when also given the required: keyword argument" do
      module TestParamsMixin
        class ParamWithRequired
          include Ronin::Core::Params::Mixin

          param :foo, required: true, desc: 'Foo param'
        end
      end

      subject { TestParamsMixin::ParamWithRequired }

      it "must define a param with #required set to true" do
        expect(subject.params[:foo]).to be_kind_of(Ronin::Core::Params::Param)
        expect(subject.params[:foo].required).to be(true)
      end
    end

    context "when also given the default: keyword argument" do
      module TestParamsMixin
        class ParamWithDefault
          include Ronin::Core::Params::Mixin

          param :foo, default: 42, desc: 'Foo param'
        end
      end

      subject { TestParamsMixin::ParamWithDefault }

      it "must define a param with #default set to true" do
        expect(subject.params[:foo]).to be_kind_of(Ronin::Core::Params::Param)
        expect(subject.params[:foo].default).to eq(42)
      end
    end
  end

  module TestParamsMixin
    class TestParams
      include Ronin::Core::Params::Mixin

      param :foo, Integer, desc: 'Foo param'
      param :bar, Integer, desc: 'Bar param'
    end

    class TestParamsWithDefault
      include Ronin::Core::Params::Mixin

      param :foo, Integer, desc: 'Foo param'
      param :bar, Integer, default: 42, desc: 'Bar param'
    end

    class TestParamsWithRequired
      include Ronin::Core::Params::Mixin

      param :foo, Integer, required: true, desc: 'Foo param'
      param :bar, Integer, desc: 'Bar param'
    end
  end

  let(:test_class) { TestParamsMixin::TestParams }
  subject { test_class.new }

  describe "#initialize" do
    context "when not given the params: keyword argument" do
      it "must default #params to {}" do
        expect(subject.params).to eq({})
      end

      context "when a param is defined with a default: value" do
        let(:test_class) { TestParamsMixin::TestParamsWithDefault }

        it "must initialize the param in #params with the param's default value" do
          expect(subject.params[:bar]).to eq(test_class.params[:bar].default_value)
        end
      end
    end

    context "when given the params: keyword argument" do
      let(:params) do
        {foo: 1, bar: 2}
      end

      subject { test_class.new(params: params) }

      it "must initialize the params using the parmms: Hash" do
        expect(subject.params).to eq(params)
      end

      context "but when one of the required param values is missing" do
        let(:test_class) { TestParamsMixin::TestParamsWithRequired }

        it do
          expect {
            test_class.new(params: {})
          }.to raise_error(Ronin::Core::Params::RequiredParam,"param 'foo' requires a value")
        end
      end

      context "but params: values do not match the param's types" do
        let(:params) do
          {foo: '1', bar: '2'}
        end

        it "must coerce the values using the param's types" do
          expect(subject.params[:foo]).to eq(params[:foo].to_i)
          expect(subject.params[:bar]).to eq(params[:bar].to_i)
        end

        context "but the values cannot be coerced" do
          let(:invalid_param) { :bar }
          let(:invalid_value) { "XYZ" }
          let(:params) do
            {foo: 1, invalid_param => invalid_value}
          end

          it do
            expect {
              test_class.new(params: params)
            }.to raise_error(Ronin::Core::Params::ValidationError,"invalid param value for param '#{invalid_param}': value contains non-numeric characters (#{invalid_value.inspect})")
          end
        end
      end

      context "but the params: value contains an unknown param" do
        let(:unknown_param) { :xxx }
        let(:params) do
          {:foo => 1, unknown_param => 2}
        end

        it do
          expect {
            test_class.new(params: params)
          }.to raise_error(Ronin::Core::Params::UnknownParam,"unknown param: #{unknown_param.inspect}")
        end
      end
    end
  end

  describe "#params=" do
    let(:params) do
      {foo: 1, bar: 2}
    end

    it "must populate #params using the parmms Hash" do
      subject.params = params

      expect(subject.params).to eq(params)
    end

    context "but #params has been previously set" do
      let(:params) do
        {foo: 1}
      end

      before do
        subject.params = {foo: 111, bar: 222}
        subject.params = params
      end

      it "must clear #params before re-populating it" do
        expect(subject.params).to eq(params)
      end
    end

    context "when a param is defined with a default: value" do
      let(:test_class) { TestParamsMixin::TestParamsWithDefault }

      let(:params) do
        {foo: 1}
      end
      before { subject.params = params }

      it "must initialize the param in #params with the param's default value" do
        expect(subject.params[:bar]).to eq(test_class.params[:bar].default_value)
      end

      it "must set the other params" do
        expect(subject.params[:foo]).to eq(params[:foo])
      end
    end

    context "but the params values do not match the param's types" do
      let(:params) do
        {foo: '1', bar: '2'}
      end

      it "must coerce the values using the param's types" do
        subject.params = params

        expect(subject.params[:foo]).to eq(params[:foo].to_i)
        expect(subject.params[:bar]).to eq(params[:bar].to_i)
      end

      context "but the values cannot be coerced" do
        let(:invalid_param) { :bar }
        let(:invalid_value) { "XYZ" }
        let(:params) do
          {foo: 1, invalid_param => invalid_value}
        end

        it do
          expect {
            subject.params = params
          }.to raise_error(Ronin::Core::Params::ValidationError,"invalid param value for param '#{invalid_param}': value contains non-numeric characters (#{invalid_value.inspect})")
        end
      end
    end

    context "when a param is defined with required: true" do
      let(:test_class) { TestParamsMixin::TestParamsWithRequired }

      let(:params) do
        {bar: 1}
      end

      context "and the value is not given in the params Hash" do
        it do
          expect {
            subject.params = params
          }.to raise_error(Ronin::Core::Params::RequiredParam,"param 'foo' requires a value")
        end
      end
    end

    context "but the params value contains an unknown param" do
      let(:unknown_param) { :xxx }
      let(:params) do
        {:foo => 1, unknown_param => 2}
      end

      it do
        expect {
          subject.params = params
        }.to raise_error(Ronin::Core::Params::UnknownParam,"unknown param: #{unknown_param.inspect}")
      end
    end
  end

  describe "#set_param" do
    let(:name)  { :foo }
    let(:value) { 42   }

    it "must set the param with the given name and value" do
      subject.set_param(name,value)

      expect(subject.params[name]).to eq(value)
    end

    context "when the param name is not unknown" do
      let(:name) { :xxx }

      it do
        expect {
          subject.set_param(name,value)
        }.to raise_error(Ronin::Core::Params::UnknownParam,"unknown param: #{name.inspect}")
      end
    end

    context "but the param value does not match the param's type" do
      let(:valie) { '42' }

      it "must coerce the value using the param's type" do
        subject.set_param(name,value)

        expect(subject.params[name]).to eq(value.to_i)
      end

      context "but the values cannot be coerced" do
        let(:value) { "XYZ" }

        it do
          expect {
            subject.set_param(name,value)
          }.to raise_error(Ronin::Core::Params::ValidationError,"invalid param value for param '#{name}': value contains non-numeric characters (#{value.inspect})")
        end
      end
    end
  end

  describe "#validate_params" do
    context "when there are required params defined" do
      let(:test_class)     { TestParamsMixin::ParamWithRequired }
      let(:required_param) { :foo }

      context "and one of them is not set in #params" do
        it do
          expect {
            subject.validate_params
          }.to raise_error(Ronin::Core::Params::ValidationError,"param '#{required_param}' requires a value")
        end
      end

      context "and one of them is set to nil in #params" do
        before { subject.params[required_param] = nil }

        it do
          expect {
            subject.validate_params
          }.to raise_error(Ronin::Core::Params::ValidationError,"param '#{required_param}' requires a value")
        end
      end

      context "and it has a non-nil value" do
        before { subject.params[required_param] = 42 }

        it "must return true" do
          expect(subject.validate_params).to be(true)
        end
      end
    end

    context "when there are no required params defined" do
      it "must return true" do
        expect(subject.validate_params).to be(true)
      end
    end
  end
end
