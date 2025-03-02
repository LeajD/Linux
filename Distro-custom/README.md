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


**sys.S**  
   - This assembly file implements low-level system call wrappers.  
   - It defines global symbols (write, read, execve, fork, real_waitid, _exit) that serve as entry points for invoking the corresponding Linux system calls using inline assembly (via the syscall instruction).  
   - These wrappers provide a minimalistic interface for user-space programs to interact with the kernel (for I/O, process creation, execution, waiting on processes, and termination).

**shell.c**  
   - This C source file implements a basic shell program.  
   - It uses the system call wrappers defined in sys.S to perform core functions:
     - **Input/Output:** The shell prints a prompt (using write) and reads a command from the user (using read).
     - **Process Management:** For every command entered, it calls fork (to create a child process) and then execve (to replace the child’s image with a new executable based on the command).  
     - **Waiting:** The parent process waits for the child process to complete using a custom wait function (real_waitid).  
     - **Termination:** It finally calls _exit to cleanly exit the shell.
     



# Kenerl compilation process
- Compiler (GCC) -> converts C to Assembly 
- Assembler -> converts Assembly to Machine code
- Linker -> creates final kernel binary
- Bootloader -> loads kernel into memory
- CPU Execution -> runs machine code instructions


# Kernel developing/debugging process
- you can use "qemu" to virtualize custom kernel environment
- you can then use "gdb" (GNU Debugger) in order to debug live custom-kernel environment and it's function (or test custom device drivers etc.) written in C (run "b $function" in order to change context inside gdb) 

