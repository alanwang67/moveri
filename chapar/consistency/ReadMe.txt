--------------------------------------------------------------
Certified Causally Consistent Distributed Key-Value Stores

--------------------------------------------------------------
Directory structure 

   coq (folder):
      The coq verification framework
      KVStore.v
         The basic definitions, the semantics and accompanying lemma
      KVSAlg1.v
         The definition and proof of algorithm 1 in the paper
      KVSAlg1.v
         The definition and proof of algorithm 2 in the paper
      KVSAlg3.v
         The definition and proof of algorithm 3 in the appendix
      Extract.v
         The coq file that extracts the algorithms
      ReflectiveAbstractSemantics.v
         The client verification definitions and lemmas
      Examples (folder)
         The verified client programs
      Lib (folder)
         The general purpose coq libraries
      
   ml (folder):
      The ocaml runtime to execute the algorithms
      algorithm.ml
         Key-value store algorithm shared interface
      algorithm1.ml
      algorithm2.ml
      algorithm3.ml
         Wrappers for the extracted algorithms         
      benchgen.ml
         Benchmark generation and storing program
      benchprog.ml
         Benchmark retrieval program
      commonbench.ml
         Common definitions for benchmarks
      common.ml
         Common definitions
      configuration.ml
         Execution configuration definitions
      readConfig.ml
         Configuration retrieval program
      runtime.ml
         Execution runtime
      launchStore1.ml
      launchStore2.ml
      launchStore3.ml
         Launchers for the extracted algorithms
      util.ml
         General purpose ocaml functions      
      MLLib (folder)
         The general purpose ocaml libraries
      experiment.ml
         Small quick ocaml programming tests   

   .:
      The execution scripts described in the section Run below 
   
--------------------------------------------------------------
Build:
   
   $ make
   It both compiles the coq files and the ocaml files
   All the requirements are already installed in the VM.

   $ make clean
   Remove the make artifacts

--------------------------------------------------------------
Run:

   Overview:
      We run with 4 nodes called the worker nodes and a node called the master node that keeps track of the start and end of the runs. The scripts support running with both the current terminal blocked or detached. In the former, our VM should be active for the entire execution time. To avoid this, we use another node called the launcher node. Repeating and collecting the results of the runs is delegated to the launcher node. Our VM can be closed and the execution results can be retrieved later from the launcher node. The four workers, the master and the launcher can be different nodes. However, to simplify running, the scripts support assigning the VM itself to all of these roles. This is the default setting. 
      
      The settings of the nodes can be edited in the file Setting.txt. The following should be noted if other machines are used as the running nodes. 
      (1) SSH access
      The VM should have password-less ssh access to the launcher node. The launcher node should have password-less ssh access to the other nodes. This can be done by copying the public key of the accessing machine to the accessed machine by a command like:
      $ cat ~/.ssh/id_dsa.pub | ssh -l remoteuser remoteserver.com 'cat >> ~/.ssh/authorized_keys'
      (2) Open ports
      The port numbers 9100, 9101, 9102, and 9103 should be open on the worker nodes 1, 2, 3 and 4 respectively. The port number 9099 should be open on the master node.   

   A simple run:
      To start the run:
      $ ./batchrundetach
      To check the status of the run
      $ ./printlauncherout
      To get the results once the run is finished.
      $ ./fetchresults
      The result are stored in the file RemoteAllResults.txt. See ./fetchresults below for the format of the results.
   
   All of the following files are in the root folder.

   Settings.txt
      KeyRange:
         The range of keys in the generated benchmarks is from 0 to this number. For our experiments, it is set to 50.
      RepeatCount
         The number of times that each experiment is repeated. For our experiments, it is set to 5.
      LauncherNode
         The user name and the ip of the launcher node
      MasterNode
         The user name and the ip of the master node
      WorkerNodes
         The user name and the ip of the worker nodes

   ./batchrun
      This is the place that the experiments are listed.
      Each call to the script run is an experiment. The arguments are
      Argument 1: The number of nodes. This is 4 for our purpose.
      Argument 2: The number of operations per server. This is 60000 in our experiments.
      Argument 3: The percent of puts. This ranges from 10 to 90 in our experiments.
            
      This script can be called to execute without using the launcher node. The current terminal is blocked.
      See ./batchrundetach below for detached execution of the experiments.

   ./batchrundetach
      To execute using the launcher node. The current terminal is detached.

   ./printlauncherout
      To see the output of the launcher even while the experiments are being run
      
   ./printnodesout
      To see the output of the worker nodes

   ./fetchresults
      To get the results.
      The fetched files are:
         RemoteAllResults.txt       The timing of the replicas
         RemoteAllOutputs.txt       The outputs of the replicas
         RemoteLauncherOutput.txt   The output of the launcher node

         The format of the RemoteAllResults.txt. 
         The following example output is for the algorithm 2 with 4 worker nodes and 40000 operations per node with 10 percent puts. It shows two runs. Under  each run, the time spend by each of the nodes is shown. We compute the maximum of these four numbers to compute the total process time.         
         ---------------------------------------------
         Algorithm: 2
         Server count: 4
         Operation count: 40000
         Put percent: 10
         Run: 1
         1.000000
         3.000000
         1.000000
         1.000000
         Run: 2
         1.000000
         1.000000
         4.000000
         1.000000
         ---------------------------------------------


   ./clearnodes
      To remove the output and result files and the running processes in all the nodes.
      This is used to start over.      

--------------------------------------------------------------






















































