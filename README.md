kafka-rpm
=========
Scripting to create a CentOS RPM for Kafka.

Introduction
=====
This is simply an improved/updated version of what Mark Poole created and posted on his website https://poole.im/apache-kafka-latest-rpm-for-centos-rhel-6/
Note that most of the scripting has been massively rewritten.

Dependencies
=====
If you don't already have development tools installed:

	$ yum groupinstall "Development Tools"

You will need to download and install the JDK from the oracle website:
http://www.oracle.com/technetwork/java/javase/downloads/jdk7-downloads-1880260.html
and install:

	$ rpm -ivh jdk-7u25-linux-x64.rpm

Building
=====
Simply run the following command

	$ make

After the compilation you will have an RPM that you should be able to install.
