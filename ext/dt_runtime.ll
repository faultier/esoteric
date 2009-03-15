; ModuleID = 'esoteric:dt:runtime'

%struct.ESONODE = type { i32, %struct.ESONODE* }
@dt.stack_top = internal global %struct.ESONODE* null

define void @dt.stack_push(i32 %val) {
entry:
    %node       = malloc %struct.ESONODE
	%val_ptr    = bitcast %struct.ESONODE* %node to i32*
	store i32 %val, i32* %val_ptr, align 4
	%top    = load %struct.ESONODE** @dt.stack_top, align 4
	%next   = getelementptr %struct.ESONODE* %node, i32 0, i32 1
	store %struct.ESONODE* %top, %struct.ESONODE** %next, align 4
	store %struct.ESONODE* %node, %struct.ESONODE** @dt.stack_top, align 4
    ret void
}

define i32 @dt.stack_pop() {
entry:
   %top         = load %struct.ESONODE** @dt.stack_top, align 4 
   %val_ptr     = getelementptr %struct.ESONODE* %top, i32 0, i32 0
   %val         = load i32* %val_ptr, align 4
   %next_ptr    = getelementptr %struct.ESONODE* %top, i32 0, i32 1
   %next        = load %struct.ESONODE** %next_ptr, align 4
   store %struct.ESONODE* %next, %struct.ESONODE** @dt.stack_top, align 4
   free %struct.ESONODE* %top
   ret i32 %val
}
