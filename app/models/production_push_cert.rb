class ProductionPushCert < PushCert
  set_local_path OKConfig[:apns_pem_path]
end
