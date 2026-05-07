# Copy Fail 利用eBPF,一行代码修复
CVE-2026-31431, 又名 Copy Fail, 可以通过bpftrace命令，用一行代码进行修复，无须编译kpatch，无须cargo编译

[English Version](README-en.md)|中文版本
--------

# 思路
要利用该漏洞，需要绑定到**AF_ALG**接口，并且使用加密算法**authencesn**，而这是绝大多数程序都不会用到的。这也就是修复代码可以发挥作用的地方。

# 文件列表

├── kfunc.sh

├── kprobe.sh

├── tests

│   └── bind_af_alg.py

└── tracepoint.sh

# 为什么要这么多文件

tracepoint.sh的原版作者是@天擎智能云，他的原版代码发布于[微信公众号](https://mp.weixin.qq.com/s/Hd_hzP5hFKRolF9__yLNoQ?scene=1)

这代码我测试了，确实能用。

但是，受到  https://github.com/Jannik2099/copyfail-ebpf-mitigation 的启发，我发现如果程序仅仅是绑定到**AF_ALG**接口，但是没有使用加密算法**authencesn**的情况下，该进程也会被无条件杀掉。

解释比较苍白，看[代码](tests/bind_af_alg.py) 。

因此，在Deepseek的帮助下，我花了1天的时间做测试，验证了另外2个修复代码。他们可以实现`记录`和`拒绝`所有尝试绑定到**AF_ALG**接口，并且使用加密算法**authencesn**的进程。

# 测试结果

|                | tracepoint | kprobe | kfunc |
| -------------- | ---------- | ------ | ----- |
| Ubuntu 20.04   | ✅          | ✅      | ❌     |
| Rocky 8.4      | ✅          | ✅      | ❌     |
| Gentoo rolling | ✅          | ✅      | ✅     |

# 运行条件
# ！！没验证过！！

|                            | tracepoint                                                                                                                                                                                                                                                                                   | kprobe                                                                                                    | kfunc                                                                                                                                                                                                                                                                                                                             |
| -------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| kernel version (minimum)   | 4.7 (4.9+ recommended)                                                                                                                                                                                                                                                                       | 4.1                                                                                                       | 5.5                                                                                                                                                                                                                                                                                                                               |
| bpftrace version (minimum) | 0.9.4                                                                                                                                                                                                                                                                                        | 0.9.0                                                                                                     | 0.12                                                                                                                                                                                                                                                                                                                              |
| kernel parameters<br><br>  | CONFIG_BPF=y<br>CONFIG_BPF_SYSCALL=y<br>CONFIG_BPF_EVENTS=y<br>CONFIG_FTRACE_SYSCALLS=y<br>CONFIG_FUNCTION_TRACER=y<br>CONFIG_HAVE_DYNAMIC_FTRACE=y<br>CONFIG_DEBUG_FS=y<br><br>optional:<br>CONFIG_BPF_JIT=y & CONFIG_HAVE_EBPF_JIT=y<br>CONFIG_KPROBES=y<br>CONFIG_KPROBE_EVENTS=y VENTS=y | CONFIG_BPF=y<br>CONFIG_BPF_SYSCALL=y<br>CONFIG_KPROBES=y<br>CONFIG_KPROBE_EVENTS=y<br>CONFIG_BPF_EVENTS=y | CONFIG_BPF=y<br>CONFIG_BPF_SYSCALL=y<br>CONFIG_BPF_EVENTS=y<br>CONFIG_BPF_JIT=y<br>CONFIG_HAVE_EBPF_JIT=y<br>CONFIG_KPROBES=y<br>CONFIG_KPROBE_EVENTS=y<br>CONFIG_FUNCTION_TRACER=y<br>CONFIG_HAVE_DYNAMIC_FTRACE=y<br>CONFIG_DYNAMIC_FTRACE=y<br>CONFIG_DEBUG_INFO_BTF=y<br>CONFIG_DEBUG_INFO_BTF_MODULES=y<br>CONFIG_DEBUG_FS=y |
