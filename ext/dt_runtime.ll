; ModuleID = 'esoteric:dt:runtime'

%struct.ESONODE = type { i32, %struct.ESONODE* }
@dt.stack_top = internal global %struct.ESONODE* null

define void @dt.stack_push(i32 %val) {
entry:
    %node       = malloc %struct.ESONODE
	%val_ptr    = bitcast %struct.ESONODE* %node to i32*
	store i32 %val, i32* %val_ptr, align 4
	%top        = load %struct.ESONODE** @dt.stack_top, align 4
	%next       = getelementptr %struct.ESONODE* %node, i32 0, i32 1
	store %struct.ESONODE* %top, %struct.ESONODE** %next, align 4
	store %struct.ESONODE* %node, %struct.ESONODE** @dt.stack_top, align 4
    ret void
}

define i32 @dt.stack_pop() {
entry:
    %top        = load %struct.ESONODE** @dt.stack_top, align 4 
    %val_ptr    = getelementptr %struct.ESONODE* %top, i32 0, i32 0
    %val        = load i32* %val_ptr, align 4
    %next_ptr   = getelementptr %struct.ESONODE* %top, i32 0, i32 1
    %next       = load %struct.ESONODE** %next_ptr, align 4
    store %struct.ESONODE* %next, %struct.ESONODE** @dt.stack_top, align 4
    free %struct.ESONODE* %top
    ret i32 %val
}

define void @dt.stack_dup() {
entry:
    %top        = load %struct.ESONODE** @dt.stack_top, align 4
    %val_ptr    = getelementptr %struct.ESONODE* %top, i32 0, i32 0
    %val        = load i32* %val_ptr, align 4
    call void @dt.stack_push(i32 %val)
    ret void
}

define void @dt.stack_copy(i32 %i) {
entry:
    %i_ptr      = alloca i32
    %node_ptr   = alloca %struct.ESONODE*
    store i32 %i, i32* %i_ptr
    %top        = load %struct.ESONODE** @dt.stack_top, align 4
    store %struct.ESONODE* %top, %struct.ESONODE** %node_ptr, align 4
    br label %loop_cond
loop_body:
    %node       = load %struct.ESONODE** %node_ptr, align 4
    %next_ptr   = getelementptr %struct.ESONODE* %node, i32 0, i32 1
    %next       = load %struct.ESONODE** %next_ptr, align 4
    store %struct.ESONODE* %next, %struct.ESONODE** %node_ptr, align 4
    %j          = load i32* %i_ptr, align 4
    %j2         = sub i32 %j, 1
    store i32 %j2, i32* %i_ptr, align 4
    br label %loop_cond
loop_cond:
    %k          = load i32* %i_ptr, align 4
    %cond       = icmp sgt i32 %k, 0
    br i1 %cond, label %loop_body, label %return
return:
    %_node      = load %struct.ESONODE** %node_ptr, align 4
    %val_ptr    = getelementptr %struct.ESONODE* %_node, i32 0, i32 0
    %val        = load i32* %val_ptr, align 4
    call void @dt.stack_push(i32 %val)
    ret void
}
