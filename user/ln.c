#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
  // Handle symbolic link: ln -s target linkname
  if(argc == 4 && strcmp(argv[1], "-s") == 0){
    if(symlink(argv[2], argv[3]) < 0){
      fprintf(2, "ln -s failed\n");
      exit(1);
    }
  } 
  // Handle hard link: ln old new
  else if(argc == 3){
    if(link(argv[1], argv[2]) < 0){
      fprintf(2, "link %s %s: failed\n", argv[1], argv[2]);
      exit(1);
    }
  } 
  else {
    fprintf(2, "Usage: ln old new OR ln -s old new\n");
    exit(1);
  }
  exit(0);
}
