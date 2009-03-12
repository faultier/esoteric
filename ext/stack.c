#include "stack.h"

static ESONODE* stack_top = NULL;

void st_push(int val) {
    ESONODE *node = (ESONODE*)malloc(sizeof(ESONODE));
    node->value = val;
    node->next = stack_top;
    stack_top = node;
}

int st_pop() {
    int val = stack_top->value;
    ESONODE *p = stack_top;
    stack_top = stack_top->next;
    free(p);
    return val;
}

void st_dup() {
    int val = st_pop();
    st_push(val);
    st_push(val);
}

void st_copy(int i) {
    ESONODE *node = stack_top;
    while (i > 0) {
        node = node->next;
        i--;
    }
    st_push(node->value);
}
