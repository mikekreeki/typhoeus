require 'spec_helper'

describe Typhoeus::Request::Stubbable do
  let(:url) { "localhost:3001" }
  let(:request) { Typhoeus::Request.new(url) }
  let(:response) { Typhoeus::Response.new }

  before { Typhoeus.stub(url).and_return(response) }
  after { Typhoeus::Expectation.clear }

  describe "#queue" do
    it "checks expactations" do
      request.run
    end

    context "when expectation found" do
      it "finishes request" do
        request.should_receive(:finish)
        request.run
      end

      it "sets mock on response" do
        request.run
        expect(request.response.mock).to be(true)
      end
    end
  end
end
