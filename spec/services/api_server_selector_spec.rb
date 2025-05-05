require 'rails_helper'

RSpec.describe ApiServerSelector, type: :service do
  let(:servers) { [ "http://localhost:3000", "http://localhost:8080", "http://localhost:8000" ] }

  describe ".servers" do
    it { expect(ApiServerSelector.servers).to eq(servers) }
  end

  describe ".healthy_servers" do
    context "when healthy? always return true" do
      before { allow(ApiServerSelector).to receive(:healthy?).and_return(true) }
      it { expect(ApiServerSelector.healthy_servers).to eq(servers) }
    end

    context "when healthy? always return false" do
      before { allow(ApiServerSelector).to receive(:healthy?).and_return(false) }
      it { expect(ApiServerSelector.healthy_servers).to eq([]) }
    end

    context "when healthy? sometimes return true" do
      before { allow(ApiServerSelector).to receive(:healthy?).and_return(true, false, true) }
      it { expect(ApiServerSelector.healthy_servers).to eq([ "http://localhost:3000", "http://localhost:8000" ]) }
    end
  end

  describe ".next" do
    context "when all servers are healthy" do
      before { allow(ApiServerSelector).to receive(:healthy_servers).and_return(servers) }

      context "and when index is at 0" do
        before { ApiServerSelector.class_variable_set(:@@index, 0) }
        it { expect { ApiServerSelector.next }.to change { ApiServerSelector.class_variable_get(:@@index) }.from(0).to(1) }
        it { expect(ApiServerSelector.next).to eq("http://localhost:3000") }
      end

      context "and when index is at 1" do
        before { ApiServerSelector.class_variable_set(:@@index, 1) }
        it { expect { ApiServerSelector.next }.to change { ApiServerSelector.class_variable_get(:@@index) }.from(1).to(2) }
        it { expect(ApiServerSelector.next).to eq("http://localhost:8080") }
      end

      context "and when index is at 2" do
        before { ApiServerSelector.class_variable_set(:@@index, 2) }
        it { expect { ApiServerSelector.next }.to change { ApiServerSelector.class_variable_get(:@@index) }.from(2).to(0) }
        it { expect(ApiServerSelector.next).to eq("http://localhost:8000") }
      end
    end

    context "when there are no healthy servers" do
      before { allow(ApiServerSelector).to receive(:healthy_servers).and_return([]) }
      it { expect { ApiServerSelector.next }.to raise_error(StandardError, "No healthy API servers available") }
    end

    context "when there are some healthy servers" do
      before do
        allow(ApiServerSelector).to receive(:healthy_servers).and_return([ "http://localhost:3000", "http://localhost:8000" ])
      end

      context "and when index is at 0" do
        before { ApiServerSelector.class_variable_set(:@@index, 0) }
        it { expect { ApiServerSelector.next }.to change { ApiServerSelector.class_variable_get(:@@index) }.from(0).to(1) }
        it { expect(ApiServerSelector.next).to eq("http://localhost:3000") }
      end

      context "and when index is at 1" do
        before { ApiServerSelector.class_variable_set(:@@index, 1) }
        it { expect { ApiServerSelector.next }.to change { ApiServerSelector.class_variable_get(:@@index) }.from(1).to(0) }
        it { expect(ApiServerSelector.next).to eq("http://localhost:8000") }
      end
    end
  end
end
