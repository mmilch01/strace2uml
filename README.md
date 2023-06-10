# strace2uml
Prerequisites: (1) strace https://github.com/strace/strace, (2) PlantUML jar 1.2023.6+

Usage: 
#first, trace the script.
trace_io.sh <script to be traced> <script arguments>
#second, filter the log file
strace_log_filter strace.log <filtered log file>
#next, convert to uml (mindmap) file
strace2uml <filtered log file> <uml file>
#finally, render the diagram.
java -DPLANTUML_LIMIT_SIZE=165535 -jar plantuml-1.2023.6.jar <uml file> 
