class ChallengesController < ApplicationController
  before_filter :require_api_access, :except => [:info]
  before_filter :set_leaderboard, :except => [:info]

  # POST to /leaderboards/:leaderboard_id/challenges with params:
  # {
  #   sender_id:
  #   receiver_ids: [x, y, z]
  # }
  #
  # This method stuffs the sender_id, receiver_id, and leaderboard_id into push
  # queue to be handled later.  Push queues are keyed by developer_id:push_queue.
  def create
    sender_id      = params[:sender_id] && params[:sender_id].to_i
    receiver_ids   = params[:receiver_ids] && params[:receiver_ids].is_a?(Array) && params[:receiver_ids].map(&:to_i)

    err_message = ''
    if !authorized_app.developer.has_push_cert?
      err_message << "You have not uploaded a push certificate yet. "
    end

    if err_message.blank?
      challenge = Challenge.new(
          sender_id: sender_id,
          receiver_ids: receiver_ids,
          leaderboard_id: @leaderboard.id,
          developer: authorized_app.developer,
          app_id: authorized_app.id
      )

      if !challenge.save
        err_message << challenge.errors.join(", ")
      end
    end

    if err_message.blank?
      head :ok
    else
      render status: :bad_request, json: {message: err_message}
    end
  end

  private
  def set_leaderboard
    @leaderboard = authorized_app && authorized_app.leaderboards.find_by_id(params[:leaderboard_id].to_i)
    unless @leaderboard
        render :status => :forbidden, :json => { message: "You do not have access to this leaderboard." }
    end
  end

  def authorized_developer
    authorized_app && authorized_app.developer
  end

end
