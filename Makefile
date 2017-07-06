all:
	docker build -t hadoop-base:latest hadoop-base
	# docker build -t lewuathe/hadoop-base:latest hadoop-base
#	docker build -t lewuathe/hadoop-master:latest hadoop-master
#	docker build -t lewuathe/hadoop-slave:latest hadoop-slave
	docker-compose -f docker-compose-hadoop.yml build

.PHONY: test clean

run:
	docker-compose -f docker-compose-hadoop.yml up -d
	echo "http://localhost:9870 for HDFS"
	echo "http://localhost:8088 for YARN"

down:
	docker-compose -f docker-compose-hadoop.yml down
