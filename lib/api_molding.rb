module ApiMolding
  extend self

  # Version 0.9 of the API used fb_ids as longs instead of strings.  Pass the
  # output of Score#as_json as an argument.
  def fb_fix_0_9(score_rep)
    score_rep[:user] && score_rep[:user]['fb_id'].is_a?(String) && (score_rep[:user]['fb_id'] = score_rep[:user]['fb_id'].to_i)
  end
end
