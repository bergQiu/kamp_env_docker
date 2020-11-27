#!/usr/bin/expect

spawn git clone -b release --single-branch ssh://git@www.marcia7.top:9021/zhijiang/kamp.git
expect "Are you sure you want to continue connecting (yes/no)?"
exp_send "yes\r"
interact