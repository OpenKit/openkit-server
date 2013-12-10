module V09
class AppsController < ApplicationController

  def purge_test_data
    test_app = App.find_by(app_key: "end_to_end_test")
    if test_app
      test_app.leaderboards.destroy_all
      test_app.achievements.destroy_all
      render json: %|{"ok":true}|
    else
      render json: %|{"ok":false}|
    end
  end
end
end