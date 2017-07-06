# Use hadoop base image (Ubuntu 14.04)
FROM hadoop-base:latest

# Install wget, lsb-release and curl
RUN apt-get update && apt-get install -y wget lsb-release curl fuse libfuse2 tree

# Add key
RUN wget -O - http://ppa.moosefs.com/moosefs.key | apt-key add -
RUN . /etc/lsb-release && echo "deb http://ppa.moosefs.com/moosefs-3/apt/ubuntu/$DISTRIB_CODENAME $DISTRIB_CODENAME main" > /etc/apt/sources.list.d/moosefs.list

# Install MooseFS chunkserver and client
RUN apt-get update && apt-get install -y moosefs-chunkserver moosefs-client

# Expose ports
EXPOSE 9419 9420 9422

# Add and run start script
ADD start-chunkserver-client-hadoop-slave.sh /home/start-chunkserver-client-hadoop-slave.sh
RUN chown root:root /home/start-chunkserver-client-hadoop-slave.sh
RUN chmod 700 /home/start-chunkserver-client-hadoop-slave.sh

ADD mapred-site.xml /home/mapred-site.xml
ADD etc_mapred-site.xml /home/etc_mapred-site.xml

CMD ["/home/start-chunkserver-client-hadoop-slave.sh", "-bash"]
