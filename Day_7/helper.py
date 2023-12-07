text = input("text: ")

res = []
for letter in text:
    res.append(str(hex(ord(letter)))[2:])

print(', '.join(res))