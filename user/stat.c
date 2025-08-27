#include "kernel/types.h"
#include "kernel/stat.h"
#include "kernel/fcntl.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
  int i;
  int nofollow = 0; // Default: follow symbolic links
  int idx = 1;
  int fd;
  struct stat st;

  if(argc < 2){
    fprintf(2, "Usage: stat [-L] file...\n");
    exit(1);
  }

  // Check for -L flag (Do not follow links)
  if(strcmp(argv[1], "-L") == 0){
    nofollow = 1;
    idx = 2;
  }

  for(i = idx; i < argc; i++){
    int mode = O_RDONLY;
    if(nofollow) mode |= O_NOFOLLOW;

    if((fd = open(argv[i], mode)) < 0){
      fprintf(2, "stat: cannot open %s\n", argv[i]);
      continue;
    }
    if(fstat(fd, &st) < 0){
      fprintf(2, "stat: cannot stat %s\n", argv[i]);
      close(fd);
      continue;
    }
    
    printf("File: %s\n", argv[i]);
    
    char *type_str;
    switch(st.type){
        case T_FILE: type_str = "Regular File"; break;
        case T_DIR:  type_str = "Directory"; break;
        case T_DEVICE: type_str = "Device"; break;
        case T_SYMLINK: type_str = "Symbolic Link"; break;
        default: type_str = "Unknown"; break;
    }
    printf("Type: %s\n", type_str);
    printf("Inode: %d\n", st.ino);
    printf("Links: %d\n", st.nlink);
    // Cast to int for compatibility with xv6 printf format specifiers
    printf("Size: %d\n", (int)st.size);
    
    close(fd);
  }
  exit(0);
}