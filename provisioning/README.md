Server Provisioning
-------------------

This is the start of a readme that will have you up and running on your
OpenKit system. WIP.

Dependencies: 

	$ brew install python
	$ pip install awscli
	$ aws configure


One time configuration:

	$ bin/create_security_groups

Boot an instance: 

	$ bin/boot_instance small -a HTTP
