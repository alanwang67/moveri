import matplotlib.pyplot as plt
import matplotlib
from matplotlib.font_manager import findfont, FontProperties
import sys
import math
import copy 
import os 

# folder where santized data is, pointing to specific workload 
# if the output of the santizied data is ../formatted then 
# the path would be ../formatted/GossipRandom/workload_5
# for workload_5 
folder = sys.argv[1]

# number of data points
data_points = int(sys.argv[2])

# output directory 
output = sys.argv[3]

# title
title = sys.argv[4]

def extract_number(s):
    return int("".join(filter(str.isdigit, s)))

int_to_session = {0: "eventual", 1: "writes follow reads", 2: "monotonic writes", 3: "monotonic reads", 4: "read my writes", 5: "causal"}

# data looks like: 
# { "eventual": [[1,2], [3,1]] } 
# which represents the data points (1, 3) and (2, 1)
data = {}

for session in range(0, 6):
    x = []
    y = []
    for i in range(1, data_points + 1):
        try:
            with open(os.path.join(folder, int_to_session[session], f"{i}.txt"), "r") as f:
                contents = f.read().splitlines()
                throughput = extract_number(contents[0])
                latency = extract_number(contents[1])
                x.append(throughput/1000)
                y.append(latency)

        except IOError as e:
            break
    
    data[int_to_session[session]] = [x, y]

plt.figure()
plt.xlabel('Throughput (kops/sec)')
plt.ylabel('Latency (us)')

order = ["eventual", "monotonic reads", "read my writes", "monotonic writes", "writes follow reads", "causal"]

for o in order:
    for session in data:
        x, y = data[session]
        if session == o and session == "eventual":
            plt.plot(x, y, marker='o', color='b', label = "EC")
        if session == o and session == "writes follow reads":
            plt.plot(x, y, marker='*', color='r', label = "WFR")
        if session == o and session == "monotonic writes":
            plt.plot(x, y, marker='h', color='g', label = "MW")
        if session == o and session == "read my writes":
            plt.plot(x, y, marker='.', color='y', label = "RMW")
        if session == o and session == "monotonic reads":
            plt.plot(x, y, marker='2', color='k', label = "MR")
        if session == o and session == "causal":
            plt.plot(x, y, marker='x', color='m', label = "C")

plt.title(title, fontsize = 8.0)

plt.legend(loc='center left', bbox_to_anchor=(1, 0.5))

plt.savefig(os.path.join(output, 'fig.png'), bbox_inches='tight')
