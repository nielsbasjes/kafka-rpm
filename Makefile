# The git tag/branch of storm you need (i.e. master or 0.8.1.0 )
GIT_VERSION_TAG=0.8.1.1

#The version for the RPM 
#BEWARE THAT THIS MAY NOT CONTAIN A '-' !!!
RPM_VERSION=0.8.1.1

# The next thing is needed to use the latest version.
# This is a numerical value that should increase with a newer release
# This may NOT start with a '0' !!
RPM_VERSION_INTEGER=8110

# =======================================================================

all: rpm

.PHONY: kafka-rpm
rpm:: kafka-rpm
kafka-rpm: kafka-$(RPM_VERSION)*.rpm

kafka-$(RPM_VERSION)*.rpm: kafka-$(RPM_VERSION).tar.gz java-is-installed
	@echo "Building the rpm"
	-@mkdir -p RPM_BUILDING/BUILD  RPM_BUILDING/RPMS  RPM_BUILDING/SOURCES  RPM_BUILDING/SPECS  RPM_BUILDING/SRPMS
	@rpmbuild --define="_topdir `pwd`/RPM_BUILDING" -tb $<
	@find RPM_BUILDING/{,S}RPMS/ -type f | xargs -n1 -iXXX mv XXX .
	@echo
	@echo "================================================="
	@echo "The rpms have been created and can be found here:"
	@ls -laF kafka*rpm
	@echo "================================================="

kafka-$(RPM_VERSION).tar.gz: kafka/kafka.spec
	@echo "Creating a $@ file."
	@(\
	  rm -f kafka-$(RPM_VERSION); \
	  ln -s kafka kafka-$(RPM_VERSION); \
	  tar czf $@ kafka-$(RPM_VERSION)/* ;\
	 )

kafka/kafka.spec: kafka.spec.in kafka-version RELEASE
	@echo "Creating the spec file"
	@read REL < RELEASE ; (( REL += 1)) ; echo $${REL} > RELEASE 
	cat $< | \
	    sed "\
	      s@##RPMVERSION##@$(RPM_VERSION)@g;\
	      s@##RPMRELEASE##@$$(cat RELEASE)@g;\
	      s@##INTEGERVERSION##@$(RPM_VERSION_INTEGER)@g" > $@ 

RELEASE:
	@echo 0 > $@

kafka/.git:
	@git clone https://github.com/apache/kafka.git kafka

kafka-version: kafka/.git Makefile
	@( cd kafka; \
	   git checkout $(GIT_VERSION_TAG) ; \
	)


java-is-installed:
	@(\
	  JAVAVERSION=$$(java -version 2>&1| head -1) ; \
	  if [[ x$${JAVAVERSION} == x ]]; \
	  then \
	    echo "ERROR: Java (JDK) 1.7 is missing." ; \
	    echo "JDK 1.7 can be downloaded from http://www.oracle.com/technetwork/java/javase/downloads/jdk7-downloads-1880260.html" ; \
	    exit 1; \
	  else \
	    echo INSTALLED > $@ ; \
	  fi \
	)

clean::
	@echo -n "Cleaning kafka "
	@rm -rf kafka kafka-$(RPM_VERSION) kafka-$(RPM_VERSION).tar.gz kafka-$(RPM_VERSION)*rpm RPM_BUILDING java-is-installed
	@echo "done."

