
lall = []
f = open("new_2.txt", "r")  
while True:  
    line = f.readline()  
    if line:
		line = line.strip()
		lall.append(line)
    else:  
        break
f.close()

lall.reverse()

for val in lall:
	print val