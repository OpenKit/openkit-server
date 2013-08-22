module ApiMolding
  extend self

  # Version 0.9 of the API used fb_ids as longs instead of strings.  Pass the
  # output of Score#as_json as an argument.
  def fb_fix_0_9(rep)
    if rep[:user]
      if rep[:user]['fb_id'] && rep[:user]['fb_id'].is_a?(String)
        rep[:user]['fb_id'] = rep[:user]['fb_id'].to_i
      end
    else
      if rep['fb_id'] && rep['fb_id'].is_a?(String)
        rep['fb_id'] = rep['fb_id'].to_i
      end
    end
  end
end
