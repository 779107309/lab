
obj/user/faultreadkernel：     文件格式 elf32-i386


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

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	cprintf("I read %08x from location 0xf0100000!\n", *(unsigned*)0xf0100000);
  800039:	ff 35 00 00 10 f0    	pushl  0xf0100000
  80003f:	68 80 0e 80 00       	push   $0x800e80
  800044:	e8 f3 00 00 00       	call   80013c <cprintf>
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
  800059:	e8 0e 0b 00 00       	call   800b6c <sys_getenvid>
    thisenv = &envs[ENVX(i)];
  80005e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800063:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800066:	c1 e0 05             	shl    $0x5,%eax
  800069:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006e:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800073:	85 db                	test   %ebx,%ebx
  800075:	7e 07                	jle    80007e <libmain+0x30>
		binaryname = argv[0];
  800077:	8b 06                	mov    (%esi),%eax
  800079:	a3 00 20 80 00       	mov    %eax,0x802000

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
  80009f:	e8 87 0a 00 00       	call   800b2b <sys_env_destroy>
}
  8000a4:	83 c4 10             	add    $0x10,%esp
  8000a7:	c9                   	leave  
  8000a8:	c3                   	ret    

008000a9 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000a9:	55                   	push   %ebp
  8000aa:	89 e5                	mov    %esp,%ebp
  8000ac:	53                   	push   %ebx
  8000ad:	83 ec 04             	sub    $0x4,%esp
  8000b0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000b3:	8b 13                	mov    (%ebx),%edx
  8000b5:	8d 42 01             	lea    0x1(%edx),%eax
  8000b8:	89 03                	mov    %eax,(%ebx)
  8000ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000bd:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000c1:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000c6:	75 1a                	jne    8000e2 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000c8:	83 ec 08             	sub    $0x8,%esp
  8000cb:	68 ff 00 00 00       	push   $0xff
  8000d0:	8d 43 08             	lea    0x8(%ebx),%eax
  8000d3:	50                   	push   %eax
  8000d4:	e8 15 0a 00 00       	call   800aee <sys_cputs>
		b->idx = 0;
  8000d9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000df:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000e2:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000e6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000e9:	c9                   	leave  
  8000ea:	c3                   	ret    

008000eb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8000f4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8000fb:	00 00 00 
	b.cnt = 0;
  8000fe:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800105:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800108:	ff 75 0c             	pushl  0xc(%ebp)
  80010b:	ff 75 08             	pushl  0x8(%ebp)
  80010e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800114:	50                   	push   %eax
  800115:	68 a9 00 80 00       	push   $0x8000a9
  80011a:	e8 1a 01 00 00       	call   800239 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80011f:	83 c4 08             	add    $0x8,%esp
  800122:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800128:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80012e:	50                   	push   %eax
  80012f:	e8 ba 09 00 00       	call   800aee <sys_cputs>

	return b.cnt;
}
  800134:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80013a:	c9                   	leave  
  80013b:	c3                   	ret    

0080013c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80013c:	55                   	push   %ebp
  80013d:	89 e5                	mov    %esp,%ebp
  80013f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800142:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800145:	50                   	push   %eax
  800146:	ff 75 08             	pushl  0x8(%ebp)
  800149:	e8 9d ff ff ff       	call   8000eb <vcprintf>
	va_end(ap);

	return cnt;
}
  80014e:	c9                   	leave  
  80014f:	c3                   	ret    

00800150 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800150:	55                   	push   %ebp
  800151:	89 e5                	mov    %esp,%ebp
  800153:	57                   	push   %edi
  800154:	56                   	push   %esi
  800155:	53                   	push   %ebx
  800156:	83 ec 1c             	sub    $0x1c,%esp
  800159:	89 c7                	mov    %eax,%edi
  80015b:	89 d6                	mov    %edx,%esi
  80015d:	8b 45 08             	mov    0x8(%ebp),%eax
  800160:	8b 55 0c             	mov    0xc(%ebp),%edx
  800163:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800166:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800169:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80016c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800171:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800174:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800177:	39 d3                	cmp    %edx,%ebx
  800179:	72 05                	jb     800180 <printnum+0x30>
  80017b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80017e:	77 45                	ja     8001c5 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800180:	83 ec 0c             	sub    $0xc,%esp
  800183:	ff 75 18             	pushl  0x18(%ebp)
  800186:	8b 45 14             	mov    0x14(%ebp),%eax
  800189:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80018c:	53                   	push   %ebx
  80018d:	ff 75 10             	pushl  0x10(%ebp)
  800190:	83 ec 08             	sub    $0x8,%esp
  800193:	ff 75 e4             	pushl  -0x1c(%ebp)
  800196:	ff 75 e0             	pushl  -0x20(%ebp)
  800199:	ff 75 dc             	pushl  -0x24(%ebp)
  80019c:	ff 75 d8             	pushl  -0x28(%ebp)
  80019f:	e8 3c 0a 00 00       	call   800be0 <__udivdi3>
  8001a4:	83 c4 18             	add    $0x18,%esp
  8001a7:	52                   	push   %edx
  8001a8:	50                   	push   %eax
  8001a9:	89 f2                	mov    %esi,%edx
  8001ab:	89 f8                	mov    %edi,%eax
  8001ad:	e8 9e ff ff ff       	call   800150 <printnum>
  8001b2:	83 c4 20             	add    $0x20,%esp
  8001b5:	eb 18                	jmp    8001cf <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001b7:	83 ec 08             	sub    $0x8,%esp
  8001ba:	56                   	push   %esi
  8001bb:	ff 75 18             	pushl  0x18(%ebp)
  8001be:	ff d7                	call   *%edi
  8001c0:	83 c4 10             	add    $0x10,%esp
  8001c3:	eb 03                	jmp    8001c8 <printnum+0x78>
  8001c5:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001c8:	83 eb 01             	sub    $0x1,%ebx
  8001cb:	85 db                	test   %ebx,%ebx
  8001cd:	7f e8                	jg     8001b7 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001cf:	83 ec 08             	sub    $0x8,%esp
  8001d2:	56                   	push   %esi
  8001d3:	83 ec 04             	sub    $0x4,%esp
  8001d6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001d9:	ff 75 e0             	pushl  -0x20(%ebp)
  8001dc:	ff 75 dc             	pushl  -0x24(%ebp)
  8001df:	ff 75 d8             	pushl  -0x28(%ebp)
  8001e2:	e8 29 0b 00 00       	call   800d10 <__umoddi3>
  8001e7:	83 c4 14             	add    $0x14,%esp
  8001ea:	0f be 80 b1 0e 80 00 	movsbl 0x800eb1(%eax),%eax
  8001f1:	50                   	push   %eax
  8001f2:	ff d7                	call   *%edi
}
  8001f4:	83 c4 10             	add    $0x10,%esp
  8001f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001fa:	5b                   	pop    %ebx
  8001fb:	5e                   	pop    %esi
  8001fc:	5f                   	pop    %edi
  8001fd:	5d                   	pop    %ebp
  8001fe:	c3                   	ret    

008001ff <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8001ff:	55                   	push   %ebp
  800200:	89 e5                	mov    %esp,%ebp
  800202:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800205:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800209:	8b 10                	mov    (%eax),%edx
  80020b:	3b 50 04             	cmp    0x4(%eax),%edx
  80020e:	73 0a                	jae    80021a <sprintputch+0x1b>
		*b->buf++ = ch;
  800210:	8d 4a 01             	lea    0x1(%edx),%ecx
  800213:	89 08                	mov    %ecx,(%eax)
  800215:	8b 45 08             	mov    0x8(%ebp),%eax
  800218:	88 02                	mov    %al,(%edx)
}
  80021a:	5d                   	pop    %ebp
  80021b:	c3                   	ret    

0080021c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800222:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800225:	50                   	push   %eax
  800226:	ff 75 10             	pushl  0x10(%ebp)
  800229:	ff 75 0c             	pushl  0xc(%ebp)
  80022c:	ff 75 08             	pushl  0x8(%ebp)
  80022f:	e8 05 00 00 00       	call   800239 <vprintfmt>
	va_end(ap);
}
  800234:	83 c4 10             	add    $0x10,%esp
  800237:	c9                   	leave  
  800238:	c3                   	ret    

00800239 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800239:	55                   	push   %ebp
  80023a:	89 e5                	mov    %esp,%ebp
  80023c:	57                   	push   %edi
  80023d:	56                   	push   %esi
  80023e:	53                   	push   %ebx
  80023f:	83 ec 2c             	sub    $0x2c,%esp
  800242:	8b 75 08             	mov    0x8(%ebp),%esi
  800245:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800248:	8b 7d 10             	mov    0x10(%ebp),%edi
  80024b:	eb 12                	jmp    80025f <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80024d:	85 c0                	test   %eax,%eax
  80024f:	0f 84 a9 04 00 00    	je     8006fe <vprintfmt+0x4c5>
				return;
			putch(ch, putdat);
  800255:	83 ec 08             	sub    $0x8,%esp
  800258:	53                   	push   %ebx
  800259:	50                   	push   %eax
  80025a:	ff d6                	call   *%esi
  80025c:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80025f:	83 c7 01             	add    $0x1,%edi
  800262:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800266:	83 f8 25             	cmp    $0x25,%eax
  800269:	75 e2                	jne    80024d <vprintfmt+0x14>
  80026b:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80026f:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800276:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80027d:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800284:	b9 00 00 00 00       	mov    $0x0,%ecx
  800289:	eb 07                	jmp    800292 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80028b:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80028e:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800292:	8d 47 01             	lea    0x1(%edi),%eax
  800295:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800298:	0f b6 07             	movzbl (%edi),%eax
  80029b:	0f b6 d0             	movzbl %al,%edx
  80029e:	83 e8 23             	sub    $0x23,%eax
  8002a1:	3c 55                	cmp    $0x55,%al
  8002a3:	0f 87 3a 04 00 00    	ja     8006e3 <vprintfmt+0x4aa>
  8002a9:	0f b6 c0             	movzbl %al,%eax
  8002ac:	ff 24 85 40 0f 80 00 	jmp    *0x800f40(,%eax,4)
  8002b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8002b6:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8002ba:	eb d6                	jmp    800292 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8002c4:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8002c7:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002ca:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8002ce:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8002d1:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8002d4:	83 f9 09             	cmp    $0x9,%ecx
  8002d7:	77 3f                	ja     800318 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8002d9:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8002dc:	eb e9                	jmp    8002c7 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8002de:	8b 45 14             	mov    0x14(%ebp),%eax
  8002e1:	8b 00                	mov    (%eax),%eax
  8002e3:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8002e9:	8d 40 04             	lea    0x4(%eax),%eax
  8002ec:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8002f2:	eb 2a                	jmp    80031e <vprintfmt+0xe5>
  8002f4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002f7:	85 c0                	test   %eax,%eax
  8002f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8002fe:	0f 49 d0             	cmovns %eax,%edx
  800301:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800304:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800307:	eb 89                	jmp    800292 <vprintfmt+0x59>
  800309:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80030c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800313:	e9 7a ff ff ff       	jmp    800292 <vprintfmt+0x59>
  800318:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80031b:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80031e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800322:	0f 89 6a ff ff ff    	jns    800292 <vprintfmt+0x59>
				width = precision, precision = -1;
  800328:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80032b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80032e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800335:	e9 58 ff ff ff       	jmp    800292 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80033a:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800340:	e9 4d ff ff ff       	jmp    800292 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800345:	8b 45 14             	mov    0x14(%ebp),%eax
  800348:	8d 78 04             	lea    0x4(%eax),%edi
  80034b:	83 ec 08             	sub    $0x8,%esp
  80034e:	53                   	push   %ebx
  80034f:	ff 30                	pushl  (%eax)
  800351:	ff d6                	call   *%esi
			break;
  800353:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800356:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800359:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80035c:	e9 fe fe ff ff       	jmp    80025f <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800361:	8b 45 14             	mov    0x14(%ebp),%eax
  800364:	8d 78 04             	lea    0x4(%eax),%edi
  800367:	8b 00                	mov    (%eax),%eax
  800369:	99                   	cltd   
  80036a:	31 d0                	xor    %edx,%eax
  80036c:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80036e:	83 f8 07             	cmp    $0x7,%eax
  800371:	7f 0b                	jg     80037e <vprintfmt+0x145>
  800373:	8b 14 85 a0 10 80 00 	mov    0x8010a0(,%eax,4),%edx
  80037a:	85 d2                	test   %edx,%edx
  80037c:	75 1b                	jne    800399 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  80037e:	50                   	push   %eax
  80037f:	68 c9 0e 80 00       	push   $0x800ec9
  800384:	53                   	push   %ebx
  800385:	56                   	push   %esi
  800386:	e8 91 fe ff ff       	call   80021c <printfmt>
  80038b:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80038e:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800391:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800394:	e9 c6 fe ff ff       	jmp    80025f <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800399:	52                   	push   %edx
  80039a:	68 d2 0e 80 00       	push   $0x800ed2
  80039f:	53                   	push   %ebx
  8003a0:	56                   	push   %esi
  8003a1:	e8 76 fe ff ff       	call   80021c <printfmt>
  8003a6:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003a9:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003af:	e9 ab fe ff ff       	jmp    80025f <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b7:	83 c0 04             	add    $0x4,%eax
  8003ba:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8003bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c0:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8003c2:	85 ff                	test   %edi,%edi
  8003c4:	b8 c2 0e 80 00       	mov    $0x800ec2,%eax
  8003c9:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8003cc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003d0:	0f 8e 94 00 00 00    	jle    80046a <vprintfmt+0x231>
  8003d6:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8003da:	0f 84 98 00 00 00    	je     800478 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003e0:	83 ec 08             	sub    $0x8,%esp
  8003e3:	ff 75 d0             	pushl  -0x30(%ebp)
  8003e6:	57                   	push   %edi
  8003e7:	e8 9a 03 00 00       	call   800786 <strnlen>
  8003ec:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8003ef:	29 c1                	sub    %eax,%ecx
  8003f1:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8003f4:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8003f7:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8003fb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003fe:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800401:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800403:	eb 0f                	jmp    800414 <vprintfmt+0x1db>
					putch(padc, putdat);
  800405:	83 ec 08             	sub    $0x8,%esp
  800408:	53                   	push   %ebx
  800409:	ff 75 e0             	pushl  -0x20(%ebp)
  80040c:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80040e:	83 ef 01             	sub    $0x1,%edi
  800411:	83 c4 10             	add    $0x10,%esp
  800414:	85 ff                	test   %edi,%edi
  800416:	7f ed                	jg     800405 <vprintfmt+0x1cc>
  800418:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80041b:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80041e:	85 c9                	test   %ecx,%ecx
  800420:	b8 00 00 00 00       	mov    $0x0,%eax
  800425:	0f 49 c1             	cmovns %ecx,%eax
  800428:	29 c1                	sub    %eax,%ecx
  80042a:	89 75 08             	mov    %esi,0x8(%ebp)
  80042d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800430:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800433:	89 cb                	mov    %ecx,%ebx
  800435:	eb 4d                	jmp    800484 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800437:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80043b:	74 1b                	je     800458 <vprintfmt+0x21f>
  80043d:	0f be c0             	movsbl %al,%eax
  800440:	83 e8 20             	sub    $0x20,%eax
  800443:	83 f8 5e             	cmp    $0x5e,%eax
  800446:	76 10                	jbe    800458 <vprintfmt+0x21f>
					putch('?', putdat);
  800448:	83 ec 08             	sub    $0x8,%esp
  80044b:	ff 75 0c             	pushl  0xc(%ebp)
  80044e:	6a 3f                	push   $0x3f
  800450:	ff 55 08             	call   *0x8(%ebp)
  800453:	83 c4 10             	add    $0x10,%esp
  800456:	eb 0d                	jmp    800465 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  800458:	83 ec 08             	sub    $0x8,%esp
  80045b:	ff 75 0c             	pushl  0xc(%ebp)
  80045e:	52                   	push   %edx
  80045f:	ff 55 08             	call   *0x8(%ebp)
  800462:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800465:	83 eb 01             	sub    $0x1,%ebx
  800468:	eb 1a                	jmp    800484 <vprintfmt+0x24b>
  80046a:	89 75 08             	mov    %esi,0x8(%ebp)
  80046d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800470:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800473:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800476:	eb 0c                	jmp    800484 <vprintfmt+0x24b>
  800478:	89 75 08             	mov    %esi,0x8(%ebp)
  80047b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80047e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800481:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800484:	83 c7 01             	add    $0x1,%edi
  800487:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80048b:	0f be d0             	movsbl %al,%edx
  80048e:	85 d2                	test   %edx,%edx
  800490:	74 23                	je     8004b5 <vprintfmt+0x27c>
  800492:	85 f6                	test   %esi,%esi
  800494:	78 a1                	js     800437 <vprintfmt+0x1fe>
  800496:	83 ee 01             	sub    $0x1,%esi
  800499:	79 9c                	jns    800437 <vprintfmt+0x1fe>
  80049b:	89 df                	mov    %ebx,%edi
  80049d:	8b 75 08             	mov    0x8(%ebp),%esi
  8004a0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004a3:	eb 18                	jmp    8004bd <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004a5:	83 ec 08             	sub    $0x8,%esp
  8004a8:	53                   	push   %ebx
  8004a9:	6a 20                	push   $0x20
  8004ab:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004ad:	83 ef 01             	sub    $0x1,%edi
  8004b0:	83 c4 10             	add    $0x10,%esp
  8004b3:	eb 08                	jmp    8004bd <vprintfmt+0x284>
  8004b5:	89 df                	mov    %ebx,%edi
  8004b7:	8b 75 08             	mov    0x8(%ebp),%esi
  8004ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004bd:	85 ff                	test   %edi,%edi
  8004bf:	7f e4                	jg     8004a5 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004c1:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004c4:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004ca:	e9 90 fd ff ff       	jmp    80025f <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8004cf:	83 f9 01             	cmp    $0x1,%ecx
  8004d2:	7e 19                	jle    8004ed <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  8004d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d7:	8b 50 04             	mov    0x4(%eax),%edx
  8004da:	8b 00                	mov    (%eax),%eax
  8004dc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004df:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e5:	8d 40 08             	lea    0x8(%eax),%eax
  8004e8:	89 45 14             	mov    %eax,0x14(%ebp)
  8004eb:	eb 38                	jmp    800525 <vprintfmt+0x2ec>
	else if (lflag)
  8004ed:	85 c9                	test   %ecx,%ecx
  8004ef:	74 1b                	je     80050c <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8004f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f4:	8b 00                	mov    (%eax),%eax
  8004f6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004f9:	89 c1                	mov    %eax,%ecx
  8004fb:	c1 f9 1f             	sar    $0x1f,%ecx
  8004fe:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800501:	8b 45 14             	mov    0x14(%ebp),%eax
  800504:	8d 40 04             	lea    0x4(%eax),%eax
  800507:	89 45 14             	mov    %eax,0x14(%ebp)
  80050a:	eb 19                	jmp    800525 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  80050c:	8b 45 14             	mov    0x14(%ebp),%eax
  80050f:	8b 00                	mov    (%eax),%eax
  800511:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800514:	89 c1                	mov    %eax,%ecx
  800516:	c1 f9 1f             	sar    $0x1f,%ecx
  800519:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80051c:	8b 45 14             	mov    0x14(%ebp),%eax
  80051f:	8d 40 04             	lea    0x4(%eax),%eax
  800522:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800525:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800528:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80052b:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800530:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800534:	0f 89 75 01 00 00    	jns    8006af <vprintfmt+0x476>
				putch('-', putdat);
  80053a:	83 ec 08             	sub    $0x8,%esp
  80053d:	53                   	push   %ebx
  80053e:	6a 2d                	push   $0x2d
  800540:	ff d6                	call   *%esi
				num = -(long long) num;
  800542:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800545:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800548:	f7 da                	neg    %edx
  80054a:	83 d1 00             	adc    $0x0,%ecx
  80054d:	f7 d9                	neg    %ecx
  80054f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800552:	b8 0a 00 00 00       	mov    $0xa,%eax
  800557:	e9 53 01 00 00       	jmp    8006af <vprintfmt+0x476>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80055c:	83 f9 01             	cmp    $0x1,%ecx
  80055f:	7e 18                	jle    800579 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800561:	8b 45 14             	mov    0x14(%ebp),%eax
  800564:	8b 10                	mov    (%eax),%edx
  800566:	8b 48 04             	mov    0x4(%eax),%ecx
  800569:	8d 40 08             	lea    0x8(%eax),%eax
  80056c:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80056f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800574:	e9 36 01 00 00       	jmp    8006af <vprintfmt+0x476>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800579:	85 c9                	test   %ecx,%ecx
  80057b:	74 1a                	je     800597 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  80057d:	8b 45 14             	mov    0x14(%ebp),%eax
  800580:	8b 10                	mov    (%eax),%edx
  800582:	b9 00 00 00 00       	mov    $0x0,%ecx
  800587:	8d 40 04             	lea    0x4(%eax),%eax
  80058a:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80058d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800592:	e9 18 01 00 00       	jmp    8006af <vprintfmt+0x476>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800597:	8b 45 14             	mov    0x14(%ebp),%eax
  80059a:	8b 10                	mov    (%eax),%edx
  80059c:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005a1:	8d 40 04             	lea    0x4(%eax),%eax
  8005a4:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005a7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ac:	e9 fe 00 00 00       	jmp    8006af <vprintfmt+0x476>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005b1:	83 f9 01             	cmp    $0x1,%ecx
  8005b4:	7e 19                	jle    8005cf <vprintfmt+0x396>
		return va_arg(*ap, long long);
  8005b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b9:	8b 50 04             	mov    0x4(%eax),%edx
  8005bc:	8b 00                	mov    (%eax),%eax
  8005be:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c1:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c7:	8d 40 08             	lea    0x8(%eax),%eax
  8005ca:	89 45 14             	mov    %eax,0x14(%ebp)
  8005cd:	eb 38                	jmp    800607 <vprintfmt+0x3ce>
	else if (lflag)
  8005cf:	85 c9                	test   %ecx,%ecx
  8005d1:	74 1b                	je     8005ee <vprintfmt+0x3b5>
		return va_arg(*ap, long);
  8005d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d6:	8b 00                	mov    (%eax),%eax
  8005d8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005db:	89 c1                	mov    %eax,%ecx
  8005dd:	c1 f9 1f             	sar    $0x1f,%ecx
  8005e0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e6:	8d 40 04             	lea    0x4(%eax),%eax
  8005e9:	89 45 14             	mov    %eax,0x14(%ebp)
  8005ec:	eb 19                	jmp    800607 <vprintfmt+0x3ce>
	else
		return va_arg(*ap, int);
  8005ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f1:	8b 00                	mov    (%eax),%eax
  8005f3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f6:	89 c1                	mov    %eax,%ecx
  8005f8:	c1 f9 1f             	sar    $0x1f,%ecx
  8005fb:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800601:	8d 40 04             	lea    0x4(%eax),%eax
  800604:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
			goto number;

		// (unsigned) octal
		case 'o':
			num = getint(&ap, lflag);
  800607:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80060a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 8;
  80060d:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;

		// (unsigned) octal
		case 'o':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800612:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800616:	0f 89 93 00 00 00    	jns    8006af <vprintfmt+0x476>
				putch('-', putdat);
  80061c:	83 ec 08             	sub    $0x8,%esp
  80061f:	53                   	push   %ebx
  800620:	6a 2d                	push   $0x2d
  800622:	ff d6                	call   *%esi
				num = -(long long) num;
  800624:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800627:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80062a:	f7 da                	neg    %edx
  80062c:	83 d1 00             	adc    $0x0,%ecx
  80062f:	f7 d9                	neg    %ecx
  800631:	83 c4 10             	add    $0x10,%esp
			}
			base = 8;
  800634:	b8 08 00 00 00       	mov    $0x8,%eax
  800639:	eb 74                	jmp    8006af <vprintfmt+0x476>
			goto number;

		// pointer
		case 'p':
			putch('0', putdat);
  80063b:	83 ec 08             	sub    $0x8,%esp
  80063e:	53                   	push   %ebx
  80063f:	6a 30                	push   $0x30
  800641:	ff d6                	call   *%esi
			putch('x', putdat);
  800643:	83 c4 08             	add    $0x8,%esp
  800646:	53                   	push   %ebx
  800647:	6a 78                	push   $0x78
  800649:	ff d6                	call   *%esi
			num = (unsigned long long)
  80064b:	8b 45 14             	mov    0x14(%ebp),%eax
  80064e:	8b 10                	mov    (%eax),%edx
  800650:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800655:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800658:	8d 40 04             	lea    0x4(%eax),%eax
  80065b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80065e:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800663:	eb 4a                	jmp    8006af <vprintfmt+0x476>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800665:	83 f9 01             	cmp    $0x1,%ecx
  800668:	7e 15                	jle    80067f <vprintfmt+0x446>
		return va_arg(*ap, unsigned long long);
  80066a:	8b 45 14             	mov    0x14(%ebp),%eax
  80066d:	8b 10                	mov    (%eax),%edx
  80066f:	8b 48 04             	mov    0x4(%eax),%ecx
  800672:	8d 40 08             	lea    0x8(%eax),%eax
  800675:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800678:	b8 10 00 00 00       	mov    $0x10,%eax
  80067d:	eb 30                	jmp    8006af <vprintfmt+0x476>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80067f:	85 c9                	test   %ecx,%ecx
  800681:	74 17                	je     80069a <vprintfmt+0x461>
		return va_arg(*ap, unsigned long);
  800683:	8b 45 14             	mov    0x14(%ebp),%eax
  800686:	8b 10                	mov    (%eax),%edx
  800688:	b9 00 00 00 00       	mov    $0x0,%ecx
  80068d:	8d 40 04             	lea    0x4(%eax),%eax
  800690:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800693:	b8 10 00 00 00       	mov    $0x10,%eax
  800698:	eb 15                	jmp    8006af <vprintfmt+0x476>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80069a:	8b 45 14             	mov    0x14(%ebp),%eax
  80069d:	8b 10                	mov    (%eax),%edx
  80069f:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006a4:	8d 40 04             	lea    0x4(%eax),%eax
  8006a7:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006aa:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006af:	83 ec 0c             	sub    $0xc,%esp
  8006b2:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006b6:	57                   	push   %edi
  8006b7:	ff 75 e0             	pushl  -0x20(%ebp)
  8006ba:	50                   	push   %eax
  8006bb:	51                   	push   %ecx
  8006bc:	52                   	push   %edx
  8006bd:	89 da                	mov    %ebx,%edx
  8006bf:	89 f0                	mov    %esi,%eax
  8006c1:	e8 8a fa ff ff       	call   800150 <printnum>
			break;
  8006c6:	83 c4 20             	add    $0x20,%esp
  8006c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006cc:	e9 8e fb ff ff       	jmp    80025f <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006d1:	83 ec 08             	sub    $0x8,%esp
  8006d4:	53                   	push   %ebx
  8006d5:	52                   	push   %edx
  8006d6:	ff d6                	call   *%esi
			break;
  8006d8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006de:	e9 7c fb ff ff       	jmp    80025f <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006e3:	83 ec 08             	sub    $0x8,%esp
  8006e6:	53                   	push   %ebx
  8006e7:	6a 25                	push   $0x25
  8006e9:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006eb:	83 c4 10             	add    $0x10,%esp
  8006ee:	eb 03                	jmp    8006f3 <vprintfmt+0x4ba>
  8006f0:	83 ef 01             	sub    $0x1,%edi
  8006f3:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006f7:	75 f7                	jne    8006f0 <vprintfmt+0x4b7>
  8006f9:	e9 61 fb ff ff       	jmp    80025f <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800701:	5b                   	pop    %ebx
  800702:	5e                   	pop    %esi
  800703:	5f                   	pop    %edi
  800704:	5d                   	pop    %ebp
  800705:	c3                   	ret    

00800706 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800706:	55                   	push   %ebp
  800707:	89 e5                	mov    %esp,%ebp
  800709:	83 ec 18             	sub    $0x18,%esp
  80070c:	8b 45 08             	mov    0x8(%ebp),%eax
  80070f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800712:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800715:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800719:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80071c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800723:	85 c0                	test   %eax,%eax
  800725:	74 26                	je     80074d <vsnprintf+0x47>
  800727:	85 d2                	test   %edx,%edx
  800729:	7e 22                	jle    80074d <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80072b:	ff 75 14             	pushl  0x14(%ebp)
  80072e:	ff 75 10             	pushl  0x10(%ebp)
  800731:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800734:	50                   	push   %eax
  800735:	68 ff 01 80 00       	push   $0x8001ff
  80073a:	e8 fa fa ff ff       	call   800239 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80073f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800742:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800745:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800748:	83 c4 10             	add    $0x10,%esp
  80074b:	eb 05                	jmp    800752 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80074d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800752:	c9                   	leave  
  800753:	c3                   	ret    

00800754 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800754:	55                   	push   %ebp
  800755:	89 e5                	mov    %esp,%ebp
  800757:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80075a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80075d:	50                   	push   %eax
  80075e:	ff 75 10             	pushl  0x10(%ebp)
  800761:	ff 75 0c             	pushl  0xc(%ebp)
  800764:	ff 75 08             	pushl  0x8(%ebp)
  800767:	e8 9a ff ff ff       	call   800706 <vsnprintf>
	va_end(ap);

	return rc;
}
  80076c:	c9                   	leave  
  80076d:	c3                   	ret    

0080076e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80076e:	55                   	push   %ebp
  80076f:	89 e5                	mov    %esp,%ebp
  800771:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800774:	b8 00 00 00 00       	mov    $0x0,%eax
  800779:	eb 03                	jmp    80077e <strlen+0x10>
		n++;
  80077b:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80077e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800782:	75 f7                	jne    80077b <strlen+0xd>
		n++;
	return n;
}
  800784:	5d                   	pop    %ebp
  800785:	c3                   	ret    

00800786 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800786:	55                   	push   %ebp
  800787:	89 e5                	mov    %esp,%ebp
  800789:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80078c:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80078f:	ba 00 00 00 00       	mov    $0x0,%edx
  800794:	eb 03                	jmp    800799 <strnlen+0x13>
		n++;
  800796:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800799:	39 c2                	cmp    %eax,%edx
  80079b:	74 08                	je     8007a5 <strnlen+0x1f>
  80079d:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007a1:	75 f3                	jne    800796 <strnlen+0x10>
  8007a3:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007a5:	5d                   	pop    %ebp
  8007a6:	c3                   	ret    

008007a7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007a7:	55                   	push   %ebp
  8007a8:	89 e5                	mov    %esp,%ebp
  8007aa:	53                   	push   %ebx
  8007ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007b1:	89 c2                	mov    %eax,%edx
  8007b3:	83 c2 01             	add    $0x1,%edx
  8007b6:	83 c1 01             	add    $0x1,%ecx
  8007b9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007bd:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007c0:	84 db                	test   %bl,%bl
  8007c2:	75 ef                	jne    8007b3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007c4:	5b                   	pop    %ebx
  8007c5:	5d                   	pop    %ebp
  8007c6:	c3                   	ret    

008007c7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007c7:	55                   	push   %ebp
  8007c8:	89 e5                	mov    %esp,%ebp
  8007ca:	53                   	push   %ebx
  8007cb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007ce:	53                   	push   %ebx
  8007cf:	e8 9a ff ff ff       	call   80076e <strlen>
  8007d4:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007d7:	ff 75 0c             	pushl  0xc(%ebp)
  8007da:	01 d8                	add    %ebx,%eax
  8007dc:	50                   	push   %eax
  8007dd:	e8 c5 ff ff ff       	call   8007a7 <strcpy>
	return dst;
}
  8007e2:	89 d8                	mov    %ebx,%eax
  8007e4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007e7:	c9                   	leave  
  8007e8:	c3                   	ret    

008007e9 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007e9:	55                   	push   %ebp
  8007ea:	89 e5                	mov    %esp,%ebp
  8007ec:	56                   	push   %esi
  8007ed:	53                   	push   %ebx
  8007ee:	8b 75 08             	mov    0x8(%ebp),%esi
  8007f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007f4:	89 f3                	mov    %esi,%ebx
  8007f6:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007f9:	89 f2                	mov    %esi,%edx
  8007fb:	eb 0f                	jmp    80080c <strncpy+0x23>
		*dst++ = *src;
  8007fd:	83 c2 01             	add    $0x1,%edx
  800800:	0f b6 01             	movzbl (%ecx),%eax
  800803:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800806:	80 39 01             	cmpb   $0x1,(%ecx)
  800809:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80080c:	39 da                	cmp    %ebx,%edx
  80080e:	75 ed                	jne    8007fd <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800810:	89 f0                	mov    %esi,%eax
  800812:	5b                   	pop    %ebx
  800813:	5e                   	pop    %esi
  800814:	5d                   	pop    %ebp
  800815:	c3                   	ret    

00800816 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800816:	55                   	push   %ebp
  800817:	89 e5                	mov    %esp,%ebp
  800819:	56                   	push   %esi
  80081a:	53                   	push   %ebx
  80081b:	8b 75 08             	mov    0x8(%ebp),%esi
  80081e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800821:	8b 55 10             	mov    0x10(%ebp),%edx
  800824:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800826:	85 d2                	test   %edx,%edx
  800828:	74 21                	je     80084b <strlcpy+0x35>
  80082a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80082e:	89 f2                	mov    %esi,%edx
  800830:	eb 09                	jmp    80083b <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800832:	83 c2 01             	add    $0x1,%edx
  800835:	83 c1 01             	add    $0x1,%ecx
  800838:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80083b:	39 c2                	cmp    %eax,%edx
  80083d:	74 09                	je     800848 <strlcpy+0x32>
  80083f:	0f b6 19             	movzbl (%ecx),%ebx
  800842:	84 db                	test   %bl,%bl
  800844:	75 ec                	jne    800832 <strlcpy+0x1c>
  800846:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800848:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80084b:	29 f0                	sub    %esi,%eax
}
  80084d:	5b                   	pop    %ebx
  80084e:	5e                   	pop    %esi
  80084f:	5d                   	pop    %ebp
  800850:	c3                   	ret    

00800851 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800851:	55                   	push   %ebp
  800852:	89 e5                	mov    %esp,%ebp
  800854:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800857:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80085a:	eb 06                	jmp    800862 <strcmp+0x11>
		p++, q++;
  80085c:	83 c1 01             	add    $0x1,%ecx
  80085f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800862:	0f b6 01             	movzbl (%ecx),%eax
  800865:	84 c0                	test   %al,%al
  800867:	74 04                	je     80086d <strcmp+0x1c>
  800869:	3a 02                	cmp    (%edx),%al
  80086b:	74 ef                	je     80085c <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80086d:	0f b6 c0             	movzbl %al,%eax
  800870:	0f b6 12             	movzbl (%edx),%edx
  800873:	29 d0                	sub    %edx,%eax
}
  800875:	5d                   	pop    %ebp
  800876:	c3                   	ret    

00800877 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800877:	55                   	push   %ebp
  800878:	89 e5                	mov    %esp,%ebp
  80087a:	53                   	push   %ebx
  80087b:	8b 45 08             	mov    0x8(%ebp),%eax
  80087e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800881:	89 c3                	mov    %eax,%ebx
  800883:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800886:	eb 06                	jmp    80088e <strncmp+0x17>
		n--, p++, q++;
  800888:	83 c0 01             	add    $0x1,%eax
  80088b:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80088e:	39 d8                	cmp    %ebx,%eax
  800890:	74 15                	je     8008a7 <strncmp+0x30>
  800892:	0f b6 08             	movzbl (%eax),%ecx
  800895:	84 c9                	test   %cl,%cl
  800897:	74 04                	je     80089d <strncmp+0x26>
  800899:	3a 0a                	cmp    (%edx),%cl
  80089b:	74 eb                	je     800888 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80089d:	0f b6 00             	movzbl (%eax),%eax
  8008a0:	0f b6 12             	movzbl (%edx),%edx
  8008a3:	29 d0                	sub    %edx,%eax
  8008a5:	eb 05                	jmp    8008ac <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008a7:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008ac:	5b                   	pop    %ebx
  8008ad:	5d                   	pop    %ebp
  8008ae:	c3                   	ret    

008008af <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008af:	55                   	push   %ebp
  8008b0:	89 e5                	mov    %esp,%ebp
  8008b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008b9:	eb 07                	jmp    8008c2 <strchr+0x13>
		if (*s == c)
  8008bb:	38 ca                	cmp    %cl,%dl
  8008bd:	74 0f                	je     8008ce <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008bf:	83 c0 01             	add    $0x1,%eax
  8008c2:	0f b6 10             	movzbl (%eax),%edx
  8008c5:	84 d2                	test   %dl,%dl
  8008c7:	75 f2                	jne    8008bb <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008c9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008ce:	5d                   	pop    %ebp
  8008cf:	c3                   	ret    

008008d0 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008d0:	55                   	push   %ebp
  8008d1:	89 e5                	mov    %esp,%ebp
  8008d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008da:	eb 03                	jmp    8008df <strfind+0xf>
  8008dc:	83 c0 01             	add    $0x1,%eax
  8008df:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008e2:	38 ca                	cmp    %cl,%dl
  8008e4:	74 04                	je     8008ea <strfind+0x1a>
  8008e6:	84 d2                	test   %dl,%dl
  8008e8:	75 f2                	jne    8008dc <strfind+0xc>
			break;
	return (char *) s;
}
  8008ea:	5d                   	pop    %ebp
  8008eb:	c3                   	ret    

008008ec <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008ec:	55                   	push   %ebp
  8008ed:	89 e5                	mov    %esp,%ebp
  8008ef:	57                   	push   %edi
  8008f0:	56                   	push   %esi
  8008f1:	53                   	push   %ebx
  8008f2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008f5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008f8:	85 c9                	test   %ecx,%ecx
  8008fa:	74 36                	je     800932 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008fc:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800902:	75 28                	jne    80092c <memset+0x40>
  800904:	f6 c1 03             	test   $0x3,%cl
  800907:	75 23                	jne    80092c <memset+0x40>
		c &= 0xFF;
  800909:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80090d:	89 d3                	mov    %edx,%ebx
  80090f:	c1 e3 08             	shl    $0x8,%ebx
  800912:	89 d6                	mov    %edx,%esi
  800914:	c1 e6 18             	shl    $0x18,%esi
  800917:	89 d0                	mov    %edx,%eax
  800919:	c1 e0 10             	shl    $0x10,%eax
  80091c:	09 f0                	or     %esi,%eax
  80091e:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800920:	89 d8                	mov    %ebx,%eax
  800922:	09 d0                	or     %edx,%eax
  800924:	c1 e9 02             	shr    $0x2,%ecx
  800927:	fc                   	cld    
  800928:	f3 ab                	rep stos %eax,%es:(%edi)
  80092a:	eb 06                	jmp    800932 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80092c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80092f:	fc                   	cld    
  800930:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800932:	89 f8                	mov    %edi,%eax
  800934:	5b                   	pop    %ebx
  800935:	5e                   	pop    %esi
  800936:	5f                   	pop    %edi
  800937:	5d                   	pop    %ebp
  800938:	c3                   	ret    

00800939 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800939:	55                   	push   %ebp
  80093a:	89 e5                	mov    %esp,%ebp
  80093c:	57                   	push   %edi
  80093d:	56                   	push   %esi
  80093e:	8b 45 08             	mov    0x8(%ebp),%eax
  800941:	8b 75 0c             	mov    0xc(%ebp),%esi
  800944:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800947:	39 c6                	cmp    %eax,%esi
  800949:	73 35                	jae    800980 <memmove+0x47>
  80094b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80094e:	39 d0                	cmp    %edx,%eax
  800950:	73 2e                	jae    800980 <memmove+0x47>
		s += n;
		d += n;
  800952:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800955:	89 d6                	mov    %edx,%esi
  800957:	09 fe                	or     %edi,%esi
  800959:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80095f:	75 13                	jne    800974 <memmove+0x3b>
  800961:	f6 c1 03             	test   $0x3,%cl
  800964:	75 0e                	jne    800974 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800966:	83 ef 04             	sub    $0x4,%edi
  800969:	8d 72 fc             	lea    -0x4(%edx),%esi
  80096c:	c1 e9 02             	shr    $0x2,%ecx
  80096f:	fd                   	std    
  800970:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800972:	eb 09                	jmp    80097d <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800974:	83 ef 01             	sub    $0x1,%edi
  800977:	8d 72 ff             	lea    -0x1(%edx),%esi
  80097a:	fd                   	std    
  80097b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80097d:	fc                   	cld    
  80097e:	eb 1d                	jmp    80099d <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800980:	89 f2                	mov    %esi,%edx
  800982:	09 c2                	or     %eax,%edx
  800984:	f6 c2 03             	test   $0x3,%dl
  800987:	75 0f                	jne    800998 <memmove+0x5f>
  800989:	f6 c1 03             	test   $0x3,%cl
  80098c:	75 0a                	jne    800998 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80098e:	c1 e9 02             	shr    $0x2,%ecx
  800991:	89 c7                	mov    %eax,%edi
  800993:	fc                   	cld    
  800994:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800996:	eb 05                	jmp    80099d <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800998:	89 c7                	mov    %eax,%edi
  80099a:	fc                   	cld    
  80099b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80099d:	5e                   	pop    %esi
  80099e:	5f                   	pop    %edi
  80099f:	5d                   	pop    %ebp
  8009a0:	c3                   	ret    

008009a1 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009a1:	55                   	push   %ebp
  8009a2:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009a4:	ff 75 10             	pushl  0x10(%ebp)
  8009a7:	ff 75 0c             	pushl  0xc(%ebp)
  8009aa:	ff 75 08             	pushl  0x8(%ebp)
  8009ad:	e8 87 ff ff ff       	call   800939 <memmove>
}
  8009b2:	c9                   	leave  
  8009b3:	c3                   	ret    

008009b4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009b4:	55                   	push   %ebp
  8009b5:	89 e5                	mov    %esp,%ebp
  8009b7:	56                   	push   %esi
  8009b8:	53                   	push   %ebx
  8009b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009bf:	89 c6                	mov    %eax,%esi
  8009c1:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009c4:	eb 1a                	jmp    8009e0 <memcmp+0x2c>
		if (*s1 != *s2)
  8009c6:	0f b6 08             	movzbl (%eax),%ecx
  8009c9:	0f b6 1a             	movzbl (%edx),%ebx
  8009cc:	38 d9                	cmp    %bl,%cl
  8009ce:	74 0a                	je     8009da <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009d0:	0f b6 c1             	movzbl %cl,%eax
  8009d3:	0f b6 db             	movzbl %bl,%ebx
  8009d6:	29 d8                	sub    %ebx,%eax
  8009d8:	eb 0f                	jmp    8009e9 <memcmp+0x35>
		s1++, s2++;
  8009da:	83 c0 01             	add    $0x1,%eax
  8009dd:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009e0:	39 f0                	cmp    %esi,%eax
  8009e2:	75 e2                	jne    8009c6 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009e4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e9:	5b                   	pop    %ebx
  8009ea:	5e                   	pop    %esi
  8009eb:	5d                   	pop    %ebp
  8009ec:	c3                   	ret    

008009ed <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009ed:	55                   	push   %ebp
  8009ee:	89 e5                	mov    %esp,%ebp
  8009f0:	53                   	push   %ebx
  8009f1:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009f4:	89 c1                	mov    %eax,%ecx
  8009f6:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009f9:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009fd:	eb 0a                	jmp    800a09 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009ff:	0f b6 10             	movzbl (%eax),%edx
  800a02:	39 da                	cmp    %ebx,%edx
  800a04:	74 07                	je     800a0d <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a06:	83 c0 01             	add    $0x1,%eax
  800a09:	39 c8                	cmp    %ecx,%eax
  800a0b:	72 f2                	jb     8009ff <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a0d:	5b                   	pop    %ebx
  800a0e:	5d                   	pop    %ebp
  800a0f:	c3                   	ret    

00800a10 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a10:	55                   	push   %ebp
  800a11:	89 e5                	mov    %esp,%ebp
  800a13:	57                   	push   %edi
  800a14:	56                   	push   %esi
  800a15:	53                   	push   %ebx
  800a16:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a19:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a1c:	eb 03                	jmp    800a21 <strtol+0x11>
		s++;
  800a1e:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a21:	0f b6 01             	movzbl (%ecx),%eax
  800a24:	3c 20                	cmp    $0x20,%al
  800a26:	74 f6                	je     800a1e <strtol+0xe>
  800a28:	3c 09                	cmp    $0x9,%al
  800a2a:	74 f2                	je     800a1e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a2c:	3c 2b                	cmp    $0x2b,%al
  800a2e:	75 0a                	jne    800a3a <strtol+0x2a>
		s++;
  800a30:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a33:	bf 00 00 00 00       	mov    $0x0,%edi
  800a38:	eb 11                	jmp    800a4b <strtol+0x3b>
  800a3a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a3f:	3c 2d                	cmp    $0x2d,%al
  800a41:	75 08                	jne    800a4b <strtol+0x3b>
		s++, neg = 1;
  800a43:	83 c1 01             	add    $0x1,%ecx
  800a46:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a4b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a51:	75 15                	jne    800a68 <strtol+0x58>
  800a53:	80 39 30             	cmpb   $0x30,(%ecx)
  800a56:	75 10                	jne    800a68 <strtol+0x58>
  800a58:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a5c:	75 7c                	jne    800ada <strtol+0xca>
		s += 2, base = 16;
  800a5e:	83 c1 02             	add    $0x2,%ecx
  800a61:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a66:	eb 16                	jmp    800a7e <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a68:	85 db                	test   %ebx,%ebx
  800a6a:	75 12                	jne    800a7e <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a6c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a71:	80 39 30             	cmpb   $0x30,(%ecx)
  800a74:	75 08                	jne    800a7e <strtol+0x6e>
		s++, base = 8;
  800a76:	83 c1 01             	add    $0x1,%ecx
  800a79:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a7e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a83:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a86:	0f b6 11             	movzbl (%ecx),%edx
  800a89:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a8c:	89 f3                	mov    %esi,%ebx
  800a8e:	80 fb 09             	cmp    $0x9,%bl
  800a91:	77 08                	ja     800a9b <strtol+0x8b>
			dig = *s - '0';
  800a93:	0f be d2             	movsbl %dl,%edx
  800a96:	83 ea 30             	sub    $0x30,%edx
  800a99:	eb 22                	jmp    800abd <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a9b:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a9e:	89 f3                	mov    %esi,%ebx
  800aa0:	80 fb 19             	cmp    $0x19,%bl
  800aa3:	77 08                	ja     800aad <strtol+0x9d>
			dig = *s - 'a' + 10;
  800aa5:	0f be d2             	movsbl %dl,%edx
  800aa8:	83 ea 57             	sub    $0x57,%edx
  800aab:	eb 10                	jmp    800abd <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800aad:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ab0:	89 f3                	mov    %esi,%ebx
  800ab2:	80 fb 19             	cmp    $0x19,%bl
  800ab5:	77 16                	ja     800acd <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ab7:	0f be d2             	movsbl %dl,%edx
  800aba:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800abd:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ac0:	7d 0b                	jge    800acd <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ac2:	83 c1 01             	add    $0x1,%ecx
  800ac5:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ac9:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800acb:	eb b9                	jmp    800a86 <strtol+0x76>

	if (endptr)
  800acd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ad1:	74 0d                	je     800ae0 <strtol+0xd0>
		*endptr = (char *) s;
  800ad3:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ad6:	89 0e                	mov    %ecx,(%esi)
  800ad8:	eb 06                	jmp    800ae0 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ada:	85 db                	test   %ebx,%ebx
  800adc:	74 98                	je     800a76 <strtol+0x66>
  800ade:	eb 9e                	jmp    800a7e <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ae0:	89 c2                	mov    %eax,%edx
  800ae2:	f7 da                	neg    %edx
  800ae4:	85 ff                	test   %edi,%edi
  800ae6:	0f 45 c2             	cmovne %edx,%eax
}
  800ae9:	5b                   	pop    %ebx
  800aea:	5e                   	pop    %esi
  800aeb:	5f                   	pop    %edi
  800aec:	5d                   	pop    %ebp
  800aed:	c3                   	ret    

00800aee <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800aee:	55                   	push   %ebp
  800aef:	89 e5                	mov    %esp,%ebp
  800af1:	57                   	push   %edi
  800af2:	56                   	push   %esi
  800af3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af4:	b8 00 00 00 00       	mov    $0x0,%eax
  800af9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800afc:	8b 55 08             	mov    0x8(%ebp),%edx
  800aff:	89 c3                	mov    %eax,%ebx
  800b01:	89 c7                	mov    %eax,%edi
  800b03:	89 c6                	mov    %eax,%esi
  800b05:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b07:	5b                   	pop    %ebx
  800b08:	5e                   	pop    %esi
  800b09:	5f                   	pop    %edi
  800b0a:	5d                   	pop    %ebp
  800b0b:	c3                   	ret    

00800b0c <sys_cgetc>:

int
sys_cgetc(void)
{
  800b0c:	55                   	push   %ebp
  800b0d:	89 e5                	mov    %esp,%ebp
  800b0f:	57                   	push   %edi
  800b10:	56                   	push   %esi
  800b11:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b12:	ba 00 00 00 00       	mov    $0x0,%edx
  800b17:	b8 01 00 00 00       	mov    $0x1,%eax
  800b1c:	89 d1                	mov    %edx,%ecx
  800b1e:	89 d3                	mov    %edx,%ebx
  800b20:	89 d7                	mov    %edx,%edi
  800b22:	89 d6                	mov    %edx,%esi
  800b24:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b26:	5b                   	pop    %ebx
  800b27:	5e                   	pop    %esi
  800b28:	5f                   	pop    %edi
  800b29:	5d                   	pop    %ebp
  800b2a:	c3                   	ret    

00800b2b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b2b:	55                   	push   %ebp
  800b2c:	89 e5                	mov    %esp,%ebp
  800b2e:	57                   	push   %edi
  800b2f:	56                   	push   %esi
  800b30:	53                   	push   %ebx
  800b31:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b34:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b39:	b8 03 00 00 00       	mov    $0x3,%eax
  800b3e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b41:	89 cb                	mov    %ecx,%ebx
  800b43:	89 cf                	mov    %ecx,%edi
  800b45:	89 ce                	mov    %ecx,%esi
  800b47:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b49:	85 c0                	test   %eax,%eax
  800b4b:	7e 17                	jle    800b64 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b4d:	83 ec 0c             	sub    $0xc,%esp
  800b50:	50                   	push   %eax
  800b51:	6a 03                	push   $0x3
  800b53:	68 c0 10 80 00       	push   $0x8010c0
  800b58:	6a 23                	push   $0x23
  800b5a:	68 dd 10 80 00       	push   $0x8010dd
  800b5f:	e8 27 00 00 00       	call   800b8b <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b64:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b67:	5b                   	pop    %ebx
  800b68:	5e                   	pop    %esi
  800b69:	5f                   	pop    %edi
  800b6a:	5d                   	pop    %ebp
  800b6b:	c3                   	ret    

00800b6c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b6c:	55                   	push   %ebp
  800b6d:	89 e5                	mov    %esp,%ebp
  800b6f:	57                   	push   %edi
  800b70:	56                   	push   %esi
  800b71:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b72:	ba 00 00 00 00       	mov    $0x0,%edx
  800b77:	b8 02 00 00 00       	mov    $0x2,%eax
  800b7c:	89 d1                	mov    %edx,%ecx
  800b7e:	89 d3                	mov    %edx,%ebx
  800b80:	89 d7                	mov    %edx,%edi
  800b82:	89 d6                	mov    %edx,%esi
  800b84:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b86:	5b                   	pop    %ebx
  800b87:	5e                   	pop    %esi
  800b88:	5f                   	pop    %edi
  800b89:	5d                   	pop    %ebp
  800b8a:	c3                   	ret    

00800b8b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800b8b:	55                   	push   %ebp
  800b8c:	89 e5                	mov    %esp,%ebp
  800b8e:	56                   	push   %esi
  800b8f:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800b90:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800b93:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800b99:	e8 ce ff ff ff       	call   800b6c <sys_getenvid>
  800b9e:	83 ec 0c             	sub    $0xc,%esp
  800ba1:	ff 75 0c             	pushl  0xc(%ebp)
  800ba4:	ff 75 08             	pushl  0x8(%ebp)
  800ba7:	56                   	push   %esi
  800ba8:	50                   	push   %eax
  800ba9:	68 ec 10 80 00       	push   $0x8010ec
  800bae:	e8 89 f5 ff ff       	call   80013c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800bb3:	83 c4 18             	add    $0x18,%esp
  800bb6:	53                   	push   %ebx
  800bb7:	ff 75 10             	pushl  0x10(%ebp)
  800bba:	e8 2c f5 ff ff       	call   8000eb <vcprintf>
	cprintf("\n");
  800bbf:	c7 04 24 10 11 80 00 	movl   $0x801110,(%esp)
  800bc6:	e8 71 f5 ff ff       	call   80013c <cprintf>
  800bcb:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800bce:	cc                   	int3   
  800bcf:	eb fd                	jmp    800bce <_panic+0x43>
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
