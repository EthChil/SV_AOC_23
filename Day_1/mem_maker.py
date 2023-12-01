import sys

prompt = open("my_input.txt", "r")
# prompt = open("test.txt", "r")

mem = open("day1.mem", "w") 

line_counter = 0

for line in prompt:
    conv_line = []
    for letter in line.strip():
        conv_line.append(str(hex(ord(letter)))[2:])
        line_counter += 1
        
    mem.write('\n'.join(conv_line) + "\nFF\n\n")
    line_counter += 1

    if(len(''.join(conv_line)) % 2 != 0):
        print("ERROR")
        exit(0)
print("SUCCESS")
print(line_counter)
mem.close()

# 4 attempts 53194