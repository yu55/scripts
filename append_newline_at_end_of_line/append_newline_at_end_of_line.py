import os.path
 
topdir = 'test'
exten = '.txt'
 
def step(ext, dirname, names):
    ext = ext.lower()
 
    for name in names:
        if name.lower().endswith(ext):
            filePath = os.path.join(dirname, name)
            print(filePath)

            file = open(filePath, 'r+')
            readedLines = file.readlines()
            if os.stat(filePath).st_size > 0 and readedLines[-1][-1] != '\n':
		print("Last=" + readedLines[-1])
                file.write('\n')
                print("File " + filePath + " appended")
            file.close()
 
os.path.walk(topdir, step, exten)
