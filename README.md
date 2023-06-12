# strace2uml
# Prerequisites
(1) Tested on CentOS 7.9<br>
(2) strace https://github.com/strace/strace, <br>
(3) PlantUML jar 1.2023.6+ https://www.plantuml.com/plantuml

# Usage <br>
#first, trace the script.<br>
trace_io.sh <script to be traced> <script arguments><br>
#second, filter the log file<br>
strace_log_filter strace.log <filtered log file><br>
#next, convert to uml (mindmap) file<br>
strace2uml <filtered log file> <uml file><br>
#finally, render the diagram.<br>
java -DPLANTUML_LIMIT_SIZE=165535 -jar plantuml-1.2023.6.jar <uml file> <br>
