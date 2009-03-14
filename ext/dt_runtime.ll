; ModuleID = 'esoteric:dt:runtime'

%struct.ESONODE = type { i32, %struct.ESONODE* }
@dt.stack_top = internal global %struct.ESONODE* null
@"\01LC" = internal constant [4 x i8] c"%d\0A\00"

define i32 @main(i32 %argc, i8** %argv) nounwind {
entry:
    call void @dt.stack_push(i32 2)
    call void @dt.stack_push(i32 5)
    %val1 = call i32 @dt.stack_pop()
    call i32 (i8*, ...)* @printf(i8* getelementptr ([4 x i8]* @"\01LC", i32 0, i32 0), i32 %val1)
    %val2 = call i32 @dt.stack_pop()
    call i32 (i8*, ...)* @printf(i8* getelementptr ([4 x i8]* @"\01LC", i32 0, i32 0), i32 %val2)
    ret i32 0
}

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

declare i32 @printf(i8*, ...)
