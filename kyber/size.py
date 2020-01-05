#!/usr/bin/env python3
import os
import re
import sys
import subprocess

def build_objects(n):
    for source_file in os.listdir('.'):
        if re.compile(r'.*\.(c|S)$').match(source_file) == None:
            continue
        object_file = 'obj/' + source_file[:-1] + 'o'
        command = ["make",f"-s",f"EXTRA_FLAGS=-DKYBER_P={n}",object_file]
        subprocess.check_call(command)

glob = f'obj/*.o'
remove = ["rm", "-rf", "obj"]

build_objects(512)
output = subprocess.check_output(
            'arm-none-eabi-size -t ' + glob,
            shell=True,
            stderr=subprocess.DEVNULL,
            universal_newlines=True)
sizes512 = output.splitlines()[-1].split('\t')
subprocess.check_call(remove)

build_objects(768)
output = subprocess.check_output(
            'arm-none-eabi-size -t ' + glob,
            shell=True,
            stderr=subprocess.DEVNULL,
            universal_newlines=True)
sizes768 = output.splitlines()[-1].split('\t')
subprocess.check_call(remove)

build_objects(1024)
output = subprocess.check_output(
            'arm-none-eabi-size -t ' + glob,
            shell=True,
            stderr=subprocess.DEVNULL,
            universal_newlines=True)
sizes1024 = output.splitlines()[-1].split('\t')
subprocess.check_call(remove)

print("==========================")
print("Kyber512")
fsizes = (f'.text bytes:\n{sizes512[0].strip()}\n'
          f'.data bytes:\n{sizes512[1].strip()}\n'
          f'.bss bytes:\n{sizes512[2].strip()}\n'
          f'.total bytes:\n{sizes512[3].strip()}\n')
print(fsizes)

print("==========================")
print("Kyber768")
fsizes = (f'.text bytes:\n{sizes768[0].strip()}\n'
          f'.data bytes:\n{sizes768[1].strip()}\n'
          f'.bss bytes:\n{sizes768[2].strip()}\n'
          f'.total bytes:\n{sizes768[3].strip()}\n')
print(fsizes)

print("==========================")
print("Kyber1024")
fsizes = (f'.text bytes:\n{sizes1024[0].strip()}\n'
          f'.data bytes:\n{sizes1024[1].strip()}\n'
          f'.bss bytes:\n{sizes1024[2].strip()}\n'
          f'.total bytes:\n{sizes1024[3].strip()}\n')
print(fsizes)
