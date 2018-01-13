
obj/user/badsegment：     文件格式 elf32-i386


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
  80002c:	e8 0d 00 00 00       	call   80003e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800036:	66 b8 28 00          	mov    $0x28,%ax
  80003a:	8e d8                	mov    %eax,%ds
}
  80003c:	5d                   	pop    %ebp
  80003d:	c3                   	ret    

0080003e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003e:	55                   	push   %ebp
  80003f:	89 e5                	mov    %esp,%ebp
  800041:	56                   	push   %esi
  800042:	53                   	push   %ebx
  800043:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800046:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t i = sys_getenvid();
  800049:	e8 c9 00 00 00       	call   800117 <sys_getenvid>
    thisenv = &envs[ENVX(i)];
  80004e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800053:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800056:	c1 e0 05             	shl    $0x5,%eax
  800059:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005e:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800063:	85 db                	test   %ebx,%ebx
  800065:	7e 07                	jle    80006e <libmain+0x30>
		binaryname = argv[0];
  800067:	8b 06                	mov    (%esi),%eax
  800069:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80006e:	83 ec 08             	sub    $0x8,%esp
  800071:	56                   	push   %esi
  800072:	53                   	push   %ebx
  800073:	e8 bb ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800078:	e8 0a 00 00 00       	call   800087 <exit>
}
  80007d:	83 c4 10             	add    $0x10,%esp
  800080:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800083:	5b                   	pop    %ebx
  800084:	5e                   	pop    %esi
  800085:	5d                   	pop    %ebp
  800086:	c3                   	ret    

00800087 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800087:	55                   	push   %ebp
  800088:	89 e5                	mov    %esp,%ebp
  80008a:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80008d:	6a 00                	push   $0x0
  80008f:	e8 42 00 00 00       	call   8000d6 <sys_env_destroy>
}
  800094:	83 c4 10             	add    $0x10,%esp
  800097:	c9                   	leave  
  800098:	c3                   	ret    

00800099 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800099:	55                   	push   %ebp
  80009a:	89 e5                	mov    %esp,%ebp
  80009c:	57                   	push   %edi
  80009d:	56                   	push   %esi
  80009e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80009f:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000aa:	89 c3                	mov    %eax,%ebx
  8000ac:	89 c7                	mov    %eax,%edi
  8000ae:	89 c6                	mov    %eax,%esi
  8000b0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b2:	5b                   	pop    %ebx
  8000b3:	5e                   	pop    %esi
  8000b4:	5f                   	pop    %edi
  8000b5:	5d                   	pop    %ebp
  8000b6:	c3                   	ret    

008000b7 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b7:	55                   	push   %ebp
  8000b8:	89 e5                	mov    %esp,%ebp
  8000ba:	57                   	push   %edi
  8000bb:	56                   	push   %esi
  8000bc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c2:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c7:	89 d1                	mov    %edx,%ecx
  8000c9:	89 d3                	mov    %edx,%ebx
  8000cb:	89 d7                	mov    %edx,%edi
  8000cd:	89 d6                	mov    %edx,%esi
  8000cf:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d1:	5b                   	pop    %ebx
  8000d2:	5e                   	pop    %esi
  8000d3:	5f                   	pop    %edi
  8000d4:	5d                   	pop    %ebp
  8000d5:	c3                   	ret    

008000d6 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d6:	55                   	push   %ebp
  8000d7:	89 e5                	mov    %esp,%ebp
  8000d9:	57                   	push   %edi
  8000da:	56                   	push   %esi
  8000db:	53                   	push   %ebx
  8000dc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000df:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e4:	b8 03 00 00 00       	mov    $0x3,%eax
  8000e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ec:	89 cb                	mov    %ecx,%ebx
  8000ee:	89 cf                	mov    %ecx,%edi
  8000f0:	89 ce                	mov    %ecx,%esi
  8000f2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000f4:	85 c0                	test   %eax,%eax
  8000f6:	7e 17                	jle    80010f <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f8:	83 ec 0c             	sub    $0xc,%esp
  8000fb:	50                   	push   %eax
  8000fc:	6a 03                	push   $0x3
  8000fe:	68 6a 0e 80 00       	push   $0x800e6a
  800103:	6a 23                	push   $0x23
  800105:	68 87 0e 80 00       	push   $0x800e87
  80010a:	e8 27 00 00 00       	call   800136 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80010f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800112:	5b                   	pop    %ebx
  800113:	5e                   	pop    %esi
  800114:	5f                   	pop    %edi
  800115:	5d                   	pop    %ebp
  800116:	c3                   	ret    

00800117 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800117:	55                   	push   %ebp
  800118:	89 e5                	mov    %esp,%ebp
  80011a:	57                   	push   %edi
  80011b:	56                   	push   %esi
  80011c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80011d:	ba 00 00 00 00       	mov    $0x0,%edx
  800122:	b8 02 00 00 00       	mov    $0x2,%eax
  800127:	89 d1                	mov    %edx,%ecx
  800129:	89 d3                	mov    %edx,%ebx
  80012b:	89 d7                	mov    %edx,%edi
  80012d:	89 d6                	mov    %edx,%esi
  80012f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800131:	5b                   	pop    %ebx
  800132:	5e                   	pop    %esi
  800133:	5f                   	pop    %edi
  800134:	5d                   	pop    %ebp
  800135:	c3                   	ret    

00800136 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800136:	55                   	push   %ebp
  800137:	89 e5                	mov    %esp,%ebp
  800139:	56                   	push   %esi
  80013a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80013b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80013e:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800144:	e8 ce ff ff ff       	call   800117 <sys_getenvid>
  800149:	83 ec 0c             	sub    $0xc,%esp
  80014c:	ff 75 0c             	pushl  0xc(%ebp)
  80014f:	ff 75 08             	pushl  0x8(%ebp)
  800152:	56                   	push   %esi
  800153:	50                   	push   %eax
  800154:	68 98 0e 80 00       	push   $0x800e98
  800159:	e8 b1 00 00 00       	call   80020f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80015e:	83 c4 18             	add    $0x18,%esp
  800161:	53                   	push   %ebx
  800162:	ff 75 10             	pushl  0x10(%ebp)
  800165:	e8 54 00 00 00       	call   8001be <vcprintf>
	cprintf("\n");
  80016a:	c7 04 24 bc 0e 80 00 	movl   $0x800ebc,(%esp)
  800171:	e8 99 00 00 00       	call   80020f <cprintf>
  800176:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800179:	cc                   	int3   
  80017a:	eb fd                	jmp    800179 <_panic+0x43>

0080017c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80017c:	55                   	push   %ebp
  80017d:	89 e5                	mov    %esp,%ebp
  80017f:	53                   	push   %ebx
  800180:	83 ec 04             	sub    $0x4,%esp
  800183:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800186:	8b 13                	mov    (%ebx),%edx
  800188:	8d 42 01             	lea    0x1(%edx),%eax
  80018b:	89 03                	mov    %eax,(%ebx)
  80018d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800190:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800194:	3d ff 00 00 00       	cmp    $0xff,%eax
  800199:	75 1a                	jne    8001b5 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80019b:	83 ec 08             	sub    $0x8,%esp
  80019e:	68 ff 00 00 00       	push   $0xff
  8001a3:	8d 43 08             	lea    0x8(%ebx),%eax
  8001a6:	50                   	push   %eax
  8001a7:	e8 ed fe ff ff       	call   800099 <sys_cputs>
		b->idx = 0;
  8001ac:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001b2:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001b5:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001bc:	c9                   	leave  
  8001bd:	c3                   	ret    

008001be <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001be:	55                   	push   %ebp
  8001bf:	89 e5                	mov    %esp,%ebp
  8001c1:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001c7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001ce:	00 00 00 
	b.cnt = 0;
  8001d1:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001d8:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001db:	ff 75 0c             	pushl  0xc(%ebp)
  8001de:	ff 75 08             	pushl  0x8(%ebp)
  8001e1:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001e7:	50                   	push   %eax
  8001e8:	68 7c 01 80 00       	push   $0x80017c
  8001ed:	e8 1a 01 00 00       	call   80030c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001f2:	83 c4 08             	add    $0x8,%esp
  8001f5:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001fb:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800201:	50                   	push   %eax
  800202:	e8 92 fe ff ff       	call   800099 <sys_cputs>

	return b.cnt;
}
  800207:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80020d:	c9                   	leave  
  80020e:	c3                   	ret    

0080020f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80020f:	55                   	push   %ebp
  800210:	89 e5                	mov    %esp,%ebp
  800212:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800215:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800218:	50                   	push   %eax
  800219:	ff 75 08             	pushl  0x8(%ebp)
  80021c:	e8 9d ff ff ff       	call   8001be <vcprintf>
	va_end(ap);

	return cnt;
}
  800221:	c9                   	leave  
  800222:	c3                   	ret    

00800223 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800223:	55                   	push   %ebp
  800224:	89 e5                	mov    %esp,%ebp
  800226:	57                   	push   %edi
  800227:	56                   	push   %esi
  800228:	53                   	push   %ebx
  800229:	83 ec 1c             	sub    $0x1c,%esp
  80022c:	89 c7                	mov    %eax,%edi
  80022e:	89 d6                	mov    %edx,%esi
  800230:	8b 45 08             	mov    0x8(%ebp),%eax
  800233:	8b 55 0c             	mov    0xc(%ebp),%edx
  800236:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800239:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80023c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80023f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800244:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800247:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80024a:	39 d3                	cmp    %edx,%ebx
  80024c:	72 05                	jb     800253 <printnum+0x30>
  80024e:	39 45 10             	cmp    %eax,0x10(%ebp)
  800251:	77 45                	ja     800298 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800253:	83 ec 0c             	sub    $0xc,%esp
  800256:	ff 75 18             	pushl  0x18(%ebp)
  800259:	8b 45 14             	mov    0x14(%ebp),%eax
  80025c:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80025f:	53                   	push   %ebx
  800260:	ff 75 10             	pushl  0x10(%ebp)
  800263:	83 ec 08             	sub    $0x8,%esp
  800266:	ff 75 e4             	pushl  -0x1c(%ebp)
  800269:	ff 75 e0             	pushl  -0x20(%ebp)
  80026c:	ff 75 dc             	pushl  -0x24(%ebp)
  80026f:	ff 75 d8             	pushl  -0x28(%ebp)
  800272:	e8 59 09 00 00       	call   800bd0 <__udivdi3>
  800277:	83 c4 18             	add    $0x18,%esp
  80027a:	52                   	push   %edx
  80027b:	50                   	push   %eax
  80027c:	89 f2                	mov    %esi,%edx
  80027e:	89 f8                	mov    %edi,%eax
  800280:	e8 9e ff ff ff       	call   800223 <printnum>
  800285:	83 c4 20             	add    $0x20,%esp
  800288:	eb 18                	jmp    8002a2 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80028a:	83 ec 08             	sub    $0x8,%esp
  80028d:	56                   	push   %esi
  80028e:	ff 75 18             	pushl  0x18(%ebp)
  800291:	ff d7                	call   *%edi
  800293:	83 c4 10             	add    $0x10,%esp
  800296:	eb 03                	jmp    80029b <printnum+0x78>
  800298:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80029b:	83 eb 01             	sub    $0x1,%ebx
  80029e:	85 db                	test   %ebx,%ebx
  8002a0:	7f e8                	jg     80028a <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002a2:	83 ec 08             	sub    $0x8,%esp
  8002a5:	56                   	push   %esi
  8002a6:	83 ec 04             	sub    $0x4,%esp
  8002a9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002ac:	ff 75 e0             	pushl  -0x20(%ebp)
  8002af:	ff 75 dc             	pushl  -0x24(%ebp)
  8002b2:	ff 75 d8             	pushl  -0x28(%ebp)
  8002b5:	e8 46 0a 00 00       	call   800d00 <__umoddi3>
  8002ba:	83 c4 14             	add    $0x14,%esp
  8002bd:	0f be 80 be 0e 80 00 	movsbl 0x800ebe(%eax),%eax
  8002c4:	50                   	push   %eax
  8002c5:	ff d7                	call   *%edi
}
  8002c7:	83 c4 10             	add    $0x10,%esp
  8002ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002cd:	5b                   	pop    %ebx
  8002ce:	5e                   	pop    %esi
  8002cf:	5f                   	pop    %edi
  8002d0:	5d                   	pop    %ebp
  8002d1:	c3                   	ret    

008002d2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002d2:	55                   	push   %ebp
  8002d3:	89 e5                	mov    %esp,%ebp
  8002d5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002d8:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002dc:	8b 10                	mov    (%eax),%edx
  8002de:	3b 50 04             	cmp    0x4(%eax),%edx
  8002e1:	73 0a                	jae    8002ed <sprintputch+0x1b>
		*b->buf++ = ch;
  8002e3:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002e6:	89 08                	mov    %ecx,(%eax)
  8002e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8002eb:	88 02                	mov    %al,(%edx)
}
  8002ed:	5d                   	pop    %ebp
  8002ee:	c3                   	ret    

008002ef <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002ef:	55                   	push   %ebp
  8002f0:	89 e5                	mov    %esp,%ebp
  8002f2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002f5:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002f8:	50                   	push   %eax
  8002f9:	ff 75 10             	pushl  0x10(%ebp)
  8002fc:	ff 75 0c             	pushl  0xc(%ebp)
  8002ff:	ff 75 08             	pushl  0x8(%ebp)
  800302:	e8 05 00 00 00       	call   80030c <vprintfmt>
	va_end(ap);
}
  800307:	83 c4 10             	add    $0x10,%esp
  80030a:	c9                   	leave  
  80030b:	c3                   	ret    

0080030c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80030c:	55                   	push   %ebp
  80030d:	89 e5                	mov    %esp,%ebp
  80030f:	57                   	push   %edi
  800310:	56                   	push   %esi
  800311:	53                   	push   %ebx
  800312:	83 ec 2c             	sub    $0x2c,%esp
  800315:	8b 75 08             	mov    0x8(%ebp),%esi
  800318:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80031b:	8b 7d 10             	mov    0x10(%ebp),%edi
  80031e:	eb 12                	jmp    800332 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800320:	85 c0                	test   %eax,%eax
  800322:	0f 84 a9 04 00 00    	je     8007d1 <vprintfmt+0x4c5>
				return;
			putch(ch, putdat);
  800328:	83 ec 08             	sub    $0x8,%esp
  80032b:	53                   	push   %ebx
  80032c:	50                   	push   %eax
  80032d:	ff d6                	call   *%esi
  80032f:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800332:	83 c7 01             	add    $0x1,%edi
  800335:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800339:	83 f8 25             	cmp    $0x25,%eax
  80033c:	75 e2                	jne    800320 <vprintfmt+0x14>
  80033e:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800342:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800349:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800350:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800357:	b9 00 00 00 00       	mov    $0x0,%ecx
  80035c:	eb 07                	jmp    800365 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035e:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800361:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800365:	8d 47 01             	lea    0x1(%edi),%eax
  800368:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80036b:	0f b6 07             	movzbl (%edi),%eax
  80036e:	0f b6 d0             	movzbl %al,%edx
  800371:	83 e8 23             	sub    $0x23,%eax
  800374:	3c 55                	cmp    $0x55,%al
  800376:	0f 87 3a 04 00 00    	ja     8007b6 <vprintfmt+0x4aa>
  80037c:	0f b6 c0             	movzbl %al,%eax
  80037f:	ff 24 85 60 0f 80 00 	jmp    *0x800f60(,%eax,4)
  800386:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800389:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80038d:	eb d6                	jmp    800365 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800392:	b8 00 00 00 00       	mov    $0x0,%eax
  800397:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80039a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80039d:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003a1:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003a4:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003a7:	83 f9 09             	cmp    $0x9,%ecx
  8003aa:	77 3f                	ja     8003eb <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003ac:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003af:	eb e9                	jmp    80039a <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b4:	8b 00                	mov    (%eax),%eax
  8003b6:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bc:	8d 40 04             	lea    0x4(%eax),%eax
  8003bf:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003c5:	eb 2a                	jmp    8003f1 <vprintfmt+0xe5>
  8003c7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003ca:	85 c0                	test   %eax,%eax
  8003cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8003d1:	0f 49 d0             	cmovns %eax,%edx
  8003d4:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003da:	eb 89                	jmp    800365 <vprintfmt+0x59>
  8003dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003df:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003e6:	e9 7a ff ff ff       	jmp    800365 <vprintfmt+0x59>
  8003eb:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003ee:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003f1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003f5:	0f 89 6a ff ff ff    	jns    800365 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003fb:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003fe:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800401:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800408:	e9 58 ff ff ff       	jmp    800365 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80040d:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800410:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800413:	e9 4d ff ff ff       	jmp    800365 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800418:	8b 45 14             	mov    0x14(%ebp),%eax
  80041b:	8d 78 04             	lea    0x4(%eax),%edi
  80041e:	83 ec 08             	sub    $0x8,%esp
  800421:	53                   	push   %ebx
  800422:	ff 30                	pushl  (%eax)
  800424:	ff d6                	call   *%esi
			break;
  800426:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800429:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80042f:	e9 fe fe ff ff       	jmp    800332 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800434:	8b 45 14             	mov    0x14(%ebp),%eax
  800437:	8d 78 04             	lea    0x4(%eax),%edi
  80043a:	8b 00                	mov    (%eax),%eax
  80043c:	99                   	cltd   
  80043d:	31 d0                	xor    %edx,%eax
  80043f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800441:	83 f8 07             	cmp    $0x7,%eax
  800444:	7f 0b                	jg     800451 <vprintfmt+0x145>
  800446:	8b 14 85 c0 10 80 00 	mov    0x8010c0(,%eax,4),%edx
  80044d:	85 d2                	test   %edx,%edx
  80044f:	75 1b                	jne    80046c <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800451:	50                   	push   %eax
  800452:	68 d6 0e 80 00       	push   $0x800ed6
  800457:	53                   	push   %ebx
  800458:	56                   	push   %esi
  800459:	e8 91 fe ff ff       	call   8002ef <printfmt>
  80045e:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800461:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800464:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800467:	e9 c6 fe ff ff       	jmp    800332 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80046c:	52                   	push   %edx
  80046d:	68 df 0e 80 00       	push   $0x800edf
  800472:	53                   	push   %ebx
  800473:	56                   	push   %esi
  800474:	e8 76 fe ff ff       	call   8002ef <printfmt>
  800479:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80047c:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800482:	e9 ab fe ff ff       	jmp    800332 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800487:	8b 45 14             	mov    0x14(%ebp),%eax
  80048a:	83 c0 04             	add    $0x4,%eax
  80048d:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800490:	8b 45 14             	mov    0x14(%ebp),%eax
  800493:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800495:	85 ff                	test   %edi,%edi
  800497:	b8 cf 0e 80 00       	mov    $0x800ecf,%eax
  80049c:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80049f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004a3:	0f 8e 94 00 00 00    	jle    80053d <vprintfmt+0x231>
  8004a9:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004ad:	0f 84 98 00 00 00    	je     80054b <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b3:	83 ec 08             	sub    $0x8,%esp
  8004b6:	ff 75 d0             	pushl  -0x30(%ebp)
  8004b9:	57                   	push   %edi
  8004ba:	e8 9a 03 00 00       	call   800859 <strnlen>
  8004bf:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004c2:	29 c1                	sub    %eax,%ecx
  8004c4:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8004c7:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004ca:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004ce:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004d1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004d4:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d6:	eb 0f                	jmp    8004e7 <vprintfmt+0x1db>
					putch(padc, putdat);
  8004d8:	83 ec 08             	sub    $0x8,%esp
  8004db:	53                   	push   %ebx
  8004dc:	ff 75 e0             	pushl  -0x20(%ebp)
  8004df:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e1:	83 ef 01             	sub    $0x1,%edi
  8004e4:	83 c4 10             	add    $0x10,%esp
  8004e7:	85 ff                	test   %edi,%edi
  8004e9:	7f ed                	jg     8004d8 <vprintfmt+0x1cc>
  8004eb:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004ee:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004f1:	85 c9                	test   %ecx,%ecx
  8004f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8004f8:	0f 49 c1             	cmovns %ecx,%eax
  8004fb:	29 c1                	sub    %eax,%ecx
  8004fd:	89 75 08             	mov    %esi,0x8(%ebp)
  800500:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800503:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800506:	89 cb                	mov    %ecx,%ebx
  800508:	eb 4d                	jmp    800557 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80050a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80050e:	74 1b                	je     80052b <vprintfmt+0x21f>
  800510:	0f be c0             	movsbl %al,%eax
  800513:	83 e8 20             	sub    $0x20,%eax
  800516:	83 f8 5e             	cmp    $0x5e,%eax
  800519:	76 10                	jbe    80052b <vprintfmt+0x21f>
					putch('?', putdat);
  80051b:	83 ec 08             	sub    $0x8,%esp
  80051e:	ff 75 0c             	pushl  0xc(%ebp)
  800521:	6a 3f                	push   $0x3f
  800523:	ff 55 08             	call   *0x8(%ebp)
  800526:	83 c4 10             	add    $0x10,%esp
  800529:	eb 0d                	jmp    800538 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  80052b:	83 ec 08             	sub    $0x8,%esp
  80052e:	ff 75 0c             	pushl  0xc(%ebp)
  800531:	52                   	push   %edx
  800532:	ff 55 08             	call   *0x8(%ebp)
  800535:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800538:	83 eb 01             	sub    $0x1,%ebx
  80053b:	eb 1a                	jmp    800557 <vprintfmt+0x24b>
  80053d:	89 75 08             	mov    %esi,0x8(%ebp)
  800540:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800543:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800546:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800549:	eb 0c                	jmp    800557 <vprintfmt+0x24b>
  80054b:	89 75 08             	mov    %esi,0x8(%ebp)
  80054e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800551:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800554:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800557:	83 c7 01             	add    $0x1,%edi
  80055a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80055e:	0f be d0             	movsbl %al,%edx
  800561:	85 d2                	test   %edx,%edx
  800563:	74 23                	je     800588 <vprintfmt+0x27c>
  800565:	85 f6                	test   %esi,%esi
  800567:	78 a1                	js     80050a <vprintfmt+0x1fe>
  800569:	83 ee 01             	sub    $0x1,%esi
  80056c:	79 9c                	jns    80050a <vprintfmt+0x1fe>
  80056e:	89 df                	mov    %ebx,%edi
  800570:	8b 75 08             	mov    0x8(%ebp),%esi
  800573:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800576:	eb 18                	jmp    800590 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800578:	83 ec 08             	sub    $0x8,%esp
  80057b:	53                   	push   %ebx
  80057c:	6a 20                	push   $0x20
  80057e:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800580:	83 ef 01             	sub    $0x1,%edi
  800583:	83 c4 10             	add    $0x10,%esp
  800586:	eb 08                	jmp    800590 <vprintfmt+0x284>
  800588:	89 df                	mov    %ebx,%edi
  80058a:	8b 75 08             	mov    0x8(%ebp),%esi
  80058d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800590:	85 ff                	test   %edi,%edi
  800592:	7f e4                	jg     800578 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800594:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800597:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80059d:	e9 90 fd ff ff       	jmp    800332 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005a2:	83 f9 01             	cmp    $0x1,%ecx
  8005a5:	7e 19                	jle    8005c0 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  8005a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005aa:	8b 50 04             	mov    0x4(%eax),%edx
  8005ad:	8b 00                	mov    (%eax),%eax
  8005af:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b2:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b8:	8d 40 08             	lea    0x8(%eax),%eax
  8005bb:	89 45 14             	mov    %eax,0x14(%ebp)
  8005be:	eb 38                	jmp    8005f8 <vprintfmt+0x2ec>
	else if (lflag)
  8005c0:	85 c9                	test   %ecx,%ecx
  8005c2:	74 1b                	je     8005df <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8005c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c7:	8b 00                	mov    (%eax),%eax
  8005c9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005cc:	89 c1                	mov    %eax,%ecx
  8005ce:	c1 f9 1f             	sar    $0x1f,%ecx
  8005d1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d7:	8d 40 04             	lea    0x4(%eax),%eax
  8005da:	89 45 14             	mov    %eax,0x14(%ebp)
  8005dd:	eb 19                	jmp    8005f8 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8005df:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e2:	8b 00                	mov    (%eax),%eax
  8005e4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e7:	89 c1                	mov    %eax,%ecx
  8005e9:	c1 f9 1f             	sar    $0x1f,%ecx
  8005ec:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f2:	8d 40 04             	lea    0x4(%eax),%eax
  8005f5:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005f8:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005fb:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005fe:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800603:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800607:	0f 89 75 01 00 00    	jns    800782 <vprintfmt+0x476>
				putch('-', putdat);
  80060d:	83 ec 08             	sub    $0x8,%esp
  800610:	53                   	push   %ebx
  800611:	6a 2d                	push   $0x2d
  800613:	ff d6                	call   *%esi
				num = -(long long) num;
  800615:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800618:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80061b:	f7 da                	neg    %edx
  80061d:	83 d1 00             	adc    $0x0,%ecx
  800620:	f7 d9                	neg    %ecx
  800622:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800625:	b8 0a 00 00 00       	mov    $0xa,%eax
  80062a:	e9 53 01 00 00       	jmp    800782 <vprintfmt+0x476>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80062f:	83 f9 01             	cmp    $0x1,%ecx
  800632:	7e 18                	jle    80064c <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800634:	8b 45 14             	mov    0x14(%ebp),%eax
  800637:	8b 10                	mov    (%eax),%edx
  800639:	8b 48 04             	mov    0x4(%eax),%ecx
  80063c:	8d 40 08             	lea    0x8(%eax),%eax
  80063f:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800642:	b8 0a 00 00 00       	mov    $0xa,%eax
  800647:	e9 36 01 00 00       	jmp    800782 <vprintfmt+0x476>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80064c:	85 c9                	test   %ecx,%ecx
  80064e:	74 1a                	je     80066a <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  800650:	8b 45 14             	mov    0x14(%ebp),%eax
  800653:	8b 10                	mov    (%eax),%edx
  800655:	b9 00 00 00 00       	mov    $0x0,%ecx
  80065a:	8d 40 04             	lea    0x4(%eax),%eax
  80065d:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800660:	b8 0a 00 00 00       	mov    $0xa,%eax
  800665:	e9 18 01 00 00       	jmp    800782 <vprintfmt+0x476>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80066a:	8b 45 14             	mov    0x14(%ebp),%eax
  80066d:	8b 10                	mov    (%eax),%edx
  80066f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800674:	8d 40 04             	lea    0x4(%eax),%eax
  800677:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80067a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80067f:	e9 fe 00 00 00       	jmp    800782 <vprintfmt+0x476>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800684:	83 f9 01             	cmp    $0x1,%ecx
  800687:	7e 19                	jle    8006a2 <vprintfmt+0x396>
		return va_arg(*ap, long long);
  800689:	8b 45 14             	mov    0x14(%ebp),%eax
  80068c:	8b 50 04             	mov    0x4(%eax),%edx
  80068f:	8b 00                	mov    (%eax),%eax
  800691:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800694:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800697:	8b 45 14             	mov    0x14(%ebp),%eax
  80069a:	8d 40 08             	lea    0x8(%eax),%eax
  80069d:	89 45 14             	mov    %eax,0x14(%ebp)
  8006a0:	eb 38                	jmp    8006da <vprintfmt+0x3ce>
	else if (lflag)
  8006a2:	85 c9                	test   %ecx,%ecx
  8006a4:	74 1b                	je     8006c1 <vprintfmt+0x3b5>
		return va_arg(*ap, long);
  8006a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a9:	8b 00                	mov    (%eax),%eax
  8006ab:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006ae:	89 c1                	mov    %eax,%ecx
  8006b0:	c1 f9 1f             	sar    $0x1f,%ecx
  8006b3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b9:	8d 40 04             	lea    0x4(%eax),%eax
  8006bc:	89 45 14             	mov    %eax,0x14(%ebp)
  8006bf:	eb 19                	jmp    8006da <vprintfmt+0x3ce>
	else
		return va_arg(*ap, int);
  8006c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c4:	8b 00                	mov    (%eax),%eax
  8006c6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006c9:	89 c1                	mov    %eax,%ecx
  8006cb:	c1 f9 1f             	sar    $0x1f,%ecx
  8006ce:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d4:	8d 40 04             	lea    0x4(%eax),%eax
  8006d7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
			goto number;

		// (unsigned) octal
		case 'o':
			num = getint(&ap, lflag);
  8006da:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006dd:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 8;
  8006e0:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;

		// (unsigned) octal
		case 'o':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006e5:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006e9:	0f 89 93 00 00 00    	jns    800782 <vprintfmt+0x476>
				putch('-', putdat);
  8006ef:	83 ec 08             	sub    $0x8,%esp
  8006f2:	53                   	push   %ebx
  8006f3:	6a 2d                	push   $0x2d
  8006f5:	ff d6                	call   *%esi
				num = -(long long) num;
  8006f7:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006fa:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8006fd:	f7 da                	neg    %edx
  8006ff:	83 d1 00             	adc    $0x0,%ecx
  800702:	f7 d9                	neg    %ecx
  800704:	83 c4 10             	add    $0x10,%esp
			}
			base = 8;
  800707:	b8 08 00 00 00       	mov    $0x8,%eax
  80070c:	eb 74                	jmp    800782 <vprintfmt+0x476>
			goto number;

		// pointer
		case 'p':
			putch('0', putdat);
  80070e:	83 ec 08             	sub    $0x8,%esp
  800711:	53                   	push   %ebx
  800712:	6a 30                	push   $0x30
  800714:	ff d6                	call   *%esi
			putch('x', putdat);
  800716:	83 c4 08             	add    $0x8,%esp
  800719:	53                   	push   %ebx
  80071a:	6a 78                	push   $0x78
  80071c:	ff d6                	call   *%esi
			num = (unsigned long long)
  80071e:	8b 45 14             	mov    0x14(%ebp),%eax
  800721:	8b 10                	mov    (%eax),%edx
  800723:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800728:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80072b:	8d 40 04             	lea    0x4(%eax),%eax
  80072e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800731:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800736:	eb 4a                	jmp    800782 <vprintfmt+0x476>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800738:	83 f9 01             	cmp    $0x1,%ecx
  80073b:	7e 15                	jle    800752 <vprintfmt+0x446>
		return va_arg(*ap, unsigned long long);
  80073d:	8b 45 14             	mov    0x14(%ebp),%eax
  800740:	8b 10                	mov    (%eax),%edx
  800742:	8b 48 04             	mov    0x4(%eax),%ecx
  800745:	8d 40 08             	lea    0x8(%eax),%eax
  800748:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80074b:	b8 10 00 00 00       	mov    $0x10,%eax
  800750:	eb 30                	jmp    800782 <vprintfmt+0x476>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800752:	85 c9                	test   %ecx,%ecx
  800754:	74 17                	je     80076d <vprintfmt+0x461>
		return va_arg(*ap, unsigned long);
  800756:	8b 45 14             	mov    0x14(%ebp),%eax
  800759:	8b 10                	mov    (%eax),%edx
  80075b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800760:	8d 40 04             	lea    0x4(%eax),%eax
  800763:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800766:	b8 10 00 00 00       	mov    $0x10,%eax
  80076b:	eb 15                	jmp    800782 <vprintfmt+0x476>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80076d:	8b 45 14             	mov    0x14(%ebp),%eax
  800770:	8b 10                	mov    (%eax),%edx
  800772:	b9 00 00 00 00       	mov    $0x0,%ecx
  800777:	8d 40 04             	lea    0x4(%eax),%eax
  80077a:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80077d:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800782:	83 ec 0c             	sub    $0xc,%esp
  800785:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800789:	57                   	push   %edi
  80078a:	ff 75 e0             	pushl  -0x20(%ebp)
  80078d:	50                   	push   %eax
  80078e:	51                   	push   %ecx
  80078f:	52                   	push   %edx
  800790:	89 da                	mov    %ebx,%edx
  800792:	89 f0                	mov    %esi,%eax
  800794:	e8 8a fa ff ff       	call   800223 <printnum>
			break;
  800799:	83 c4 20             	add    $0x20,%esp
  80079c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80079f:	e9 8e fb ff ff       	jmp    800332 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007a4:	83 ec 08             	sub    $0x8,%esp
  8007a7:	53                   	push   %ebx
  8007a8:	52                   	push   %edx
  8007a9:	ff d6                	call   *%esi
			break;
  8007ab:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007b1:	e9 7c fb ff ff       	jmp    800332 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007b6:	83 ec 08             	sub    $0x8,%esp
  8007b9:	53                   	push   %ebx
  8007ba:	6a 25                	push   $0x25
  8007bc:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007be:	83 c4 10             	add    $0x10,%esp
  8007c1:	eb 03                	jmp    8007c6 <vprintfmt+0x4ba>
  8007c3:	83 ef 01             	sub    $0x1,%edi
  8007c6:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007ca:	75 f7                	jne    8007c3 <vprintfmt+0x4b7>
  8007cc:	e9 61 fb ff ff       	jmp    800332 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8007d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007d4:	5b                   	pop    %ebx
  8007d5:	5e                   	pop    %esi
  8007d6:	5f                   	pop    %edi
  8007d7:	5d                   	pop    %ebp
  8007d8:	c3                   	ret    

008007d9 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007d9:	55                   	push   %ebp
  8007da:	89 e5                	mov    %esp,%ebp
  8007dc:	83 ec 18             	sub    $0x18,%esp
  8007df:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e2:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007e5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007e8:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007ec:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007ef:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007f6:	85 c0                	test   %eax,%eax
  8007f8:	74 26                	je     800820 <vsnprintf+0x47>
  8007fa:	85 d2                	test   %edx,%edx
  8007fc:	7e 22                	jle    800820 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007fe:	ff 75 14             	pushl  0x14(%ebp)
  800801:	ff 75 10             	pushl  0x10(%ebp)
  800804:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800807:	50                   	push   %eax
  800808:	68 d2 02 80 00       	push   $0x8002d2
  80080d:	e8 fa fa ff ff       	call   80030c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800812:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800815:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800818:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80081b:	83 c4 10             	add    $0x10,%esp
  80081e:	eb 05                	jmp    800825 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800820:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800825:	c9                   	leave  
  800826:	c3                   	ret    

00800827 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800827:	55                   	push   %ebp
  800828:	89 e5                	mov    %esp,%ebp
  80082a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80082d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800830:	50                   	push   %eax
  800831:	ff 75 10             	pushl  0x10(%ebp)
  800834:	ff 75 0c             	pushl  0xc(%ebp)
  800837:	ff 75 08             	pushl  0x8(%ebp)
  80083a:	e8 9a ff ff ff       	call   8007d9 <vsnprintf>
	va_end(ap);

	return rc;
}
  80083f:	c9                   	leave  
  800840:	c3                   	ret    

00800841 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800841:	55                   	push   %ebp
  800842:	89 e5                	mov    %esp,%ebp
  800844:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800847:	b8 00 00 00 00       	mov    $0x0,%eax
  80084c:	eb 03                	jmp    800851 <strlen+0x10>
		n++;
  80084e:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800851:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800855:	75 f7                	jne    80084e <strlen+0xd>
		n++;
	return n;
}
  800857:	5d                   	pop    %ebp
  800858:	c3                   	ret    

00800859 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800859:	55                   	push   %ebp
  80085a:	89 e5                	mov    %esp,%ebp
  80085c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80085f:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800862:	ba 00 00 00 00       	mov    $0x0,%edx
  800867:	eb 03                	jmp    80086c <strnlen+0x13>
		n++;
  800869:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80086c:	39 c2                	cmp    %eax,%edx
  80086e:	74 08                	je     800878 <strnlen+0x1f>
  800870:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800874:	75 f3                	jne    800869 <strnlen+0x10>
  800876:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800878:	5d                   	pop    %ebp
  800879:	c3                   	ret    

0080087a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80087a:	55                   	push   %ebp
  80087b:	89 e5                	mov    %esp,%ebp
  80087d:	53                   	push   %ebx
  80087e:	8b 45 08             	mov    0x8(%ebp),%eax
  800881:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800884:	89 c2                	mov    %eax,%edx
  800886:	83 c2 01             	add    $0x1,%edx
  800889:	83 c1 01             	add    $0x1,%ecx
  80088c:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800890:	88 5a ff             	mov    %bl,-0x1(%edx)
  800893:	84 db                	test   %bl,%bl
  800895:	75 ef                	jne    800886 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800897:	5b                   	pop    %ebx
  800898:	5d                   	pop    %ebp
  800899:	c3                   	ret    

0080089a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80089a:	55                   	push   %ebp
  80089b:	89 e5                	mov    %esp,%ebp
  80089d:	53                   	push   %ebx
  80089e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008a1:	53                   	push   %ebx
  8008a2:	e8 9a ff ff ff       	call   800841 <strlen>
  8008a7:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008aa:	ff 75 0c             	pushl  0xc(%ebp)
  8008ad:	01 d8                	add    %ebx,%eax
  8008af:	50                   	push   %eax
  8008b0:	e8 c5 ff ff ff       	call   80087a <strcpy>
	return dst;
}
  8008b5:	89 d8                	mov    %ebx,%eax
  8008b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008ba:	c9                   	leave  
  8008bb:	c3                   	ret    

008008bc <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008bc:	55                   	push   %ebp
  8008bd:	89 e5                	mov    %esp,%ebp
  8008bf:	56                   	push   %esi
  8008c0:	53                   	push   %ebx
  8008c1:	8b 75 08             	mov    0x8(%ebp),%esi
  8008c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008c7:	89 f3                	mov    %esi,%ebx
  8008c9:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008cc:	89 f2                	mov    %esi,%edx
  8008ce:	eb 0f                	jmp    8008df <strncpy+0x23>
		*dst++ = *src;
  8008d0:	83 c2 01             	add    $0x1,%edx
  8008d3:	0f b6 01             	movzbl (%ecx),%eax
  8008d6:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008d9:	80 39 01             	cmpb   $0x1,(%ecx)
  8008dc:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008df:	39 da                	cmp    %ebx,%edx
  8008e1:	75 ed                	jne    8008d0 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008e3:	89 f0                	mov    %esi,%eax
  8008e5:	5b                   	pop    %ebx
  8008e6:	5e                   	pop    %esi
  8008e7:	5d                   	pop    %ebp
  8008e8:	c3                   	ret    

008008e9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008e9:	55                   	push   %ebp
  8008ea:	89 e5                	mov    %esp,%ebp
  8008ec:	56                   	push   %esi
  8008ed:	53                   	push   %ebx
  8008ee:	8b 75 08             	mov    0x8(%ebp),%esi
  8008f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008f4:	8b 55 10             	mov    0x10(%ebp),%edx
  8008f7:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008f9:	85 d2                	test   %edx,%edx
  8008fb:	74 21                	je     80091e <strlcpy+0x35>
  8008fd:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800901:	89 f2                	mov    %esi,%edx
  800903:	eb 09                	jmp    80090e <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800905:	83 c2 01             	add    $0x1,%edx
  800908:	83 c1 01             	add    $0x1,%ecx
  80090b:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80090e:	39 c2                	cmp    %eax,%edx
  800910:	74 09                	je     80091b <strlcpy+0x32>
  800912:	0f b6 19             	movzbl (%ecx),%ebx
  800915:	84 db                	test   %bl,%bl
  800917:	75 ec                	jne    800905 <strlcpy+0x1c>
  800919:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80091b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80091e:	29 f0                	sub    %esi,%eax
}
  800920:	5b                   	pop    %ebx
  800921:	5e                   	pop    %esi
  800922:	5d                   	pop    %ebp
  800923:	c3                   	ret    

00800924 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800924:	55                   	push   %ebp
  800925:	89 e5                	mov    %esp,%ebp
  800927:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80092a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80092d:	eb 06                	jmp    800935 <strcmp+0x11>
		p++, q++;
  80092f:	83 c1 01             	add    $0x1,%ecx
  800932:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800935:	0f b6 01             	movzbl (%ecx),%eax
  800938:	84 c0                	test   %al,%al
  80093a:	74 04                	je     800940 <strcmp+0x1c>
  80093c:	3a 02                	cmp    (%edx),%al
  80093e:	74 ef                	je     80092f <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800940:	0f b6 c0             	movzbl %al,%eax
  800943:	0f b6 12             	movzbl (%edx),%edx
  800946:	29 d0                	sub    %edx,%eax
}
  800948:	5d                   	pop    %ebp
  800949:	c3                   	ret    

0080094a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80094a:	55                   	push   %ebp
  80094b:	89 e5                	mov    %esp,%ebp
  80094d:	53                   	push   %ebx
  80094e:	8b 45 08             	mov    0x8(%ebp),%eax
  800951:	8b 55 0c             	mov    0xc(%ebp),%edx
  800954:	89 c3                	mov    %eax,%ebx
  800956:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800959:	eb 06                	jmp    800961 <strncmp+0x17>
		n--, p++, q++;
  80095b:	83 c0 01             	add    $0x1,%eax
  80095e:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800961:	39 d8                	cmp    %ebx,%eax
  800963:	74 15                	je     80097a <strncmp+0x30>
  800965:	0f b6 08             	movzbl (%eax),%ecx
  800968:	84 c9                	test   %cl,%cl
  80096a:	74 04                	je     800970 <strncmp+0x26>
  80096c:	3a 0a                	cmp    (%edx),%cl
  80096e:	74 eb                	je     80095b <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800970:	0f b6 00             	movzbl (%eax),%eax
  800973:	0f b6 12             	movzbl (%edx),%edx
  800976:	29 d0                	sub    %edx,%eax
  800978:	eb 05                	jmp    80097f <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80097a:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80097f:	5b                   	pop    %ebx
  800980:	5d                   	pop    %ebp
  800981:	c3                   	ret    

00800982 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800982:	55                   	push   %ebp
  800983:	89 e5                	mov    %esp,%ebp
  800985:	8b 45 08             	mov    0x8(%ebp),%eax
  800988:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80098c:	eb 07                	jmp    800995 <strchr+0x13>
		if (*s == c)
  80098e:	38 ca                	cmp    %cl,%dl
  800990:	74 0f                	je     8009a1 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800992:	83 c0 01             	add    $0x1,%eax
  800995:	0f b6 10             	movzbl (%eax),%edx
  800998:	84 d2                	test   %dl,%dl
  80099a:	75 f2                	jne    80098e <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80099c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009a1:	5d                   	pop    %ebp
  8009a2:	c3                   	ret    

008009a3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009a3:	55                   	push   %ebp
  8009a4:	89 e5                	mov    %esp,%ebp
  8009a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009ad:	eb 03                	jmp    8009b2 <strfind+0xf>
  8009af:	83 c0 01             	add    $0x1,%eax
  8009b2:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009b5:	38 ca                	cmp    %cl,%dl
  8009b7:	74 04                	je     8009bd <strfind+0x1a>
  8009b9:	84 d2                	test   %dl,%dl
  8009bb:	75 f2                	jne    8009af <strfind+0xc>
			break;
	return (char *) s;
}
  8009bd:	5d                   	pop    %ebp
  8009be:	c3                   	ret    

008009bf <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009bf:	55                   	push   %ebp
  8009c0:	89 e5                	mov    %esp,%ebp
  8009c2:	57                   	push   %edi
  8009c3:	56                   	push   %esi
  8009c4:	53                   	push   %ebx
  8009c5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009c8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009cb:	85 c9                	test   %ecx,%ecx
  8009cd:	74 36                	je     800a05 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009cf:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009d5:	75 28                	jne    8009ff <memset+0x40>
  8009d7:	f6 c1 03             	test   $0x3,%cl
  8009da:	75 23                	jne    8009ff <memset+0x40>
		c &= 0xFF;
  8009dc:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009e0:	89 d3                	mov    %edx,%ebx
  8009e2:	c1 e3 08             	shl    $0x8,%ebx
  8009e5:	89 d6                	mov    %edx,%esi
  8009e7:	c1 e6 18             	shl    $0x18,%esi
  8009ea:	89 d0                	mov    %edx,%eax
  8009ec:	c1 e0 10             	shl    $0x10,%eax
  8009ef:	09 f0                	or     %esi,%eax
  8009f1:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8009f3:	89 d8                	mov    %ebx,%eax
  8009f5:	09 d0                	or     %edx,%eax
  8009f7:	c1 e9 02             	shr    $0x2,%ecx
  8009fa:	fc                   	cld    
  8009fb:	f3 ab                	rep stos %eax,%es:(%edi)
  8009fd:	eb 06                	jmp    800a05 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a02:	fc                   	cld    
  800a03:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a05:	89 f8                	mov    %edi,%eax
  800a07:	5b                   	pop    %ebx
  800a08:	5e                   	pop    %esi
  800a09:	5f                   	pop    %edi
  800a0a:	5d                   	pop    %ebp
  800a0b:	c3                   	ret    

00800a0c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a0c:	55                   	push   %ebp
  800a0d:	89 e5                	mov    %esp,%ebp
  800a0f:	57                   	push   %edi
  800a10:	56                   	push   %esi
  800a11:	8b 45 08             	mov    0x8(%ebp),%eax
  800a14:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a17:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a1a:	39 c6                	cmp    %eax,%esi
  800a1c:	73 35                	jae    800a53 <memmove+0x47>
  800a1e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a21:	39 d0                	cmp    %edx,%eax
  800a23:	73 2e                	jae    800a53 <memmove+0x47>
		s += n;
		d += n;
  800a25:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a28:	89 d6                	mov    %edx,%esi
  800a2a:	09 fe                	or     %edi,%esi
  800a2c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a32:	75 13                	jne    800a47 <memmove+0x3b>
  800a34:	f6 c1 03             	test   $0x3,%cl
  800a37:	75 0e                	jne    800a47 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a39:	83 ef 04             	sub    $0x4,%edi
  800a3c:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a3f:	c1 e9 02             	shr    $0x2,%ecx
  800a42:	fd                   	std    
  800a43:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a45:	eb 09                	jmp    800a50 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a47:	83 ef 01             	sub    $0x1,%edi
  800a4a:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a4d:	fd                   	std    
  800a4e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a50:	fc                   	cld    
  800a51:	eb 1d                	jmp    800a70 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a53:	89 f2                	mov    %esi,%edx
  800a55:	09 c2                	or     %eax,%edx
  800a57:	f6 c2 03             	test   $0x3,%dl
  800a5a:	75 0f                	jne    800a6b <memmove+0x5f>
  800a5c:	f6 c1 03             	test   $0x3,%cl
  800a5f:	75 0a                	jne    800a6b <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a61:	c1 e9 02             	shr    $0x2,%ecx
  800a64:	89 c7                	mov    %eax,%edi
  800a66:	fc                   	cld    
  800a67:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a69:	eb 05                	jmp    800a70 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a6b:	89 c7                	mov    %eax,%edi
  800a6d:	fc                   	cld    
  800a6e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a70:	5e                   	pop    %esi
  800a71:	5f                   	pop    %edi
  800a72:	5d                   	pop    %ebp
  800a73:	c3                   	ret    

00800a74 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a74:	55                   	push   %ebp
  800a75:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a77:	ff 75 10             	pushl  0x10(%ebp)
  800a7a:	ff 75 0c             	pushl  0xc(%ebp)
  800a7d:	ff 75 08             	pushl  0x8(%ebp)
  800a80:	e8 87 ff ff ff       	call   800a0c <memmove>
}
  800a85:	c9                   	leave  
  800a86:	c3                   	ret    

00800a87 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a87:	55                   	push   %ebp
  800a88:	89 e5                	mov    %esp,%ebp
  800a8a:	56                   	push   %esi
  800a8b:	53                   	push   %ebx
  800a8c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a92:	89 c6                	mov    %eax,%esi
  800a94:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a97:	eb 1a                	jmp    800ab3 <memcmp+0x2c>
		if (*s1 != *s2)
  800a99:	0f b6 08             	movzbl (%eax),%ecx
  800a9c:	0f b6 1a             	movzbl (%edx),%ebx
  800a9f:	38 d9                	cmp    %bl,%cl
  800aa1:	74 0a                	je     800aad <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800aa3:	0f b6 c1             	movzbl %cl,%eax
  800aa6:	0f b6 db             	movzbl %bl,%ebx
  800aa9:	29 d8                	sub    %ebx,%eax
  800aab:	eb 0f                	jmp    800abc <memcmp+0x35>
		s1++, s2++;
  800aad:	83 c0 01             	add    $0x1,%eax
  800ab0:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ab3:	39 f0                	cmp    %esi,%eax
  800ab5:	75 e2                	jne    800a99 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ab7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800abc:	5b                   	pop    %ebx
  800abd:	5e                   	pop    %esi
  800abe:	5d                   	pop    %ebp
  800abf:	c3                   	ret    

00800ac0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ac0:	55                   	push   %ebp
  800ac1:	89 e5                	mov    %esp,%ebp
  800ac3:	53                   	push   %ebx
  800ac4:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ac7:	89 c1                	mov    %eax,%ecx
  800ac9:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800acc:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ad0:	eb 0a                	jmp    800adc <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ad2:	0f b6 10             	movzbl (%eax),%edx
  800ad5:	39 da                	cmp    %ebx,%edx
  800ad7:	74 07                	je     800ae0 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ad9:	83 c0 01             	add    $0x1,%eax
  800adc:	39 c8                	cmp    %ecx,%eax
  800ade:	72 f2                	jb     800ad2 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ae0:	5b                   	pop    %ebx
  800ae1:	5d                   	pop    %ebp
  800ae2:	c3                   	ret    

00800ae3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ae3:	55                   	push   %ebp
  800ae4:	89 e5                	mov    %esp,%ebp
  800ae6:	57                   	push   %edi
  800ae7:	56                   	push   %esi
  800ae8:	53                   	push   %ebx
  800ae9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aec:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aef:	eb 03                	jmp    800af4 <strtol+0x11>
		s++;
  800af1:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800af4:	0f b6 01             	movzbl (%ecx),%eax
  800af7:	3c 20                	cmp    $0x20,%al
  800af9:	74 f6                	je     800af1 <strtol+0xe>
  800afb:	3c 09                	cmp    $0x9,%al
  800afd:	74 f2                	je     800af1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800aff:	3c 2b                	cmp    $0x2b,%al
  800b01:	75 0a                	jne    800b0d <strtol+0x2a>
		s++;
  800b03:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b06:	bf 00 00 00 00       	mov    $0x0,%edi
  800b0b:	eb 11                	jmp    800b1e <strtol+0x3b>
  800b0d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b12:	3c 2d                	cmp    $0x2d,%al
  800b14:	75 08                	jne    800b1e <strtol+0x3b>
		s++, neg = 1;
  800b16:	83 c1 01             	add    $0x1,%ecx
  800b19:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b1e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b24:	75 15                	jne    800b3b <strtol+0x58>
  800b26:	80 39 30             	cmpb   $0x30,(%ecx)
  800b29:	75 10                	jne    800b3b <strtol+0x58>
  800b2b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b2f:	75 7c                	jne    800bad <strtol+0xca>
		s += 2, base = 16;
  800b31:	83 c1 02             	add    $0x2,%ecx
  800b34:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b39:	eb 16                	jmp    800b51 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b3b:	85 db                	test   %ebx,%ebx
  800b3d:	75 12                	jne    800b51 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b3f:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b44:	80 39 30             	cmpb   $0x30,(%ecx)
  800b47:	75 08                	jne    800b51 <strtol+0x6e>
		s++, base = 8;
  800b49:	83 c1 01             	add    $0x1,%ecx
  800b4c:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b51:	b8 00 00 00 00       	mov    $0x0,%eax
  800b56:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b59:	0f b6 11             	movzbl (%ecx),%edx
  800b5c:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b5f:	89 f3                	mov    %esi,%ebx
  800b61:	80 fb 09             	cmp    $0x9,%bl
  800b64:	77 08                	ja     800b6e <strtol+0x8b>
			dig = *s - '0';
  800b66:	0f be d2             	movsbl %dl,%edx
  800b69:	83 ea 30             	sub    $0x30,%edx
  800b6c:	eb 22                	jmp    800b90 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b6e:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b71:	89 f3                	mov    %esi,%ebx
  800b73:	80 fb 19             	cmp    $0x19,%bl
  800b76:	77 08                	ja     800b80 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b78:	0f be d2             	movsbl %dl,%edx
  800b7b:	83 ea 57             	sub    $0x57,%edx
  800b7e:	eb 10                	jmp    800b90 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b80:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b83:	89 f3                	mov    %esi,%ebx
  800b85:	80 fb 19             	cmp    $0x19,%bl
  800b88:	77 16                	ja     800ba0 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b8a:	0f be d2             	movsbl %dl,%edx
  800b8d:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b90:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b93:	7d 0b                	jge    800ba0 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b95:	83 c1 01             	add    $0x1,%ecx
  800b98:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b9c:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b9e:	eb b9                	jmp    800b59 <strtol+0x76>

	if (endptr)
  800ba0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ba4:	74 0d                	je     800bb3 <strtol+0xd0>
		*endptr = (char *) s;
  800ba6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ba9:	89 0e                	mov    %ecx,(%esi)
  800bab:	eb 06                	jmp    800bb3 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bad:	85 db                	test   %ebx,%ebx
  800baf:	74 98                	je     800b49 <strtol+0x66>
  800bb1:	eb 9e                	jmp    800b51 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800bb3:	89 c2                	mov    %eax,%edx
  800bb5:	f7 da                	neg    %edx
  800bb7:	85 ff                	test   %edi,%edi
  800bb9:	0f 45 c2             	cmovne %edx,%eax
}
  800bbc:	5b                   	pop    %ebx
  800bbd:	5e                   	pop    %esi
  800bbe:	5f                   	pop    %edi
  800bbf:	5d                   	pop    %ebp
  800bc0:	c3                   	ret    
  800bc1:	66 90                	xchg   %ax,%ax
  800bc3:	66 90                	xchg   %ax,%ax
  800bc5:	66 90                	xchg   %ax,%ax
  800bc7:	66 90                	xchg   %ax,%ax
  800bc9:	66 90                	xchg   %ax,%ax
  800bcb:	66 90                	xchg   %ax,%ax
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
