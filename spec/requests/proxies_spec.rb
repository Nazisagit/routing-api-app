require 'rails_helper'

RSpec.describe "Proxies", type: :request do
  describe "POST /echo" do
    context "when a valid JSON body is provided" do
      let(:valid_params) do
        '{
          "game": "Mobile Legends",
          "gamerID": "GYUTDTE",
          "points": 20
        }'
      end

      it "returns 200 and the JSON body that was provided" do
        post echo_proxy_path, params: valid_params, headers: { "CONTENT_TYPE" => "application/json" }

        expect(response.status).to eq(200)
        expect(response.body).to eq(valid_params)
      end
    end

    context "when an invalid JSON body is provided" do
      let(:invalid_params) do
        '{ "game": "Mobile Legends", "gamerID": "GYUTDTE", "points": 20'
      end

      it "returns 400 and an error message" do
        post echo_proxy_path, params: invalid_params, headers: { "CONTENT_TYPE" => "application/json" }

        expect(response.status).to eq(400)
        expect(JSON.parse(response.body)["error"]).to eq("Invalid JSON format")
      end
    end

    context "when an HTML body is provided" do
      let(:html_body) do
        "<html><body><h1>Hello</h1></body></html>"
      end

      it "returns 400 and an error message" do
        post echo_proxy_path, params: html_body, headers: { "CONTENT_TYPE" => "text/html" }

        expect(response.status).to eq(400)
        expect(JSON.parse(response.body)["error"]).to eq("Invalid JSON format")
      end
    end
  end
end
