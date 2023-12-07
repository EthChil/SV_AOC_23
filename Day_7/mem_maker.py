import sys

#TODO: modify so makefile feeds day number in

def encode(prompt, output):
    line_counter = 0

    for line in prompt:
        conv_line = []
        for letter in line.strip():
            conv_line.append(str(hex(ord(letter)))[2:])
            line_counter += 1
            
        output.write('\n'.join(conv_line) + "\nFF\n\n")
        line_counter += 1
        if(len(''.join(conv_line)) % 2 != 0):
            print("ERROR")
            exit(0)
    print("SUCCESS")
    print(line_counter)
    output.close()

prompt_test = open("test.txt", "r")
prompt_legit = open("my_input.txt", "r")

mem_test = open("test.mem", "w")
mem_legit = open("day7.mem", "w") 

encode(prompt_test, mem_test)
encode(prompt_legit, mem_legit)