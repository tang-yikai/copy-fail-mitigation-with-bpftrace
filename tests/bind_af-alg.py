#!/usr/bin/env python3
import socket

def bind_af_alg(alg_type, alg_name):
    sock = socket.socket(socket.AF_ALG, socket.SOCK_SEQPACKET, 0)

    sock.bind((alg_type, alg_name))

    print(f"[+] bind successful: family=AF_ALG, type={alg_type}, name={alg_name}")
    print("[+] Process survived")
    sock.close()

if __name__ == "__main__":
    bind_af_alg("skcipher", "cbc(aes)")
