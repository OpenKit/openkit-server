require File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', 'push_service.rb'))

push_service = PushService.new(:dev)
push_service.connect
push_service.write("7263097dd87a783c5d90dfa61ad3df3d17b11428143c788e77c1be4c2d162d38", {aps: {alert: "This is cool!", badge: 1, sound: "default"}, other_meta: 10})
push_service.disconnect
