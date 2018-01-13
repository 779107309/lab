
obj/user/evilhello：     文件格式 elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 19 00 00 00       	call   80004a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	// try to print the kernel entry point as a string!  mua ha ha!
	sys_cputs((char*)0xf010000c, 100);
  800039:	6a 64                	push   $0x64
  80003b:	68 0c 00 10 f0       	push   $0xf010000c
  800040:	e8 60 00 00 00       	call   8000a5 <sys_cputs>
}
  800045:	83 c4 10             	add    $0x10,%esp
  800048:	c9                   	leave  
  800049:	c3                   	ret    

0080004a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004a:	55                   	push   %ebp
  80004b:	89 e5                	mov    %esp,%ebp
  80004d:	56                   	push   %esi
  80004e:	53                   	push   %ebx
  80004f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800052:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t i = sys_getenvid();
  800055:	e8 c9 00 00 00       	call   800123 <sys_getenvid>
    thisenv = &envs[ENVX(i)];
  80005a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005f:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800062:	c1 e0 05             	shl    $0x5,%eax
  800065:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006a:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006f:	85 db                	test   %ebx,%ebx
  800071:	7e 07                	jle    80007a <libmain+0x30>
		binaryname = argv[0];
  800073:	8b 06                	mov    (%esi),%eax
  800075:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80007a:	83 ec 08             	sub    $0x8,%esp
  80007d:	56                   	push   %esi
  80007e:	53                   	push   %ebx
  80007f:	e8 af ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800084:	e8 0a 00 00 00       	call   800093 <exit>
}
  800089:	83 c4 10             	add    $0x10,%esp
  80008c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008f:	5b                   	pop    %ebx
  800090:	5e                   	pop    %esi
  800091:	5d                   	pop    %ebp
  800092:	c3                   	ret    

00800093 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800093:	55                   	push   %ebp
  800094:	89 e5                	mov    %esp,%ebp
  800096:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800099:	6a 00                	push   $0x0
  80009b:	e8 42 00 00 00       	call   8000e2 <sys_env_destroy>
}
  8000a0:	83 c4 10             	add    $0x10,%esp
  8000a3:	c9                   	leave  
  8000a4:	c3                   	ret    

008000a5 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a5:	55                   	push   %ebp
  8000a6:	89 e5                	mov    %esp,%ebp
  8000a8:	57                   	push   %edi
  8000a9:	56                   	push   %esi
  8000aa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b3:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b6:	89 c3                	mov    %eax,%ebx
  8000b8:	89 c7                	mov    %eax,%edi
  8000ba:	89 c6                	mov    %eax,%esi
  8000bc:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000be:	5b                   	pop    %ebx
  8000bf:	5e                   	pop    %esi
  8000c0:	5f                   	pop    %edi
  8000c1:	5d                   	pop    %ebp
  8000c2:	c3                   	ret    

008000c3 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c3:	55                   	push   %ebp
  8000c4:	89 e5                	mov    %esp,%ebp
  8000c6:	57                   	push   %edi
  8000c7:	56                   	push   %esi
  8000c8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8000ce:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d3:	89 d1                	mov    %edx,%ecx
  8000d5:	89 d3                	mov    %edx,%ebx
  8000d7:	89 d7                	mov    %edx,%edi
  8000d9:	89 d6                	mov    %edx,%esi
  8000db:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000dd:	5b                   	pop    %ebx
  8000de:	5e                   	pop    %esi
  8000df:	5f                   	pop    %edi
  8000e0:	5d                   	pop    %ebp
  8000e1:	c3                   	ret    

008000e2 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e2:	55                   	push   %ebp
  8000e3:	89 e5                	mov    %esp,%ebp
  8000e5:	57                   	push   %edi
  8000e6:	56                   	push   %esi
  8000e7:	53                   	push   %ebx
  8000e8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000eb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f0:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f8:	89 cb                	mov    %ecx,%ebx
  8000fa:	89 cf                	mov    %ecx,%edi
  8000fc:	89 ce                	mov    %ecx,%esi
  8000fe:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800100:	85 c0                	test   %eax,%eax
  800102:	7e 17                	jle    80011b <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800104:	83 ec 0c             	sub    $0xc,%esp
  800107:	50                   	push   %eax
  800108:	6a 03                	push   $0x3
  80010a:	68 6a 0e 80 00       	push   $0x800e6a
  80010f:	6a 23                	push   $0x23
  800111:	68 87 0e 80 00       	push   $0x800e87
  800116:	e8 27 00 00 00       	call   800142 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80011b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80011e:	5b                   	pop    %ebx
  80011f:	5e                   	pop    %esi
  800120:	5f                   	pop    %edi
  800121:	5d                   	pop    %ebp
  800122:	c3                   	ret    

00800123 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800123:	55                   	push   %ebp
  800124:	89 e5                	mov    %esp,%ebp
  800126:	57                   	push   %edi
  800127:	56                   	push   %esi
  800128:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800129:	ba 00 00 00 00       	mov    $0x0,%edx
  80012e:	b8 02 00 00 00       	mov    $0x2,%eax
  800133:	89 d1                	mov    %edx,%ecx
  800135:	89 d3                	mov    %edx,%ebx
  800137:	89 d7                	mov    %edx,%edi
  800139:	89 d6                	mov    %edx,%esi
  80013b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80013d:	5b                   	pop    %ebx
  80013e:	5e                   	pop    %esi
  80013f:	5f                   	pop    %edi
  800140:	5d                   	pop    %ebp
  800141:	c3                   	ret    

00800142 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800142:	55                   	push   %ebp
  800143:	89 e5                	mov    %esp,%ebp
  800145:	56                   	push   %esi
  800146:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800147:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80014a:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800150:	e8 ce ff ff ff       	call   800123 <sys_getenvid>
  800155:	83 ec 0c             	sub    $0xc,%esp
  800158:	ff 75 0c             	pushl  0xc(%ebp)
  80015b:	ff 75 08             	pushl  0x8(%ebp)
  80015e:	56                   	push   %esi
  80015f:	50                   	push   %eax
  800160:	68 98 0e 80 00       	push   $0x800e98
  800165:	e8 b1 00 00 00       	call   80021b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80016a:	83 c4 18             	add    $0x18,%esp
  80016d:	53                   	push   %ebx
  80016e:	ff 75 10             	pushl  0x10(%ebp)
  800171:	e8 54 00 00 00       	call   8001ca <vcprintf>
	cprintf("\n");
  800176:	c7 04 24 bc 0e 80 00 	movl   $0x800ebc,(%esp)
  80017d:	e8 99 00 00 00       	call   80021b <cprintf>
  800182:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800185:	cc                   	int3   
  800186:	eb fd                	jmp    800185 <_panic+0x43>

00800188 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800188:	55                   	push   %ebp
  800189:	89 e5                	mov    %esp,%ebp
  80018b:	53                   	push   %ebx
  80018c:	83 ec 04             	sub    $0x4,%esp
  80018f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800192:	8b 13                	mov    (%ebx),%edx
  800194:	8d 42 01             	lea    0x1(%edx),%eax
  800197:	89 03                	mov    %eax,(%ebx)
  800199:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80019c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001a0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001a5:	75 1a                	jne    8001c1 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001a7:	83 ec 08             	sub    $0x8,%esp
  8001aa:	68 ff 00 00 00       	push   $0xff
  8001af:	8d 43 08             	lea    0x8(%ebx),%eax
  8001b2:	50                   	push   %eax
  8001b3:	e8 ed fe ff ff       	call   8000a5 <sys_cputs>
		b->idx = 0;
  8001b8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001be:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001c1:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001c5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001c8:	c9                   	leave  
  8001c9:	c3                   	ret    

008001ca <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001ca:	55                   	push   %ebp
  8001cb:	89 e5                	mov    %esp,%ebp
  8001cd:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001d3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001da:	00 00 00 
	b.cnt = 0;
  8001dd:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001e4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001e7:	ff 75 0c             	pushl  0xc(%ebp)
  8001ea:	ff 75 08             	pushl  0x8(%ebp)
  8001ed:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001f3:	50                   	push   %eax
  8001f4:	68 88 01 80 00       	push   $0x800188
  8001f9:	e8 1a 01 00 00       	call   800318 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001fe:	83 c4 08             	add    $0x8,%esp
  800201:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800207:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80020d:	50                   	push   %eax
  80020e:	e8 92 fe ff ff       	call   8000a5 <sys_cputs>

	return b.cnt;
}
  800213:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800219:	c9                   	leave  
  80021a:	c3                   	ret    

0080021b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80021b:	55                   	push   %ebp
  80021c:	89 e5                	mov    %esp,%ebp
  80021e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800221:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800224:	50                   	push   %eax
  800225:	ff 75 08             	pushl  0x8(%ebp)
  800228:	e8 9d ff ff ff       	call   8001ca <vcprintf>
	va_end(ap);

	return cnt;
}
  80022d:	c9                   	leave  
  80022e:	c3                   	ret    

0080022f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80022f:	55                   	push   %ebp
  800230:	89 e5                	mov    %esp,%ebp
  800232:	57                   	push   %edi
  800233:	56                   	push   %esi
  800234:	53                   	push   %ebx
  800235:	83 ec 1c             	sub    $0x1c,%esp
  800238:	89 c7                	mov    %eax,%edi
  80023a:	89 d6                	mov    %edx,%esi
  80023c:	8b 45 08             	mov    0x8(%ebp),%eax
  80023f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800242:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800245:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800248:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80024b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800250:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800253:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800256:	39 d3                	cmp    %edx,%ebx
  800258:	72 05                	jb     80025f <printnum+0x30>
  80025a:	39 45 10             	cmp    %eax,0x10(%ebp)
  80025d:	77 45                	ja     8002a4 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80025f:	83 ec 0c             	sub    $0xc,%esp
  800262:	ff 75 18             	pushl  0x18(%ebp)
  800265:	8b 45 14             	mov    0x14(%ebp),%eax
  800268:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80026b:	53                   	push   %ebx
  80026c:	ff 75 10             	pushl  0x10(%ebp)
  80026f:	83 ec 08             	sub    $0x8,%esp
  800272:	ff 75 e4             	pushl  -0x1c(%ebp)
  800275:	ff 75 e0             	pushl  -0x20(%ebp)
  800278:	ff 75 dc             	pushl  -0x24(%ebp)
  80027b:	ff 75 d8             	pushl  -0x28(%ebp)
  80027e:	e8 4d 09 00 00       	call   800bd0 <__udivdi3>
  800283:	83 c4 18             	add    $0x18,%esp
  800286:	52                   	push   %edx
  800287:	50                   	push   %eax
  800288:	89 f2                	mov    %esi,%edx
  80028a:	89 f8                	mov    %edi,%eax
  80028c:	e8 9e ff ff ff       	call   80022f <printnum>
  800291:	83 c4 20             	add    $0x20,%esp
  800294:	eb 18                	jmp    8002ae <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800296:	83 ec 08             	sub    $0x8,%esp
  800299:	56                   	push   %esi
  80029a:	ff 75 18             	pushl  0x18(%ebp)
  80029d:	ff d7                	call   *%edi
  80029f:	83 c4 10             	add    $0x10,%esp
  8002a2:	eb 03                	jmp    8002a7 <printnum+0x78>
  8002a4:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002a7:	83 eb 01             	sub    $0x1,%ebx
  8002aa:	85 db                	test   %ebx,%ebx
  8002ac:	7f e8                	jg     800296 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002ae:	83 ec 08             	sub    $0x8,%esp
  8002b1:	56                   	push   %esi
  8002b2:	83 ec 04             	sub    $0x4,%esp
  8002b5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002b8:	ff 75 e0             	pushl  -0x20(%ebp)
  8002bb:	ff 75 dc             	pushl  -0x24(%ebp)
  8002be:	ff 75 d8             	pushl  -0x28(%ebp)
  8002c1:	e8 3a 0a 00 00       	call   800d00 <__umoddi3>
  8002c6:	83 c4 14             	add    $0x14,%esp
  8002c9:	0f be 80 be 0e 80 00 	movsbl 0x800ebe(%eax),%eax
  8002d0:	50                   	push   %eax
  8002d1:	ff d7                	call   *%edi
}
  8002d3:	83 c4 10             	add    $0x10,%esp
  8002d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002d9:	5b                   	pop    %ebx
  8002da:	5e                   	pop    %esi
  8002db:	5f                   	pop    %edi
  8002dc:	5d                   	pop    %ebp
  8002dd:	c3                   	ret    

008002de <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002de:	55                   	push   %ebp
  8002df:	89 e5                	mov    %esp,%ebp
  8002e1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002e4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002e8:	8b 10                	mov    (%eax),%edx
  8002ea:	3b 50 04             	cmp    0x4(%eax),%edx
  8002ed:	73 0a                	jae    8002f9 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002ef:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002f2:	89 08                	mov    %ecx,(%eax)
  8002f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f7:	88 02                	mov    %al,(%edx)
}
  8002f9:	5d                   	pop    %ebp
  8002fa:	c3                   	ret    

008002fb <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002fb:	55                   	push   %ebp
  8002fc:	89 e5                	mov    %esp,%ebp
  8002fe:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800301:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800304:	50                   	push   %eax
  800305:	ff 75 10             	pushl  0x10(%ebp)
  800308:	ff 75 0c             	pushl  0xc(%ebp)
  80030b:	ff 75 08             	pushl  0x8(%ebp)
  80030e:	e8 05 00 00 00       	call   800318 <vprintfmt>
	va_end(ap);
}
  800313:	83 c4 10             	add    $0x10,%esp
  800316:	c9                   	leave  
  800317:	c3                   	ret    

00800318 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800318:	55                   	push   %ebp
  800319:	89 e5                	mov    %esp,%ebp
  80031b:	57                   	push   %edi
  80031c:	56                   	push   %esi
  80031d:	53                   	push   %ebx
  80031e:	83 ec 2c             	sub    $0x2c,%esp
  800321:	8b 75 08             	mov    0x8(%ebp),%esi
  800324:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800327:	8b 7d 10             	mov    0x10(%ebp),%edi
  80032a:	eb 12                	jmp    80033e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80032c:	85 c0                	test   %eax,%eax
  80032e:	0f 84 a9 04 00 00    	je     8007dd <vprintfmt+0x4c5>
				return;
			putch(ch, putdat);
  800334:	83 ec 08             	sub    $0x8,%esp
  800337:	53                   	push   %ebx
  800338:	50                   	push   %eax
  800339:	ff d6                	call   *%esi
  80033b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80033e:	83 c7 01             	add    $0x1,%edi
  800341:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800345:	83 f8 25             	cmp    $0x25,%eax
  800348:	75 e2                	jne    80032c <vprintfmt+0x14>
  80034a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80034e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800355:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80035c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800363:	b9 00 00 00 00       	mov    $0x0,%ecx
  800368:	eb 07                	jmp    800371 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036a:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80036d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800371:	8d 47 01             	lea    0x1(%edi),%eax
  800374:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800377:	0f b6 07             	movzbl (%edi),%eax
  80037a:	0f b6 d0             	movzbl %al,%edx
  80037d:	83 e8 23             	sub    $0x23,%eax
  800380:	3c 55                	cmp    $0x55,%al
  800382:	0f 87 3a 04 00 00    	ja     8007c2 <vprintfmt+0x4aa>
  800388:	0f b6 c0             	movzbl %al,%eax
  80038b:	ff 24 85 60 0f 80 00 	jmp    *0x800f60(,%eax,4)
  800392:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800395:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800399:	eb d6                	jmp    800371 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80039e:	b8 00 00 00 00       	mov    $0x0,%eax
  8003a3:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003a6:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003a9:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003ad:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003b0:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003b3:	83 f9 09             	cmp    $0x9,%ecx
  8003b6:	77 3f                	ja     8003f7 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003b8:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003bb:	eb e9                	jmp    8003a6 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c0:	8b 00                	mov    (%eax),%eax
  8003c2:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c8:	8d 40 04             	lea    0x4(%eax),%eax
  8003cb:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003d1:	eb 2a                	jmp    8003fd <vprintfmt+0xe5>
  8003d3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003d6:	85 c0                	test   %eax,%eax
  8003d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8003dd:	0f 49 d0             	cmovns %eax,%edx
  8003e0:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003e6:	eb 89                	jmp    800371 <vprintfmt+0x59>
  8003e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003eb:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003f2:	e9 7a ff ff ff       	jmp    800371 <vprintfmt+0x59>
  8003f7:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003fa:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003fd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800401:	0f 89 6a ff ff ff    	jns    800371 <vprintfmt+0x59>
				width = precision, precision = -1;
  800407:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80040a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80040d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800414:	e9 58 ff ff ff       	jmp    800371 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800419:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80041f:	e9 4d ff ff ff       	jmp    800371 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800424:	8b 45 14             	mov    0x14(%ebp),%eax
  800427:	8d 78 04             	lea    0x4(%eax),%edi
  80042a:	83 ec 08             	sub    $0x8,%esp
  80042d:	53                   	push   %ebx
  80042e:	ff 30                	pushl  (%eax)
  800430:	ff d6                	call   *%esi
			break;
  800432:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800435:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800438:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80043b:	e9 fe fe ff ff       	jmp    80033e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800440:	8b 45 14             	mov    0x14(%ebp),%eax
  800443:	8d 78 04             	lea    0x4(%eax),%edi
  800446:	8b 00                	mov    (%eax),%eax
  800448:	99                   	cltd   
  800449:	31 d0                	xor    %edx,%eax
  80044b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80044d:	83 f8 07             	cmp    $0x7,%eax
  800450:	7f 0b                	jg     80045d <vprintfmt+0x145>
  800452:	8b 14 85 c0 10 80 00 	mov    0x8010c0(,%eax,4),%edx
  800459:	85 d2                	test   %edx,%edx
  80045b:	75 1b                	jne    800478 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  80045d:	50                   	push   %eax
  80045e:	68 d6 0e 80 00       	push   $0x800ed6
  800463:	53                   	push   %ebx
  800464:	56                   	push   %esi
  800465:	e8 91 fe ff ff       	call   8002fb <printfmt>
  80046a:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80046d:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800470:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800473:	e9 c6 fe ff ff       	jmp    80033e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800478:	52                   	push   %edx
  800479:	68 df 0e 80 00       	push   $0x800edf
  80047e:	53                   	push   %ebx
  80047f:	56                   	push   %esi
  800480:	e8 76 fe ff ff       	call   8002fb <printfmt>
  800485:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800488:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80048e:	e9 ab fe ff ff       	jmp    80033e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800493:	8b 45 14             	mov    0x14(%ebp),%eax
  800496:	83 c0 04             	add    $0x4,%eax
  800499:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80049c:	8b 45 14             	mov    0x14(%ebp),%eax
  80049f:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004a1:	85 ff                	test   %edi,%edi
  8004a3:	b8 cf 0e 80 00       	mov    $0x800ecf,%eax
  8004a8:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004ab:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004af:	0f 8e 94 00 00 00    	jle    800549 <vprintfmt+0x231>
  8004b5:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004b9:	0f 84 98 00 00 00    	je     800557 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004bf:	83 ec 08             	sub    $0x8,%esp
  8004c2:	ff 75 d0             	pushl  -0x30(%ebp)
  8004c5:	57                   	push   %edi
  8004c6:	e8 9a 03 00 00       	call   800865 <strnlen>
  8004cb:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004ce:	29 c1                	sub    %eax,%ecx
  8004d0:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8004d3:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004d6:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004da:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004dd:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004e0:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e2:	eb 0f                	jmp    8004f3 <vprintfmt+0x1db>
					putch(padc, putdat);
  8004e4:	83 ec 08             	sub    $0x8,%esp
  8004e7:	53                   	push   %ebx
  8004e8:	ff 75 e0             	pushl  -0x20(%ebp)
  8004eb:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ed:	83 ef 01             	sub    $0x1,%edi
  8004f0:	83 c4 10             	add    $0x10,%esp
  8004f3:	85 ff                	test   %edi,%edi
  8004f5:	7f ed                	jg     8004e4 <vprintfmt+0x1cc>
  8004f7:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004fa:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004fd:	85 c9                	test   %ecx,%ecx
  8004ff:	b8 00 00 00 00       	mov    $0x0,%eax
  800504:	0f 49 c1             	cmovns %ecx,%eax
  800507:	29 c1                	sub    %eax,%ecx
  800509:	89 75 08             	mov    %esi,0x8(%ebp)
  80050c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80050f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800512:	89 cb                	mov    %ecx,%ebx
  800514:	eb 4d                	jmp    800563 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800516:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80051a:	74 1b                	je     800537 <vprintfmt+0x21f>
  80051c:	0f be c0             	movsbl %al,%eax
  80051f:	83 e8 20             	sub    $0x20,%eax
  800522:	83 f8 5e             	cmp    $0x5e,%eax
  800525:	76 10                	jbe    800537 <vprintfmt+0x21f>
					putch('?', putdat);
  800527:	83 ec 08             	sub    $0x8,%esp
  80052a:	ff 75 0c             	pushl  0xc(%ebp)
  80052d:	6a 3f                	push   $0x3f
  80052f:	ff 55 08             	call   *0x8(%ebp)
  800532:	83 c4 10             	add    $0x10,%esp
  800535:	eb 0d                	jmp    800544 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  800537:	83 ec 08             	sub    $0x8,%esp
  80053a:	ff 75 0c             	pushl  0xc(%ebp)
  80053d:	52                   	push   %edx
  80053e:	ff 55 08             	call   *0x8(%ebp)
  800541:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800544:	83 eb 01             	sub    $0x1,%ebx
  800547:	eb 1a                	jmp    800563 <vprintfmt+0x24b>
  800549:	89 75 08             	mov    %esi,0x8(%ebp)
  80054c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80054f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800552:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800555:	eb 0c                	jmp    800563 <vprintfmt+0x24b>
  800557:	89 75 08             	mov    %esi,0x8(%ebp)
  80055a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80055d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800560:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800563:	83 c7 01             	add    $0x1,%edi
  800566:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80056a:	0f be d0             	movsbl %al,%edx
  80056d:	85 d2                	test   %edx,%edx
  80056f:	74 23                	je     800594 <vprintfmt+0x27c>
  800571:	85 f6                	test   %esi,%esi
  800573:	78 a1                	js     800516 <vprintfmt+0x1fe>
  800575:	83 ee 01             	sub    $0x1,%esi
  800578:	79 9c                	jns    800516 <vprintfmt+0x1fe>
  80057a:	89 df                	mov    %ebx,%edi
  80057c:	8b 75 08             	mov    0x8(%ebp),%esi
  80057f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800582:	eb 18                	jmp    80059c <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800584:	83 ec 08             	sub    $0x8,%esp
  800587:	53                   	push   %ebx
  800588:	6a 20                	push   $0x20
  80058a:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80058c:	83 ef 01             	sub    $0x1,%edi
  80058f:	83 c4 10             	add    $0x10,%esp
  800592:	eb 08                	jmp    80059c <vprintfmt+0x284>
  800594:	89 df                	mov    %ebx,%edi
  800596:	8b 75 08             	mov    0x8(%ebp),%esi
  800599:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80059c:	85 ff                	test   %edi,%edi
  80059e:	7f e4                	jg     800584 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005a0:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8005a3:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005a9:	e9 90 fd ff ff       	jmp    80033e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005ae:	83 f9 01             	cmp    $0x1,%ecx
  8005b1:	7e 19                	jle    8005cc <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  8005b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b6:	8b 50 04             	mov    0x4(%eax),%edx
  8005b9:	8b 00                	mov    (%eax),%eax
  8005bb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005be:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c4:	8d 40 08             	lea    0x8(%eax),%eax
  8005c7:	89 45 14             	mov    %eax,0x14(%ebp)
  8005ca:	eb 38                	jmp    800604 <vprintfmt+0x2ec>
	else if (lflag)
  8005cc:	85 c9                	test   %ecx,%ecx
  8005ce:	74 1b                	je     8005eb <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8005d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d3:	8b 00                	mov    (%eax),%eax
  8005d5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d8:	89 c1                	mov    %eax,%ecx
  8005da:	c1 f9 1f             	sar    $0x1f,%ecx
  8005dd:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e3:	8d 40 04             	lea    0x4(%eax),%eax
  8005e6:	89 45 14             	mov    %eax,0x14(%ebp)
  8005e9:	eb 19                	jmp    800604 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8005eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ee:	8b 00                	mov    (%eax),%eax
  8005f0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f3:	89 c1                	mov    %eax,%ecx
  8005f5:	c1 f9 1f             	sar    $0x1f,%ecx
  8005f8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fe:	8d 40 04             	lea    0x4(%eax),%eax
  800601:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800604:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800607:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80060a:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80060f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800613:	0f 89 75 01 00 00    	jns    80078e <vprintfmt+0x476>
				putch('-', putdat);
  800619:	83 ec 08             	sub    $0x8,%esp
  80061c:	53                   	push   %ebx
  80061d:	6a 2d                	push   $0x2d
  80061f:	ff d6                	call   *%esi
				num = -(long long) num;
  800621:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800624:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800627:	f7 da                	neg    %edx
  800629:	83 d1 00             	adc    $0x0,%ecx
  80062c:	f7 d9                	neg    %ecx
  80062e:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800631:	b8 0a 00 00 00       	mov    $0xa,%eax
  800636:	e9 53 01 00 00       	jmp    80078e <vprintfmt+0x476>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80063b:	83 f9 01             	cmp    $0x1,%ecx
  80063e:	7e 18                	jle    800658 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800640:	8b 45 14             	mov    0x14(%ebp),%eax
  800643:	8b 10                	mov    (%eax),%edx
  800645:	8b 48 04             	mov    0x4(%eax),%ecx
  800648:	8d 40 08             	lea    0x8(%eax),%eax
  80064b:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80064e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800653:	e9 36 01 00 00       	jmp    80078e <vprintfmt+0x476>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800658:	85 c9                	test   %ecx,%ecx
  80065a:	74 1a                	je     800676 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  80065c:	8b 45 14             	mov    0x14(%ebp),%eax
  80065f:	8b 10                	mov    (%eax),%edx
  800661:	b9 00 00 00 00       	mov    $0x0,%ecx
  800666:	8d 40 04             	lea    0x4(%eax),%eax
  800669:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80066c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800671:	e9 18 01 00 00       	jmp    80078e <vprintfmt+0x476>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800676:	8b 45 14             	mov    0x14(%ebp),%eax
  800679:	8b 10                	mov    (%eax),%edx
  80067b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800680:	8d 40 04             	lea    0x4(%eax),%eax
  800683:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800686:	b8 0a 00 00 00       	mov    $0xa,%eax
  80068b:	e9 fe 00 00 00       	jmp    80078e <vprintfmt+0x476>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800690:	83 f9 01             	cmp    $0x1,%ecx
  800693:	7e 19                	jle    8006ae <vprintfmt+0x396>
		return va_arg(*ap, long long);
  800695:	8b 45 14             	mov    0x14(%ebp),%eax
  800698:	8b 50 04             	mov    0x4(%eax),%edx
  80069b:	8b 00                	mov    (%eax),%eax
  80069d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006a0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a6:	8d 40 08             	lea    0x8(%eax),%eax
  8006a9:	89 45 14             	mov    %eax,0x14(%ebp)
  8006ac:	eb 38                	jmp    8006e6 <vprintfmt+0x3ce>
	else if (lflag)
  8006ae:	85 c9                	test   %ecx,%ecx
  8006b0:	74 1b                	je     8006cd <vprintfmt+0x3b5>
		return va_arg(*ap, long);
  8006b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b5:	8b 00                	mov    (%eax),%eax
  8006b7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006ba:	89 c1                	mov    %eax,%ecx
  8006bc:	c1 f9 1f             	sar    $0x1f,%ecx
  8006bf:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c5:	8d 40 04             	lea    0x4(%eax),%eax
  8006c8:	89 45 14             	mov    %eax,0x14(%ebp)
  8006cb:	eb 19                	jmp    8006e6 <vprintfmt+0x3ce>
	else
		return va_arg(*ap, int);
  8006cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d0:	8b 00                	mov    (%eax),%eax
  8006d2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006d5:	89 c1                	mov    %eax,%ecx
  8006d7:	c1 f9 1f             	sar    $0x1f,%ecx
  8006da:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e0:	8d 40 04             	lea    0x4(%eax),%eax
  8006e3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
			goto number;

		// (unsigned) octal
		case 'o':
			num = getint(&ap, lflag);
  8006e6:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006e9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 8;
  8006ec:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;

		// (unsigned) octal
		case 'o':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006f1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006f5:	0f 89 93 00 00 00    	jns    80078e <vprintfmt+0x476>
				putch('-', putdat);
  8006fb:	83 ec 08             	sub    $0x8,%esp
  8006fe:	53                   	push   %ebx
  8006ff:	6a 2d                	push   $0x2d
  800701:	ff d6                	call   *%esi
				num = -(long long) num;
  800703:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800706:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800709:	f7 da                	neg    %edx
  80070b:	83 d1 00             	adc    $0x0,%ecx
  80070e:	f7 d9                	neg    %ecx
  800710:	83 c4 10             	add    $0x10,%esp
			}
			base = 8;
  800713:	b8 08 00 00 00       	mov    $0x8,%eax
  800718:	eb 74                	jmp    80078e <vprintfmt+0x476>
			goto number;

		// pointer
		case 'p':
			putch('0', putdat);
  80071a:	83 ec 08             	sub    $0x8,%esp
  80071d:	53                   	push   %ebx
  80071e:	6a 30                	push   $0x30
  800720:	ff d6                	call   *%esi
			putch('x', putdat);
  800722:	83 c4 08             	add    $0x8,%esp
  800725:	53                   	push   %ebx
  800726:	6a 78                	push   $0x78
  800728:	ff d6                	call   *%esi
			num = (unsigned long long)
  80072a:	8b 45 14             	mov    0x14(%ebp),%eax
  80072d:	8b 10                	mov    (%eax),%edx
  80072f:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800734:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800737:	8d 40 04             	lea    0x4(%eax),%eax
  80073a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80073d:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800742:	eb 4a                	jmp    80078e <vprintfmt+0x476>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800744:	83 f9 01             	cmp    $0x1,%ecx
  800747:	7e 15                	jle    80075e <vprintfmt+0x446>
		return va_arg(*ap, unsigned long long);
  800749:	8b 45 14             	mov    0x14(%ebp),%eax
  80074c:	8b 10                	mov    (%eax),%edx
  80074e:	8b 48 04             	mov    0x4(%eax),%ecx
  800751:	8d 40 08             	lea    0x8(%eax),%eax
  800754:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800757:	b8 10 00 00 00       	mov    $0x10,%eax
  80075c:	eb 30                	jmp    80078e <vprintfmt+0x476>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80075e:	85 c9                	test   %ecx,%ecx
  800760:	74 17                	je     800779 <vprintfmt+0x461>
		return va_arg(*ap, unsigned long);
  800762:	8b 45 14             	mov    0x14(%ebp),%eax
  800765:	8b 10                	mov    (%eax),%edx
  800767:	b9 00 00 00 00       	mov    $0x0,%ecx
  80076c:	8d 40 04             	lea    0x4(%eax),%eax
  80076f:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800772:	b8 10 00 00 00       	mov    $0x10,%eax
  800777:	eb 15                	jmp    80078e <vprintfmt+0x476>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800779:	8b 45 14             	mov    0x14(%ebp),%eax
  80077c:	8b 10                	mov    (%eax),%edx
  80077e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800783:	8d 40 04             	lea    0x4(%eax),%eax
  800786:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800789:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80078e:	83 ec 0c             	sub    $0xc,%esp
  800791:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800795:	57                   	push   %edi
  800796:	ff 75 e0             	pushl  -0x20(%ebp)
  800799:	50                   	push   %eax
  80079a:	51                   	push   %ecx
  80079b:	52                   	push   %edx
  80079c:	89 da                	mov    %ebx,%edx
  80079e:	89 f0                	mov    %esi,%eax
  8007a0:	e8 8a fa ff ff       	call   80022f <printnum>
			break;
  8007a5:	83 c4 20             	add    $0x20,%esp
  8007a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007ab:	e9 8e fb ff ff       	jmp    80033e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007b0:	83 ec 08             	sub    $0x8,%esp
  8007b3:	53                   	push   %ebx
  8007b4:	52                   	push   %edx
  8007b5:	ff d6                	call   *%esi
			break;
  8007b7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007bd:	e9 7c fb ff ff       	jmp    80033e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007c2:	83 ec 08             	sub    $0x8,%esp
  8007c5:	53                   	push   %ebx
  8007c6:	6a 25                	push   $0x25
  8007c8:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007ca:	83 c4 10             	add    $0x10,%esp
  8007cd:	eb 03                	jmp    8007d2 <vprintfmt+0x4ba>
  8007cf:	83 ef 01             	sub    $0x1,%edi
  8007d2:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007d6:	75 f7                	jne    8007cf <vprintfmt+0x4b7>
  8007d8:	e9 61 fb ff ff       	jmp    80033e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8007dd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007e0:	5b                   	pop    %ebx
  8007e1:	5e                   	pop    %esi
  8007e2:	5f                   	pop    %edi
  8007e3:	5d                   	pop    %ebp
  8007e4:	c3                   	ret    

008007e5 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007e5:	55                   	push   %ebp
  8007e6:	89 e5                	mov    %esp,%ebp
  8007e8:	83 ec 18             	sub    $0x18,%esp
  8007eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ee:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007f1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007f4:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007f8:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007fb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800802:	85 c0                	test   %eax,%eax
  800804:	74 26                	je     80082c <vsnprintf+0x47>
  800806:	85 d2                	test   %edx,%edx
  800808:	7e 22                	jle    80082c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80080a:	ff 75 14             	pushl  0x14(%ebp)
  80080d:	ff 75 10             	pushl  0x10(%ebp)
  800810:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800813:	50                   	push   %eax
  800814:	68 de 02 80 00       	push   $0x8002de
  800819:	e8 fa fa ff ff       	call   800318 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80081e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800821:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800824:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800827:	83 c4 10             	add    $0x10,%esp
  80082a:	eb 05                	jmp    800831 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80082c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800831:	c9                   	leave  
  800832:	c3                   	ret    

00800833 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800833:	55                   	push   %ebp
  800834:	89 e5                	mov    %esp,%ebp
  800836:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800839:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80083c:	50                   	push   %eax
  80083d:	ff 75 10             	pushl  0x10(%ebp)
  800840:	ff 75 0c             	pushl  0xc(%ebp)
  800843:	ff 75 08             	pushl  0x8(%ebp)
  800846:	e8 9a ff ff ff       	call   8007e5 <vsnprintf>
	va_end(ap);

	return rc;
}
  80084b:	c9                   	leave  
  80084c:	c3                   	ret    

0080084d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80084d:	55                   	push   %ebp
  80084e:	89 e5                	mov    %esp,%ebp
  800850:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800853:	b8 00 00 00 00       	mov    $0x0,%eax
  800858:	eb 03                	jmp    80085d <strlen+0x10>
		n++;
  80085a:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80085d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800861:	75 f7                	jne    80085a <strlen+0xd>
		n++;
	return n;
}
  800863:	5d                   	pop    %ebp
  800864:	c3                   	ret    

00800865 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800865:	55                   	push   %ebp
  800866:	89 e5                	mov    %esp,%ebp
  800868:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80086b:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80086e:	ba 00 00 00 00       	mov    $0x0,%edx
  800873:	eb 03                	jmp    800878 <strnlen+0x13>
		n++;
  800875:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800878:	39 c2                	cmp    %eax,%edx
  80087a:	74 08                	je     800884 <strnlen+0x1f>
  80087c:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800880:	75 f3                	jne    800875 <strnlen+0x10>
  800882:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800884:	5d                   	pop    %ebp
  800885:	c3                   	ret    

00800886 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800886:	55                   	push   %ebp
  800887:	89 e5                	mov    %esp,%ebp
  800889:	53                   	push   %ebx
  80088a:	8b 45 08             	mov    0x8(%ebp),%eax
  80088d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800890:	89 c2                	mov    %eax,%edx
  800892:	83 c2 01             	add    $0x1,%edx
  800895:	83 c1 01             	add    $0x1,%ecx
  800898:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80089c:	88 5a ff             	mov    %bl,-0x1(%edx)
  80089f:	84 db                	test   %bl,%bl
  8008a1:	75 ef                	jne    800892 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008a3:	5b                   	pop    %ebx
  8008a4:	5d                   	pop    %ebp
  8008a5:	c3                   	ret    

008008a6 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008a6:	55                   	push   %ebp
  8008a7:	89 e5                	mov    %esp,%ebp
  8008a9:	53                   	push   %ebx
  8008aa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008ad:	53                   	push   %ebx
  8008ae:	e8 9a ff ff ff       	call   80084d <strlen>
  8008b3:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008b6:	ff 75 0c             	pushl  0xc(%ebp)
  8008b9:	01 d8                	add    %ebx,%eax
  8008bb:	50                   	push   %eax
  8008bc:	e8 c5 ff ff ff       	call   800886 <strcpy>
	return dst;
}
  8008c1:	89 d8                	mov    %ebx,%eax
  8008c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008c6:	c9                   	leave  
  8008c7:	c3                   	ret    

008008c8 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008c8:	55                   	push   %ebp
  8008c9:	89 e5                	mov    %esp,%ebp
  8008cb:	56                   	push   %esi
  8008cc:	53                   	push   %ebx
  8008cd:	8b 75 08             	mov    0x8(%ebp),%esi
  8008d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008d3:	89 f3                	mov    %esi,%ebx
  8008d5:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008d8:	89 f2                	mov    %esi,%edx
  8008da:	eb 0f                	jmp    8008eb <strncpy+0x23>
		*dst++ = *src;
  8008dc:	83 c2 01             	add    $0x1,%edx
  8008df:	0f b6 01             	movzbl (%ecx),%eax
  8008e2:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008e5:	80 39 01             	cmpb   $0x1,(%ecx)
  8008e8:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008eb:	39 da                	cmp    %ebx,%edx
  8008ed:	75 ed                	jne    8008dc <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008ef:	89 f0                	mov    %esi,%eax
  8008f1:	5b                   	pop    %ebx
  8008f2:	5e                   	pop    %esi
  8008f3:	5d                   	pop    %ebp
  8008f4:	c3                   	ret    

008008f5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008f5:	55                   	push   %ebp
  8008f6:	89 e5                	mov    %esp,%ebp
  8008f8:	56                   	push   %esi
  8008f9:	53                   	push   %ebx
  8008fa:	8b 75 08             	mov    0x8(%ebp),%esi
  8008fd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800900:	8b 55 10             	mov    0x10(%ebp),%edx
  800903:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800905:	85 d2                	test   %edx,%edx
  800907:	74 21                	je     80092a <strlcpy+0x35>
  800909:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80090d:	89 f2                	mov    %esi,%edx
  80090f:	eb 09                	jmp    80091a <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800911:	83 c2 01             	add    $0x1,%edx
  800914:	83 c1 01             	add    $0x1,%ecx
  800917:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80091a:	39 c2                	cmp    %eax,%edx
  80091c:	74 09                	je     800927 <strlcpy+0x32>
  80091e:	0f b6 19             	movzbl (%ecx),%ebx
  800921:	84 db                	test   %bl,%bl
  800923:	75 ec                	jne    800911 <strlcpy+0x1c>
  800925:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800927:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80092a:	29 f0                	sub    %esi,%eax
}
  80092c:	5b                   	pop    %ebx
  80092d:	5e                   	pop    %esi
  80092e:	5d                   	pop    %ebp
  80092f:	c3                   	ret    

00800930 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800930:	55                   	push   %ebp
  800931:	89 e5                	mov    %esp,%ebp
  800933:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800936:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800939:	eb 06                	jmp    800941 <strcmp+0x11>
		p++, q++;
  80093b:	83 c1 01             	add    $0x1,%ecx
  80093e:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800941:	0f b6 01             	movzbl (%ecx),%eax
  800944:	84 c0                	test   %al,%al
  800946:	74 04                	je     80094c <strcmp+0x1c>
  800948:	3a 02                	cmp    (%edx),%al
  80094a:	74 ef                	je     80093b <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80094c:	0f b6 c0             	movzbl %al,%eax
  80094f:	0f b6 12             	movzbl (%edx),%edx
  800952:	29 d0                	sub    %edx,%eax
}
  800954:	5d                   	pop    %ebp
  800955:	c3                   	ret    

00800956 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800956:	55                   	push   %ebp
  800957:	89 e5                	mov    %esp,%ebp
  800959:	53                   	push   %ebx
  80095a:	8b 45 08             	mov    0x8(%ebp),%eax
  80095d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800960:	89 c3                	mov    %eax,%ebx
  800962:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800965:	eb 06                	jmp    80096d <strncmp+0x17>
		n--, p++, q++;
  800967:	83 c0 01             	add    $0x1,%eax
  80096a:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80096d:	39 d8                	cmp    %ebx,%eax
  80096f:	74 15                	je     800986 <strncmp+0x30>
  800971:	0f b6 08             	movzbl (%eax),%ecx
  800974:	84 c9                	test   %cl,%cl
  800976:	74 04                	je     80097c <strncmp+0x26>
  800978:	3a 0a                	cmp    (%edx),%cl
  80097a:	74 eb                	je     800967 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80097c:	0f b6 00             	movzbl (%eax),%eax
  80097f:	0f b6 12             	movzbl (%edx),%edx
  800982:	29 d0                	sub    %edx,%eax
  800984:	eb 05                	jmp    80098b <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800986:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80098b:	5b                   	pop    %ebx
  80098c:	5d                   	pop    %ebp
  80098d:	c3                   	ret    

0080098e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80098e:	55                   	push   %ebp
  80098f:	89 e5                	mov    %esp,%ebp
  800991:	8b 45 08             	mov    0x8(%ebp),%eax
  800994:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800998:	eb 07                	jmp    8009a1 <strchr+0x13>
		if (*s == c)
  80099a:	38 ca                	cmp    %cl,%dl
  80099c:	74 0f                	je     8009ad <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80099e:	83 c0 01             	add    $0x1,%eax
  8009a1:	0f b6 10             	movzbl (%eax),%edx
  8009a4:	84 d2                	test   %dl,%dl
  8009a6:	75 f2                	jne    80099a <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009a8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ad:	5d                   	pop    %ebp
  8009ae:	c3                   	ret    

008009af <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009af:	55                   	push   %ebp
  8009b0:	89 e5                	mov    %esp,%ebp
  8009b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009b9:	eb 03                	jmp    8009be <strfind+0xf>
  8009bb:	83 c0 01             	add    $0x1,%eax
  8009be:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009c1:	38 ca                	cmp    %cl,%dl
  8009c3:	74 04                	je     8009c9 <strfind+0x1a>
  8009c5:	84 d2                	test   %dl,%dl
  8009c7:	75 f2                	jne    8009bb <strfind+0xc>
			break;
	return (char *) s;
}
  8009c9:	5d                   	pop    %ebp
  8009ca:	c3                   	ret    

008009cb <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	57                   	push   %edi
  8009cf:	56                   	push   %esi
  8009d0:	53                   	push   %ebx
  8009d1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009d4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009d7:	85 c9                	test   %ecx,%ecx
  8009d9:	74 36                	je     800a11 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009db:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009e1:	75 28                	jne    800a0b <memset+0x40>
  8009e3:	f6 c1 03             	test   $0x3,%cl
  8009e6:	75 23                	jne    800a0b <memset+0x40>
		c &= 0xFF;
  8009e8:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009ec:	89 d3                	mov    %edx,%ebx
  8009ee:	c1 e3 08             	shl    $0x8,%ebx
  8009f1:	89 d6                	mov    %edx,%esi
  8009f3:	c1 e6 18             	shl    $0x18,%esi
  8009f6:	89 d0                	mov    %edx,%eax
  8009f8:	c1 e0 10             	shl    $0x10,%eax
  8009fb:	09 f0                	or     %esi,%eax
  8009fd:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8009ff:	89 d8                	mov    %ebx,%eax
  800a01:	09 d0                	or     %edx,%eax
  800a03:	c1 e9 02             	shr    $0x2,%ecx
  800a06:	fc                   	cld    
  800a07:	f3 ab                	rep stos %eax,%es:(%edi)
  800a09:	eb 06                	jmp    800a11 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a0b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a0e:	fc                   	cld    
  800a0f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a11:	89 f8                	mov    %edi,%eax
  800a13:	5b                   	pop    %ebx
  800a14:	5e                   	pop    %esi
  800a15:	5f                   	pop    %edi
  800a16:	5d                   	pop    %ebp
  800a17:	c3                   	ret    

00800a18 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a18:	55                   	push   %ebp
  800a19:	89 e5                	mov    %esp,%ebp
  800a1b:	57                   	push   %edi
  800a1c:	56                   	push   %esi
  800a1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a20:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a23:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a26:	39 c6                	cmp    %eax,%esi
  800a28:	73 35                	jae    800a5f <memmove+0x47>
  800a2a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a2d:	39 d0                	cmp    %edx,%eax
  800a2f:	73 2e                	jae    800a5f <memmove+0x47>
		s += n;
		d += n;
  800a31:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a34:	89 d6                	mov    %edx,%esi
  800a36:	09 fe                	or     %edi,%esi
  800a38:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a3e:	75 13                	jne    800a53 <memmove+0x3b>
  800a40:	f6 c1 03             	test   $0x3,%cl
  800a43:	75 0e                	jne    800a53 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a45:	83 ef 04             	sub    $0x4,%edi
  800a48:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a4b:	c1 e9 02             	shr    $0x2,%ecx
  800a4e:	fd                   	std    
  800a4f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a51:	eb 09                	jmp    800a5c <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a53:	83 ef 01             	sub    $0x1,%edi
  800a56:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a59:	fd                   	std    
  800a5a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a5c:	fc                   	cld    
  800a5d:	eb 1d                	jmp    800a7c <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a5f:	89 f2                	mov    %esi,%edx
  800a61:	09 c2                	or     %eax,%edx
  800a63:	f6 c2 03             	test   $0x3,%dl
  800a66:	75 0f                	jne    800a77 <memmove+0x5f>
  800a68:	f6 c1 03             	test   $0x3,%cl
  800a6b:	75 0a                	jne    800a77 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a6d:	c1 e9 02             	shr    $0x2,%ecx
  800a70:	89 c7                	mov    %eax,%edi
  800a72:	fc                   	cld    
  800a73:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a75:	eb 05                	jmp    800a7c <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a77:	89 c7                	mov    %eax,%edi
  800a79:	fc                   	cld    
  800a7a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a7c:	5e                   	pop    %esi
  800a7d:	5f                   	pop    %edi
  800a7e:	5d                   	pop    %ebp
  800a7f:	c3                   	ret    

00800a80 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a80:	55                   	push   %ebp
  800a81:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a83:	ff 75 10             	pushl  0x10(%ebp)
  800a86:	ff 75 0c             	pushl  0xc(%ebp)
  800a89:	ff 75 08             	pushl  0x8(%ebp)
  800a8c:	e8 87 ff ff ff       	call   800a18 <memmove>
}
  800a91:	c9                   	leave  
  800a92:	c3                   	ret    

00800a93 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a93:	55                   	push   %ebp
  800a94:	89 e5                	mov    %esp,%ebp
  800a96:	56                   	push   %esi
  800a97:	53                   	push   %ebx
  800a98:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a9e:	89 c6                	mov    %eax,%esi
  800aa0:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aa3:	eb 1a                	jmp    800abf <memcmp+0x2c>
		if (*s1 != *s2)
  800aa5:	0f b6 08             	movzbl (%eax),%ecx
  800aa8:	0f b6 1a             	movzbl (%edx),%ebx
  800aab:	38 d9                	cmp    %bl,%cl
  800aad:	74 0a                	je     800ab9 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800aaf:	0f b6 c1             	movzbl %cl,%eax
  800ab2:	0f b6 db             	movzbl %bl,%ebx
  800ab5:	29 d8                	sub    %ebx,%eax
  800ab7:	eb 0f                	jmp    800ac8 <memcmp+0x35>
		s1++, s2++;
  800ab9:	83 c0 01             	add    $0x1,%eax
  800abc:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800abf:	39 f0                	cmp    %esi,%eax
  800ac1:	75 e2                	jne    800aa5 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ac3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ac8:	5b                   	pop    %ebx
  800ac9:	5e                   	pop    %esi
  800aca:	5d                   	pop    %ebp
  800acb:	c3                   	ret    

00800acc <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800acc:	55                   	push   %ebp
  800acd:	89 e5                	mov    %esp,%ebp
  800acf:	53                   	push   %ebx
  800ad0:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ad3:	89 c1                	mov    %eax,%ecx
  800ad5:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800ad8:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800adc:	eb 0a                	jmp    800ae8 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ade:	0f b6 10             	movzbl (%eax),%edx
  800ae1:	39 da                	cmp    %ebx,%edx
  800ae3:	74 07                	je     800aec <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ae5:	83 c0 01             	add    $0x1,%eax
  800ae8:	39 c8                	cmp    %ecx,%eax
  800aea:	72 f2                	jb     800ade <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800aec:	5b                   	pop    %ebx
  800aed:	5d                   	pop    %ebp
  800aee:	c3                   	ret    

00800aef <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800aef:	55                   	push   %ebp
  800af0:	89 e5                	mov    %esp,%ebp
  800af2:	57                   	push   %edi
  800af3:	56                   	push   %esi
  800af4:	53                   	push   %ebx
  800af5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800af8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800afb:	eb 03                	jmp    800b00 <strtol+0x11>
		s++;
  800afd:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b00:	0f b6 01             	movzbl (%ecx),%eax
  800b03:	3c 20                	cmp    $0x20,%al
  800b05:	74 f6                	je     800afd <strtol+0xe>
  800b07:	3c 09                	cmp    $0x9,%al
  800b09:	74 f2                	je     800afd <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b0b:	3c 2b                	cmp    $0x2b,%al
  800b0d:	75 0a                	jne    800b19 <strtol+0x2a>
		s++;
  800b0f:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b12:	bf 00 00 00 00       	mov    $0x0,%edi
  800b17:	eb 11                	jmp    800b2a <strtol+0x3b>
  800b19:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b1e:	3c 2d                	cmp    $0x2d,%al
  800b20:	75 08                	jne    800b2a <strtol+0x3b>
		s++, neg = 1;
  800b22:	83 c1 01             	add    $0x1,%ecx
  800b25:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b2a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b30:	75 15                	jne    800b47 <strtol+0x58>
  800b32:	80 39 30             	cmpb   $0x30,(%ecx)
  800b35:	75 10                	jne    800b47 <strtol+0x58>
  800b37:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b3b:	75 7c                	jne    800bb9 <strtol+0xca>
		s += 2, base = 16;
  800b3d:	83 c1 02             	add    $0x2,%ecx
  800b40:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b45:	eb 16                	jmp    800b5d <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b47:	85 db                	test   %ebx,%ebx
  800b49:	75 12                	jne    800b5d <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b4b:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b50:	80 39 30             	cmpb   $0x30,(%ecx)
  800b53:	75 08                	jne    800b5d <strtol+0x6e>
		s++, base = 8;
  800b55:	83 c1 01             	add    $0x1,%ecx
  800b58:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b5d:	b8 00 00 00 00       	mov    $0x0,%eax
  800b62:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b65:	0f b6 11             	movzbl (%ecx),%edx
  800b68:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b6b:	89 f3                	mov    %esi,%ebx
  800b6d:	80 fb 09             	cmp    $0x9,%bl
  800b70:	77 08                	ja     800b7a <strtol+0x8b>
			dig = *s - '0';
  800b72:	0f be d2             	movsbl %dl,%edx
  800b75:	83 ea 30             	sub    $0x30,%edx
  800b78:	eb 22                	jmp    800b9c <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b7a:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b7d:	89 f3                	mov    %esi,%ebx
  800b7f:	80 fb 19             	cmp    $0x19,%bl
  800b82:	77 08                	ja     800b8c <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b84:	0f be d2             	movsbl %dl,%edx
  800b87:	83 ea 57             	sub    $0x57,%edx
  800b8a:	eb 10                	jmp    800b9c <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b8c:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b8f:	89 f3                	mov    %esi,%ebx
  800b91:	80 fb 19             	cmp    $0x19,%bl
  800b94:	77 16                	ja     800bac <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b96:	0f be d2             	movsbl %dl,%edx
  800b99:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b9c:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b9f:	7d 0b                	jge    800bac <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ba1:	83 c1 01             	add    $0x1,%ecx
  800ba4:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ba8:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800baa:	eb b9                	jmp    800b65 <strtol+0x76>

	if (endptr)
  800bac:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bb0:	74 0d                	je     800bbf <strtol+0xd0>
		*endptr = (char *) s;
  800bb2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bb5:	89 0e                	mov    %ecx,(%esi)
  800bb7:	eb 06                	jmp    800bbf <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bb9:	85 db                	test   %ebx,%ebx
  800bbb:	74 98                	je     800b55 <strtol+0x66>
  800bbd:	eb 9e                	jmp    800b5d <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800bbf:	89 c2                	mov    %eax,%edx
  800bc1:	f7 da                	neg    %edx
  800bc3:	85 ff                	test   %edi,%edi
  800bc5:	0f 45 c2             	cmovne %edx,%eax
}
  800bc8:	5b                   	pop    %ebx
  800bc9:	5e                   	pop    %esi
  800bca:	5f                   	pop    %edi
  800bcb:	5d                   	pop    %ebp
  800bcc:	c3                   	ret    
  800bcd:	66 90                	xchg   %ax,%ax
  800bcf:	90                   	nop

00800bd0 <__udivdi3>:
  800bd0:	55                   	push   %ebp
  800bd1:	57                   	push   %edi
  800bd2:	56                   	push   %esi
  800bd3:	53                   	push   %ebx
  800bd4:	83 ec 1c             	sub    $0x1c,%esp
  800bd7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800bdb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800bdf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800be3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800be7:	85 f6                	test   %esi,%esi
  800be9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800bed:	89 ca                	mov    %ecx,%edx
  800bef:	89 f8                	mov    %edi,%eax
  800bf1:	75 3d                	jne    800c30 <__udivdi3+0x60>
  800bf3:	39 cf                	cmp    %ecx,%edi
  800bf5:	0f 87 c5 00 00 00    	ja     800cc0 <__udivdi3+0xf0>
  800bfb:	85 ff                	test   %edi,%edi
  800bfd:	89 fd                	mov    %edi,%ebp
  800bff:	75 0b                	jne    800c0c <__udivdi3+0x3c>
  800c01:	b8 01 00 00 00       	mov    $0x1,%eax
  800c06:	31 d2                	xor    %edx,%edx
  800c08:	f7 f7                	div    %edi
  800c0a:	89 c5                	mov    %eax,%ebp
  800c0c:	89 c8                	mov    %ecx,%eax
  800c0e:	31 d2                	xor    %edx,%edx
  800c10:	f7 f5                	div    %ebp
  800c12:	89 c1                	mov    %eax,%ecx
  800c14:	89 d8                	mov    %ebx,%eax
  800c16:	89 cf                	mov    %ecx,%edi
  800c18:	f7 f5                	div    %ebp
  800c1a:	89 c3                	mov    %eax,%ebx
  800c1c:	89 d8                	mov    %ebx,%eax
  800c1e:	89 fa                	mov    %edi,%edx
  800c20:	83 c4 1c             	add    $0x1c,%esp
  800c23:	5b                   	pop    %ebx
  800c24:	5e                   	pop    %esi
  800c25:	5f                   	pop    %edi
  800c26:	5d                   	pop    %ebp
  800c27:	c3                   	ret    
  800c28:	90                   	nop
  800c29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800c30:	39 ce                	cmp    %ecx,%esi
  800c32:	77 74                	ja     800ca8 <__udivdi3+0xd8>
  800c34:	0f bd fe             	bsr    %esi,%edi
  800c37:	83 f7 1f             	xor    $0x1f,%edi
  800c3a:	0f 84 98 00 00 00    	je     800cd8 <__udivdi3+0x108>
  800c40:	bb 20 00 00 00       	mov    $0x20,%ebx
  800c45:	89 f9                	mov    %edi,%ecx
  800c47:	89 c5                	mov    %eax,%ebp
  800c49:	29 fb                	sub    %edi,%ebx
  800c4b:	d3 e6                	shl    %cl,%esi
  800c4d:	89 d9                	mov    %ebx,%ecx
  800c4f:	d3 ed                	shr    %cl,%ebp
  800c51:	89 f9                	mov    %edi,%ecx
  800c53:	d3 e0                	shl    %cl,%eax
  800c55:	09 ee                	or     %ebp,%esi
  800c57:	89 d9                	mov    %ebx,%ecx
  800c59:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c5d:	89 d5                	mov    %edx,%ebp
  800c5f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800c63:	d3 ed                	shr    %cl,%ebp
  800c65:	89 f9                	mov    %edi,%ecx
  800c67:	d3 e2                	shl    %cl,%edx
  800c69:	89 d9                	mov    %ebx,%ecx
  800c6b:	d3 e8                	shr    %cl,%eax
  800c6d:	09 c2                	or     %eax,%edx
  800c6f:	89 d0                	mov    %edx,%eax
  800c71:	89 ea                	mov    %ebp,%edx
  800c73:	f7 f6                	div    %esi
  800c75:	89 d5                	mov    %edx,%ebp
  800c77:	89 c3                	mov    %eax,%ebx
  800c79:	f7 64 24 0c          	mull   0xc(%esp)
  800c7d:	39 d5                	cmp    %edx,%ebp
  800c7f:	72 10                	jb     800c91 <__udivdi3+0xc1>
  800c81:	8b 74 24 08          	mov    0x8(%esp),%esi
  800c85:	89 f9                	mov    %edi,%ecx
  800c87:	d3 e6                	shl    %cl,%esi
  800c89:	39 c6                	cmp    %eax,%esi
  800c8b:	73 07                	jae    800c94 <__udivdi3+0xc4>
  800c8d:	39 d5                	cmp    %edx,%ebp
  800c8f:	75 03                	jne    800c94 <__udivdi3+0xc4>
  800c91:	83 eb 01             	sub    $0x1,%ebx
  800c94:	31 ff                	xor    %edi,%edi
  800c96:	89 d8                	mov    %ebx,%eax
  800c98:	89 fa                	mov    %edi,%edx
  800c9a:	83 c4 1c             	add    $0x1c,%esp
  800c9d:	5b                   	pop    %ebx
  800c9e:	5e                   	pop    %esi
  800c9f:	5f                   	pop    %edi
  800ca0:	5d                   	pop    %ebp
  800ca1:	c3                   	ret    
  800ca2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800ca8:	31 ff                	xor    %edi,%edi
  800caa:	31 db                	xor    %ebx,%ebx
  800cac:	89 d8                	mov    %ebx,%eax
  800cae:	89 fa                	mov    %edi,%edx
  800cb0:	83 c4 1c             	add    $0x1c,%esp
  800cb3:	5b                   	pop    %ebx
  800cb4:	5e                   	pop    %esi
  800cb5:	5f                   	pop    %edi
  800cb6:	5d                   	pop    %ebp
  800cb7:	c3                   	ret    
  800cb8:	90                   	nop
  800cb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800cc0:	89 d8                	mov    %ebx,%eax
  800cc2:	f7 f7                	div    %edi
  800cc4:	31 ff                	xor    %edi,%edi
  800cc6:	89 c3                	mov    %eax,%ebx
  800cc8:	89 d8                	mov    %ebx,%eax
  800cca:	89 fa                	mov    %edi,%edx
  800ccc:	83 c4 1c             	add    $0x1c,%esp
  800ccf:	5b                   	pop    %ebx
  800cd0:	5e                   	pop    %esi
  800cd1:	5f                   	pop    %edi
  800cd2:	5d                   	pop    %ebp
  800cd3:	c3                   	ret    
  800cd4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800cd8:	39 ce                	cmp    %ecx,%esi
  800cda:	72 0c                	jb     800ce8 <__udivdi3+0x118>
  800cdc:	31 db                	xor    %ebx,%ebx
  800cde:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800ce2:	0f 87 34 ff ff ff    	ja     800c1c <__udivdi3+0x4c>
  800ce8:	bb 01 00 00 00       	mov    $0x1,%ebx
  800ced:	e9 2a ff ff ff       	jmp    800c1c <__udivdi3+0x4c>
  800cf2:	66 90                	xchg   %ax,%ax
  800cf4:	66 90                	xchg   %ax,%ax
  800cf6:	66 90                	xchg   %ax,%ax
  800cf8:	66 90                	xchg   %ax,%ax
  800cfa:	66 90                	xchg   %ax,%ax
  800cfc:	66 90                	xchg   %ax,%ax
  800cfe:	66 90                	xchg   %ax,%ax

00800d00 <__umoddi3>:
  800d00:	55                   	push   %ebp
  800d01:	57                   	push   %edi
  800d02:	56                   	push   %esi
  800d03:	53                   	push   %ebx
  800d04:	83 ec 1c             	sub    $0x1c,%esp
  800d07:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800d0b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800d0f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800d13:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d17:	85 d2                	test   %edx,%edx
  800d19:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800d1d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800d21:	89 f3                	mov    %esi,%ebx
  800d23:	89 3c 24             	mov    %edi,(%esp)
  800d26:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d2a:	75 1c                	jne    800d48 <__umoddi3+0x48>
  800d2c:	39 f7                	cmp    %esi,%edi
  800d2e:	76 50                	jbe    800d80 <__umoddi3+0x80>
  800d30:	89 c8                	mov    %ecx,%eax
  800d32:	89 f2                	mov    %esi,%edx
  800d34:	f7 f7                	div    %edi
  800d36:	89 d0                	mov    %edx,%eax
  800d38:	31 d2                	xor    %edx,%edx
  800d3a:	83 c4 1c             	add    $0x1c,%esp
  800d3d:	5b                   	pop    %ebx
  800d3e:	5e                   	pop    %esi
  800d3f:	5f                   	pop    %edi
  800d40:	5d                   	pop    %ebp
  800d41:	c3                   	ret    
  800d42:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d48:	39 f2                	cmp    %esi,%edx
  800d4a:	89 d0                	mov    %edx,%eax
  800d4c:	77 52                	ja     800da0 <__umoddi3+0xa0>
  800d4e:	0f bd ea             	bsr    %edx,%ebp
  800d51:	83 f5 1f             	xor    $0x1f,%ebp
  800d54:	75 5a                	jne    800db0 <__umoddi3+0xb0>
  800d56:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800d5a:	0f 82 e0 00 00 00    	jb     800e40 <__umoddi3+0x140>
  800d60:	39 0c 24             	cmp    %ecx,(%esp)
  800d63:	0f 86 d7 00 00 00    	jbe    800e40 <__umoddi3+0x140>
  800d69:	8b 44 24 08          	mov    0x8(%esp),%eax
  800d6d:	8b 54 24 04          	mov    0x4(%esp),%edx
  800d71:	83 c4 1c             	add    $0x1c,%esp
  800d74:	5b                   	pop    %ebx
  800d75:	5e                   	pop    %esi
  800d76:	5f                   	pop    %edi
  800d77:	5d                   	pop    %ebp
  800d78:	c3                   	ret    
  800d79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d80:	85 ff                	test   %edi,%edi
  800d82:	89 fd                	mov    %edi,%ebp
  800d84:	75 0b                	jne    800d91 <__umoddi3+0x91>
  800d86:	b8 01 00 00 00       	mov    $0x1,%eax
  800d8b:	31 d2                	xor    %edx,%edx
  800d8d:	f7 f7                	div    %edi
  800d8f:	89 c5                	mov    %eax,%ebp
  800d91:	89 f0                	mov    %esi,%eax
  800d93:	31 d2                	xor    %edx,%edx
  800d95:	f7 f5                	div    %ebp
  800d97:	89 c8                	mov    %ecx,%eax
  800d99:	f7 f5                	div    %ebp
  800d9b:	89 d0                	mov    %edx,%eax
  800d9d:	eb 99                	jmp    800d38 <__umoddi3+0x38>
  800d9f:	90                   	nop
  800da0:	89 c8                	mov    %ecx,%eax
  800da2:	89 f2                	mov    %esi,%edx
  800da4:	83 c4 1c             	add    $0x1c,%esp
  800da7:	5b                   	pop    %ebx
  800da8:	5e                   	pop    %esi
  800da9:	5f                   	pop    %edi
  800daa:	5d                   	pop    %ebp
  800dab:	c3                   	ret    
  800dac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800db0:	8b 34 24             	mov    (%esp),%esi
  800db3:	bf 20 00 00 00       	mov    $0x20,%edi
  800db8:	89 e9                	mov    %ebp,%ecx
  800dba:	29 ef                	sub    %ebp,%edi
  800dbc:	d3 e0                	shl    %cl,%eax
  800dbe:	89 f9                	mov    %edi,%ecx
  800dc0:	89 f2                	mov    %esi,%edx
  800dc2:	d3 ea                	shr    %cl,%edx
  800dc4:	89 e9                	mov    %ebp,%ecx
  800dc6:	09 c2                	or     %eax,%edx
  800dc8:	89 d8                	mov    %ebx,%eax
  800dca:	89 14 24             	mov    %edx,(%esp)
  800dcd:	89 f2                	mov    %esi,%edx
  800dcf:	d3 e2                	shl    %cl,%edx
  800dd1:	89 f9                	mov    %edi,%ecx
  800dd3:	89 54 24 04          	mov    %edx,0x4(%esp)
  800dd7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800ddb:	d3 e8                	shr    %cl,%eax
  800ddd:	89 e9                	mov    %ebp,%ecx
  800ddf:	89 c6                	mov    %eax,%esi
  800de1:	d3 e3                	shl    %cl,%ebx
  800de3:	89 f9                	mov    %edi,%ecx
  800de5:	89 d0                	mov    %edx,%eax
  800de7:	d3 e8                	shr    %cl,%eax
  800de9:	89 e9                	mov    %ebp,%ecx
  800deb:	09 d8                	or     %ebx,%eax
  800ded:	89 d3                	mov    %edx,%ebx
  800def:	89 f2                	mov    %esi,%edx
  800df1:	f7 34 24             	divl   (%esp)
  800df4:	89 d6                	mov    %edx,%esi
  800df6:	d3 e3                	shl    %cl,%ebx
  800df8:	f7 64 24 04          	mull   0x4(%esp)
  800dfc:	39 d6                	cmp    %edx,%esi
  800dfe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800e02:	89 d1                	mov    %edx,%ecx
  800e04:	89 c3                	mov    %eax,%ebx
  800e06:	72 08                	jb     800e10 <__umoddi3+0x110>
  800e08:	75 11                	jne    800e1b <__umoddi3+0x11b>
  800e0a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800e0e:	73 0b                	jae    800e1b <__umoddi3+0x11b>
  800e10:	2b 44 24 04          	sub    0x4(%esp),%eax
  800e14:	1b 14 24             	sbb    (%esp),%edx
  800e17:	89 d1                	mov    %edx,%ecx
  800e19:	89 c3                	mov    %eax,%ebx
  800e1b:	8b 54 24 08          	mov    0x8(%esp),%edx
  800e1f:	29 da                	sub    %ebx,%edx
  800e21:	19 ce                	sbb    %ecx,%esi
  800e23:	89 f9                	mov    %edi,%ecx
  800e25:	89 f0                	mov    %esi,%eax
  800e27:	d3 e0                	shl    %cl,%eax
  800e29:	89 e9                	mov    %ebp,%ecx
  800e2b:	d3 ea                	shr    %cl,%edx
  800e2d:	89 e9                	mov    %ebp,%ecx
  800e2f:	d3 ee                	shr    %cl,%esi
  800e31:	09 d0                	or     %edx,%eax
  800e33:	89 f2                	mov    %esi,%edx
  800e35:	83 c4 1c             	add    $0x1c,%esp
  800e38:	5b                   	pop    %ebx
  800e39:	5e                   	pop    %esi
  800e3a:	5f                   	pop    %edi
  800e3b:	5d                   	pop    %ebp
  800e3c:	c3                   	ret    
  800e3d:	8d 76 00             	lea    0x0(%esi),%esi
  800e40:	29 f9                	sub    %edi,%ecx
  800e42:	19 d6                	sbb    %edx,%esi
  800e44:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e48:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e4c:	e9 18 ff ff ff       	jmp    800d69 <__umoddi3+0x69>
