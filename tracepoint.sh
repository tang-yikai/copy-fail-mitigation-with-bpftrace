nohup bpftrace --unsafe -e '
tracepoint:syscalls:sys_enter_socket
/args->family == 38/
{
    printf("Killed %d (%s) for trying to use AF_ALG\n", pid, comm);
    signal("SIGKILL");
}' >> /home/<xxx>/.log/afalg_killer.log 2>&1 &
