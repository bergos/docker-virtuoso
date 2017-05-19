FROM ubuntu:14.04

MAINTAINER Erika Pauwels <erika.pauwels@tenforce.com>

# Install Virtuoso prerequisites and crudini Python lib
RUN apt-get update \
        && apt-get install -y build-essential debhelper autotools-dev autoconf automake unzip wget net-tools git libtool flex bison gperf gawk m4 libssl-dev libreadline-dev libreadline-dev openssl python-pip \
        && pip install crudini

# Set Virtuoso commit SHA to Virtuoso 7.2.1 release (24/06/2015)
ENV VIRTUOSO_COMMIT 39e64c3a7ad8dd2143e5bb5d9ee81019e20c25bf

# Get Virtuoso source code from GitHub and checkout specific commit
# Make and install Virtuoso (by default in /usr/local/virtuoso-opensource)
RUN git clone https://github.com/openlink/virtuoso-opensource.git \
        && cd virtuoso-opensource \
        && git checkout ${VIRTUOSO_COMMIT} \
        && ./autogen.sh \
        && CFLAGS="-O2 -m64" && export CFLAGS && ./configure --disable-bpel-vad --enable-conductor-vad --enable-fct-vad --disable-dbpedia-vad --disable-demo-vad --disable-isparql-vad --disable-ods-vad --disable-sparqldemo-vad --disable-syncml-vad --disable-tutorial-vad --with-readline --program-transform-name="s/isql/isql-v/" \
        && make && make install \
        && ln -s /usr/local/virtuoso-opensource/var/lib/virtuoso/ /var/lib/virtuoso \
	&& ln -s /var/lib/virtuoso/db /data \
        && cd .. \
        && rm -r /virtuoso-opensource

# Add Virtuoso bin to the PATH
ENV PATH /usr/local/virtuoso-opensource/bin/:$PATH

# Add Virtuoso config
ADD virtuoso.ini /virtuoso.ini

# Add dump_nquads_procedure
ADD dump_nquads_procedure.sql /dump_nquads_procedure.sql

# Add Virtuoso log cleaning script
ADD clean-logs.sh /clean-logs.sh

# Add startup script
ADD virtuoso.sh /virtuoso.sh

VOLUME /data
WORKDIR /data
EXPOSE 8890
EXPOSE 1111

CMD ["/bin/bash", "/virtuoso.sh"]
