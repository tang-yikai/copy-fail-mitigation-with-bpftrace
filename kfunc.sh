nohup bpftrace --unsafe -e '
#include <linux/if_alg.h>
kfunc:alg_bind
{
    $sa = (struct sockaddr_alg *)args.uaddr;
    $match = ($sa->salg_name[0] == 97 && $sa->salg_name[1] == 117 &&
              $sa->salg_name[2] == 116 && $sa->salg_name[3] == 104 &&
              $sa->salg_name[4] == 101 && $sa->salg_name[5] == 110 &&
              $sa->salg_name[6] == 99 && $sa->salg_name[7] == 101 &&
              $sa->salg_name[8] == 115 && $sa->salg_name[9] == 110);
    if ($match) {
        printf("killed %d (%s) for binding AF_ALG [authencesn]\n", pid, comm);
        signal("SIGKILL");
    }
}' >> /home/<xxx>/.log/afalg_killer.log 2>&1 &
