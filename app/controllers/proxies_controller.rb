class ProxiesController < ApplicationController
  def echo
    render json: { message: "10-4 good buddy" }, status: :ok
  end
end
