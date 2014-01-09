#Put the version of storm you need in the next line
KAFKARPMVERSIONTAG=0.8.0
#KAFKARPMVERSIONTAG=kafka-0.7.2-incubating-candidate-5
#BEWARE THAT THIS MAY NOT CONTAIN A '-' !!!
KAFKARPMVERSION=0.8.0
#KAFKARPMVERSION=0.7.2

# The next thing is needed to  use the latest version.
# This may NOT start with a '0' !!
KAFKARPMVERSIONINTEGER=8000
RPMRELEASE=1

all: rpm

# =======================================================================

.PHONY: kafka-rpm
rpm:: kafka-rpm
kafka-rpm: kafka-$(KAFKARPMVERSION)*.rpm

kafka-$(KAFKARPMVERSION)*.rpm: kafka-$(KAFKARPMVERSION).tar.gz java-is-installed
	@echo "Building the rpm"
	-@mkdir -p RPM_BUILDING/BUILD  RPM_BUILDING/RPMS  RPM_BUILDING/SOURCES  RPM_BUILDING/SPECS  RPM_BUILDING/SRPMS
	@rpmbuild --define="_topdir `pwd`/RPM_BUILDING" -tb $<
	@find RPM_BUILDING/{,S}RPMS/ -type f | xargs -n1 -iXXX mv XXX .
	@echo
	@echo "================================================="
	@echo "The rpms have been created and can be found here:"
	@ls -laF kafka*rpm
	@echo "================================================="

kafka-$(KAFKARPMVERSION).tar.gz: kafka/kafka.spec
	@echo "Creating a $@ file."
	@(\
	  rm -f kafka-$(KAFKARPMVERSION); \
	  ln -s kafka kafka-$(KAFKARPMVERSION); \
	  tar czf $@ kafka-$(KAFKARPMVERSION)/* ;\
	 )

kafka/kafka.spec: kafka.spec.in kafka-version 
	@echo "Creating the spec file"
	@(cat $< | sed 's@##RPMVERSION##@$(KAFKARPMVERSION)@g;s@##RPMRELEASE##@$(RPMRELEASE)@g;s@##INTEGERVERSION##@$(KAFKARPMVERSIONINTEGER)@g' > $@ )
	

kafka/.git:
	@git clone https://github.com/apache/kafka.git kafka

kafka-version: kafka/.git Makefile
	@( cd kafka; \
	   git checkout $(KAFKARPMVERSIONTAG) ; \
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
	@rm -rf kafka kafka-$(KAFKARPMVERSION) kafka-$(KAFKARPMVERSION).tar.gz kafka-$(KAFKARPMVERSION)*rpm RPM_BUILDING java-is-installed
	@echo "done."

