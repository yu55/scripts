import os.path
 
topdir = './test'
exten = '.txt'
 
def step(ext, dirname, names):
    ext = ext.lower()
 
    for name in names:
        if name.lower().endswith(ext):
            filePath = os.path.join(dirname, name)
            print(filePath)

            file = open(filePath, 'a+')
            if os.stat(filePath).st_size > 0 and file.readlines()[-1] != '\n':
                file.write('\n')
                print("File " + filePath + " appended")
            file.close()
 
os.path.walk(topdir, step, exten)
