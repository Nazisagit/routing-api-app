class ProxiesController < ApplicationController
  def echo
    # choose the next available server
    target = ApiServerSelector.next
    uri = URI(target)
    uri.path = "/echo"

    # prepare post request
    req = ::Net::HTTP::Post.new(uri)
    req.body = request.body.string
    req.content_type = "application/json"

    res = ::Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
      http.request(req)
    end
    render json: res.body, status: res.code.to_i
  end
end
