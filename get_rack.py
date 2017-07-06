import subprocess
import sys

def getRackInfo(fname):
    cmd = "docker-compose -f docker-compose-hadoop.yml exec mfschunkhadoop_a2 hadoop/bin/hdfs fsck %s -files -blocks -locations -racks" % fname

    cmd = cmd.split(' ')

    ret = subprocess.check_output(cmd)
    ret = ret.decode('utf-8')
    ret = ret.split('\n')
    ret = [x for x in ret if "default/rack" in x]
    data=[]
    for l in ret:
        t = l.split('[')[1]
        t = t.split(']')[0]
        t = t.split(', ')
        print("Block: "+l[0])
        for a in t:
            print("\t"+a)

if len(sys.argv) == 2:
    getRackInfo(sys.argv[1])
else:
    print("Usage:\n%s hdfs_file_path"%sys.argv[0])
