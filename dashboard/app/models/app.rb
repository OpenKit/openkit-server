App.class_eval do

  def features=(arr)
    raise ArgumentError.new("Pass an array to App#features=") unless arr.is_a?(Array)
    self.feature_list = arr.join(',')
  end

  def sandbox_push_cert
    @sandbox_push_cert ||= SandboxPushCert.find_by_app_key(app_key)
  end

  def production_push_cert
    @production_push_cert ||= ProductionPushCert.find_by_app_key(app_key)
  end
end