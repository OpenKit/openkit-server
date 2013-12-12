App.class_eval do

  # First, see if the user already exists for the developer of this app, based
  # on user_params. If user already exists, subscribe him/her to this app.  If
  # user does not yet exist, create both the user and the subscription.
  def find_or_create_subscribed_user(user_params)
    u = (user_params[:fb_id]      && developer.users.find_by(fb_id: user_params[:fb_id].to_s)) ||
        (user_params[:twitter_id] && developer.users.find_by(twitter_id: user_params[:twitter_id].to_s)) ||
        (user_params[:google_id]  && developer.users.find_by(google_id: user_params[:google_id].to_s))||
        (user_params[:custom_id]  && developer.users.find_by(custom_id: user_params[:custom_id].to_s)) ||
        (user_params[:gamecenter_id]  && developer.users.find_by(gamecenter_id: user_params[:gamecenter_id].to_s))

    if !u
      u = developer.users.create(user_params)
    end

    if u.errors.count == 0
      u.apps << self unless u.apps.include?(self)
    end

    u
  end
end