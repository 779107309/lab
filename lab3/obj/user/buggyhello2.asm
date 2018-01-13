
obj/user/buggyhello2：     文件格式 elf32-i386


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
  80002c:	e8 1d 00 00 00       	call   80004e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_cputs(hello, 1024*1024);
  800039:	68 00 00 10 00       	push   $0x100000
  80003e:	ff 35 00 20 80 00    	pushl  0x802000
  800044:	e8 60 00 00 00       	call   8000a9 <sys_cputs>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800056:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t i = sys_getenvid();
  800059:	e8 c9 00 00 00       	call   800127 <sys_getenvid>
    thisenv = &envs[ENVX(i)];
  80005e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800063:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800066:	c1 e0 05             	shl    $0x5,%eax
  800069:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006e:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800073:	85 db                	test   %ebx,%ebx
  800075:	7e 07                	jle    80007e <libmain+0x30>
		binaryname = argv[0];
  800077:	8b 06                	mov    (%esi),%eax
  800079:	a3 04 20 80 00       	mov    %eax,0x802004

	// call user main routine
	umain(argc, argv);
  80007e:	83 ec 08             	sub    $0x8,%esp
  800081:	56                   	push   %esi
  800082:	53                   	push   %ebx
  800083:	e8 ab ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800088:	e8 0a 00 00 00       	call   800097 <exit>
}
  80008d:	83 c4 10             	add    $0x10,%esp
  800090:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800093:	5b                   	pop    %ebx
  800094:	5e                   	pop    %esi
  800095:	5d                   	pop    %ebp
  800096:	c3                   	ret    

00800097 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800097:	55                   	push   %ebp
  800098:	89 e5                	mov    %esp,%ebp
  80009a:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80009d:	6a 00                	push   $0x0
  80009f:	e8 42 00 00 00       	call   8000e6 <sys_env_destroy>
}
  8000a4:	83 c4 10             	add    $0x10,%esp
  8000a7:	c9                   	leave  
  8000a8:	c3                   	ret    

008000a9 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a9:	55                   	push   %ebp
  8000aa:	89 e5                	mov    %esp,%ebp
  8000ac:	57                   	push   %edi
  8000ad:	56                   	push   %esi
  8000ae:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000af:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ba:	89 c3                	mov    %eax,%ebx
  8000bc:	89 c7                	mov    %eax,%edi
  8000be:	89 c6                	mov    %eax,%esi
  8000c0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c2:	5b                   	pop    %ebx
  8000c3:	5e                   	pop    %esi
  8000c4:	5f                   	pop    %edi
  8000c5:	5d                   	pop    %ebp
  8000c6:	c3                   	ret    

008000c7 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c7:	55                   	push   %ebp
  8000c8:	89 e5                	mov    %esp,%ebp
  8000ca:	57                   	push   %edi
  8000cb:	56                   	push   %esi
  8000cc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d2:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d7:	89 d1                	mov    %edx,%ecx
  8000d9:	89 d3                	mov    %edx,%ebx
  8000db:	89 d7                	mov    %edx,%edi
  8000dd:	89 d6                	mov    %edx,%esi
  8000df:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e1:	5b                   	pop    %ebx
  8000e2:	5e                   	pop    %esi
  8000e3:	5f                   	pop    %edi
  8000e4:	5d                   	pop    %ebp
  8000e5:	c3                   	ret    

008000e6 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e6:	55                   	push   %ebp
  8000e7:	89 e5                	mov    %esp,%ebp
  8000e9:	57                   	push   %edi
  8000ea:	56                   	push   %esi
  8000eb:	53                   	push   %ebx
  8000ec:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ef:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f4:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fc:	89 cb                	mov    %ecx,%ebx
  8000fe:	89 cf                	mov    %ecx,%edi
  800100:	89 ce                	mov    %ecx,%esi
  800102:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800104:	85 c0                	test   %eax,%eax
  800106:	7e 17                	jle    80011f <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800108:	83 ec 0c             	sub    $0xc,%esp
  80010b:	50                   	push   %eax
  80010c:	6a 03                	push   $0x3
  80010e:	68 98 0e 80 00       	push   $0x800e98
  800113:	6a 23                	push   $0x23
  800115:	68 b5 0e 80 00       	push   $0x800eb5
  80011a:	e8 27 00 00 00       	call   800146 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80011f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800122:	5b                   	pop    %ebx
  800123:	5e                   	pop    %esi
  800124:	5f                   	pop    %edi
  800125:	5d                   	pop    %ebp
  800126:	c3                   	ret    

00800127 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800127:	55                   	push   %ebp
  800128:	89 e5                	mov    %esp,%ebp
  80012a:	57                   	push   %edi
  80012b:	56                   	push   %esi
  80012c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80012d:	ba 00 00 00 00       	mov    $0x0,%edx
  800132:	b8 02 00 00 00       	mov    $0x2,%eax
  800137:	89 d1                	mov    %edx,%ecx
  800139:	89 d3                	mov    %edx,%ebx
  80013b:	89 d7                	mov    %edx,%edi
  80013d:	89 d6                	mov    %edx,%esi
  80013f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800141:	5b                   	pop    %ebx
  800142:	5e                   	pop    %esi
  800143:	5f                   	pop    %edi
  800144:	5d                   	pop    %ebp
  800145:	c3                   	ret    

00800146 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800146:	55                   	push   %ebp
  800147:	89 e5                	mov    %esp,%ebp
  800149:	56                   	push   %esi
  80014a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80014b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80014e:	8b 35 04 20 80 00    	mov    0x802004,%esi
  800154:	e8 ce ff ff ff       	call   800127 <sys_getenvid>
  800159:	83 ec 0c             	sub    $0xc,%esp
  80015c:	ff 75 0c             	pushl  0xc(%ebp)
  80015f:	ff 75 08             	pushl  0x8(%ebp)
  800162:	56                   	push   %esi
  800163:	50                   	push   %eax
  800164:	68 c4 0e 80 00       	push   $0x800ec4
  800169:	e8 b1 00 00 00       	call   80021f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80016e:	83 c4 18             	add    $0x18,%esp
  800171:	53                   	push   %ebx
  800172:	ff 75 10             	pushl  0x10(%ebp)
  800175:	e8 54 00 00 00       	call   8001ce <vcprintf>
	cprintf("\n");
  80017a:	c7 04 24 8c 0e 80 00 	movl   $0x800e8c,(%esp)
  800181:	e8 99 00 00 00       	call   80021f <cprintf>
  800186:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800189:	cc                   	int3   
  80018a:	eb fd                	jmp    800189 <_panic+0x43>

0080018c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80018c:	55                   	push   %ebp
  80018d:	89 e5                	mov    %esp,%ebp
  80018f:	53                   	push   %ebx
  800190:	83 ec 04             	sub    $0x4,%esp
  800193:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800196:	8b 13                	mov    (%ebx),%edx
  800198:	8d 42 01             	lea    0x1(%edx),%eax
  80019b:	89 03                	mov    %eax,(%ebx)
  80019d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001a0:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001a4:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001a9:	75 1a                	jne    8001c5 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001ab:	83 ec 08             	sub    $0x8,%esp
  8001ae:	68 ff 00 00 00       	push   $0xff
  8001b3:	8d 43 08             	lea    0x8(%ebx),%eax
  8001b6:	50                   	push   %eax
  8001b7:	e8 ed fe ff ff       	call   8000a9 <sys_cputs>
		b->idx = 0;
  8001bc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001c2:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001c5:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001cc:	c9                   	leave  
  8001cd:	c3                   	ret    

008001ce <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001ce:	55                   	push   %ebp
  8001cf:	89 e5                	mov    %esp,%ebp
  8001d1:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001d7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001de:	00 00 00 
	b.cnt = 0;
  8001e1:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001e8:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001eb:	ff 75 0c             	pushl  0xc(%ebp)
  8001ee:	ff 75 08             	pushl  0x8(%ebp)
  8001f1:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001f7:	50                   	push   %eax
  8001f8:	68 8c 01 80 00       	push   $0x80018c
  8001fd:	e8 1a 01 00 00       	call   80031c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800202:	83 c4 08             	add    $0x8,%esp
  800205:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80020b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800211:	50                   	push   %eax
  800212:	e8 92 fe ff ff       	call   8000a9 <sys_cputs>

	return b.cnt;
}
  800217:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80021d:	c9                   	leave  
  80021e:	c3                   	ret    

0080021f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80021f:	55                   	push   %ebp
  800220:	89 e5                	mov    %esp,%ebp
  800222:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800225:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800228:	50                   	push   %eax
  800229:	ff 75 08             	pushl  0x8(%ebp)
  80022c:	e8 9d ff ff ff       	call   8001ce <vcprintf>
	va_end(ap);

	return cnt;
}
  800231:	c9                   	leave  
  800232:	c3                   	ret    

00800233 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800233:	55                   	push   %ebp
  800234:	89 e5                	mov    %esp,%ebp
  800236:	57                   	push   %edi
  800237:	56                   	push   %esi
  800238:	53                   	push   %ebx
  800239:	83 ec 1c             	sub    $0x1c,%esp
  80023c:	89 c7                	mov    %eax,%edi
  80023e:	89 d6                	mov    %edx,%esi
  800240:	8b 45 08             	mov    0x8(%ebp),%eax
  800243:	8b 55 0c             	mov    0xc(%ebp),%edx
  800246:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800249:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80024c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80024f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800254:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800257:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80025a:	39 d3                	cmp    %edx,%ebx
  80025c:	72 05                	jb     800263 <printnum+0x30>
  80025e:	39 45 10             	cmp    %eax,0x10(%ebp)
  800261:	77 45                	ja     8002a8 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800263:	83 ec 0c             	sub    $0xc,%esp
  800266:	ff 75 18             	pushl  0x18(%ebp)
  800269:	8b 45 14             	mov    0x14(%ebp),%eax
  80026c:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80026f:	53                   	push   %ebx
  800270:	ff 75 10             	pushl  0x10(%ebp)
  800273:	83 ec 08             	sub    $0x8,%esp
  800276:	ff 75 e4             	pushl  -0x1c(%ebp)
  800279:	ff 75 e0             	pushl  -0x20(%ebp)
  80027c:	ff 75 dc             	pushl  -0x24(%ebp)
  80027f:	ff 75 d8             	pushl  -0x28(%ebp)
  800282:	e8 59 09 00 00       	call   800be0 <__udivdi3>
  800287:	83 c4 18             	add    $0x18,%esp
  80028a:	52                   	push   %edx
  80028b:	50                   	push   %eax
  80028c:	89 f2                	mov    %esi,%edx
  80028e:	89 f8                	mov    %edi,%eax
  800290:	e8 9e ff ff ff       	call   800233 <printnum>
  800295:	83 c4 20             	add    $0x20,%esp
  800298:	eb 18                	jmp    8002b2 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80029a:	83 ec 08             	sub    $0x8,%esp
  80029d:	56                   	push   %esi
  80029e:	ff 75 18             	pushl  0x18(%ebp)
  8002a1:	ff d7                	call   *%edi
  8002a3:	83 c4 10             	add    $0x10,%esp
  8002a6:	eb 03                	jmp    8002ab <printnum+0x78>
  8002a8:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002ab:	83 eb 01             	sub    $0x1,%ebx
  8002ae:	85 db                	test   %ebx,%ebx
  8002b0:	7f e8                	jg     80029a <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002b2:	83 ec 08             	sub    $0x8,%esp
  8002b5:	56                   	push   %esi
  8002b6:	83 ec 04             	sub    $0x4,%esp
  8002b9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002bc:	ff 75 e0             	pushl  -0x20(%ebp)
  8002bf:	ff 75 dc             	pushl  -0x24(%ebp)
  8002c2:	ff 75 d8             	pushl  -0x28(%ebp)
  8002c5:	e8 46 0a 00 00       	call   800d10 <__umoddi3>
  8002ca:	83 c4 14             	add    $0x14,%esp
  8002cd:	0f be 80 e8 0e 80 00 	movsbl 0x800ee8(%eax),%eax
  8002d4:	50                   	push   %eax
  8002d5:	ff d7                	call   *%edi
}
  8002d7:	83 c4 10             	add    $0x10,%esp
  8002da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002dd:	5b                   	pop    %ebx
  8002de:	5e                   	pop    %esi
  8002df:	5f                   	pop    %edi
  8002e0:	5d                   	pop    %ebp
  8002e1:	c3                   	ret    

008002e2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002e2:	55                   	push   %ebp
  8002e3:	89 e5                	mov    %esp,%ebp
  8002e5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002e8:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002ec:	8b 10                	mov    (%eax),%edx
  8002ee:	3b 50 04             	cmp    0x4(%eax),%edx
  8002f1:	73 0a                	jae    8002fd <sprintputch+0x1b>
		*b->buf++ = ch;
  8002f3:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002f6:	89 08                	mov    %ecx,(%eax)
  8002f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8002fb:	88 02                	mov    %al,(%edx)
}
  8002fd:	5d                   	pop    %ebp
  8002fe:	c3                   	ret    

008002ff <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002ff:	55                   	push   %ebp
  800300:	89 e5                	mov    %esp,%ebp
  800302:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800305:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800308:	50                   	push   %eax
  800309:	ff 75 10             	pushl  0x10(%ebp)
  80030c:	ff 75 0c             	pushl  0xc(%ebp)
  80030f:	ff 75 08             	pushl  0x8(%ebp)
  800312:	e8 05 00 00 00       	call   80031c <vprintfmt>
	va_end(ap);
}
  800317:	83 c4 10             	add    $0x10,%esp
  80031a:	c9                   	leave  
  80031b:	c3                   	ret    

0080031c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80031c:	55                   	push   %ebp
  80031d:	89 e5                	mov    %esp,%ebp
  80031f:	57                   	push   %edi
  800320:	56                   	push   %esi
  800321:	53                   	push   %ebx
  800322:	83 ec 2c             	sub    $0x2c,%esp
  800325:	8b 75 08             	mov    0x8(%ebp),%esi
  800328:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80032b:	8b 7d 10             	mov    0x10(%ebp),%edi
  80032e:	eb 12                	jmp    800342 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800330:	85 c0                	test   %eax,%eax
  800332:	0f 84 a9 04 00 00    	je     8007e1 <vprintfmt+0x4c5>
				return;
			putch(ch, putdat);
  800338:	83 ec 08             	sub    $0x8,%esp
  80033b:	53                   	push   %ebx
  80033c:	50                   	push   %eax
  80033d:	ff d6                	call   *%esi
  80033f:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800342:	83 c7 01             	add    $0x1,%edi
  800345:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800349:	83 f8 25             	cmp    $0x25,%eax
  80034c:	75 e2                	jne    800330 <vprintfmt+0x14>
  80034e:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800352:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800359:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800360:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800367:	b9 00 00 00 00       	mov    $0x0,%ecx
  80036c:	eb 07                	jmp    800375 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036e:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800371:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800375:	8d 47 01             	lea    0x1(%edi),%eax
  800378:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80037b:	0f b6 07             	movzbl (%edi),%eax
  80037e:	0f b6 d0             	movzbl %al,%edx
  800381:	83 e8 23             	sub    $0x23,%eax
  800384:	3c 55                	cmp    $0x55,%al
  800386:	0f 87 3a 04 00 00    	ja     8007c6 <vprintfmt+0x4aa>
  80038c:	0f b6 c0             	movzbl %al,%eax
  80038f:	ff 24 85 80 0f 80 00 	jmp    *0x800f80(,%eax,4)
  800396:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800399:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80039d:	eb d6                	jmp    800375 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8003a7:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003aa:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003ad:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003b1:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003b4:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003b7:	83 f9 09             	cmp    $0x9,%ecx
  8003ba:	77 3f                	ja     8003fb <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003bc:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003bf:	eb e9                	jmp    8003aa <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c4:	8b 00                	mov    (%eax),%eax
  8003c6:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cc:	8d 40 04             	lea    0x4(%eax),%eax
  8003cf:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003d5:	eb 2a                	jmp    800401 <vprintfmt+0xe5>
  8003d7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003da:	85 c0                	test   %eax,%eax
  8003dc:	ba 00 00 00 00       	mov    $0x0,%edx
  8003e1:	0f 49 d0             	cmovns %eax,%edx
  8003e4:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ea:	eb 89                	jmp    800375 <vprintfmt+0x59>
  8003ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003ef:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003f6:	e9 7a ff ff ff       	jmp    800375 <vprintfmt+0x59>
  8003fb:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003fe:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800401:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800405:	0f 89 6a ff ff ff    	jns    800375 <vprintfmt+0x59>
				width = precision, precision = -1;
  80040b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80040e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800411:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800418:	e9 58 ff ff ff       	jmp    800375 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80041d:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800420:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800423:	e9 4d ff ff ff       	jmp    800375 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800428:	8b 45 14             	mov    0x14(%ebp),%eax
  80042b:	8d 78 04             	lea    0x4(%eax),%edi
  80042e:	83 ec 08             	sub    $0x8,%esp
  800431:	53                   	push   %ebx
  800432:	ff 30                	pushl  (%eax)
  800434:	ff d6                	call   *%esi
			break;
  800436:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800439:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80043f:	e9 fe fe ff ff       	jmp    800342 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800444:	8b 45 14             	mov    0x14(%ebp),%eax
  800447:	8d 78 04             	lea    0x4(%eax),%edi
  80044a:	8b 00                	mov    (%eax),%eax
  80044c:	99                   	cltd   
  80044d:	31 d0                	xor    %edx,%eax
  80044f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800451:	83 f8 07             	cmp    $0x7,%eax
  800454:	7f 0b                	jg     800461 <vprintfmt+0x145>
  800456:	8b 14 85 e0 10 80 00 	mov    0x8010e0(,%eax,4),%edx
  80045d:	85 d2                	test   %edx,%edx
  80045f:	75 1b                	jne    80047c <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800461:	50                   	push   %eax
  800462:	68 00 0f 80 00       	push   $0x800f00
  800467:	53                   	push   %ebx
  800468:	56                   	push   %esi
  800469:	e8 91 fe ff ff       	call   8002ff <printfmt>
  80046e:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800471:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800474:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800477:	e9 c6 fe ff ff       	jmp    800342 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80047c:	52                   	push   %edx
  80047d:	68 09 0f 80 00       	push   $0x800f09
  800482:	53                   	push   %ebx
  800483:	56                   	push   %esi
  800484:	e8 76 fe ff ff       	call   8002ff <printfmt>
  800489:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80048c:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800492:	e9 ab fe ff ff       	jmp    800342 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800497:	8b 45 14             	mov    0x14(%ebp),%eax
  80049a:	83 c0 04             	add    $0x4,%eax
  80049d:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8004a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a3:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004a5:	85 ff                	test   %edi,%edi
  8004a7:	b8 f9 0e 80 00       	mov    $0x800ef9,%eax
  8004ac:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004af:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004b3:	0f 8e 94 00 00 00    	jle    80054d <vprintfmt+0x231>
  8004b9:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004bd:	0f 84 98 00 00 00    	je     80055b <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c3:	83 ec 08             	sub    $0x8,%esp
  8004c6:	ff 75 d0             	pushl  -0x30(%ebp)
  8004c9:	57                   	push   %edi
  8004ca:	e8 9a 03 00 00       	call   800869 <strnlen>
  8004cf:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004d2:	29 c1                	sub    %eax,%ecx
  8004d4:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8004d7:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004da:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004de:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004e1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004e4:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e6:	eb 0f                	jmp    8004f7 <vprintfmt+0x1db>
					putch(padc, putdat);
  8004e8:	83 ec 08             	sub    $0x8,%esp
  8004eb:	53                   	push   %ebx
  8004ec:	ff 75 e0             	pushl  -0x20(%ebp)
  8004ef:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f1:	83 ef 01             	sub    $0x1,%edi
  8004f4:	83 c4 10             	add    $0x10,%esp
  8004f7:	85 ff                	test   %edi,%edi
  8004f9:	7f ed                	jg     8004e8 <vprintfmt+0x1cc>
  8004fb:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004fe:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800501:	85 c9                	test   %ecx,%ecx
  800503:	b8 00 00 00 00       	mov    $0x0,%eax
  800508:	0f 49 c1             	cmovns %ecx,%eax
  80050b:	29 c1                	sub    %eax,%ecx
  80050d:	89 75 08             	mov    %esi,0x8(%ebp)
  800510:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800513:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800516:	89 cb                	mov    %ecx,%ebx
  800518:	eb 4d                	jmp    800567 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80051a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80051e:	74 1b                	je     80053b <vprintfmt+0x21f>
  800520:	0f be c0             	movsbl %al,%eax
  800523:	83 e8 20             	sub    $0x20,%eax
  800526:	83 f8 5e             	cmp    $0x5e,%eax
  800529:	76 10                	jbe    80053b <vprintfmt+0x21f>
					putch('?', putdat);
  80052b:	83 ec 08             	sub    $0x8,%esp
  80052e:	ff 75 0c             	pushl  0xc(%ebp)
  800531:	6a 3f                	push   $0x3f
  800533:	ff 55 08             	call   *0x8(%ebp)
  800536:	83 c4 10             	add    $0x10,%esp
  800539:	eb 0d                	jmp    800548 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  80053b:	83 ec 08             	sub    $0x8,%esp
  80053e:	ff 75 0c             	pushl  0xc(%ebp)
  800541:	52                   	push   %edx
  800542:	ff 55 08             	call   *0x8(%ebp)
  800545:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800548:	83 eb 01             	sub    $0x1,%ebx
  80054b:	eb 1a                	jmp    800567 <vprintfmt+0x24b>
  80054d:	89 75 08             	mov    %esi,0x8(%ebp)
  800550:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800553:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800556:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800559:	eb 0c                	jmp    800567 <vprintfmt+0x24b>
  80055b:	89 75 08             	mov    %esi,0x8(%ebp)
  80055e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800561:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800564:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800567:	83 c7 01             	add    $0x1,%edi
  80056a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80056e:	0f be d0             	movsbl %al,%edx
  800571:	85 d2                	test   %edx,%edx
  800573:	74 23                	je     800598 <vprintfmt+0x27c>
  800575:	85 f6                	test   %esi,%esi
  800577:	78 a1                	js     80051a <vprintfmt+0x1fe>
  800579:	83 ee 01             	sub    $0x1,%esi
  80057c:	79 9c                	jns    80051a <vprintfmt+0x1fe>
  80057e:	89 df                	mov    %ebx,%edi
  800580:	8b 75 08             	mov    0x8(%ebp),%esi
  800583:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800586:	eb 18                	jmp    8005a0 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800588:	83 ec 08             	sub    $0x8,%esp
  80058b:	53                   	push   %ebx
  80058c:	6a 20                	push   $0x20
  80058e:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800590:	83 ef 01             	sub    $0x1,%edi
  800593:	83 c4 10             	add    $0x10,%esp
  800596:	eb 08                	jmp    8005a0 <vprintfmt+0x284>
  800598:	89 df                	mov    %ebx,%edi
  80059a:	8b 75 08             	mov    0x8(%ebp),%esi
  80059d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005a0:	85 ff                	test   %edi,%edi
  8005a2:	7f e4                	jg     800588 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005a4:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8005a7:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005ad:	e9 90 fd ff ff       	jmp    800342 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005b2:	83 f9 01             	cmp    $0x1,%ecx
  8005b5:	7e 19                	jle    8005d0 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  8005b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ba:	8b 50 04             	mov    0x4(%eax),%edx
  8005bd:	8b 00                	mov    (%eax),%eax
  8005bf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c2:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c8:	8d 40 08             	lea    0x8(%eax),%eax
  8005cb:	89 45 14             	mov    %eax,0x14(%ebp)
  8005ce:	eb 38                	jmp    800608 <vprintfmt+0x2ec>
	else if (lflag)
  8005d0:	85 c9                	test   %ecx,%ecx
  8005d2:	74 1b                	je     8005ef <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8005d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d7:	8b 00                	mov    (%eax),%eax
  8005d9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005dc:	89 c1                	mov    %eax,%ecx
  8005de:	c1 f9 1f             	sar    $0x1f,%ecx
  8005e1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e7:	8d 40 04             	lea    0x4(%eax),%eax
  8005ea:	89 45 14             	mov    %eax,0x14(%ebp)
  8005ed:	eb 19                	jmp    800608 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8005ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f2:	8b 00                	mov    (%eax),%eax
  8005f4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f7:	89 c1                	mov    %eax,%ecx
  8005f9:	c1 f9 1f             	sar    $0x1f,%ecx
  8005fc:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800602:	8d 40 04             	lea    0x4(%eax),%eax
  800605:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800608:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80060b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80060e:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800613:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800617:	0f 89 75 01 00 00    	jns    800792 <vprintfmt+0x476>
				putch('-', putdat);
  80061d:	83 ec 08             	sub    $0x8,%esp
  800620:	53                   	push   %ebx
  800621:	6a 2d                	push   $0x2d
  800623:	ff d6                	call   *%esi
				num = -(long long) num;
  800625:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800628:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80062b:	f7 da                	neg    %edx
  80062d:	83 d1 00             	adc    $0x0,%ecx
  800630:	f7 d9                	neg    %ecx
  800632:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800635:	b8 0a 00 00 00       	mov    $0xa,%eax
  80063a:	e9 53 01 00 00       	jmp    800792 <vprintfmt+0x476>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80063f:	83 f9 01             	cmp    $0x1,%ecx
  800642:	7e 18                	jle    80065c <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800644:	8b 45 14             	mov    0x14(%ebp),%eax
  800647:	8b 10                	mov    (%eax),%edx
  800649:	8b 48 04             	mov    0x4(%eax),%ecx
  80064c:	8d 40 08             	lea    0x8(%eax),%eax
  80064f:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800652:	b8 0a 00 00 00       	mov    $0xa,%eax
  800657:	e9 36 01 00 00       	jmp    800792 <vprintfmt+0x476>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80065c:	85 c9                	test   %ecx,%ecx
  80065e:	74 1a                	je     80067a <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  800660:	8b 45 14             	mov    0x14(%ebp),%eax
  800663:	8b 10                	mov    (%eax),%edx
  800665:	b9 00 00 00 00       	mov    $0x0,%ecx
  80066a:	8d 40 04             	lea    0x4(%eax),%eax
  80066d:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800670:	b8 0a 00 00 00       	mov    $0xa,%eax
  800675:	e9 18 01 00 00       	jmp    800792 <vprintfmt+0x476>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80067a:	8b 45 14             	mov    0x14(%ebp),%eax
  80067d:	8b 10                	mov    (%eax),%edx
  80067f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800684:	8d 40 04             	lea    0x4(%eax),%eax
  800687:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80068a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80068f:	e9 fe 00 00 00       	jmp    800792 <vprintfmt+0x476>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800694:	83 f9 01             	cmp    $0x1,%ecx
  800697:	7e 19                	jle    8006b2 <vprintfmt+0x396>
		return va_arg(*ap, long long);
  800699:	8b 45 14             	mov    0x14(%ebp),%eax
  80069c:	8b 50 04             	mov    0x4(%eax),%edx
  80069f:	8b 00                	mov    (%eax),%eax
  8006a1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006a4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006aa:	8d 40 08             	lea    0x8(%eax),%eax
  8006ad:	89 45 14             	mov    %eax,0x14(%ebp)
  8006b0:	eb 38                	jmp    8006ea <vprintfmt+0x3ce>
	else if (lflag)
  8006b2:	85 c9                	test   %ecx,%ecx
  8006b4:	74 1b                	je     8006d1 <vprintfmt+0x3b5>
		return va_arg(*ap, long);
  8006b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b9:	8b 00                	mov    (%eax),%eax
  8006bb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006be:	89 c1                	mov    %eax,%ecx
  8006c0:	c1 f9 1f             	sar    $0x1f,%ecx
  8006c3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c9:	8d 40 04             	lea    0x4(%eax),%eax
  8006cc:	89 45 14             	mov    %eax,0x14(%ebp)
  8006cf:	eb 19                	jmp    8006ea <vprintfmt+0x3ce>
	else
		return va_arg(*ap, int);
  8006d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d4:	8b 00                	mov    (%eax),%eax
  8006d6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006d9:	89 c1                	mov    %eax,%ecx
  8006db:	c1 f9 1f             	sar    $0x1f,%ecx
  8006de:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e4:	8d 40 04             	lea    0x4(%eax),%eax
  8006e7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
			goto number;

		// (unsigned) octal
		case 'o':
			num = getint(&ap, lflag);
  8006ea:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006ed:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 8;
  8006f0:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;

		// (unsigned) octal
		case 'o':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006f5:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006f9:	0f 89 93 00 00 00    	jns    800792 <vprintfmt+0x476>
				putch('-', putdat);
  8006ff:	83 ec 08             	sub    $0x8,%esp
  800702:	53                   	push   %ebx
  800703:	6a 2d                	push   $0x2d
  800705:	ff d6                	call   *%esi
				num = -(long long) num;
  800707:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80070a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80070d:	f7 da                	neg    %edx
  80070f:	83 d1 00             	adc    $0x0,%ecx
  800712:	f7 d9                	neg    %ecx
  800714:	83 c4 10             	add    $0x10,%esp
			}
			base = 8;
  800717:	b8 08 00 00 00       	mov    $0x8,%eax
  80071c:	eb 74                	jmp    800792 <vprintfmt+0x476>
			goto number;

		// pointer
		case 'p':
			putch('0', putdat);
  80071e:	83 ec 08             	sub    $0x8,%esp
  800721:	53                   	push   %ebx
  800722:	6a 30                	push   $0x30
  800724:	ff d6                	call   *%esi
			putch('x', putdat);
  800726:	83 c4 08             	add    $0x8,%esp
  800729:	53                   	push   %ebx
  80072a:	6a 78                	push   $0x78
  80072c:	ff d6                	call   *%esi
			num = (unsigned long long)
  80072e:	8b 45 14             	mov    0x14(%ebp),%eax
  800731:	8b 10                	mov    (%eax),%edx
  800733:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800738:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80073b:	8d 40 04             	lea    0x4(%eax),%eax
  80073e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800741:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800746:	eb 4a                	jmp    800792 <vprintfmt+0x476>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800748:	83 f9 01             	cmp    $0x1,%ecx
  80074b:	7e 15                	jle    800762 <vprintfmt+0x446>
		return va_arg(*ap, unsigned long long);
  80074d:	8b 45 14             	mov    0x14(%ebp),%eax
  800750:	8b 10                	mov    (%eax),%edx
  800752:	8b 48 04             	mov    0x4(%eax),%ecx
  800755:	8d 40 08             	lea    0x8(%eax),%eax
  800758:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80075b:	b8 10 00 00 00       	mov    $0x10,%eax
  800760:	eb 30                	jmp    800792 <vprintfmt+0x476>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800762:	85 c9                	test   %ecx,%ecx
  800764:	74 17                	je     80077d <vprintfmt+0x461>
		return va_arg(*ap, unsigned long);
  800766:	8b 45 14             	mov    0x14(%ebp),%eax
  800769:	8b 10                	mov    (%eax),%edx
  80076b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800770:	8d 40 04             	lea    0x4(%eax),%eax
  800773:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800776:	b8 10 00 00 00       	mov    $0x10,%eax
  80077b:	eb 15                	jmp    800792 <vprintfmt+0x476>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80077d:	8b 45 14             	mov    0x14(%ebp),%eax
  800780:	8b 10                	mov    (%eax),%edx
  800782:	b9 00 00 00 00       	mov    $0x0,%ecx
  800787:	8d 40 04             	lea    0x4(%eax),%eax
  80078a:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80078d:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800792:	83 ec 0c             	sub    $0xc,%esp
  800795:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800799:	57                   	push   %edi
  80079a:	ff 75 e0             	pushl  -0x20(%ebp)
  80079d:	50                   	push   %eax
  80079e:	51                   	push   %ecx
  80079f:	52                   	push   %edx
  8007a0:	89 da                	mov    %ebx,%edx
  8007a2:	89 f0                	mov    %esi,%eax
  8007a4:	e8 8a fa ff ff       	call   800233 <printnum>
			break;
  8007a9:	83 c4 20             	add    $0x20,%esp
  8007ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007af:	e9 8e fb ff ff       	jmp    800342 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007b4:	83 ec 08             	sub    $0x8,%esp
  8007b7:	53                   	push   %ebx
  8007b8:	52                   	push   %edx
  8007b9:	ff d6                	call   *%esi
			break;
  8007bb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007c1:	e9 7c fb ff ff       	jmp    800342 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007c6:	83 ec 08             	sub    $0x8,%esp
  8007c9:	53                   	push   %ebx
  8007ca:	6a 25                	push   $0x25
  8007cc:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007ce:	83 c4 10             	add    $0x10,%esp
  8007d1:	eb 03                	jmp    8007d6 <vprintfmt+0x4ba>
  8007d3:	83 ef 01             	sub    $0x1,%edi
  8007d6:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007da:	75 f7                	jne    8007d3 <vprintfmt+0x4b7>
  8007dc:	e9 61 fb ff ff       	jmp    800342 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8007e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007e4:	5b                   	pop    %ebx
  8007e5:	5e                   	pop    %esi
  8007e6:	5f                   	pop    %edi
  8007e7:	5d                   	pop    %ebp
  8007e8:	c3                   	ret    

008007e9 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007e9:	55                   	push   %ebp
  8007ea:	89 e5                	mov    %esp,%ebp
  8007ec:	83 ec 18             	sub    $0x18,%esp
  8007ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f2:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007f5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007f8:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007fc:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007ff:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800806:	85 c0                	test   %eax,%eax
  800808:	74 26                	je     800830 <vsnprintf+0x47>
  80080a:	85 d2                	test   %edx,%edx
  80080c:	7e 22                	jle    800830 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80080e:	ff 75 14             	pushl  0x14(%ebp)
  800811:	ff 75 10             	pushl  0x10(%ebp)
  800814:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800817:	50                   	push   %eax
  800818:	68 e2 02 80 00       	push   $0x8002e2
  80081d:	e8 fa fa ff ff       	call   80031c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800822:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800825:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800828:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80082b:	83 c4 10             	add    $0x10,%esp
  80082e:	eb 05                	jmp    800835 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800830:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800835:	c9                   	leave  
  800836:	c3                   	ret    

00800837 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800837:	55                   	push   %ebp
  800838:	89 e5                	mov    %esp,%ebp
  80083a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80083d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800840:	50                   	push   %eax
  800841:	ff 75 10             	pushl  0x10(%ebp)
  800844:	ff 75 0c             	pushl  0xc(%ebp)
  800847:	ff 75 08             	pushl  0x8(%ebp)
  80084a:	e8 9a ff ff ff       	call   8007e9 <vsnprintf>
	va_end(ap);

	return rc;
}
  80084f:	c9                   	leave  
  800850:	c3                   	ret    

00800851 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800851:	55                   	push   %ebp
  800852:	89 e5                	mov    %esp,%ebp
  800854:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800857:	b8 00 00 00 00       	mov    $0x0,%eax
  80085c:	eb 03                	jmp    800861 <strlen+0x10>
		n++;
  80085e:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800861:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800865:	75 f7                	jne    80085e <strlen+0xd>
		n++;
	return n;
}
  800867:	5d                   	pop    %ebp
  800868:	c3                   	ret    

00800869 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800869:	55                   	push   %ebp
  80086a:	89 e5                	mov    %esp,%ebp
  80086c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80086f:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800872:	ba 00 00 00 00       	mov    $0x0,%edx
  800877:	eb 03                	jmp    80087c <strnlen+0x13>
		n++;
  800879:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80087c:	39 c2                	cmp    %eax,%edx
  80087e:	74 08                	je     800888 <strnlen+0x1f>
  800880:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800884:	75 f3                	jne    800879 <strnlen+0x10>
  800886:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800888:	5d                   	pop    %ebp
  800889:	c3                   	ret    

0080088a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80088a:	55                   	push   %ebp
  80088b:	89 e5                	mov    %esp,%ebp
  80088d:	53                   	push   %ebx
  80088e:	8b 45 08             	mov    0x8(%ebp),%eax
  800891:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800894:	89 c2                	mov    %eax,%edx
  800896:	83 c2 01             	add    $0x1,%edx
  800899:	83 c1 01             	add    $0x1,%ecx
  80089c:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008a0:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008a3:	84 db                	test   %bl,%bl
  8008a5:	75 ef                	jne    800896 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008a7:	5b                   	pop    %ebx
  8008a8:	5d                   	pop    %ebp
  8008a9:	c3                   	ret    

008008aa <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008aa:	55                   	push   %ebp
  8008ab:	89 e5                	mov    %esp,%ebp
  8008ad:	53                   	push   %ebx
  8008ae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008b1:	53                   	push   %ebx
  8008b2:	e8 9a ff ff ff       	call   800851 <strlen>
  8008b7:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008ba:	ff 75 0c             	pushl  0xc(%ebp)
  8008bd:	01 d8                	add    %ebx,%eax
  8008bf:	50                   	push   %eax
  8008c0:	e8 c5 ff ff ff       	call   80088a <strcpy>
	return dst;
}
  8008c5:	89 d8                	mov    %ebx,%eax
  8008c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008ca:	c9                   	leave  
  8008cb:	c3                   	ret    

008008cc <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008cc:	55                   	push   %ebp
  8008cd:	89 e5                	mov    %esp,%ebp
  8008cf:	56                   	push   %esi
  8008d0:	53                   	push   %ebx
  8008d1:	8b 75 08             	mov    0x8(%ebp),%esi
  8008d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008d7:	89 f3                	mov    %esi,%ebx
  8008d9:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008dc:	89 f2                	mov    %esi,%edx
  8008de:	eb 0f                	jmp    8008ef <strncpy+0x23>
		*dst++ = *src;
  8008e0:	83 c2 01             	add    $0x1,%edx
  8008e3:	0f b6 01             	movzbl (%ecx),%eax
  8008e6:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008e9:	80 39 01             	cmpb   $0x1,(%ecx)
  8008ec:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008ef:	39 da                	cmp    %ebx,%edx
  8008f1:	75 ed                	jne    8008e0 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008f3:	89 f0                	mov    %esi,%eax
  8008f5:	5b                   	pop    %ebx
  8008f6:	5e                   	pop    %esi
  8008f7:	5d                   	pop    %ebp
  8008f8:	c3                   	ret    

008008f9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008f9:	55                   	push   %ebp
  8008fa:	89 e5                	mov    %esp,%ebp
  8008fc:	56                   	push   %esi
  8008fd:	53                   	push   %ebx
  8008fe:	8b 75 08             	mov    0x8(%ebp),%esi
  800901:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800904:	8b 55 10             	mov    0x10(%ebp),%edx
  800907:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800909:	85 d2                	test   %edx,%edx
  80090b:	74 21                	je     80092e <strlcpy+0x35>
  80090d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800911:	89 f2                	mov    %esi,%edx
  800913:	eb 09                	jmp    80091e <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800915:	83 c2 01             	add    $0x1,%edx
  800918:	83 c1 01             	add    $0x1,%ecx
  80091b:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80091e:	39 c2                	cmp    %eax,%edx
  800920:	74 09                	je     80092b <strlcpy+0x32>
  800922:	0f b6 19             	movzbl (%ecx),%ebx
  800925:	84 db                	test   %bl,%bl
  800927:	75 ec                	jne    800915 <strlcpy+0x1c>
  800929:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80092b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80092e:	29 f0                	sub    %esi,%eax
}
  800930:	5b                   	pop    %ebx
  800931:	5e                   	pop    %esi
  800932:	5d                   	pop    %ebp
  800933:	c3                   	ret    

00800934 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800934:	55                   	push   %ebp
  800935:	89 e5                	mov    %esp,%ebp
  800937:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80093a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80093d:	eb 06                	jmp    800945 <strcmp+0x11>
		p++, q++;
  80093f:	83 c1 01             	add    $0x1,%ecx
  800942:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800945:	0f b6 01             	movzbl (%ecx),%eax
  800948:	84 c0                	test   %al,%al
  80094a:	74 04                	je     800950 <strcmp+0x1c>
  80094c:	3a 02                	cmp    (%edx),%al
  80094e:	74 ef                	je     80093f <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800950:	0f b6 c0             	movzbl %al,%eax
  800953:	0f b6 12             	movzbl (%edx),%edx
  800956:	29 d0                	sub    %edx,%eax
}
  800958:	5d                   	pop    %ebp
  800959:	c3                   	ret    

0080095a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80095a:	55                   	push   %ebp
  80095b:	89 e5                	mov    %esp,%ebp
  80095d:	53                   	push   %ebx
  80095e:	8b 45 08             	mov    0x8(%ebp),%eax
  800961:	8b 55 0c             	mov    0xc(%ebp),%edx
  800964:	89 c3                	mov    %eax,%ebx
  800966:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800969:	eb 06                	jmp    800971 <strncmp+0x17>
		n--, p++, q++;
  80096b:	83 c0 01             	add    $0x1,%eax
  80096e:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800971:	39 d8                	cmp    %ebx,%eax
  800973:	74 15                	je     80098a <strncmp+0x30>
  800975:	0f b6 08             	movzbl (%eax),%ecx
  800978:	84 c9                	test   %cl,%cl
  80097a:	74 04                	je     800980 <strncmp+0x26>
  80097c:	3a 0a                	cmp    (%edx),%cl
  80097e:	74 eb                	je     80096b <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800980:	0f b6 00             	movzbl (%eax),%eax
  800983:	0f b6 12             	movzbl (%edx),%edx
  800986:	29 d0                	sub    %edx,%eax
  800988:	eb 05                	jmp    80098f <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80098a:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80098f:	5b                   	pop    %ebx
  800990:	5d                   	pop    %ebp
  800991:	c3                   	ret    

00800992 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800992:	55                   	push   %ebp
  800993:	89 e5                	mov    %esp,%ebp
  800995:	8b 45 08             	mov    0x8(%ebp),%eax
  800998:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80099c:	eb 07                	jmp    8009a5 <strchr+0x13>
		if (*s == c)
  80099e:	38 ca                	cmp    %cl,%dl
  8009a0:	74 0f                	je     8009b1 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009a2:	83 c0 01             	add    $0x1,%eax
  8009a5:	0f b6 10             	movzbl (%eax),%edx
  8009a8:	84 d2                	test   %dl,%dl
  8009aa:	75 f2                	jne    80099e <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009ac:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009b1:	5d                   	pop    %ebp
  8009b2:	c3                   	ret    

008009b3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009b3:	55                   	push   %ebp
  8009b4:	89 e5                	mov    %esp,%ebp
  8009b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009bd:	eb 03                	jmp    8009c2 <strfind+0xf>
  8009bf:	83 c0 01             	add    $0x1,%eax
  8009c2:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009c5:	38 ca                	cmp    %cl,%dl
  8009c7:	74 04                	je     8009cd <strfind+0x1a>
  8009c9:	84 d2                	test   %dl,%dl
  8009cb:	75 f2                	jne    8009bf <strfind+0xc>
			break;
	return (char *) s;
}
  8009cd:	5d                   	pop    %ebp
  8009ce:	c3                   	ret    

008009cf <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009cf:	55                   	push   %ebp
  8009d0:	89 e5                	mov    %esp,%ebp
  8009d2:	57                   	push   %edi
  8009d3:	56                   	push   %esi
  8009d4:	53                   	push   %ebx
  8009d5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009d8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009db:	85 c9                	test   %ecx,%ecx
  8009dd:	74 36                	je     800a15 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009df:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009e5:	75 28                	jne    800a0f <memset+0x40>
  8009e7:	f6 c1 03             	test   $0x3,%cl
  8009ea:	75 23                	jne    800a0f <memset+0x40>
		c &= 0xFF;
  8009ec:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009f0:	89 d3                	mov    %edx,%ebx
  8009f2:	c1 e3 08             	shl    $0x8,%ebx
  8009f5:	89 d6                	mov    %edx,%esi
  8009f7:	c1 e6 18             	shl    $0x18,%esi
  8009fa:	89 d0                	mov    %edx,%eax
  8009fc:	c1 e0 10             	shl    $0x10,%eax
  8009ff:	09 f0                	or     %esi,%eax
  800a01:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a03:	89 d8                	mov    %ebx,%eax
  800a05:	09 d0                	or     %edx,%eax
  800a07:	c1 e9 02             	shr    $0x2,%ecx
  800a0a:	fc                   	cld    
  800a0b:	f3 ab                	rep stos %eax,%es:(%edi)
  800a0d:	eb 06                	jmp    800a15 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a0f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a12:	fc                   	cld    
  800a13:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a15:	89 f8                	mov    %edi,%eax
  800a17:	5b                   	pop    %ebx
  800a18:	5e                   	pop    %esi
  800a19:	5f                   	pop    %edi
  800a1a:	5d                   	pop    %ebp
  800a1b:	c3                   	ret    

00800a1c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a1c:	55                   	push   %ebp
  800a1d:	89 e5                	mov    %esp,%ebp
  800a1f:	57                   	push   %edi
  800a20:	56                   	push   %esi
  800a21:	8b 45 08             	mov    0x8(%ebp),%eax
  800a24:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a27:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a2a:	39 c6                	cmp    %eax,%esi
  800a2c:	73 35                	jae    800a63 <memmove+0x47>
  800a2e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a31:	39 d0                	cmp    %edx,%eax
  800a33:	73 2e                	jae    800a63 <memmove+0x47>
		s += n;
		d += n;
  800a35:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a38:	89 d6                	mov    %edx,%esi
  800a3a:	09 fe                	or     %edi,%esi
  800a3c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a42:	75 13                	jne    800a57 <memmove+0x3b>
  800a44:	f6 c1 03             	test   $0x3,%cl
  800a47:	75 0e                	jne    800a57 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a49:	83 ef 04             	sub    $0x4,%edi
  800a4c:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a4f:	c1 e9 02             	shr    $0x2,%ecx
  800a52:	fd                   	std    
  800a53:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a55:	eb 09                	jmp    800a60 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a57:	83 ef 01             	sub    $0x1,%edi
  800a5a:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a5d:	fd                   	std    
  800a5e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a60:	fc                   	cld    
  800a61:	eb 1d                	jmp    800a80 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a63:	89 f2                	mov    %esi,%edx
  800a65:	09 c2                	or     %eax,%edx
  800a67:	f6 c2 03             	test   $0x3,%dl
  800a6a:	75 0f                	jne    800a7b <memmove+0x5f>
  800a6c:	f6 c1 03             	test   $0x3,%cl
  800a6f:	75 0a                	jne    800a7b <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a71:	c1 e9 02             	shr    $0x2,%ecx
  800a74:	89 c7                	mov    %eax,%edi
  800a76:	fc                   	cld    
  800a77:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a79:	eb 05                	jmp    800a80 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a7b:	89 c7                	mov    %eax,%edi
  800a7d:	fc                   	cld    
  800a7e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a80:	5e                   	pop    %esi
  800a81:	5f                   	pop    %edi
  800a82:	5d                   	pop    %ebp
  800a83:	c3                   	ret    

00800a84 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a84:	55                   	push   %ebp
  800a85:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a87:	ff 75 10             	pushl  0x10(%ebp)
  800a8a:	ff 75 0c             	pushl  0xc(%ebp)
  800a8d:	ff 75 08             	pushl  0x8(%ebp)
  800a90:	e8 87 ff ff ff       	call   800a1c <memmove>
}
  800a95:	c9                   	leave  
  800a96:	c3                   	ret    

00800a97 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a97:	55                   	push   %ebp
  800a98:	89 e5                	mov    %esp,%ebp
  800a9a:	56                   	push   %esi
  800a9b:	53                   	push   %ebx
  800a9c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aa2:	89 c6                	mov    %eax,%esi
  800aa4:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aa7:	eb 1a                	jmp    800ac3 <memcmp+0x2c>
		if (*s1 != *s2)
  800aa9:	0f b6 08             	movzbl (%eax),%ecx
  800aac:	0f b6 1a             	movzbl (%edx),%ebx
  800aaf:	38 d9                	cmp    %bl,%cl
  800ab1:	74 0a                	je     800abd <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800ab3:	0f b6 c1             	movzbl %cl,%eax
  800ab6:	0f b6 db             	movzbl %bl,%ebx
  800ab9:	29 d8                	sub    %ebx,%eax
  800abb:	eb 0f                	jmp    800acc <memcmp+0x35>
		s1++, s2++;
  800abd:	83 c0 01             	add    $0x1,%eax
  800ac0:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ac3:	39 f0                	cmp    %esi,%eax
  800ac5:	75 e2                	jne    800aa9 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ac7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800acc:	5b                   	pop    %ebx
  800acd:	5e                   	pop    %esi
  800ace:	5d                   	pop    %ebp
  800acf:	c3                   	ret    

00800ad0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ad0:	55                   	push   %ebp
  800ad1:	89 e5                	mov    %esp,%ebp
  800ad3:	53                   	push   %ebx
  800ad4:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ad7:	89 c1                	mov    %eax,%ecx
  800ad9:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800adc:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ae0:	eb 0a                	jmp    800aec <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ae2:	0f b6 10             	movzbl (%eax),%edx
  800ae5:	39 da                	cmp    %ebx,%edx
  800ae7:	74 07                	je     800af0 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ae9:	83 c0 01             	add    $0x1,%eax
  800aec:	39 c8                	cmp    %ecx,%eax
  800aee:	72 f2                	jb     800ae2 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800af0:	5b                   	pop    %ebx
  800af1:	5d                   	pop    %ebp
  800af2:	c3                   	ret    

00800af3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800af3:	55                   	push   %ebp
  800af4:	89 e5                	mov    %esp,%ebp
  800af6:	57                   	push   %edi
  800af7:	56                   	push   %esi
  800af8:	53                   	push   %ebx
  800af9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800afc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aff:	eb 03                	jmp    800b04 <strtol+0x11>
		s++;
  800b01:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b04:	0f b6 01             	movzbl (%ecx),%eax
  800b07:	3c 20                	cmp    $0x20,%al
  800b09:	74 f6                	je     800b01 <strtol+0xe>
  800b0b:	3c 09                	cmp    $0x9,%al
  800b0d:	74 f2                	je     800b01 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b0f:	3c 2b                	cmp    $0x2b,%al
  800b11:	75 0a                	jne    800b1d <strtol+0x2a>
		s++;
  800b13:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b16:	bf 00 00 00 00       	mov    $0x0,%edi
  800b1b:	eb 11                	jmp    800b2e <strtol+0x3b>
  800b1d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b22:	3c 2d                	cmp    $0x2d,%al
  800b24:	75 08                	jne    800b2e <strtol+0x3b>
		s++, neg = 1;
  800b26:	83 c1 01             	add    $0x1,%ecx
  800b29:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b2e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b34:	75 15                	jne    800b4b <strtol+0x58>
  800b36:	80 39 30             	cmpb   $0x30,(%ecx)
  800b39:	75 10                	jne    800b4b <strtol+0x58>
  800b3b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b3f:	75 7c                	jne    800bbd <strtol+0xca>
		s += 2, base = 16;
  800b41:	83 c1 02             	add    $0x2,%ecx
  800b44:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b49:	eb 16                	jmp    800b61 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b4b:	85 db                	test   %ebx,%ebx
  800b4d:	75 12                	jne    800b61 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b4f:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b54:	80 39 30             	cmpb   $0x30,(%ecx)
  800b57:	75 08                	jne    800b61 <strtol+0x6e>
		s++, base = 8;
  800b59:	83 c1 01             	add    $0x1,%ecx
  800b5c:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b61:	b8 00 00 00 00       	mov    $0x0,%eax
  800b66:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b69:	0f b6 11             	movzbl (%ecx),%edx
  800b6c:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b6f:	89 f3                	mov    %esi,%ebx
  800b71:	80 fb 09             	cmp    $0x9,%bl
  800b74:	77 08                	ja     800b7e <strtol+0x8b>
			dig = *s - '0';
  800b76:	0f be d2             	movsbl %dl,%edx
  800b79:	83 ea 30             	sub    $0x30,%edx
  800b7c:	eb 22                	jmp    800ba0 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b7e:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b81:	89 f3                	mov    %esi,%ebx
  800b83:	80 fb 19             	cmp    $0x19,%bl
  800b86:	77 08                	ja     800b90 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b88:	0f be d2             	movsbl %dl,%edx
  800b8b:	83 ea 57             	sub    $0x57,%edx
  800b8e:	eb 10                	jmp    800ba0 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b90:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b93:	89 f3                	mov    %esi,%ebx
  800b95:	80 fb 19             	cmp    $0x19,%bl
  800b98:	77 16                	ja     800bb0 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b9a:	0f be d2             	movsbl %dl,%edx
  800b9d:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ba0:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ba3:	7d 0b                	jge    800bb0 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ba5:	83 c1 01             	add    $0x1,%ecx
  800ba8:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bac:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800bae:	eb b9                	jmp    800b69 <strtol+0x76>

	if (endptr)
  800bb0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bb4:	74 0d                	je     800bc3 <strtol+0xd0>
		*endptr = (char *) s;
  800bb6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bb9:	89 0e                	mov    %ecx,(%esi)
  800bbb:	eb 06                	jmp    800bc3 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bbd:	85 db                	test   %ebx,%ebx
  800bbf:	74 98                	je     800b59 <strtol+0x66>
  800bc1:	eb 9e                	jmp    800b61 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800bc3:	89 c2                	mov    %eax,%edx
  800bc5:	f7 da                	neg    %edx
  800bc7:	85 ff                	test   %edi,%edi
  800bc9:	0f 45 c2             	cmovne %edx,%eax
}
  800bcc:	5b                   	pop    %ebx
  800bcd:	5e                   	pop    %esi
  800bce:	5f                   	pop    %edi
  800bcf:	5d                   	pop    %ebp
  800bd0:	c3                   	ret    
  800bd1:	66 90                	xchg   %ax,%ax
  800bd3:	66 90                	xchg   %ax,%ax
  800bd5:	66 90                	xchg   %ax,%ax
  800bd7:	66 90                	xchg   %ax,%ax
  800bd9:	66 90                	xchg   %ax,%ax
  800bdb:	66 90                	xchg   %ax,%ax
  800bdd:	66 90                	xchg   %ax,%ax
  800bdf:	90                   	nop

00800be0 <__udivdi3>:
  800be0:	55                   	push   %ebp
  800be1:	57                   	push   %edi
  800be2:	56                   	push   %esi
  800be3:	53                   	push   %ebx
  800be4:	83 ec 1c             	sub    $0x1c,%esp
  800be7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800beb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800bef:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800bf3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800bf7:	85 f6                	test   %esi,%esi
  800bf9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800bfd:	89 ca                	mov    %ecx,%edx
  800bff:	89 f8                	mov    %edi,%eax
  800c01:	75 3d                	jne    800c40 <__udivdi3+0x60>
  800c03:	39 cf                	cmp    %ecx,%edi
  800c05:	0f 87 c5 00 00 00    	ja     800cd0 <__udivdi3+0xf0>
  800c0b:	85 ff                	test   %edi,%edi
  800c0d:	89 fd                	mov    %edi,%ebp
  800c0f:	75 0b                	jne    800c1c <__udivdi3+0x3c>
  800c11:	b8 01 00 00 00       	mov    $0x1,%eax
  800c16:	31 d2                	xor    %edx,%edx
  800c18:	f7 f7                	div    %edi
  800c1a:	89 c5                	mov    %eax,%ebp
  800c1c:	89 c8                	mov    %ecx,%eax
  800c1e:	31 d2                	xor    %edx,%edx
  800c20:	f7 f5                	div    %ebp
  800c22:	89 c1                	mov    %eax,%ecx
  800c24:	89 d8                	mov    %ebx,%eax
  800c26:	89 cf                	mov    %ecx,%edi
  800c28:	f7 f5                	div    %ebp
  800c2a:	89 c3                	mov    %eax,%ebx
  800c2c:	89 d8                	mov    %ebx,%eax
  800c2e:	89 fa                	mov    %edi,%edx
  800c30:	83 c4 1c             	add    $0x1c,%esp
  800c33:	5b                   	pop    %ebx
  800c34:	5e                   	pop    %esi
  800c35:	5f                   	pop    %edi
  800c36:	5d                   	pop    %ebp
  800c37:	c3                   	ret    
  800c38:	90                   	nop
  800c39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800c40:	39 ce                	cmp    %ecx,%esi
  800c42:	77 74                	ja     800cb8 <__udivdi3+0xd8>
  800c44:	0f bd fe             	bsr    %esi,%edi
  800c47:	83 f7 1f             	xor    $0x1f,%edi
  800c4a:	0f 84 98 00 00 00    	je     800ce8 <__udivdi3+0x108>
  800c50:	bb 20 00 00 00       	mov    $0x20,%ebx
  800c55:	89 f9                	mov    %edi,%ecx
  800c57:	89 c5                	mov    %eax,%ebp
  800c59:	29 fb                	sub    %edi,%ebx
  800c5b:	d3 e6                	shl    %cl,%esi
  800c5d:	89 d9                	mov    %ebx,%ecx
  800c5f:	d3 ed                	shr    %cl,%ebp
  800c61:	89 f9                	mov    %edi,%ecx
  800c63:	d3 e0                	shl    %cl,%eax
  800c65:	09 ee                	or     %ebp,%esi
  800c67:	89 d9                	mov    %ebx,%ecx
  800c69:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c6d:	89 d5                	mov    %edx,%ebp
  800c6f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800c73:	d3 ed                	shr    %cl,%ebp
  800c75:	89 f9                	mov    %edi,%ecx
  800c77:	d3 e2                	shl    %cl,%edx
  800c79:	89 d9                	mov    %ebx,%ecx
  800c7b:	d3 e8                	shr    %cl,%eax
  800c7d:	09 c2                	or     %eax,%edx
  800c7f:	89 d0                	mov    %edx,%eax
  800c81:	89 ea                	mov    %ebp,%edx
  800c83:	f7 f6                	div    %esi
  800c85:	89 d5                	mov    %edx,%ebp
  800c87:	89 c3                	mov    %eax,%ebx
  800c89:	f7 64 24 0c          	mull   0xc(%esp)
  800c8d:	39 d5                	cmp    %edx,%ebp
  800c8f:	72 10                	jb     800ca1 <__udivdi3+0xc1>
  800c91:	8b 74 24 08          	mov    0x8(%esp),%esi
  800c95:	89 f9                	mov    %edi,%ecx
  800c97:	d3 e6                	shl    %cl,%esi
  800c99:	39 c6                	cmp    %eax,%esi
  800c9b:	73 07                	jae    800ca4 <__udivdi3+0xc4>
  800c9d:	39 d5                	cmp    %edx,%ebp
  800c9f:	75 03                	jne    800ca4 <__udivdi3+0xc4>
  800ca1:	83 eb 01             	sub    $0x1,%ebx
  800ca4:	31 ff                	xor    %edi,%edi
  800ca6:	89 d8                	mov    %ebx,%eax
  800ca8:	89 fa                	mov    %edi,%edx
  800caa:	83 c4 1c             	add    $0x1c,%esp
  800cad:	5b                   	pop    %ebx
  800cae:	5e                   	pop    %esi
  800caf:	5f                   	pop    %edi
  800cb0:	5d                   	pop    %ebp
  800cb1:	c3                   	ret    
  800cb2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800cb8:	31 ff                	xor    %edi,%edi
  800cba:	31 db                	xor    %ebx,%ebx
  800cbc:	89 d8                	mov    %ebx,%eax
  800cbe:	89 fa                	mov    %edi,%edx
  800cc0:	83 c4 1c             	add    $0x1c,%esp
  800cc3:	5b                   	pop    %ebx
  800cc4:	5e                   	pop    %esi
  800cc5:	5f                   	pop    %edi
  800cc6:	5d                   	pop    %ebp
  800cc7:	c3                   	ret    
  800cc8:	90                   	nop
  800cc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800cd0:	89 d8                	mov    %ebx,%eax
  800cd2:	f7 f7                	div    %edi
  800cd4:	31 ff                	xor    %edi,%edi
  800cd6:	89 c3                	mov    %eax,%ebx
  800cd8:	89 d8                	mov    %ebx,%eax
  800cda:	89 fa                	mov    %edi,%edx
  800cdc:	83 c4 1c             	add    $0x1c,%esp
  800cdf:	5b                   	pop    %ebx
  800ce0:	5e                   	pop    %esi
  800ce1:	5f                   	pop    %edi
  800ce2:	5d                   	pop    %ebp
  800ce3:	c3                   	ret    
  800ce4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ce8:	39 ce                	cmp    %ecx,%esi
  800cea:	72 0c                	jb     800cf8 <__udivdi3+0x118>
  800cec:	31 db                	xor    %ebx,%ebx
  800cee:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800cf2:	0f 87 34 ff ff ff    	ja     800c2c <__udivdi3+0x4c>
  800cf8:	bb 01 00 00 00       	mov    $0x1,%ebx
  800cfd:	e9 2a ff ff ff       	jmp    800c2c <__udivdi3+0x4c>
  800d02:	66 90                	xchg   %ax,%ax
  800d04:	66 90                	xchg   %ax,%ax
  800d06:	66 90                	xchg   %ax,%ax
  800d08:	66 90                	xchg   %ax,%ax
  800d0a:	66 90                	xchg   %ax,%ax
  800d0c:	66 90                	xchg   %ax,%ax
  800d0e:	66 90                	xchg   %ax,%ax

00800d10 <__umoddi3>:
  800d10:	55                   	push   %ebp
  800d11:	57                   	push   %edi
  800d12:	56                   	push   %esi
  800d13:	53                   	push   %ebx
  800d14:	83 ec 1c             	sub    $0x1c,%esp
  800d17:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800d1b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800d1f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800d23:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d27:	85 d2                	test   %edx,%edx
  800d29:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800d2d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800d31:	89 f3                	mov    %esi,%ebx
  800d33:	89 3c 24             	mov    %edi,(%esp)
  800d36:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d3a:	75 1c                	jne    800d58 <__umoddi3+0x48>
  800d3c:	39 f7                	cmp    %esi,%edi
  800d3e:	76 50                	jbe    800d90 <__umoddi3+0x80>
  800d40:	89 c8                	mov    %ecx,%eax
  800d42:	89 f2                	mov    %esi,%edx
  800d44:	f7 f7                	div    %edi
  800d46:	89 d0                	mov    %edx,%eax
  800d48:	31 d2                	xor    %edx,%edx
  800d4a:	83 c4 1c             	add    $0x1c,%esp
  800d4d:	5b                   	pop    %ebx
  800d4e:	5e                   	pop    %esi
  800d4f:	5f                   	pop    %edi
  800d50:	5d                   	pop    %ebp
  800d51:	c3                   	ret    
  800d52:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d58:	39 f2                	cmp    %esi,%edx
  800d5a:	89 d0                	mov    %edx,%eax
  800d5c:	77 52                	ja     800db0 <__umoddi3+0xa0>
  800d5e:	0f bd ea             	bsr    %edx,%ebp
  800d61:	83 f5 1f             	xor    $0x1f,%ebp
  800d64:	75 5a                	jne    800dc0 <__umoddi3+0xb0>
  800d66:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800d6a:	0f 82 e0 00 00 00    	jb     800e50 <__umoddi3+0x140>
  800d70:	39 0c 24             	cmp    %ecx,(%esp)
  800d73:	0f 86 d7 00 00 00    	jbe    800e50 <__umoddi3+0x140>
  800d79:	8b 44 24 08          	mov    0x8(%esp),%eax
  800d7d:	8b 54 24 04          	mov    0x4(%esp),%edx
  800d81:	83 c4 1c             	add    $0x1c,%esp
  800d84:	5b                   	pop    %ebx
  800d85:	5e                   	pop    %esi
  800d86:	5f                   	pop    %edi
  800d87:	5d                   	pop    %ebp
  800d88:	c3                   	ret    
  800d89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d90:	85 ff                	test   %edi,%edi
  800d92:	89 fd                	mov    %edi,%ebp
  800d94:	75 0b                	jne    800da1 <__umoddi3+0x91>
  800d96:	b8 01 00 00 00       	mov    $0x1,%eax
  800d9b:	31 d2                	xor    %edx,%edx
  800d9d:	f7 f7                	div    %edi
  800d9f:	89 c5                	mov    %eax,%ebp
  800da1:	89 f0                	mov    %esi,%eax
  800da3:	31 d2                	xor    %edx,%edx
  800da5:	f7 f5                	div    %ebp
  800da7:	89 c8                	mov    %ecx,%eax
  800da9:	f7 f5                	div    %ebp
  800dab:	89 d0                	mov    %edx,%eax
  800dad:	eb 99                	jmp    800d48 <__umoddi3+0x38>
  800daf:	90                   	nop
  800db0:	89 c8                	mov    %ecx,%eax
  800db2:	89 f2                	mov    %esi,%edx
  800db4:	83 c4 1c             	add    $0x1c,%esp
  800db7:	5b                   	pop    %ebx
  800db8:	5e                   	pop    %esi
  800db9:	5f                   	pop    %edi
  800dba:	5d                   	pop    %ebp
  800dbb:	c3                   	ret    
  800dbc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800dc0:	8b 34 24             	mov    (%esp),%esi
  800dc3:	bf 20 00 00 00       	mov    $0x20,%edi
  800dc8:	89 e9                	mov    %ebp,%ecx
  800dca:	29 ef                	sub    %ebp,%edi
  800dcc:	d3 e0                	shl    %cl,%eax
  800dce:	89 f9                	mov    %edi,%ecx
  800dd0:	89 f2                	mov    %esi,%edx
  800dd2:	d3 ea                	shr    %cl,%edx
  800dd4:	89 e9                	mov    %ebp,%ecx
  800dd6:	09 c2                	or     %eax,%edx
  800dd8:	89 d8                	mov    %ebx,%eax
  800dda:	89 14 24             	mov    %edx,(%esp)
  800ddd:	89 f2                	mov    %esi,%edx
  800ddf:	d3 e2                	shl    %cl,%edx
  800de1:	89 f9                	mov    %edi,%ecx
  800de3:	89 54 24 04          	mov    %edx,0x4(%esp)
  800de7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800deb:	d3 e8                	shr    %cl,%eax
  800ded:	89 e9                	mov    %ebp,%ecx
  800def:	89 c6                	mov    %eax,%esi
  800df1:	d3 e3                	shl    %cl,%ebx
  800df3:	89 f9                	mov    %edi,%ecx
  800df5:	89 d0                	mov    %edx,%eax
  800df7:	d3 e8                	shr    %cl,%eax
  800df9:	89 e9                	mov    %ebp,%ecx
  800dfb:	09 d8                	or     %ebx,%eax
  800dfd:	89 d3                	mov    %edx,%ebx
  800dff:	89 f2                	mov    %esi,%edx
  800e01:	f7 34 24             	divl   (%esp)
  800e04:	89 d6                	mov    %edx,%esi
  800e06:	d3 e3                	shl    %cl,%ebx
  800e08:	f7 64 24 04          	mull   0x4(%esp)
  800e0c:	39 d6                	cmp    %edx,%esi
  800e0e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800e12:	89 d1                	mov    %edx,%ecx
  800e14:	89 c3                	mov    %eax,%ebx
  800e16:	72 08                	jb     800e20 <__umoddi3+0x110>
  800e18:	75 11                	jne    800e2b <__umoddi3+0x11b>
  800e1a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800e1e:	73 0b                	jae    800e2b <__umoddi3+0x11b>
  800e20:	2b 44 24 04          	sub    0x4(%esp),%eax
  800e24:	1b 14 24             	sbb    (%esp),%edx
  800e27:	89 d1                	mov    %edx,%ecx
  800e29:	89 c3                	mov    %eax,%ebx
  800e2b:	8b 54 24 08          	mov    0x8(%esp),%edx
  800e2f:	29 da                	sub    %ebx,%edx
  800e31:	19 ce                	sbb    %ecx,%esi
  800e33:	89 f9                	mov    %edi,%ecx
  800e35:	89 f0                	mov    %esi,%eax
  800e37:	d3 e0                	shl    %cl,%eax
  800e39:	89 e9                	mov    %ebp,%ecx
  800e3b:	d3 ea                	shr    %cl,%edx
  800e3d:	89 e9                	mov    %ebp,%ecx
  800e3f:	d3 ee                	shr    %cl,%esi
  800e41:	09 d0                	or     %edx,%eax
  800e43:	89 f2                	mov    %esi,%edx
  800e45:	83 c4 1c             	add    $0x1c,%esp
  800e48:	5b                   	pop    %ebx
  800e49:	5e                   	pop    %esi
  800e4a:	5f                   	pop    %edi
  800e4b:	5d                   	pop    %ebp
  800e4c:	c3                   	ret    
  800e4d:	8d 76 00             	lea    0x0(%esi),%esi
  800e50:	29 f9                	sub    %edi,%ecx
  800e52:	19 d6                	sbb    %edx,%esi
  800e54:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e58:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e5c:	e9 18 ff ff ff       	jmp    800d79 <__umoddi3+0x69>
