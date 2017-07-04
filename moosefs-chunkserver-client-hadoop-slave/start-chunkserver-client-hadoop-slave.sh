#!/bin/bash
cp /etc/mfs/mfschunkserver.cfg.sample /etc/mfs/mfschunkserver.cfg

mkdir -p /mnt/sdb1
chmod -R 777 /mnt/sdb1
echo "/mnt/sdb1 10GiB" >> /etc/mfs/mfshdd.cfg

ifconfig eth0 | awk '/inet addr/{print substr($2,6)}'

sed -i '/# LABELS =/c\LABELS = DOCKER' /etc/mfs/mfschunkserver.cfg
sed -i '/MFSCHUNKSERVER_ENABLE=false/c\MFSCHUNKSERVER_ENABLE=true' /etc/default/moosefs-chunkserver
mfschunkserver start

# wait for mfsmaster startup
ping -c 10 mfsmaster

mkdir -p /mnt/mfs

# mount mfs
mfsmount /mnt/mfs -H mfsmaster

# create example file to MooseFS
echo "If you can find this file in /mnt/mfs/SUCCESS on your client instance it means MooseFS is working correctly, congratulations!" > /mnt/mfs/welcome_to_moosefs.txt

# list files in MooseFS
ls /mnt/mfs/

# Increase memory size
mv /home/mapred-site.xml /usr/local/hadoop-3.0.0-alpha4-SNAPSHOT/input/mapred-site.xml
mv /home/etc_mapred-site.xml /usr/local/hadoop-3.0.0-alpha4-SNAPSHOT/etc/hadoop/mapred-site.xml

# Hadoop
$HADOOP_HOME/etc/hadoop/hadoop-env.sh

rm /tmp/*.pid

# installing libraries if any - (resource urls added comma separated to the ACP system variable)
cd $HADOOP_HOME/share/hadoop/common ; for cp in ${ACP//,/ }; do  echo == $cp; curl -LO $cp ; done; cd -

# altering the core-site configuration
#sed s/NAMENODE/$HOSTNAME/ /usr/local/hadoop/etc/hadoop/core-site.xml.template > /usr/local/hadoop/etc/hadoop/core-site.xml
#sed s/NAMENODE/$HOSTNAME/ /usr/local/hadoop/etc/hadoop/hdfs-site.xml.template > /usr/local/hadoop/etc/hadoop/hdfs-site.xml
#sed s/RESOURCEMANAGER/$HOSTNAME/ /usr/local/hadoop/etc/hadoop/yarn-site.xml.template.template > /usr/local/hadoop/etc/hadoop/yarn-site.xml.template

service ssh start
nohup $HADOOP_HOME/bin/hdfs datanode 2>> /var/log/hadoop/datanode.err >> /var/log/hadoop/datanode.out &
nohup $HADOOP_HOME/bin/yarn nodemanager 2>> /var/log/hadoop/nodemanager.err >> /var/log/hadoop/nodemanager.out &

# Example computation
if [[ -v RUN_EXAMPLE ]]
then
  echo "Running example MapReduce job"

  apt install git -y
  git clone https://github.com/karolmajek/hadoop-mapreduce-python-example.git example
  cd example
  ./download_data.sh
  echo `pwd`
  ls -la
  ls -la data
  ls `pwd`/data
  ls `pwd`/data/purchases.txt
  $HADOOP_HOME/bin/hadoop fs -ls
  $HADOOP_HOME/bin/hadoop fs -mkdir -p /user/root
  $HADOOP_HOME/bin/hadoop fs -ls
  $HADOOP_HOME/bin/hadoop fs -mkdir -p data
  $HADOOP_HOME/bin/hadoop fs -ls
  $HADOOP_HOME/bin/hadoop fs -put data/purchases.txt data/
  $HADOOP_HOME/bin/hadoop fs -ls data
  $HADOOP_HOME/bin/hadoop fs -mkdir -p results
  $HADOOP_HOME/bin/hadoop fs -ls

  export HADOOP_TOOLS_LIB_JARS_DIR=lib
  export HADOOP_TOOLS_HOME="/usr/local/hadoop-3.0.0-alpha4-SNAPSHOT/share/hadoop/tools"

  #Wait to exit safe mode
  while [ `$HADOOP_HOME/bin/hadoop dfsadmin -safemode get | grep ON | wc -l` -eq "1" ]; do echo "SAFEMODE is ON; Waiting to exit safe mode"; sleep 10; done

  echo "SAFEMODE is OFF"
  echo "Starting example job"

  $HADOOP_HOME/bin/hadoop jar ${HADOOP_TOOLS_HOME}/${HADOOP_TOOLS_LIB_JARS_DIR}/hadoop-streaming-3.0.0-alpha4-SNAPSHOT.jar -input data/ -output results/0000 -mapper mapper.py -file mapper.py -reducer reducer.py -file reducer.py
fi

if [[ $1 == "-d" ]]; then
    while true; do sleep 1000; done
fi

if [[ $1 == "-bash" ]]; then
    /bin/bash
fi
