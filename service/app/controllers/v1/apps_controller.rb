module V1
class AppsController < ApplicationController

  def purge_test_data
    test_app = App.find_by(app_key: "end_to_end_test")
    if test_app
      test_app.leaderboards.destroy_all
      test_app.achievements.destroy_all
      test_app.developer.users.destroy_all
      head :ok
    else
      render json: {message: "no test app on this endpoint."}
    end
  end
end
end