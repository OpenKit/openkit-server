class DeveloperSession < Authlogic::Session::Base
  remember_me true
  remember_me_for 30.days
end

