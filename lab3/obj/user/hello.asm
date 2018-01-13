
obj/user/hello：     文件格式 elf32-i386


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
  80002c:	e8 2d 00 00 00       	call   80005e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
// hello, world
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 14             	sub    $0x14,%esp
	cprintf("hello, world\n");
  800039:	68 80 0e 80 00       	push   $0x800e80
  80003e:	e8 09 01 00 00       	call   80014c <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800043:	a1 04 20 80 00       	mov    0x802004,%eax
  800048:	8b 40 48             	mov    0x48(%eax),%eax
  80004b:	83 c4 08             	add    $0x8,%esp
  80004e:	50                   	push   %eax
  80004f:	68 8e 0e 80 00       	push   $0x800e8e
  800054:	e8 f3 00 00 00       	call   80014c <cprintf>
}
  800059:	83 c4 10             	add    $0x10,%esp
  80005c:	c9                   	leave  
  80005d:	c3                   	ret    

0080005e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80005e:	55                   	push   %ebp
  80005f:	89 e5                	mov    %esp,%ebp
  800061:	56                   	push   %esi
  800062:	53                   	push   %ebx
  800063:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800066:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t i = sys_getenvid();
  800069:	e8 0e 0b 00 00       	call   800b7c <sys_getenvid>
    thisenv = &envs[ENVX(i)];
  80006e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800073:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800076:	c1 e0 05             	shl    $0x5,%eax
  800079:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007e:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800083:	85 db                	test   %ebx,%ebx
  800085:	7e 07                	jle    80008e <libmain+0x30>
		binaryname = argv[0];
  800087:	8b 06                	mov    (%esi),%eax
  800089:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80008e:	83 ec 08             	sub    $0x8,%esp
  800091:	56                   	push   %esi
  800092:	53                   	push   %ebx
  800093:	e8 9b ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800098:	e8 0a 00 00 00       	call   8000a7 <exit>
}
  80009d:	83 c4 10             	add    $0x10,%esp
  8000a0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a3:	5b                   	pop    %ebx
  8000a4:	5e                   	pop    %esi
  8000a5:	5d                   	pop    %ebp
  8000a6:	c3                   	ret    

008000a7 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a7:	55                   	push   %ebp
  8000a8:	89 e5                	mov    %esp,%ebp
  8000aa:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000ad:	6a 00                	push   $0x0
  8000af:	e8 87 0a 00 00       	call   800b3b <sys_env_destroy>
}
  8000b4:	83 c4 10             	add    $0x10,%esp
  8000b7:	c9                   	leave  
  8000b8:	c3                   	ret    

008000b9 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000b9:	55                   	push   %ebp
  8000ba:	89 e5                	mov    %esp,%ebp
  8000bc:	53                   	push   %ebx
  8000bd:	83 ec 04             	sub    $0x4,%esp
  8000c0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000c3:	8b 13                	mov    (%ebx),%edx
  8000c5:	8d 42 01             	lea    0x1(%edx),%eax
  8000c8:	89 03                	mov    %eax,(%ebx)
  8000ca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000cd:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000d1:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000d6:	75 1a                	jne    8000f2 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000d8:	83 ec 08             	sub    $0x8,%esp
  8000db:	68 ff 00 00 00       	push   $0xff
  8000e0:	8d 43 08             	lea    0x8(%ebx),%eax
  8000e3:	50                   	push   %eax
  8000e4:	e8 15 0a 00 00       	call   800afe <sys_cputs>
		b->idx = 0;
  8000e9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000ef:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000f2:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000f6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000f9:	c9                   	leave  
  8000fa:	c3                   	ret    

008000fb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000fb:	55                   	push   %ebp
  8000fc:	89 e5                	mov    %esp,%ebp
  8000fe:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800104:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80010b:	00 00 00 
	b.cnt = 0;
  80010e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800115:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800118:	ff 75 0c             	pushl  0xc(%ebp)
  80011b:	ff 75 08             	pushl  0x8(%ebp)
  80011e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800124:	50                   	push   %eax
  800125:	68 b9 00 80 00       	push   $0x8000b9
  80012a:	e8 1a 01 00 00       	call   800249 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80012f:	83 c4 08             	add    $0x8,%esp
  800132:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800138:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80013e:	50                   	push   %eax
  80013f:	e8 ba 09 00 00       	call   800afe <sys_cputs>

	return b.cnt;
}
  800144:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80014a:	c9                   	leave  
  80014b:	c3                   	ret    

0080014c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80014c:	55                   	push   %ebp
  80014d:	89 e5                	mov    %esp,%ebp
  80014f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800152:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800155:	50                   	push   %eax
  800156:	ff 75 08             	pushl  0x8(%ebp)
  800159:	e8 9d ff ff ff       	call   8000fb <vcprintf>
	va_end(ap);

	return cnt;
}
  80015e:	c9                   	leave  
  80015f:	c3                   	ret    

00800160 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	57                   	push   %edi
  800164:	56                   	push   %esi
  800165:	53                   	push   %ebx
  800166:	83 ec 1c             	sub    $0x1c,%esp
  800169:	89 c7                	mov    %eax,%edi
  80016b:	89 d6                	mov    %edx,%esi
  80016d:	8b 45 08             	mov    0x8(%ebp),%eax
  800170:	8b 55 0c             	mov    0xc(%ebp),%edx
  800173:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800176:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800179:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80017c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800181:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800184:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800187:	39 d3                	cmp    %edx,%ebx
  800189:	72 05                	jb     800190 <printnum+0x30>
  80018b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80018e:	77 45                	ja     8001d5 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800190:	83 ec 0c             	sub    $0xc,%esp
  800193:	ff 75 18             	pushl  0x18(%ebp)
  800196:	8b 45 14             	mov    0x14(%ebp),%eax
  800199:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80019c:	53                   	push   %ebx
  80019d:	ff 75 10             	pushl  0x10(%ebp)
  8001a0:	83 ec 08             	sub    $0x8,%esp
  8001a3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001a6:	ff 75 e0             	pushl  -0x20(%ebp)
  8001a9:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ac:	ff 75 d8             	pushl  -0x28(%ebp)
  8001af:	e8 3c 0a 00 00       	call   800bf0 <__udivdi3>
  8001b4:	83 c4 18             	add    $0x18,%esp
  8001b7:	52                   	push   %edx
  8001b8:	50                   	push   %eax
  8001b9:	89 f2                	mov    %esi,%edx
  8001bb:	89 f8                	mov    %edi,%eax
  8001bd:	e8 9e ff ff ff       	call   800160 <printnum>
  8001c2:	83 c4 20             	add    $0x20,%esp
  8001c5:	eb 18                	jmp    8001df <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001c7:	83 ec 08             	sub    $0x8,%esp
  8001ca:	56                   	push   %esi
  8001cb:	ff 75 18             	pushl  0x18(%ebp)
  8001ce:	ff d7                	call   *%edi
  8001d0:	83 c4 10             	add    $0x10,%esp
  8001d3:	eb 03                	jmp    8001d8 <printnum+0x78>
  8001d5:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001d8:	83 eb 01             	sub    $0x1,%ebx
  8001db:	85 db                	test   %ebx,%ebx
  8001dd:	7f e8                	jg     8001c7 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001df:	83 ec 08             	sub    $0x8,%esp
  8001e2:	56                   	push   %esi
  8001e3:	83 ec 04             	sub    $0x4,%esp
  8001e6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001e9:	ff 75 e0             	pushl  -0x20(%ebp)
  8001ec:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ef:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f2:	e8 29 0b 00 00       	call   800d20 <__umoddi3>
  8001f7:	83 c4 14             	add    $0x14,%esp
  8001fa:	0f be 80 af 0e 80 00 	movsbl 0x800eaf(%eax),%eax
  800201:	50                   	push   %eax
  800202:	ff d7                	call   *%edi
}
  800204:	83 c4 10             	add    $0x10,%esp
  800207:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80020a:	5b                   	pop    %ebx
  80020b:	5e                   	pop    %esi
  80020c:	5f                   	pop    %edi
  80020d:	5d                   	pop    %ebp
  80020e:	c3                   	ret    

0080020f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80020f:	55                   	push   %ebp
  800210:	89 e5                	mov    %esp,%ebp
  800212:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800215:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800219:	8b 10                	mov    (%eax),%edx
  80021b:	3b 50 04             	cmp    0x4(%eax),%edx
  80021e:	73 0a                	jae    80022a <sprintputch+0x1b>
		*b->buf++ = ch;
  800220:	8d 4a 01             	lea    0x1(%edx),%ecx
  800223:	89 08                	mov    %ecx,(%eax)
  800225:	8b 45 08             	mov    0x8(%ebp),%eax
  800228:	88 02                	mov    %al,(%edx)
}
  80022a:	5d                   	pop    %ebp
  80022b:	c3                   	ret    

0080022c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80022c:	55                   	push   %ebp
  80022d:	89 e5                	mov    %esp,%ebp
  80022f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800232:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800235:	50                   	push   %eax
  800236:	ff 75 10             	pushl  0x10(%ebp)
  800239:	ff 75 0c             	pushl  0xc(%ebp)
  80023c:	ff 75 08             	pushl  0x8(%ebp)
  80023f:	e8 05 00 00 00       	call   800249 <vprintfmt>
	va_end(ap);
}
  800244:	83 c4 10             	add    $0x10,%esp
  800247:	c9                   	leave  
  800248:	c3                   	ret    

00800249 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800249:	55                   	push   %ebp
  80024a:	89 e5                	mov    %esp,%ebp
  80024c:	57                   	push   %edi
  80024d:	56                   	push   %esi
  80024e:	53                   	push   %ebx
  80024f:	83 ec 2c             	sub    $0x2c,%esp
  800252:	8b 75 08             	mov    0x8(%ebp),%esi
  800255:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800258:	8b 7d 10             	mov    0x10(%ebp),%edi
  80025b:	eb 12                	jmp    80026f <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80025d:	85 c0                	test   %eax,%eax
  80025f:	0f 84 a9 04 00 00    	je     80070e <vprintfmt+0x4c5>
				return;
			putch(ch, putdat);
  800265:	83 ec 08             	sub    $0x8,%esp
  800268:	53                   	push   %ebx
  800269:	50                   	push   %eax
  80026a:	ff d6                	call   *%esi
  80026c:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80026f:	83 c7 01             	add    $0x1,%edi
  800272:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800276:	83 f8 25             	cmp    $0x25,%eax
  800279:	75 e2                	jne    80025d <vprintfmt+0x14>
  80027b:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80027f:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800286:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80028d:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800294:	b9 00 00 00 00       	mov    $0x0,%ecx
  800299:	eb 07                	jmp    8002a2 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80029b:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80029e:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002a2:	8d 47 01             	lea    0x1(%edi),%eax
  8002a5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002a8:	0f b6 07             	movzbl (%edi),%eax
  8002ab:	0f b6 d0             	movzbl %al,%edx
  8002ae:	83 e8 23             	sub    $0x23,%eax
  8002b1:	3c 55                	cmp    $0x55,%al
  8002b3:	0f 87 3a 04 00 00    	ja     8006f3 <vprintfmt+0x4aa>
  8002b9:	0f b6 c0             	movzbl %al,%eax
  8002bc:	ff 24 85 40 0f 80 00 	jmp    *0x800f40(,%eax,4)
  8002c3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8002c6:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8002ca:	eb d6                	jmp    8002a2 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8002d4:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8002d7:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002da:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8002de:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8002e1:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8002e4:	83 f9 09             	cmp    $0x9,%ecx
  8002e7:	77 3f                	ja     800328 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8002e9:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8002ec:	eb e9                	jmp    8002d7 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8002ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8002f1:	8b 00                	mov    (%eax),%eax
  8002f3:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8002f9:	8d 40 04             	lea    0x4(%eax),%eax
  8002fc:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800302:	eb 2a                	jmp    80032e <vprintfmt+0xe5>
  800304:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800307:	85 c0                	test   %eax,%eax
  800309:	ba 00 00 00 00       	mov    $0x0,%edx
  80030e:	0f 49 d0             	cmovns %eax,%edx
  800311:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800314:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800317:	eb 89                	jmp    8002a2 <vprintfmt+0x59>
  800319:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80031c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800323:	e9 7a ff ff ff       	jmp    8002a2 <vprintfmt+0x59>
  800328:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80032b:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80032e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800332:	0f 89 6a ff ff ff    	jns    8002a2 <vprintfmt+0x59>
				width = precision, precision = -1;
  800338:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80033b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80033e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800345:	e9 58 ff ff ff       	jmp    8002a2 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80034a:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80034d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800350:	e9 4d ff ff ff       	jmp    8002a2 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800355:	8b 45 14             	mov    0x14(%ebp),%eax
  800358:	8d 78 04             	lea    0x4(%eax),%edi
  80035b:	83 ec 08             	sub    $0x8,%esp
  80035e:	53                   	push   %ebx
  80035f:	ff 30                	pushl  (%eax)
  800361:	ff d6                	call   *%esi
			break;
  800363:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800366:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800369:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80036c:	e9 fe fe ff ff       	jmp    80026f <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800371:	8b 45 14             	mov    0x14(%ebp),%eax
  800374:	8d 78 04             	lea    0x4(%eax),%edi
  800377:	8b 00                	mov    (%eax),%eax
  800379:	99                   	cltd   
  80037a:	31 d0                	xor    %edx,%eax
  80037c:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80037e:	83 f8 07             	cmp    $0x7,%eax
  800381:	7f 0b                	jg     80038e <vprintfmt+0x145>
  800383:	8b 14 85 a0 10 80 00 	mov    0x8010a0(,%eax,4),%edx
  80038a:	85 d2                	test   %edx,%edx
  80038c:	75 1b                	jne    8003a9 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  80038e:	50                   	push   %eax
  80038f:	68 c7 0e 80 00       	push   $0x800ec7
  800394:	53                   	push   %ebx
  800395:	56                   	push   %esi
  800396:	e8 91 fe ff ff       	call   80022c <printfmt>
  80039b:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80039e:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003a4:	e9 c6 fe ff ff       	jmp    80026f <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003a9:	52                   	push   %edx
  8003aa:	68 d0 0e 80 00       	push   $0x800ed0
  8003af:	53                   	push   %ebx
  8003b0:	56                   	push   %esi
  8003b1:	e8 76 fe ff ff       	call   80022c <printfmt>
  8003b6:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003b9:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003bf:	e9 ab fe ff ff       	jmp    80026f <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c7:	83 c0 04             	add    $0x4,%eax
  8003ca:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8003cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d0:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8003d2:	85 ff                	test   %edi,%edi
  8003d4:	b8 c0 0e 80 00       	mov    $0x800ec0,%eax
  8003d9:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8003dc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003e0:	0f 8e 94 00 00 00    	jle    80047a <vprintfmt+0x231>
  8003e6:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8003ea:	0f 84 98 00 00 00    	je     800488 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003f0:	83 ec 08             	sub    $0x8,%esp
  8003f3:	ff 75 d0             	pushl  -0x30(%ebp)
  8003f6:	57                   	push   %edi
  8003f7:	e8 9a 03 00 00       	call   800796 <strnlen>
  8003fc:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8003ff:	29 c1                	sub    %eax,%ecx
  800401:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800404:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800407:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80040b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80040e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800411:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800413:	eb 0f                	jmp    800424 <vprintfmt+0x1db>
					putch(padc, putdat);
  800415:	83 ec 08             	sub    $0x8,%esp
  800418:	53                   	push   %ebx
  800419:	ff 75 e0             	pushl  -0x20(%ebp)
  80041c:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80041e:	83 ef 01             	sub    $0x1,%edi
  800421:	83 c4 10             	add    $0x10,%esp
  800424:	85 ff                	test   %edi,%edi
  800426:	7f ed                	jg     800415 <vprintfmt+0x1cc>
  800428:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80042b:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80042e:	85 c9                	test   %ecx,%ecx
  800430:	b8 00 00 00 00       	mov    $0x0,%eax
  800435:	0f 49 c1             	cmovns %ecx,%eax
  800438:	29 c1                	sub    %eax,%ecx
  80043a:	89 75 08             	mov    %esi,0x8(%ebp)
  80043d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800440:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800443:	89 cb                	mov    %ecx,%ebx
  800445:	eb 4d                	jmp    800494 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800447:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80044b:	74 1b                	je     800468 <vprintfmt+0x21f>
  80044d:	0f be c0             	movsbl %al,%eax
  800450:	83 e8 20             	sub    $0x20,%eax
  800453:	83 f8 5e             	cmp    $0x5e,%eax
  800456:	76 10                	jbe    800468 <vprintfmt+0x21f>
					putch('?', putdat);
  800458:	83 ec 08             	sub    $0x8,%esp
  80045b:	ff 75 0c             	pushl  0xc(%ebp)
  80045e:	6a 3f                	push   $0x3f
  800460:	ff 55 08             	call   *0x8(%ebp)
  800463:	83 c4 10             	add    $0x10,%esp
  800466:	eb 0d                	jmp    800475 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  800468:	83 ec 08             	sub    $0x8,%esp
  80046b:	ff 75 0c             	pushl  0xc(%ebp)
  80046e:	52                   	push   %edx
  80046f:	ff 55 08             	call   *0x8(%ebp)
  800472:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800475:	83 eb 01             	sub    $0x1,%ebx
  800478:	eb 1a                	jmp    800494 <vprintfmt+0x24b>
  80047a:	89 75 08             	mov    %esi,0x8(%ebp)
  80047d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800480:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800483:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800486:	eb 0c                	jmp    800494 <vprintfmt+0x24b>
  800488:	89 75 08             	mov    %esi,0x8(%ebp)
  80048b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80048e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800491:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800494:	83 c7 01             	add    $0x1,%edi
  800497:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80049b:	0f be d0             	movsbl %al,%edx
  80049e:	85 d2                	test   %edx,%edx
  8004a0:	74 23                	je     8004c5 <vprintfmt+0x27c>
  8004a2:	85 f6                	test   %esi,%esi
  8004a4:	78 a1                	js     800447 <vprintfmt+0x1fe>
  8004a6:	83 ee 01             	sub    $0x1,%esi
  8004a9:	79 9c                	jns    800447 <vprintfmt+0x1fe>
  8004ab:	89 df                	mov    %ebx,%edi
  8004ad:	8b 75 08             	mov    0x8(%ebp),%esi
  8004b0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004b3:	eb 18                	jmp    8004cd <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004b5:	83 ec 08             	sub    $0x8,%esp
  8004b8:	53                   	push   %ebx
  8004b9:	6a 20                	push   $0x20
  8004bb:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004bd:	83 ef 01             	sub    $0x1,%edi
  8004c0:	83 c4 10             	add    $0x10,%esp
  8004c3:	eb 08                	jmp    8004cd <vprintfmt+0x284>
  8004c5:	89 df                	mov    %ebx,%edi
  8004c7:	8b 75 08             	mov    0x8(%ebp),%esi
  8004ca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004cd:	85 ff                	test   %edi,%edi
  8004cf:	7f e4                	jg     8004b5 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004d1:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004d4:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004da:	e9 90 fd ff ff       	jmp    80026f <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8004df:	83 f9 01             	cmp    $0x1,%ecx
  8004e2:	7e 19                	jle    8004fd <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  8004e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e7:	8b 50 04             	mov    0x4(%eax),%edx
  8004ea:	8b 00                	mov    (%eax),%eax
  8004ec:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004ef:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f5:	8d 40 08             	lea    0x8(%eax),%eax
  8004f8:	89 45 14             	mov    %eax,0x14(%ebp)
  8004fb:	eb 38                	jmp    800535 <vprintfmt+0x2ec>
	else if (lflag)
  8004fd:	85 c9                	test   %ecx,%ecx
  8004ff:	74 1b                	je     80051c <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  800501:	8b 45 14             	mov    0x14(%ebp),%eax
  800504:	8b 00                	mov    (%eax),%eax
  800506:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800509:	89 c1                	mov    %eax,%ecx
  80050b:	c1 f9 1f             	sar    $0x1f,%ecx
  80050e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800511:	8b 45 14             	mov    0x14(%ebp),%eax
  800514:	8d 40 04             	lea    0x4(%eax),%eax
  800517:	89 45 14             	mov    %eax,0x14(%ebp)
  80051a:	eb 19                	jmp    800535 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  80051c:	8b 45 14             	mov    0x14(%ebp),%eax
  80051f:	8b 00                	mov    (%eax),%eax
  800521:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800524:	89 c1                	mov    %eax,%ecx
  800526:	c1 f9 1f             	sar    $0x1f,%ecx
  800529:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80052c:	8b 45 14             	mov    0x14(%ebp),%eax
  80052f:	8d 40 04             	lea    0x4(%eax),%eax
  800532:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800535:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800538:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80053b:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800540:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800544:	0f 89 75 01 00 00    	jns    8006bf <vprintfmt+0x476>
				putch('-', putdat);
  80054a:	83 ec 08             	sub    $0x8,%esp
  80054d:	53                   	push   %ebx
  80054e:	6a 2d                	push   $0x2d
  800550:	ff d6                	call   *%esi
				num = -(long long) num;
  800552:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800555:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800558:	f7 da                	neg    %edx
  80055a:	83 d1 00             	adc    $0x0,%ecx
  80055d:	f7 d9                	neg    %ecx
  80055f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800562:	b8 0a 00 00 00       	mov    $0xa,%eax
  800567:	e9 53 01 00 00       	jmp    8006bf <vprintfmt+0x476>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80056c:	83 f9 01             	cmp    $0x1,%ecx
  80056f:	7e 18                	jle    800589 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800571:	8b 45 14             	mov    0x14(%ebp),%eax
  800574:	8b 10                	mov    (%eax),%edx
  800576:	8b 48 04             	mov    0x4(%eax),%ecx
  800579:	8d 40 08             	lea    0x8(%eax),%eax
  80057c:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80057f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800584:	e9 36 01 00 00       	jmp    8006bf <vprintfmt+0x476>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800589:	85 c9                	test   %ecx,%ecx
  80058b:	74 1a                	je     8005a7 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  80058d:	8b 45 14             	mov    0x14(%ebp),%eax
  800590:	8b 10                	mov    (%eax),%edx
  800592:	b9 00 00 00 00       	mov    $0x0,%ecx
  800597:	8d 40 04             	lea    0x4(%eax),%eax
  80059a:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80059d:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005a2:	e9 18 01 00 00       	jmp    8006bf <vprintfmt+0x476>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8005a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005aa:	8b 10                	mov    (%eax),%edx
  8005ac:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005b1:	8d 40 04             	lea    0x4(%eax),%eax
  8005b4:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005b7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005bc:	e9 fe 00 00 00       	jmp    8006bf <vprintfmt+0x476>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005c1:	83 f9 01             	cmp    $0x1,%ecx
  8005c4:	7e 19                	jle    8005df <vprintfmt+0x396>
		return va_arg(*ap, long long);
  8005c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c9:	8b 50 04             	mov    0x4(%eax),%edx
  8005cc:	8b 00                	mov    (%eax),%eax
  8005ce:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d1:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d7:	8d 40 08             	lea    0x8(%eax),%eax
  8005da:	89 45 14             	mov    %eax,0x14(%ebp)
  8005dd:	eb 38                	jmp    800617 <vprintfmt+0x3ce>
	else if (lflag)
  8005df:	85 c9                	test   %ecx,%ecx
  8005e1:	74 1b                	je     8005fe <vprintfmt+0x3b5>
		return va_arg(*ap, long);
  8005e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e6:	8b 00                	mov    (%eax),%eax
  8005e8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005eb:	89 c1                	mov    %eax,%ecx
  8005ed:	c1 f9 1f             	sar    $0x1f,%ecx
  8005f0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f6:	8d 40 04             	lea    0x4(%eax),%eax
  8005f9:	89 45 14             	mov    %eax,0x14(%ebp)
  8005fc:	eb 19                	jmp    800617 <vprintfmt+0x3ce>
	else
		return va_arg(*ap, int);
  8005fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800601:	8b 00                	mov    (%eax),%eax
  800603:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800606:	89 c1                	mov    %eax,%ecx
  800608:	c1 f9 1f             	sar    $0x1f,%ecx
  80060b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80060e:	8b 45 14             	mov    0x14(%ebp),%eax
  800611:	8d 40 04             	lea    0x4(%eax),%eax
  800614:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
			goto number;

		// (unsigned) octal
		case 'o':
			num = getint(&ap, lflag);
  800617:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80061a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 8;
  80061d:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;

		// (unsigned) octal
		case 'o':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800622:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800626:	0f 89 93 00 00 00    	jns    8006bf <vprintfmt+0x476>
				putch('-', putdat);
  80062c:	83 ec 08             	sub    $0x8,%esp
  80062f:	53                   	push   %ebx
  800630:	6a 2d                	push   $0x2d
  800632:	ff d6                	call   *%esi
				num = -(long long) num;
  800634:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800637:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80063a:	f7 da                	neg    %edx
  80063c:	83 d1 00             	adc    $0x0,%ecx
  80063f:	f7 d9                	neg    %ecx
  800641:	83 c4 10             	add    $0x10,%esp
			}
			base = 8;
  800644:	b8 08 00 00 00       	mov    $0x8,%eax
  800649:	eb 74                	jmp    8006bf <vprintfmt+0x476>
			goto number;

		// pointer
		case 'p':
			putch('0', putdat);
  80064b:	83 ec 08             	sub    $0x8,%esp
  80064e:	53                   	push   %ebx
  80064f:	6a 30                	push   $0x30
  800651:	ff d6                	call   *%esi
			putch('x', putdat);
  800653:	83 c4 08             	add    $0x8,%esp
  800656:	53                   	push   %ebx
  800657:	6a 78                	push   $0x78
  800659:	ff d6                	call   *%esi
			num = (unsigned long long)
  80065b:	8b 45 14             	mov    0x14(%ebp),%eax
  80065e:	8b 10                	mov    (%eax),%edx
  800660:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800665:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800668:	8d 40 04             	lea    0x4(%eax),%eax
  80066b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80066e:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800673:	eb 4a                	jmp    8006bf <vprintfmt+0x476>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800675:	83 f9 01             	cmp    $0x1,%ecx
  800678:	7e 15                	jle    80068f <vprintfmt+0x446>
		return va_arg(*ap, unsigned long long);
  80067a:	8b 45 14             	mov    0x14(%ebp),%eax
  80067d:	8b 10                	mov    (%eax),%edx
  80067f:	8b 48 04             	mov    0x4(%eax),%ecx
  800682:	8d 40 08             	lea    0x8(%eax),%eax
  800685:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800688:	b8 10 00 00 00       	mov    $0x10,%eax
  80068d:	eb 30                	jmp    8006bf <vprintfmt+0x476>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80068f:	85 c9                	test   %ecx,%ecx
  800691:	74 17                	je     8006aa <vprintfmt+0x461>
		return va_arg(*ap, unsigned long);
  800693:	8b 45 14             	mov    0x14(%ebp),%eax
  800696:	8b 10                	mov    (%eax),%edx
  800698:	b9 00 00 00 00       	mov    $0x0,%ecx
  80069d:	8d 40 04             	lea    0x4(%eax),%eax
  8006a0:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006a3:	b8 10 00 00 00       	mov    $0x10,%eax
  8006a8:	eb 15                	jmp    8006bf <vprintfmt+0x476>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8006aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ad:	8b 10                	mov    (%eax),%edx
  8006af:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006b4:	8d 40 04             	lea    0x4(%eax),%eax
  8006b7:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006ba:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006bf:	83 ec 0c             	sub    $0xc,%esp
  8006c2:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006c6:	57                   	push   %edi
  8006c7:	ff 75 e0             	pushl  -0x20(%ebp)
  8006ca:	50                   	push   %eax
  8006cb:	51                   	push   %ecx
  8006cc:	52                   	push   %edx
  8006cd:	89 da                	mov    %ebx,%edx
  8006cf:	89 f0                	mov    %esi,%eax
  8006d1:	e8 8a fa ff ff       	call   800160 <printnum>
			break;
  8006d6:	83 c4 20             	add    $0x20,%esp
  8006d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006dc:	e9 8e fb ff ff       	jmp    80026f <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006e1:	83 ec 08             	sub    $0x8,%esp
  8006e4:	53                   	push   %ebx
  8006e5:	52                   	push   %edx
  8006e6:	ff d6                	call   *%esi
			break;
  8006e8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006ee:	e9 7c fb ff ff       	jmp    80026f <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006f3:	83 ec 08             	sub    $0x8,%esp
  8006f6:	53                   	push   %ebx
  8006f7:	6a 25                	push   $0x25
  8006f9:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006fb:	83 c4 10             	add    $0x10,%esp
  8006fe:	eb 03                	jmp    800703 <vprintfmt+0x4ba>
  800700:	83 ef 01             	sub    $0x1,%edi
  800703:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800707:	75 f7                	jne    800700 <vprintfmt+0x4b7>
  800709:	e9 61 fb ff ff       	jmp    80026f <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80070e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800711:	5b                   	pop    %ebx
  800712:	5e                   	pop    %esi
  800713:	5f                   	pop    %edi
  800714:	5d                   	pop    %ebp
  800715:	c3                   	ret    

00800716 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800716:	55                   	push   %ebp
  800717:	89 e5                	mov    %esp,%ebp
  800719:	83 ec 18             	sub    $0x18,%esp
  80071c:	8b 45 08             	mov    0x8(%ebp),%eax
  80071f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800722:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800725:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800729:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80072c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800733:	85 c0                	test   %eax,%eax
  800735:	74 26                	je     80075d <vsnprintf+0x47>
  800737:	85 d2                	test   %edx,%edx
  800739:	7e 22                	jle    80075d <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80073b:	ff 75 14             	pushl  0x14(%ebp)
  80073e:	ff 75 10             	pushl  0x10(%ebp)
  800741:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800744:	50                   	push   %eax
  800745:	68 0f 02 80 00       	push   $0x80020f
  80074a:	e8 fa fa ff ff       	call   800249 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80074f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800752:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800755:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800758:	83 c4 10             	add    $0x10,%esp
  80075b:	eb 05                	jmp    800762 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80075d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800762:	c9                   	leave  
  800763:	c3                   	ret    

00800764 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800764:	55                   	push   %ebp
  800765:	89 e5                	mov    %esp,%ebp
  800767:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80076a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80076d:	50                   	push   %eax
  80076e:	ff 75 10             	pushl  0x10(%ebp)
  800771:	ff 75 0c             	pushl  0xc(%ebp)
  800774:	ff 75 08             	pushl  0x8(%ebp)
  800777:	e8 9a ff ff ff       	call   800716 <vsnprintf>
	va_end(ap);

	return rc;
}
  80077c:	c9                   	leave  
  80077d:	c3                   	ret    

0080077e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80077e:	55                   	push   %ebp
  80077f:	89 e5                	mov    %esp,%ebp
  800781:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800784:	b8 00 00 00 00       	mov    $0x0,%eax
  800789:	eb 03                	jmp    80078e <strlen+0x10>
		n++;
  80078b:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80078e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800792:	75 f7                	jne    80078b <strlen+0xd>
		n++;
	return n;
}
  800794:	5d                   	pop    %ebp
  800795:	c3                   	ret    

00800796 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800796:	55                   	push   %ebp
  800797:	89 e5                	mov    %esp,%ebp
  800799:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80079c:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80079f:	ba 00 00 00 00       	mov    $0x0,%edx
  8007a4:	eb 03                	jmp    8007a9 <strnlen+0x13>
		n++;
  8007a6:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a9:	39 c2                	cmp    %eax,%edx
  8007ab:	74 08                	je     8007b5 <strnlen+0x1f>
  8007ad:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007b1:	75 f3                	jne    8007a6 <strnlen+0x10>
  8007b3:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007b5:	5d                   	pop    %ebp
  8007b6:	c3                   	ret    

008007b7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007b7:	55                   	push   %ebp
  8007b8:	89 e5                	mov    %esp,%ebp
  8007ba:	53                   	push   %ebx
  8007bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8007be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007c1:	89 c2                	mov    %eax,%edx
  8007c3:	83 c2 01             	add    $0x1,%edx
  8007c6:	83 c1 01             	add    $0x1,%ecx
  8007c9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007cd:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007d0:	84 db                	test   %bl,%bl
  8007d2:	75 ef                	jne    8007c3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007d4:	5b                   	pop    %ebx
  8007d5:	5d                   	pop    %ebp
  8007d6:	c3                   	ret    

008007d7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007d7:	55                   	push   %ebp
  8007d8:	89 e5                	mov    %esp,%ebp
  8007da:	53                   	push   %ebx
  8007db:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007de:	53                   	push   %ebx
  8007df:	e8 9a ff ff ff       	call   80077e <strlen>
  8007e4:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007e7:	ff 75 0c             	pushl  0xc(%ebp)
  8007ea:	01 d8                	add    %ebx,%eax
  8007ec:	50                   	push   %eax
  8007ed:	e8 c5 ff ff ff       	call   8007b7 <strcpy>
	return dst;
}
  8007f2:	89 d8                	mov    %ebx,%eax
  8007f4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007f7:	c9                   	leave  
  8007f8:	c3                   	ret    

008007f9 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007f9:	55                   	push   %ebp
  8007fa:	89 e5                	mov    %esp,%ebp
  8007fc:	56                   	push   %esi
  8007fd:	53                   	push   %ebx
  8007fe:	8b 75 08             	mov    0x8(%ebp),%esi
  800801:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800804:	89 f3                	mov    %esi,%ebx
  800806:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800809:	89 f2                	mov    %esi,%edx
  80080b:	eb 0f                	jmp    80081c <strncpy+0x23>
		*dst++ = *src;
  80080d:	83 c2 01             	add    $0x1,%edx
  800810:	0f b6 01             	movzbl (%ecx),%eax
  800813:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800816:	80 39 01             	cmpb   $0x1,(%ecx)
  800819:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80081c:	39 da                	cmp    %ebx,%edx
  80081e:	75 ed                	jne    80080d <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800820:	89 f0                	mov    %esi,%eax
  800822:	5b                   	pop    %ebx
  800823:	5e                   	pop    %esi
  800824:	5d                   	pop    %ebp
  800825:	c3                   	ret    

00800826 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800826:	55                   	push   %ebp
  800827:	89 e5                	mov    %esp,%ebp
  800829:	56                   	push   %esi
  80082a:	53                   	push   %ebx
  80082b:	8b 75 08             	mov    0x8(%ebp),%esi
  80082e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800831:	8b 55 10             	mov    0x10(%ebp),%edx
  800834:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800836:	85 d2                	test   %edx,%edx
  800838:	74 21                	je     80085b <strlcpy+0x35>
  80083a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80083e:	89 f2                	mov    %esi,%edx
  800840:	eb 09                	jmp    80084b <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800842:	83 c2 01             	add    $0x1,%edx
  800845:	83 c1 01             	add    $0x1,%ecx
  800848:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80084b:	39 c2                	cmp    %eax,%edx
  80084d:	74 09                	je     800858 <strlcpy+0x32>
  80084f:	0f b6 19             	movzbl (%ecx),%ebx
  800852:	84 db                	test   %bl,%bl
  800854:	75 ec                	jne    800842 <strlcpy+0x1c>
  800856:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800858:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80085b:	29 f0                	sub    %esi,%eax
}
  80085d:	5b                   	pop    %ebx
  80085e:	5e                   	pop    %esi
  80085f:	5d                   	pop    %ebp
  800860:	c3                   	ret    

00800861 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800861:	55                   	push   %ebp
  800862:	89 e5                	mov    %esp,%ebp
  800864:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800867:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80086a:	eb 06                	jmp    800872 <strcmp+0x11>
		p++, q++;
  80086c:	83 c1 01             	add    $0x1,%ecx
  80086f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800872:	0f b6 01             	movzbl (%ecx),%eax
  800875:	84 c0                	test   %al,%al
  800877:	74 04                	je     80087d <strcmp+0x1c>
  800879:	3a 02                	cmp    (%edx),%al
  80087b:	74 ef                	je     80086c <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80087d:	0f b6 c0             	movzbl %al,%eax
  800880:	0f b6 12             	movzbl (%edx),%edx
  800883:	29 d0                	sub    %edx,%eax
}
  800885:	5d                   	pop    %ebp
  800886:	c3                   	ret    

00800887 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800887:	55                   	push   %ebp
  800888:	89 e5                	mov    %esp,%ebp
  80088a:	53                   	push   %ebx
  80088b:	8b 45 08             	mov    0x8(%ebp),%eax
  80088e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800891:	89 c3                	mov    %eax,%ebx
  800893:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800896:	eb 06                	jmp    80089e <strncmp+0x17>
		n--, p++, q++;
  800898:	83 c0 01             	add    $0x1,%eax
  80089b:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80089e:	39 d8                	cmp    %ebx,%eax
  8008a0:	74 15                	je     8008b7 <strncmp+0x30>
  8008a2:	0f b6 08             	movzbl (%eax),%ecx
  8008a5:	84 c9                	test   %cl,%cl
  8008a7:	74 04                	je     8008ad <strncmp+0x26>
  8008a9:	3a 0a                	cmp    (%edx),%cl
  8008ab:	74 eb                	je     800898 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ad:	0f b6 00             	movzbl (%eax),%eax
  8008b0:	0f b6 12             	movzbl (%edx),%edx
  8008b3:	29 d0                	sub    %edx,%eax
  8008b5:	eb 05                	jmp    8008bc <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008b7:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008bc:	5b                   	pop    %ebx
  8008bd:	5d                   	pop    %ebp
  8008be:	c3                   	ret    

008008bf <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008bf:	55                   	push   %ebp
  8008c0:	89 e5                	mov    %esp,%ebp
  8008c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008c9:	eb 07                	jmp    8008d2 <strchr+0x13>
		if (*s == c)
  8008cb:	38 ca                	cmp    %cl,%dl
  8008cd:	74 0f                	je     8008de <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008cf:	83 c0 01             	add    $0x1,%eax
  8008d2:	0f b6 10             	movzbl (%eax),%edx
  8008d5:	84 d2                	test   %dl,%dl
  8008d7:	75 f2                	jne    8008cb <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008d9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008de:	5d                   	pop    %ebp
  8008df:	c3                   	ret    

008008e0 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008e0:	55                   	push   %ebp
  8008e1:	89 e5                	mov    %esp,%ebp
  8008e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ea:	eb 03                	jmp    8008ef <strfind+0xf>
  8008ec:	83 c0 01             	add    $0x1,%eax
  8008ef:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008f2:	38 ca                	cmp    %cl,%dl
  8008f4:	74 04                	je     8008fa <strfind+0x1a>
  8008f6:	84 d2                	test   %dl,%dl
  8008f8:	75 f2                	jne    8008ec <strfind+0xc>
			break;
	return (char *) s;
}
  8008fa:	5d                   	pop    %ebp
  8008fb:	c3                   	ret    

008008fc <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008fc:	55                   	push   %ebp
  8008fd:	89 e5                	mov    %esp,%ebp
  8008ff:	57                   	push   %edi
  800900:	56                   	push   %esi
  800901:	53                   	push   %ebx
  800902:	8b 7d 08             	mov    0x8(%ebp),%edi
  800905:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800908:	85 c9                	test   %ecx,%ecx
  80090a:	74 36                	je     800942 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80090c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800912:	75 28                	jne    80093c <memset+0x40>
  800914:	f6 c1 03             	test   $0x3,%cl
  800917:	75 23                	jne    80093c <memset+0x40>
		c &= 0xFF;
  800919:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80091d:	89 d3                	mov    %edx,%ebx
  80091f:	c1 e3 08             	shl    $0x8,%ebx
  800922:	89 d6                	mov    %edx,%esi
  800924:	c1 e6 18             	shl    $0x18,%esi
  800927:	89 d0                	mov    %edx,%eax
  800929:	c1 e0 10             	shl    $0x10,%eax
  80092c:	09 f0                	or     %esi,%eax
  80092e:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800930:	89 d8                	mov    %ebx,%eax
  800932:	09 d0                	or     %edx,%eax
  800934:	c1 e9 02             	shr    $0x2,%ecx
  800937:	fc                   	cld    
  800938:	f3 ab                	rep stos %eax,%es:(%edi)
  80093a:	eb 06                	jmp    800942 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80093c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80093f:	fc                   	cld    
  800940:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800942:	89 f8                	mov    %edi,%eax
  800944:	5b                   	pop    %ebx
  800945:	5e                   	pop    %esi
  800946:	5f                   	pop    %edi
  800947:	5d                   	pop    %ebp
  800948:	c3                   	ret    

00800949 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800949:	55                   	push   %ebp
  80094a:	89 e5                	mov    %esp,%ebp
  80094c:	57                   	push   %edi
  80094d:	56                   	push   %esi
  80094e:	8b 45 08             	mov    0x8(%ebp),%eax
  800951:	8b 75 0c             	mov    0xc(%ebp),%esi
  800954:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800957:	39 c6                	cmp    %eax,%esi
  800959:	73 35                	jae    800990 <memmove+0x47>
  80095b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80095e:	39 d0                	cmp    %edx,%eax
  800960:	73 2e                	jae    800990 <memmove+0x47>
		s += n;
		d += n;
  800962:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800965:	89 d6                	mov    %edx,%esi
  800967:	09 fe                	or     %edi,%esi
  800969:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80096f:	75 13                	jne    800984 <memmove+0x3b>
  800971:	f6 c1 03             	test   $0x3,%cl
  800974:	75 0e                	jne    800984 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800976:	83 ef 04             	sub    $0x4,%edi
  800979:	8d 72 fc             	lea    -0x4(%edx),%esi
  80097c:	c1 e9 02             	shr    $0x2,%ecx
  80097f:	fd                   	std    
  800980:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800982:	eb 09                	jmp    80098d <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800984:	83 ef 01             	sub    $0x1,%edi
  800987:	8d 72 ff             	lea    -0x1(%edx),%esi
  80098a:	fd                   	std    
  80098b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80098d:	fc                   	cld    
  80098e:	eb 1d                	jmp    8009ad <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800990:	89 f2                	mov    %esi,%edx
  800992:	09 c2                	or     %eax,%edx
  800994:	f6 c2 03             	test   $0x3,%dl
  800997:	75 0f                	jne    8009a8 <memmove+0x5f>
  800999:	f6 c1 03             	test   $0x3,%cl
  80099c:	75 0a                	jne    8009a8 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80099e:	c1 e9 02             	shr    $0x2,%ecx
  8009a1:	89 c7                	mov    %eax,%edi
  8009a3:	fc                   	cld    
  8009a4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a6:	eb 05                	jmp    8009ad <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009a8:	89 c7                	mov    %eax,%edi
  8009aa:	fc                   	cld    
  8009ab:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009ad:	5e                   	pop    %esi
  8009ae:	5f                   	pop    %edi
  8009af:	5d                   	pop    %ebp
  8009b0:	c3                   	ret    

008009b1 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009b1:	55                   	push   %ebp
  8009b2:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009b4:	ff 75 10             	pushl  0x10(%ebp)
  8009b7:	ff 75 0c             	pushl  0xc(%ebp)
  8009ba:	ff 75 08             	pushl  0x8(%ebp)
  8009bd:	e8 87 ff ff ff       	call   800949 <memmove>
}
  8009c2:	c9                   	leave  
  8009c3:	c3                   	ret    

008009c4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009c4:	55                   	push   %ebp
  8009c5:	89 e5                	mov    %esp,%ebp
  8009c7:	56                   	push   %esi
  8009c8:	53                   	push   %ebx
  8009c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009cf:	89 c6                	mov    %eax,%esi
  8009d1:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009d4:	eb 1a                	jmp    8009f0 <memcmp+0x2c>
		if (*s1 != *s2)
  8009d6:	0f b6 08             	movzbl (%eax),%ecx
  8009d9:	0f b6 1a             	movzbl (%edx),%ebx
  8009dc:	38 d9                	cmp    %bl,%cl
  8009de:	74 0a                	je     8009ea <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009e0:	0f b6 c1             	movzbl %cl,%eax
  8009e3:	0f b6 db             	movzbl %bl,%ebx
  8009e6:	29 d8                	sub    %ebx,%eax
  8009e8:	eb 0f                	jmp    8009f9 <memcmp+0x35>
		s1++, s2++;
  8009ea:	83 c0 01             	add    $0x1,%eax
  8009ed:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f0:	39 f0                	cmp    %esi,%eax
  8009f2:	75 e2                	jne    8009d6 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009f4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f9:	5b                   	pop    %ebx
  8009fa:	5e                   	pop    %esi
  8009fb:	5d                   	pop    %ebp
  8009fc:	c3                   	ret    

008009fd <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009fd:	55                   	push   %ebp
  8009fe:	89 e5                	mov    %esp,%ebp
  800a00:	53                   	push   %ebx
  800a01:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a04:	89 c1                	mov    %eax,%ecx
  800a06:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a09:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a0d:	eb 0a                	jmp    800a19 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a0f:	0f b6 10             	movzbl (%eax),%edx
  800a12:	39 da                	cmp    %ebx,%edx
  800a14:	74 07                	je     800a1d <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a16:	83 c0 01             	add    $0x1,%eax
  800a19:	39 c8                	cmp    %ecx,%eax
  800a1b:	72 f2                	jb     800a0f <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a1d:	5b                   	pop    %ebx
  800a1e:	5d                   	pop    %ebp
  800a1f:	c3                   	ret    

00800a20 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a20:	55                   	push   %ebp
  800a21:	89 e5                	mov    %esp,%ebp
  800a23:	57                   	push   %edi
  800a24:	56                   	push   %esi
  800a25:	53                   	push   %ebx
  800a26:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a29:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a2c:	eb 03                	jmp    800a31 <strtol+0x11>
		s++;
  800a2e:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a31:	0f b6 01             	movzbl (%ecx),%eax
  800a34:	3c 20                	cmp    $0x20,%al
  800a36:	74 f6                	je     800a2e <strtol+0xe>
  800a38:	3c 09                	cmp    $0x9,%al
  800a3a:	74 f2                	je     800a2e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a3c:	3c 2b                	cmp    $0x2b,%al
  800a3e:	75 0a                	jne    800a4a <strtol+0x2a>
		s++;
  800a40:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a43:	bf 00 00 00 00       	mov    $0x0,%edi
  800a48:	eb 11                	jmp    800a5b <strtol+0x3b>
  800a4a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a4f:	3c 2d                	cmp    $0x2d,%al
  800a51:	75 08                	jne    800a5b <strtol+0x3b>
		s++, neg = 1;
  800a53:	83 c1 01             	add    $0x1,%ecx
  800a56:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a5b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a61:	75 15                	jne    800a78 <strtol+0x58>
  800a63:	80 39 30             	cmpb   $0x30,(%ecx)
  800a66:	75 10                	jne    800a78 <strtol+0x58>
  800a68:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a6c:	75 7c                	jne    800aea <strtol+0xca>
		s += 2, base = 16;
  800a6e:	83 c1 02             	add    $0x2,%ecx
  800a71:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a76:	eb 16                	jmp    800a8e <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a78:	85 db                	test   %ebx,%ebx
  800a7a:	75 12                	jne    800a8e <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a7c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a81:	80 39 30             	cmpb   $0x30,(%ecx)
  800a84:	75 08                	jne    800a8e <strtol+0x6e>
		s++, base = 8;
  800a86:	83 c1 01             	add    $0x1,%ecx
  800a89:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a8e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a93:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a96:	0f b6 11             	movzbl (%ecx),%edx
  800a99:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a9c:	89 f3                	mov    %esi,%ebx
  800a9e:	80 fb 09             	cmp    $0x9,%bl
  800aa1:	77 08                	ja     800aab <strtol+0x8b>
			dig = *s - '0';
  800aa3:	0f be d2             	movsbl %dl,%edx
  800aa6:	83 ea 30             	sub    $0x30,%edx
  800aa9:	eb 22                	jmp    800acd <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800aab:	8d 72 9f             	lea    -0x61(%edx),%esi
  800aae:	89 f3                	mov    %esi,%ebx
  800ab0:	80 fb 19             	cmp    $0x19,%bl
  800ab3:	77 08                	ja     800abd <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ab5:	0f be d2             	movsbl %dl,%edx
  800ab8:	83 ea 57             	sub    $0x57,%edx
  800abb:	eb 10                	jmp    800acd <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800abd:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ac0:	89 f3                	mov    %esi,%ebx
  800ac2:	80 fb 19             	cmp    $0x19,%bl
  800ac5:	77 16                	ja     800add <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ac7:	0f be d2             	movsbl %dl,%edx
  800aca:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800acd:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ad0:	7d 0b                	jge    800add <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ad2:	83 c1 01             	add    $0x1,%ecx
  800ad5:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ad9:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800adb:	eb b9                	jmp    800a96 <strtol+0x76>

	if (endptr)
  800add:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ae1:	74 0d                	je     800af0 <strtol+0xd0>
		*endptr = (char *) s;
  800ae3:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ae6:	89 0e                	mov    %ecx,(%esi)
  800ae8:	eb 06                	jmp    800af0 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aea:	85 db                	test   %ebx,%ebx
  800aec:	74 98                	je     800a86 <strtol+0x66>
  800aee:	eb 9e                	jmp    800a8e <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800af0:	89 c2                	mov    %eax,%edx
  800af2:	f7 da                	neg    %edx
  800af4:	85 ff                	test   %edi,%edi
  800af6:	0f 45 c2             	cmovne %edx,%eax
}
  800af9:	5b                   	pop    %ebx
  800afa:	5e                   	pop    %esi
  800afb:	5f                   	pop    %edi
  800afc:	5d                   	pop    %ebp
  800afd:	c3                   	ret    

00800afe <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800afe:	55                   	push   %ebp
  800aff:	89 e5                	mov    %esp,%ebp
  800b01:	57                   	push   %edi
  800b02:	56                   	push   %esi
  800b03:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b04:	b8 00 00 00 00       	mov    $0x0,%eax
  800b09:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b0c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b0f:	89 c3                	mov    %eax,%ebx
  800b11:	89 c7                	mov    %eax,%edi
  800b13:	89 c6                	mov    %eax,%esi
  800b15:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b17:	5b                   	pop    %ebx
  800b18:	5e                   	pop    %esi
  800b19:	5f                   	pop    %edi
  800b1a:	5d                   	pop    %ebp
  800b1b:	c3                   	ret    

00800b1c <sys_cgetc>:

int
sys_cgetc(void)
{
  800b1c:	55                   	push   %ebp
  800b1d:	89 e5                	mov    %esp,%ebp
  800b1f:	57                   	push   %edi
  800b20:	56                   	push   %esi
  800b21:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b22:	ba 00 00 00 00       	mov    $0x0,%edx
  800b27:	b8 01 00 00 00       	mov    $0x1,%eax
  800b2c:	89 d1                	mov    %edx,%ecx
  800b2e:	89 d3                	mov    %edx,%ebx
  800b30:	89 d7                	mov    %edx,%edi
  800b32:	89 d6                	mov    %edx,%esi
  800b34:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b36:	5b                   	pop    %ebx
  800b37:	5e                   	pop    %esi
  800b38:	5f                   	pop    %edi
  800b39:	5d                   	pop    %ebp
  800b3a:	c3                   	ret    

00800b3b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b3b:	55                   	push   %ebp
  800b3c:	89 e5                	mov    %esp,%ebp
  800b3e:	57                   	push   %edi
  800b3f:	56                   	push   %esi
  800b40:	53                   	push   %ebx
  800b41:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b44:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b49:	b8 03 00 00 00       	mov    $0x3,%eax
  800b4e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b51:	89 cb                	mov    %ecx,%ebx
  800b53:	89 cf                	mov    %ecx,%edi
  800b55:	89 ce                	mov    %ecx,%esi
  800b57:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b59:	85 c0                	test   %eax,%eax
  800b5b:	7e 17                	jle    800b74 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b5d:	83 ec 0c             	sub    $0xc,%esp
  800b60:	50                   	push   %eax
  800b61:	6a 03                	push   $0x3
  800b63:	68 c0 10 80 00       	push   $0x8010c0
  800b68:	6a 23                	push   $0x23
  800b6a:	68 dd 10 80 00       	push   $0x8010dd
  800b6f:	e8 27 00 00 00       	call   800b9b <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b74:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b77:	5b                   	pop    %ebx
  800b78:	5e                   	pop    %esi
  800b79:	5f                   	pop    %edi
  800b7a:	5d                   	pop    %ebp
  800b7b:	c3                   	ret    

00800b7c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b7c:	55                   	push   %ebp
  800b7d:	89 e5                	mov    %esp,%ebp
  800b7f:	57                   	push   %edi
  800b80:	56                   	push   %esi
  800b81:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b82:	ba 00 00 00 00       	mov    $0x0,%edx
  800b87:	b8 02 00 00 00       	mov    $0x2,%eax
  800b8c:	89 d1                	mov    %edx,%ecx
  800b8e:	89 d3                	mov    %edx,%ebx
  800b90:	89 d7                	mov    %edx,%edi
  800b92:	89 d6                	mov    %edx,%esi
  800b94:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b96:	5b                   	pop    %ebx
  800b97:	5e                   	pop    %esi
  800b98:	5f                   	pop    %edi
  800b99:	5d                   	pop    %ebp
  800b9a:	c3                   	ret    

00800b9b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800b9b:	55                   	push   %ebp
  800b9c:	89 e5                	mov    %esp,%ebp
  800b9e:	56                   	push   %esi
  800b9f:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800ba0:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800ba3:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800ba9:	e8 ce ff ff ff       	call   800b7c <sys_getenvid>
  800bae:	83 ec 0c             	sub    $0xc,%esp
  800bb1:	ff 75 0c             	pushl  0xc(%ebp)
  800bb4:	ff 75 08             	pushl  0x8(%ebp)
  800bb7:	56                   	push   %esi
  800bb8:	50                   	push   %eax
  800bb9:	68 ec 10 80 00       	push   $0x8010ec
  800bbe:	e8 89 f5 ff ff       	call   80014c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800bc3:	83 c4 18             	add    $0x18,%esp
  800bc6:	53                   	push   %ebx
  800bc7:	ff 75 10             	pushl  0x10(%ebp)
  800bca:	e8 2c f5 ff ff       	call   8000fb <vcprintf>
	cprintf("\n");
  800bcf:	c7 04 24 8c 0e 80 00 	movl   $0x800e8c,(%esp)
  800bd6:	e8 71 f5 ff ff       	call   80014c <cprintf>
  800bdb:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800bde:	cc                   	int3   
  800bdf:	eb fd                	jmp    800bde <_panic+0x43>
  800be1:	66 90                	xchg   %ax,%ax
  800be3:	66 90                	xchg   %ax,%ax
  800be5:	66 90                	xchg   %ax,%ax
  800be7:	66 90                	xchg   %ax,%ax
  800be9:	66 90                	xchg   %ax,%ax
  800beb:	66 90                	xchg   %ax,%ax
  800bed:	66 90                	xchg   %ax,%ax
  800bef:	90                   	nop

00800bf0 <__udivdi3>:
  800bf0:	55                   	push   %ebp
  800bf1:	57                   	push   %edi
  800bf2:	56                   	push   %esi
  800bf3:	53                   	push   %ebx
  800bf4:	83 ec 1c             	sub    $0x1c,%esp
  800bf7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800bfb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800bff:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800c03:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800c07:	85 f6                	test   %esi,%esi
  800c09:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800c0d:	89 ca                	mov    %ecx,%edx
  800c0f:	89 f8                	mov    %edi,%eax
  800c11:	75 3d                	jne    800c50 <__udivdi3+0x60>
  800c13:	39 cf                	cmp    %ecx,%edi
  800c15:	0f 87 c5 00 00 00    	ja     800ce0 <__udivdi3+0xf0>
  800c1b:	85 ff                	test   %edi,%edi
  800c1d:	89 fd                	mov    %edi,%ebp
  800c1f:	75 0b                	jne    800c2c <__udivdi3+0x3c>
  800c21:	b8 01 00 00 00       	mov    $0x1,%eax
  800c26:	31 d2                	xor    %edx,%edx
  800c28:	f7 f7                	div    %edi
  800c2a:	89 c5                	mov    %eax,%ebp
  800c2c:	89 c8                	mov    %ecx,%eax
  800c2e:	31 d2                	xor    %edx,%edx
  800c30:	f7 f5                	div    %ebp
  800c32:	89 c1                	mov    %eax,%ecx
  800c34:	89 d8                	mov    %ebx,%eax
  800c36:	89 cf                	mov    %ecx,%edi
  800c38:	f7 f5                	div    %ebp
  800c3a:	89 c3                	mov    %eax,%ebx
  800c3c:	89 d8                	mov    %ebx,%eax
  800c3e:	89 fa                	mov    %edi,%edx
  800c40:	83 c4 1c             	add    $0x1c,%esp
  800c43:	5b                   	pop    %ebx
  800c44:	5e                   	pop    %esi
  800c45:	5f                   	pop    %edi
  800c46:	5d                   	pop    %ebp
  800c47:	c3                   	ret    
  800c48:	90                   	nop
  800c49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800c50:	39 ce                	cmp    %ecx,%esi
  800c52:	77 74                	ja     800cc8 <__udivdi3+0xd8>
  800c54:	0f bd fe             	bsr    %esi,%edi
  800c57:	83 f7 1f             	xor    $0x1f,%edi
  800c5a:	0f 84 98 00 00 00    	je     800cf8 <__udivdi3+0x108>
  800c60:	bb 20 00 00 00       	mov    $0x20,%ebx
  800c65:	89 f9                	mov    %edi,%ecx
  800c67:	89 c5                	mov    %eax,%ebp
  800c69:	29 fb                	sub    %edi,%ebx
  800c6b:	d3 e6                	shl    %cl,%esi
  800c6d:	89 d9                	mov    %ebx,%ecx
  800c6f:	d3 ed                	shr    %cl,%ebp
  800c71:	89 f9                	mov    %edi,%ecx
  800c73:	d3 e0                	shl    %cl,%eax
  800c75:	09 ee                	or     %ebp,%esi
  800c77:	89 d9                	mov    %ebx,%ecx
  800c79:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c7d:	89 d5                	mov    %edx,%ebp
  800c7f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800c83:	d3 ed                	shr    %cl,%ebp
  800c85:	89 f9                	mov    %edi,%ecx
  800c87:	d3 e2                	shl    %cl,%edx
  800c89:	89 d9                	mov    %ebx,%ecx
  800c8b:	d3 e8                	shr    %cl,%eax
  800c8d:	09 c2                	or     %eax,%edx
  800c8f:	89 d0                	mov    %edx,%eax
  800c91:	89 ea                	mov    %ebp,%edx
  800c93:	f7 f6                	div    %esi
  800c95:	89 d5                	mov    %edx,%ebp
  800c97:	89 c3                	mov    %eax,%ebx
  800c99:	f7 64 24 0c          	mull   0xc(%esp)
  800c9d:	39 d5                	cmp    %edx,%ebp
  800c9f:	72 10                	jb     800cb1 <__udivdi3+0xc1>
  800ca1:	8b 74 24 08          	mov    0x8(%esp),%esi
  800ca5:	89 f9                	mov    %edi,%ecx
  800ca7:	d3 e6                	shl    %cl,%esi
  800ca9:	39 c6                	cmp    %eax,%esi
  800cab:	73 07                	jae    800cb4 <__udivdi3+0xc4>
  800cad:	39 d5                	cmp    %edx,%ebp
  800caf:	75 03                	jne    800cb4 <__udivdi3+0xc4>
  800cb1:	83 eb 01             	sub    $0x1,%ebx
  800cb4:	31 ff                	xor    %edi,%edi
  800cb6:	89 d8                	mov    %ebx,%eax
  800cb8:	89 fa                	mov    %edi,%edx
  800cba:	83 c4 1c             	add    $0x1c,%esp
  800cbd:	5b                   	pop    %ebx
  800cbe:	5e                   	pop    %esi
  800cbf:	5f                   	pop    %edi
  800cc0:	5d                   	pop    %ebp
  800cc1:	c3                   	ret    
  800cc2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800cc8:	31 ff                	xor    %edi,%edi
  800cca:	31 db                	xor    %ebx,%ebx
  800ccc:	89 d8                	mov    %ebx,%eax
  800cce:	89 fa                	mov    %edi,%edx
  800cd0:	83 c4 1c             	add    $0x1c,%esp
  800cd3:	5b                   	pop    %ebx
  800cd4:	5e                   	pop    %esi
  800cd5:	5f                   	pop    %edi
  800cd6:	5d                   	pop    %ebp
  800cd7:	c3                   	ret    
  800cd8:	90                   	nop
  800cd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ce0:	89 d8                	mov    %ebx,%eax
  800ce2:	f7 f7                	div    %edi
  800ce4:	31 ff                	xor    %edi,%edi
  800ce6:	89 c3                	mov    %eax,%ebx
  800ce8:	89 d8                	mov    %ebx,%eax
  800cea:	89 fa                	mov    %edi,%edx
  800cec:	83 c4 1c             	add    $0x1c,%esp
  800cef:	5b                   	pop    %ebx
  800cf0:	5e                   	pop    %esi
  800cf1:	5f                   	pop    %edi
  800cf2:	5d                   	pop    %ebp
  800cf3:	c3                   	ret    
  800cf4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800cf8:	39 ce                	cmp    %ecx,%esi
  800cfa:	72 0c                	jb     800d08 <__udivdi3+0x118>
  800cfc:	31 db                	xor    %ebx,%ebx
  800cfe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800d02:	0f 87 34 ff ff ff    	ja     800c3c <__udivdi3+0x4c>
  800d08:	bb 01 00 00 00       	mov    $0x1,%ebx
  800d0d:	e9 2a ff ff ff       	jmp    800c3c <__udivdi3+0x4c>
  800d12:	66 90                	xchg   %ax,%ax
  800d14:	66 90                	xchg   %ax,%ax
  800d16:	66 90                	xchg   %ax,%ax
  800d18:	66 90                	xchg   %ax,%ax
  800d1a:	66 90                	xchg   %ax,%ax
  800d1c:	66 90                	xchg   %ax,%ax
  800d1e:	66 90                	xchg   %ax,%ax

00800d20 <__umoddi3>:
  800d20:	55                   	push   %ebp
  800d21:	57                   	push   %edi
  800d22:	56                   	push   %esi
  800d23:	53                   	push   %ebx
  800d24:	83 ec 1c             	sub    $0x1c,%esp
  800d27:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800d2b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800d2f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800d33:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d37:	85 d2                	test   %edx,%edx
  800d39:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800d3d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800d41:	89 f3                	mov    %esi,%ebx
  800d43:	89 3c 24             	mov    %edi,(%esp)
  800d46:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d4a:	75 1c                	jne    800d68 <__umoddi3+0x48>
  800d4c:	39 f7                	cmp    %esi,%edi
  800d4e:	76 50                	jbe    800da0 <__umoddi3+0x80>
  800d50:	89 c8                	mov    %ecx,%eax
  800d52:	89 f2                	mov    %esi,%edx
  800d54:	f7 f7                	div    %edi
  800d56:	89 d0                	mov    %edx,%eax
  800d58:	31 d2                	xor    %edx,%edx
  800d5a:	83 c4 1c             	add    $0x1c,%esp
  800d5d:	5b                   	pop    %ebx
  800d5e:	5e                   	pop    %esi
  800d5f:	5f                   	pop    %edi
  800d60:	5d                   	pop    %ebp
  800d61:	c3                   	ret    
  800d62:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d68:	39 f2                	cmp    %esi,%edx
  800d6a:	89 d0                	mov    %edx,%eax
  800d6c:	77 52                	ja     800dc0 <__umoddi3+0xa0>
  800d6e:	0f bd ea             	bsr    %edx,%ebp
  800d71:	83 f5 1f             	xor    $0x1f,%ebp
  800d74:	75 5a                	jne    800dd0 <__umoddi3+0xb0>
  800d76:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800d7a:	0f 82 e0 00 00 00    	jb     800e60 <__umoddi3+0x140>
  800d80:	39 0c 24             	cmp    %ecx,(%esp)
  800d83:	0f 86 d7 00 00 00    	jbe    800e60 <__umoddi3+0x140>
  800d89:	8b 44 24 08          	mov    0x8(%esp),%eax
  800d8d:	8b 54 24 04          	mov    0x4(%esp),%edx
  800d91:	83 c4 1c             	add    $0x1c,%esp
  800d94:	5b                   	pop    %ebx
  800d95:	5e                   	pop    %esi
  800d96:	5f                   	pop    %edi
  800d97:	5d                   	pop    %ebp
  800d98:	c3                   	ret    
  800d99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800da0:	85 ff                	test   %edi,%edi
  800da2:	89 fd                	mov    %edi,%ebp
  800da4:	75 0b                	jne    800db1 <__umoddi3+0x91>
  800da6:	b8 01 00 00 00       	mov    $0x1,%eax
  800dab:	31 d2                	xor    %edx,%edx
  800dad:	f7 f7                	div    %edi
  800daf:	89 c5                	mov    %eax,%ebp
  800db1:	89 f0                	mov    %esi,%eax
  800db3:	31 d2                	xor    %edx,%edx
  800db5:	f7 f5                	div    %ebp
  800db7:	89 c8                	mov    %ecx,%eax
  800db9:	f7 f5                	div    %ebp
  800dbb:	89 d0                	mov    %edx,%eax
  800dbd:	eb 99                	jmp    800d58 <__umoddi3+0x38>
  800dbf:	90                   	nop
  800dc0:	89 c8                	mov    %ecx,%eax
  800dc2:	89 f2                	mov    %esi,%edx
  800dc4:	83 c4 1c             	add    $0x1c,%esp
  800dc7:	5b                   	pop    %ebx
  800dc8:	5e                   	pop    %esi
  800dc9:	5f                   	pop    %edi
  800dca:	5d                   	pop    %ebp
  800dcb:	c3                   	ret    
  800dcc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800dd0:	8b 34 24             	mov    (%esp),%esi
  800dd3:	bf 20 00 00 00       	mov    $0x20,%edi
  800dd8:	89 e9                	mov    %ebp,%ecx
  800dda:	29 ef                	sub    %ebp,%edi
  800ddc:	d3 e0                	shl    %cl,%eax
  800dde:	89 f9                	mov    %edi,%ecx
  800de0:	89 f2                	mov    %esi,%edx
  800de2:	d3 ea                	shr    %cl,%edx
  800de4:	89 e9                	mov    %ebp,%ecx
  800de6:	09 c2                	or     %eax,%edx
  800de8:	89 d8                	mov    %ebx,%eax
  800dea:	89 14 24             	mov    %edx,(%esp)
  800ded:	89 f2                	mov    %esi,%edx
  800def:	d3 e2                	shl    %cl,%edx
  800df1:	89 f9                	mov    %edi,%ecx
  800df3:	89 54 24 04          	mov    %edx,0x4(%esp)
  800df7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800dfb:	d3 e8                	shr    %cl,%eax
  800dfd:	89 e9                	mov    %ebp,%ecx
  800dff:	89 c6                	mov    %eax,%esi
  800e01:	d3 e3                	shl    %cl,%ebx
  800e03:	89 f9                	mov    %edi,%ecx
  800e05:	89 d0                	mov    %edx,%eax
  800e07:	d3 e8                	shr    %cl,%eax
  800e09:	89 e9                	mov    %ebp,%ecx
  800e0b:	09 d8                	or     %ebx,%eax
  800e0d:	89 d3                	mov    %edx,%ebx
  800e0f:	89 f2                	mov    %esi,%edx
  800e11:	f7 34 24             	divl   (%esp)
  800e14:	89 d6                	mov    %edx,%esi
  800e16:	d3 e3                	shl    %cl,%ebx
  800e18:	f7 64 24 04          	mull   0x4(%esp)
  800e1c:	39 d6                	cmp    %edx,%esi
  800e1e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800e22:	89 d1                	mov    %edx,%ecx
  800e24:	89 c3                	mov    %eax,%ebx
  800e26:	72 08                	jb     800e30 <__umoddi3+0x110>
  800e28:	75 11                	jne    800e3b <__umoddi3+0x11b>
  800e2a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800e2e:	73 0b                	jae    800e3b <__umoddi3+0x11b>
  800e30:	2b 44 24 04          	sub    0x4(%esp),%eax
  800e34:	1b 14 24             	sbb    (%esp),%edx
  800e37:	89 d1                	mov    %edx,%ecx
  800e39:	89 c3                	mov    %eax,%ebx
  800e3b:	8b 54 24 08          	mov    0x8(%esp),%edx
  800e3f:	29 da                	sub    %ebx,%edx
  800e41:	19 ce                	sbb    %ecx,%esi
  800e43:	89 f9                	mov    %edi,%ecx
  800e45:	89 f0                	mov    %esi,%eax
  800e47:	d3 e0                	shl    %cl,%eax
  800e49:	89 e9                	mov    %ebp,%ecx
  800e4b:	d3 ea                	shr    %cl,%edx
  800e4d:	89 e9                	mov    %ebp,%ecx
  800e4f:	d3 ee                	shr    %cl,%esi
  800e51:	09 d0                	or     %edx,%eax
  800e53:	89 f2                	mov    %esi,%edx
  800e55:	83 c4 1c             	add    $0x1c,%esp
  800e58:	5b                   	pop    %ebx
  800e59:	5e                   	pop    %esi
  800e5a:	5f                   	pop    %edi
  800e5b:	5d                   	pop    %ebp
  800e5c:	c3                   	ret    
  800e5d:	8d 76 00             	lea    0x0(%esi),%esi
  800e60:	29 f9                	sub    %edi,%ecx
  800e62:	19 d6                	sbb    %edx,%esi
  800e64:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e68:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e6c:	e9 18 ff ff ff       	jmp    800d89 <__umoddi3+0x69>
