#!/bin/bash

create_session() {
    tmux new-session -d -s ${1} -c ${2}
}

# Attach to tmux session
attach_session() {
    tmux attach-session -t $1
}

# Create new tmux window, set starting directory
new_window() {
    tmux new-window -t ${1}:${2} -c ${3}
}

# Create new tmux window split horizontally, set starting directory
new_window_horiz_split() {
    tmux new-window -t ${1}:${2} -c ${3}
    tmux split-window -h -t ${1}:${2}
}

# Name tmux window
name_window() {
    tmux rename-window -t ${1}:${2} ${3}
}

# Run tmux command
run_command() {
    tmux send-keys -t ${1}:${2} "${3}" C-m
}

# Run tmux command in left pane
run_command_left() {
    tmux send-keys -t ${1}:${2}.0 "${3}" C-m
}

# Run tmux command in right pane
run_command_right() {
    tmux send-keys -t ${1}:${2}.1 "${3}" C-m
}

ct=0
# tmux kill-session -t experiment 
    
SES="experiment"               
DIR="~/redis-7.4.2/src"   

create_session $SES $DIR       
new_window $SES 1 $DIR
new_window $SES 2 $DIR

sleep 1
name_window $SES 0 server0 
run_command $SES 0 "ssh srg02"

name_window $SES 1 server1
run_command $SES 1 "ssh srg03"

name_window $SES 2 server2
run_command $SES 2 "ssh srg04"

run_command $SES 0 "cd ~/redis-stable/src"
run_command $SES 1 "cd ~/redis-stable/src"
run_command $SES 2 "cd ~/redis-stable/src"

# absolute path of go directory, without trailing slash
cd $1; go build main.go 

sleep 1

# provide absolute path of output directory, without trailing slash
cd $2

for run in {1..3}
    do  
        cd $2
        mkdir run_$run 
        cd $2/run_$run
        for i in {1..3} # 3 represents the number of runs 
            do
                # run redis on each ssh session with 1 primary servers and 2 backup servers 
                run_command $SES 0 "../../redis-server ../redis_conf/redis.conf"

                run_command $SES 1 "../../redis-server ../redis_conf/redis_backup.conf"

                run_command $SES 2 "../../redis-server ../redis_conf/redis_backup.conf"

                sleep 10

                # the three arguments here are threads, time experiment is running and workload 
                # (i.e. go run main.go 2500 10 50 means that there will be 2500 threads, the experiment will be ran for 10 seconds 
                # and the workload is 50% writes)
                cd $1; go run main.go $(( 2500 )) 10 50 > $2/run_$run/$i
                
                tmux send-keys -t server0 C-c
                tmux send-keys -t server1 C-c
                tmux send-keys -t server2 C-c
        done 
    done
done
