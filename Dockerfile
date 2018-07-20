#
# DB2 10.5 Client Dockerfile (Part 1)
#
# Requires
#   - DB2 10.5 Client for 64bit Linux ibm_data_server_runtime_client_linuxx64_v10.5.tar.gz
#   - Response file for DB2 10.5 Client for 64bit Linux db2rtcl_nr.rsp 
#
#
# Using Ubuntu 14.04 base image as the starting point.
FROM ubuntu:14.04

MAINTAINER David Carew <carew@us.ibm.com>

# DB2 prereqs (also installing sharutils package as we use the utility uuencode to generate password - all others are required for the DB2 Client) 
RUN dpkg --add-architecture i386 && apt-get update && apt-get install -y sharutils binutils libstdc++6:i386 libpam0g:i386 && ln -s /lib/i386-linux-gnu/libpam.so.0 /lib/libpam.so.0


# Create user db2clnt
# Generate strong random password and allow sudo to root w/o password
#
RUN  \
   adduser --quiet --disabled-password -shell /bin/bash -home /home/db2clnt --gecos "DB2 Client" db2clnt && \
   echo db2clnt:`dd if=/dev/urandom bs=16 count=1 2>/dev/null | uuencode -| head -n 2 | grep -v begin | cut -b 2-10` | chgpasswd && \
   adduser db2clnt sudo && \
   echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Install DB2
RUN mkdir /install
# Copy DB2 tarball - ADD command will expand it automatically
#ADD ibm_data_server_runtime_client_linuxx64_v10.5.tar.gz /install/
ADD v10.5fp1_linuxx64_rtcl.tar.gz /install/
# Copy response file
COPY  db2rtcl_nr.rsp /install/
# Run  DB2 silent installer
RUN /install/rtcl/db2setup -u /install/db2rtcl_nr.rsp 

# Clean up unwanted files
RUN rm -fr /install/rtcl

# Login as db2clnt user
CMD su - db2clnt









