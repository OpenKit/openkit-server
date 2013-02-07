module ApplicationHelper
  def logging_in?
    request.path == login_path
  end

  def display_login?
    !current_developer && !logging_in?
  end

  def display_logout?
    !!current_developer
  end
end
