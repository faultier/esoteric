#include "stack.h"
#include <stdio.h>

int main(int argc, char **argv) {
    st_push(1);
    st_push(3);
    st_dup();
    st_copy(2);
    printf("%d\n", st_pop());
    printf("%d\n", st_pop());
    printf("%d\n", st_pop());
    printf("%d\n", st_pop());
    return 0;
}
