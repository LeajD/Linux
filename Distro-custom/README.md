# Linux


# build your own Linux distro (custom kernel, shell, syscalls)
1. download tar -> https://www.kernel.org/
2. install required pacakges for kernel compilation
3. generate .config file for kernel 
$ make tinyconfig or ... 
$ ... make menuconfig -j12
$ make -j4
To run kernel:
$ qemu-system-x86_64 -kernel arch/x86/boot/bzImage
4. write custom shell (shell.c file) (-static for not dynamic executable) and build it:
$ gcc shell.c -o shell.o
5. write custom assembly system calls for our shell functionalities (sys.S file) and build it:
$ as sys.C
6. link shell with assembly system calls:
$ ld -o shell shell.o a.out --entry main -z noexecstack
To debug shell:
gdb ./shell
7. Create CPIO archive of the init file (preparing initramfs (initial RAM filesystem) )
$ echo shell | cpio -H newc -o > init.cpio

cd cloned/linux
make isoimage FDARGS="initrd=/init.cpio" FDINITRD="our-custom-init-path.cpio"
/init.cpio is the path on the iso image that will be executed as init service (we will run our our-custom.init.cpio as this file)
above command will generate .iso image for our distro

8. Include "lua" in our distro (programming language)
$ wget lua tar gz
// go into lua/src/
// change Makefile "MYLDFLAGS=-static"
$ make

9. Include "lua" as example tool to interact inside our distro
create "files" file to contain which file we want to include in our distro (we will reference this file in next stage)
"init
lua"

$ cat files | cpio -H -newc -o > init.cpio
go to directory with kernel code
$ make isoimage FDARGS="initrd=/init.cpio" FDINITRD="our-custom-init-path.cpio"
$ qemu-system-86_64 -cdrom arch/x86/boot/image.iso


---     


# Explaination of syscalls, shell.c and sys.S:

The **sys.S** file is an assembly source file that defines low-level wrappers for system calls. Here’s what it does and where it fits in the overall picture:

1. **Purpose and Content:**  
   - The file defines routines such as `write`, `read`, `execve`, `fork`, `real_waitid`, and `_exit`.  
   - Each routine sets up the appropriate system call number (placed in register RAX) and then executes the `syscall` instruction. This instruction is the gateway from user mode to kernel mode.

2. **Where It Goes:**  
   - When you compile your custom Linux distribution (or a minimal user-space environment) that includes **sys.S** along with your other files (like **shell.c**), these assembly routines get assembled into object code and then linked into the final executable (for example, your shell program).
   - They become part of your user-space binary, providing the means for the program to request services from the kernel.
   - They do not get “installed” into the kernel image per se; rather, they are part of the user-level support library that interacts with the kernel.

3. **Interaction with User/Kernel:**  
   - When your shell (or any program using these routines) calls a function like `write`, it invokes the version defined in **sys.S**.  
   - This function places the system call number in RAX (in this case, 1 for `write`), then executes the `syscall` instruction.  
   - That instruction transfers control from user space to the kernel, which then processes the request (writing data in this example) and returns to user space.
   - This mechanism ensures that even though your code is running in user space, it can safely request services (like I/O, process management, etc.) provided by the kernel.

In summary, **sys.S** is part of your custom environment that implements the basic interface for making system calls. It’s compiled and linked into your user-space program and functions as the bridge for invoking kernel services via the `syscall` instruction.




# Kernel compilation process
- Compiler (GCC) -> converts C to Assembly 
- Assembler -> converts Assembly to Machine code
- Linker -> creates final kernel binary
- Bootloader -> loads kernel into memory
- CPU Execution -> runs machine code instructions


# Kernel developing/debugging process
- you can use "qemu" to virtualize custom kernel environment
- you can then use "gdb" (GNU Debugger) in order to debug live custom-kernel environment and it's function (or test custom device drivers etc.) written in C (run "b $function" in order to change context inside gdb) 
