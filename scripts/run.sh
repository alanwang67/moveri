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

if [[ $* == *-help* ]]; then 
    echo Provide: {absolute path of go code} {absolute path where you want your output} {absolute path of config file}
else 
    ct=0
    tmux kill-session -t experiment 
    
    cd $1
    go build main.go 

    cd $2

    SES="experiment"               
    DIR=$1

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

    run_command $SES 0 "cd $1"
    run_command $SES 1 "cd $1"
    run_command $SES 2 "cd $1"

    sleep 1

    declare -a arr=("PrimaryBackUpRoundRobin" "GossipRandom" "PinnedRoundRobin" "PrimaryBackUpRandom") # name of json files your config folder must contain
    declare -a workload=(5 50 95) 
    for name in "${arr[@]}"
    do
        cd $2
        mkdir $name
        for w in "${workload[@]}"
        do
            cd $2/$name/
            mkdir workload_$w
            for session in {0..5} 
            do  
                cd $2/$name/workload_$w
                mkdir $session    
                for run in {1..3}
                do
                    cd $2/$name/workload_$w/$session 
                    mkdir run_$run 
                    for i in {1..3}
                    do
                        # start all the server's arguments are: server id, gossip interval
                        run_command $SES 0 "./main $ct server 0 500"

                        run_command $SES 1 "./main $ct server 1 500"

                        run_command $SES 2 "./main $ct server 2 500"

                        sleep 10

                        # for different write percentages we scale up by different amounts of threads
                        if [ $w = 50 ]; then
                            # start client arguments are client config file, time client is running, session semantic, workload 
                            cd ~/session_semantics; ./main $ct client $3/$name.json $(( 2 + (($i - 1) * 9) )) 10 $session $w > $2/$name/workload_$w/$session/run_$run/$i
                        fi 

                        if [ $w = 5 ]; then
                            # start client arguments are client config file, number of threads, time client is running, session semantic, workload 
                            cd ~/session_semantics; ./main $ct client $3/$name.json $(( 2 + (($i - 1) * 8) )) 10 $session $w > $2/$name/workload_$w/$session/run_$run/$i
                        fi 

                        if [ $w = 95 ]; then
                            # start client arguments are client config file, number of threads, time client is running, session semantic, workload 
                            cd ~/session_semantics; ./main $ct client $3/$name.json $(( 2 + (($i - 1) * 6) )) 10 $session $w > $2/$name/workload_$w/$session/run_$run/$i
                        fi 

                        ct=$(($ct + 1))

                        tmux send-keys -t server0 C-c
                        tmux send-keys -t server1 C-c
                        tmux send-keys -t server2 C-c

                    done 
                done
            done
        done 
    done
fi