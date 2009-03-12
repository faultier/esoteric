#include <stdlib.h>

#ifndef __ESOSTACK__
#define __ESOSTACK__
typedef struct __node ESONODE;
struct __node {
    int value;
    ESONODE* next;
};

//void st_insert(ESONODE* p);
//void st_delete(ESONODE* p);
void st_push(int val);
int st_pop();
void st_dup();
void st_copy(int i);
#endif
