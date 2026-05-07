# copy-fail-mitigation-with-bpftrace
CVE-2026-31431, AKA Copy Fail, can be mitigated in one-line with bpftrace, no kpatch building, no cargo building

--------

# Idea
To exploit Copy Fail, you need to bind socket **AF_ALG** and use algorithm **authencesn**, which most applications don't use a lot. And that's where the mitigation can involve.

# files

├── kfunc.sh

├── kprobe.sh

├── tests

│   └── bind_af_alg.py

└── tracepoint.sh

# Why these files

the Author of `tracepoint.sh` is @天擎智能云, who published his writing at [Wechat Public Accounts](https://mp.weixin.qq.com/s/Hd_hzP5hFKRolF9__yLNoQ?scene=1)

I tested his script, and it worked out fine. 

However, inspired by https://github.com/Jannik2099/copyfail-ebpf-mitigation
I find that who bind socket **AF_ALG** but did not use algorithm **authencesn**, it may kill unconditionally.

The file tests/bind_af_alg.py explained for me.

Therefore, with the help of Deepseek, and after a day of manual experimentation, I verified kprobe.sh and kfunc.sh, who can log and deny all attempts to use bind() with salg_name=authencesn.

# Test results

|                | tracepoint | kprobe | kfunc |
| -------------- | ---------- | ------ | ----- |
| Ubuntu 20.04   | ✅          | ✅      | ❌     |
| Rocky 8.4      | ✅          | ✅      | ❌     |
| Gentoo rolling | ✅          | ✅      | ✅     |

# Requirements
# !!unverified!!
|                            | tracepoint                                                                                                                                                                                                                                                                                   | kprobe                                                                                                    | kfunc                                                                                                                                                                                                                                                                                                                             |
| -------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| kernel version (minimum)   | 4.7 (4.9+ recommended)                                                                                                                                                                                                                                                                       | 4.1                                                                                                       | 5.5                                                                                                                                                                                                                                                                                                                               |
| bpftrace version (minimum) | 0.9.4                                                                                                                                                                                                                                                                                        | 0.9.0                                                                                                     | 0.12                                                                                                                                                                                                                                                                                                                              |
| kernel parameters<br><br>  | CONFIG_BPF=y<br>CONFIG_BPF_SYSCALL=y<br>CONFIG_BPF_EVENTS=y<br>CONFIG_FTRACE_SYSCALLS=y<br>CONFIG_FUNCTION_TRACER=y<br>CONFIG_HAVE_DYNAMIC_FTRACE=y<br>CONFIG_DEBUG_FS=y<br><br>optional:<br>CONFIG_BPF_JIT=y & CONFIG_HAVE_EBPF_JIT=y<br>CONFIG_KPROBES=y<br>CONFIG_KPROBE_EVENTS=y VENTS=y | CONFIG_BPF=y<br>CONFIG_BPF_SYSCALL=y<br>CONFIG_KPROBES=y<br>CONFIG_KPROBE_EVENTS=y<br>CONFIG_BPF_EVENTS=y | CONFIG_BPF=y<br>CONFIG_BPF_SYSCALL=y<br>CONFIG_BPF_EVENTS=y<br>CONFIG_BPF_JIT=y<br>CONFIG_HAVE_EBPF_JIT=y<br>CONFIG_KPROBES=y<br>CONFIG_KPROBE_EVENTS=y<br>CONFIG_FUNCTION_TRACER=y<br>CONFIG_HAVE_DYNAMIC_FTRACE=y<br>CONFIG_DYNAMIC_FTRACE=y<br>CONFIG_DEBUG_INFO_BTF=y<br>CONFIG_DEBUG_INFO_BTF_MODULES=y<br>CONFIG_DEBUG_FS=y |

