module V1
class AchievementsController < ApplicationController

  def index
    @achievements = authorized_app.achievements
    user_id = params[:user_id] && params[:user_id].to_i
    render json: @achievements.map {|x| x.api_fields(request_base_uri, in_sandbox?, user_id)}
  end

  def create
    @achievement = authorized_app.achievements.new(params[:achievement])
    if @achievement.save
      render json: @achievement.api_fields(request_base_uri, in_sandbox?), status: :created
    else
      render json: @achievement.errors, status: :unprocessable_entity
    end
  end
end
end