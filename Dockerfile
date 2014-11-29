# Baresip Docker

FROM phusion/baseimage:0.9.15
MAINTAINER L. Mangani <mangani@ntop.org>

# Set correct environment variables.
ENV HOME /root

# Set locale to UTF8
RUN locale-gen --no-purge en_US.UTF-8
RUN update-locale LANG=en_US.UTF-8
RUN dpkg-reconfigure locales
ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# Set software versions to install
ENV WEB http://www.creytiv.com/pub
ENV LIBRE re-0.4.10 
ENV LIBREM rem-0.4.6 
ENV BARESIP baresip-0.4.11

# Update Apt
RUN apt-get update
 
# Installing required packages
RUN sudo apt-get -y install build-essential git wget

# Enable loopback audio
RUN sudo apt-get -y install libasound2-dev libasound2 libasound2-data
#RUN sudo modprobe snd-aloop

RUN cd /tmp

# Install Libre
RUN wget $WEB/$LIBRE.tar.gz
RUN tar zxvf $WEB/$LIBRE.tar.gz
RUN cd $LIBRE
RUN make
RUN sudo make install
RUN cd ..
RUN rm -rf $LIBRE*

# Install Librem
RUN wget $WEB/$LIBREM.tar.gz
RUN tar zxvf $WEB/$LIBREM.tar.gz
RUN cd $LIBREM
RUN make
RUN sudo make install
RUN cd ..
RUN rm -rf $LIBREM*

# Install Baresip
RUN wget $WEB/$BARESIP.tar.gz
RUN tar zxvf $WEB/$BARESIP.tar.gz
RUN cd $BARESIP
RUN make
RUN sudo make install
RUN cd ..
RUN rm -rf $BARESIP*
 
# Updating shared libs
RUN sudo ldconfig

# Test
RUN baresip -h

# Enable Loopback
RUN sed '/^audio_player/ { s/default/hw:0,0/ }' $HOME/.baresip/config
RUN sed '/^audio_source/ { s/default/hw:0,1/ }' $HOME/.baresip/config
RUN sed '/^audio_alert/ { s/audio_alert/#audio_alert/ }' $HOME/.baresip/config  

# Clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Re-Test
RUN baresip -h
