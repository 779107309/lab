
obj/user/divzero：     文件格式 elf32-i386


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
  80002c:	e8 2f 00 00 00       	call   800060 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

int zero;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	zero = 0;
  800039:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800040:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  800043:	b8 01 00 00 00       	mov    $0x1,%eax
  800048:	b9 00 00 00 00       	mov    $0x0,%ecx
  80004d:	99                   	cltd   
  80004e:	f7 f9                	idiv   %ecx
  800050:	50                   	push   %eax
  800051:	68 80 0e 80 00       	push   $0x800e80
  800056:	e8 f3 00 00 00       	call   80014e <cprintf>
}
  80005b:	83 c4 10             	add    $0x10,%esp
  80005e:	c9                   	leave  
  80005f:	c3                   	ret    

00800060 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800060:	55                   	push   %ebp
  800061:	89 e5                	mov    %esp,%ebp
  800063:	56                   	push   %esi
  800064:	53                   	push   %ebx
  800065:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800068:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t i = sys_getenvid();
  80006b:	e8 0e 0b 00 00       	call   800b7e <sys_getenvid>
    thisenv = &envs[ENVX(i)];
  800070:	25 ff 03 00 00       	and    $0x3ff,%eax
  800075:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800078:	c1 e0 05             	shl    $0x5,%eax
  80007b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800080:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800085:	85 db                	test   %ebx,%ebx
  800087:	7e 07                	jle    800090 <libmain+0x30>
		binaryname = argv[0];
  800089:	8b 06                	mov    (%esi),%eax
  80008b:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800090:	83 ec 08             	sub    $0x8,%esp
  800093:	56                   	push   %esi
  800094:	53                   	push   %ebx
  800095:	e8 99 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80009a:	e8 0a 00 00 00       	call   8000a9 <exit>
}
  80009f:	83 c4 10             	add    $0x10,%esp
  8000a2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a5:	5b                   	pop    %ebx
  8000a6:	5e                   	pop    %esi
  8000a7:	5d                   	pop    %ebp
  8000a8:	c3                   	ret    

008000a9 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a9:	55                   	push   %ebp
  8000aa:	89 e5                	mov    %esp,%ebp
  8000ac:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000af:	6a 00                	push   $0x0
  8000b1:	e8 87 0a 00 00       	call   800b3d <sys_env_destroy>
}
  8000b6:	83 c4 10             	add    $0x10,%esp
  8000b9:	c9                   	leave  
  8000ba:	c3                   	ret    

008000bb <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000bb:	55                   	push   %ebp
  8000bc:	89 e5                	mov    %esp,%ebp
  8000be:	53                   	push   %ebx
  8000bf:	83 ec 04             	sub    $0x4,%esp
  8000c2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000c5:	8b 13                	mov    (%ebx),%edx
  8000c7:	8d 42 01             	lea    0x1(%edx),%eax
  8000ca:	89 03                	mov    %eax,(%ebx)
  8000cc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000cf:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000d3:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000d8:	75 1a                	jne    8000f4 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000da:	83 ec 08             	sub    $0x8,%esp
  8000dd:	68 ff 00 00 00       	push   $0xff
  8000e2:	8d 43 08             	lea    0x8(%ebx),%eax
  8000e5:	50                   	push   %eax
  8000e6:	e8 15 0a 00 00       	call   800b00 <sys_cputs>
		b->idx = 0;
  8000eb:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000f1:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000f4:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000f8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000fb:	c9                   	leave  
  8000fc:	c3                   	ret    

008000fd <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000fd:	55                   	push   %ebp
  8000fe:	89 e5                	mov    %esp,%ebp
  800100:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800106:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80010d:	00 00 00 
	b.cnt = 0;
  800110:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800117:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80011a:	ff 75 0c             	pushl  0xc(%ebp)
  80011d:	ff 75 08             	pushl  0x8(%ebp)
  800120:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800126:	50                   	push   %eax
  800127:	68 bb 00 80 00       	push   $0x8000bb
  80012c:	e8 1a 01 00 00       	call   80024b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800131:	83 c4 08             	add    $0x8,%esp
  800134:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80013a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800140:	50                   	push   %eax
  800141:	e8 ba 09 00 00       	call   800b00 <sys_cputs>

	return b.cnt;
}
  800146:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80014c:	c9                   	leave  
  80014d:	c3                   	ret    

0080014e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80014e:	55                   	push   %ebp
  80014f:	89 e5                	mov    %esp,%ebp
  800151:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800154:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800157:	50                   	push   %eax
  800158:	ff 75 08             	pushl  0x8(%ebp)
  80015b:	e8 9d ff ff ff       	call   8000fd <vcprintf>
	va_end(ap);

	return cnt;
}
  800160:	c9                   	leave  
  800161:	c3                   	ret    

00800162 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800162:	55                   	push   %ebp
  800163:	89 e5                	mov    %esp,%ebp
  800165:	57                   	push   %edi
  800166:	56                   	push   %esi
  800167:	53                   	push   %ebx
  800168:	83 ec 1c             	sub    $0x1c,%esp
  80016b:	89 c7                	mov    %eax,%edi
  80016d:	89 d6                	mov    %edx,%esi
  80016f:	8b 45 08             	mov    0x8(%ebp),%eax
  800172:	8b 55 0c             	mov    0xc(%ebp),%edx
  800175:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800178:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80017b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80017e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800183:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800186:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800189:	39 d3                	cmp    %edx,%ebx
  80018b:	72 05                	jb     800192 <printnum+0x30>
  80018d:	39 45 10             	cmp    %eax,0x10(%ebp)
  800190:	77 45                	ja     8001d7 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800192:	83 ec 0c             	sub    $0xc,%esp
  800195:	ff 75 18             	pushl  0x18(%ebp)
  800198:	8b 45 14             	mov    0x14(%ebp),%eax
  80019b:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80019e:	53                   	push   %ebx
  80019f:	ff 75 10             	pushl  0x10(%ebp)
  8001a2:	83 ec 08             	sub    $0x8,%esp
  8001a5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001a8:	ff 75 e0             	pushl  -0x20(%ebp)
  8001ab:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ae:	ff 75 d8             	pushl  -0x28(%ebp)
  8001b1:	e8 3a 0a 00 00       	call   800bf0 <__udivdi3>
  8001b6:	83 c4 18             	add    $0x18,%esp
  8001b9:	52                   	push   %edx
  8001ba:	50                   	push   %eax
  8001bb:	89 f2                	mov    %esi,%edx
  8001bd:	89 f8                	mov    %edi,%eax
  8001bf:	e8 9e ff ff ff       	call   800162 <printnum>
  8001c4:	83 c4 20             	add    $0x20,%esp
  8001c7:	eb 18                	jmp    8001e1 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001c9:	83 ec 08             	sub    $0x8,%esp
  8001cc:	56                   	push   %esi
  8001cd:	ff 75 18             	pushl  0x18(%ebp)
  8001d0:	ff d7                	call   *%edi
  8001d2:	83 c4 10             	add    $0x10,%esp
  8001d5:	eb 03                	jmp    8001da <printnum+0x78>
  8001d7:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001da:	83 eb 01             	sub    $0x1,%ebx
  8001dd:	85 db                	test   %ebx,%ebx
  8001df:	7f e8                	jg     8001c9 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001e1:	83 ec 08             	sub    $0x8,%esp
  8001e4:	56                   	push   %esi
  8001e5:	83 ec 04             	sub    $0x4,%esp
  8001e8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001eb:	ff 75 e0             	pushl  -0x20(%ebp)
  8001ee:	ff 75 dc             	pushl  -0x24(%ebp)
  8001f1:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f4:	e8 27 0b 00 00       	call   800d20 <__umoddi3>
  8001f9:	83 c4 14             	add    $0x14,%esp
  8001fc:	0f be 80 98 0e 80 00 	movsbl 0x800e98(%eax),%eax
  800203:	50                   	push   %eax
  800204:	ff d7                	call   *%edi
}
  800206:	83 c4 10             	add    $0x10,%esp
  800209:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80020c:	5b                   	pop    %ebx
  80020d:	5e                   	pop    %esi
  80020e:	5f                   	pop    %edi
  80020f:	5d                   	pop    %ebp
  800210:	c3                   	ret    

00800211 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800211:	55                   	push   %ebp
  800212:	89 e5                	mov    %esp,%ebp
  800214:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800217:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80021b:	8b 10                	mov    (%eax),%edx
  80021d:	3b 50 04             	cmp    0x4(%eax),%edx
  800220:	73 0a                	jae    80022c <sprintputch+0x1b>
		*b->buf++ = ch;
  800222:	8d 4a 01             	lea    0x1(%edx),%ecx
  800225:	89 08                	mov    %ecx,(%eax)
  800227:	8b 45 08             	mov    0x8(%ebp),%eax
  80022a:	88 02                	mov    %al,(%edx)
}
  80022c:	5d                   	pop    %ebp
  80022d:	c3                   	ret    

0080022e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80022e:	55                   	push   %ebp
  80022f:	89 e5                	mov    %esp,%ebp
  800231:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800234:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800237:	50                   	push   %eax
  800238:	ff 75 10             	pushl  0x10(%ebp)
  80023b:	ff 75 0c             	pushl  0xc(%ebp)
  80023e:	ff 75 08             	pushl  0x8(%ebp)
  800241:	e8 05 00 00 00       	call   80024b <vprintfmt>
	va_end(ap);
}
  800246:	83 c4 10             	add    $0x10,%esp
  800249:	c9                   	leave  
  80024a:	c3                   	ret    

0080024b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80024b:	55                   	push   %ebp
  80024c:	89 e5                	mov    %esp,%ebp
  80024e:	57                   	push   %edi
  80024f:	56                   	push   %esi
  800250:	53                   	push   %ebx
  800251:	83 ec 2c             	sub    $0x2c,%esp
  800254:	8b 75 08             	mov    0x8(%ebp),%esi
  800257:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80025a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80025d:	eb 12                	jmp    800271 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80025f:	85 c0                	test   %eax,%eax
  800261:	0f 84 a9 04 00 00    	je     800710 <vprintfmt+0x4c5>
				return;
			putch(ch, putdat);
  800267:	83 ec 08             	sub    $0x8,%esp
  80026a:	53                   	push   %ebx
  80026b:	50                   	push   %eax
  80026c:	ff d6                	call   *%esi
  80026e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800271:	83 c7 01             	add    $0x1,%edi
  800274:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800278:	83 f8 25             	cmp    $0x25,%eax
  80027b:	75 e2                	jne    80025f <vprintfmt+0x14>
  80027d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800281:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800288:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80028f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800296:	b9 00 00 00 00       	mov    $0x0,%ecx
  80029b:	eb 07                	jmp    8002a4 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80029d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002a0:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002a4:	8d 47 01             	lea    0x1(%edi),%eax
  8002a7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002aa:	0f b6 07             	movzbl (%edi),%eax
  8002ad:	0f b6 d0             	movzbl %al,%edx
  8002b0:	83 e8 23             	sub    $0x23,%eax
  8002b3:	3c 55                	cmp    $0x55,%al
  8002b5:	0f 87 3a 04 00 00    	ja     8006f5 <vprintfmt+0x4aa>
  8002bb:	0f b6 c0             	movzbl %al,%eax
  8002be:	ff 24 85 40 0f 80 00 	jmp    *0x800f40(,%eax,4)
  8002c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8002c8:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8002cc:	eb d6                	jmp    8002a4 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8002d6:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8002d9:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002dc:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8002e0:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8002e3:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8002e6:	83 f9 09             	cmp    $0x9,%ecx
  8002e9:	77 3f                	ja     80032a <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8002eb:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8002ee:	eb e9                	jmp    8002d9 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8002f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8002f3:	8b 00                	mov    (%eax),%eax
  8002f5:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8002fb:	8d 40 04             	lea    0x4(%eax),%eax
  8002fe:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800301:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800304:	eb 2a                	jmp    800330 <vprintfmt+0xe5>
  800306:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800309:	85 c0                	test   %eax,%eax
  80030b:	ba 00 00 00 00       	mov    $0x0,%edx
  800310:	0f 49 d0             	cmovns %eax,%edx
  800313:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800316:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800319:	eb 89                	jmp    8002a4 <vprintfmt+0x59>
  80031b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80031e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800325:	e9 7a ff ff ff       	jmp    8002a4 <vprintfmt+0x59>
  80032a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80032d:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800330:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800334:	0f 89 6a ff ff ff    	jns    8002a4 <vprintfmt+0x59>
				width = precision, precision = -1;
  80033a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80033d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800340:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800347:	e9 58 ff ff ff       	jmp    8002a4 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80034c:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80034f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800352:	e9 4d ff ff ff       	jmp    8002a4 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800357:	8b 45 14             	mov    0x14(%ebp),%eax
  80035a:	8d 78 04             	lea    0x4(%eax),%edi
  80035d:	83 ec 08             	sub    $0x8,%esp
  800360:	53                   	push   %ebx
  800361:	ff 30                	pushl  (%eax)
  800363:	ff d6                	call   *%esi
			break;
  800365:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800368:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80036e:	e9 fe fe ff ff       	jmp    800271 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800373:	8b 45 14             	mov    0x14(%ebp),%eax
  800376:	8d 78 04             	lea    0x4(%eax),%edi
  800379:	8b 00                	mov    (%eax),%eax
  80037b:	99                   	cltd   
  80037c:	31 d0                	xor    %edx,%eax
  80037e:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800380:	83 f8 07             	cmp    $0x7,%eax
  800383:	7f 0b                	jg     800390 <vprintfmt+0x145>
  800385:	8b 14 85 a0 10 80 00 	mov    0x8010a0(,%eax,4),%edx
  80038c:	85 d2                	test   %edx,%edx
  80038e:	75 1b                	jne    8003ab <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800390:	50                   	push   %eax
  800391:	68 b0 0e 80 00       	push   $0x800eb0
  800396:	53                   	push   %ebx
  800397:	56                   	push   %esi
  800398:	e8 91 fe ff ff       	call   80022e <printfmt>
  80039d:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003a0:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003a6:	e9 c6 fe ff ff       	jmp    800271 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003ab:	52                   	push   %edx
  8003ac:	68 b9 0e 80 00       	push   $0x800eb9
  8003b1:	53                   	push   %ebx
  8003b2:	56                   	push   %esi
  8003b3:	e8 76 fe ff ff       	call   80022e <printfmt>
  8003b8:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003bb:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003c1:	e9 ab fe ff ff       	jmp    800271 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c9:	83 c0 04             	add    $0x4,%eax
  8003cc:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8003cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d2:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8003d4:	85 ff                	test   %edi,%edi
  8003d6:	b8 a9 0e 80 00       	mov    $0x800ea9,%eax
  8003db:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8003de:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003e2:	0f 8e 94 00 00 00    	jle    80047c <vprintfmt+0x231>
  8003e8:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8003ec:	0f 84 98 00 00 00    	je     80048a <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003f2:	83 ec 08             	sub    $0x8,%esp
  8003f5:	ff 75 d0             	pushl  -0x30(%ebp)
  8003f8:	57                   	push   %edi
  8003f9:	e8 9a 03 00 00       	call   800798 <strnlen>
  8003fe:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800401:	29 c1                	sub    %eax,%ecx
  800403:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800406:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800409:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80040d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800410:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800413:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800415:	eb 0f                	jmp    800426 <vprintfmt+0x1db>
					putch(padc, putdat);
  800417:	83 ec 08             	sub    $0x8,%esp
  80041a:	53                   	push   %ebx
  80041b:	ff 75 e0             	pushl  -0x20(%ebp)
  80041e:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800420:	83 ef 01             	sub    $0x1,%edi
  800423:	83 c4 10             	add    $0x10,%esp
  800426:	85 ff                	test   %edi,%edi
  800428:	7f ed                	jg     800417 <vprintfmt+0x1cc>
  80042a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80042d:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800430:	85 c9                	test   %ecx,%ecx
  800432:	b8 00 00 00 00       	mov    $0x0,%eax
  800437:	0f 49 c1             	cmovns %ecx,%eax
  80043a:	29 c1                	sub    %eax,%ecx
  80043c:	89 75 08             	mov    %esi,0x8(%ebp)
  80043f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800442:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800445:	89 cb                	mov    %ecx,%ebx
  800447:	eb 4d                	jmp    800496 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800449:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80044d:	74 1b                	je     80046a <vprintfmt+0x21f>
  80044f:	0f be c0             	movsbl %al,%eax
  800452:	83 e8 20             	sub    $0x20,%eax
  800455:	83 f8 5e             	cmp    $0x5e,%eax
  800458:	76 10                	jbe    80046a <vprintfmt+0x21f>
					putch('?', putdat);
  80045a:	83 ec 08             	sub    $0x8,%esp
  80045d:	ff 75 0c             	pushl  0xc(%ebp)
  800460:	6a 3f                	push   $0x3f
  800462:	ff 55 08             	call   *0x8(%ebp)
  800465:	83 c4 10             	add    $0x10,%esp
  800468:	eb 0d                	jmp    800477 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  80046a:	83 ec 08             	sub    $0x8,%esp
  80046d:	ff 75 0c             	pushl  0xc(%ebp)
  800470:	52                   	push   %edx
  800471:	ff 55 08             	call   *0x8(%ebp)
  800474:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800477:	83 eb 01             	sub    $0x1,%ebx
  80047a:	eb 1a                	jmp    800496 <vprintfmt+0x24b>
  80047c:	89 75 08             	mov    %esi,0x8(%ebp)
  80047f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800482:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800485:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800488:	eb 0c                	jmp    800496 <vprintfmt+0x24b>
  80048a:	89 75 08             	mov    %esi,0x8(%ebp)
  80048d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800490:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800493:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800496:	83 c7 01             	add    $0x1,%edi
  800499:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80049d:	0f be d0             	movsbl %al,%edx
  8004a0:	85 d2                	test   %edx,%edx
  8004a2:	74 23                	je     8004c7 <vprintfmt+0x27c>
  8004a4:	85 f6                	test   %esi,%esi
  8004a6:	78 a1                	js     800449 <vprintfmt+0x1fe>
  8004a8:	83 ee 01             	sub    $0x1,%esi
  8004ab:	79 9c                	jns    800449 <vprintfmt+0x1fe>
  8004ad:	89 df                	mov    %ebx,%edi
  8004af:	8b 75 08             	mov    0x8(%ebp),%esi
  8004b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004b5:	eb 18                	jmp    8004cf <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004b7:	83 ec 08             	sub    $0x8,%esp
  8004ba:	53                   	push   %ebx
  8004bb:	6a 20                	push   $0x20
  8004bd:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004bf:	83 ef 01             	sub    $0x1,%edi
  8004c2:	83 c4 10             	add    $0x10,%esp
  8004c5:	eb 08                	jmp    8004cf <vprintfmt+0x284>
  8004c7:	89 df                	mov    %ebx,%edi
  8004c9:	8b 75 08             	mov    0x8(%ebp),%esi
  8004cc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004cf:	85 ff                	test   %edi,%edi
  8004d1:	7f e4                	jg     8004b7 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004d3:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004d6:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004dc:	e9 90 fd ff ff       	jmp    800271 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8004e1:	83 f9 01             	cmp    $0x1,%ecx
  8004e4:	7e 19                	jle    8004ff <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  8004e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e9:	8b 50 04             	mov    0x4(%eax),%edx
  8004ec:	8b 00                	mov    (%eax),%eax
  8004ee:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004f1:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f7:	8d 40 08             	lea    0x8(%eax),%eax
  8004fa:	89 45 14             	mov    %eax,0x14(%ebp)
  8004fd:	eb 38                	jmp    800537 <vprintfmt+0x2ec>
	else if (lflag)
  8004ff:	85 c9                	test   %ecx,%ecx
  800501:	74 1b                	je     80051e <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  800503:	8b 45 14             	mov    0x14(%ebp),%eax
  800506:	8b 00                	mov    (%eax),%eax
  800508:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80050b:	89 c1                	mov    %eax,%ecx
  80050d:	c1 f9 1f             	sar    $0x1f,%ecx
  800510:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800513:	8b 45 14             	mov    0x14(%ebp),%eax
  800516:	8d 40 04             	lea    0x4(%eax),%eax
  800519:	89 45 14             	mov    %eax,0x14(%ebp)
  80051c:	eb 19                	jmp    800537 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  80051e:	8b 45 14             	mov    0x14(%ebp),%eax
  800521:	8b 00                	mov    (%eax),%eax
  800523:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800526:	89 c1                	mov    %eax,%ecx
  800528:	c1 f9 1f             	sar    $0x1f,%ecx
  80052b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80052e:	8b 45 14             	mov    0x14(%ebp),%eax
  800531:	8d 40 04             	lea    0x4(%eax),%eax
  800534:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800537:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80053a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80053d:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800542:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800546:	0f 89 75 01 00 00    	jns    8006c1 <vprintfmt+0x476>
				putch('-', putdat);
  80054c:	83 ec 08             	sub    $0x8,%esp
  80054f:	53                   	push   %ebx
  800550:	6a 2d                	push   $0x2d
  800552:	ff d6                	call   *%esi
				num = -(long long) num;
  800554:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800557:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80055a:	f7 da                	neg    %edx
  80055c:	83 d1 00             	adc    $0x0,%ecx
  80055f:	f7 d9                	neg    %ecx
  800561:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800564:	b8 0a 00 00 00       	mov    $0xa,%eax
  800569:	e9 53 01 00 00       	jmp    8006c1 <vprintfmt+0x476>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80056e:	83 f9 01             	cmp    $0x1,%ecx
  800571:	7e 18                	jle    80058b <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800573:	8b 45 14             	mov    0x14(%ebp),%eax
  800576:	8b 10                	mov    (%eax),%edx
  800578:	8b 48 04             	mov    0x4(%eax),%ecx
  80057b:	8d 40 08             	lea    0x8(%eax),%eax
  80057e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800581:	b8 0a 00 00 00       	mov    $0xa,%eax
  800586:	e9 36 01 00 00       	jmp    8006c1 <vprintfmt+0x476>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80058b:	85 c9                	test   %ecx,%ecx
  80058d:	74 1a                	je     8005a9 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  80058f:	8b 45 14             	mov    0x14(%ebp),%eax
  800592:	8b 10                	mov    (%eax),%edx
  800594:	b9 00 00 00 00       	mov    $0x0,%ecx
  800599:	8d 40 04             	lea    0x4(%eax),%eax
  80059c:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80059f:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005a4:	e9 18 01 00 00       	jmp    8006c1 <vprintfmt+0x476>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8005a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ac:	8b 10                	mov    (%eax),%edx
  8005ae:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005b3:	8d 40 04             	lea    0x4(%eax),%eax
  8005b6:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005b9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005be:	e9 fe 00 00 00       	jmp    8006c1 <vprintfmt+0x476>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005c3:	83 f9 01             	cmp    $0x1,%ecx
  8005c6:	7e 19                	jle    8005e1 <vprintfmt+0x396>
		return va_arg(*ap, long long);
  8005c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cb:	8b 50 04             	mov    0x4(%eax),%edx
  8005ce:	8b 00                	mov    (%eax),%eax
  8005d0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d3:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d9:	8d 40 08             	lea    0x8(%eax),%eax
  8005dc:	89 45 14             	mov    %eax,0x14(%ebp)
  8005df:	eb 38                	jmp    800619 <vprintfmt+0x3ce>
	else if (lflag)
  8005e1:	85 c9                	test   %ecx,%ecx
  8005e3:	74 1b                	je     800600 <vprintfmt+0x3b5>
		return va_arg(*ap, long);
  8005e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e8:	8b 00                	mov    (%eax),%eax
  8005ea:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ed:	89 c1                	mov    %eax,%ecx
  8005ef:	c1 f9 1f             	sar    $0x1f,%ecx
  8005f2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f8:	8d 40 04             	lea    0x4(%eax),%eax
  8005fb:	89 45 14             	mov    %eax,0x14(%ebp)
  8005fe:	eb 19                	jmp    800619 <vprintfmt+0x3ce>
	else
		return va_arg(*ap, int);
  800600:	8b 45 14             	mov    0x14(%ebp),%eax
  800603:	8b 00                	mov    (%eax),%eax
  800605:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800608:	89 c1                	mov    %eax,%ecx
  80060a:	c1 f9 1f             	sar    $0x1f,%ecx
  80060d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800610:	8b 45 14             	mov    0x14(%ebp),%eax
  800613:	8d 40 04             	lea    0x4(%eax),%eax
  800616:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
			goto number;

		// (unsigned) octal
		case 'o':
			num = getint(&ap, lflag);
  800619:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80061c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 8;
  80061f:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;

		// (unsigned) octal
		case 'o':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800624:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800628:	0f 89 93 00 00 00    	jns    8006c1 <vprintfmt+0x476>
				putch('-', putdat);
  80062e:	83 ec 08             	sub    $0x8,%esp
  800631:	53                   	push   %ebx
  800632:	6a 2d                	push   $0x2d
  800634:	ff d6                	call   *%esi
				num = -(long long) num;
  800636:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800639:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80063c:	f7 da                	neg    %edx
  80063e:	83 d1 00             	adc    $0x0,%ecx
  800641:	f7 d9                	neg    %ecx
  800643:	83 c4 10             	add    $0x10,%esp
			}
			base = 8;
  800646:	b8 08 00 00 00       	mov    $0x8,%eax
  80064b:	eb 74                	jmp    8006c1 <vprintfmt+0x476>
			goto number;

		// pointer
		case 'p':
			putch('0', putdat);
  80064d:	83 ec 08             	sub    $0x8,%esp
  800650:	53                   	push   %ebx
  800651:	6a 30                	push   $0x30
  800653:	ff d6                	call   *%esi
			putch('x', putdat);
  800655:	83 c4 08             	add    $0x8,%esp
  800658:	53                   	push   %ebx
  800659:	6a 78                	push   $0x78
  80065b:	ff d6                	call   *%esi
			num = (unsigned long long)
  80065d:	8b 45 14             	mov    0x14(%ebp),%eax
  800660:	8b 10                	mov    (%eax),%edx
  800662:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800667:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80066a:	8d 40 04             	lea    0x4(%eax),%eax
  80066d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800670:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800675:	eb 4a                	jmp    8006c1 <vprintfmt+0x476>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800677:	83 f9 01             	cmp    $0x1,%ecx
  80067a:	7e 15                	jle    800691 <vprintfmt+0x446>
		return va_arg(*ap, unsigned long long);
  80067c:	8b 45 14             	mov    0x14(%ebp),%eax
  80067f:	8b 10                	mov    (%eax),%edx
  800681:	8b 48 04             	mov    0x4(%eax),%ecx
  800684:	8d 40 08             	lea    0x8(%eax),%eax
  800687:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80068a:	b8 10 00 00 00       	mov    $0x10,%eax
  80068f:	eb 30                	jmp    8006c1 <vprintfmt+0x476>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800691:	85 c9                	test   %ecx,%ecx
  800693:	74 17                	je     8006ac <vprintfmt+0x461>
		return va_arg(*ap, unsigned long);
  800695:	8b 45 14             	mov    0x14(%ebp),%eax
  800698:	8b 10                	mov    (%eax),%edx
  80069a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80069f:	8d 40 04             	lea    0x4(%eax),%eax
  8006a2:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006a5:	b8 10 00 00 00       	mov    $0x10,%eax
  8006aa:	eb 15                	jmp    8006c1 <vprintfmt+0x476>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8006ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8006af:	8b 10                	mov    (%eax),%edx
  8006b1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006b6:	8d 40 04             	lea    0x4(%eax),%eax
  8006b9:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006bc:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006c1:	83 ec 0c             	sub    $0xc,%esp
  8006c4:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006c8:	57                   	push   %edi
  8006c9:	ff 75 e0             	pushl  -0x20(%ebp)
  8006cc:	50                   	push   %eax
  8006cd:	51                   	push   %ecx
  8006ce:	52                   	push   %edx
  8006cf:	89 da                	mov    %ebx,%edx
  8006d1:	89 f0                	mov    %esi,%eax
  8006d3:	e8 8a fa ff ff       	call   800162 <printnum>
			break;
  8006d8:	83 c4 20             	add    $0x20,%esp
  8006db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006de:	e9 8e fb ff ff       	jmp    800271 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006e3:	83 ec 08             	sub    $0x8,%esp
  8006e6:	53                   	push   %ebx
  8006e7:	52                   	push   %edx
  8006e8:	ff d6                	call   *%esi
			break;
  8006ea:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006f0:	e9 7c fb ff ff       	jmp    800271 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006f5:	83 ec 08             	sub    $0x8,%esp
  8006f8:	53                   	push   %ebx
  8006f9:	6a 25                	push   $0x25
  8006fb:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006fd:	83 c4 10             	add    $0x10,%esp
  800700:	eb 03                	jmp    800705 <vprintfmt+0x4ba>
  800702:	83 ef 01             	sub    $0x1,%edi
  800705:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800709:	75 f7                	jne    800702 <vprintfmt+0x4b7>
  80070b:	e9 61 fb ff ff       	jmp    800271 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800710:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800713:	5b                   	pop    %ebx
  800714:	5e                   	pop    %esi
  800715:	5f                   	pop    %edi
  800716:	5d                   	pop    %ebp
  800717:	c3                   	ret    

00800718 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800718:	55                   	push   %ebp
  800719:	89 e5                	mov    %esp,%ebp
  80071b:	83 ec 18             	sub    $0x18,%esp
  80071e:	8b 45 08             	mov    0x8(%ebp),%eax
  800721:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800724:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800727:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80072b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80072e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800735:	85 c0                	test   %eax,%eax
  800737:	74 26                	je     80075f <vsnprintf+0x47>
  800739:	85 d2                	test   %edx,%edx
  80073b:	7e 22                	jle    80075f <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80073d:	ff 75 14             	pushl  0x14(%ebp)
  800740:	ff 75 10             	pushl  0x10(%ebp)
  800743:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800746:	50                   	push   %eax
  800747:	68 11 02 80 00       	push   $0x800211
  80074c:	e8 fa fa ff ff       	call   80024b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800751:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800754:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800757:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80075a:	83 c4 10             	add    $0x10,%esp
  80075d:	eb 05                	jmp    800764 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80075f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800764:	c9                   	leave  
  800765:	c3                   	ret    

00800766 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800766:	55                   	push   %ebp
  800767:	89 e5                	mov    %esp,%ebp
  800769:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80076c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80076f:	50                   	push   %eax
  800770:	ff 75 10             	pushl  0x10(%ebp)
  800773:	ff 75 0c             	pushl  0xc(%ebp)
  800776:	ff 75 08             	pushl  0x8(%ebp)
  800779:	e8 9a ff ff ff       	call   800718 <vsnprintf>
	va_end(ap);

	return rc;
}
  80077e:	c9                   	leave  
  80077f:	c3                   	ret    

00800780 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800780:	55                   	push   %ebp
  800781:	89 e5                	mov    %esp,%ebp
  800783:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800786:	b8 00 00 00 00       	mov    $0x0,%eax
  80078b:	eb 03                	jmp    800790 <strlen+0x10>
		n++;
  80078d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800790:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800794:	75 f7                	jne    80078d <strlen+0xd>
		n++;
	return n;
}
  800796:	5d                   	pop    %ebp
  800797:	c3                   	ret    

00800798 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800798:	55                   	push   %ebp
  800799:	89 e5                	mov    %esp,%ebp
  80079b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80079e:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8007a6:	eb 03                	jmp    8007ab <strnlen+0x13>
		n++;
  8007a8:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ab:	39 c2                	cmp    %eax,%edx
  8007ad:	74 08                	je     8007b7 <strnlen+0x1f>
  8007af:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007b3:	75 f3                	jne    8007a8 <strnlen+0x10>
  8007b5:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007b7:	5d                   	pop    %ebp
  8007b8:	c3                   	ret    

008007b9 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007b9:	55                   	push   %ebp
  8007ba:	89 e5                	mov    %esp,%ebp
  8007bc:	53                   	push   %ebx
  8007bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007c3:	89 c2                	mov    %eax,%edx
  8007c5:	83 c2 01             	add    $0x1,%edx
  8007c8:	83 c1 01             	add    $0x1,%ecx
  8007cb:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007cf:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007d2:	84 db                	test   %bl,%bl
  8007d4:	75 ef                	jne    8007c5 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007d6:	5b                   	pop    %ebx
  8007d7:	5d                   	pop    %ebp
  8007d8:	c3                   	ret    

008007d9 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007d9:	55                   	push   %ebp
  8007da:	89 e5                	mov    %esp,%ebp
  8007dc:	53                   	push   %ebx
  8007dd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007e0:	53                   	push   %ebx
  8007e1:	e8 9a ff ff ff       	call   800780 <strlen>
  8007e6:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007e9:	ff 75 0c             	pushl  0xc(%ebp)
  8007ec:	01 d8                	add    %ebx,%eax
  8007ee:	50                   	push   %eax
  8007ef:	e8 c5 ff ff ff       	call   8007b9 <strcpy>
	return dst;
}
  8007f4:	89 d8                	mov    %ebx,%eax
  8007f6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007f9:	c9                   	leave  
  8007fa:	c3                   	ret    

008007fb <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007fb:	55                   	push   %ebp
  8007fc:	89 e5                	mov    %esp,%ebp
  8007fe:	56                   	push   %esi
  8007ff:	53                   	push   %ebx
  800800:	8b 75 08             	mov    0x8(%ebp),%esi
  800803:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800806:	89 f3                	mov    %esi,%ebx
  800808:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80080b:	89 f2                	mov    %esi,%edx
  80080d:	eb 0f                	jmp    80081e <strncpy+0x23>
		*dst++ = *src;
  80080f:	83 c2 01             	add    $0x1,%edx
  800812:	0f b6 01             	movzbl (%ecx),%eax
  800815:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800818:	80 39 01             	cmpb   $0x1,(%ecx)
  80081b:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80081e:	39 da                	cmp    %ebx,%edx
  800820:	75 ed                	jne    80080f <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800822:	89 f0                	mov    %esi,%eax
  800824:	5b                   	pop    %ebx
  800825:	5e                   	pop    %esi
  800826:	5d                   	pop    %ebp
  800827:	c3                   	ret    

00800828 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800828:	55                   	push   %ebp
  800829:	89 e5                	mov    %esp,%ebp
  80082b:	56                   	push   %esi
  80082c:	53                   	push   %ebx
  80082d:	8b 75 08             	mov    0x8(%ebp),%esi
  800830:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800833:	8b 55 10             	mov    0x10(%ebp),%edx
  800836:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800838:	85 d2                	test   %edx,%edx
  80083a:	74 21                	je     80085d <strlcpy+0x35>
  80083c:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800840:	89 f2                	mov    %esi,%edx
  800842:	eb 09                	jmp    80084d <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800844:	83 c2 01             	add    $0x1,%edx
  800847:	83 c1 01             	add    $0x1,%ecx
  80084a:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80084d:	39 c2                	cmp    %eax,%edx
  80084f:	74 09                	je     80085a <strlcpy+0x32>
  800851:	0f b6 19             	movzbl (%ecx),%ebx
  800854:	84 db                	test   %bl,%bl
  800856:	75 ec                	jne    800844 <strlcpy+0x1c>
  800858:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80085a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80085d:	29 f0                	sub    %esi,%eax
}
  80085f:	5b                   	pop    %ebx
  800860:	5e                   	pop    %esi
  800861:	5d                   	pop    %ebp
  800862:	c3                   	ret    

00800863 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800863:	55                   	push   %ebp
  800864:	89 e5                	mov    %esp,%ebp
  800866:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800869:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80086c:	eb 06                	jmp    800874 <strcmp+0x11>
		p++, q++;
  80086e:	83 c1 01             	add    $0x1,%ecx
  800871:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800874:	0f b6 01             	movzbl (%ecx),%eax
  800877:	84 c0                	test   %al,%al
  800879:	74 04                	je     80087f <strcmp+0x1c>
  80087b:	3a 02                	cmp    (%edx),%al
  80087d:	74 ef                	je     80086e <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80087f:	0f b6 c0             	movzbl %al,%eax
  800882:	0f b6 12             	movzbl (%edx),%edx
  800885:	29 d0                	sub    %edx,%eax
}
  800887:	5d                   	pop    %ebp
  800888:	c3                   	ret    

00800889 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800889:	55                   	push   %ebp
  80088a:	89 e5                	mov    %esp,%ebp
  80088c:	53                   	push   %ebx
  80088d:	8b 45 08             	mov    0x8(%ebp),%eax
  800890:	8b 55 0c             	mov    0xc(%ebp),%edx
  800893:	89 c3                	mov    %eax,%ebx
  800895:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800898:	eb 06                	jmp    8008a0 <strncmp+0x17>
		n--, p++, q++;
  80089a:	83 c0 01             	add    $0x1,%eax
  80089d:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008a0:	39 d8                	cmp    %ebx,%eax
  8008a2:	74 15                	je     8008b9 <strncmp+0x30>
  8008a4:	0f b6 08             	movzbl (%eax),%ecx
  8008a7:	84 c9                	test   %cl,%cl
  8008a9:	74 04                	je     8008af <strncmp+0x26>
  8008ab:	3a 0a                	cmp    (%edx),%cl
  8008ad:	74 eb                	je     80089a <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008af:	0f b6 00             	movzbl (%eax),%eax
  8008b2:	0f b6 12             	movzbl (%edx),%edx
  8008b5:	29 d0                	sub    %edx,%eax
  8008b7:	eb 05                	jmp    8008be <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008b9:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008be:	5b                   	pop    %ebx
  8008bf:	5d                   	pop    %ebp
  8008c0:	c3                   	ret    

008008c1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008c1:	55                   	push   %ebp
  8008c2:	89 e5                	mov    %esp,%ebp
  8008c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008cb:	eb 07                	jmp    8008d4 <strchr+0x13>
		if (*s == c)
  8008cd:	38 ca                	cmp    %cl,%dl
  8008cf:	74 0f                	je     8008e0 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008d1:	83 c0 01             	add    $0x1,%eax
  8008d4:	0f b6 10             	movzbl (%eax),%edx
  8008d7:	84 d2                	test   %dl,%dl
  8008d9:	75 f2                	jne    8008cd <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008db:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008e0:	5d                   	pop    %ebp
  8008e1:	c3                   	ret    

008008e2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008e2:	55                   	push   %ebp
  8008e3:	89 e5                	mov    %esp,%ebp
  8008e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ec:	eb 03                	jmp    8008f1 <strfind+0xf>
  8008ee:	83 c0 01             	add    $0x1,%eax
  8008f1:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008f4:	38 ca                	cmp    %cl,%dl
  8008f6:	74 04                	je     8008fc <strfind+0x1a>
  8008f8:	84 d2                	test   %dl,%dl
  8008fa:	75 f2                	jne    8008ee <strfind+0xc>
			break;
	return (char *) s;
}
  8008fc:	5d                   	pop    %ebp
  8008fd:	c3                   	ret    

008008fe <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008fe:	55                   	push   %ebp
  8008ff:	89 e5                	mov    %esp,%ebp
  800901:	57                   	push   %edi
  800902:	56                   	push   %esi
  800903:	53                   	push   %ebx
  800904:	8b 7d 08             	mov    0x8(%ebp),%edi
  800907:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80090a:	85 c9                	test   %ecx,%ecx
  80090c:	74 36                	je     800944 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80090e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800914:	75 28                	jne    80093e <memset+0x40>
  800916:	f6 c1 03             	test   $0x3,%cl
  800919:	75 23                	jne    80093e <memset+0x40>
		c &= 0xFF;
  80091b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80091f:	89 d3                	mov    %edx,%ebx
  800921:	c1 e3 08             	shl    $0x8,%ebx
  800924:	89 d6                	mov    %edx,%esi
  800926:	c1 e6 18             	shl    $0x18,%esi
  800929:	89 d0                	mov    %edx,%eax
  80092b:	c1 e0 10             	shl    $0x10,%eax
  80092e:	09 f0                	or     %esi,%eax
  800930:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800932:	89 d8                	mov    %ebx,%eax
  800934:	09 d0                	or     %edx,%eax
  800936:	c1 e9 02             	shr    $0x2,%ecx
  800939:	fc                   	cld    
  80093a:	f3 ab                	rep stos %eax,%es:(%edi)
  80093c:	eb 06                	jmp    800944 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80093e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800941:	fc                   	cld    
  800942:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800944:	89 f8                	mov    %edi,%eax
  800946:	5b                   	pop    %ebx
  800947:	5e                   	pop    %esi
  800948:	5f                   	pop    %edi
  800949:	5d                   	pop    %ebp
  80094a:	c3                   	ret    

0080094b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80094b:	55                   	push   %ebp
  80094c:	89 e5                	mov    %esp,%ebp
  80094e:	57                   	push   %edi
  80094f:	56                   	push   %esi
  800950:	8b 45 08             	mov    0x8(%ebp),%eax
  800953:	8b 75 0c             	mov    0xc(%ebp),%esi
  800956:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800959:	39 c6                	cmp    %eax,%esi
  80095b:	73 35                	jae    800992 <memmove+0x47>
  80095d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800960:	39 d0                	cmp    %edx,%eax
  800962:	73 2e                	jae    800992 <memmove+0x47>
		s += n;
		d += n;
  800964:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800967:	89 d6                	mov    %edx,%esi
  800969:	09 fe                	or     %edi,%esi
  80096b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800971:	75 13                	jne    800986 <memmove+0x3b>
  800973:	f6 c1 03             	test   $0x3,%cl
  800976:	75 0e                	jne    800986 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800978:	83 ef 04             	sub    $0x4,%edi
  80097b:	8d 72 fc             	lea    -0x4(%edx),%esi
  80097e:	c1 e9 02             	shr    $0x2,%ecx
  800981:	fd                   	std    
  800982:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800984:	eb 09                	jmp    80098f <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800986:	83 ef 01             	sub    $0x1,%edi
  800989:	8d 72 ff             	lea    -0x1(%edx),%esi
  80098c:	fd                   	std    
  80098d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80098f:	fc                   	cld    
  800990:	eb 1d                	jmp    8009af <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800992:	89 f2                	mov    %esi,%edx
  800994:	09 c2                	or     %eax,%edx
  800996:	f6 c2 03             	test   $0x3,%dl
  800999:	75 0f                	jne    8009aa <memmove+0x5f>
  80099b:	f6 c1 03             	test   $0x3,%cl
  80099e:	75 0a                	jne    8009aa <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009a0:	c1 e9 02             	shr    $0x2,%ecx
  8009a3:	89 c7                	mov    %eax,%edi
  8009a5:	fc                   	cld    
  8009a6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a8:	eb 05                	jmp    8009af <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009aa:	89 c7                	mov    %eax,%edi
  8009ac:	fc                   	cld    
  8009ad:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009af:	5e                   	pop    %esi
  8009b0:	5f                   	pop    %edi
  8009b1:	5d                   	pop    %ebp
  8009b2:	c3                   	ret    

008009b3 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009b3:	55                   	push   %ebp
  8009b4:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009b6:	ff 75 10             	pushl  0x10(%ebp)
  8009b9:	ff 75 0c             	pushl  0xc(%ebp)
  8009bc:	ff 75 08             	pushl  0x8(%ebp)
  8009bf:	e8 87 ff ff ff       	call   80094b <memmove>
}
  8009c4:	c9                   	leave  
  8009c5:	c3                   	ret    

008009c6 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009c6:	55                   	push   %ebp
  8009c7:	89 e5                	mov    %esp,%ebp
  8009c9:	56                   	push   %esi
  8009ca:	53                   	push   %ebx
  8009cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ce:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009d1:	89 c6                	mov    %eax,%esi
  8009d3:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009d6:	eb 1a                	jmp    8009f2 <memcmp+0x2c>
		if (*s1 != *s2)
  8009d8:	0f b6 08             	movzbl (%eax),%ecx
  8009db:	0f b6 1a             	movzbl (%edx),%ebx
  8009de:	38 d9                	cmp    %bl,%cl
  8009e0:	74 0a                	je     8009ec <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009e2:	0f b6 c1             	movzbl %cl,%eax
  8009e5:	0f b6 db             	movzbl %bl,%ebx
  8009e8:	29 d8                	sub    %ebx,%eax
  8009ea:	eb 0f                	jmp    8009fb <memcmp+0x35>
		s1++, s2++;
  8009ec:	83 c0 01             	add    $0x1,%eax
  8009ef:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f2:	39 f0                	cmp    %esi,%eax
  8009f4:	75 e2                	jne    8009d8 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009f6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009fb:	5b                   	pop    %ebx
  8009fc:	5e                   	pop    %esi
  8009fd:	5d                   	pop    %ebp
  8009fe:	c3                   	ret    

008009ff <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009ff:	55                   	push   %ebp
  800a00:	89 e5                	mov    %esp,%ebp
  800a02:	53                   	push   %ebx
  800a03:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a06:	89 c1                	mov    %eax,%ecx
  800a08:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a0b:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a0f:	eb 0a                	jmp    800a1b <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a11:	0f b6 10             	movzbl (%eax),%edx
  800a14:	39 da                	cmp    %ebx,%edx
  800a16:	74 07                	je     800a1f <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a18:	83 c0 01             	add    $0x1,%eax
  800a1b:	39 c8                	cmp    %ecx,%eax
  800a1d:	72 f2                	jb     800a11 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a1f:	5b                   	pop    %ebx
  800a20:	5d                   	pop    %ebp
  800a21:	c3                   	ret    

00800a22 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a22:	55                   	push   %ebp
  800a23:	89 e5                	mov    %esp,%ebp
  800a25:	57                   	push   %edi
  800a26:	56                   	push   %esi
  800a27:	53                   	push   %ebx
  800a28:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a2b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a2e:	eb 03                	jmp    800a33 <strtol+0x11>
		s++;
  800a30:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a33:	0f b6 01             	movzbl (%ecx),%eax
  800a36:	3c 20                	cmp    $0x20,%al
  800a38:	74 f6                	je     800a30 <strtol+0xe>
  800a3a:	3c 09                	cmp    $0x9,%al
  800a3c:	74 f2                	je     800a30 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a3e:	3c 2b                	cmp    $0x2b,%al
  800a40:	75 0a                	jne    800a4c <strtol+0x2a>
		s++;
  800a42:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a45:	bf 00 00 00 00       	mov    $0x0,%edi
  800a4a:	eb 11                	jmp    800a5d <strtol+0x3b>
  800a4c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a51:	3c 2d                	cmp    $0x2d,%al
  800a53:	75 08                	jne    800a5d <strtol+0x3b>
		s++, neg = 1;
  800a55:	83 c1 01             	add    $0x1,%ecx
  800a58:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a5d:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a63:	75 15                	jne    800a7a <strtol+0x58>
  800a65:	80 39 30             	cmpb   $0x30,(%ecx)
  800a68:	75 10                	jne    800a7a <strtol+0x58>
  800a6a:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a6e:	75 7c                	jne    800aec <strtol+0xca>
		s += 2, base = 16;
  800a70:	83 c1 02             	add    $0x2,%ecx
  800a73:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a78:	eb 16                	jmp    800a90 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a7a:	85 db                	test   %ebx,%ebx
  800a7c:	75 12                	jne    800a90 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a7e:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a83:	80 39 30             	cmpb   $0x30,(%ecx)
  800a86:	75 08                	jne    800a90 <strtol+0x6e>
		s++, base = 8;
  800a88:	83 c1 01             	add    $0x1,%ecx
  800a8b:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a90:	b8 00 00 00 00       	mov    $0x0,%eax
  800a95:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a98:	0f b6 11             	movzbl (%ecx),%edx
  800a9b:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a9e:	89 f3                	mov    %esi,%ebx
  800aa0:	80 fb 09             	cmp    $0x9,%bl
  800aa3:	77 08                	ja     800aad <strtol+0x8b>
			dig = *s - '0';
  800aa5:	0f be d2             	movsbl %dl,%edx
  800aa8:	83 ea 30             	sub    $0x30,%edx
  800aab:	eb 22                	jmp    800acf <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800aad:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ab0:	89 f3                	mov    %esi,%ebx
  800ab2:	80 fb 19             	cmp    $0x19,%bl
  800ab5:	77 08                	ja     800abf <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ab7:	0f be d2             	movsbl %dl,%edx
  800aba:	83 ea 57             	sub    $0x57,%edx
  800abd:	eb 10                	jmp    800acf <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800abf:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ac2:	89 f3                	mov    %esi,%ebx
  800ac4:	80 fb 19             	cmp    $0x19,%bl
  800ac7:	77 16                	ja     800adf <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ac9:	0f be d2             	movsbl %dl,%edx
  800acc:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800acf:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ad2:	7d 0b                	jge    800adf <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ad4:	83 c1 01             	add    $0x1,%ecx
  800ad7:	0f af 45 10          	imul   0x10(%ebp),%eax
  800adb:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800add:	eb b9                	jmp    800a98 <strtol+0x76>

	if (endptr)
  800adf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ae3:	74 0d                	je     800af2 <strtol+0xd0>
		*endptr = (char *) s;
  800ae5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ae8:	89 0e                	mov    %ecx,(%esi)
  800aea:	eb 06                	jmp    800af2 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aec:	85 db                	test   %ebx,%ebx
  800aee:	74 98                	je     800a88 <strtol+0x66>
  800af0:	eb 9e                	jmp    800a90 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800af2:	89 c2                	mov    %eax,%edx
  800af4:	f7 da                	neg    %edx
  800af6:	85 ff                	test   %edi,%edi
  800af8:	0f 45 c2             	cmovne %edx,%eax
}
  800afb:	5b                   	pop    %ebx
  800afc:	5e                   	pop    %esi
  800afd:	5f                   	pop    %edi
  800afe:	5d                   	pop    %ebp
  800aff:	c3                   	ret    

00800b00 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b00:	55                   	push   %ebp
  800b01:	89 e5                	mov    %esp,%ebp
  800b03:	57                   	push   %edi
  800b04:	56                   	push   %esi
  800b05:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b06:	b8 00 00 00 00       	mov    $0x0,%eax
  800b0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b0e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b11:	89 c3                	mov    %eax,%ebx
  800b13:	89 c7                	mov    %eax,%edi
  800b15:	89 c6                	mov    %eax,%esi
  800b17:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b19:	5b                   	pop    %ebx
  800b1a:	5e                   	pop    %esi
  800b1b:	5f                   	pop    %edi
  800b1c:	5d                   	pop    %ebp
  800b1d:	c3                   	ret    

00800b1e <sys_cgetc>:

int
sys_cgetc(void)
{
  800b1e:	55                   	push   %ebp
  800b1f:	89 e5                	mov    %esp,%ebp
  800b21:	57                   	push   %edi
  800b22:	56                   	push   %esi
  800b23:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b24:	ba 00 00 00 00       	mov    $0x0,%edx
  800b29:	b8 01 00 00 00       	mov    $0x1,%eax
  800b2e:	89 d1                	mov    %edx,%ecx
  800b30:	89 d3                	mov    %edx,%ebx
  800b32:	89 d7                	mov    %edx,%edi
  800b34:	89 d6                	mov    %edx,%esi
  800b36:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b38:	5b                   	pop    %ebx
  800b39:	5e                   	pop    %esi
  800b3a:	5f                   	pop    %edi
  800b3b:	5d                   	pop    %ebp
  800b3c:	c3                   	ret    

00800b3d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b3d:	55                   	push   %ebp
  800b3e:	89 e5                	mov    %esp,%ebp
  800b40:	57                   	push   %edi
  800b41:	56                   	push   %esi
  800b42:	53                   	push   %ebx
  800b43:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b46:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b4b:	b8 03 00 00 00       	mov    $0x3,%eax
  800b50:	8b 55 08             	mov    0x8(%ebp),%edx
  800b53:	89 cb                	mov    %ecx,%ebx
  800b55:	89 cf                	mov    %ecx,%edi
  800b57:	89 ce                	mov    %ecx,%esi
  800b59:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b5b:	85 c0                	test   %eax,%eax
  800b5d:	7e 17                	jle    800b76 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b5f:	83 ec 0c             	sub    $0xc,%esp
  800b62:	50                   	push   %eax
  800b63:	6a 03                	push   $0x3
  800b65:	68 c0 10 80 00       	push   $0x8010c0
  800b6a:	6a 23                	push   $0x23
  800b6c:	68 dd 10 80 00       	push   $0x8010dd
  800b71:	e8 27 00 00 00       	call   800b9d <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b76:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b79:	5b                   	pop    %ebx
  800b7a:	5e                   	pop    %esi
  800b7b:	5f                   	pop    %edi
  800b7c:	5d                   	pop    %ebp
  800b7d:	c3                   	ret    

00800b7e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b7e:	55                   	push   %ebp
  800b7f:	89 e5                	mov    %esp,%ebp
  800b81:	57                   	push   %edi
  800b82:	56                   	push   %esi
  800b83:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b84:	ba 00 00 00 00       	mov    $0x0,%edx
  800b89:	b8 02 00 00 00       	mov    $0x2,%eax
  800b8e:	89 d1                	mov    %edx,%ecx
  800b90:	89 d3                	mov    %edx,%ebx
  800b92:	89 d7                	mov    %edx,%edi
  800b94:	89 d6                	mov    %edx,%esi
  800b96:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b98:	5b                   	pop    %ebx
  800b99:	5e                   	pop    %esi
  800b9a:	5f                   	pop    %edi
  800b9b:	5d                   	pop    %ebp
  800b9c:	c3                   	ret    

00800b9d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800b9d:	55                   	push   %ebp
  800b9e:	89 e5                	mov    %esp,%ebp
  800ba0:	56                   	push   %esi
  800ba1:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800ba2:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800ba5:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800bab:	e8 ce ff ff ff       	call   800b7e <sys_getenvid>
  800bb0:	83 ec 0c             	sub    $0xc,%esp
  800bb3:	ff 75 0c             	pushl  0xc(%ebp)
  800bb6:	ff 75 08             	pushl  0x8(%ebp)
  800bb9:	56                   	push   %esi
  800bba:	50                   	push   %eax
  800bbb:	68 ec 10 80 00       	push   $0x8010ec
  800bc0:	e8 89 f5 ff ff       	call   80014e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800bc5:	83 c4 18             	add    $0x18,%esp
  800bc8:	53                   	push   %ebx
  800bc9:	ff 75 10             	pushl  0x10(%ebp)
  800bcc:	e8 2c f5 ff ff       	call   8000fd <vcprintf>
	cprintf("\n");
  800bd1:	c7 04 24 8c 0e 80 00 	movl   $0x800e8c,(%esp)
  800bd8:	e8 71 f5 ff ff       	call   80014e <cprintf>
  800bdd:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800be0:	cc                   	int3   
  800be1:	eb fd                	jmp    800be0 <_panic+0x43>
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
