# strace2uml
# Prerequisites
(1) Tested on CentOS 7.9<br>
(2) strace binary on path, https://github.com/strace/strace, <br>
(3) PlantUML jar in the install dir, v.1.2023.6+ https://www.plantuml.com/plantuml
(4) java, trace-io.sh, strace2uml, strace_log_filter on path

# Usage <br>
#first, trace the script.<br>
trace_io.sh \<script to be traced\> \<script arguments\><br>
#filter the log file, convert it to uml and render the diagram.
strace2uml \<strace log file\> \<uml file\><br>
