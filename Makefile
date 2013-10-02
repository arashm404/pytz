# Build the pytz libraries
#

MAKE=make
PYTHON24=python2.4
PYTHON25=python2.5
PYTHON26=python2.6
PYTHON27=python2.7
PYTHON31=python3.1
PYTHON32=python3.2
PYTHON33=python3.3
PYTHON=${PYTHON27}
PYTHON3=${PYTHON32}
OLSON=./elsie.nci.nih.gov
TESTARGS=-vv
TARGET=
#TARGET=Europe/Amsterdam Europe/Moscow W-SU Etc/GMT+2 Atlantic/South_Georgia Europe/Warsaw Europe/Vilnius
#Mideast/Riyadh87
STYLESHEET=/usr/share/python-docutils/stylesheets/default.css

all: dist

check: test_tzinfo test_docs

build: build/dist/locales/pytz.pot

dist: build/dist/locales/pytz.pot .stamp-dist
.stamp-dist: .stamp-tzinfo
	cd build/dist && mkdir -p ../tarballs && \
	${PYTHON} setup.py sdist --dist-dir ../tarballs \
	    --formats=bztar,gztar,zip && \
	${PYTHON24} setup.py bdist_egg --dist-dir=../tarballs && \
	${PYTHON25} setup.py bdist_egg --dist-dir=../tarballs && \
	${PYTHON26} setup.py bdist_egg --dist-dir=../tarballs && \
	${PYTHON27} setup.py bdist_egg --dist-dir=../tarballs && \
	${PYTHON33} setup.py bdist_egg --dist-dir=../tarballs && \
	${PYTHON31} setup.py bdist_egg --dist-dir=../tarballs && \
	${PYTHON32} setup.py bdist_egg --dist-dir=../tarballs
	touch $@

upload: dist build/dist/locales/pytz.pot .stamp-upload
.stamp-upload: .stamp-tzinfo
	cd build/dist && \
	${PYTHON} setup.py register sdist \
	    --formats=bztar,gztar,zip --dist-dir=../tarballs \
	    upload --sign && \
	${PYTHON24} setup.py register bdist_egg --dist-dir=../tarballs \
	    upload --sign && \
	${PYTHON25} setup.py register bdist_egg --dist-dir=../tarballs \
	    upload --sign && \
	${PYTHON26} setup.py register bdist_egg --dist-dir=../tarballs \
	    upload --sign && \
	${PYTHON27} setup.py register bdist_egg --dist-dir=../tarballs \
	    upload --sign && \
	${PYTHON33} setup.py register bdist_egg --dist-dir=../tarballs \
	    upload --sign && \
	${PYTHON32} setup.py register bdist_egg --dist-dir=../tarballs \
	    upload --sign && \
	${PYTHON31} setup.py register bdist_egg --dist-dir=../tarballs \
	    upload --sign
	touch $@

test: test_tzinfo test_docs test_zdump

clean:
	rm -f .stamp-*
	rm -rf build/*/*
	make -C ${OLSON}/src clean
	find . -name \*.pyc | xargs rm -f

test_tzinfo: .stamp-tzinfo
	cd build/dist/pytz/tests \
	    && ${PYTHON24} test_tzinfo.py ${TESTARGS} \
	    && ${PYTHON25} test_tzinfo.py ${TESTARGS} \
	    && ${PYTHON26} test_tzinfo.py ${TESTARGS} \
	    && ${PYTHON27} test_tzinfo.py ${TESTARGS} \
	    && ${PYTHON31} test_tzinfo.py ${TESTARGS} \
	    && ${PYTHON32} test_tzinfo.py ${TESTARGS} \
	    && ${PYTHON33} test_tzinfo.py ${TESTARGS}

test_docs: .stamp-tzinfo
	cd build/dist/pytz/tests \
	    && ${PYTHON24} test_docs.py ${TESTARGS} \
	    && ${PYTHON25} test_docs.py ${TESTARGS} \
	    && ${PYTHON26} test_docs.py ${TESTARGS} \
	    && ${PYTHON27} test_docs.py ${TESTARGS} \
	    && ${PYTHON31} test_docs.py ${TESTARGS} \
	    && ${PYTHON32} test_docs.py ${TESTARGS} \
	    && ${PYTHON33} test_docs.py ${TESTARGS}

test_zdump: dist
	${PYTHON} gen_tests.py ${TARGET} && \
	${PYTHON} test_zdump.py ${TESTARGS} && \
	${PYTHON3} test_zdump.py ${TESTARGS}

build/dist/test_zdump.py: .stamp-zoneinfo

doc: docs

docs: dist
	mkdir -p build/docs/source/.static
	mkdir -p build/docs/built
	cp src/README.txt build/docs/source/index.txt
	cp conf.py build/docs/source/conf.py
	sphinx-build build/docs/source build/docs/built
	chmod -R og-w build/docs/built
	chmod -R a+rX build/docs/built

upload_docs: upload_docs_pythonhosted upload_docs_sf

upload_docs_sf: docs
	rsync -e ssh -ravP build/docs/built/ \
	    web.sourceforge.net:/home/project-web/pytz/htdocs/

upload_docs_pythonhosted: docs
	cd build/dist \
	    && ${PYTHON} setup.py upload_docs --upload-dir=../docs/built

.stamp-tzinfo: .stamp-zoneinfo gen_tzinfo.py build/etc/zoneinfo/GMT
	${PYTHON} gen_tzinfo.py ${TARGET}
	rm -rf build/dist/pytz/zoneinfo
	cp -a build/etc/zoneinfo build/dist/pytz/zoneinfo
	touch $@

.stamp-zoneinfo:
	${MAKE} -C ${OLSON}/src TOPDIR=`pwd`/build install
	# Break hard links, working around http://bugs.python.org/issue8876.
	for d in zoneinfo zoneinfo-leaps zoneinfo-posix; do \
	    rm -rf `pwd`/build/etc/$$d.tmp; \
	    rsync -a `pwd`/build/etc/$$d/ `pwd`/build/etc/$$d.tmp; \
	    rm -rf `pwd`/build/etc/$$d; \
	    mv `pwd`/build/etc/$$d.tmp `pwd`/build/etc/$$d; \
	done
	touch $@

build/dist/locales/pytz.pot: .stamp-tzinfo
	@: #${PYTHON} gen_pot.py build/dist/pytz/locales/pytz.pot

#	cd build/dist; mkdir locales; \
#	pygettext --extract-all --no-location \
#	    --default-domain=pytz --output-dir=locales



.PHONY: all check dist test test_tzinfo test_docs test_zdump
