require 'rails_helper'

RSpec.describe "Proxies", type: :request do
  describe "POST /echo" do
    it do
      post echo_proxy_path
      expect(response.status).to eq(200)
    end
  end
end
