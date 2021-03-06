require 'spec_helper'

describe Typhoeus::Request::Callbacks do
  let(:request) { Typhoeus::Request.new("fubar") }

  after do
    request.on_complete.clear
    Typhoeus.on_complete.clear
  end

  [:on_complete, :on_success, :on_failure].each do |callback|
    describe "##{callback}" do
      it "responds" do
        expect(request).to respond_to(callback)
      end

      context "when no block given" do
        it "returns @#{callback}" do
          expect(request.method(callback).call).to eq([])
        end
      end

      context "when block given" do
        it "stores" do
          request.method(callback).call { p 1 }
          expect(request.instance_variable_get("@#{callback}")).to have(1).items
        end
      end

      context "when multiple blocks given" do
        it "stores" do
          request.method(callback).call { p 1 }
          request.method(callback).call { p 2 }
          expect(request.instance_variable_get("@#{callback}")).to have(2).items
        end
      end
    end
  end

  describe "#execute_callbacks" do
    [:on_complete, :on_success, :on_failure].each do |callback|
      context "when #{callback}" do
        context "when local callback" do
          before do
            request.response = Typhoeus::Response.new(mock: true, response_code: 200)
            request.method(callback).call {|r| expect(r).to be_a(Typhoeus::Response) }
          end

          it "executes blocks and passes response" do
            request.execute_callbacks
          end

          it "sets handled_response" do
            request.method(callback).call.clear
            request.method(callback).call { 1 }
            request.execute_callbacks
            expect(request.response.handled_response).to be(1)
          end
        end

        context "when global callback" do
          before do
            request.response = Typhoeus::Response.new
            Typhoeus.method(callback).call {|r| expect(r).to be_a(Typhoeus::Response) }
          end

          it "executes blocks and passes response" do
            request.execute_callbacks
          end
        end

        context "when global and local callbacks" do
          before do
            request.response = Typhoeus::Response.new
            Typhoeus.method(callback).call {|r| r.instance_variable_set(:@fu, 1) }
            request.method(callback).call {|r| expect(r.instance_variable_get(:@fu)).to eq(1) }
          end

          it "runs global first" do
            request.execute_callbacks
          end
        end
      end
    end

    context "when local on_complete and gobal on_success" do
      it "runs all global callbacks first" do
        pending
      end
    end
  end
end
