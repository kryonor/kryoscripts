# JFIF to JPG rename script, applies to all subdirs
# usage : python stopJFIF.py "path/to/rootDir"
# fvck you twitter

import os
import sys

def main():
  folder = sys.argv[1]
  for root, dirs, files in os.walk(folder):
    for fname in files:
      sys.stdout.write(fname)
      if not ".jfif" in fname:
        sys.stdout.write(" 0\n")
        continue
      fpath = os.path.join(root, fname)
      file1 = open(fpath, "rb")
      content = file1.read()
      file1.close()
      file2 = open(fpath.replace(".jfif", ".jpg"), "wb")
      file2.write(content)
      file2.close()
      os.remove(fpath)
      sys.stdout.write(" 1\n")

if __name__ == "__main__":
  main()
  os.system("pause")
