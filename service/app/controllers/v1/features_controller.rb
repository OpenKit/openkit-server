module V1
  class FeaturesController < ApplicationController
    def index
      render :json => authorized_app.features
    end
  end
end
