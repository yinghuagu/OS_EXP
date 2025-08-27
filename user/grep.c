// Simple grep. Only supports ^ . * $ operators.
// Supports case-insensitive search (-i).

#include "kernel/types.h"
#include "kernel/stat.h"
#include "kernel/fcntl.h"
#include "user/user.h"

char buf[1024];
int match(char*, char*);
int ignore_case = 0; // Global flag for case-insensitivity

// Helper: Convert character to lower case
char to_lower(char c) {
  if (c >= 'A' && c <= 'Z') return c + 32;
  return c;
}

void
grep(char *pattern, int fd)
{
  int n, m;
  char *p, *q;

  m = 0;
  while((n = read(fd, buf+m, sizeof(buf)-m-1)) > 0){
    m += n;
    buf[m] = '\0';
    p = buf;
    while((q = strchr(p, '\n')) != 0){
      *q = 0;
      if(match(pattern, p)){
        *q = '\n';
        write(1, p, q+1 - p);
      }
      *q = '\n';
      p = q+1;
    }
    if(m > 0){
      m -= p - buf;
      memmove(buf, p, m);
    }
  }
}

int
main(int argc, char *argv[])
{
  int fd, i;
  char *pattern;
  int idx = 1;

  if(argc <= 1){
    fprintf(2, "usage: grep [-i] pattern [file ...]\n");
    exit(1);
  }

  // Parse -i flag
  if(strcmp(argv[1], "-i") == 0){
    if(argc <= 2){
        fprintf(2, "usage: grep [-i] pattern [file ...]\n");
        exit(1);
    }
    ignore_case = 1;
    idx = 2;
  }

  pattern = argv[idx];

  if(argc <= idx + 1){
    grep(pattern, 0);
    exit(0);
  }

  for(i = idx + 1; i < argc; i++){
    if((fd = open(argv[i], O_RDONLY)) < 0){
      printf("grep: cannot open %s\n", argv[i]);
      exit(1);
    }
    grep(pattern, fd);
    close(fd);
  }
  exit(0);
}

// Regexp matcher from Kernighan & Pike

int matchhere(char*, char*);
int matchstar(int, char*, char*);

int
match(char *re, char *text)
{
  if(re[0] == '^')
    return matchhere(re+1, text);
  do{  // must look at empty string
    if(matchhere(re, text))
      return 1;
  }while(*text++ != '\0');
  return 0;
}

// matchhere: search for re at beginning of text
int matchhere(char *re, char *text)
{
  if(re[0] == '\0')
    return 1;
  if(re[1] == '*')
    return matchstar(re[0], re+2, text);
  if(re[0] == '$' && re[1] == '\0')
    return *text == '\0';
  
  // Compare characters with case-sensitivity check
  if(*text!='\0' && (re[0]=='.' || (ignore_case ? (to_lower(re[0])==to_lower(*text)) : (re[0]==*text))))
    return matchhere(re+1, text+1);
  return 0;
}

// matchstar: search for c*re at beginning of text
int matchstar(int c, char *re, char *text)
{
  do{  // a * matches zero or more instances
    if(matchhere(re, text))
      return 1;
  }while(*text!='\0' && (c=='.' || (ignore_case ? (to_lower(*text++)==to_lower(c)) : (*text++==c))));
  return 0;
}