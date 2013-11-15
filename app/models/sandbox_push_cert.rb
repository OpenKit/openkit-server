class SandboxPushCert < PushCert
  set_local_path OKConfig[:apns_sandbox_pem_path]
end
