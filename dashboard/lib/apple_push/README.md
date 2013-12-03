API
====

	require './apple_push.rb'

	combined_pem_path = './push_dev.pem'
	token = "7263097dd87a783c5d90dfa61ad3df3d17b11428143c788e77c1be4c2d162d38"
	payload = {aps: {alert: "la la la la", badge: 0, sound: "default"}, other_meta: 10}

	# High level API
	# ----------------

	ApplePush::Sandbox.deliver(token, payload, combined_pem_path)


	# Lower level API
	# ---------------

	host = 'gateway.sandbox.push.apple.com'
	note = ApplePush::Note.new(token, payload)
	cxn  = ApplePush::Connection.new(host, combined_pem_path)
	cxn.write(note.packed)


Creating the combined pem file
==============================
  1. Download your push cert from https://developer.apple.com/account/ios/certificate/certificateList.action
  2. Double click on the downloaded cert (aps_development.cer) to add it to keychain.
  3. Right click on the cert in keychain and export it as push_dev.p12
  4. Convert the exported .p12 to a .pem file with:  
    `$ openssl pkcs12 -in push_dev.p12 -out push_dev.pem -nodes`

Author
======
Lou Zell @ OpenKit.  
If you'd like to contribute, or have feedback, please email me at lou@openkit.io.  

Example
=======
Send messages to yourself:

```
require './apple_push.rb'

token = "7263097dd87a783c5d90dfa61ad3df3d17b11428143c788e77c1be4c2d162d38"   # use your own token
combined_pem_path = './push_dev.pem'                                         # use your own combined pem file

while (line = gets.chomp)
  payload = {aps: {alert: line}}
  ApplePush::Sandbox.deliver(token, payload, combined_pem_path)
end
```
