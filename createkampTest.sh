# create kampTestEnv
docker run -itd \
           -p 0.0.0.0:8004:8003 \
           -p 0.0.0.0:8024:8023 \
		   -p 0.0.0.0:52:22 \
           --name kampDev \
           --hostname kamp_develop \
           -v /home/berg/work/proj/kamp:/home/berg/work/proj/kamp \
		   kamp_env2_sshd:v1.0 \

#		   --restart=always \
#		   --entrypoint="mkdir /var/run/sshd;/usr/sbin/sshd;/bin/bash" \
#          192.168.7.184:5005/kamp_env2/kamp:test2 \
