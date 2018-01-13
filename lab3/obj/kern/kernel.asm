
obj/kern/kernel：     文件格式 elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 90 11 00       	mov    $0x119000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 90 11 f0       	mov    $0xf0119000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 02 00 00 00       	call   f0100040 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <i386_init>:
#include <kern/trap.h>


void
i386_init(void)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	83 ec 1c             	sub    $0x1c,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100046:	b8 10 db 17 f0       	mov    $0xf017db10,%eax
f010004b:	2d ee cb 17 f0       	sub    $0xf017cbee,%eax
f0100050:	50                   	push   %eax
f0100051:	6a 00                	push   $0x0
f0100053:	68 ee cb 17 f0       	push   $0xf017cbee
f0100058:	e8 d2 44 00 00       	call   f010452f <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f010005d:	e8 d9 04 00 00       	call   f010053b <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f0100062:	83 c4 08             	add    $0x8,%esp
f0100065:	68 ac 1a 00 00       	push   $0x1aac
f010006a:	68 e0 49 10 f0       	push   $0xf01049e0
f010006f:	e8 86 2f 00 00       	call   f0102ffa <cprintf>
    {
        int x = 1, y = 3, z = 4;
    Lab1_exercise8_3:
        cprintf("x %d, y %x, z %d\n", x, y, z);
f0100074:	6a 04                	push   $0x4
f0100076:	6a 03                	push   $0x3
f0100078:	6a 01                	push   $0x1
f010007a:	68 fb 49 10 f0       	push   $0xf01049fb
f010007f:	e8 76 2f 00 00       	call   f0102ffa <cprintf>
    Lab1_exercise8_5:
        cprintf("x=%d y=%d", 3);
f0100084:	83 c4 18             	add    $0x18,%esp
f0100087:	6a 03                	push   $0x3
f0100089:	68 0d 4a 10 f0       	push   $0xf0104a0d
f010008e:	e8 67 2f 00 00       	call   f0102ffa <cprintf>
    }
    {
        unsigned int i = 0x000a646c;
f0100093:	c7 45 f4 6c 64 0a 00 	movl   $0xa646c,-0xc(%ebp)
    Lab1_exercise8_4:
        cprintf("H%x Wor%s", 57616, &i);
f010009a:	83 c4 0c             	add    $0xc,%esp
f010009d:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01000a0:	50                   	push   %eax
f01000a1:	68 10 e1 00 00       	push   $0xe110
f01000a6:	68 17 4a 10 f0       	push   $0xf0104a17
f01000ab:	e8 4a 2f 00 00       	call   f0102ffa <cprintf>
    }

	// Lab 2 memory management initialization functions
	mem_init();
f01000b0:	e8 0f 10 00 00       	call   f01010c4 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f01000b5:	e8 71 29 00 00       	call   f0102a2b <env_init>
	trap_init();
f01000ba:	e8 ac 2f 00 00       	call   f010306b <trap_init>

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f01000bf:	83 c4 08             	add    $0x8,%esp
f01000c2:	6a 00                	push   $0x0
f01000c4:	68 9e 0b 14 f0       	push   $0xf0140b9e
f01000c9:	e8 06 2b 00 00       	call   f0102bd4 <env_create>
	// Touch all you want.
	ENV_CREATE(user_hello, ENV_TYPE_USER);
#endif // TEST*

	// We only have one user environment for now, so just run it.
	env_run(&envs[0]);
f01000ce:	83 c4 04             	add    $0x4,%esp
f01000d1:	ff 35 4c ce 17 f0    	pushl  0xf017ce4c
f01000d7:	e8 55 2e 00 00       	call   f0102f31 <env_run>

f01000dc <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000dc:	55                   	push   %ebp
f01000dd:	89 e5                	mov    %esp,%ebp
f01000df:	56                   	push   %esi
f01000e0:	53                   	push   %ebx
f01000e1:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f01000e4:	83 3d 00 db 17 f0 00 	cmpl   $0x0,0xf017db00
f01000eb:	75 37                	jne    f0100124 <_panic+0x48>
		goto dead;
	panicstr = fmt;
f01000ed:	89 35 00 db 17 f0    	mov    %esi,0xf017db00

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f01000f3:	fa                   	cli    
f01000f4:	fc                   	cld    

	va_start(ap, fmt);
f01000f5:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f01000f8:	83 ec 04             	sub    $0x4,%esp
f01000fb:	ff 75 0c             	pushl  0xc(%ebp)
f01000fe:	ff 75 08             	pushl  0x8(%ebp)
f0100101:	68 21 4a 10 f0       	push   $0xf0104a21
f0100106:	e8 ef 2e 00 00       	call   f0102ffa <cprintf>
	vcprintf(fmt, ap);
f010010b:	83 c4 08             	add    $0x8,%esp
f010010e:	53                   	push   %ebx
f010010f:	56                   	push   %esi
f0100110:	e8 bf 2e 00 00       	call   f0102fd4 <vcprintf>
	cprintf("\n");
f0100115:	c7 04 24 c6 59 10 f0 	movl   $0xf01059c6,(%esp)
f010011c:	e8 d9 2e 00 00       	call   f0102ffa <cprintf>
	va_end(ap);
f0100121:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100124:	83 ec 0c             	sub    $0xc,%esp
f0100127:	6a 00                	push   $0x0
f0100129:	e8 ae 06 00 00       	call   f01007dc <monitor>
f010012e:	83 c4 10             	add    $0x10,%esp
f0100131:	eb f1                	jmp    f0100124 <_panic+0x48>

f0100133 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100133:	55                   	push   %ebp
f0100134:	89 e5                	mov    %esp,%ebp
f0100136:	53                   	push   %ebx
f0100137:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f010013a:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f010013d:	ff 75 0c             	pushl  0xc(%ebp)
f0100140:	ff 75 08             	pushl  0x8(%ebp)
f0100143:	68 39 4a 10 f0       	push   $0xf0104a39
f0100148:	e8 ad 2e 00 00       	call   f0102ffa <cprintf>
	vcprintf(fmt, ap);
f010014d:	83 c4 08             	add    $0x8,%esp
f0100150:	53                   	push   %ebx
f0100151:	ff 75 10             	pushl  0x10(%ebp)
f0100154:	e8 7b 2e 00 00       	call   f0102fd4 <vcprintf>
	cprintf("\n");
f0100159:	c7 04 24 c6 59 10 f0 	movl   $0xf01059c6,(%esp)
f0100160:	e8 95 2e 00 00       	call   f0102ffa <cprintf>
	va_end(ap);
}
f0100165:	83 c4 10             	add    $0x10,%esp
f0100168:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010016b:	c9                   	leave  
f010016c:	c3                   	ret    

f010016d <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f010016d:	55                   	push   %ebp
f010016e:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100170:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100175:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100176:	a8 01                	test   $0x1,%al
f0100178:	74 0b                	je     f0100185 <serial_proc_data+0x18>
f010017a:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010017f:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100180:	0f b6 c0             	movzbl %al,%eax
f0100183:	eb 05                	jmp    f010018a <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f0100185:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f010018a:	5d                   	pop    %ebp
f010018b:	c3                   	ret    

f010018c <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010018c:	55                   	push   %ebp
f010018d:	89 e5                	mov    %esp,%ebp
f010018f:	53                   	push   %ebx
f0100190:	83 ec 04             	sub    $0x4,%esp
f0100193:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100195:	eb 2b                	jmp    f01001c2 <cons_intr+0x36>
		if (c == 0)
f0100197:	85 c0                	test   %eax,%eax
f0100199:	74 27                	je     f01001c2 <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f010019b:	8b 0d 24 ce 17 f0    	mov    0xf017ce24,%ecx
f01001a1:	8d 51 01             	lea    0x1(%ecx),%edx
f01001a4:	89 15 24 ce 17 f0    	mov    %edx,0xf017ce24
f01001aa:	88 81 20 cc 17 f0    	mov    %al,-0xfe833e0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01001b0:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01001b6:	75 0a                	jne    f01001c2 <cons_intr+0x36>
			cons.wpos = 0;
f01001b8:	c7 05 24 ce 17 f0 00 	movl   $0x0,0xf017ce24
f01001bf:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01001c2:	ff d3                	call   *%ebx
f01001c4:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001c7:	75 ce                	jne    f0100197 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01001c9:	83 c4 04             	add    $0x4,%esp
f01001cc:	5b                   	pop    %ebx
f01001cd:	5d                   	pop    %ebp
f01001ce:	c3                   	ret    

f01001cf <kbd_proc_data>:
f01001cf:	ba 64 00 00 00       	mov    $0x64,%edx
f01001d4:	ec                   	in     (%dx),%al
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f01001d5:	a8 01                	test   $0x1,%al
f01001d7:	0f 84 f0 00 00 00    	je     f01002cd <kbd_proc_data+0xfe>
f01001dd:	ba 60 00 00 00       	mov    $0x60,%edx
f01001e2:	ec                   	in     (%dx),%al
f01001e3:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01001e5:	3c e0                	cmp    $0xe0,%al
f01001e7:	75 0d                	jne    f01001f6 <kbd_proc_data+0x27>
		// E0 escape character
		shift |= E0ESC;
f01001e9:	83 0d 00 cc 17 f0 40 	orl    $0x40,0xf017cc00
		return 0;
f01001f0:	b8 00 00 00 00       	mov    $0x0,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01001f5:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01001f6:	55                   	push   %ebp
f01001f7:	89 e5                	mov    %esp,%ebp
f01001f9:	53                   	push   %ebx
f01001fa:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f01001fd:	84 c0                	test   %al,%al
f01001ff:	79 36                	jns    f0100237 <kbd_proc_data+0x68>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100201:	8b 0d 00 cc 17 f0    	mov    0xf017cc00,%ecx
f0100207:	89 cb                	mov    %ecx,%ebx
f0100209:	83 e3 40             	and    $0x40,%ebx
f010020c:	83 e0 7f             	and    $0x7f,%eax
f010020f:	85 db                	test   %ebx,%ebx
f0100211:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100214:	0f b6 d2             	movzbl %dl,%edx
f0100217:	0f b6 82 a0 4b 10 f0 	movzbl -0xfefb460(%edx),%eax
f010021e:	83 c8 40             	or     $0x40,%eax
f0100221:	0f b6 c0             	movzbl %al,%eax
f0100224:	f7 d0                	not    %eax
f0100226:	21 c8                	and    %ecx,%eax
f0100228:	a3 00 cc 17 f0       	mov    %eax,0xf017cc00
		return 0;
f010022d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100232:	e9 9e 00 00 00       	jmp    f01002d5 <kbd_proc_data+0x106>
	} else if (shift & E0ESC) {
f0100237:	8b 0d 00 cc 17 f0    	mov    0xf017cc00,%ecx
f010023d:	f6 c1 40             	test   $0x40,%cl
f0100240:	74 0e                	je     f0100250 <kbd_proc_data+0x81>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100242:	83 c8 80             	or     $0xffffff80,%eax
f0100245:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100247:	83 e1 bf             	and    $0xffffffbf,%ecx
f010024a:	89 0d 00 cc 17 f0    	mov    %ecx,0xf017cc00
	}

	shift |= shiftcode[data];
f0100250:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f0100253:	0f b6 82 a0 4b 10 f0 	movzbl -0xfefb460(%edx),%eax
f010025a:	0b 05 00 cc 17 f0    	or     0xf017cc00,%eax
f0100260:	0f b6 8a a0 4a 10 f0 	movzbl -0xfefb560(%edx),%ecx
f0100267:	31 c8                	xor    %ecx,%eax
f0100269:	a3 00 cc 17 f0       	mov    %eax,0xf017cc00

	c = charcode[shift & (CTL | SHIFT)][data];
f010026e:	89 c1                	mov    %eax,%ecx
f0100270:	83 e1 03             	and    $0x3,%ecx
f0100273:	8b 0c 8d 80 4a 10 f0 	mov    -0xfefb580(,%ecx,4),%ecx
f010027a:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f010027e:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100281:	a8 08                	test   $0x8,%al
f0100283:	74 1b                	je     f01002a0 <kbd_proc_data+0xd1>
		if ('a' <= c && c <= 'z')
f0100285:	89 da                	mov    %ebx,%edx
f0100287:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f010028a:	83 f9 19             	cmp    $0x19,%ecx
f010028d:	77 05                	ja     f0100294 <kbd_proc_data+0xc5>
			c += 'A' - 'a';
f010028f:	83 eb 20             	sub    $0x20,%ebx
f0100292:	eb 0c                	jmp    f01002a0 <kbd_proc_data+0xd1>
		else if ('A' <= c && c <= 'Z')
f0100294:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f0100297:	8d 4b 20             	lea    0x20(%ebx),%ecx
f010029a:	83 fa 19             	cmp    $0x19,%edx
f010029d:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01002a0:	f7 d0                	not    %eax
f01002a2:	a8 06                	test   $0x6,%al
f01002a4:	75 2d                	jne    f01002d3 <kbd_proc_data+0x104>
f01002a6:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01002ac:	75 25                	jne    f01002d3 <kbd_proc_data+0x104>
		cprintf("Rebooting!\n");
f01002ae:	83 ec 0c             	sub    $0xc,%esp
f01002b1:	68 53 4a 10 f0       	push   $0xf0104a53
f01002b6:	e8 3f 2d 00 00       	call   f0102ffa <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002bb:	ba 92 00 00 00       	mov    $0x92,%edx
f01002c0:	b8 03 00 00 00       	mov    $0x3,%eax
f01002c5:	ee                   	out    %al,(%dx)
f01002c6:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01002c9:	89 d8                	mov    %ebx,%eax
f01002cb:	eb 08                	jmp    f01002d5 <kbd_proc_data+0x106>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f01002cd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01002d2:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01002d3:	89 d8                	mov    %ebx,%eax
}
f01002d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01002d8:	c9                   	leave  
f01002d9:	c3                   	ret    

f01002da <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01002da:	55                   	push   %ebp
f01002db:	89 e5                	mov    %esp,%ebp
f01002dd:	57                   	push   %edi
f01002de:	56                   	push   %esi
f01002df:	53                   	push   %ebx
f01002e0:	83 ec 1c             	sub    $0x1c,%esp
f01002e3:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01002e5:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002ea:	be fd 03 00 00       	mov    $0x3fd,%esi
f01002ef:	b9 84 00 00 00       	mov    $0x84,%ecx
f01002f4:	eb 09                	jmp    f01002ff <cons_putc+0x25>
f01002f6:	89 ca                	mov    %ecx,%edx
f01002f8:	ec                   	in     (%dx),%al
f01002f9:	ec                   	in     (%dx),%al
f01002fa:	ec                   	in     (%dx),%al
f01002fb:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f01002fc:	83 c3 01             	add    $0x1,%ebx
f01002ff:	89 f2                	mov    %esi,%edx
f0100301:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100302:	a8 20                	test   $0x20,%al
f0100304:	75 08                	jne    f010030e <cons_putc+0x34>
f0100306:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f010030c:	7e e8                	jle    f01002f6 <cons_putc+0x1c>
f010030e:	89 f8                	mov    %edi,%eax
f0100310:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100313:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100318:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100319:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010031e:	be 79 03 00 00       	mov    $0x379,%esi
f0100323:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100328:	eb 09                	jmp    f0100333 <cons_putc+0x59>
f010032a:	89 ca                	mov    %ecx,%edx
f010032c:	ec                   	in     (%dx),%al
f010032d:	ec                   	in     (%dx),%al
f010032e:	ec                   	in     (%dx),%al
f010032f:	ec                   	in     (%dx),%al
f0100330:	83 c3 01             	add    $0x1,%ebx
f0100333:	89 f2                	mov    %esi,%edx
f0100335:	ec                   	in     (%dx),%al
f0100336:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f010033c:	7f 04                	jg     f0100342 <cons_putc+0x68>
f010033e:	84 c0                	test   %al,%al
f0100340:	79 e8                	jns    f010032a <cons_putc+0x50>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100342:	ba 78 03 00 00       	mov    $0x378,%edx
f0100347:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f010034b:	ee                   	out    %al,(%dx)
f010034c:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100351:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100356:	ee                   	out    %al,(%dx)
f0100357:	b8 08 00 00 00       	mov    $0x8,%eax
f010035c:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f010035d:	89 fa                	mov    %edi,%edx
f010035f:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f0100365:	89 f8                	mov    %edi,%eax
f0100367:	80 cc 07             	or     $0x7,%ah
f010036a:	85 d2                	test   %edx,%edx
f010036c:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f010036f:	89 f8                	mov    %edi,%eax
f0100371:	0f b6 c0             	movzbl %al,%eax
f0100374:	83 f8 09             	cmp    $0x9,%eax
f0100377:	74 74                	je     f01003ed <cons_putc+0x113>
f0100379:	83 f8 09             	cmp    $0x9,%eax
f010037c:	7f 0a                	jg     f0100388 <cons_putc+0xae>
f010037e:	83 f8 08             	cmp    $0x8,%eax
f0100381:	74 14                	je     f0100397 <cons_putc+0xbd>
f0100383:	e9 99 00 00 00       	jmp    f0100421 <cons_putc+0x147>
f0100388:	83 f8 0a             	cmp    $0xa,%eax
f010038b:	74 3a                	je     f01003c7 <cons_putc+0xed>
f010038d:	83 f8 0d             	cmp    $0xd,%eax
f0100390:	74 3d                	je     f01003cf <cons_putc+0xf5>
f0100392:	e9 8a 00 00 00       	jmp    f0100421 <cons_putc+0x147>
	case '\b':
		if (crt_pos > 0) {
f0100397:	0f b7 05 28 ce 17 f0 	movzwl 0xf017ce28,%eax
f010039e:	66 85 c0             	test   %ax,%ax
f01003a1:	0f 84 e6 00 00 00    	je     f010048d <cons_putc+0x1b3>
			crt_pos--;
f01003a7:	83 e8 01             	sub    $0x1,%eax
f01003aa:	66 a3 28 ce 17 f0    	mov    %ax,0xf017ce28
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01003b0:	0f b7 c0             	movzwl %ax,%eax
f01003b3:	66 81 e7 00 ff       	and    $0xff00,%di
f01003b8:	83 cf 20             	or     $0x20,%edi
f01003bb:	8b 15 2c ce 17 f0    	mov    0xf017ce2c,%edx
f01003c1:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01003c5:	eb 78                	jmp    f010043f <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01003c7:	66 83 05 28 ce 17 f0 	addw   $0x50,0xf017ce28
f01003ce:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01003cf:	0f b7 05 28 ce 17 f0 	movzwl 0xf017ce28,%eax
f01003d6:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01003dc:	c1 e8 16             	shr    $0x16,%eax
f01003df:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01003e2:	c1 e0 04             	shl    $0x4,%eax
f01003e5:	66 a3 28 ce 17 f0    	mov    %ax,0xf017ce28
f01003eb:	eb 52                	jmp    f010043f <cons_putc+0x165>
		break;
	case '\t':
		cons_putc(' ');
f01003ed:	b8 20 00 00 00       	mov    $0x20,%eax
f01003f2:	e8 e3 fe ff ff       	call   f01002da <cons_putc>
		cons_putc(' ');
f01003f7:	b8 20 00 00 00       	mov    $0x20,%eax
f01003fc:	e8 d9 fe ff ff       	call   f01002da <cons_putc>
		cons_putc(' ');
f0100401:	b8 20 00 00 00       	mov    $0x20,%eax
f0100406:	e8 cf fe ff ff       	call   f01002da <cons_putc>
		cons_putc(' ');
f010040b:	b8 20 00 00 00       	mov    $0x20,%eax
f0100410:	e8 c5 fe ff ff       	call   f01002da <cons_putc>
		cons_putc(' ');
f0100415:	b8 20 00 00 00       	mov    $0x20,%eax
f010041a:	e8 bb fe ff ff       	call   f01002da <cons_putc>
f010041f:	eb 1e                	jmp    f010043f <cons_putc+0x165>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100421:	0f b7 05 28 ce 17 f0 	movzwl 0xf017ce28,%eax
f0100428:	8d 50 01             	lea    0x1(%eax),%edx
f010042b:	66 89 15 28 ce 17 f0 	mov    %dx,0xf017ce28
f0100432:	0f b7 c0             	movzwl %ax,%eax
f0100435:	8b 15 2c ce 17 f0    	mov    0xf017ce2c,%edx
f010043b:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f010043f:	66 81 3d 28 ce 17 f0 	cmpw   $0x7cf,0xf017ce28
f0100446:	cf 07 
f0100448:	76 43                	jbe    f010048d <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010044a:	a1 2c ce 17 f0       	mov    0xf017ce2c,%eax
f010044f:	83 ec 04             	sub    $0x4,%esp
f0100452:	68 00 0f 00 00       	push   $0xf00
f0100457:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010045d:	52                   	push   %edx
f010045e:	50                   	push   %eax
f010045f:	e8 18 41 00 00       	call   f010457c <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100464:	8b 15 2c ce 17 f0    	mov    0xf017ce2c,%edx
f010046a:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100470:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100476:	83 c4 10             	add    $0x10,%esp
f0100479:	66 c7 00 20 07       	movw   $0x720,(%eax)
f010047e:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100481:	39 d0                	cmp    %edx,%eax
f0100483:	75 f4                	jne    f0100479 <cons_putc+0x19f>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f0100485:	66 83 2d 28 ce 17 f0 	subw   $0x50,0xf017ce28
f010048c:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f010048d:	8b 0d 30 ce 17 f0    	mov    0xf017ce30,%ecx
f0100493:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100498:	89 ca                	mov    %ecx,%edx
f010049a:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010049b:	0f b7 1d 28 ce 17 f0 	movzwl 0xf017ce28,%ebx
f01004a2:	8d 71 01             	lea    0x1(%ecx),%esi
f01004a5:	89 d8                	mov    %ebx,%eax
f01004a7:	66 c1 e8 08          	shr    $0x8,%ax
f01004ab:	89 f2                	mov    %esi,%edx
f01004ad:	ee                   	out    %al,(%dx)
f01004ae:	b8 0f 00 00 00       	mov    $0xf,%eax
f01004b3:	89 ca                	mov    %ecx,%edx
f01004b5:	ee                   	out    %al,(%dx)
f01004b6:	89 d8                	mov    %ebx,%eax
f01004b8:	89 f2                	mov    %esi,%edx
f01004ba:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01004bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01004be:	5b                   	pop    %ebx
f01004bf:	5e                   	pop    %esi
f01004c0:	5f                   	pop    %edi
f01004c1:	5d                   	pop    %ebp
f01004c2:	c3                   	ret    

f01004c3 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f01004c3:	80 3d 34 ce 17 f0 00 	cmpb   $0x0,0xf017ce34
f01004ca:	74 11                	je     f01004dd <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01004cc:	55                   	push   %ebp
f01004cd:	89 e5                	mov    %esp,%ebp
f01004cf:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f01004d2:	b8 6d 01 10 f0       	mov    $0xf010016d,%eax
f01004d7:	e8 b0 fc ff ff       	call   f010018c <cons_intr>
}
f01004dc:	c9                   	leave  
f01004dd:	f3 c3                	repz ret 

f01004df <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01004df:	55                   	push   %ebp
f01004e0:	89 e5                	mov    %esp,%ebp
f01004e2:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01004e5:	b8 cf 01 10 f0       	mov    $0xf01001cf,%eax
f01004ea:	e8 9d fc ff ff       	call   f010018c <cons_intr>
}
f01004ef:	c9                   	leave  
f01004f0:	c3                   	ret    

f01004f1 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01004f1:	55                   	push   %ebp
f01004f2:	89 e5                	mov    %esp,%ebp
f01004f4:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01004f7:	e8 c7 ff ff ff       	call   f01004c3 <serial_intr>
	kbd_intr();
f01004fc:	e8 de ff ff ff       	call   f01004df <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100501:	a1 20 ce 17 f0       	mov    0xf017ce20,%eax
f0100506:	3b 05 24 ce 17 f0    	cmp    0xf017ce24,%eax
f010050c:	74 26                	je     f0100534 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f010050e:	8d 50 01             	lea    0x1(%eax),%edx
f0100511:	89 15 20 ce 17 f0    	mov    %edx,0xf017ce20
f0100517:	0f b6 88 20 cc 17 f0 	movzbl -0xfe833e0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f010051e:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f0100520:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100526:	75 11                	jne    f0100539 <cons_getc+0x48>
			cons.rpos = 0;
f0100528:	c7 05 20 ce 17 f0 00 	movl   $0x0,0xf017ce20
f010052f:	00 00 00 
f0100532:	eb 05                	jmp    f0100539 <cons_getc+0x48>
		return c;
	}
	return 0;
f0100534:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100539:	c9                   	leave  
f010053a:	c3                   	ret    

f010053b <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f010053b:	55                   	push   %ebp
f010053c:	89 e5                	mov    %esp,%ebp
f010053e:	57                   	push   %edi
f010053f:	56                   	push   %esi
f0100540:	53                   	push   %ebx
f0100541:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100544:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010054b:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100552:	5a a5 
	if (*cp != 0xA55A) {
f0100554:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010055b:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010055f:	74 11                	je     f0100572 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100561:	c7 05 30 ce 17 f0 b4 	movl   $0x3b4,0xf017ce30
f0100568:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010056b:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100570:	eb 16                	jmp    f0100588 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100572:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100579:	c7 05 30 ce 17 f0 d4 	movl   $0x3d4,0xf017ce30
f0100580:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100583:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f0100588:	8b 3d 30 ce 17 f0    	mov    0xf017ce30,%edi
f010058e:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100593:	89 fa                	mov    %edi,%edx
f0100595:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100596:	8d 5f 01             	lea    0x1(%edi),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100599:	89 da                	mov    %ebx,%edx
f010059b:	ec                   	in     (%dx),%al
f010059c:	0f b6 c8             	movzbl %al,%ecx
f010059f:	c1 e1 08             	shl    $0x8,%ecx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005a2:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005a7:	89 fa                	mov    %edi,%edx
f01005a9:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005aa:	89 da                	mov    %ebx,%edx
f01005ac:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01005ad:	89 35 2c ce 17 f0    	mov    %esi,0xf017ce2c
	crt_pos = pos;
f01005b3:	0f b6 c0             	movzbl %al,%eax
f01005b6:	09 c8                	or     %ecx,%eax
f01005b8:	66 a3 28 ce 17 f0    	mov    %ax,0xf017ce28
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005be:	be fa 03 00 00       	mov    $0x3fa,%esi
f01005c3:	b8 00 00 00 00       	mov    $0x0,%eax
f01005c8:	89 f2                	mov    %esi,%edx
f01005ca:	ee                   	out    %al,(%dx)
f01005cb:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01005d0:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01005d5:	ee                   	out    %al,(%dx)
f01005d6:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f01005db:	b8 0c 00 00 00       	mov    $0xc,%eax
f01005e0:	89 da                	mov    %ebx,%edx
f01005e2:	ee                   	out    %al,(%dx)
f01005e3:	ba f9 03 00 00       	mov    $0x3f9,%edx
f01005e8:	b8 00 00 00 00       	mov    $0x0,%eax
f01005ed:	ee                   	out    %al,(%dx)
f01005ee:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01005f3:	b8 03 00 00 00       	mov    $0x3,%eax
f01005f8:	ee                   	out    %al,(%dx)
f01005f9:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01005fe:	b8 00 00 00 00       	mov    $0x0,%eax
f0100603:	ee                   	out    %al,(%dx)
f0100604:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100609:	b8 01 00 00 00       	mov    $0x1,%eax
f010060e:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010060f:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100614:	ec                   	in     (%dx),%al
f0100615:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100617:	3c ff                	cmp    $0xff,%al
f0100619:	0f 95 05 34 ce 17 f0 	setne  0xf017ce34
f0100620:	89 f2                	mov    %esi,%edx
f0100622:	ec                   	in     (%dx),%al
f0100623:	89 da                	mov    %ebx,%edx
f0100625:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100626:	80 f9 ff             	cmp    $0xff,%cl
f0100629:	75 10                	jne    f010063b <cons_init+0x100>
		cprintf("Serial port does not exist!\n");
f010062b:	83 ec 0c             	sub    $0xc,%esp
f010062e:	68 5f 4a 10 f0       	push   $0xf0104a5f
f0100633:	e8 c2 29 00 00       	call   f0102ffa <cprintf>
f0100638:	83 c4 10             	add    $0x10,%esp
}
f010063b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010063e:	5b                   	pop    %ebx
f010063f:	5e                   	pop    %esi
f0100640:	5f                   	pop    %edi
f0100641:	5d                   	pop    %ebp
f0100642:	c3                   	ret    

f0100643 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100643:	55                   	push   %ebp
f0100644:	89 e5                	mov    %esp,%ebp
f0100646:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100649:	8b 45 08             	mov    0x8(%ebp),%eax
f010064c:	e8 89 fc ff ff       	call   f01002da <cons_putc>
}
f0100651:	c9                   	leave  
f0100652:	c3                   	ret    

f0100653 <getchar>:

int
getchar(void)
{
f0100653:	55                   	push   %ebp
f0100654:	89 e5                	mov    %esp,%ebp
f0100656:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100659:	e8 93 fe ff ff       	call   f01004f1 <cons_getc>
f010065e:	85 c0                	test   %eax,%eax
f0100660:	74 f7                	je     f0100659 <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100662:	c9                   	leave  
f0100663:	c3                   	ret    

f0100664 <iscons>:

int
iscons(int fdnum)
{
f0100664:	55                   	push   %ebp
f0100665:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100667:	b8 01 00 00 00       	mov    $0x1,%eax
f010066c:	5d                   	pop    %ebp
f010066d:	c3                   	ret    

f010066e <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f010066e:	55                   	push   %ebp
f010066f:	89 e5                	mov    %esp,%ebp
f0100671:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100674:	68 a0 4c 10 f0       	push   $0xf0104ca0
f0100679:	68 be 4c 10 f0       	push   $0xf0104cbe
f010067e:	68 c3 4c 10 f0       	push   $0xf0104cc3
f0100683:	e8 72 29 00 00       	call   f0102ffa <cprintf>
f0100688:	83 c4 0c             	add    $0xc,%esp
f010068b:	68 5c 4d 10 f0       	push   $0xf0104d5c
f0100690:	68 cc 4c 10 f0       	push   $0xf0104ccc
f0100695:	68 c3 4c 10 f0       	push   $0xf0104cc3
f010069a:	e8 5b 29 00 00       	call   f0102ffa <cprintf>
f010069f:	83 c4 0c             	add    $0xc,%esp
f01006a2:	68 d5 4c 10 f0       	push   $0xf0104cd5
f01006a7:	68 ec 4c 10 f0       	push   $0xf0104cec
f01006ac:	68 c3 4c 10 f0       	push   $0xf0104cc3
f01006b1:	e8 44 29 00 00       	call   f0102ffa <cprintf>
	return 0;
}
f01006b6:	b8 00 00 00 00       	mov    $0x0,%eax
f01006bb:	c9                   	leave  
f01006bc:	c3                   	ret    

f01006bd <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01006bd:	55                   	push   %ebp
f01006be:	89 e5                	mov    %esp,%ebp
f01006c0:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01006c3:	68 f6 4c 10 f0       	push   $0xf0104cf6
f01006c8:	e8 2d 29 00 00       	call   f0102ffa <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01006cd:	83 c4 08             	add    $0x8,%esp
f01006d0:	68 0c 00 10 00       	push   $0x10000c
f01006d5:	68 84 4d 10 f0       	push   $0xf0104d84
f01006da:	e8 1b 29 00 00       	call   f0102ffa <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01006df:	83 c4 0c             	add    $0xc,%esp
f01006e2:	68 0c 00 10 00       	push   $0x10000c
f01006e7:	68 0c 00 10 f0       	push   $0xf010000c
f01006ec:	68 ac 4d 10 f0       	push   $0xf0104dac
f01006f1:	e8 04 29 00 00       	call   f0102ffa <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01006f6:	83 c4 0c             	add    $0xc,%esp
f01006f9:	68 c1 49 10 00       	push   $0x1049c1
f01006fe:	68 c1 49 10 f0       	push   $0xf01049c1
f0100703:	68 d0 4d 10 f0       	push   $0xf0104dd0
f0100708:	e8 ed 28 00 00       	call   f0102ffa <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010070d:	83 c4 0c             	add    $0xc,%esp
f0100710:	68 ee cb 17 00       	push   $0x17cbee
f0100715:	68 ee cb 17 f0       	push   $0xf017cbee
f010071a:	68 f4 4d 10 f0       	push   $0xf0104df4
f010071f:	e8 d6 28 00 00       	call   f0102ffa <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100724:	83 c4 0c             	add    $0xc,%esp
f0100727:	68 10 db 17 00       	push   $0x17db10
f010072c:	68 10 db 17 f0       	push   $0xf017db10
f0100731:	68 18 4e 10 f0       	push   $0xf0104e18
f0100736:	e8 bf 28 00 00       	call   f0102ffa <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f010073b:	b8 0f df 17 f0       	mov    $0xf017df0f,%eax
f0100740:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100745:	83 c4 08             	add    $0x8,%esp
f0100748:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f010074d:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100753:	85 c0                	test   %eax,%eax
f0100755:	0f 48 c2             	cmovs  %edx,%eax
f0100758:	c1 f8 0a             	sar    $0xa,%eax
f010075b:	50                   	push   %eax
f010075c:	68 3c 4e 10 f0       	push   $0xf0104e3c
f0100761:	e8 94 28 00 00       	call   f0102ffa <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f0100766:	b8 00 00 00 00       	mov    $0x0,%eax
f010076b:	c9                   	leave  
f010076c:	c3                   	ret    

f010076d <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010076d:	55                   	push   %ebp
f010076e:	89 e5                	mov    %esp,%ebp
f0100770:	57                   	push   %edi
f0100771:	56                   	push   %esi
f0100772:	53                   	push   %ebx
f0100773:	83 ec 2c             	sub    $0x2c,%esp

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0100776:	89 e8                	mov    %ebp,%eax
    while (ebp != 0)
    {
        p = (uint32_t *) ebp;
        eip = p[1];
        cprintf("ebp %x eip %x args %08x %08x %08x %08x %08x\n", ebp, eip, p[2], p[3], p[4], p[5], p[6]);
        if (debuginfo_eip(eip, &info) == 0)
f0100778:	8d 7d d0             	lea    -0x30(%ebp),%edi
{
    uint32_t ebp, eip, *p;
    struct Eipdebuginfo info;

    ebp = read_ebp();
    while (ebp != 0)
f010077b:	eb 53                	jmp    f01007d0 <mon_backtrace+0x63>
    {
        p = (uint32_t *) ebp;
f010077d:	89 c6                	mov    %eax,%esi
        eip = p[1];
f010077f:	8b 58 04             	mov    0x4(%eax),%ebx
        cprintf("ebp %x eip %x args %08x %08x %08x %08x %08x\n", ebp, eip, p[2], p[3], p[4], p[5], p[6]);
f0100782:	ff 70 18             	pushl  0x18(%eax)
f0100785:	ff 70 14             	pushl  0x14(%eax)
f0100788:	ff 70 10             	pushl  0x10(%eax)
f010078b:	ff 70 0c             	pushl  0xc(%eax)
f010078e:	ff 70 08             	pushl  0x8(%eax)
f0100791:	53                   	push   %ebx
f0100792:	50                   	push   %eax
f0100793:	68 68 4e 10 f0       	push   $0xf0104e68
f0100798:	e8 5d 28 00 00       	call   f0102ffa <cprintf>
        if (debuginfo_eip(eip, &info) == 0)
f010079d:	83 c4 18             	add    $0x18,%esp
f01007a0:	57                   	push   %edi
f01007a1:	53                   	push   %ebx
f01007a2:	e8 30 32 00 00       	call   f01039d7 <debuginfo_eip>
f01007a7:	83 c4 10             	add    $0x10,%esp
f01007aa:	85 c0                	test   %eax,%eax
f01007ac:	75 20                	jne    f01007ce <mon_backtrace+0x61>
        {
            int fn_offset = eip - info.eip_fn_addr;

            cprintf("%s:%d: %.*s+%d\n", info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name, fn_offset);
f01007ae:	83 ec 08             	sub    $0x8,%esp
f01007b1:	2b 5d e0             	sub    -0x20(%ebp),%ebx
f01007b4:	53                   	push   %ebx
f01007b5:	ff 75 d8             	pushl  -0x28(%ebp)
f01007b8:	ff 75 dc             	pushl  -0x24(%ebp)
f01007bb:	ff 75 d4             	pushl  -0x2c(%ebp)
f01007be:	ff 75 d0             	pushl  -0x30(%ebp)
f01007c1:	68 0f 4d 10 f0       	push   $0xf0104d0f
f01007c6:	e8 2f 28 00 00       	call   f0102ffa <cprintf>
f01007cb:	83 c4 20             	add    $0x20,%esp
        }
        ebp = p[0];
f01007ce:	8b 06                	mov    (%esi),%eax
{
    uint32_t ebp, eip, *p;
    struct Eipdebuginfo info;

    ebp = read_ebp();
    while (ebp != 0)
f01007d0:	85 c0                	test   %eax,%eax
f01007d2:	75 a9                	jne    f010077d <mon_backtrace+0x10>
        }
        ebp = p[0];
    }
    
	return 0;
}
f01007d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01007d7:	5b                   	pop    %ebx
f01007d8:	5e                   	pop    %esi
f01007d9:	5f                   	pop    %edi
f01007da:	5d                   	pop    %ebp
f01007db:	c3                   	ret    

f01007dc <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01007dc:	55                   	push   %ebp
f01007dd:	89 e5                	mov    %esp,%ebp
f01007df:	57                   	push   %edi
f01007e0:	56                   	push   %esi
f01007e1:	53                   	push   %ebx
f01007e2:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01007e5:	68 98 4e 10 f0       	push   $0xf0104e98
f01007ea:	e8 0b 28 00 00       	call   f0102ffa <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01007ef:	c7 04 24 bc 4e 10 f0 	movl   $0xf0104ebc,(%esp)
f01007f6:	e8 ff 27 00 00       	call   f0102ffa <cprintf>

	if (tf != NULL)
f01007fb:	83 c4 10             	add    $0x10,%esp
f01007fe:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100802:	74 0e                	je     f0100812 <monitor+0x36>
		print_trapframe(tf);
f0100804:	83 ec 0c             	sub    $0xc,%esp
f0100807:	ff 75 08             	pushl  0x8(%ebp)
f010080a:	e8 7b 2c 00 00       	call   f010348a <print_trapframe>
f010080f:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0100812:	83 ec 0c             	sub    $0xc,%esp
f0100815:	68 1f 4d 10 f0       	push   $0xf0104d1f
f010081a:	e8 b9 3a 00 00       	call   f01042d8 <readline>
f010081f:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100821:	83 c4 10             	add    $0x10,%esp
f0100824:	85 c0                	test   %eax,%eax
f0100826:	74 ea                	je     f0100812 <monitor+0x36>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100828:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f010082f:	be 00 00 00 00       	mov    $0x0,%esi
f0100834:	eb 0a                	jmp    f0100840 <monitor+0x64>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100836:	c6 03 00             	movb   $0x0,(%ebx)
f0100839:	89 f7                	mov    %esi,%edi
f010083b:	8d 5b 01             	lea    0x1(%ebx),%ebx
f010083e:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100840:	0f b6 03             	movzbl (%ebx),%eax
f0100843:	84 c0                	test   %al,%al
f0100845:	74 63                	je     f01008aa <monitor+0xce>
f0100847:	83 ec 08             	sub    $0x8,%esp
f010084a:	0f be c0             	movsbl %al,%eax
f010084d:	50                   	push   %eax
f010084e:	68 23 4d 10 f0       	push   $0xf0104d23
f0100853:	e8 9a 3c 00 00       	call   f01044f2 <strchr>
f0100858:	83 c4 10             	add    $0x10,%esp
f010085b:	85 c0                	test   %eax,%eax
f010085d:	75 d7                	jne    f0100836 <monitor+0x5a>
			*buf++ = 0;
		if (*buf == 0)
f010085f:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100862:	74 46                	je     f01008aa <monitor+0xce>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100864:	83 fe 0f             	cmp    $0xf,%esi
f0100867:	75 14                	jne    f010087d <monitor+0xa1>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100869:	83 ec 08             	sub    $0x8,%esp
f010086c:	6a 10                	push   $0x10
f010086e:	68 28 4d 10 f0       	push   $0xf0104d28
f0100873:	e8 82 27 00 00       	call   f0102ffa <cprintf>
f0100878:	83 c4 10             	add    $0x10,%esp
f010087b:	eb 95                	jmp    f0100812 <monitor+0x36>
			return 0;
		}
		argv[argc++] = buf;
f010087d:	8d 7e 01             	lea    0x1(%esi),%edi
f0100880:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100884:	eb 03                	jmp    f0100889 <monitor+0xad>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0100886:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100889:	0f b6 03             	movzbl (%ebx),%eax
f010088c:	84 c0                	test   %al,%al
f010088e:	74 ae                	je     f010083e <monitor+0x62>
f0100890:	83 ec 08             	sub    $0x8,%esp
f0100893:	0f be c0             	movsbl %al,%eax
f0100896:	50                   	push   %eax
f0100897:	68 23 4d 10 f0       	push   $0xf0104d23
f010089c:	e8 51 3c 00 00       	call   f01044f2 <strchr>
f01008a1:	83 c4 10             	add    $0x10,%esp
f01008a4:	85 c0                	test   %eax,%eax
f01008a6:	74 de                	je     f0100886 <monitor+0xaa>
f01008a8:	eb 94                	jmp    f010083e <monitor+0x62>
			buf++;
	}
	argv[argc] = 0;
f01008aa:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f01008b1:	00 

	// Lookup and invoke the command
	if (argc == 0)
f01008b2:	85 f6                	test   %esi,%esi
f01008b4:	0f 84 58 ff ff ff    	je     f0100812 <monitor+0x36>
f01008ba:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f01008bf:	83 ec 08             	sub    $0x8,%esp
f01008c2:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01008c5:	ff 34 85 00 4f 10 f0 	pushl  -0xfefb100(,%eax,4)
f01008cc:	ff 75 a8             	pushl  -0x58(%ebp)
f01008cf:	e8 c0 3b 00 00       	call   f0104494 <strcmp>
f01008d4:	83 c4 10             	add    $0x10,%esp
f01008d7:	85 c0                	test   %eax,%eax
f01008d9:	75 21                	jne    f01008fc <monitor+0x120>
			return commands[i].func(argc, argv, tf);
f01008db:	83 ec 04             	sub    $0x4,%esp
f01008de:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01008e1:	ff 75 08             	pushl  0x8(%ebp)
f01008e4:	8d 55 a8             	lea    -0x58(%ebp),%edx
f01008e7:	52                   	push   %edx
f01008e8:	56                   	push   %esi
f01008e9:	ff 14 85 08 4f 10 f0 	call   *-0xfefb0f8(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f01008f0:	83 c4 10             	add    $0x10,%esp
f01008f3:	85 c0                	test   %eax,%eax
f01008f5:	78 25                	js     f010091c <monitor+0x140>
f01008f7:	e9 16 ff ff ff       	jmp    f0100812 <monitor+0x36>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f01008fc:	83 c3 01             	add    $0x1,%ebx
f01008ff:	83 fb 03             	cmp    $0x3,%ebx
f0100902:	75 bb                	jne    f01008bf <monitor+0xe3>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100904:	83 ec 08             	sub    $0x8,%esp
f0100907:	ff 75 a8             	pushl  -0x58(%ebp)
f010090a:	68 45 4d 10 f0       	push   $0xf0104d45
f010090f:	e8 e6 26 00 00       	call   f0102ffa <cprintf>
f0100914:	83 c4 10             	add    $0x10,%esp
f0100917:	e9 f6 fe ff ff       	jmp    f0100812 <monitor+0x36>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f010091c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010091f:	5b                   	pop    %ebx
f0100920:	5e                   	pop    %esi
f0100921:	5f                   	pop    %edi
f0100922:	5d                   	pop    %ebp
f0100923:	c3                   	ret    

f0100924 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100924:	55                   	push   %ebp
f0100925:	89 e5                	mov    %esp,%ebp
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100927:	83 3d 38 ce 17 f0 00 	cmpl   $0x0,0xf017ce38
f010092e:	75 11                	jne    f0100941 <boot_alloc+0x1d>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100930:	ba 0f eb 17 f0       	mov    $0xf017eb0f,%edx
f0100935:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010093b:	89 15 38 ce 17 f0    	mov    %edx,0xf017ce38
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
    result = nextfree;
f0100941:	8b 0d 38 ce 17 f0    	mov    0xf017ce38,%ecx
    nextfree = ROUNDUP(nextfree + n, PGSIZE);
f0100947:	8d 94 01 ff 0f 00 00 	lea    0xfff(%ecx,%eax,1),%edx
f010094e:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100954:	89 15 38 ce 17 f0    	mov    %edx,0xf017ce38

	return result;
}
f010095a:	89 c8                	mov    %ecx,%eax
f010095c:	5d                   	pop    %ebp
f010095d:	c3                   	ret    

f010095e <check_va2pa>:
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f010095e:	89 d1                	mov    %edx,%ecx
f0100960:	c1 e9 16             	shr    $0x16,%ecx
f0100963:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100966:	a8 01                	test   $0x1,%al
f0100968:	74 52                	je     f01009bc <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f010096a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010096f:	89 c1                	mov    %eax,%ecx
f0100971:	c1 e9 0c             	shr    $0xc,%ecx
f0100974:	3b 0d 04 db 17 f0    	cmp    0xf017db04,%ecx
f010097a:	72 1b                	jb     f0100997 <check_va2pa+0x39>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f010097c:	55                   	push   %ebp
f010097d:	89 e5                	mov    %esp,%ebp
f010097f:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100982:	50                   	push   %eax
f0100983:	68 24 4f 10 f0       	push   $0xf0104f24
f0100988:	68 89 03 00 00       	push   $0x389
f010098d:	68 15 57 10 f0       	push   $0xf0105715
f0100992:	e8 45 f7 ff ff       	call   f01000dc <_panic>

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f0100997:	c1 ea 0c             	shr    $0xc,%edx
f010099a:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f01009a0:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f01009a7:	89 c2                	mov    %eax,%edx
f01009a9:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f01009ac:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01009b1:	85 d2                	test   %edx,%edx
f01009b3:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f01009b8:	0f 44 c2             	cmove  %edx,%eax
f01009bb:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f01009bc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f01009c1:	c3                   	ret    

f01009c2 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f01009c2:	55                   	push   %ebp
f01009c3:	89 e5                	mov    %esp,%ebp
f01009c5:	57                   	push   %edi
f01009c6:	56                   	push   %esi
f01009c7:	53                   	push   %ebx
f01009c8:	83 ec 2c             	sub    $0x2c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f01009cb:	84 c0                	test   %al,%al
f01009cd:	0f 85 72 02 00 00    	jne    f0100c45 <check_page_free_list+0x283>
f01009d3:	e9 7f 02 00 00       	jmp    f0100c57 <check_page_free_list+0x295>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f01009d8:	83 ec 04             	sub    $0x4,%esp
f01009db:	68 48 4f 10 f0       	push   $0xf0104f48
f01009e0:	68 c7 02 00 00       	push   $0x2c7
f01009e5:	68 15 57 10 f0       	push   $0xf0105715
f01009ea:	e8 ed f6 ff ff       	call   f01000dc <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f01009ef:	8d 55 d8             	lea    -0x28(%ebp),%edx
f01009f2:	89 55 e0             	mov    %edx,-0x20(%ebp)
f01009f5:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01009f8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f01009fb:	89 c2                	mov    %eax,%edx
f01009fd:	2b 15 0c db 17 f0    	sub    0xf017db0c,%edx
f0100a03:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100a09:	0f 95 c2             	setne  %dl
f0100a0c:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100a0f:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100a13:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100a15:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100a19:	8b 00                	mov    (%eax),%eax
f0100a1b:	85 c0                	test   %eax,%eax
f0100a1d:	75 dc                	jne    f01009fb <check_page_free_list+0x39>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100a1f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a22:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100a28:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100a2b:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100a2e:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100a30:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100a33:	a3 40 ce 17 f0       	mov    %eax,0xf017ce40
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100a38:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100a3d:	8b 1d 40 ce 17 f0    	mov    0xf017ce40,%ebx
f0100a43:	eb 53                	jmp    f0100a98 <check_page_free_list+0xd6>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100a45:	89 d8                	mov    %ebx,%eax
f0100a47:	2b 05 0c db 17 f0    	sub    0xf017db0c,%eax
f0100a4d:	c1 f8 03             	sar    $0x3,%eax
f0100a50:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100a53:	89 c2                	mov    %eax,%edx
f0100a55:	c1 ea 16             	shr    $0x16,%edx
f0100a58:	39 f2                	cmp    %esi,%edx
f0100a5a:	73 3a                	jae    f0100a96 <check_page_free_list+0xd4>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100a5c:	89 c2                	mov    %eax,%edx
f0100a5e:	c1 ea 0c             	shr    $0xc,%edx
f0100a61:	3b 15 04 db 17 f0    	cmp    0xf017db04,%edx
f0100a67:	72 12                	jb     f0100a7b <check_page_free_list+0xb9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100a69:	50                   	push   %eax
f0100a6a:	68 24 4f 10 f0       	push   $0xf0104f24
f0100a6f:	6a 56                	push   $0x56
f0100a71:	68 21 57 10 f0       	push   $0xf0105721
f0100a76:	e8 61 f6 ff ff       	call   f01000dc <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100a7b:	83 ec 04             	sub    $0x4,%esp
f0100a7e:	68 80 00 00 00       	push   $0x80
f0100a83:	68 97 00 00 00       	push   $0x97
f0100a88:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100a8d:	50                   	push   %eax
f0100a8e:	e8 9c 3a 00 00       	call   f010452f <memset>
f0100a93:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100a96:	8b 1b                	mov    (%ebx),%ebx
f0100a98:	85 db                	test   %ebx,%ebx
f0100a9a:	75 a9                	jne    f0100a45 <check_page_free_list+0x83>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100a9c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100aa1:	e8 7e fe ff ff       	call   f0100924 <boot_alloc>
f0100aa6:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100aa9:	8b 15 40 ce 17 f0    	mov    0xf017ce40,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100aaf:	8b 0d 0c db 17 f0    	mov    0xf017db0c,%ecx
		assert(pp < pages + npages);
f0100ab5:	a1 04 db 17 f0       	mov    0xf017db04,%eax
f0100aba:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100abd:	8d 3c c1             	lea    (%ecx,%eax,8),%edi
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100ac0:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100ac3:	be 00 00 00 00       	mov    $0x0,%esi
f0100ac8:	89 5d d0             	mov    %ebx,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100acb:	e9 30 01 00 00       	jmp    f0100c00 <check_page_free_list+0x23e>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100ad0:	39 ca                	cmp    %ecx,%edx
f0100ad2:	73 19                	jae    f0100aed <check_page_free_list+0x12b>
f0100ad4:	68 2f 57 10 f0       	push   $0xf010572f
f0100ad9:	68 3b 57 10 f0       	push   $0xf010573b
f0100ade:	68 e1 02 00 00       	push   $0x2e1
f0100ae3:	68 15 57 10 f0       	push   $0xf0105715
f0100ae8:	e8 ef f5 ff ff       	call   f01000dc <_panic>
		assert(pp < pages + npages);
f0100aed:	39 fa                	cmp    %edi,%edx
f0100aef:	72 19                	jb     f0100b0a <check_page_free_list+0x148>
f0100af1:	68 50 57 10 f0       	push   $0xf0105750
f0100af6:	68 3b 57 10 f0       	push   $0xf010573b
f0100afb:	68 e2 02 00 00       	push   $0x2e2
f0100b00:	68 15 57 10 f0       	push   $0xf0105715
f0100b05:	e8 d2 f5 ff ff       	call   f01000dc <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100b0a:	89 d0                	mov    %edx,%eax
f0100b0c:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f0100b0f:	a8 07                	test   $0x7,%al
f0100b11:	74 19                	je     f0100b2c <check_page_free_list+0x16a>
f0100b13:	68 6c 4f 10 f0       	push   $0xf0104f6c
f0100b18:	68 3b 57 10 f0       	push   $0xf010573b
f0100b1d:	68 e3 02 00 00       	push   $0x2e3
f0100b22:	68 15 57 10 f0       	push   $0xf0105715
f0100b27:	e8 b0 f5 ff ff       	call   f01000dc <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100b2c:	c1 f8 03             	sar    $0x3,%eax
f0100b2f:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100b32:	85 c0                	test   %eax,%eax
f0100b34:	75 19                	jne    f0100b4f <check_page_free_list+0x18d>
f0100b36:	68 64 57 10 f0       	push   $0xf0105764
f0100b3b:	68 3b 57 10 f0       	push   $0xf010573b
f0100b40:	68 e6 02 00 00       	push   $0x2e6
f0100b45:	68 15 57 10 f0       	push   $0xf0105715
f0100b4a:	e8 8d f5 ff ff       	call   f01000dc <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100b4f:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100b54:	75 19                	jne    f0100b6f <check_page_free_list+0x1ad>
f0100b56:	68 75 57 10 f0       	push   $0xf0105775
f0100b5b:	68 3b 57 10 f0       	push   $0xf010573b
f0100b60:	68 e7 02 00 00       	push   $0x2e7
f0100b65:	68 15 57 10 f0       	push   $0xf0105715
f0100b6a:	e8 6d f5 ff ff       	call   f01000dc <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100b6f:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100b74:	75 19                	jne    f0100b8f <check_page_free_list+0x1cd>
f0100b76:	68 a0 4f 10 f0       	push   $0xf0104fa0
f0100b7b:	68 3b 57 10 f0       	push   $0xf010573b
f0100b80:	68 e8 02 00 00       	push   $0x2e8
f0100b85:	68 15 57 10 f0       	push   $0xf0105715
f0100b8a:	e8 4d f5 ff ff       	call   f01000dc <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100b8f:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100b94:	75 19                	jne    f0100baf <check_page_free_list+0x1ed>
f0100b96:	68 8e 57 10 f0       	push   $0xf010578e
f0100b9b:	68 3b 57 10 f0       	push   $0xf010573b
f0100ba0:	68 e9 02 00 00       	push   $0x2e9
f0100ba5:	68 15 57 10 f0       	push   $0xf0105715
f0100baa:	e8 2d f5 ff ff       	call   f01000dc <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100baf:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100bb4:	76 3f                	jbe    f0100bf5 <check_page_free_list+0x233>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100bb6:	89 c3                	mov    %eax,%ebx
f0100bb8:	c1 eb 0c             	shr    $0xc,%ebx
f0100bbb:	39 5d c8             	cmp    %ebx,-0x38(%ebp)
f0100bbe:	77 12                	ja     f0100bd2 <check_page_free_list+0x210>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100bc0:	50                   	push   %eax
f0100bc1:	68 24 4f 10 f0       	push   $0xf0104f24
f0100bc6:	6a 56                	push   $0x56
f0100bc8:	68 21 57 10 f0       	push   $0xf0105721
f0100bcd:	e8 0a f5 ff ff       	call   f01000dc <_panic>
f0100bd2:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100bd7:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0100bda:	76 1e                	jbe    f0100bfa <check_page_free_list+0x238>
f0100bdc:	68 c4 4f 10 f0       	push   $0xf0104fc4
f0100be1:	68 3b 57 10 f0       	push   $0xf010573b
f0100be6:	68 ea 02 00 00       	push   $0x2ea
f0100beb:	68 15 57 10 f0       	push   $0xf0105715
f0100bf0:	e8 e7 f4 ff ff       	call   f01000dc <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100bf5:	83 c6 01             	add    $0x1,%esi
f0100bf8:	eb 04                	jmp    f0100bfe <check_page_free_list+0x23c>
		else
			++nfree_extmem;
f0100bfa:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100bfe:	8b 12                	mov    (%edx),%edx
f0100c00:	85 d2                	test   %edx,%edx
f0100c02:	0f 85 c8 fe ff ff    	jne    f0100ad0 <check_page_free_list+0x10e>
f0100c08:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100c0b:	85 f6                	test   %esi,%esi
f0100c0d:	7f 19                	jg     f0100c28 <check_page_free_list+0x266>
f0100c0f:	68 a8 57 10 f0       	push   $0xf01057a8
f0100c14:	68 3b 57 10 f0       	push   $0xf010573b
f0100c19:	68 f2 02 00 00       	push   $0x2f2
f0100c1e:	68 15 57 10 f0       	push   $0xf0105715
f0100c23:	e8 b4 f4 ff ff       	call   f01000dc <_panic>
	assert(nfree_extmem > 0);
f0100c28:	85 db                	test   %ebx,%ebx
f0100c2a:	7f 42                	jg     f0100c6e <check_page_free_list+0x2ac>
f0100c2c:	68 ba 57 10 f0       	push   $0xf01057ba
f0100c31:	68 3b 57 10 f0       	push   $0xf010573b
f0100c36:	68 f3 02 00 00       	push   $0x2f3
f0100c3b:	68 15 57 10 f0       	push   $0xf0105715
f0100c40:	e8 97 f4 ff ff       	call   f01000dc <_panic>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100c45:	a1 40 ce 17 f0       	mov    0xf017ce40,%eax
f0100c4a:	85 c0                	test   %eax,%eax
f0100c4c:	0f 85 9d fd ff ff    	jne    f01009ef <check_page_free_list+0x2d>
f0100c52:	e9 81 fd ff ff       	jmp    f01009d8 <check_page_free_list+0x16>
f0100c57:	83 3d 40 ce 17 f0 00 	cmpl   $0x0,0xf017ce40
f0100c5e:	0f 84 74 fd ff ff    	je     f01009d8 <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100c64:	be 00 04 00 00       	mov    $0x400,%esi
f0100c69:	e9 cf fd ff ff       	jmp    f0100a3d <check_page_free_list+0x7b>
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);
}
f0100c6e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100c71:	5b                   	pop    %ebx
f0100c72:	5e                   	pop    %esi
f0100c73:	5f                   	pop    %edi
f0100c74:	5d                   	pop    %ebp
f0100c75:	c3                   	ret    

f0100c76 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100c76:	55                   	push   %ebp
f0100c77:	89 e5                	mov    %esp,%ebp
f0100c79:	56                   	push   %esi
f0100c7a:	53                   	push   %ebx
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}*/

    // Mark page 0 as in use
    pages[0].pp_ref = 1;
f0100c7b:	a1 0c db 17 f0       	mov    0xf017db0c,%eax
f0100c80:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)

    // Mark base memory as free
	for (i = 1; i < npages_basemem; i++)
f0100c86:	8b 35 44 ce 17 f0    	mov    0xf017ce44,%esi
f0100c8c:	8b 1d 40 ce 17 f0    	mov    0xf017ce40,%ebx
f0100c92:	ba 00 00 00 00       	mov    $0x0,%edx
f0100c97:	b8 01 00 00 00       	mov    $0x1,%eax
f0100c9c:	eb 27                	jmp    f0100cc5 <page_init+0x4f>
	{
	    pages[i].pp_ref = 0;
f0100c9e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0100ca5:	89 d1                	mov    %edx,%ecx
f0100ca7:	03 0d 0c db 17 f0    	add    0xf017db0c,%ecx
f0100cad:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
	    pages[i].pp_link = page_free_list;
f0100cb3:	89 19                	mov    %ebx,(%ecx)

    // Mark page 0 as in use
    pages[0].pp_ref = 1;

    // Mark base memory as free
	for (i = 1; i < npages_basemem; i++)
f0100cb5:	83 c0 01             	add    $0x1,%eax
	{
	    pages[i].pp_ref = 0;
	    pages[i].pp_link = page_free_list;
	    page_free_list = &pages[i];
f0100cb8:	89 d3                	mov    %edx,%ebx
f0100cba:	03 1d 0c db 17 f0    	add    0xf017db0c,%ebx
f0100cc0:	ba 01 00 00 00       	mov    $0x1,%edx

    // Mark page 0 as in use
    pages[0].pp_ref = 1;

    // Mark base memory as free
	for (i = 1; i < npages_basemem; i++)
f0100cc5:	39 f0                	cmp    %esi,%eax
f0100cc7:	72 d5                	jb     f0100c9e <page_init+0x28>
f0100cc9:	84 d2                	test   %dl,%dl
f0100ccb:	74 06                	je     f0100cd3 <page_init+0x5d>
f0100ccd:	89 1d 40 ce 17 f0    	mov    %ebx,0xf017ce40
	
	// IOPHYSMEM/PGSIZE == npages_basemem
	// Mark IO hole
	for (i = IOPHYSMEM/PGSIZE; i < EXTPHYSMEM/PGSIZE; i++)
	{
	    pages[i].pp_ref = 1;
f0100cd3:	8b 15 0c db 17 f0    	mov    0xf017db0c,%edx
f0100cd9:	8d 82 04 05 00 00    	lea    0x504(%edx),%eax
f0100cdf:	81 c2 04 08 00 00    	add    $0x804,%edx
f0100ce5:	66 c7 00 01 00       	movw   $0x1,(%eax)
f0100cea:	83 c0 08             	add    $0x8,%eax
	    page_free_list = &pages[i];
	}
	
	// IOPHYSMEM/PGSIZE == npages_basemem
	// Mark IO hole
	for (i = IOPHYSMEM/PGSIZE; i < EXTPHYSMEM/PGSIZE; i++)
f0100ced:	39 d0                	cmp    %edx,%eax
f0100cef:	75 f4                	jne    f0100ce5 <page_init+0x6f>
    // kernel is loaded in physical memory 0x100000, the beginning of extended memory
    // page directory entry, and npages of PageInfo structure ares allocated by 
    // boot_alloc in mem_init(). next free byte is 


    first_free_byte = PADDR(boot_alloc(0));
f0100cf1:	b8 00 00 00 00       	mov    $0x0,%eax
f0100cf6:	e8 29 fc ff ff       	call   f0100924 <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100cfb:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100d00:	77 15                	ja     f0100d17 <page_init+0xa1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100d02:	50                   	push   %eax
f0100d03:	68 0c 50 10 f0       	push   $0xf010500c
f0100d08:	68 45 01 00 00       	push   $0x145
f0100d0d:	68 15 57 10 f0       	push   $0xf0105715
f0100d12:	e8 c5 f3 ff ff       	call   f01000dc <_panic>
    first_free_page = first_free_byte/PGSIZE;
f0100d17:	05 00 00 00 10       	add    $0x10000000,%eax
f0100d1c:	c1 e8 0c             	shr    $0xc,%eax

    // mark kernel and page directory, PageInfo list as in use
    for (i = EXTPHYSMEM/PGSIZE; i < first_free_page; i++)
    {
        pages[i].pp_ref = 1;
f0100d1f:	8b 0d 0c db 17 f0    	mov    0xf017db0c,%ecx

    first_free_byte = PADDR(boot_alloc(0));
    first_free_page = first_free_byte/PGSIZE;

    // mark kernel and page directory, PageInfo list as in use
    for (i = EXTPHYSMEM/PGSIZE; i < first_free_page; i++)
f0100d25:	ba 00 01 00 00       	mov    $0x100,%edx
f0100d2a:	eb 0a                	jmp    f0100d36 <page_init+0xc0>
    {
        pages[i].pp_ref = 1;
f0100d2c:	66 c7 44 d1 04 01 00 	movw   $0x1,0x4(%ecx,%edx,8)

    first_free_byte = PADDR(boot_alloc(0));
    first_free_page = first_free_byte/PGSIZE;

    // mark kernel and page directory, PageInfo list as in use
    for (i = EXTPHYSMEM/PGSIZE; i < first_free_page; i++)
f0100d33:	83 c2 01             	add    $0x1,%edx
f0100d36:	39 c2                	cmp    %eax,%edx
f0100d38:	72 f2                	jb     f0100d2c <page_init+0xb6>
f0100d3a:	8b 1d 40 ce 17 f0    	mov    0xf017ce40,%ebx
f0100d40:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0100d47:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100d4c:	eb 23                	jmp    f0100d71 <page_init+0xfb>
        pages[i].pp_ref = 1;
    }
    // mark others as free
    for (i = first_free_page; i < npages; i++)
    {
        pages[i].pp_ref = 0;
f0100d4e:	89 d1                	mov    %edx,%ecx
f0100d50:	03 0d 0c db 17 f0    	add    0xf017db0c,%ecx
f0100d56:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
        pages[i].pp_link = page_free_list;
f0100d5c:	89 19                	mov    %ebx,(%ecx)
	    page_free_list = &pages[i];
f0100d5e:	89 d3                	mov    %edx,%ebx
f0100d60:	03 1d 0c db 17 f0    	add    0xf017db0c,%ebx
    for (i = EXTPHYSMEM/PGSIZE; i < first_free_page; i++)
    {
        pages[i].pp_ref = 1;
    }
    // mark others as free
    for (i = first_free_page; i < npages; i++)
f0100d66:	83 c0 01             	add    $0x1,%eax
f0100d69:	83 c2 08             	add    $0x8,%edx
f0100d6c:	b9 01 00 00 00       	mov    $0x1,%ecx
f0100d71:	3b 05 04 db 17 f0    	cmp    0xf017db04,%eax
f0100d77:	72 d5                	jb     f0100d4e <page_init+0xd8>
f0100d79:	84 c9                	test   %cl,%cl
f0100d7b:	74 06                	je     f0100d83 <page_init+0x10d>
f0100d7d:	89 1d 40 ce 17 f0    	mov    %ebx,0xf017ce40
    {
        pages[i].pp_ref = 0;
        pages[i].pp_link = page_free_list;
	    page_free_list = &pages[i];
	}
}
f0100d83:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100d86:	5b                   	pop    %ebx
f0100d87:	5e                   	pop    %esi
f0100d88:	5d                   	pop    %ebp
f0100d89:	c3                   	ret    

f0100d8a <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100d8a:	55                   	push   %ebp
f0100d8b:	89 e5                	mov    %esp,%ebp
f0100d8d:	53                   	push   %ebx
f0100d8e:	83 ec 04             	sub    $0x4,%esp
    struct PageInfo *pp;
    char *kva;

    if (!page_free_list)
f0100d91:	8b 1d 40 ce 17 f0    	mov    0xf017ce40,%ebx
f0100d97:	85 db                	test   %ebx,%ebx
f0100d99:	74 58                	je     f0100df3 <page_alloc+0x69>
    {
        return NULL;
    }
    pp = page_free_list;
    page_free_list = page_free_list->pp_link;
f0100d9b:	8b 03                	mov    (%ebx),%eax
f0100d9d:	a3 40 ce 17 f0       	mov    %eax,0xf017ce40
    pp->pp_link = NULL;
f0100da2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    if (alloc_flags & ALLOC_ZERO)
f0100da8:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100dac:	74 45                	je     f0100df3 <page_alloc+0x69>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100dae:	89 d8                	mov    %ebx,%eax
f0100db0:	2b 05 0c db 17 f0    	sub    0xf017db0c,%eax
f0100db6:	c1 f8 03             	sar    $0x3,%eax
f0100db9:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100dbc:	89 c2                	mov    %eax,%edx
f0100dbe:	c1 ea 0c             	shr    $0xc,%edx
f0100dc1:	3b 15 04 db 17 f0    	cmp    0xf017db04,%edx
f0100dc7:	72 12                	jb     f0100ddb <page_alloc+0x51>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100dc9:	50                   	push   %eax
f0100dca:	68 24 4f 10 f0       	push   $0xf0104f24
f0100dcf:	6a 56                	push   $0x56
f0100dd1:	68 21 57 10 f0       	push   $0xf0105721
f0100dd6:	e8 01 f3 ff ff       	call   f01000dc <_panic>
    {
        kva = page2kva(pp);
        memset(kva, '\0', PGSIZE);
f0100ddb:	83 ec 04             	sub    $0x4,%esp
f0100dde:	68 00 10 00 00       	push   $0x1000
f0100de3:	6a 00                	push   $0x0
f0100de5:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100dea:	50                   	push   %eax
f0100deb:	e8 3f 37 00 00       	call   f010452f <memset>
f0100df0:	83 c4 10             	add    $0x10,%esp
    }

	// Fill this function in
	return pp;
}
f0100df3:	89 d8                	mov    %ebx,%eax
f0100df5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100df8:	c9                   	leave  
f0100df9:	c3                   	ret    

f0100dfa <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100dfa:	55                   	push   %ebp
f0100dfb:	89 e5                	mov    %esp,%ebp
f0100dfd:	83 ec 08             	sub    $0x8,%esp
f0100e00:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	if (pp->pp_ref != 0 || pp->pp_link != NULL)
f0100e03:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100e08:	75 05                	jne    f0100e0f <page_free+0x15>
f0100e0a:	83 38 00             	cmpl   $0x0,(%eax)
f0100e0d:	74 17                	je     f0100e26 <page_free+0x2c>
	{
	    panic("can't free page in use, or page in the free list");
f0100e0f:	83 ec 04             	sub    $0x4,%esp
f0100e12:	68 30 50 10 f0       	push   $0xf0105030
f0100e17:	68 85 01 00 00       	push   $0x185
f0100e1c:	68 15 57 10 f0       	push   $0xf0105715
f0100e21:	e8 b6 f2 ff ff       	call   f01000dc <_panic>
	}
	pp->pp_link = page_free_list;
f0100e26:	8b 15 40 ce 17 f0    	mov    0xf017ce40,%edx
f0100e2c:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0100e2e:	a3 40 ce 17 f0       	mov    %eax,0xf017ce40
}
f0100e33:	c9                   	leave  
f0100e34:	c3                   	ret    

f0100e35 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0100e35:	55                   	push   %ebp
f0100e36:	89 e5                	mov    %esp,%ebp
f0100e38:	83 ec 08             	sub    $0x8,%esp
f0100e3b:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0100e3e:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0100e42:	83 e8 01             	sub    $0x1,%eax
f0100e45:	66 89 42 04          	mov    %ax,0x4(%edx)
f0100e49:	66 85 c0             	test   %ax,%ax
f0100e4c:	75 0c                	jne    f0100e5a <page_decref+0x25>
		page_free(pp);
f0100e4e:	83 ec 0c             	sub    $0xc,%esp
f0100e51:	52                   	push   %edx
f0100e52:	e8 a3 ff ff ff       	call   f0100dfa <page_free>
f0100e57:	83 c4 10             	add    $0x10,%esp
}
f0100e5a:	c9                   	leave  
f0100e5b:	c3                   	ret    

f0100e5c <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0100e5c:	55                   	push   %ebp
f0100e5d:	89 e5                	mov    %esp,%ebp
f0100e5f:	57                   	push   %edi
f0100e60:	56                   	push   %esi
f0100e61:	53                   	push   %ebx
f0100e62:	83 ec 0c             	sub    $0xc,%esp
f0100e65:	8b 45 0c             	mov    0xc(%ebp),%eax

    uint32_t pdx = PDX(va);
    uint32_t ptx = PTX(va);
f0100e68:	89 c6                	mov    %eax,%esi
f0100e6a:	c1 ee 0c             	shr    $0xc,%esi
f0100e6d:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
    pde_t * pde;
    pte_t * pte;
    struct PageInfo *pp;

    pde = &pgdir[pdx];
f0100e73:	c1 e8 16             	shr    $0x16,%eax
f0100e76:	8d 1c 85 00 00 00 00 	lea    0x0(,%eax,4),%ebx
f0100e7d:	03 5d 08             	add    0x8(%ebp),%ebx
    if(*pde & PTE_P)
f0100e80:	8b 03                	mov    (%ebx),%eax
f0100e82:	a8 01                	test   $0x1,%al
f0100e84:	74 2f                	je     f0100eb5 <pgdir_walk+0x59>
    { 
        pte = (KADDR(PTE_ADDR(*pde)));
f0100e86:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100e8b:	89 c2                	mov    %eax,%edx
f0100e8d:	c1 ea 0c             	shr    $0xc,%edx
f0100e90:	39 15 04 db 17 f0    	cmp    %edx,0xf017db04
f0100e96:	77 15                	ja     f0100ead <pgdir_walk+0x51>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e98:	50                   	push   %eax
f0100e99:	68 24 4f 10 f0       	push   $0xf0104f24
f0100e9e:	68 b9 01 00 00       	push   $0x1b9
f0100ea3:	68 15 57 10 f0       	push   $0xf0105715
f0100ea8:	e8 2f f2 ff ff       	call   f01000dc <_panic>
	return (void *)(pa + KERNBASE);
f0100ead:	8d 90 00 00 00 f0    	lea    -0x10000000(%eax),%edx
f0100eb3:	eb 73                	jmp    f0100f28 <pgdir_walk+0xcc>
    }
    else
    {
        if (!create)
f0100eb5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0100eb9:	74 72                	je     f0100f2d <pgdir_walk+0xd1>
        {
            return NULL;
        }
        if(!(pp = page_alloc(ALLOC_ZERO)))
f0100ebb:	83 ec 0c             	sub    $0xc,%esp
f0100ebe:	6a 01                	push   $0x1
f0100ec0:	e8 c5 fe ff ff       	call   f0100d8a <page_alloc>
f0100ec5:	83 c4 10             	add    $0x10,%esp
f0100ec8:	85 c0                	test   %eax,%eax
f0100eca:	74 68                	je     f0100f34 <pgdir_walk+0xd8>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100ecc:	89 c1                	mov    %eax,%ecx
f0100ece:	2b 0d 0c db 17 f0    	sub    0xf017db0c,%ecx
f0100ed4:	c1 f9 03             	sar    $0x3,%ecx
f0100ed7:	c1 e1 0c             	shl    $0xc,%ecx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100eda:	89 ca                	mov    %ecx,%edx
f0100edc:	c1 ea 0c             	shr    $0xc,%edx
f0100edf:	3b 15 04 db 17 f0    	cmp    0xf017db04,%edx
f0100ee5:	72 12                	jb     f0100ef9 <pgdir_walk+0x9d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ee7:	51                   	push   %ecx
f0100ee8:	68 24 4f 10 f0       	push   $0xf0104f24
f0100eed:	6a 56                	push   $0x56
f0100eef:	68 21 57 10 f0       	push   $0xf0105721
f0100ef4:	e8 e3 f1 ff ff       	call   f01000dc <_panic>
	return (void *)(pa + KERNBASE);
f0100ef9:	8d b9 00 00 00 f0    	lea    -0x10000000(%ecx),%edi
f0100eff:	89 fa                	mov    %edi,%edx
        {
	return NULL;
}

        pte = (pte_t *)page2kva(pp);
        pp->pp_ref++;
f0100f01:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100f06:	81 ff ff ff ff ef    	cmp    $0xefffffff,%edi
f0100f0c:	77 15                	ja     f0100f23 <pgdir_walk+0xc7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100f0e:	57                   	push   %edi
f0100f0f:	68 0c 50 10 f0       	push   $0xf010500c
f0100f14:	68 c8 01 00 00       	push   $0x1c8
f0100f19:	68 15 57 10 f0       	push   $0xf0105715
f0100f1e:	e8 b9 f1 ff ff       	call   f01000dc <_panic>
        *pde = PADDR(pte) | PTE_P | PTE_W | PTE_U;
f0100f23:	83 c9 07             	or     $0x7,%ecx
f0100f26:	89 0b                	mov    %ecx,(%ebx)
    }   

    return &pte[ptx];
f0100f28:	8d 04 b2             	lea    (%edx,%esi,4),%eax
f0100f2b:	eb 0c                	jmp    f0100f39 <pgdir_walk+0xdd>
    }
    else
    {
        if (!create)
        {
            return NULL;
f0100f2d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f32:	eb 05                	jmp    f0100f39 <pgdir_walk+0xdd>
        }
        if(!(pp = page_alloc(ALLOC_ZERO)))
        {
	return NULL;
f0100f34:	b8 00 00 00 00       	mov    $0x0,%eax
        pp->pp_ref++;
        *pde = PADDR(pte) | PTE_P | PTE_W | PTE_U;
    }   

    return &pte[ptx];
}
f0100f39:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100f3c:	5b                   	pop    %ebx
f0100f3d:	5e                   	pop    %esi
f0100f3e:	5f                   	pop    %edi
f0100f3f:	5d                   	pop    %ebp
f0100f40:	c3                   	ret    

f0100f41 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0100f41:	55                   	push   %ebp
f0100f42:	89 e5                	mov    %esp,%ebp
f0100f44:	57                   	push   %edi
f0100f45:	56                   	push   %esi
f0100f46:	53                   	push   %ebx
f0100f47:	83 ec 1c             	sub    $0x1c,%esp
f0100f4a:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100f4d:	8b 45 08             	mov    0x8(%ebp),%eax
    uintptr_t pva = va;
    physaddr_t ppa = pa;
    pte_t *pte;
    size_t i, np;

    np = size/PGSIZE;
f0100f50:	c1 e9 0c             	shr    $0xc,%ecx
f0100f53:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
    uintptr_t pva = va;
    physaddr_t ppa = pa;
f0100f56:	89 c3                	mov    %eax,%ebx
    pte_t *pte;
    size_t i, np;

    np = size/PGSIZE;
    // can't use va+size as upper bound, may overflow    
    for (i = 0; i < np; i++)
f0100f58:	be 00 00 00 00       	mov    $0x0,%esi
    {
        pte = pgdir_walk(pgdir, (void *)pva, 1);
f0100f5d:	89 d7                	mov    %edx,%edi
f0100f5f:	29 c7                	sub    %eax,%edi
    pte_t *pte;
    size_t i, np;

    np = size/PGSIZE;
    // can't use va+size as upper bound, may overflow    
    for (i = 0; i < np; i++)
f0100f61:	eb 2e                	jmp    f0100f91 <boot_map_region+0x50>
    {
        pte = pgdir_walk(pgdir, (void *)pva, 1);
f0100f63:	83 ec 04             	sub    $0x4,%esp
f0100f66:	6a 01                	push   $0x1
f0100f68:	8d 04 1f             	lea    (%edi,%ebx,1),%eax
f0100f6b:	50                   	push   %eax
f0100f6c:	ff 75 e0             	pushl  -0x20(%ebp)
f0100f6f:	e8 e8 fe ff ff       	call   f0100e5c <pgdir_walk>
        if (!pte)
f0100f74:	83 c4 10             	add    $0x10,%esp
f0100f77:	85 c0                	test   %eax,%eax
f0100f79:	74 1b                	je     f0100f96 <boot_map_region+0x55>
        {
            return;
        }
        *pte = PTE_ADDR(ppa) | perm;
f0100f7b:	89 da                	mov    %ebx,%edx
f0100f7d:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100f83:	0b 55 0c             	or     0xc(%ebp),%edx
f0100f86:	89 10                	mov    %edx,(%eax)
        pva+=PGSIZE;
        ppa+=PGSIZE;
f0100f88:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    pte_t *pte;
    size_t i, np;

    np = size/PGSIZE;
    // can't use va+size as upper bound, may overflow    
    for (i = 0; i < np; i++)
f0100f8e:	83 c6 01             	add    $0x1,%esi
f0100f91:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f0100f94:	75 cd                	jne    f0100f63 <boot_map_region+0x22>
        }
        *pte = PTE_ADDR(ppa) | perm;
        pva+=PGSIZE;
        ppa+=PGSIZE;
    }
}
f0100f96:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100f99:	5b                   	pop    %ebx
f0100f9a:	5e                   	pop    %esi
f0100f9b:	5f                   	pop    %edi
f0100f9c:	5d                   	pop    %ebp
f0100f9d:	c3                   	ret    

f0100f9e <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0100f9e:	55                   	push   %ebp
f0100f9f:	89 e5                	mov    %esp,%ebp
f0100fa1:	53                   	push   %ebx
f0100fa2:	83 ec 08             	sub    $0x8,%esp
f0100fa5:	8b 5d 10             	mov    0x10(%ebp),%ebx
    pte_t * pte = pgdir_walk(pgdir, va, 0);
f0100fa8:	6a 00                	push   $0x0
f0100faa:	ff 75 0c             	pushl  0xc(%ebp)
f0100fad:	ff 75 08             	pushl  0x8(%ebp)
f0100fb0:	e8 a7 fe ff ff       	call   f0100e5c <pgdir_walk>

    if (!pte)
f0100fb5:	83 c4 10             	add    $0x10,%esp
f0100fb8:	85 c0                	test   %eax,%eax
f0100fba:	74 32                	je     f0100fee <page_lookup+0x50>
    {
        return NULL;
    }

    if (pte_store)
f0100fbc:	85 db                	test   %ebx,%ebx
f0100fbe:	74 02                	je     f0100fc2 <page_lookup+0x24>
    {
        *pte_store = pte;
f0100fc0:	89 03                	mov    %eax,(%ebx)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100fc2:	8b 00                	mov    (%eax),%eax
f0100fc4:	c1 e8 0c             	shr    $0xc,%eax
f0100fc7:	3b 05 04 db 17 f0    	cmp    0xf017db04,%eax
f0100fcd:	72 14                	jb     f0100fe3 <page_lookup+0x45>
		panic("pa2page called with invalid pa");
f0100fcf:	83 ec 04             	sub    $0x4,%esp
f0100fd2:	68 64 50 10 f0       	push   $0xf0105064
f0100fd7:	6a 4f                	push   $0x4f
f0100fd9:	68 21 57 10 f0       	push   $0xf0105721
f0100fde:	e8 f9 f0 ff ff       	call   f01000dc <_panic>
	return &pages[PGNUM(pa)];
f0100fe3:	8b 15 0c db 17 f0    	mov    0xf017db0c,%edx
f0100fe9:	8d 04 c2             	lea    (%edx,%eax,8),%eax
    }

    return pa2page(PTE_ADDR(*pte));
f0100fec:	eb 05                	jmp    f0100ff3 <page_lookup+0x55>
{
    pte_t * pte = pgdir_walk(pgdir, va, 0);

    if (!pte)
    {
        return NULL;
f0100fee:	b8 00 00 00 00       	mov    $0x0,%eax
    {
        *pte_store = pte;
    }

    return pa2page(PTE_ADDR(*pte));
}
f0100ff3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100ff6:	c9                   	leave  
f0100ff7:	c3                   	ret    

f0100ff8 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0100ff8:	55                   	push   %ebp
f0100ff9:	89 e5                	mov    %esp,%ebp
f0100ffb:	53                   	push   %ebx
f0100ffc:	83 ec 18             	sub    $0x18,%esp
f0100fff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    pte_t *pte;
    pte_t **pte_store = &pte;
    struct PageInfo *pp = page_lookup(pgdir, va, pte_store);
f0101002:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101005:	50                   	push   %eax
f0101006:	53                   	push   %ebx
f0101007:	ff 75 08             	pushl  0x8(%ebp)
f010100a:	e8 8f ff ff ff       	call   f0100f9e <page_lookup>
    if(!pp)
f010100f:	83 c4 10             	add    $0x10,%esp
f0101012:	85 c0                	test   %eax,%eax
f0101014:	74 18                	je     f010102e <page_remove+0x36>
        return;

    page_decref(pp);
f0101016:	83 ec 0c             	sub    $0xc,%esp
f0101019:	50                   	push   %eax
f010101a:	e8 16 fe ff ff       	call   f0100e35 <page_decref>

    **pte_store = 0;
f010101f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101022:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101028:	0f 01 3b             	invlpg (%ebx)
f010102b:	83 c4 10             	add    $0x10,%esp
    tlb_invalidate(pgdir, va);
}
f010102e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101031:	c9                   	leave  
f0101032:	c3                   	ret    

f0101033 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0101033:	55                   	push   %ebp
f0101034:	89 e5                	mov    %esp,%ebp
f0101036:	57                   	push   %edi
f0101037:	56                   	push   %esi
f0101038:	53                   	push   %ebx
f0101039:	83 ec 10             	sub    $0x10,%esp
f010103c:	8b 75 0c             	mov    0xc(%ebp),%esi
f010103f:	8b 7d 10             	mov    0x10(%ebp),%edi
    pte_t *pte = pgdir_walk(pgdir, va, 1);
f0101042:	6a 01                	push   $0x1
f0101044:	57                   	push   %edi
f0101045:	ff 75 08             	pushl  0x8(%ebp)
f0101048:	e8 0f fe ff ff       	call   f0100e5c <pgdir_walk>
    if (!pte)
f010104d:	83 c4 10             	add    $0x10,%esp
f0101050:	85 c0                	test   %eax,%eax
f0101052:	74 63                	je     f01010b7 <page_insert+0x84>
f0101054:	89 c3                	mov    %eax,%ebx
    {
        return -E_NO_MEM;
    }
    if (*pte & PTE_P)
f0101056:	8b 00                	mov    (%eax),%eax
f0101058:	a8 01                	test   $0x1,%al
f010105a:	74 37                	je     f0101093 <page_insert+0x60>
    {
        // reinsert same page to same va
        if (PTE_ADDR(*pte) == page2pa(pp))
f010105c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101061:	89 f2                	mov    %esi,%edx
f0101063:	2b 15 0c db 17 f0    	sub    0xf017db0c,%edx
f0101069:	c1 fa 03             	sar    $0x3,%edx
f010106c:	c1 e2 0c             	shl    $0xc,%edx
f010106f:	39 d0                	cmp    %edx,%eax
f0101071:	75 11                	jne    f0101084 <page_insert+0x51>
        {
            *pte = page2pa(pp) | (perm|PTE_P);
f0101073:	8b 55 14             	mov    0x14(%ebp),%edx
f0101076:	83 ca 01             	or     $0x1,%edx
f0101079:	09 d0                	or     %edx,%eax
f010107b:	89 03                	mov    %eax,(%ebx)
            return 0;
f010107d:	b8 00 00 00 00       	mov    $0x0,%eax
f0101082:	eb 38                	jmp    f01010bc <page_insert+0x89>
        }
        else
        {
            page_remove(pgdir, va);
f0101084:	83 ec 08             	sub    $0x8,%esp
f0101087:	57                   	push   %edi
f0101088:	ff 75 08             	pushl  0x8(%ebp)
f010108b:	e8 68 ff ff ff       	call   f0100ff8 <page_remove>
f0101090:	83 c4 10             	add    $0x10,%esp
        }
    }
    *pte = page2pa(pp) | perm | PTE_P;
f0101093:	89 f0                	mov    %esi,%eax
f0101095:	2b 05 0c db 17 f0    	sub    0xf017db0c,%eax
f010109b:	c1 f8 03             	sar    $0x3,%eax
f010109e:	c1 e0 0c             	shl    $0xc,%eax
f01010a1:	8b 55 14             	mov    0x14(%ebp),%edx
f01010a4:	83 ca 01             	or     $0x1,%edx
f01010a7:	09 d0                	or     %edx,%eax
f01010a9:	89 03                	mov    %eax,(%ebx)
    pp->pp_ref++;
f01010ab:	66 83 46 04 01       	addw   $0x1,0x4(%esi)

	return 0;
f01010b0:	b8 00 00 00 00       	mov    $0x0,%eax
f01010b5:	eb 05                	jmp    f01010bc <page_insert+0x89>
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
    pte_t *pte = pgdir_walk(pgdir, va, 1);
    if (!pte)
    {
        return -E_NO_MEM;
f01010b7:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
    }
    *pte = page2pa(pp) | perm | PTE_P;
    pp->pp_ref++;

	return 0;
}
f01010bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01010bf:	5b                   	pop    %ebx
f01010c0:	5e                   	pop    %esi
f01010c1:	5f                   	pop    %edi
f01010c2:	5d                   	pop    %ebp
f01010c3:	c3                   	ret    

f01010c4 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f01010c4:	55                   	push   %ebp
f01010c5:	89 e5                	mov    %esp,%ebp
f01010c7:	57                   	push   %edi
f01010c8:	56                   	push   %esi
f01010c9:	53                   	push   %ebx
f01010ca:	83 ec 38             	sub    $0x38,%esp
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f01010cd:	6a 15                	push   $0x15
f01010cf:	e8 bf 1e 00 00       	call   f0102f93 <mc146818_read>
f01010d4:	89 c3                	mov    %eax,%ebx
f01010d6:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f01010dd:	e8 b1 1e 00 00       	call   f0102f93 <mc146818_read>
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f01010e2:	c1 e0 08             	shl    $0x8,%eax
f01010e5:	09 d8                	or     %ebx,%eax
f01010e7:	c1 e0 0a             	shl    $0xa,%eax
f01010ea:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f01010f0:	85 c0                	test   %eax,%eax
f01010f2:	0f 48 c2             	cmovs  %edx,%eax
f01010f5:	c1 f8 0c             	sar    $0xc,%eax
f01010f8:	a3 44 ce 17 f0       	mov    %eax,0xf017ce44
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f01010fd:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f0101104:	e8 8a 1e 00 00       	call   f0102f93 <mc146818_read>
f0101109:	89 c3                	mov    %eax,%ebx
f010110b:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f0101112:	e8 7c 1e 00 00       	call   f0102f93 <mc146818_read>
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f0101117:	c1 e0 08             	shl    $0x8,%eax
f010111a:	09 d8                	or     %ebx,%eax
f010111c:	c1 e0 0a             	shl    $0xa,%eax
f010111f:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101125:	83 c4 10             	add    $0x10,%esp
f0101128:	85 c0                	test   %eax,%eax
f010112a:	0f 48 c2             	cmovs  %edx,%eax
f010112d:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f0101130:	85 c0                	test   %eax,%eax
f0101132:	74 0e                	je     f0101142 <mem_init+0x7e>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0101134:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f010113a:	89 15 04 db 17 f0    	mov    %edx,0xf017db04
f0101140:	eb 0c                	jmp    f010114e <mem_init+0x8a>
	else
		npages = npages_basemem;
f0101142:	8b 15 44 ce 17 f0    	mov    0xf017ce44,%edx
f0101148:	89 15 04 db 17 f0    	mov    %edx,0xf017db04

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010114e:	c1 e0 0c             	shl    $0xc,%eax
f0101151:	c1 e8 0a             	shr    $0xa,%eax
f0101154:	50                   	push   %eax
f0101155:	a1 44 ce 17 f0       	mov    0xf017ce44,%eax
f010115a:	c1 e0 0c             	shl    $0xc,%eax
f010115d:	c1 e8 0a             	shr    $0xa,%eax
f0101160:	50                   	push   %eax
f0101161:	a1 04 db 17 f0       	mov    0xf017db04,%eax
f0101166:	c1 e0 0c             	shl    $0xc,%eax
f0101169:	c1 e8 0a             	shr    $0xa,%eax
f010116c:	50                   	push   %eax
f010116d:	68 84 50 10 f0       	push   $0xf0105084
f0101172:	e8 83 1e 00 00       	call   f0102ffa <cprintf>
	// Remove this line when you're ready to test this function.
	// panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101177:	b8 00 10 00 00       	mov    $0x1000,%eax
f010117c:	e8 a3 f7 ff ff       	call   f0100924 <boot_alloc>
f0101181:	a3 08 db 17 f0       	mov    %eax,0xf017db08
	memset(kern_pgdir, 0, PGSIZE);
f0101186:	83 c4 0c             	add    $0xc,%esp
f0101189:	68 00 10 00 00       	push   $0x1000
f010118e:	6a 00                	push   $0x0
f0101190:	50                   	push   %eax
f0101191:	e8 99 33 00 00       	call   f010452f <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101196:	a1 08 db 17 f0       	mov    0xf017db08,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010119b:	83 c4 10             	add    $0x10,%esp
f010119e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01011a3:	77 15                	ja     f01011ba <mem_init+0xf6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01011a5:	50                   	push   %eax
f01011a6:	68 0c 50 10 f0       	push   $0xf010500c
f01011ab:	68 8f 00 00 00       	push   $0x8f
f01011b0:	68 15 57 10 f0       	push   $0xf0105715
f01011b5:	e8 22 ef ff ff       	call   f01000dc <_panic>
f01011ba:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01011c0:	83 ca 05             	or     $0x5,%edx
f01011c3:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:

    pages = (struct PageInfo*)boot_alloc(sizeof(struct PageInfo)*npages);
f01011c9:	a1 04 db 17 f0       	mov    0xf017db04,%eax
f01011ce:	c1 e0 03             	shl    $0x3,%eax
f01011d1:	e8 4e f7 ff ff       	call   f0100924 <boot_alloc>
f01011d6:	a3 0c db 17 f0       	mov    %eax,0xf017db0c
    memset(pages, 0, sizeof(struct PageInfo)*npages);
f01011db:	83 ec 04             	sub    $0x4,%esp
f01011de:	8b 3d 04 db 17 f0    	mov    0xf017db04,%edi
f01011e4:	8d 14 fd 00 00 00 00 	lea    0x0(,%edi,8),%edx
f01011eb:	52                   	push   %edx
f01011ec:	6a 00                	push   $0x0
f01011ee:	50                   	push   %eax
f01011ef:	e8 3b 33 00 00       	call   f010452f <memset>

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.

	envs = (struct Env*)boot_alloc(sizeof(struct Env)*NENV);
f01011f4:	b8 00 80 01 00       	mov    $0x18000,%eax
f01011f9:	e8 26 f7 ff ff       	call   f0100924 <boot_alloc>
f01011fe:	a3 4c ce 17 f0       	mov    %eax,0xf017ce4c
	memset(envs, 0, sizeof(struct Env)*NENV);
f0101203:	83 c4 0c             	add    $0xc,%esp
f0101206:	68 00 80 01 00       	push   $0x18000
f010120b:	6a 00                	push   $0x0
f010120d:	50                   	push   %eax
f010120e:	e8 1c 33 00 00       	call   f010452f <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0101213:	e8 5e fa ff ff       	call   f0100c76 <page_init>

	check_page_free_list(1);
f0101218:	b8 01 00 00 00       	mov    $0x1,%eax
f010121d:	e8 a0 f7 ff ff       	call   f01009c2 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0101222:	83 c4 10             	add    $0x10,%esp
f0101225:	83 3d 0c db 17 f0 00 	cmpl   $0x0,0xf017db0c
f010122c:	75 17                	jne    f0101245 <mem_init+0x181>
		panic("'pages' is a null pointer!");
f010122e:	83 ec 04             	sub    $0x4,%esp
f0101231:	68 cb 57 10 f0       	push   $0xf01057cb
f0101236:	68 04 03 00 00       	push   $0x304
f010123b:	68 15 57 10 f0       	push   $0xf0105715
f0101240:	e8 97 ee ff ff       	call   f01000dc <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101245:	a1 40 ce 17 f0       	mov    0xf017ce40,%eax
f010124a:	bb 00 00 00 00       	mov    $0x0,%ebx
f010124f:	eb 05                	jmp    f0101256 <mem_init+0x192>
		++nfree;
f0101251:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101254:	8b 00                	mov    (%eax),%eax
f0101256:	85 c0                	test   %eax,%eax
f0101258:	75 f7                	jne    f0101251 <mem_init+0x18d>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010125a:	83 ec 0c             	sub    $0xc,%esp
f010125d:	6a 00                	push   $0x0
f010125f:	e8 26 fb ff ff       	call   f0100d8a <page_alloc>
f0101264:	89 c7                	mov    %eax,%edi
f0101266:	83 c4 10             	add    $0x10,%esp
f0101269:	85 c0                	test   %eax,%eax
f010126b:	75 19                	jne    f0101286 <mem_init+0x1c2>
f010126d:	68 e6 57 10 f0       	push   $0xf01057e6
f0101272:	68 3b 57 10 f0       	push   $0xf010573b
f0101277:	68 0c 03 00 00       	push   $0x30c
f010127c:	68 15 57 10 f0       	push   $0xf0105715
f0101281:	e8 56 ee ff ff       	call   f01000dc <_panic>
	assert((pp1 = page_alloc(0)));
f0101286:	83 ec 0c             	sub    $0xc,%esp
f0101289:	6a 00                	push   $0x0
f010128b:	e8 fa fa ff ff       	call   f0100d8a <page_alloc>
f0101290:	89 c6                	mov    %eax,%esi
f0101292:	83 c4 10             	add    $0x10,%esp
f0101295:	85 c0                	test   %eax,%eax
f0101297:	75 19                	jne    f01012b2 <mem_init+0x1ee>
f0101299:	68 fc 57 10 f0       	push   $0xf01057fc
f010129e:	68 3b 57 10 f0       	push   $0xf010573b
f01012a3:	68 0d 03 00 00       	push   $0x30d
f01012a8:	68 15 57 10 f0       	push   $0xf0105715
f01012ad:	e8 2a ee ff ff       	call   f01000dc <_panic>
	assert((pp2 = page_alloc(0)));
f01012b2:	83 ec 0c             	sub    $0xc,%esp
f01012b5:	6a 00                	push   $0x0
f01012b7:	e8 ce fa ff ff       	call   f0100d8a <page_alloc>
f01012bc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01012bf:	83 c4 10             	add    $0x10,%esp
f01012c2:	85 c0                	test   %eax,%eax
f01012c4:	75 19                	jne    f01012df <mem_init+0x21b>
f01012c6:	68 12 58 10 f0       	push   $0xf0105812
f01012cb:	68 3b 57 10 f0       	push   $0xf010573b
f01012d0:	68 0e 03 00 00       	push   $0x30e
f01012d5:	68 15 57 10 f0       	push   $0xf0105715
f01012da:	e8 fd ed ff ff       	call   f01000dc <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01012df:	39 f7                	cmp    %esi,%edi
f01012e1:	75 19                	jne    f01012fc <mem_init+0x238>
f01012e3:	68 28 58 10 f0       	push   $0xf0105828
f01012e8:	68 3b 57 10 f0       	push   $0xf010573b
f01012ed:	68 11 03 00 00       	push   $0x311
f01012f2:	68 15 57 10 f0       	push   $0xf0105715
f01012f7:	e8 e0 ed ff ff       	call   f01000dc <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01012fc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01012ff:	39 c6                	cmp    %eax,%esi
f0101301:	74 04                	je     f0101307 <mem_init+0x243>
f0101303:	39 c7                	cmp    %eax,%edi
f0101305:	75 19                	jne    f0101320 <mem_init+0x25c>
f0101307:	68 c0 50 10 f0       	push   $0xf01050c0
f010130c:	68 3b 57 10 f0       	push   $0xf010573b
f0101311:	68 12 03 00 00       	push   $0x312
f0101316:	68 15 57 10 f0       	push   $0xf0105715
f010131b:	e8 bc ed ff ff       	call   f01000dc <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101320:	8b 0d 0c db 17 f0    	mov    0xf017db0c,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101326:	8b 15 04 db 17 f0    	mov    0xf017db04,%edx
f010132c:	c1 e2 0c             	shl    $0xc,%edx
f010132f:	89 f8                	mov    %edi,%eax
f0101331:	29 c8                	sub    %ecx,%eax
f0101333:	c1 f8 03             	sar    $0x3,%eax
f0101336:	c1 e0 0c             	shl    $0xc,%eax
f0101339:	39 d0                	cmp    %edx,%eax
f010133b:	72 19                	jb     f0101356 <mem_init+0x292>
f010133d:	68 3a 58 10 f0       	push   $0xf010583a
f0101342:	68 3b 57 10 f0       	push   $0xf010573b
f0101347:	68 13 03 00 00       	push   $0x313
f010134c:	68 15 57 10 f0       	push   $0xf0105715
f0101351:	e8 86 ed ff ff       	call   f01000dc <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101356:	89 f0                	mov    %esi,%eax
f0101358:	29 c8                	sub    %ecx,%eax
f010135a:	c1 f8 03             	sar    $0x3,%eax
f010135d:	c1 e0 0c             	shl    $0xc,%eax
f0101360:	39 c2                	cmp    %eax,%edx
f0101362:	77 19                	ja     f010137d <mem_init+0x2b9>
f0101364:	68 57 58 10 f0       	push   $0xf0105857
f0101369:	68 3b 57 10 f0       	push   $0xf010573b
f010136e:	68 14 03 00 00       	push   $0x314
f0101373:	68 15 57 10 f0       	push   $0xf0105715
f0101378:	e8 5f ed ff ff       	call   f01000dc <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f010137d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101380:	29 c8                	sub    %ecx,%eax
f0101382:	c1 f8 03             	sar    $0x3,%eax
f0101385:	c1 e0 0c             	shl    $0xc,%eax
f0101388:	39 c2                	cmp    %eax,%edx
f010138a:	77 19                	ja     f01013a5 <mem_init+0x2e1>
f010138c:	68 74 58 10 f0       	push   $0xf0105874
f0101391:	68 3b 57 10 f0       	push   $0xf010573b
f0101396:	68 15 03 00 00       	push   $0x315
f010139b:	68 15 57 10 f0       	push   $0xf0105715
f01013a0:	e8 37 ed ff ff       	call   f01000dc <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01013a5:	a1 40 ce 17 f0       	mov    0xf017ce40,%eax
f01013aa:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01013ad:	c7 05 40 ce 17 f0 00 	movl   $0x0,0xf017ce40
f01013b4:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01013b7:	83 ec 0c             	sub    $0xc,%esp
f01013ba:	6a 00                	push   $0x0
f01013bc:	e8 c9 f9 ff ff       	call   f0100d8a <page_alloc>
f01013c1:	83 c4 10             	add    $0x10,%esp
f01013c4:	85 c0                	test   %eax,%eax
f01013c6:	74 19                	je     f01013e1 <mem_init+0x31d>
f01013c8:	68 91 58 10 f0       	push   $0xf0105891
f01013cd:	68 3b 57 10 f0       	push   $0xf010573b
f01013d2:	68 1c 03 00 00       	push   $0x31c
f01013d7:	68 15 57 10 f0       	push   $0xf0105715
f01013dc:	e8 fb ec ff ff       	call   f01000dc <_panic>

	// free and re-allocate?
	page_free(pp0);
f01013e1:	83 ec 0c             	sub    $0xc,%esp
f01013e4:	57                   	push   %edi
f01013e5:	e8 10 fa ff ff       	call   f0100dfa <page_free>
	page_free(pp1);
f01013ea:	89 34 24             	mov    %esi,(%esp)
f01013ed:	e8 08 fa ff ff       	call   f0100dfa <page_free>
	page_free(pp2);
f01013f2:	83 c4 04             	add    $0x4,%esp
f01013f5:	ff 75 d4             	pushl  -0x2c(%ebp)
f01013f8:	e8 fd f9 ff ff       	call   f0100dfa <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01013fd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101404:	e8 81 f9 ff ff       	call   f0100d8a <page_alloc>
f0101409:	89 c6                	mov    %eax,%esi
f010140b:	83 c4 10             	add    $0x10,%esp
f010140e:	85 c0                	test   %eax,%eax
f0101410:	75 19                	jne    f010142b <mem_init+0x367>
f0101412:	68 e6 57 10 f0       	push   $0xf01057e6
f0101417:	68 3b 57 10 f0       	push   $0xf010573b
f010141c:	68 23 03 00 00       	push   $0x323
f0101421:	68 15 57 10 f0       	push   $0xf0105715
f0101426:	e8 b1 ec ff ff       	call   f01000dc <_panic>
	assert((pp1 = page_alloc(0)));
f010142b:	83 ec 0c             	sub    $0xc,%esp
f010142e:	6a 00                	push   $0x0
f0101430:	e8 55 f9 ff ff       	call   f0100d8a <page_alloc>
f0101435:	89 c7                	mov    %eax,%edi
f0101437:	83 c4 10             	add    $0x10,%esp
f010143a:	85 c0                	test   %eax,%eax
f010143c:	75 19                	jne    f0101457 <mem_init+0x393>
f010143e:	68 fc 57 10 f0       	push   $0xf01057fc
f0101443:	68 3b 57 10 f0       	push   $0xf010573b
f0101448:	68 24 03 00 00       	push   $0x324
f010144d:	68 15 57 10 f0       	push   $0xf0105715
f0101452:	e8 85 ec ff ff       	call   f01000dc <_panic>
	assert((pp2 = page_alloc(0)));
f0101457:	83 ec 0c             	sub    $0xc,%esp
f010145a:	6a 00                	push   $0x0
f010145c:	e8 29 f9 ff ff       	call   f0100d8a <page_alloc>
f0101461:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101464:	83 c4 10             	add    $0x10,%esp
f0101467:	85 c0                	test   %eax,%eax
f0101469:	75 19                	jne    f0101484 <mem_init+0x3c0>
f010146b:	68 12 58 10 f0       	push   $0xf0105812
f0101470:	68 3b 57 10 f0       	push   $0xf010573b
f0101475:	68 25 03 00 00       	push   $0x325
f010147a:	68 15 57 10 f0       	push   $0xf0105715
f010147f:	e8 58 ec ff ff       	call   f01000dc <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101484:	39 fe                	cmp    %edi,%esi
f0101486:	75 19                	jne    f01014a1 <mem_init+0x3dd>
f0101488:	68 28 58 10 f0       	push   $0xf0105828
f010148d:	68 3b 57 10 f0       	push   $0xf010573b
f0101492:	68 27 03 00 00       	push   $0x327
f0101497:	68 15 57 10 f0       	push   $0xf0105715
f010149c:	e8 3b ec ff ff       	call   f01000dc <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01014a1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01014a4:	39 c7                	cmp    %eax,%edi
f01014a6:	74 04                	je     f01014ac <mem_init+0x3e8>
f01014a8:	39 c6                	cmp    %eax,%esi
f01014aa:	75 19                	jne    f01014c5 <mem_init+0x401>
f01014ac:	68 c0 50 10 f0       	push   $0xf01050c0
f01014b1:	68 3b 57 10 f0       	push   $0xf010573b
f01014b6:	68 28 03 00 00       	push   $0x328
f01014bb:	68 15 57 10 f0       	push   $0xf0105715
f01014c0:	e8 17 ec ff ff       	call   f01000dc <_panic>
	assert(!page_alloc(0));
f01014c5:	83 ec 0c             	sub    $0xc,%esp
f01014c8:	6a 00                	push   $0x0
f01014ca:	e8 bb f8 ff ff       	call   f0100d8a <page_alloc>
f01014cf:	83 c4 10             	add    $0x10,%esp
f01014d2:	85 c0                	test   %eax,%eax
f01014d4:	74 19                	je     f01014ef <mem_init+0x42b>
f01014d6:	68 91 58 10 f0       	push   $0xf0105891
f01014db:	68 3b 57 10 f0       	push   $0xf010573b
f01014e0:	68 29 03 00 00       	push   $0x329
f01014e5:	68 15 57 10 f0       	push   $0xf0105715
f01014ea:	e8 ed eb ff ff       	call   f01000dc <_panic>
f01014ef:	89 f0                	mov    %esi,%eax
f01014f1:	2b 05 0c db 17 f0    	sub    0xf017db0c,%eax
f01014f7:	c1 f8 03             	sar    $0x3,%eax
f01014fa:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01014fd:	89 c2                	mov    %eax,%edx
f01014ff:	c1 ea 0c             	shr    $0xc,%edx
f0101502:	3b 15 04 db 17 f0    	cmp    0xf017db04,%edx
f0101508:	72 12                	jb     f010151c <mem_init+0x458>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010150a:	50                   	push   %eax
f010150b:	68 24 4f 10 f0       	push   $0xf0104f24
f0101510:	6a 56                	push   $0x56
f0101512:	68 21 57 10 f0       	push   $0xf0105721
f0101517:	e8 c0 eb ff ff       	call   f01000dc <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f010151c:	83 ec 04             	sub    $0x4,%esp
f010151f:	68 00 10 00 00       	push   $0x1000
f0101524:	6a 01                	push   $0x1
f0101526:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010152b:	50                   	push   %eax
f010152c:	e8 fe 2f 00 00       	call   f010452f <memset>
	page_free(pp0);
f0101531:	89 34 24             	mov    %esi,(%esp)
f0101534:	e8 c1 f8 ff ff       	call   f0100dfa <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101539:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101540:	e8 45 f8 ff ff       	call   f0100d8a <page_alloc>
f0101545:	83 c4 10             	add    $0x10,%esp
f0101548:	85 c0                	test   %eax,%eax
f010154a:	75 19                	jne    f0101565 <mem_init+0x4a1>
f010154c:	68 a0 58 10 f0       	push   $0xf01058a0
f0101551:	68 3b 57 10 f0       	push   $0xf010573b
f0101556:	68 2e 03 00 00       	push   $0x32e
f010155b:	68 15 57 10 f0       	push   $0xf0105715
f0101560:	e8 77 eb ff ff       	call   f01000dc <_panic>
	assert(pp && pp0 == pp);
f0101565:	39 c6                	cmp    %eax,%esi
f0101567:	74 19                	je     f0101582 <mem_init+0x4be>
f0101569:	68 be 58 10 f0       	push   $0xf01058be
f010156e:	68 3b 57 10 f0       	push   $0xf010573b
f0101573:	68 2f 03 00 00       	push   $0x32f
f0101578:	68 15 57 10 f0       	push   $0xf0105715
f010157d:	e8 5a eb ff ff       	call   f01000dc <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101582:	89 f0                	mov    %esi,%eax
f0101584:	2b 05 0c db 17 f0    	sub    0xf017db0c,%eax
f010158a:	c1 f8 03             	sar    $0x3,%eax
f010158d:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101590:	89 c2                	mov    %eax,%edx
f0101592:	c1 ea 0c             	shr    $0xc,%edx
f0101595:	3b 15 04 db 17 f0    	cmp    0xf017db04,%edx
f010159b:	72 12                	jb     f01015af <mem_init+0x4eb>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010159d:	50                   	push   %eax
f010159e:	68 24 4f 10 f0       	push   $0xf0104f24
f01015a3:	6a 56                	push   $0x56
f01015a5:	68 21 57 10 f0       	push   $0xf0105721
f01015aa:	e8 2d eb ff ff       	call   f01000dc <_panic>
f01015af:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f01015b5:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f01015bb:	80 38 00             	cmpb   $0x0,(%eax)
f01015be:	74 19                	je     f01015d9 <mem_init+0x515>
f01015c0:	68 ce 58 10 f0       	push   $0xf01058ce
f01015c5:	68 3b 57 10 f0       	push   $0xf010573b
f01015ca:	68 32 03 00 00       	push   $0x332
f01015cf:	68 15 57 10 f0       	push   $0xf0105715
f01015d4:	e8 03 eb ff ff       	call   f01000dc <_panic>
f01015d9:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f01015dc:	39 d0                	cmp    %edx,%eax
f01015de:	75 db                	jne    f01015bb <mem_init+0x4f7>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f01015e0:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01015e3:	a3 40 ce 17 f0       	mov    %eax,0xf017ce40

	// free the pages we took
	page_free(pp0);
f01015e8:	83 ec 0c             	sub    $0xc,%esp
f01015eb:	56                   	push   %esi
f01015ec:	e8 09 f8 ff ff       	call   f0100dfa <page_free>
	page_free(pp1);
f01015f1:	89 3c 24             	mov    %edi,(%esp)
f01015f4:	e8 01 f8 ff ff       	call   f0100dfa <page_free>
	page_free(pp2);
f01015f9:	83 c4 04             	add    $0x4,%esp
f01015fc:	ff 75 d4             	pushl  -0x2c(%ebp)
f01015ff:	e8 f6 f7 ff ff       	call   f0100dfa <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101604:	a1 40 ce 17 f0       	mov    0xf017ce40,%eax
f0101609:	83 c4 10             	add    $0x10,%esp
f010160c:	eb 05                	jmp    f0101613 <mem_init+0x54f>
		--nfree;
f010160e:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101611:	8b 00                	mov    (%eax),%eax
f0101613:	85 c0                	test   %eax,%eax
f0101615:	75 f7                	jne    f010160e <mem_init+0x54a>
		--nfree;
	assert(nfree == 0);
f0101617:	85 db                	test   %ebx,%ebx
f0101619:	74 19                	je     f0101634 <mem_init+0x570>
f010161b:	68 d8 58 10 f0       	push   $0xf01058d8
f0101620:	68 3b 57 10 f0       	push   $0xf010573b
f0101625:	68 3f 03 00 00       	push   $0x33f
f010162a:	68 15 57 10 f0       	push   $0xf0105715
f010162f:	e8 a8 ea ff ff       	call   f01000dc <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101634:	83 ec 0c             	sub    $0xc,%esp
f0101637:	68 e0 50 10 f0       	push   $0xf01050e0
f010163c:	e8 b9 19 00 00       	call   f0102ffa <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101641:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101648:	e8 3d f7 ff ff       	call   f0100d8a <page_alloc>
f010164d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101650:	83 c4 10             	add    $0x10,%esp
f0101653:	85 c0                	test   %eax,%eax
f0101655:	75 19                	jne    f0101670 <mem_init+0x5ac>
f0101657:	68 e6 57 10 f0       	push   $0xf01057e6
f010165c:	68 3b 57 10 f0       	push   $0xf010573b
f0101661:	68 9d 03 00 00       	push   $0x39d
f0101666:	68 15 57 10 f0       	push   $0xf0105715
f010166b:	e8 6c ea ff ff       	call   f01000dc <_panic>
	assert((pp1 = page_alloc(0)));
f0101670:	83 ec 0c             	sub    $0xc,%esp
f0101673:	6a 00                	push   $0x0
f0101675:	e8 10 f7 ff ff       	call   f0100d8a <page_alloc>
f010167a:	89 c3                	mov    %eax,%ebx
f010167c:	83 c4 10             	add    $0x10,%esp
f010167f:	85 c0                	test   %eax,%eax
f0101681:	75 19                	jne    f010169c <mem_init+0x5d8>
f0101683:	68 fc 57 10 f0       	push   $0xf01057fc
f0101688:	68 3b 57 10 f0       	push   $0xf010573b
f010168d:	68 9e 03 00 00       	push   $0x39e
f0101692:	68 15 57 10 f0       	push   $0xf0105715
f0101697:	e8 40 ea ff ff       	call   f01000dc <_panic>
	assert((pp2 = page_alloc(0)));
f010169c:	83 ec 0c             	sub    $0xc,%esp
f010169f:	6a 00                	push   $0x0
f01016a1:	e8 e4 f6 ff ff       	call   f0100d8a <page_alloc>
f01016a6:	89 c6                	mov    %eax,%esi
f01016a8:	83 c4 10             	add    $0x10,%esp
f01016ab:	85 c0                	test   %eax,%eax
f01016ad:	75 19                	jne    f01016c8 <mem_init+0x604>
f01016af:	68 12 58 10 f0       	push   $0xf0105812
f01016b4:	68 3b 57 10 f0       	push   $0xf010573b
f01016b9:	68 9f 03 00 00       	push   $0x39f
f01016be:	68 15 57 10 f0       	push   $0xf0105715
f01016c3:	e8 14 ea ff ff       	call   f01000dc <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01016c8:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f01016cb:	75 19                	jne    f01016e6 <mem_init+0x622>
f01016cd:	68 28 58 10 f0       	push   $0xf0105828
f01016d2:	68 3b 57 10 f0       	push   $0xf010573b
f01016d7:	68 a2 03 00 00       	push   $0x3a2
f01016dc:	68 15 57 10 f0       	push   $0xf0105715
f01016e1:	e8 f6 e9 ff ff       	call   f01000dc <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01016e6:	39 c3                	cmp    %eax,%ebx
f01016e8:	74 05                	je     f01016ef <mem_init+0x62b>
f01016ea:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f01016ed:	75 19                	jne    f0101708 <mem_init+0x644>
f01016ef:	68 c0 50 10 f0       	push   $0xf01050c0
f01016f4:	68 3b 57 10 f0       	push   $0xf010573b
f01016f9:	68 a3 03 00 00       	push   $0x3a3
f01016fe:	68 15 57 10 f0       	push   $0xf0105715
f0101703:	e8 d4 e9 ff ff       	call   f01000dc <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101708:	a1 40 ce 17 f0       	mov    0xf017ce40,%eax
f010170d:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101710:	c7 05 40 ce 17 f0 00 	movl   $0x0,0xf017ce40
f0101717:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f010171a:	83 ec 0c             	sub    $0xc,%esp
f010171d:	6a 00                	push   $0x0
f010171f:	e8 66 f6 ff ff       	call   f0100d8a <page_alloc>
f0101724:	83 c4 10             	add    $0x10,%esp
f0101727:	85 c0                	test   %eax,%eax
f0101729:	74 19                	je     f0101744 <mem_init+0x680>
f010172b:	68 91 58 10 f0       	push   $0xf0105891
f0101730:	68 3b 57 10 f0       	push   $0xf010573b
f0101735:	68 aa 03 00 00       	push   $0x3aa
f010173a:	68 15 57 10 f0       	push   $0xf0105715
f010173f:	e8 98 e9 ff ff       	call   f01000dc <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101744:	83 ec 04             	sub    $0x4,%esp
f0101747:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010174a:	50                   	push   %eax
f010174b:	6a 00                	push   $0x0
f010174d:	ff 35 08 db 17 f0    	pushl  0xf017db08
f0101753:	e8 46 f8 ff ff       	call   f0100f9e <page_lookup>
f0101758:	83 c4 10             	add    $0x10,%esp
f010175b:	85 c0                	test   %eax,%eax
f010175d:	74 19                	je     f0101778 <mem_init+0x6b4>
f010175f:	68 00 51 10 f0       	push   $0xf0105100
f0101764:	68 3b 57 10 f0       	push   $0xf010573b
f0101769:	68 ad 03 00 00       	push   $0x3ad
f010176e:	68 15 57 10 f0       	push   $0xf0105715
f0101773:	e8 64 e9 ff ff       	call   f01000dc <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101778:	6a 02                	push   $0x2
f010177a:	6a 00                	push   $0x0
f010177c:	53                   	push   %ebx
f010177d:	ff 35 08 db 17 f0    	pushl  0xf017db08
f0101783:	e8 ab f8 ff ff       	call   f0101033 <page_insert>
f0101788:	83 c4 10             	add    $0x10,%esp
f010178b:	85 c0                	test   %eax,%eax
f010178d:	78 19                	js     f01017a8 <mem_init+0x6e4>
f010178f:	68 38 51 10 f0       	push   $0xf0105138
f0101794:	68 3b 57 10 f0       	push   $0xf010573b
f0101799:	68 b0 03 00 00       	push   $0x3b0
f010179e:	68 15 57 10 f0       	push   $0xf0105715
f01017a3:	e8 34 e9 ff ff       	call   f01000dc <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f01017a8:	83 ec 0c             	sub    $0xc,%esp
f01017ab:	ff 75 d4             	pushl  -0x2c(%ebp)
f01017ae:	e8 47 f6 ff ff       	call   f0100dfa <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01017b3:	6a 02                	push   $0x2
f01017b5:	6a 00                	push   $0x0
f01017b7:	53                   	push   %ebx
f01017b8:	ff 35 08 db 17 f0    	pushl  0xf017db08
f01017be:	e8 70 f8 ff ff       	call   f0101033 <page_insert>
f01017c3:	83 c4 20             	add    $0x20,%esp
f01017c6:	85 c0                	test   %eax,%eax
f01017c8:	74 19                	je     f01017e3 <mem_init+0x71f>
f01017ca:	68 68 51 10 f0       	push   $0xf0105168
f01017cf:	68 3b 57 10 f0       	push   $0xf010573b
f01017d4:	68 b4 03 00 00       	push   $0x3b4
f01017d9:	68 15 57 10 f0       	push   $0xf0105715
f01017de:	e8 f9 e8 ff ff       	call   f01000dc <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01017e3:	8b 3d 08 db 17 f0    	mov    0xf017db08,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01017e9:	a1 0c db 17 f0       	mov    0xf017db0c,%eax
f01017ee:	89 c1                	mov    %eax,%ecx
f01017f0:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01017f3:	8b 17                	mov    (%edi),%edx
f01017f5:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01017fb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01017fe:	29 c8                	sub    %ecx,%eax
f0101800:	c1 f8 03             	sar    $0x3,%eax
f0101803:	c1 e0 0c             	shl    $0xc,%eax
f0101806:	39 c2                	cmp    %eax,%edx
f0101808:	74 19                	je     f0101823 <mem_init+0x75f>
f010180a:	68 98 51 10 f0       	push   $0xf0105198
f010180f:	68 3b 57 10 f0       	push   $0xf010573b
f0101814:	68 b5 03 00 00       	push   $0x3b5
f0101819:	68 15 57 10 f0       	push   $0xf0105715
f010181e:	e8 b9 e8 ff ff       	call   f01000dc <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101823:	ba 00 00 00 00       	mov    $0x0,%edx
f0101828:	89 f8                	mov    %edi,%eax
f010182a:	e8 2f f1 ff ff       	call   f010095e <check_va2pa>
f010182f:	89 da                	mov    %ebx,%edx
f0101831:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101834:	c1 fa 03             	sar    $0x3,%edx
f0101837:	c1 e2 0c             	shl    $0xc,%edx
f010183a:	39 d0                	cmp    %edx,%eax
f010183c:	74 19                	je     f0101857 <mem_init+0x793>
f010183e:	68 c0 51 10 f0       	push   $0xf01051c0
f0101843:	68 3b 57 10 f0       	push   $0xf010573b
f0101848:	68 b6 03 00 00       	push   $0x3b6
f010184d:	68 15 57 10 f0       	push   $0xf0105715
f0101852:	e8 85 e8 ff ff       	call   f01000dc <_panic>
	assert(pp1->pp_ref == 1);
f0101857:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010185c:	74 19                	je     f0101877 <mem_init+0x7b3>
f010185e:	68 e3 58 10 f0       	push   $0xf01058e3
f0101863:	68 3b 57 10 f0       	push   $0xf010573b
f0101868:	68 b7 03 00 00       	push   $0x3b7
f010186d:	68 15 57 10 f0       	push   $0xf0105715
f0101872:	e8 65 e8 ff ff       	call   f01000dc <_panic>
	assert(pp0->pp_ref == 1);
f0101877:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010187a:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f010187f:	74 19                	je     f010189a <mem_init+0x7d6>
f0101881:	68 f4 58 10 f0       	push   $0xf01058f4
f0101886:	68 3b 57 10 f0       	push   $0xf010573b
f010188b:	68 b8 03 00 00       	push   $0x3b8
f0101890:	68 15 57 10 f0       	push   $0xf0105715
f0101895:	e8 42 e8 ff ff       	call   f01000dc <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010189a:	6a 02                	push   $0x2
f010189c:	68 00 10 00 00       	push   $0x1000
f01018a1:	56                   	push   %esi
f01018a2:	57                   	push   %edi
f01018a3:	e8 8b f7 ff ff       	call   f0101033 <page_insert>
f01018a8:	83 c4 10             	add    $0x10,%esp
f01018ab:	85 c0                	test   %eax,%eax
f01018ad:	74 19                	je     f01018c8 <mem_init+0x804>
f01018af:	68 f0 51 10 f0       	push   $0xf01051f0
f01018b4:	68 3b 57 10 f0       	push   $0xf010573b
f01018b9:	68 bb 03 00 00       	push   $0x3bb
f01018be:	68 15 57 10 f0       	push   $0xf0105715
f01018c3:	e8 14 e8 ff ff       	call   f01000dc <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01018c8:	ba 00 10 00 00       	mov    $0x1000,%edx
f01018cd:	a1 08 db 17 f0       	mov    0xf017db08,%eax
f01018d2:	e8 87 f0 ff ff       	call   f010095e <check_va2pa>
f01018d7:	89 f2                	mov    %esi,%edx
f01018d9:	2b 15 0c db 17 f0    	sub    0xf017db0c,%edx
f01018df:	c1 fa 03             	sar    $0x3,%edx
f01018e2:	c1 e2 0c             	shl    $0xc,%edx
f01018e5:	39 d0                	cmp    %edx,%eax
f01018e7:	74 19                	je     f0101902 <mem_init+0x83e>
f01018e9:	68 2c 52 10 f0       	push   $0xf010522c
f01018ee:	68 3b 57 10 f0       	push   $0xf010573b
f01018f3:	68 bc 03 00 00       	push   $0x3bc
f01018f8:	68 15 57 10 f0       	push   $0xf0105715
f01018fd:	e8 da e7 ff ff       	call   f01000dc <_panic>
	assert(pp2->pp_ref == 1);
f0101902:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101907:	74 19                	je     f0101922 <mem_init+0x85e>
f0101909:	68 05 59 10 f0       	push   $0xf0105905
f010190e:	68 3b 57 10 f0       	push   $0xf010573b
f0101913:	68 bd 03 00 00       	push   $0x3bd
f0101918:	68 15 57 10 f0       	push   $0xf0105715
f010191d:	e8 ba e7 ff ff       	call   f01000dc <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101922:	83 ec 0c             	sub    $0xc,%esp
f0101925:	6a 00                	push   $0x0
f0101927:	e8 5e f4 ff ff       	call   f0100d8a <page_alloc>
f010192c:	83 c4 10             	add    $0x10,%esp
f010192f:	85 c0                	test   %eax,%eax
f0101931:	74 19                	je     f010194c <mem_init+0x888>
f0101933:	68 91 58 10 f0       	push   $0xf0105891
f0101938:	68 3b 57 10 f0       	push   $0xf010573b
f010193d:	68 c0 03 00 00       	push   $0x3c0
f0101942:	68 15 57 10 f0       	push   $0xf0105715
f0101947:	e8 90 e7 ff ff       	call   f01000dc <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010194c:	6a 02                	push   $0x2
f010194e:	68 00 10 00 00       	push   $0x1000
f0101953:	56                   	push   %esi
f0101954:	ff 35 08 db 17 f0    	pushl  0xf017db08
f010195a:	e8 d4 f6 ff ff       	call   f0101033 <page_insert>
f010195f:	83 c4 10             	add    $0x10,%esp
f0101962:	85 c0                	test   %eax,%eax
f0101964:	74 19                	je     f010197f <mem_init+0x8bb>
f0101966:	68 f0 51 10 f0       	push   $0xf01051f0
f010196b:	68 3b 57 10 f0       	push   $0xf010573b
f0101970:	68 c3 03 00 00       	push   $0x3c3
f0101975:	68 15 57 10 f0       	push   $0xf0105715
f010197a:	e8 5d e7 ff ff       	call   f01000dc <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010197f:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101984:	a1 08 db 17 f0       	mov    0xf017db08,%eax
f0101989:	e8 d0 ef ff ff       	call   f010095e <check_va2pa>
f010198e:	89 f2                	mov    %esi,%edx
f0101990:	2b 15 0c db 17 f0    	sub    0xf017db0c,%edx
f0101996:	c1 fa 03             	sar    $0x3,%edx
f0101999:	c1 e2 0c             	shl    $0xc,%edx
f010199c:	39 d0                	cmp    %edx,%eax
f010199e:	74 19                	je     f01019b9 <mem_init+0x8f5>
f01019a0:	68 2c 52 10 f0       	push   $0xf010522c
f01019a5:	68 3b 57 10 f0       	push   $0xf010573b
f01019aa:	68 c4 03 00 00       	push   $0x3c4
f01019af:	68 15 57 10 f0       	push   $0xf0105715
f01019b4:	e8 23 e7 ff ff       	call   f01000dc <_panic>
	assert(pp2->pp_ref == 1);
f01019b9:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01019be:	74 19                	je     f01019d9 <mem_init+0x915>
f01019c0:	68 05 59 10 f0       	push   $0xf0105905
f01019c5:	68 3b 57 10 f0       	push   $0xf010573b
f01019ca:	68 c5 03 00 00       	push   $0x3c5
f01019cf:	68 15 57 10 f0       	push   $0xf0105715
f01019d4:	e8 03 e7 ff ff       	call   f01000dc <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f01019d9:	83 ec 0c             	sub    $0xc,%esp
f01019dc:	6a 00                	push   $0x0
f01019de:	e8 a7 f3 ff ff       	call   f0100d8a <page_alloc>
f01019e3:	83 c4 10             	add    $0x10,%esp
f01019e6:	85 c0                	test   %eax,%eax
f01019e8:	74 19                	je     f0101a03 <mem_init+0x93f>
f01019ea:	68 91 58 10 f0       	push   $0xf0105891
f01019ef:	68 3b 57 10 f0       	push   $0xf010573b
f01019f4:	68 c9 03 00 00       	push   $0x3c9
f01019f9:	68 15 57 10 f0       	push   $0xf0105715
f01019fe:	e8 d9 e6 ff ff       	call   f01000dc <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101a03:	8b 15 08 db 17 f0    	mov    0xf017db08,%edx
f0101a09:	8b 02                	mov    (%edx),%eax
f0101a0b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101a10:	89 c1                	mov    %eax,%ecx
f0101a12:	c1 e9 0c             	shr    $0xc,%ecx
f0101a15:	3b 0d 04 db 17 f0    	cmp    0xf017db04,%ecx
f0101a1b:	72 15                	jb     f0101a32 <mem_init+0x96e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101a1d:	50                   	push   %eax
f0101a1e:	68 24 4f 10 f0       	push   $0xf0104f24
f0101a23:	68 cc 03 00 00       	push   $0x3cc
f0101a28:	68 15 57 10 f0       	push   $0xf0105715
f0101a2d:	e8 aa e6 ff ff       	call   f01000dc <_panic>
f0101a32:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101a37:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101a3a:	83 ec 04             	sub    $0x4,%esp
f0101a3d:	6a 00                	push   $0x0
f0101a3f:	68 00 10 00 00       	push   $0x1000
f0101a44:	52                   	push   %edx
f0101a45:	e8 12 f4 ff ff       	call   f0100e5c <pgdir_walk>
f0101a4a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101a4d:	8d 57 04             	lea    0x4(%edi),%edx
f0101a50:	83 c4 10             	add    $0x10,%esp
f0101a53:	39 d0                	cmp    %edx,%eax
f0101a55:	74 19                	je     f0101a70 <mem_init+0x9ac>
f0101a57:	68 5c 52 10 f0       	push   $0xf010525c
f0101a5c:	68 3b 57 10 f0       	push   $0xf010573b
f0101a61:	68 cd 03 00 00       	push   $0x3cd
f0101a66:	68 15 57 10 f0       	push   $0xf0105715
f0101a6b:	e8 6c e6 ff ff       	call   f01000dc <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101a70:	6a 06                	push   $0x6
f0101a72:	68 00 10 00 00       	push   $0x1000
f0101a77:	56                   	push   %esi
f0101a78:	ff 35 08 db 17 f0    	pushl  0xf017db08
f0101a7e:	e8 b0 f5 ff ff       	call   f0101033 <page_insert>
f0101a83:	83 c4 10             	add    $0x10,%esp
f0101a86:	85 c0                	test   %eax,%eax
f0101a88:	74 19                	je     f0101aa3 <mem_init+0x9df>
f0101a8a:	68 9c 52 10 f0       	push   $0xf010529c
f0101a8f:	68 3b 57 10 f0       	push   $0xf010573b
f0101a94:	68 d0 03 00 00       	push   $0x3d0
f0101a99:	68 15 57 10 f0       	push   $0xf0105715
f0101a9e:	e8 39 e6 ff ff       	call   f01000dc <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101aa3:	8b 3d 08 db 17 f0    	mov    0xf017db08,%edi
f0101aa9:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101aae:	89 f8                	mov    %edi,%eax
f0101ab0:	e8 a9 ee ff ff       	call   f010095e <check_va2pa>
f0101ab5:	89 f2                	mov    %esi,%edx
f0101ab7:	2b 15 0c db 17 f0    	sub    0xf017db0c,%edx
f0101abd:	c1 fa 03             	sar    $0x3,%edx
f0101ac0:	c1 e2 0c             	shl    $0xc,%edx
f0101ac3:	39 d0                	cmp    %edx,%eax
f0101ac5:	74 19                	je     f0101ae0 <mem_init+0xa1c>
f0101ac7:	68 2c 52 10 f0       	push   $0xf010522c
f0101acc:	68 3b 57 10 f0       	push   $0xf010573b
f0101ad1:	68 d1 03 00 00       	push   $0x3d1
f0101ad6:	68 15 57 10 f0       	push   $0xf0105715
f0101adb:	e8 fc e5 ff ff       	call   f01000dc <_panic>
	assert(pp2->pp_ref == 1);
f0101ae0:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101ae5:	74 19                	je     f0101b00 <mem_init+0xa3c>
f0101ae7:	68 05 59 10 f0       	push   $0xf0105905
f0101aec:	68 3b 57 10 f0       	push   $0xf010573b
f0101af1:	68 d2 03 00 00       	push   $0x3d2
f0101af6:	68 15 57 10 f0       	push   $0xf0105715
f0101afb:	e8 dc e5 ff ff       	call   f01000dc <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101b00:	83 ec 04             	sub    $0x4,%esp
f0101b03:	6a 00                	push   $0x0
f0101b05:	68 00 10 00 00       	push   $0x1000
f0101b0a:	57                   	push   %edi
f0101b0b:	e8 4c f3 ff ff       	call   f0100e5c <pgdir_walk>
f0101b10:	83 c4 10             	add    $0x10,%esp
f0101b13:	f6 00 04             	testb  $0x4,(%eax)
f0101b16:	75 19                	jne    f0101b31 <mem_init+0xa6d>
f0101b18:	68 dc 52 10 f0       	push   $0xf01052dc
f0101b1d:	68 3b 57 10 f0       	push   $0xf010573b
f0101b22:	68 d3 03 00 00       	push   $0x3d3
f0101b27:	68 15 57 10 f0       	push   $0xf0105715
f0101b2c:	e8 ab e5 ff ff       	call   f01000dc <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101b31:	a1 08 db 17 f0       	mov    0xf017db08,%eax
f0101b36:	f6 00 04             	testb  $0x4,(%eax)
f0101b39:	75 19                	jne    f0101b54 <mem_init+0xa90>
f0101b3b:	68 16 59 10 f0       	push   $0xf0105916
f0101b40:	68 3b 57 10 f0       	push   $0xf010573b
f0101b45:	68 d4 03 00 00       	push   $0x3d4
f0101b4a:	68 15 57 10 f0       	push   $0xf0105715
f0101b4f:	e8 88 e5 ff ff       	call   f01000dc <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101b54:	6a 02                	push   $0x2
f0101b56:	68 00 10 00 00       	push   $0x1000
f0101b5b:	56                   	push   %esi
f0101b5c:	50                   	push   %eax
f0101b5d:	e8 d1 f4 ff ff       	call   f0101033 <page_insert>
f0101b62:	83 c4 10             	add    $0x10,%esp
f0101b65:	85 c0                	test   %eax,%eax
f0101b67:	74 19                	je     f0101b82 <mem_init+0xabe>
f0101b69:	68 f0 51 10 f0       	push   $0xf01051f0
f0101b6e:	68 3b 57 10 f0       	push   $0xf010573b
f0101b73:	68 d7 03 00 00       	push   $0x3d7
f0101b78:	68 15 57 10 f0       	push   $0xf0105715
f0101b7d:	e8 5a e5 ff ff       	call   f01000dc <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101b82:	83 ec 04             	sub    $0x4,%esp
f0101b85:	6a 00                	push   $0x0
f0101b87:	68 00 10 00 00       	push   $0x1000
f0101b8c:	ff 35 08 db 17 f0    	pushl  0xf017db08
f0101b92:	e8 c5 f2 ff ff       	call   f0100e5c <pgdir_walk>
f0101b97:	83 c4 10             	add    $0x10,%esp
f0101b9a:	f6 00 02             	testb  $0x2,(%eax)
f0101b9d:	75 19                	jne    f0101bb8 <mem_init+0xaf4>
f0101b9f:	68 10 53 10 f0       	push   $0xf0105310
f0101ba4:	68 3b 57 10 f0       	push   $0xf010573b
f0101ba9:	68 d8 03 00 00       	push   $0x3d8
f0101bae:	68 15 57 10 f0       	push   $0xf0105715
f0101bb3:	e8 24 e5 ff ff       	call   f01000dc <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101bb8:	83 ec 04             	sub    $0x4,%esp
f0101bbb:	6a 00                	push   $0x0
f0101bbd:	68 00 10 00 00       	push   $0x1000
f0101bc2:	ff 35 08 db 17 f0    	pushl  0xf017db08
f0101bc8:	e8 8f f2 ff ff       	call   f0100e5c <pgdir_walk>
f0101bcd:	83 c4 10             	add    $0x10,%esp
f0101bd0:	f6 00 04             	testb  $0x4,(%eax)
f0101bd3:	74 19                	je     f0101bee <mem_init+0xb2a>
f0101bd5:	68 44 53 10 f0       	push   $0xf0105344
f0101bda:	68 3b 57 10 f0       	push   $0xf010573b
f0101bdf:	68 d9 03 00 00       	push   $0x3d9
f0101be4:	68 15 57 10 f0       	push   $0xf0105715
f0101be9:	e8 ee e4 ff ff       	call   f01000dc <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101bee:	6a 02                	push   $0x2
f0101bf0:	68 00 00 40 00       	push   $0x400000
f0101bf5:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101bf8:	ff 35 08 db 17 f0    	pushl  0xf017db08
f0101bfe:	e8 30 f4 ff ff       	call   f0101033 <page_insert>
f0101c03:	83 c4 10             	add    $0x10,%esp
f0101c06:	85 c0                	test   %eax,%eax
f0101c08:	78 19                	js     f0101c23 <mem_init+0xb5f>
f0101c0a:	68 7c 53 10 f0       	push   $0xf010537c
f0101c0f:	68 3b 57 10 f0       	push   $0xf010573b
f0101c14:	68 dc 03 00 00       	push   $0x3dc
f0101c19:	68 15 57 10 f0       	push   $0xf0105715
f0101c1e:	e8 b9 e4 ff ff       	call   f01000dc <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101c23:	6a 02                	push   $0x2
f0101c25:	68 00 10 00 00       	push   $0x1000
f0101c2a:	53                   	push   %ebx
f0101c2b:	ff 35 08 db 17 f0    	pushl  0xf017db08
f0101c31:	e8 fd f3 ff ff       	call   f0101033 <page_insert>
f0101c36:	83 c4 10             	add    $0x10,%esp
f0101c39:	85 c0                	test   %eax,%eax
f0101c3b:	74 19                	je     f0101c56 <mem_init+0xb92>
f0101c3d:	68 b4 53 10 f0       	push   $0xf01053b4
f0101c42:	68 3b 57 10 f0       	push   $0xf010573b
f0101c47:	68 df 03 00 00       	push   $0x3df
f0101c4c:	68 15 57 10 f0       	push   $0xf0105715
f0101c51:	e8 86 e4 ff ff       	call   f01000dc <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101c56:	83 ec 04             	sub    $0x4,%esp
f0101c59:	6a 00                	push   $0x0
f0101c5b:	68 00 10 00 00       	push   $0x1000
f0101c60:	ff 35 08 db 17 f0    	pushl  0xf017db08
f0101c66:	e8 f1 f1 ff ff       	call   f0100e5c <pgdir_walk>
f0101c6b:	83 c4 10             	add    $0x10,%esp
f0101c6e:	f6 00 04             	testb  $0x4,(%eax)
f0101c71:	74 19                	je     f0101c8c <mem_init+0xbc8>
f0101c73:	68 44 53 10 f0       	push   $0xf0105344
f0101c78:	68 3b 57 10 f0       	push   $0xf010573b
f0101c7d:	68 e0 03 00 00       	push   $0x3e0
f0101c82:	68 15 57 10 f0       	push   $0xf0105715
f0101c87:	e8 50 e4 ff ff       	call   f01000dc <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101c8c:	8b 3d 08 db 17 f0    	mov    0xf017db08,%edi
f0101c92:	ba 00 00 00 00       	mov    $0x0,%edx
f0101c97:	89 f8                	mov    %edi,%eax
f0101c99:	e8 c0 ec ff ff       	call   f010095e <check_va2pa>
f0101c9e:	89 c1                	mov    %eax,%ecx
f0101ca0:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101ca3:	89 d8                	mov    %ebx,%eax
f0101ca5:	2b 05 0c db 17 f0    	sub    0xf017db0c,%eax
f0101cab:	c1 f8 03             	sar    $0x3,%eax
f0101cae:	c1 e0 0c             	shl    $0xc,%eax
f0101cb1:	39 c1                	cmp    %eax,%ecx
f0101cb3:	74 19                	je     f0101cce <mem_init+0xc0a>
f0101cb5:	68 f0 53 10 f0       	push   $0xf01053f0
f0101cba:	68 3b 57 10 f0       	push   $0xf010573b
f0101cbf:	68 e3 03 00 00       	push   $0x3e3
f0101cc4:	68 15 57 10 f0       	push   $0xf0105715
f0101cc9:	e8 0e e4 ff ff       	call   f01000dc <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101cce:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101cd3:	89 f8                	mov    %edi,%eax
f0101cd5:	e8 84 ec ff ff       	call   f010095e <check_va2pa>
f0101cda:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101cdd:	74 19                	je     f0101cf8 <mem_init+0xc34>
f0101cdf:	68 1c 54 10 f0       	push   $0xf010541c
f0101ce4:	68 3b 57 10 f0       	push   $0xf010573b
f0101ce9:	68 e4 03 00 00       	push   $0x3e4
f0101cee:	68 15 57 10 f0       	push   $0xf0105715
f0101cf3:	e8 e4 e3 ff ff       	call   f01000dc <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101cf8:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0101cfd:	74 19                	je     f0101d18 <mem_init+0xc54>
f0101cff:	68 2c 59 10 f0       	push   $0xf010592c
f0101d04:	68 3b 57 10 f0       	push   $0xf010573b
f0101d09:	68 e6 03 00 00       	push   $0x3e6
f0101d0e:	68 15 57 10 f0       	push   $0xf0105715
f0101d13:	e8 c4 e3 ff ff       	call   f01000dc <_panic>
	assert(pp2->pp_ref == 0);
f0101d18:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101d1d:	74 19                	je     f0101d38 <mem_init+0xc74>
f0101d1f:	68 3d 59 10 f0       	push   $0xf010593d
f0101d24:	68 3b 57 10 f0       	push   $0xf010573b
f0101d29:	68 e7 03 00 00       	push   $0x3e7
f0101d2e:	68 15 57 10 f0       	push   $0xf0105715
f0101d33:	e8 a4 e3 ff ff       	call   f01000dc <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101d38:	83 ec 0c             	sub    $0xc,%esp
f0101d3b:	6a 00                	push   $0x0
f0101d3d:	e8 48 f0 ff ff       	call   f0100d8a <page_alloc>
f0101d42:	83 c4 10             	add    $0x10,%esp
f0101d45:	85 c0                	test   %eax,%eax
f0101d47:	74 04                	je     f0101d4d <mem_init+0xc89>
f0101d49:	39 c6                	cmp    %eax,%esi
f0101d4b:	74 19                	je     f0101d66 <mem_init+0xca2>
f0101d4d:	68 4c 54 10 f0       	push   $0xf010544c
f0101d52:	68 3b 57 10 f0       	push   $0xf010573b
f0101d57:	68 ea 03 00 00       	push   $0x3ea
f0101d5c:	68 15 57 10 f0       	push   $0xf0105715
f0101d61:	e8 76 e3 ff ff       	call   f01000dc <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101d66:	83 ec 08             	sub    $0x8,%esp
f0101d69:	6a 00                	push   $0x0
f0101d6b:	ff 35 08 db 17 f0    	pushl  0xf017db08
f0101d71:	e8 82 f2 ff ff       	call   f0100ff8 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101d76:	8b 3d 08 db 17 f0    	mov    0xf017db08,%edi
f0101d7c:	ba 00 00 00 00       	mov    $0x0,%edx
f0101d81:	89 f8                	mov    %edi,%eax
f0101d83:	e8 d6 eb ff ff       	call   f010095e <check_va2pa>
f0101d88:	83 c4 10             	add    $0x10,%esp
f0101d8b:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101d8e:	74 19                	je     f0101da9 <mem_init+0xce5>
f0101d90:	68 70 54 10 f0       	push   $0xf0105470
f0101d95:	68 3b 57 10 f0       	push   $0xf010573b
f0101d9a:	68 ee 03 00 00       	push   $0x3ee
f0101d9f:	68 15 57 10 f0       	push   $0xf0105715
f0101da4:	e8 33 e3 ff ff       	call   f01000dc <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101da9:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101dae:	89 f8                	mov    %edi,%eax
f0101db0:	e8 a9 eb ff ff       	call   f010095e <check_va2pa>
f0101db5:	89 da                	mov    %ebx,%edx
f0101db7:	2b 15 0c db 17 f0    	sub    0xf017db0c,%edx
f0101dbd:	c1 fa 03             	sar    $0x3,%edx
f0101dc0:	c1 e2 0c             	shl    $0xc,%edx
f0101dc3:	39 d0                	cmp    %edx,%eax
f0101dc5:	74 19                	je     f0101de0 <mem_init+0xd1c>
f0101dc7:	68 1c 54 10 f0       	push   $0xf010541c
f0101dcc:	68 3b 57 10 f0       	push   $0xf010573b
f0101dd1:	68 ef 03 00 00       	push   $0x3ef
f0101dd6:	68 15 57 10 f0       	push   $0xf0105715
f0101ddb:	e8 fc e2 ff ff       	call   f01000dc <_panic>
	assert(pp1->pp_ref == 1);
f0101de0:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101de5:	74 19                	je     f0101e00 <mem_init+0xd3c>
f0101de7:	68 e3 58 10 f0       	push   $0xf01058e3
f0101dec:	68 3b 57 10 f0       	push   $0xf010573b
f0101df1:	68 f0 03 00 00       	push   $0x3f0
f0101df6:	68 15 57 10 f0       	push   $0xf0105715
f0101dfb:	e8 dc e2 ff ff       	call   f01000dc <_panic>
	assert(pp2->pp_ref == 0);
f0101e00:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101e05:	74 19                	je     f0101e20 <mem_init+0xd5c>
f0101e07:	68 3d 59 10 f0       	push   $0xf010593d
f0101e0c:	68 3b 57 10 f0       	push   $0xf010573b
f0101e11:	68 f1 03 00 00       	push   $0x3f1
f0101e16:	68 15 57 10 f0       	push   $0xf0105715
f0101e1b:	e8 bc e2 ff ff       	call   f01000dc <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101e20:	6a 00                	push   $0x0
f0101e22:	68 00 10 00 00       	push   $0x1000
f0101e27:	53                   	push   %ebx
f0101e28:	57                   	push   %edi
f0101e29:	e8 05 f2 ff ff       	call   f0101033 <page_insert>
f0101e2e:	83 c4 10             	add    $0x10,%esp
f0101e31:	85 c0                	test   %eax,%eax
f0101e33:	74 19                	je     f0101e4e <mem_init+0xd8a>
f0101e35:	68 94 54 10 f0       	push   $0xf0105494
f0101e3a:	68 3b 57 10 f0       	push   $0xf010573b
f0101e3f:	68 f4 03 00 00       	push   $0x3f4
f0101e44:	68 15 57 10 f0       	push   $0xf0105715
f0101e49:	e8 8e e2 ff ff       	call   f01000dc <_panic>
	assert(pp1->pp_ref);
f0101e4e:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101e53:	75 19                	jne    f0101e6e <mem_init+0xdaa>
f0101e55:	68 4e 59 10 f0       	push   $0xf010594e
f0101e5a:	68 3b 57 10 f0       	push   $0xf010573b
f0101e5f:	68 f5 03 00 00       	push   $0x3f5
f0101e64:	68 15 57 10 f0       	push   $0xf0105715
f0101e69:	e8 6e e2 ff ff       	call   f01000dc <_panic>
	assert(pp1->pp_link == NULL);
f0101e6e:	83 3b 00             	cmpl   $0x0,(%ebx)
f0101e71:	74 19                	je     f0101e8c <mem_init+0xdc8>
f0101e73:	68 5a 59 10 f0       	push   $0xf010595a
f0101e78:	68 3b 57 10 f0       	push   $0xf010573b
f0101e7d:	68 f6 03 00 00       	push   $0x3f6
f0101e82:	68 15 57 10 f0       	push   $0xf0105715
f0101e87:	e8 50 e2 ff ff       	call   f01000dc <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101e8c:	83 ec 08             	sub    $0x8,%esp
f0101e8f:	68 00 10 00 00       	push   $0x1000
f0101e94:	ff 35 08 db 17 f0    	pushl  0xf017db08
f0101e9a:	e8 59 f1 ff ff       	call   f0100ff8 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101e9f:	8b 3d 08 db 17 f0    	mov    0xf017db08,%edi
f0101ea5:	ba 00 00 00 00       	mov    $0x0,%edx
f0101eaa:	89 f8                	mov    %edi,%eax
f0101eac:	e8 ad ea ff ff       	call   f010095e <check_va2pa>
f0101eb1:	83 c4 10             	add    $0x10,%esp
f0101eb4:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101eb7:	74 19                	je     f0101ed2 <mem_init+0xe0e>
f0101eb9:	68 70 54 10 f0       	push   $0xf0105470
f0101ebe:	68 3b 57 10 f0       	push   $0xf010573b
f0101ec3:	68 fa 03 00 00       	push   $0x3fa
f0101ec8:	68 15 57 10 f0       	push   $0xf0105715
f0101ecd:	e8 0a e2 ff ff       	call   f01000dc <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101ed2:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ed7:	89 f8                	mov    %edi,%eax
f0101ed9:	e8 80 ea ff ff       	call   f010095e <check_va2pa>
f0101ede:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101ee1:	74 19                	je     f0101efc <mem_init+0xe38>
f0101ee3:	68 cc 54 10 f0       	push   $0xf01054cc
f0101ee8:	68 3b 57 10 f0       	push   $0xf010573b
f0101eed:	68 fb 03 00 00       	push   $0x3fb
f0101ef2:	68 15 57 10 f0       	push   $0xf0105715
f0101ef7:	e8 e0 e1 ff ff       	call   f01000dc <_panic>
	assert(pp1->pp_ref == 0);
f0101efc:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101f01:	74 19                	je     f0101f1c <mem_init+0xe58>
f0101f03:	68 6f 59 10 f0       	push   $0xf010596f
f0101f08:	68 3b 57 10 f0       	push   $0xf010573b
f0101f0d:	68 fc 03 00 00       	push   $0x3fc
f0101f12:	68 15 57 10 f0       	push   $0xf0105715
f0101f17:	e8 c0 e1 ff ff       	call   f01000dc <_panic>
	assert(pp2->pp_ref == 0);
f0101f1c:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101f21:	74 19                	je     f0101f3c <mem_init+0xe78>
f0101f23:	68 3d 59 10 f0       	push   $0xf010593d
f0101f28:	68 3b 57 10 f0       	push   $0xf010573b
f0101f2d:	68 fd 03 00 00       	push   $0x3fd
f0101f32:	68 15 57 10 f0       	push   $0xf0105715
f0101f37:	e8 a0 e1 ff ff       	call   f01000dc <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101f3c:	83 ec 0c             	sub    $0xc,%esp
f0101f3f:	6a 00                	push   $0x0
f0101f41:	e8 44 ee ff ff       	call   f0100d8a <page_alloc>
f0101f46:	83 c4 10             	add    $0x10,%esp
f0101f49:	39 c3                	cmp    %eax,%ebx
f0101f4b:	75 04                	jne    f0101f51 <mem_init+0xe8d>
f0101f4d:	85 c0                	test   %eax,%eax
f0101f4f:	75 19                	jne    f0101f6a <mem_init+0xea6>
f0101f51:	68 f4 54 10 f0       	push   $0xf01054f4
f0101f56:	68 3b 57 10 f0       	push   $0xf010573b
f0101f5b:	68 00 04 00 00       	push   $0x400
f0101f60:	68 15 57 10 f0       	push   $0xf0105715
f0101f65:	e8 72 e1 ff ff       	call   f01000dc <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101f6a:	83 ec 0c             	sub    $0xc,%esp
f0101f6d:	6a 00                	push   $0x0
f0101f6f:	e8 16 ee ff ff       	call   f0100d8a <page_alloc>
f0101f74:	83 c4 10             	add    $0x10,%esp
f0101f77:	85 c0                	test   %eax,%eax
f0101f79:	74 19                	je     f0101f94 <mem_init+0xed0>
f0101f7b:	68 91 58 10 f0       	push   $0xf0105891
f0101f80:	68 3b 57 10 f0       	push   $0xf010573b
f0101f85:	68 03 04 00 00       	push   $0x403
f0101f8a:	68 15 57 10 f0       	push   $0xf0105715
f0101f8f:	e8 48 e1 ff ff       	call   f01000dc <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101f94:	8b 0d 08 db 17 f0    	mov    0xf017db08,%ecx
f0101f9a:	8b 11                	mov    (%ecx),%edx
f0101f9c:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101fa2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101fa5:	2b 05 0c db 17 f0    	sub    0xf017db0c,%eax
f0101fab:	c1 f8 03             	sar    $0x3,%eax
f0101fae:	c1 e0 0c             	shl    $0xc,%eax
f0101fb1:	39 c2                	cmp    %eax,%edx
f0101fb3:	74 19                	je     f0101fce <mem_init+0xf0a>
f0101fb5:	68 98 51 10 f0       	push   $0xf0105198
f0101fba:	68 3b 57 10 f0       	push   $0xf010573b
f0101fbf:	68 06 04 00 00       	push   $0x406
f0101fc4:	68 15 57 10 f0       	push   $0xf0105715
f0101fc9:	e8 0e e1 ff ff       	call   f01000dc <_panic>
	kern_pgdir[0] = 0;
f0101fce:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0101fd4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101fd7:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101fdc:	74 19                	je     f0101ff7 <mem_init+0xf33>
f0101fde:	68 f4 58 10 f0       	push   $0xf01058f4
f0101fe3:	68 3b 57 10 f0       	push   $0xf010573b
f0101fe8:	68 08 04 00 00       	push   $0x408
f0101fed:	68 15 57 10 f0       	push   $0xf0105715
f0101ff2:	e8 e5 e0 ff ff       	call   f01000dc <_panic>
	pp0->pp_ref = 0;
f0101ff7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ffa:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102000:	83 ec 0c             	sub    $0xc,%esp
f0102003:	50                   	push   %eax
f0102004:	e8 f1 ed ff ff       	call   f0100dfa <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102009:	83 c4 0c             	add    $0xc,%esp
f010200c:	6a 01                	push   $0x1
f010200e:	68 00 10 40 00       	push   $0x401000
f0102013:	ff 35 08 db 17 f0    	pushl  0xf017db08
f0102019:	e8 3e ee ff ff       	call   f0100e5c <pgdir_walk>
f010201e:	89 c7                	mov    %eax,%edi
f0102020:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102023:	a1 08 db 17 f0       	mov    0xf017db08,%eax
f0102028:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010202b:	8b 40 04             	mov    0x4(%eax),%eax
f010202e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102033:	8b 0d 04 db 17 f0    	mov    0xf017db04,%ecx
f0102039:	89 c2                	mov    %eax,%edx
f010203b:	c1 ea 0c             	shr    $0xc,%edx
f010203e:	83 c4 10             	add    $0x10,%esp
f0102041:	39 ca                	cmp    %ecx,%edx
f0102043:	72 15                	jb     f010205a <mem_init+0xf96>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102045:	50                   	push   %eax
f0102046:	68 24 4f 10 f0       	push   $0xf0104f24
f010204b:	68 0f 04 00 00       	push   $0x40f
f0102050:	68 15 57 10 f0       	push   $0xf0105715
f0102055:	e8 82 e0 ff ff       	call   f01000dc <_panic>
	assert(ptep == ptep1 + PTX(va));
f010205a:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f010205f:	39 c7                	cmp    %eax,%edi
f0102061:	74 19                	je     f010207c <mem_init+0xfb8>
f0102063:	68 80 59 10 f0       	push   $0xf0105980
f0102068:	68 3b 57 10 f0       	push   $0xf010573b
f010206d:	68 10 04 00 00       	push   $0x410
f0102072:	68 15 57 10 f0       	push   $0xf0105715
f0102077:	e8 60 e0 ff ff       	call   f01000dc <_panic>
	kern_pgdir[PDX(va)] = 0;
f010207c:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010207f:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f0102086:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102089:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010208f:	2b 05 0c db 17 f0    	sub    0xf017db0c,%eax
f0102095:	c1 f8 03             	sar    $0x3,%eax
f0102098:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010209b:	89 c2                	mov    %eax,%edx
f010209d:	c1 ea 0c             	shr    $0xc,%edx
f01020a0:	39 d1                	cmp    %edx,%ecx
f01020a2:	77 12                	ja     f01020b6 <mem_init+0xff2>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01020a4:	50                   	push   %eax
f01020a5:	68 24 4f 10 f0       	push   $0xf0104f24
f01020aa:	6a 56                	push   $0x56
f01020ac:	68 21 57 10 f0       	push   $0xf0105721
f01020b1:	e8 26 e0 ff ff       	call   f01000dc <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f01020b6:	83 ec 04             	sub    $0x4,%esp
f01020b9:	68 00 10 00 00       	push   $0x1000
f01020be:	68 ff 00 00 00       	push   $0xff
f01020c3:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01020c8:	50                   	push   %eax
f01020c9:	e8 61 24 00 00       	call   f010452f <memset>
	page_free(pp0);
f01020ce:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01020d1:	89 3c 24             	mov    %edi,(%esp)
f01020d4:	e8 21 ed ff ff       	call   f0100dfa <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f01020d9:	83 c4 0c             	add    $0xc,%esp
f01020dc:	6a 01                	push   $0x1
f01020de:	6a 00                	push   $0x0
f01020e0:	ff 35 08 db 17 f0    	pushl  0xf017db08
f01020e6:	e8 71 ed ff ff       	call   f0100e5c <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01020eb:	89 fa                	mov    %edi,%edx
f01020ed:	2b 15 0c db 17 f0    	sub    0xf017db0c,%edx
f01020f3:	c1 fa 03             	sar    $0x3,%edx
f01020f6:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01020f9:	89 d0                	mov    %edx,%eax
f01020fb:	c1 e8 0c             	shr    $0xc,%eax
f01020fe:	83 c4 10             	add    $0x10,%esp
f0102101:	3b 05 04 db 17 f0    	cmp    0xf017db04,%eax
f0102107:	72 12                	jb     f010211b <mem_init+0x1057>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102109:	52                   	push   %edx
f010210a:	68 24 4f 10 f0       	push   $0xf0104f24
f010210f:	6a 56                	push   $0x56
f0102111:	68 21 57 10 f0       	push   $0xf0105721
f0102116:	e8 c1 df ff ff       	call   f01000dc <_panic>
	return (void *)(pa + KERNBASE);
f010211b:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102121:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102124:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f010212a:	f6 00 01             	testb  $0x1,(%eax)
f010212d:	74 19                	je     f0102148 <mem_init+0x1084>
f010212f:	68 98 59 10 f0       	push   $0xf0105998
f0102134:	68 3b 57 10 f0       	push   $0xf010573b
f0102139:	68 1a 04 00 00       	push   $0x41a
f010213e:	68 15 57 10 f0       	push   $0xf0105715
f0102143:	e8 94 df ff ff       	call   f01000dc <_panic>
f0102148:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f010214b:	39 c2                	cmp    %eax,%edx
f010214d:	75 db                	jne    f010212a <mem_init+0x1066>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f010214f:	a1 08 db 17 f0       	mov    0xf017db08,%eax
f0102154:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f010215a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010215d:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0102163:	8b 7d d0             	mov    -0x30(%ebp),%edi
f0102166:	89 3d 40 ce 17 f0    	mov    %edi,0xf017ce40

	// free the pages we took
	page_free(pp0);
f010216c:	83 ec 0c             	sub    $0xc,%esp
f010216f:	50                   	push   %eax
f0102170:	e8 85 ec ff ff       	call   f0100dfa <page_free>
	page_free(pp1);
f0102175:	89 1c 24             	mov    %ebx,(%esp)
f0102178:	e8 7d ec ff ff       	call   f0100dfa <page_free>
	page_free(pp2);
f010217d:	89 34 24             	mov    %esi,(%esp)
f0102180:	e8 75 ec ff ff       	call   f0100dfa <page_free>

	cprintf("check_page() succeeded!\n");
f0102185:	c7 04 24 af 59 10 f0 	movl   $0xf01059af,(%esp)
f010218c:	e8 69 0e 00 00       	call   f0102ffa <cprintf>
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:

   boot_map_region(kern_pgdir, 
f0102191:	a1 0c db 17 f0       	mov    0xf017db0c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102196:	83 c4 10             	add    $0x10,%esp
f0102199:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010219e:	77 15                	ja     f01021b5 <mem_init+0x10f1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01021a0:	50                   	push   %eax
f01021a1:	68 0c 50 10 f0       	push   $0xf010500c
f01021a6:	68 bd 00 00 00       	push   $0xbd
f01021ab:	68 15 57 10 f0       	push   $0xf0105715
f01021b0:	e8 27 df ff ff       	call   f01000dc <_panic>
                    UPAGES, 
                    ROUNDUP((sizeof(struct PageInfo)*npages), PGSIZE),
f01021b5:	8b 15 04 db 17 f0    	mov    0xf017db04,%edx
f01021bb:	8d 0c d5 ff 0f 00 00 	lea    0xfff(,%edx,8),%ecx
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:

   boot_map_region(kern_pgdir, 
f01021c2:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f01021c8:	83 ec 08             	sub    $0x8,%esp
f01021cb:	6a 05                	push   $0x5
f01021cd:	05 00 00 00 10       	add    $0x10000000,%eax
f01021d2:	50                   	push   %eax
f01021d3:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f01021d8:	a1 08 db 17 f0       	mov    0xf017db08,%eax
f01021dd:	e8 5f ed ff ff       	call   f0100f41 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01021e2:	83 c4 10             	add    $0x10,%esp
f01021e5:	b8 00 10 11 f0       	mov    $0xf0111000,%eax
f01021ea:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01021ef:	77 15                	ja     f0102206 <mem_init+0x1142>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01021f1:	50                   	push   %eax
f01021f2:	68 0c 50 10 f0       	push   $0xf010500c
f01021f7:	68 ce 00 00 00       	push   $0xce
f01021fc:	68 15 57 10 f0       	push   $0xf0105715
f0102201:	e8 d6 de ff ff       	call   f01000dc <_panic>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir, 
f0102206:	83 ec 08             	sub    $0x8,%esp
f0102209:	6a 03                	push   $0x3
f010220b:	68 00 10 11 00       	push   $0x111000
f0102210:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102215:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f010221a:	a1 08 db 17 f0       	mov    0xf017db08,%eax
f010221f:	e8 1d ed ff ff       	call   f0100f41 <boot_map_region>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir, 
f0102224:	83 c4 08             	add    $0x8,%esp
f0102227:	6a 03                	push   $0x3
f0102229:	6a 00                	push   $0x0
f010222b:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102230:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102235:	a1 08 db 17 f0       	mov    0xf017db08,%eax
f010223a:	e8 02 ed ff ff       	call   f0100f41 <boot_map_region>
	// Map 'envs' read-only by the user at linear address UENVS
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
    boot_map_region(kern_pgdir, 
f010223f:	a1 4c ce 17 f0       	mov    0xf017ce4c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102244:	83 c4 10             	add    $0x10,%esp
f0102247:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010224c:	77 15                	ja     f0102263 <mem_init+0x119f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010224e:	50                   	push   %eax
f010224f:	68 0c 50 10 f0       	push   $0xf010500c
f0102254:	68 e8 00 00 00       	push   $0xe8
f0102259:	68 15 57 10 f0       	push   $0xf0105715
f010225e:	e8 79 de ff ff       	call   f01000dc <_panic>
f0102263:	83 ec 08             	sub    $0x8,%esp
f0102266:	6a 05                	push   $0x5
f0102268:	05 00 00 00 10       	add    $0x10000000,%eax
f010226d:	50                   	push   %eax
f010226e:	b9 00 80 01 00       	mov    $0x18000,%ecx
f0102273:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102278:	a1 08 db 17 f0       	mov    0xf017db08,%eax
f010227d:	e8 bf ec ff ff       	call   f0100f41 <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102282:	8b 1d 08 db 17 f0    	mov    0xf017db08,%ebx

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102288:	a1 04 db 17 f0       	mov    0xf017db04,%eax
f010228d:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102290:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102297:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010229c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010229f:	8b 3d 0c db 17 f0    	mov    0xf017db0c,%edi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01022a5:	89 7d d0             	mov    %edi,-0x30(%ebp)
f01022a8:	83 c4 10             	add    $0x10,%esp

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01022ab:	be 00 00 00 00       	mov    $0x0,%esi
f01022b0:	eb 55                	jmp    f0102307 <mem_init+0x1243>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01022b2:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
f01022b8:	89 d8                	mov    %ebx,%eax
f01022ba:	e8 9f e6 ff ff       	call   f010095e <check_va2pa>
f01022bf:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f01022c6:	77 15                	ja     f01022dd <mem_init+0x1219>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01022c8:	57                   	push   %edi
f01022c9:	68 0c 50 10 f0       	push   $0xf010500c
f01022ce:	68 57 03 00 00       	push   $0x357
f01022d3:	68 15 57 10 f0       	push   $0xf0105715
f01022d8:	e8 ff dd ff ff       	call   f01000dc <_panic>
f01022dd:	8d 94 37 00 00 00 10 	lea    0x10000000(%edi,%esi,1),%edx
f01022e4:	39 d0                	cmp    %edx,%eax
f01022e6:	74 19                	je     f0102301 <mem_init+0x123d>
f01022e8:	68 18 55 10 f0       	push   $0xf0105518
f01022ed:	68 3b 57 10 f0       	push   $0xf010573b
f01022f2:	68 57 03 00 00       	push   $0x357
f01022f7:	68 15 57 10 f0       	push   $0xf0105715
f01022fc:	e8 db dd ff ff       	call   f01000dc <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102301:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102307:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
f010230a:	77 a6                	ja     f01022b2 <mem_init+0x11ee>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f010230c:	8b 3d 4c ce 17 f0    	mov    0xf017ce4c,%edi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102312:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0102315:	be 00 00 c0 ee       	mov    $0xeec00000,%esi
f010231a:	89 f2                	mov    %esi,%edx
f010231c:	89 d8                	mov    %ebx,%eax
f010231e:	e8 3b e6 ff ff       	call   f010095e <check_va2pa>
f0102323:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f010232a:	77 15                	ja     f0102341 <mem_init+0x127d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010232c:	57                   	push   %edi
f010232d:	68 0c 50 10 f0       	push   $0xf010500c
f0102332:	68 5c 03 00 00       	push   $0x35c
f0102337:	68 15 57 10 f0       	push   $0xf0105715
f010233c:	e8 9b dd ff ff       	call   f01000dc <_panic>
f0102341:	8d 94 37 00 00 40 21 	lea    0x21400000(%edi,%esi,1),%edx
f0102348:	39 c2                	cmp    %eax,%edx
f010234a:	74 19                	je     f0102365 <mem_init+0x12a1>
f010234c:	68 4c 55 10 f0       	push   $0xf010554c
f0102351:	68 3b 57 10 f0       	push   $0xf010573b
f0102356:	68 5c 03 00 00       	push   $0x35c
f010235b:	68 15 57 10 f0       	push   $0xf0105715
f0102360:	e8 77 dd ff ff       	call   f01000dc <_panic>
f0102365:	81 c6 00 10 00 00    	add    $0x1000,%esi
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f010236b:	81 fe 00 80 c1 ee    	cmp    $0xeec18000,%esi
f0102371:	75 a7                	jne    f010231a <mem_init+0x1256>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102373:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0102376:	c1 e7 0c             	shl    $0xc,%edi
f0102379:	be 00 00 00 00       	mov    $0x0,%esi
f010237e:	eb 30                	jmp    f01023b0 <mem_init+0x12ec>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102380:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
f0102386:	89 d8                	mov    %ebx,%eax
f0102388:	e8 d1 e5 ff ff       	call   f010095e <check_va2pa>
f010238d:	39 c6                	cmp    %eax,%esi
f010238f:	74 19                	je     f01023aa <mem_init+0x12e6>
f0102391:	68 80 55 10 f0       	push   $0xf0105580
f0102396:	68 3b 57 10 f0       	push   $0xf010573b
f010239b:	68 60 03 00 00       	push   $0x360
f01023a0:	68 15 57 10 f0       	push   $0xf0105715
f01023a5:	e8 32 dd ff ff       	call   f01000dc <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01023aa:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01023b0:	39 fe                	cmp    %edi,%esi
f01023b2:	72 cc                	jb     f0102380 <mem_init+0x12bc>
f01023b4:	be 00 80 ff ef       	mov    $0xefff8000,%esi
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f01023b9:	89 f2                	mov    %esi,%edx
f01023bb:	89 d8                	mov    %ebx,%eax
f01023bd:	e8 9c e5 ff ff       	call   f010095e <check_va2pa>
f01023c2:	8d 96 00 90 11 10    	lea    0x10119000(%esi),%edx
f01023c8:	39 c2                	cmp    %eax,%edx
f01023ca:	74 19                	je     f01023e5 <mem_init+0x1321>
f01023cc:	68 a8 55 10 f0       	push   $0xf01055a8
f01023d1:	68 3b 57 10 f0       	push   $0xf010573b
f01023d6:	68 64 03 00 00       	push   $0x364
f01023db:	68 15 57 10 f0       	push   $0xf0105715
f01023e0:	e8 f7 dc ff ff       	call   f01000dc <_panic>
f01023e5:	81 c6 00 10 00 00    	add    $0x1000,%esi
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f01023eb:	81 fe 00 00 00 f0    	cmp    $0xf0000000,%esi
f01023f1:	75 c6                	jne    f01023b9 <mem_init+0x12f5>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f01023f3:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f01023f8:	89 d8                	mov    %ebx,%eax
f01023fa:	e8 5f e5 ff ff       	call   f010095e <check_va2pa>
f01023ff:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102402:	74 51                	je     f0102455 <mem_init+0x1391>
f0102404:	68 f0 55 10 f0       	push   $0xf01055f0
f0102409:	68 3b 57 10 f0       	push   $0xf010573b
f010240e:	68 65 03 00 00       	push   $0x365
f0102413:	68 15 57 10 f0       	push   $0xf0105715
f0102418:	e8 bf dc ff ff       	call   f01000dc <_panic>

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f010241d:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f0102422:	72 36                	jb     f010245a <mem_init+0x1396>
f0102424:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f0102429:	76 07                	jbe    f0102432 <mem_init+0x136e>
f010242b:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102430:	75 28                	jne    f010245a <mem_init+0x1396>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
			assert(pgdir[i] & PTE_P);
f0102432:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f0102436:	0f 85 83 00 00 00    	jne    f01024bf <mem_init+0x13fb>
f010243c:	68 c8 59 10 f0       	push   $0xf01059c8
f0102441:	68 3b 57 10 f0       	push   $0xf010573b
f0102446:	68 6e 03 00 00       	push   $0x36e
f010244b:	68 15 57 10 f0       	push   $0xf0105715
f0102450:	e8 87 dc ff ff       	call   f01000dc <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102455:	b8 00 00 00 00       	mov    $0x0,%eax
		case PDX(UPAGES):
		case PDX(UENVS):
			assert(pgdir[i] & PTE_P);
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f010245a:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f010245f:	76 3f                	jbe    f01024a0 <mem_init+0x13dc>
				assert(pgdir[i] & PTE_P);
f0102461:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f0102464:	f6 c2 01             	test   $0x1,%dl
f0102467:	75 19                	jne    f0102482 <mem_init+0x13be>
f0102469:	68 c8 59 10 f0       	push   $0xf01059c8
f010246e:	68 3b 57 10 f0       	push   $0xf010573b
f0102473:	68 72 03 00 00       	push   $0x372
f0102478:	68 15 57 10 f0       	push   $0xf0105715
f010247d:	e8 5a dc ff ff       	call   f01000dc <_panic>
				assert(pgdir[i] & PTE_W);
f0102482:	f6 c2 02             	test   $0x2,%dl
f0102485:	75 38                	jne    f01024bf <mem_init+0x13fb>
f0102487:	68 d9 59 10 f0       	push   $0xf01059d9
f010248c:	68 3b 57 10 f0       	push   $0xf010573b
f0102491:	68 73 03 00 00       	push   $0x373
f0102496:	68 15 57 10 f0       	push   $0xf0105715
f010249b:	e8 3c dc ff ff       	call   f01000dc <_panic>
			} else
				assert(pgdir[i] == 0);
f01024a0:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f01024a4:	74 19                	je     f01024bf <mem_init+0x13fb>
f01024a6:	68 ea 59 10 f0       	push   $0xf01059ea
f01024ab:	68 3b 57 10 f0       	push   $0xf010573b
f01024b0:	68 75 03 00 00       	push   $0x375
f01024b5:	68 15 57 10 f0       	push   $0xf0105715
f01024ba:	e8 1d dc ff ff       	call   f01000dc <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f01024bf:	83 c0 01             	add    $0x1,%eax
f01024c2:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f01024c7:	0f 86 50 ff ff ff    	jbe    f010241d <mem_init+0x1359>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f01024cd:	83 ec 0c             	sub    $0xc,%esp
f01024d0:	68 20 56 10 f0       	push   $0xf0105620
f01024d5:	e8 20 0b 00 00       	call   f0102ffa <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f01024da:	a1 08 db 17 f0       	mov    0xf017db08,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01024df:	83 c4 10             	add    $0x10,%esp
f01024e2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01024e7:	77 15                	ja     f01024fe <mem_init+0x143a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01024e9:	50                   	push   %eax
f01024ea:	68 0c 50 10 f0       	push   $0xf010500c
f01024ef:	68 f6 00 00 00       	push   $0xf6
f01024f4:	68 15 57 10 f0       	push   $0xf0105715
f01024f9:	e8 de db ff ff       	call   f01000dc <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01024fe:	05 00 00 00 10       	add    $0x10000000,%eax
f0102503:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0102506:	b8 00 00 00 00       	mov    $0x0,%eax
f010250b:	e8 b2 e4 ff ff       	call   f01009c2 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0102510:	0f 20 c0             	mov    %cr0,%eax
f0102513:	83 e0 f3             	and    $0xfffffff3,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0102516:	0d 23 00 05 80       	or     $0x80050023,%eax
f010251b:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010251e:	83 ec 0c             	sub    $0xc,%esp
f0102521:	6a 00                	push   $0x0
f0102523:	e8 62 e8 ff ff       	call   f0100d8a <page_alloc>
f0102528:	89 c3                	mov    %eax,%ebx
f010252a:	83 c4 10             	add    $0x10,%esp
f010252d:	85 c0                	test   %eax,%eax
f010252f:	75 19                	jne    f010254a <mem_init+0x1486>
f0102531:	68 e6 57 10 f0       	push   $0xf01057e6
f0102536:	68 3b 57 10 f0       	push   $0xf010573b
f010253b:	68 35 04 00 00       	push   $0x435
f0102540:	68 15 57 10 f0       	push   $0xf0105715
f0102545:	e8 92 db ff ff       	call   f01000dc <_panic>
	assert((pp1 = page_alloc(0)));
f010254a:	83 ec 0c             	sub    $0xc,%esp
f010254d:	6a 00                	push   $0x0
f010254f:	e8 36 e8 ff ff       	call   f0100d8a <page_alloc>
f0102554:	89 c7                	mov    %eax,%edi
f0102556:	83 c4 10             	add    $0x10,%esp
f0102559:	85 c0                	test   %eax,%eax
f010255b:	75 19                	jne    f0102576 <mem_init+0x14b2>
f010255d:	68 fc 57 10 f0       	push   $0xf01057fc
f0102562:	68 3b 57 10 f0       	push   $0xf010573b
f0102567:	68 36 04 00 00       	push   $0x436
f010256c:	68 15 57 10 f0       	push   $0xf0105715
f0102571:	e8 66 db ff ff       	call   f01000dc <_panic>
	assert((pp2 = page_alloc(0)));
f0102576:	83 ec 0c             	sub    $0xc,%esp
f0102579:	6a 00                	push   $0x0
f010257b:	e8 0a e8 ff ff       	call   f0100d8a <page_alloc>
f0102580:	89 c6                	mov    %eax,%esi
f0102582:	83 c4 10             	add    $0x10,%esp
f0102585:	85 c0                	test   %eax,%eax
f0102587:	75 19                	jne    f01025a2 <mem_init+0x14de>
f0102589:	68 12 58 10 f0       	push   $0xf0105812
f010258e:	68 3b 57 10 f0       	push   $0xf010573b
f0102593:	68 37 04 00 00       	push   $0x437
f0102598:	68 15 57 10 f0       	push   $0xf0105715
f010259d:	e8 3a db ff ff       	call   f01000dc <_panic>
	page_free(pp0);
f01025a2:	83 ec 0c             	sub    $0xc,%esp
f01025a5:	53                   	push   %ebx
f01025a6:	e8 4f e8 ff ff       	call   f0100dfa <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01025ab:	89 f8                	mov    %edi,%eax
f01025ad:	2b 05 0c db 17 f0    	sub    0xf017db0c,%eax
f01025b3:	c1 f8 03             	sar    $0x3,%eax
f01025b6:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01025b9:	89 c2                	mov    %eax,%edx
f01025bb:	c1 ea 0c             	shr    $0xc,%edx
f01025be:	83 c4 10             	add    $0x10,%esp
f01025c1:	3b 15 04 db 17 f0    	cmp    0xf017db04,%edx
f01025c7:	72 12                	jb     f01025db <mem_init+0x1517>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01025c9:	50                   	push   %eax
f01025ca:	68 24 4f 10 f0       	push   $0xf0104f24
f01025cf:	6a 56                	push   $0x56
f01025d1:	68 21 57 10 f0       	push   $0xf0105721
f01025d6:	e8 01 db ff ff       	call   f01000dc <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f01025db:	83 ec 04             	sub    $0x4,%esp
f01025de:	68 00 10 00 00       	push   $0x1000
f01025e3:	6a 01                	push   $0x1
f01025e5:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01025ea:	50                   	push   %eax
f01025eb:	e8 3f 1f 00 00       	call   f010452f <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01025f0:	89 f0                	mov    %esi,%eax
f01025f2:	2b 05 0c db 17 f0    	sub    0xf017db0c,%eax
f01025f8:	c1 f8 03             	sar    $0x3,%eax
f01025fb:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01025fe:	89 c2                	mov    %eax,%edx
f0102600:	c1 ea 0c             	shr    $0xc,%edx
f0102603:	83 c4 10             	add    $0x10,%esp
f0102606:	3b 15 04 db 17 f0    	cmp    0xf017db04,%edx
f010260c:	72 12                	jb     f0102620 <mem_init+0x155c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010260e:	50                   	push   %eax
f010260f:	68 24 4f 10 f0       	push   $0xf0104f24
f0102614:	6a 56                	push   $0x56
f0102616:	68 21 57 10 f0       	push   $0xf0105721
f010261b:	e8 bc da ff ff       	call   f01000dc <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102620:	83 ec 04             	sub    $0x4,%esp
f0102623:	68 00 10 00 00       	push   $0x1000
f0102628:	6a 02                	push   $0x2
f010262a:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010262f:	50                   	push   %eax
f0102630:	e8 fa 1e 00 00       	call   f010452f <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102635:	6a 02                	push   $0x2
f0102637:	68 00 10 00 00       	push   $0x1000
f010263c:	57                   	push   %edi
f010263d:	ff 35 08 db 17 f0    	pushl  0xf017db08
f0102643:	e8 eb e9 ff ff       	call   f0101033 <page_insert>
	assert(pp1->pp_ref == 1);
f0102648:	83 c4 20             	add    $0x20,%esp
f010264b:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102650:	74 19                	je     f010266b <mem_init+0x15a7>
f0102652:	68 e3 58 10 f0       	push   $0xf01058e3
f0102657:	68 3b 57 10 f0       	push   $0xf010573b
f010265c:	68 3c 04 00 00       	push   $0x43c
f0102661:	68 15 57 10 f0       	push   $0xf0105715
f0102666:	e8 71 da ff ff       	call   f01000dc <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f010266b:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102672:	01 01 01 
f0102675:	74 19                	je     f0102690 <mem_init+0x15cc>
f0102677:	68 40 56 10 f0       	push   $0xf0105640
f010267c:	68 3b 57 10 f0       	push   $0xf010573b
f0102681:	68 3d 04 00 00       	push   $0x43d
f0102686:	68 15 57 10 f0       	push   $0xf0105715
f010268b:	e8 4c da ff ff       	call   f01000dc <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102690:	6a 02                	push   $0x2
f0102692:	68 00 10 00 00       	push   $0x1000
f0102697:	56                   	push   %esi
f0102698:	ff 35 08 db 17 f0    	pushl  0xf017db08
f010269e:	e8 90 e9 ff ff       	call   f0101033 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f01026a3:	83 c4 10             	add    $0x10,%esp
f01026a6:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f01026ad:	02 02 02 
f01026b0:	74 19                	je     f01026cb <mem_init+0x1607>
f01026b2:	68 64 56 10 f0       	push   $0xf0105664
f01026b7:	68 3b 57 10 f0       	push   $0xf010573b
f01026bc:	68 3f 04 00 00       	push   $0x43f
f01026c1:	68 15 57 10 f0       	push   $0xf0105715
f01026c6:	e8 11 da ff ff       	call   f01000dc <_panic>
	assert(pp2->pp_ref == 1);
f01026cb:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01026d0:	74 19                	je     f01026eb <mem_init+0x1627>
f01026d2:	68 05 59 10 f0       	push   $0xf0105905
f01026d7:	68 3b 57 10 f0       	push   $0xf010573b
f01026dc:	68 40 04 00 00       	push   $0x440
f01026e1:	68 15 57 10 f0       	push   $0xf0105715
f01026e6:	e8 f1 d9 ff ff       	call   f01000dc <_panic>
	assert(pp1->pp_ref == 0);
f01026eb:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f01026f0:	74 19                	je     f010270b <mem_init+0x1647>
f01026f2:	68 6f 59 10 f0       	push   $0xf010596f
f01026f7:	68 3b 57 10 f0       	push   $0xf010573b
f01026fc:	68 41 04 00 00       	push   $0x441
f0102701:	68 15 57 10 f0       	push   $0xf0105715
f0102706:	e8 d1 d9 ff ff       	call   f01000dc <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f010270b:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102712:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102715:	89 f0                	mov    %esi,%eax
f0102717:	2b 05 0c db 17 f0    	sub    0xf017db0c,%eax
f010271d:	c1 f8 03             	sar    $0x3,%eax
f0102720:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102723:	89 c2                	mov    %eax,%edx
f0102725:	c1 ea 0c             	shr    $0xc,%edx
f0102728:	3b 15 04 db 17 f0    	cmp    0xf017db04,%edx
f010272e:	72 12                	jb     f0102742 <mem_init+0x167e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102730:	50                   	push   %eax
f0102731:	68 24 4f 10 f0       	push   $0xf0104f24
f0102736:	6a 56                	push   $0x56
f0102738:	68 21 57 10 f0       	push   $0xf0105721
f010273d:	e8 9a d9 ff ff       	call   f01000dc <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102742:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102749:	03 03 03 
f010274c:	74 19                	je     f0102767 <mem_init+0x16a3>
f010274e:	68 88 56 10 f0       	push   $0xf0105688
f0102753:	68 3b 57 10 f0       	push   $0xf010573b
f0102758:	68 43 04 00 00       	push   $0x443
f010275d:	68 15 57 10 f0       	push   $0xf0105715
f0102762:	e8 75 d9 ff ff       	call   f01000dc <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102767:	83 ec 08             	sub    $0x8,%esp
f010276a:	68 00 10 00 00       	push   $0x1000
f010276f:	ff 35 08 db 17 f0    	pushl  0xf017db08
f0102775:	e8 7e e8 ff ff       	call   f0100ff8 <page_remove>
	assert(pp2->pp_ref == 0);
f010277a:	83 c4 10             	add    $0x10,%esp
f010277d:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102782:	74 19                	je     f010279d <mem_init+0x16d9>
f0102784:	68 3d 59 10 f0       	push   $0xf010593d
f0102789:	68 3b 57 10 f0       	push   $0xf010573b
f010278e:	68 45 04 00 00       	push   $0x445
f0102793:	68 15 57 10 f0       	push   $0xf0105715
f0102798:	e8 3f d9 ff ff       	call   f01000dc <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010279d:	8b 0d 08 db 17 f0    	mov    0xf017db08,%ecx
f01027a3:	8b 11                	mov    (%ecx),%edx
f01027a5:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01027ab:	89 d8                	mov    %ebx,%eax
f01027ad:	2b 05 0c db 17 f0    	sub    0xf017db0c,%eax
f01027b3:	c1 f8 03             	sar    $0x3,%eax
f01027b6:	c1 e0 0c             	shl    $0xc,%eax
f01027b9:	39 c2                	cmp    %eax,%edx
f01027bb:	74 19                	je     f01027d6 <mem_init+0x1712>
f01027bd:	68 98 51 10 f0       	push   $0xf0105198
f01027c2:	68 3b 57 10 f0       	push   $0xf010573b
f01027c7:	68 48 04 00 00       	push   $0x448
f01027cc:	68 15 57 10 f0       	push   $0xf0105715
f01027d1:	e8 06 d9 ff ff       	call   f01000dc <_panic>
	kern_pgdir[0] = 0;
f01027d6:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f01027dc:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01027e1:	74 19                	je     f01027fc <mem_init+0x1738>
f01027e3:	68 f4 58 10 f0       	push   $0xf01058f4
f01027e8:	68 3b 57 10 f0       	push   $0xf010573b
f01027ed:	68 4a 04 00 00       	push   $0x44a
f01027f2:	68 15 57 10 f0       	push   $0xf0105715
f01027f7:	e8 e0 d8 ff ff       	call   f01000dc <_panic>
	pp0->pp_ref = 0;
f01027fc:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102802:	83 ec 0c             	sub    $0xc,%esp
f0102805:	53                   	push   %ebx
f0102806:	e8 ef e5 ff ff       	call   f0100dfa <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f010280b:	c7 04 24 b4 56 10 f0 	movl   $0xf01056b4,(%esp)
f0102812:	e8 e3 07 00 00       	call   f0102ffa <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102817:	83 c4 10             	add    $0x10,%esp
f010281a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010281d:	5b                   	pop    %ebx
f010281e:	5e                   	pop    %esi
f010281f:	5f                   	pop    %edi
f0102820:	5d                   	pop    %ebp
f0102821:	c3                   	ret    

f0102822 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0102822:	55                   	push   %ebp
f0102823:	89 e5                	mov    %esp,%ebp
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0102825:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102828:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f010282b:	5d                   	pop    %ebp
f010282c:	c3                   	ret    

f010282d <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f010282d:	55                   	push   %ebp
f010282e:	89 e5                	mov    %esp,%ebp
f0102830:	57                   	push   %edi
f0102831:	56                   	push   %esi
f0102832:	53                   	push   %ebx
f0102833:	83 ec 1c             	sub    $0x1c,%esp
f0102836:	8b 7d 08             	mov    0x8(%ebp),%edi
f0102839:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 3: Your code here.
    pte_t * pte;
    void * end = (void *)va + len - 1;
    void * aligned_addr, *aligned_end;

    aligned_addr = ROUNDDOWN((void *)va, PGSIZE);
f010283c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010283f:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    aligned_end = ROUNDUP((void *)(va + len), PGSIZE);
f0102845:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102848:	03 45 10             	add    0x10(%ebp),%eax
f010284b:	05 ff 0f 00 00       	add    $0xfff,%eax
f0102850:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102855:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    if (aligned_addr >= (void *)ULIM)
f0102858:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f010285e:	76 57                	jbe    f01028b7 <user_mem_check+0x8a>
    {
        user_mem_check_addr = (uintptr_t)va;
f0102860:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102863:	a3 3c ce 17 f0       	mov    %eax,0xf017ce3c
        return -E_FAULT;
f0102868:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f010286d:	eb 52                	jmp    f01028c1 <user_mem_check+0x94>
    }

    for (; aligned_addr < aligned_end; aligned_addr += PGSIZE) {
        pte = pgdir_walk(env->env_pgdir, aligned_addr, 0);
f010286f:	83 ec 04             	sub    $0x4,%esp
f0102872:	6a 00                	push   $0x0
f0102874:	53                   	push   %ebx
f0102875:	ff 77 5c             	pushl  0x5c(%edi)
f0102878:	e8 df e5 ff ff       	call   f0100e5c <pgdir_walk>
        if (!pte || !(*pte & PTE_P) || (*pte & perm) != perm)
f010287d:	83 c4 10             	add    $0x10,%esp
f0102880:	85 c0                	test   %eax,%eax
f0102882:	74 0c                	je     f0102890 <user_mem_check+0x63>
f0102884:	8b 00                	mov    (%eax),%eax
f0102886:	a8 01                	test   $0x1,%al
f0102888:	74 06                	je     f0102890 <user_mem_check+0x63>
f010288a:	21 f0                	and    %esi,%eax
f010288c:	39 c6                	cmp    %eax,%esi
f010288e:	74 21                	je     f01028b1 <user_mem_check+0x84>
        {
            if (aligned_addr < va)
f0102890:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f0102893:	73 0f                	jae    f01028a4 <user_mem_check+0x77>
            {
                user_mem_check_addr = (uintptr_t)va;
f0102895:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102898:	a3 3c ce 17 f0       	mov    %eax,0xf017ce3c
            else
            {
                user_mem_check_addr = (uintptr_t)aligned_addr;
            }
            
            return -E_FAULT;
f010289d:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f01028a2:	eb 1d                	jmp    f01028c1 <user_mem_check+0x94>
            {
                user_mem_check_addr = (uintptr_t)va;
            }
            else
            {
                user_mem_check_addr = (uintptr_t)aligned_addr;
f01028a4:	89 1d 3c ce 17 f0    	mov    %ebx,0xf017ce3c
            }
            
            return -E_FAULT;
f01028aa:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f01028af:	eb 10                	jmp    f01028c1 <user_mem_check+0x94>
    {
        user_mem_check_addr = (uintptr_t)va;
        return -E_FAULT;
    }

    for (; aligned_addr < aligned_end; aligned_addr += PGSIZE) {
f01028b1:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01028b7:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f01028ba:	72 b3                	jb     f010286f <user_mem_check+0x42>
            
            return -E_FAULT;
        }
    }

	return 0;
f01028bc:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01028c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01028c4:	5b                   	pop    %ebx
f01028c5:	5e                   	pop    %esi
f01028c6:	5f                   	pop    %edi
f01028c7:	5d                   	pop    %ebp
f01028c8:	c3                   	ret    

f01028c9 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f01028c9:	55                   	push   %ebp
f01028ca:	89 e5                	mov    %esp,%ebp
f01028cc:	53                   	push   %ebx
f01028cd:	83 ec 04             	sub    $0x4,%esp
f01028d0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f01028d3:	8b 45 14             	mov    0x14(%ebp),%eax
f01028d6:	83 c8 04             	or     $0x4,%eax
f01028d9:	50                   	push   %eax
f01028da:	ff 75 10             	pushl  0x10(%ebp)
f01028dd:	ff 75 0c             	pushl  0xc(%ebp)
f01028e0:	53                   	push   %ebx
f01028e1:	e8 47 ff ff ff       	call   f010282d <user_mem_check>
f01028e6:	83 c4 10             	add    $0x10,%esp
f01028e9:	85 c0                	test   %eax,%eax
f01028eb:	79 21                	jns    f010290e <user_mem_assert+0x45>
		cprintf("[%08x] user_mem_check assertion failure for "
f01028ed:	83 ec 04             	sub    $0x4,%esp
f01028f0:	ff 35 3c ce 17 f0    	pushl  0xf017ce3c
f01028f6:	ff 73 48             	pushl  0x48(%ebx)
f01028f9:	68 e0 56 10 f0       	push   $0xf01056e0
f01028fe:	e8 f7 06 00 00       	call   f0102ffa <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0102903:	89 1c 24             	mov    %ebx,(%esp)
f0102906:	e8 d6 05 00 00       	call   f0102ee1 <env_destroy>
f010290b:	83 c4 10             	add    $0x10,%esp
	}
}
f010290e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102911:	c9                   	leave  
f0102912:	c3                   	ret    

f0102913 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0102913:	55                   	push   %ebp
f0102914:	89 e5                	mov    %esp,%ebp
f0102916:	57                   	push   %edi
f0102917:	56                   	push   %esi
f0102918:	53                   	push   %ebx
f0102919:	83 ec 0c             	sub    $0xc,%esp
f010291c:	89 c7                	mov    %eax,%edi
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	struct PageInfo *pp;
	uint32_t va_start = ROUNDDOWN((uint32_t)va, PGSIZE);
	uint32_t va_end = ROUNDUP((uint32_t)va+len, PGSIZE);
f010291e:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f0102925:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	int i;

	for (i = va_start; i < va_end; i+=PGSIZE)
f010292b:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102931:	89 d3                	mov    %edx,%ebx
f0102933:	eb 3c                	jmp    f0102971 <region_alloc+0x5e>
	{
	    pp = (struct PageInfo*)page_alloc(0);
f0102935:	83 ec 0c             	sub    $0xc,%esp
f0102938:	6a 00                	push   $0x0
f010293a:	e8 4b e4 ff ff       	call   f0100d8a <page_alloc>
	    if (!pp)
f010293f:	83 c4 10             	add    $0x10,%esp
f0102942:	85 c0                	test   %eax,%eax
f0102944:	75 16                	jne    f010295c <region_alloc+0x49>
	    {
	        int r = -E_NO_MEM;
	        panic("region_alloc: %e", r);
f0102946:	6a fc                	push   $0xfffffffc
f0102948:	68 f8 59 10 f0       	push   $0xf01059f8
f010294d:	68 25 01 00 00       	push   $0x125
f0102952:	68 09 5a 10 f0       	push   $0xf0105a09
f0102957:	e8 80 d7 ff ff       	call   f01000dc <_panic>
	    }
	    page_insert(e->env_pgdir, pp, (void*)i, PTE_U | PTE_W | PTE_P);
f010295c:	6a 07                	push   $0x7
f010295e:	53                   	push   %ebx
f010295f:	50                   	push   %eax
f0102960:	ff 77 5c             	pushl  0x5c(%edi)
f0102963:	e8 cb e6 ff ff       	call   f0101033 <page_insert>
	struct PageInfo *pp;
	uint32_t va_start = ROUNDDOWN((uint32_t)va, PGSIZE);
	uint32_t va_end = ROUNDUP((uint32_t)va+len, PGSIZE);
	int i;

	for (i = va_start; i < va_end; i+=PGSIZE)
f0102968:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010296e:	83 c4 10             	add    $0x10,%esp
f0102971:	39 f3                	cmp    %esi,%ebx
f0102973:	72 c0                	jb     f0102935 <region_alloc+0x22>
	        int r = -E_NO_MEM;
	        panic("region_alloc: %e", r);
	    }
	    page_insert(e->env_pgdir, pp, (void*)i, PTE_U | PTE_W | PTE_P);
	}
}
f0102975:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102978:	5b                   	pop    %ebx
f0102979:	5e                   	pop    %esi
f010297a:	5f                   	pop    %edi
f010297b:	5d                   	pop    %ebp
f010297c:	c3                   	ret    

f010297d <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f010297d:	55                   	push   %ebp
f010297e:	89 e5                	mov    %esp,%ebp
f0102980:	8b 55 08             	mov    0x8(%ebp),%edx
f0102983:	8b 4d 10             	mov    0x10(%ebp),%ecx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0102986:	85 d2                	test   %edx,%edx
f0102988:	75 11                	jne    f010299b <envid2env+0x1e>
		*env_store = curenv;
f010298a:	a1 48 ce 17 f0       	mov    0xf017ce48,%eax
f010298f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102992:	89 01                	mov    %eax,(%ecx)
		return 0;
f0102994:	b8 00 00 00 00       	mov    $0x0,%eax
f0102999:	eb 5e                	jmp    f01029f9 <envid2env+0x7c>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f010299b:	89 d0                	mov    %edx,%eax
f010299d:	25 ff 03 00 00       	and    $0x3ff,%eax
f01029a2:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01029a5:	c1 e0 05             	shl    $0x5,%eax
f01029a8:	03 05 4c ce 17 f0    	add    0xf017ce4c,%eax
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f01029ae:	83 78 54 00          	cmpl   $0x0,0x54(%eax)
f01029b2:	74 05                	je     f01029b9 <envid2env+0x3c>
f01029b4:	3b 50 48             	cmp    0x48(%eax),%edx
f01029b7:	74 10                	je     f01029c9 <envid2env+0x4c>
		*env_store = 0;
f01029b9:	8b 45 0c             	mov    0xc(%ebp),%eax
f01029bc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f01029c2:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01029c7:	eb 30                	jmp    f01029f9 <envid2env+0x7c>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f01029c9:	84 c9                	test   %cl,%cl
f01029cb:	74 22                	je     f01029ef <envid2env+0x72>
f01029cd:	8b 15 48 ce 17 f0    	mov    0xf017ce48,%edx
f01029d3:	39 d0                	cmp    %edx,%eax
f01029d5:	74 18                	je     f01029ef <envid2env+0x72>
f01029d7:	8b 4a 48             	mov    0x48(%edx),%ecx
f01029da:	39 48 4c             	cmp    %ecx,0x4c(%eax)
f01029dd:	74 10                	je     f01029ef <envid2env+0x72>
		*env_store = 0;
f01029df:	8b 45 0c             	mov    0xc(%ebp),%eax
f01029e2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f01029e8:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01029ed:	eb 0a                	jmp    f01029f9 <envid2env+0x7c>
	}

	*env_store = e;
f01029ef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01029f2:	89 01                	mov    %eax,(%ecx)
	return 0;
f01029f4:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01029f9:	5d                   	pop    %ebp
f01029fa:	c3                   	ret    

f01029fb <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f01029fb:	55                   	push   %ebp
f01029fc:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f01029fe:	b8 00 b3 11 f0       	mov    $0xf011b300,%eax
f0102a03:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f0102a06:	b8 23 00 00 00       	mov    $0x23,%eax
f0102a0b:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f0102a0d:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f0102a0f:	b8 10 00 00 00       	mov    $0x10,%eax
f0102a14:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f0102a16:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f0102a18:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f0102a1a:	ea 21 2a 10 f0 08 00 	ljmp   $0x8,$0xf0102a21
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f0102a21:	b8 00 00 00 00       	mov    $0x0,%eax
f0102a26:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0102a29:	5d                   	pop    %ebp
f0102a2a:	c3                   	ret    

f0102a2b <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0102a2b:	55                   	push   %ebp
f0102a2c:	89 e5                	mov    %esp,%ebp
f0102a2e:	56                   	push   %esi
f0102a2f:	53                   	push   %ebx
	// LAB 3: Your code here.
    int i;

    for (i = NENV-1; i >= 0; i--)
    {
        envs[i].env_id = 0;
f0102a30:	8b 35 4c ce 17 f0    	mov    0xf017ce4c,%esi
f0102a36:	8b 15 50 ce 17 f0    	mov    0xf017ce50,%edx
f0102a3c:	8d 86 a0 7f 01 00    	lea    0x17fa0(%esi),%eax
f0102a42:	8d 5e a0             	lea    -0x60(%esi),%ebx
f0102a45:	89 c1                	mov    %eax,%ecx
f0102a47:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
        envs[i].env_link = env_free_list;
f0102a4e:	89 50 44             	mov    %edx,0x44(%eax)
f0102a51:	83 e8 60             	sub    $0x60,%eax
        env_free_list = &envs[i];
f0102a54:	89 ca                	mov    %ecx,%edx
{
	// Set up envs array
	// LAB 3: Your code here.
    int i;

    for (i = NENV-1; i >= 0; i--)
f0102a56:	39 d8                	cmp    %ebx,%eax
f0102a58:	75 eb                	jne    f0102a45 <env_init+0x1a>
f0102a5a:	89 35 50 ce 17 f0    	mov    %esi,0xf017ce50
        envs[i].env_link = env_free_list;
        env_free_list = &envs[i];
    }
	// Per-CPU part of the initialization

	env_init_percpu();
f0102a60:	e8 96 ff ff ff       	call   f01029fb <env_init_percpu>
}
f0102a65:	5b                   	pop    %ebx
f0102a66:	5e                   	pop    %esi
f0102a67:	5d                   	pop    %ebp
f0102a68:	c3                   	ret    

f0102a69 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0102a69:	55                   	push   %ebp
f0102a6a:	89 e5                	mov    %esp,%ebp
f0102a6c:	56                   	push   %esi
f0102a6d:	53                   	push   %ebx
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0102a6e:	8b 1d 50 ce 17 f0    	mov    0xf017ce50,%ebx
f0102a74:	85 db                	test   %ebx,%ebx
f0102a76:	0f 84 45 01 00 00    	je     f0102bc1 <env_alloc+0x158>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0102a7c:	83 ec 0c             	sub    $0xc,%esp
f0102a7f:	6a 01                	push   $0x1
f0102a81:	e8 04 e3 ff ff       	call   f0100d8a <page_alloc>
f0102a86:	89 c6                	mov    %eax,%esi
f0102a88:	83 c4 10             	add    $0x10,%esp
f0102a8b:	85 c0                	test   %eax,%eax
f0102a8d:	0f 84 35 01 00 00    	je     f0102bc8 <env_alloc+0x15f>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102a93:	2b 05 0c db 17 f0    	sub    0xf017db0c,%eax
f0102a99:	c1 f8 03             	sar    $0x3,%eax
f0102a9c:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102a9f:	89 c2                	mov    %eax,%edx
f0102aa1:	c1 ea 0c             	shr    $0xc,%edx
f0102aa4:	3b 15 04 db 17 f0    	cmp    0xf017db04,%edx
f0102aaa:	72 12                	jb     f0102abe <env_alloc+0x55>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102aac:	50                   	push   %eax
f0102aad:	68 24 4f 10 f0       	push   $0xf0104f24
f0102ab2:	6a 56                	push   $0x56
f0102ab4:	68 21 57 10 f0       	push   $0xf0105721
f0102ab9:	e8 1e d6 ff ff       	call   f01000dc <_panic>
	return (void *)(pa + KERNBASE);
f0102abe:	2d 00 00 00 10       	sub    $0x10000000,%eax
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	e->env_pgdir = page2kva(p);
f0102ac3:	89 43 5c             	mov    %eax,0x5c(%ebx)

    memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
f0102ac6:	83 ec 04             	sub    $0x4,%esp
f0102ac9:	68 00 10 00 00       	push   $0x1000
f0102ace:	ff 35 08 db 17 f0    	pushl  0xf017db08
f0102ad4:	50                   	push   %eax
f0102ad5:	e8 0a 1b 00 00       	call   f01045e4 <memcpy>
    p->pp_ref++;
f0102ada:	66 83 46 04 01       	addw   $0x1,0x4(%esi)

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0102adf:	8b 43 5c             	mov    0x5c(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102ae2:	83 c4 10             	add    $0x10,%esp
f0102ae5:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102aea:	77 15                	ja     f0102b01 <env_alloc+0x98>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102aec:	50                   	push   %eax
f0102aed:	68 0c 50 10 f0       	push   $0xf010500c
f0102af2:	68 c5 00 00 00       	push   $0xc5
f0102af7:	68 09 5a 10 f0       	push   $0xf0105a09
f0102afc:	e8 db d5 ff ff       	call   f01000dc <_panic>
f0102b01:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0102b07:	83 ca 05             	or     $0x5,%edx
f0102b0a:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0102b10:	8b 43 48             	mov    0x48(%ebx),%eax
f0102b13:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0102b18:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0102b1d:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102b22:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0102b25:	89 da                	mov    %ebx,%edx
f0102b27:	2b 15 4c ce 17 f0    	sub    0xf017ce4c,%edx
f0102b2d:	c1 fa 05             	sar    $0x5,%edx
f0102b30:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0102b36:	09 d0                	or     %edx,%eax
f0102b38:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0102b3b:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102b3e:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0102b41:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0102b48:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0102b4f:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0102b56:	83 ec 04             	sub    $0x4,%esp
f0102b59:	6a 44                	push   $0x44
f0102b5b:	6a 00                	push   $0x0
f0102b5d:	53                   	push   %ebx
f0102b5e:	e8 cc 19 00 00       	call   f010452f <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0102b63:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0102b69:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0102b6f:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0102b75:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0102b7c:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// commit the allocation
	env_free_list = e->env_link;
f0102b82:	8b 43 44             	mov    0x44(%ebx),%eax
f0102b85:	a3 50 ce 17 f0       	mov    %eax,0xf017ce50
	*newenv_store = e;
f0102b8a:	8b 45 08             	mov    0x8(%ebp),%eax
f0102b8d:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0102b8f:	8b 53 48             	mov    0x48(%ebx),%edx
f0102b92:	a1 48 ce 17 f0       	mov    0xf017ce48,%eax
f0102b97:	83 c4 10             	add    $0x10,%esp
f0102b9a:	85 c0                	test   %eax,%eax
f0102b9c:	74 05                	je     f0102ba3 <env_alloc+0x13a>
f0102b9e:	8b 40 48             	mov    0x48(%eax),%eax
f0102ba1:	eb 05                	jmp    f0102ba8 <env_alloc+0x13f>
f0102ba3:	b8 00 00 00 00       	mov    $0x0,%eax
f0102ba8:	83 ec 04             	sub    $0x4,%esp
f0102bab:	52                   	push   %edx
f0102bac:	50                   	push   %eax
f0102bad:	68 14 5a 10 f0       	push   $0xf0105a14
f0102bb2:	e8 43 04 00 00       	call   f0102ffa <cprintf>
	return 0;
f0102bb7:	83 c4 10             	add    $0x10,%esp
f0102bba:	b8 00 00 00 00       	mov    $0x0,%eax
f0102bbf:	eb 0c                	jmp    f0102bcd <env_alloc+0x164>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f0102bc1:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0102bc6:	eb 05                	jmp    f0102bcd <env_alloc+0x164>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0102bc8:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0102bcd:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0102bd0:	5b                   	pop    %ebx
f0102bd1:	5e                   	pop    %esi
f0102bd2:	5d                   	pop    %ebp
f0102bd3:	c3                   	ret    

f0102bd4 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0102bd4:	55                   	push   %ebp
f0102bd5:	89 e5                	mov    %esp,%ebp
f0102bd7:	57                   	push   %edi
f0102bd8:	56                   	push   %esi
f0102bd9:	53                   	push   %ebx
f0102bda:	83 ec 34             	sub    $0x34,%esp
f0102bdd:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.
	struct Env *e = NULL;
f0102be0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	int r;
	if ((r = env_alloc(&e, 0)) < 0)
f0102be7:	6a 00                	push   $0x0
f0102be9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0102bec:	50                   	push   %eax
f0102bed:	e8 77 fe ff ff       	call   f0102a69 <env_alloc>
f0102bf2:	83 c4 10             	add    $0x10,%esp
f0102bf5:	85 c0                	test   %eax,%eax
f0102bf7:	79 15                	jns    f0102c0e <env_create+0x3a>
	{
	    panic("env create: %e", r);
f0102bf9:	50                   	push   %eax
f0102bfa:	68 29 5a 10 f0       	push   $0xf0105a29
f0102bff:	68 8f 01 00 00       	push   $0x18f
f0102c04:	68 09 5a 10 f0       	push   $0xf0105a09
f0102c09:	e8 ce d4 ff ff       	call   f01000dc <_panic>
	    return;
	}
	load_icode(e, binary);
f0102c0e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102c11:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	//  What?  (See env_run() and env_pop_tf() below.)

	// LAB 3: Your code here.
    struct Elf *elfhdr = (struct Elf *) binary;
    struct Proghdr *ph, *eph;
    if (elfhdr->e_magic != ELF_MAGIC)
f0102c14:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f0102c1a:	74 17                	je     f0102c33 <env_create+0x5f>
        panic("elf header's magic is not correct\n");
f0102c1c:	83 ec 04             	sub    $0x4,%esp
f0102c1f:	68 5c 5a 10 f0       	push   $0xf0105a5c
f0102c24:	68 64 01 00 00       	push   $0x164
f0102c29:	68 09 5a 10 f0       	push   $0xf0105a09
f0102c2e:	e8 a9 d4 ff ff       	call   f01000dc <_panic>
    ph = (struct Proghdr *) ((uint8_t *) elfhdr + elfhdr->e_phoff);
f0102c33:	89 fb                	mov    %edi,%ebx
f0102c35:	03 5f 1c             	add    0x1c(%edi),%ebx
    eph = ph + elfhdr->e_phnum;
f0102c38:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f0102c3c:	c1 e6 05             	shl    $0x5,%esi
f0102c3f:	01 de                	add    %ebx,%esi

    lcr3(PADDR(e->env_pgdir));
f0102c41:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102c44:	8b 40 5c             	mov    0x5c(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102c47:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102c4c:	77 15                	ja     f0102c63 <env_create+0x8f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102c4e:	50                   	push   %eax
f0102c4f:	68 0c 50 10 f0       	push   $0xf010500c
f0102c54:	68 68 01 00 00       	push   $0x168
f0102c59:	68 09 5a 10 f0       	push   $0xf0105a09
f0102c5e:	e8 79 d4 ff ff       	call   f01000dc <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102c63:	05 00 00 00 10       	add    $0x10000000,%eax
f0102c68:	0f 22 d8             	mov    %eax,%cr3
f0102c6b:	eb 60                	jmp    f0102ccd <env_create+0xf9>

    for ( ;ph < eph; ph++) {
        if (ph->p_type != ELF_PROG_LOAD) 
f0102c6d:	83 3b 01             	cmpl   $0x1,(%ebx)
f0102c70:	75 58                	jne    f0102cca <env_create+0xf6>
            continue;
        if (ph->p_filesz > ph->p_memsz)
f0102c72:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0102c75:	39 4b 10             	cmp    %ecx,0x10(%ebx)
f0102c78:	76 17                	jbe    f0102c91 <env_create+0xbd>
            panic("file size is great than memory size\n");
f0102c7a:	83 ec 04             	sub    $0x4,%esp
f0102c7d:	68 80 5a 10 f0       	push   $0xf0105a80
f0102c82:	68 6e 01 00 00       	push   $0x16e
f0102c87:	68 09 5a 10 f0       	push   $0xf0105a09
f0102c8c:	e8 4b d4 ff ff       	call   f01000dc <_panic>
        region_alloc(e, (void *) ph->p_va, ph->p_memsz);
f0102c91:	8b 53 08             	mov    0x8(%ebx),%edx
f0102c94:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102c97:	e8 77 fc ff ff       	call   f0102913 <region_alloc>
        memcpy((void *) ph->p_va, binary+ph->p_offset, ph->p_filesz);
f0102c9c:	83 ec 04             	sub    $0x4,%esp
f0102c9f:	ff 73 10             	pushl  0x10(%ebx)
f0102ca2:	89 f8                	mov    %edi,%eax
f0102ca4:	03 43 04             	add    0x4(%ebx),%eax
f0102ca7:	50                   	push   %eax
f0102ca8:	ff 73 08             	pushl  0x8(%ebx)
f0102cab:	e8 34 19 00 00       	call   f01045e4 <memcpy>
        // clear bss section
        memset((void *) ph->p_va + ph->p_filesz, 0, (ph->p_memsz - ph->p_filesz));
f0102cb0:	8b 43 10             	mov    0x10(%ebx),%eax
f0102cb3:	83 c4 0c             	add    $0xc,%esp
f0102cb6:	8b 53 14             	mov    0x14(%ebx),%edx
f0102cb9:	29 c2                	sub    %eax,%edx
f0102cbb:	52                   	push   %edx
f0102cbc:	6a 00                	push   $0x0
f0102cbe:	03 43 08             	add    0x8(%ebx),%eax
f0102cc1:	50                   	push   %eax
f0102cc2:	e8 68 18 00 00       	call   f010452f <memset>
f0102cc7:	83 c4 10             	add    $0x10,%esp
    ph = (struct Proghdr *) ((uint8_t *) elfhdr + elfhdr->e_phoff);
    eph = ph + elfhdr->e_phnum;

    lcr3(PADDR(e->env_pgdir));

    for ( ;ph < eph; ph++) {
f0102cca:	83 c3 20             	add    $0x20,%ebx
f0102ccd:	39 de                	cmp    %ebx,%esi
f0102ccf:	77 9c                	ja     f0102c6d <env_create+0x99>
        memcpy((void *) ph->p_va, binary+ph->p_offset, ph->p_filesz);
        // clear bss section
        memset((void *) ph->p_va + ph->p_filesz, 0, (ph->p_memsz - ph->p_filesz));
    }   

    e->env_tf.tf_eip = elfhdr->e_entry;
f0102cd1:	8b 47 18             	mov    0x18(%edi),%eax
f0102cd4:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102cd7:	89 47 30             	mov    %eax,0x30(%edi)

	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
    region_alloc(e, (void *) USTACKTOP - PGSIZE, PGSIZE);                                                                                                                                      
f0102cda:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0102cdf:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0102ce4:	89 f8                	mov    %edi,%eax
f0102ce6:	e8 28 fc ff ff       	call   f0102913 <region_alloc>

    lcr3(PADDR(kern_pgdir));
f0102ceb:	a1 08 db 17 f0       	mov    0xf017db08,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102cf0:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102cf5:	77 15                	ja     f0102d0c <env_create+0x138>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102cf7:	50                   	push   %eax
f0102cf8:	68 0c 50 10 f0       	push   $0xf010500c
f0102cfd:	68 7d 01 00 00       	push   $0x17d
f0102d02:	68 09 5a 10 f0       	push   $0xf0105a09
f0102d07:	e8 d0 d3 ff ff       	call   f01000dc <_panic>
f0102d0c:	05 00 00 00 10       	add    $0x10000000,%eax
f0102d11:	0f 22 d8             	mov    %eax,%cr3
	{
	    panic("env create: %e", r);
	    return;
	}
	load_icode(e, binary);
	e->env_type = type;
f0102d14:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102d17:	8b 55 0c             	mov    0xc(%ebp),%edx
f0102d1a:	89 50 50             	mov    %edx,0x50(%eax)
}
f0102d1d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102d20:	5b                   	pop    %ebx
f0102d21:	5e                   	pop    %esi
f0102d22:	5f                   	pop    %edi
f0102d23:	5d                   	pop    %ebp
f0102d24:	c3                   	ret    

f0102d25 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0102d25:	55                   	push   %ebp
f0102d26:	89 e5                	mov    %esp,%ebp
f0102d28:	57                   	push   %edi
f0102d29:	56                   	push   %esi
f0102d2a:	53                   	push   %ebx
f0102d2b:	83 ec 1c             	sub    $0x1c,%esp
f0102d2e:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0102d31:	8b 15 48 ce 17 f0    	mov    0xf017ce48,%edx
f0102d37:	39 fa                	cmp    %edi,%edx
f0102d39:	75 29                	jne    f0102d64 <env_free+0x3f>
		lcr3(PADDR(kern_pgdir));
f0102d3b:	a1 08 db 17 f0       	mov    0xf017db08,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102d40:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102d45:	77 15                	ja     f0102d5c <env_free+0x37>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102d47:	50                   	push   %eax
f0102d48:	68 0c 50 10 f0       	push   $0xf010500c
f0102d4d:	68 a4 01 00 00       	push   $0x1a4
f0102d52:	68 09 5a 10 f0       	push   $0xf0105a09
f0102d57:	e8 80 d3 ff ff       	call   f01000dc <_panic>
f0102d5c:	05 00 00 00 10       	add    $0x10000000,%eax
f0102d61:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0102d64:	8b 4f 48             	mov    0x48(%edi),%ecx
f0102d67:	85 d2                	test   %edx,%edx
f0102d69:	74 05                	je     f0102d70 <env_free+0x4b>
f0102d6b:	8b 42 48             	mov    0x48(%edx),%eax
f0102d6e:	eb 05                	jmp    f0102d75 <env_free+0x50>
f0102d70:	b8 00 00 00 00       	mov    $0x0,%eax
f0102d75:	83 ec 04             	sub    $0x4,%esp
f0102d78:	51                   	push   %ecx
f0102d79:	50                   	push   %eax
f0102d7a:	68 38 5a 10 f0       	push   $0xf0105a38
f0102d7f:	e8 76 02 00 00       	call   f0102ffa <cprintf>
f0102d84:	83 c4 10             	add    $0x10,%esp

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0102d87:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0102d8e:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0102d91:	89 d0                	mov    %edx,%eax
f0102d93:	c1 e0 02             	shl    $0x2,%eax
f0102d96:	89 45 dc             	mov    %eax,-0x24(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0102d99:	8b 47 5c             	mov    0x5c(%edi),%eax
f0102d9c:	8b 34 90             	mov    (%eax,%edx,4),%esi
f0102d9f:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0102da5:	0f 84 a8 00 00 00    	je     f0102e53 <env_free+0x12e>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0102dab:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102db1:	89 f0                	mov    %esi,%eax
f0102db3:	c1 e8 0c             	shr    $0xc,%eax
f0102db6:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102db9:	39 05 04 db 17 f0    	cmp    %eax,0xf017db04
f0102dbf:	77 15                	ja     f0102dd6 <env_free+0xb1>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102dc1:	56                   	push   %esi
f0102dc2:	68 24 4f 10 f0       	push   $0xf0104f24
f0102dc7:	68 b3 01 00 00       	push   $0x1b3
f0102dcc:	68 09 5a 10 f0       	push   $0xf0105a09
f0102dd1:	e8 06 d3 ff ff       	call   f01000dc <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0102dd6:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102dd9:	c1 e0 16             	shl    $0x16,%eax
f0102ddc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0102ddf:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0102de4:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0102deb:	01 
f0102dec:	74 17                	je     f0102e05 <env_free+0xe0>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0102dee:	83 ec 08             	sub    $0x8,%esp
f0102df1:	89 d8                	mov    %ebx,%eax
f0102df3:	c1 e0 0c             	shl    $0xc,%eax
f0102df6:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0102df9:	50                   	push   %eax
f0102dfa:	ff 77 5c             	pushl  0x5c(%edi)
f0102dfd:	e8 f6 e1 ff ff       	call   f0100ff8 <page_remove>
f0102e02:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0102e05:	83 c3 01             	add    $0x1,%ebx
f0102e08:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0102e0e:	75 d4                	jne    f0102de4 <env_free+0xbf>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0102e10:	8b 47 5c             	mov    0x5c(%edi),%eax
f0102e13:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102e16:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102e1d:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0102e20:	3b 05 04 db 17 f0    	cmp    0xf017db04,%eax
f0102e26:	72 14                	jb     f0102e3c <env_free+0x117>
		panic("pa2page called with invalid pa");
f0102e28:	83 ec 04             	sub    $0x4,%esp
f0102e2b:	68 64 50 10 f0       	push   $0xf0105064
f0102e30:	6a 4f                	push   $0x4f
f0102e32:	68 21 57 10 f0       	push   $0xf0105721
f0102e37:	e8 a0 d2 ff ff       	call   f01000dc <_panic>
		page_decref(pa2page(pa));
f0102e3c:	83 ec 0c             	sub    $0xc,%esp
f0102e3f:	a1 0c db 17 f0       	mov    0xf017db0c,%eax
f0102e44:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0102e47:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f0102e4a:	50                   	push   %eax
f0102e4b:	e8 e5 df ff ff       	call   f0100e35 <page_decref>
f0102e50:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0102e53:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0102e57:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102e5a:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f0102e5f:	0f 85 29 ff ff ff    	jne    f0102d8e <env_free+0x69>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0102e65:	8b 47 5c             	mov    0x5c(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102e68:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102e6d:	77 15                	ja     f0102e84 <env_free+0x15f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102e6f:	50                   	push   %eax
f0102e70:	68 0c 50 10 f0       	push   $0xf010500c
f0102e75:	68 c1 01 00 00       	push   $0x1c1
f0102e7a:	68 09 5a 10 f0       	push   $0xf0105a09
f0102e7f:	e8 58 d2 ff ff       	call   f01000dc <_panic>
	e->env_pgdir = 0;
f0102e84:	c7 47 5c 00 00 00 00 	movl   $0x0,0x5c(%edi)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102e8b:	05 00 00 00 10       	add    $0x10000000,%eax
f0102e90:	c1 e8 0c             	shr    $0xc,%eax
f0102e93:	3b 05 04 db 17 f0    	cmp    0xf017db04,%eax
f0102e99:	72 14                	jb     f0102eaf <env_free+0x18a>
		panic("pa2page called with invalid pa");
f0102e9b:	83 ec 04             	sub    $0x4,%esp
f0102e9e:	68 64 50 10 f0       	push   $0xf0105064
f0102ea3:	6a 4f                	push   $0x4f
f0102ea5:	68 21 57 10 f0       	push   $0xf0105721
f0102eaa:	e8 2d d2 ff ff       	call   f01000dc <_panic>
	page_decref(pa2page(pa));
f0102eaf:	83 ec 0c             	sub    $0xc,%esp
f0102eb2:	8b 15 0c db 17 f0    	mov    0xf017db0c,%edx
f0102eb8:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0102ebb:	50                   	push   %eax
f0102ebc:	e8 74 df ff ff       	call   f0100e35 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0102ec1:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0102ec8:	a1 50 ce 17 f0       	mov    0xf017ce50,%eax
f0102ecd:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0102ed0:	89 3d 50 ce 17 f0    	mov    %edi,0xf017ce50
}
f0102ed6:	83 c4 10             	add    $0x10,%esp
f0102ed9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102edc:	5b                   	pop    %ebx
f0102edd:	5e                   	pop    %esi
f0102ede:	5f                   	pop    %edi
f0102edf:	5d                   	pop    %ebp
f0102ee0:	c3                   	ret    

f0102ee1 <env_destroy>:
//
// Frees environment e.
//
void
env_destroy(struct Env *e)
{
f0102ee1:	55                   	push   %ebp
f0102ee2:	89 e5                	mov    %esp,%ebp
f0102ee4:	83 ec 14             	sub    $0x14,%esp
	env_free(e);
f0102ee7:	ff 75 08             	pushl  0x8(%ebp)
f0102eea:	e8 36 fe ff ff       	call   f0102d25 <env_free>

	cprintf("Destroyed the only environment - nothing more to do!\n");
f0102eef:	c7 04 24 a8 5a 10 f0 	movl   $0xf0105aa8,(%esp)
f0102ef6:	e8 ff 00 00 00       	call   f0102ffa <cprintf>
f0102efb:	83 c4 10             	add    $0x10,%esp
	while (1)
		monitor(NULL);
f0102efe:	83 ec 0c             	sub    $0xc,%esp
f0102f01:	6a 00                	push   $0x0
f0102f03:	e8 d4 d8 ff ff       	call   f01007dc <monitor>
f0102f08:	83 c4 10             	add    $0x10,%esp
f0102f0b:	eb f1                	jmp    f0102efe <env_destroy+0x1d>

f0102f0d <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0102f0d:	55                   	push   %ebp
f0102f0e:	89 e5                	mov    %esp,%ebp
f0102f10:	83 ec 0c             	sub    $0xc,%esp
	__asm __volatile("movl %0,%%esp\n"
f0102f13:	8b 65 08             	mov    0x8(%ebp),%esp
f0102f16:	61                   	popa   
f0102f17:	07                   	pop    %es
f0102f18:	1f                   	pop    %ds
f0102f19:	83 c4 08             	add    $0x8,%esp
f0102f1c:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0102f1d:	68 4e 5a 10 f0       	push   $0xf0105a4e
f0102f22:	68 e9 01 00 00       	push   $0x1e9
f0102f27:	68 09 5a 10 f0       	push   $0xf0105a09
f0102f2c:	e8 ab d1 ff ff       	call   f01000dc <_panic>

f0102f31 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0102f31:	55                   	push   %ebp
f0102f32:	89 e5                	mov    %esp,%ebp
f0102f34:	83 ec 08             	sub    $0x8,%esp
f0102f37:	8b 45 08             	mov    0x8(%ebp),%eax
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if (curenv)
f0102f3a:	8b 15 48 ce 17 f0    	mov    0xf017ce48,%edx
f0102f40:	85 d2                	test   %edx,%edx
f0102f42:	74 0d                	je     f0102f51 <env_run+0x20>
	{
	    if (curenv->env_status == ENV_RUNNING)
f0102f44:	83 7a 54 03          	cmpl   $0x3,0x54(%edx)
f0102f48:	75 07                	jne    f0102f51 <env_run+0x20>
	    {
    	    curenv->env_status = ENV_RUNNABLE;
f0102f4a:	c7 42 54 02 00 00 00 	movl   $0x2,0x54(%edx)
	    }
	}
	curenv = e;
f0102f51:	a3 48 ce 17 f0       	mov    %eax,0xf017ce48
	e->env_status = ENV_RUNNING;
f0102f56:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	e->env_runs++;
f0102f5d:	83 40 58 01          	addl   $0x1,0x58(%eax)
	lcr3(PADDR(e->env_pgdir));
f0102f61:	8b 50 5c             	mov    0x5c(%eax),%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102f64:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102f6a:	77 15                	ja     f0102f81 <env_run+0x50>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102f6c:	52                   	push   %edx
f0102f6d:	68 0c 50 10 f0       	push   $0xf010500c
f0102f72:	68 11 02 00 00       	push   $0x211
f0102f77:	68 09 5a 10 f0       	push   $0xf0105a09
f0102f7c:	e8 5b d1 ff ff       	call   f01000dc <_panic>
f0102f81:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0102f87:	0f 22 da             	mov    %edx,%cr3

    env_pop_tf(&e->env_tf);
f0102f8a:	83 ec 0c             	sub    $0xc,%esp
f0102f8d:	50                   	push   %eax
f0102f8e:	e8 7a ff ff ff       	call   f0102f0d <env_pop_tf>

f0102f93 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0102f93:	55                   	push   %ebp
f0102f94:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102f96:	ba 70 00 00 00       	mov    $0x70,%edx
f0102f9b:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f9e:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0102f9f:	ba 71 00 00 00       	mov    $0x71,%edx
f0102fa4:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0102fa5:	0f b6 c0             	movzbl %al,%eax
}
f0102fa8:	5d                   	pop    %ebp
f0102fa9:	c3                   	ret    

f0102faa <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0102faa:	55                   	push   %ebp
f0102fab:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102fad:	ba 70 00 00 00       	mov    $0x70,%edx
f0102fb2:	8b 45 08             	mov    0x8(%ebp),%eax
f0102fb5:	ee                   	out    %al,(%dx)
f0102fb6:	ba 71 00 00 00       	mov    $0x71,%edx
f0102fbb:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102fbe:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0102fbf:	5d                   	pop    %ebp
f0102fc0:	c3                   	ret    

f0102fc1 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0102fc1:	55                   	push   %ebp
f0102fc2:	89 e5                	mov    %esp,%ebp
f0102fc4:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0102fc7:	ff 75 08             	pushl  0x8(%ebp)
f0102fca:	e8 74 d6 ff ff       	call   f0100643 <cputchar>
	*cnt++;
}
f0102fcf:	83 c4 10             	add    $0x10,%esp
f0102fd2:	c9                   	leave  
f0102fd3:	c3                   	ret    

f0102fd4 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0102fd4:	55                   	push   %ebp
f0102fd5:	89 e5                	mov    %esp,%ebp
f0102fd7:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0102fda:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0102fe1:	ff 75 0c             	pushl  0xc(%ebp)
f0102fe4:	ff 75 08             	pushl  0x8(%ebp)
f0102fe7:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0102fea:	50                   	push   %eax
f0102feb:	68 c1 2f 10 f0       	push   $0xf0102fc1
f0102ff0:	e8 ae 0d 00 00       	call   f0103da3 <vprintfmt>
	return cnt;
}
f0102ff5:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102ff8:	c9                   	leave  
f0102ff9:	c3                   	ret    

f0102ffa <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0102ffa:	55                   	push   %ebp
f0102ffb:	89 e5                	mov    %esp,%ebp
f0102ffd:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103000:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103003:	50                   	push   %eax
f0103004:	ff 75 08             	pushl  0x8(%ebp)
f0103007:	e8 c8 ff ff ff       	call   f0102fd4 <vcprintf>
	va_end(ap);

	return cnt;
}
f010300c:	c9                   	leave  
f010300d:	c3                   	ret    

f010300e <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f010300e:	55                   	push   %ebp
f010300f:	89 e5                	mov    %esp,%ebp
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f0103011:	b8 80 d6 17 f0       	mov    $0xf017d680,%eax
f0103016:	c7 05 84 d6 17 f0 00 	movl   $0xf0000000,0xf017d684
f010301d:	00 00 f0 
	ts.ts_ss0 = GD_KD;
f0103020:	66 c7 05 88 d6 17 f0 	movw   $0x10,0xf017d688
f0103027:	10 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f0103029:	66 c7 05 48 b3 11 f0 	movw   $0x67,0xf011b348
f0103030:	67 00 
f0103032:	66 a3 4a b3 11 f0    	mov    %ax,0xf011b34a
f0103038:	89 c2                	mov    %eax,%edx
f010303a:	c1 ea 10             	shr    $0x10,%edx
f010303d:	88 15 4c b3 11 f0    	mov    %dl,0xf011b34c
f0103043:	c6 05 4e b3 11 f0 40 	movb   $0x40,0xf011b34e
f010304a:	c1 e8 18             	shr    $0x18,%eax
f010304d:	a2 4f b3 11 f0       	mov    %al,0xf011b34f
					sizeof(struct Taskstate) - 1, 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f0103052:	c6 05 4d b3 11 f0 89 	movb   $0x89,0xf011b34d
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f0103059:	b8 28 00 00 00       	mov    $0x28,%eax
f010305e:	0f 00 d8             	ltr    %ax
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f0103061:	b8 50 b3 11 f0       	mov    $0xf011b350,%eax
f0103066:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f0103069:	5d                   	pop    %ebp
f010306a:	c3                   	ret    

f010306b <trap_init>:
}


void
trap_init(void)
{
f010306b:	55                   	push   %ebp
f010306c:	89 e5                	mov    %esp,%ebp
    void handler19();

    void handler_syscall();


    SETGATE(idt[0], 0, GD_KT, handler0, 0);
f010306e:	b8 94 37 10 f0       	mov    $0xf0103794,%eax
f0103073:	66 a3 60 ce 17 f0    	mov    %ax,0xf017ce60
f0103079:	66 c7 05 62 ce 17 f0 	movw   $0x8,0xf017ce62
f0103080:	08 00 
f0103082:	c6 05 64 ce 17 f0 00 	movb   $0x0,0xf017ce64
f0103089:	c6 05 65 ce 17 f0 8e 	movb   $0x8e,0xf017ce65
f0103090:	c1 e8 10             	shr    $0x10,%eax
f0103093:	66 a3 66 ce 17 f0    	mov    %ax,0xf017ce66
    SETGATE(idt[1], 0, GD_KT, handler1, 0);
f0103099:	b8 9a 37 10 f0       	mov    $0xf010379a,%eax
f010309e:	66 a3 68 ce 17 f0    	mov    %ax,0xf017ce68
f01030a4:	66 c7 05 6a ce 17 f0 	movw   $0x8,0xf017ce6a
f01030ab:	08 00 
f01030ad:	c6 05 6c ce 17 f0 00 	movb   $0x0,0xf017ce6c
f01030b4:	c6 05 6d ce 17 f0 8e 	movb   $0x8e,0xf017ce6d
f01030bb:	c1 e8 10             	shr    $0x10,%eax
f01030be:	66 a3 6e ce 17 f0    	mov    %ax,0xf017ce6e
    SETGATE(idt[2], 0, GD_KT, handler2, 0);
f01030c4:	b8 a0 37 10 f0       	mov    $0xf01037a0,%eax
f01030c9:	66 a3 70 ce 17 f0    	mov    %ax,0xf017ce70
f01030cf:	66 c7 05 72 ce 17 f0 	movw   $0x8,0xf017ce72
f01030d6:	08 00 
f01030d8:	c6 05 74 ce 17 f0 00 	movb   $0x0,0xf017ce74
f01030df:	c6 05 75 ce 17 f0 8e 	movb   $0x8e,0xf017ce75
f01030e6:	c1 e8 10             	shr    $0x10,%eax
f01030e9:	66 a3 76 ce 17 f0    	mov    %ax,0xf017ce76
    SETGATE(idt[3], 0, GD_KT, handler3, 3);
f01030ef:	b8 a6 37 10 f0       	mov    $0xf01037a6,%eax
f01030f4:	66 a3 78 ce 17 f0    	mov    %ax,0xf017ce78
f01030fa:	66 c7 05 7a ce 17 f0 	movw   $0x8,0xf017ce7a
f0103101:	08 00 
f0103103:	c6 05 7c ce 17 f0 00 	movb   $0x0,0xf017ce7c
f010310a:	c6 05 7d ce 17 f0 ee 	movb   $0xee,0xf017ce7d
f0103111:	c1 e8 10             	shr    $0x10,%eax
f0103114:	66 a3 7e ce 17 f0    	mov    %ax,0xf017ce7e
    SETGATE(idt[4], 0, GD_KT, handler4, 0);
f010311a:	b8 ac 37 10 f0       	mov    $0xf01037ac,%eax
f010311f:	66 a3 80 ce 17 f0    	mov    %ax,0xf017ce80
f0103125:	66 c7 05 82 ce 17 f0 	movw   $0x8,0xf017ce82
f010312c:	08 00 
f010312e:	c6 05 84 ce 17 f0 00 	movb   $0x0,0xf017ce84
f0103135:	c6 05 85 ce 17 f0 8e 	movb   $0x8e,0xf017ce85
f010313c:	c1 e8 10             	shr    $0x10,%eax
f010313f:	66 a3 86 ce 17 f0    	mov    %ax,0xf017ce86
    SETGATE(idt[5], 0, GD_KT, handler5, 0);
f0103145:	b8 b2 37 10 f0       	mov    $0xf01037b2,%eax
f010314a:	66 a3 88 ce 17 f0    	mov    %ax,0xf017ce88
f0103150:	66 c7 05 8a ce 17 f0 	movw   $0x8,0xf017ce8a
f0103157:	08 00 
f0103159:	c6 05 8c ce 17 f0 00 	movb   $0x0,0xf017ce8c
f0103160:	c6 05 8d ce 17 f0 8e 	movb   $0x8e,0xf017ce8d
f0103167:	c1 e8 10             	shr    $0x10,%eax
f010316a:	66 a3 8e ce 17 f0    	mov    %ax,0xf017ce8e
    SETGATE(idt[6], 0, GD_KT, handler6, 0);
f0103170:	b8 b8 37 10 f0       	mov    $0xf01037b8,%eax
f0103175:	66 a3 90 ce 17 f0    	mov    %ax,0xf017ce90
f010317b:	66 c7 05 92 ce 17 f0 	movw   $0x8,0xf017ce92
f0103182:	08 00 
f0103184:	c6 05 94 ce 17 f0 00 	movb   $0x0,0xf017ce94
f010318b:	c6 05 95 ce 17 f0 8e 	movb   $0x8e,0xf017ce95
f0103192:	c1 e8 10             	shr    $0x10,%eax
f0103195:	66 a3 96 ce 17 f0    	mov    %ax,0xf017ce96
    SETGATE(idt[7], 0, GD_KT, handler7, 0);
f010319b:	b8 be 37 10 f0       	mov    $0xf01037be,%eax
f01031a0:	66 a3 98 ce 17 f0    	mov    %ax,0xf017ce98
f01031a6:	66 c7 05 9a ce 17 f0 	movw   $0x8,0xf017ce9a
f01031ad:	08 00 
f01031af:	c6 05 9c ce 17 f0 00 	movb   $0x0,0xf017ce9c
f01031b6:	c6 05 9d ce 17 f0 8e 	movb   $0x8e,0xf017ce9d
f01031bd:	c1 e8 10             	shr    $0x10,%eax
f01031c0:	66 a3 9e ce 17 f0    	mov    %ax,0xf017ce9e
    SETGATE(idt[8], 0, GD_KT, handler8, 0);
f01031c6:	b8 c4 37 10 f0       	mov    $0xf01037c4,%eax
f01031cb:	66 a3 a0 ce 17 f0    	mov    %ax,0xf017cea0
f01031d1:	66 c7 05 a2 ce 17 f0 	movw   $0x8,0xf017cea2
f01031d8:	08 00 
f01031da:	c6 05 a4 ce 17 f0 00 	movb   $0x0,0xf017cea4
f01031e1:	c6 05 a5 ce 17 f0 8e 	movb   $0x8e,0xf017cea5
f01031e8:	c1 e8 10             	shr    $0x10,%eax
f01031eb:	66 a3 a6 ce 17 f0    	mov    %ax,0xf017cea6
    SETGATE(idt[9], 0, GD_KT, handler9, 0);
f01031f1:	b8 c8 37 10 f0       	mov    $0xf01037c8,%eax
f01031f6:	66 a3 a8 ce 17 f0    	mov    %ax,0xf017cea8
f01031fc:	66 c7 05 aa ce 17 f0 	movw   $0x8,0xf017ceaa
f0103203:	08 00 
f0103205:	c6 05 ac ce 17 f0 00 	movb   $0x0,0xf017ceac
f010320c:	c6 05 ad ce 17 f0 8e 	movb   $0x8e,0xf017cead
f0103213:	c1 e8 10             	shr    $0x10,%eax
f0103216:	66 a3 ae ce 17 f0    	mov    %ax,0xf017ceae
    SETGATE(idt[10], 0, GD_KT, handler10, 0);
f010321c:	b8 ce 37 10 f0       	mov    $0xf01037ce,%eax
f0103221:	66 a3 b0 ce 17 f0    	mov    %ax,0xf017ceb0
f0103227:	66 c7 05 b2 ce 17 f0 	movw   $0x8,0xf017ceb2
f010322e:	08 00 
f0103230:	c6 05 b4 ce 17 f0 00 	movb   $0x0,0xf017ceb4
f0103237:	c6 05 b5 ce 17 f0 8e 	movb   $0x8e,0xf017ceb5
f010323e:	c1 e8 10             	shr    $0x10,%eax
f0103241:	66 a3 b6 ce 17 f0    	mov    %ax,0xf017ceb6
    SETGATE(idt[11], 0, GD_KT, handler11, 0);
f0103247:	b8 d2 37 10 f0       	mov    $0xf01037d2,%eax
f010324c:	66 a3 b8 ce 17 f0    	mov    %ax,0xf017ceb8
f0103252:	66 c7 05 ba ce 17 f0 	movw   $0x8,0xf017ceba
f0103259:	08 00 
f010325b:	c6 05 bc ce 17 f0 00 	movb   $0x0,0xf017cebc
f0103262:	c6 05 bd ce 17 f0 8e 	movb   $0x8e,0xf017cebd
f0103269:	c1 e8 10             	shr    $0x10,%eax
f010326c:	66 a3 be ce 17 f0    	mov    %ax,0xf017cebe
    SETGATE(idt[12], 0, GD_KT, handler12, 0);
f0103272:	b8 d6 37 10 f0       	mov    $0xf01037d6,%eax
f0103277:	66 a3 c0 ce 17 f0    	mov    %ax,0xf017cec0
f010327d:	66 c7 05 c2 ce 17 f0 	movw   $0x8,0xf017cec2
f0103284:	08 00 
f0103286:	c6 05 c4 ce 17 f0 00 	movb   $0x0,0xf017cec4
f010328d:	c6 05 c5 ce 17 f0 8e 	movb   $0x8e,0xf017cec5
f0103294:	c1 e8 10             	shr    $0x10,%eax
f0103297:	66 a3 c6 ce 17 f0    	mov    %ax,0xf017cec6
    SETGATE(idt[13], 0, GD_KT, handler13, 0);
f010329d:	b8 da 37 10 f0       	mov    $0xf01037da,%eax
f01032a2:	66 a3 c8 ce 17 f0    	mov    %ax,0xf017cec8
f01032a8:	66 c7 05 ca ce 17 f0 	movw   $0x8,0xf017ceca
f01032af:	08 00 
f01032b1:	c6 05 cc ce 17 f0 00 	movb   $0x0,0xf017cecc
f01032b8:	c6 05 cd ce 17 f0 8e 	movb   $0x8e,0xf017cecd
f01032bf:	c1 e8 10             	shr    $0x10,%eax
f01032c2:	66 a3 ce ce 17 f0    	mov    %ax,0xf017cece
    SETGATE(idt[14], 0, GD_KT, handler14, 0);
f01032c8:	b8 de 37 10 f0       	mov    $0xf01037de,%eax
f01032cd:	66 a3 d0 ce 17 f0    	mov    %ax,0xf017ced0
f01032d3:	66 c7 05 d2 ce 17 f0 	movw   $0x8,0xf017ced2
f01032da:	08 00 
f01032dc:	c6 05 d4 ce 17 f0 00 	movb   $0x0,0xf017ced4
f01032e3:	c6 05 d5 ce 17 f0 8e 	movb   $0x8e,0xf017ced5
f01032ea:	c1 e8 10             	shr    $0x10,%eax
f01032ed:	66 a3 d6 ce 17 f0    	mov    %ax,0xf017ced6
    SETGATE(idt[15], 0, GD_KT, handler15, 0);
f01032f3:	b8 e2 37 10 f0       	mov    $0xf01037e2,%eax
f01032f8:	66 a3 d8 ce 17 f0    	mov    %ax,0xf017ced8
f01032fe:	66 c7 05 da ce 17 f0 	movw   $0x8,0xf017ceda
f0103305:	08 00 
f0103307:	c6 05 dc ce 17 f0 00 	movb   $0x0,0xf017cedc
f010330e:	c6 05 dd ce 17 f0 8e 	movb   $0x8e,0xf017cedd
f0103315:	c1 e8 10             	shr    $0x10,%eax
f0103318:	66 a3 de ce 17 f0    	mov    %ax,0xf017cede
    SETGATE(idt[16], 0, GD_KT, handler16, 0);
f010331e:	b8 e8 37 10 f0       	mov    $0xf01037e8,%eax
f0103323:	66 a3 e0 ce 17 f0    	mov    %ax,0xf017cee0
f0103329:	66 c7 05 e2 ce 17 f0 	movw   $0x8,0xf017cee2
f0103330:	08 00 
f0103332:	c6 05 e4 ce 17 f0 00 	movb   $0x0,0xf017cee4
f0103339:	c6 05 e5 ce 17 f0 8e 	movb   $0x8e,0xf017cee5
f0103340:	c1 e8 10             	shr    $0x10,%eax
f0103343:	66 a3 e6 ce 17 f0    	mov    %ax,0xf017cee6
    SETGATE(idt[17], 0, GD_KT, handler17, 0);
f0103349:	b8 ee 37 10 f0       	mov    $0xf01037ee,%eax
f010334e:	66 a3 e8 ce 17 f0    	mov    %ax,0xf017cee8
f0103354:	66 c7 05 ea ce 17 f0 	movw   $0x8,0xf017ceea
f010335b:	08 00 
f010335d:	c6 05 ec ce 17 f0 00 	movb   $0x0,0xf017ceec
f0103364:	c6 05 ed ce 17 f0 8e 	movb   $0x8e,0xf017ceed
f010336b:	c1 e8 10             	shr    $0x10,%eax
f010336e:	66 a3 ee ce 17 f0    	mov    %ax,0xf017ceee
    SETGATE(idt[18], 0, GD_KT, handler18, 0);
f0103374:	b8 f2 37 10 f0       	mov    $0xf01037f2,%eax
f0103379:	66 a3 f0 ce 17 f0    	mov    %ax,0xf017cef0
f010337f:	66 c7 05 f2 ce 17 f0 	movw   $0x8,0xf017cef2
f0103386:	08 00 
f0103388:	c6 05 f4 ce 17 f0 00 	movb   $0x0,0xf017cef4
f010338f:	c6 05 f5 ce 17 f0 8e 	movb   $0x8e,0xf017cef5
f0103396:	c1 e8 10             	shr    $0x10,%eax
f0103399:	66 a3 f6 ce 17 f0    	mov    %ax,0xf017cef6
    SETGATE(idt[19], 0, GD_KT, handler19, 0);
f010339f:	b8 f8 37 10 f0       	mov    $0xf01037f8,%eax
f01033a4:	66 a3 f8 ce 17 f0    	mov    %ax,0xf017cef8
f01033aa:	66 c7 05 fa ce 17 f0 	movw   $0x8,0xf017cefa
f01033b1:	08 00 
f01033b3:	c6 05 fc ce 17 f0 00 	movb   $0x0,0xf017cefc
f01033ba:	c6 05 fd ce 17 f0 8e 	movb   $0x8e,0xf017cefd
f01033c1:	c1 e8 10             	shr    $0x10,%eax
f01033c4:	66 a3 fe ce 17 f0    	mov    %ax,0xf017cefe

    SETGATE(idt[T_SYSCALL], 0, GD_KT, handler_syscall, 3);
f01033ca:	b8 fe 37 10 f0       	mov    $0xf01037fe,%eax
f01033cf:	66 a3 e0 cf 17 f0    	mov    %ax,0xf017cfe0
f01033d5:	66 c7 05 e2 cf 17 f0 	movw   $0x8,0xf017cfe2
f01033dc:	08 00 
f01033de:	c6 05 e4 cf 17 f0 00 	movb   $0x0,0xf017cfe4
f01033e5:	c6 05 e5 cf 17 f0 ee 	movb   $0xee,0xf017cfe5
f01033ec:	c1 e8 10             	shr    $0x10,%eax
f01033ef:	66 a3 e6 cf 17 f0    	mov    %ax,0xf017cfe6


	// Per-CPU setup 
	trap_init_percpu();
f01033f5:	e8 14 fc ff ff       	call   f010300e <trap_init_percpu>
}
f01033fa:	5d                   	pop    %ebp
f01033fb:	c3                   	ret    

f01033fc <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f01033fc:	55                   	push   %ebp
f01033fd:	89 e5                	mov    %esp,%ebp
f01033ff:	53                   	push   %ebx
f0103400:	83 ec 0c             	sub    $0xc,%esp
f0103403:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103406:	ff 33                	pushl  (%ebx)
f0103408:	68 de 5a 10 f0       	push   $0xf0105ade
f010340d:	e8 e8 fb ff ff       	call   f0102ffa <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103412:	83 c4 08             	add    $0x8,%esp
f0103415:	ff 73 04             	pushl  0x4(%ebx)
f0103418:	68 ed 5a 10 f0       	push   $0xf0105aed
f010341d:	e8 d8 fb ff ff       	call   f0102ffa <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103422:	83 c4 08             	add    $0x8,%esp
f0103425:	ff 73 08             	pushl  0x8(%ebx)
f0103428:	68 fc 5a 10 f0       	push   $0xf0105afc
f010342d:	e8 c8 fb ff ff       	call   f0102ffa <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103432:	83 c4 08             	add    $0x8,%esp
f0103435:	ff 73 0c             	pushl  0xc(%ebx)
f0103438:	68 0b 5b 10 f0       	push   $0xf0105b0b
f010343d:	e8 b8 fb ff ff       	call   f0102ffa <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103442:	83 c4 08             	add    $0x8,%esp
f0103445:	ff 73 10             	pushl  0x10(%ebx)
f0103448:	68 1a 5b 10 f0       	push   $0xf0105b1a
f010344d:	e8 a8 fb ff ff       	call   f0102ffa <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103452:	83 c4 08             	add    $0x8,%esp
f0103455:	ff 73 14             	pushl  0x14(%ebx)
f0103458:	68 29 5b 10 f0       	push   $0xf0105b29
f010345d:	e8 98 fb ff ff       	call   f0102ffa <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103462:	83 c4 08             	add    $0x8,%esp
f0103465:	ff 73 18             	pushl  0x18(%ebx)
f0103468:	68 38 5b 10 f0       	push   $0xf0105b38
f010346d:	e8 88 fb ff ff       	call   f0102ffa <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103472:	83 c4 08             	add    $0x8,%esp
f0103475:	ff 73 1c             	pushl  0x1c(%ebx)
f0103478:	68 47 5b 10 f0       	push   $0xf0105b47
f010347d:	e8 78 fb ff ff       	call   f0102ffa <cprintf>
}
f0103482:	83 c4 10             	add    $0x10,%esp
f0103485:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103488:	c9                   	leave  
f0103489:	c3                   	ret    

f010348a <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f010348a:	55                   	push   %ebp
f010348b:	89 e5                	mov    %esp,%ebp
f010348d:	56                   	push   %esi
f010348e:	53                   	push   %ebx
f010348f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p\n", tf);
f0103492:	83 ec 08             	sub    $0x8,%esp
f0103495:	53                   	push   %ebx
f0103496:	68 7d 5c 10 f0       	push   $0xf0105c7d
f010349b:	e8 5a fb ff ff       	call   f0102ffa <cprintf>
	print_regs(&tf->tf_regs);
f01034a0:	89 1c 24             	mov    %ebx,(%esp)
f01034a3:	e8 54 ff ff ff       	call   f01033fc <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f01034a8:	83 c4 08             	add    $0x8,%esp
f01034ab:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f01034af:	50                   	push   %eax
f01034b0:	68 98 5b 10 f0       	push   $0xf0105b98
f01034b5:	e8 40 fb ff ff       	call   f0102ffa <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f01034ba:	83 c4 08             	add    $0x8,%esp
f01034bd:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f01034c1:	50                   	push   %eax
f01034c2:	68 ab 5b 10 f0       	push   $0xf0105bab
f01034c7:	e8 2e fb ff ff       	call   f0102ffa <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01034cc:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f01034cf:	83 c4 10             	add    $0x10,%esp
f01034d2:	83 f8 13             	cmp    $0x13,%eax
f01034d5:	77 09                	ja     f01034e0 <print_trapframe+0x56>
		return excnames[trapno];
f01034d7:	8b 14 85 80 5e 10 f0 	mov    -0xfefa180(,%eax,4),%edx
f01034de:	eb 10                	jmp    f01034f0 <print_trapframe+0x66>
	if (trapno == T_SYSCALL)
		return "System call";
	return "(unknown trap)";
f01034e0:	83 f8 30             	cmp    $0x30,%eax
f01034e3:	b9 62 5b 10 f0       	mov    $0xf0105b62,%ecx
f01034e8:	ba 56 5b 10 f0       	mov    $0xf0105b56,%edx
f01034ed:	0f 45 d1             	cmovne %ecx,%edx
{
	cprintf("TRAP frame at %p\n", tf);
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01034f0:	83 ec 04             	sub    $0x4,%esp
f01034f3:	52                   	push   %edx
f01034f4:	50                   	push   %eax
f01034f5:	68 be 5b 10 f0       	push   $0xf0105bbe
f01034fa:	e8 fb fa ff ff       	call   f0102ffa <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f01034ff:	83 c4 10             	add    $0x10,%esp
f0103502:	3b 1d 60 d6 17 f0    	cmp    0xf017d660,%ebx
f0103508:	75 1a                	jne    f0103524 <print_trapframe+0x9a>
f010350a:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010350e:	75 14                	jne    f0103524 <print_trapframe+0x9a>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0103510:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103513:	83 ec 08             	sub    $0x8,%esp
f0103516:	50                   	push   %eax
f0103517:	68 d0 5b 10 f0       	push   $0xf0105bd0
f010351c:	e8 d9 fa ff ff       	call   f0102ffa <cprintf>
f0103521:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f0103524:	83 ec 08             	sub    $0x8,%esp
f0103527:	ff 73 2c             	pushl  0x2c(%ebx)
f010352a:	68 df 5b 10 f0       	push   $0xf0105bdf
f010352f:	e8 c6 fa ff ff       	call   f0102ffa <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0103534:	83 c4 10             	add    $0x10,%esp
f0103537:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010353b:	75 49                	jne    f0103586 <print_trapframe+0xfc>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f010353d:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0103540:	89 c2                	mov    %eax,%edx
f0103542:	83 e2 01             	and    $0x1,%edx
f0103545:	ba 7c 5b 10 f0       	mov    $0xf0105b7c,%edx
f010354a:	b9 71 5b 10 f0       	mov    $0xf0105b71,%ecx
f010354f:	0f 44 ca             	cmove  %edx,%ecx
f0103552:	89 c2                	mov    %eax,%edx
f0103554:	83 e2 02             	and    $0x2,%edx
f0103557:	ba 8e 5b 10 f0       	mov    $0xf0105b8e,%edx
f010355c:	be 88 5b 10 f0       	mov    $0xf0105b88,%esi
f0103561:	0f 45 d6             	cmovne %esi,%edx
f0103564:	83 e0 04             	and    $0x4,%eax
f0103567:	be a8 5c 10 f0       	mov    $0xf0105ca8,%esi
f010356c:	b8 93 5b 10 f0       	mov    $0xf0105b93,%eax
f0103571:	0f 44 c6             	cmove  %esi,%eax
f0103574:	51                   	push   %ecx
f0103575:	52                   	push   %edx
f0103576:	50                   	push   %eax
f0103577:	68 ed 5b 10 f0       	push   $0xf0105bed
f010357c:	e8 79 fa ff ff       	call   f0102ffa <cprintf>
f0103581:	83 c4 10             	add    $0x10,%esp
f0103584:	eb 10                	jmp    f0103596 <print_trapframe+0x10c>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0103586:	83 ec 0c             	sub    $0xc,%esp
f0103589:	68 c6 59 10 f0       	push   $0xf01059c6
f010358e:	e8 67 fa ff ff       	call   f0102ffa <cprintf>
f0103593:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103596:	83 ec 08             	sub    $0x8,%esp
f0103599:	ff 73 30             	pushl  0x30(%ebx)
f010359c:	68 fc 5b 10 f0       	push   $0xf0105bfc
f01035a1:	e8 54 fa ff ff       	call   f0102ffa <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f01035a6:	83 c4 08             	add    $0x8,%esp
f01035a9:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f01035ad:	50                   	push   %eax
f01035ae:	68 0b 5c 10 f0       	push   $0xf0105c0b
f01035b3:	e8 42 fa ff ff       	call   f0102ffa <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f01035b8:	83 c4 08             	add    $0x8,%esp
f01035bb:	ff 73 38             	pushl  0x38(%ebx)
f01035be:	68 1e 5c 10 f0       	push   $0xf0105c1e
f01035c3:	e8 32 fa ff ff       	call   f0102ffa <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f01035c8:	83 c4 10             	add    $0x10,%esp
f01035cb:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01035cf:	74 25                	je     f01035f6 <print_trapframe+0x16c>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f01035d1:	83 ec 08             	sub    $0x8,%esp
f01035d4:	ff 73 3c             	pushl  0x3c(%ebx)
f01035d7:	68 2d 5c 10 f0       	push   $0xf0105c2d
f01035dc:	e8 19 fa ff ff       	call   f0102ffa <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f01035e1:	83 c4 08             	add    $0x8,%esp
f01035e4:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f01035e8:	50                   	push   %eax
f01035e9:	68 3c 5c 10 f0       	push   $0xf0105c3c
f01035ee:	e8 07 fa ff ff       	call   f0102ffa <cprintf>
f01035f3:	83 c4 10             	add    $0x10,%esp
	}
}
f01035f6:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01035f9:	5b                   	pop    %ebx
f01035fa:	5e                   	pop    %esi
f01035fb:	5d                   	pop    %ebp
f01035fc:	c3                   	ret    

f01035fd <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f01035fd:	55                   	push   %ebp
f01035fe:	89 e5                	mov    %esp,%ebp
f0103600:	53                   	push   %ebx
f0103601:	83 ec 04             	sub    $0x4,%esp
f0103604:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103607:	0f 20 d0             	mov    %cr2,%eax

	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f010360a:	ff 73 30             	pushl  0x30(%ebx)
f010360d:	50                   	push   %eax
f010360e:	a1 48 ce 17 f0       	mov    0xf017ce48,%eax
f0103613:	ff 70 48             	pushl  0x48(%eax)
f0103616:	68 f4 5d 10 f0       	push   $0xf0105df4
f010361b:	e8 da f9 ff ff       	call   f0102ffa <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0103620:	89 1c 24             	mov    %ebx,(%esp)
f0103623:	e8 62 fe ff ff       	call   f010348a <print_trapframe>
	env_destroy(curenv);
f0103628:	83 c4 04             	add    $0x4,%esp
f010362b:	ff 35 48 ce 17 f0    	pushl  0xf017ce48
f0103631:	e8 ab f8 ff ff       	call   f0102ee1 <env_destroy>
}
f0103636:	83 c4 10             	add    $0x10,%esp
f0103639:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010363c:	c9                   	leave  
f010363d:	c3                   	ret    

f010363e <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f010363e:	55                   	push   %ebp
f010363f:	89 e5                	mov    %esp,%ebp
f0103641:	57                   	push   %edi
f0103642:	56                   	push   %esi
f0103643:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0103646:	fc                   	cld    

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f0103647:	9c                   	pushf  
f0103648:	58                   	pop    %eax

	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0103649:	f6 c4 02             	test   $0x2,%ah
f010364c:	74 19                	je     f0103667 <trap+0x29>
f010364e:	68 4f 5c 10 f0       	push   $0xf0105c4f
f0103653:	68 3b 57 10 f0       	push   $0xf010573b
f0103658:	68 f0 00 00 00       	push   $0xf0
f010365d:	68 68 5c 10 f0       	push   $0xf0105c68
f0103662:	e8 75 ca ff ff       	call   f01000dc <_panic>

	cprintf("Incoming TRAP frame at %p\n", tf);
f0103667:	83 ec 08             	sub    $0x8,%esp
f010366a:	56                   	push   %esi
f010366b:	68 74 5c 10 f0       	push   $0xf0105c74
f0103670:	e8 85 f9 ff ff       	call   f0102ffa <cprintf>

	if ((tf->tf_cs & 3) == 3) {
f0103675:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0103679:	83 e0 03             	and    $0x3,%eax
f010367c:	83 c4 10             	add    $0x10,%esp
f010367f:	66 83 f8 03          	cmp    $0x3,%ax
f0103683:	75 31                	jne    f01036b6 <trap+0x78>
		// Trapped from user mode.
		assert(curenv);
f0103685:	a1 48 ce 17 f0       	mov    0xf017ce48,%eax
f010368a:	85 c0                	test   %eax,%eax
f010368c:	75 19                	jne    f01036a7 <trap+0x69>
f010368e:	68 8f 5c 10 f0       	push   $0xf0105c8f
f0103693:	68 3b 57 10 f0       	push   $0xf010573b
f0103698:	68 f6 00 00 00       	push   $0xf6
f010369d:	68 68 5c 10 f0       	push   $0xf0105c68
f01036a2:	e8 35 ca ff ff       	call   f01000dc <_panic>

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f01036a7:	b9 11 00 00 00       	mov    $0x11,%ecx
f01036ac:	89 c7                	mov    %eax,%edi
f01036ae:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f01036b0:	8b 35 48 ce 17 f0    	mov    0xf017ce48,%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f01036b6:	89 35 60 d6 17 f0    	mov    %esi,0xf017d660
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
    int syscall_ret;

    if (tf->tf_trapno == T_PGFLT)
f01036bc:	8b 46 28             	mov    0x28(%esi),%eax
f01036bf:	83 f8 0e             	cmp    $0xe,%eax
f01036c2:	75 2b                	jne    f01036ef <trap+0xb1>
    {
        if ((tf->tf_cs & 0x3) == 0)
f01036c4:	f6 46 34 03          	testb  $0x3,0x34(%esi)
f01036c8:	75 17                	jne    f01036e1 <trap+0xa3>
        {
            panic("Page fault in kernel code, halt");
f01036ca:	83 ec 04             	sub    $0x4,%esp
f01036cd:	68 18 5e 10 f0       	push   $0xf0105e18
f01036d2:	68 c7 00 00 00       	push   $0xc7
f01036d7:	68 68 5c 10 f0       	push   $0xf0105c68
f01036dc:	e8 fb c9 ff ff       	call   f01000dc <_panic>
        }
        page_fault_handler(tf);
f01036e1:	83 ec 0c             	sub    $0xc,%esp
f01036e4:	56                   	push   %esi
f01036e5:	e8 13 ff ff ff       	call   f01035fd <page_fault_handler>
f01036ea:	83 c4 10             	add    $0x10,%esp
f01036ed:	eb 74                	jmp    f0103763 <trap+0x125>
        return;
    }
    else if (tf->tf_trapno == T_BRKPT)
f01036ef:	83 f8 03             	cmp    $0x3,%eax
f01036f2:	75 0e                	jne    f0103702 <trap+0xc4>
    {
        monitor(tf);
f01036f4:	83 ec 0c             	sub    $0xc,%esp
f01036f7:	56                   	push   %esi
f01036f8:	e8 df d0 ff ff       	call   f01007dc <monitor>
f01036fd:	83 c4 10             	add    $0x10,%esp
f0103700:	eb 61                	jmp    f0103763 <trap+0x125>
        return;
    }
    else if (tf->tf_trapno == T_SYSCALL)
f0103702:	83 f8 30             	cmp    $0x30,%eax
f0103705:	75 21                	jne    f0103728 <trap+0xea>
    {
        syscall_ret = syscall(tf->tf_regs.reg_eax, 
f0103707:	83 ec 08             	sub    $0x8,%esp
f010370a:	ff 76 04             	pushl  0x4(%esi)
f010370d:	ff 36                	pushl  (%esi)
f010370f:	ff 76 10             	pushl  0x10(%esi)
f0103712:	ff 76 18             	pushl  0x18(%esi)
f0103715:	ff 76 14             	pushl  0x14(%esi)
f0103718:	ff 76 1c             	pushl  0x1c(%esi)
f010371b:	e8 f5 00 00 00       	call   f0103815 <syscall>
            tf->tf_regs.reg_edx, 
            tf->tf_regs.reg_ecx, 
            tf->tf_regs.reg_ebx, 
            tf->tf_regs.reg_edi, 
            tf->tf_regs.reg_esi);
        tf->tf_regs.reg_eax = syscall_ret;
f0103720:	89 46 1c             	mov    %eax,0x1c(%esi)
f0103723:	83 c4 20             	add    $0x20,%esp
f0103726:	eb 3b                	jmp    f0103763 <trap+0x125>
        return;
    }
	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f0103728:	83 ec 0c             	sub    $0xc,%esp
f010372b:	56                   	push   %esi
f010372c:	e8 59 fd ff ff       	call   f010348a <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0103731:	83 c4 10             	add    $0x10,%esp
f0103734:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0103739:	75 17                	jne    f0103752 <trap+0x114>
		panic("unhandled trap in kernel");
f010373b:	83 ec 04             	sub    $0x4,%esp
f010373e:	68 96 5c 10 f0       	push   $0xf0105c96
f0103743:	68 df 00 00 00       	push   $0xdf
f0103748:	68 68 5c 10 f0       	push   $0xf0105c68
f010374d:	e8 8a c9 ff ff       	call   f01000dc <_panic>
	else {
		env_destroy(curenv);
f0103752:	83 ec 0c             	sub    $0xc,%esp
f0103755:	ff 35 48 ce 17 f0    	pushl  0xf017ce48
f010375b:	e8 81 f7 ff ff       	call   f0102ee1 <env_destroy>
f0103760:	83 c4 10             	add    $0x10,%esp

	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);

	// Return to the current environment, which should be running.
	assert(curenv && curenv->env_status == ENV_RUNNING);
f0103763:	a1 48 ce 17 f0       	mov    0xf017ce48,%eax
f0103768:	85 c0                	test   %eax,%eax
f010376a:	74 06                	je     f0103772 <trap+0x134>
f010376c:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103770:	74 19                	je     f010378b <trap+0x14d>
f0103772:	68 38 5e 10 f0       	push   $0xf0105e38
f0103777:	68 3b 57 10 f0       	push   $0xf010573b
f010377c:	68 08 01 00 00       	push   $0x108
f0103781:	68 68 5c 10 f0       	push   $0xf0105c68
f0103786:	e8 51 c9 ff ff       	call   f01000dc <_panic>
	env_run(curenv);
f010378b:	83 ec 0c             	sub    $0xc,%esp
f010378e:	50                   	push   %eax
f010378f:	e8 9d f7 ff ff       	call   f0102f31 <env_run>

f0103794 <handler0>:
/*
clpsz:
please visit here to find a summary of all exceptions
http://wiki.osdev.org/Exceptions
*/
TRAPHANDLER_NOEC(handler0, T_DIVIDE)
f0103794:	6a 00                	push   $0x0
f0103796:	6a 00                	push   $0x0
f0103798:	eb 6a                	jmp    f0103804 <_alltraps>

f010379a <handler1>:
TRAPHANDLER_NOEC(handler1, T_DEBUG)
f010379a:	6a 00                	push   $0x0
f010379c:	6a 01                	push   $0x1
f010379e:	eb 64                	jmp    f0103804 <_alltraps>

f01037a0 <handler2>:
TRAPHANDLER_NOEC(handler2, T_NMI)
f01037a0:	6a 00                	push   $0x0
f01037a2:	6a 02                	push   $0x2
f01037a4:	eb 5e                	jmp    f0103804 <_alltraps>

f01037a6 <handler3>:
TRAPHANDLER_NOEC(handler3, T_BRKPT)
f01037a6:	6a 00                	push   $0x0
f01037a8:	6a 03                	push   $0x3
f01037aa:	eb 58                	jmp    f0103804 <_alltraps>

f01037ac <handler4>:
TRAPHANDLER_NOEC(handler4, T_OFLOW)
f01037ac:	6a 00                	push   $0x0
f01037ae:	6a 04                	push   $0x4
f01037b0:	eb 52                	jmp    f0103804 <_alltraps>

f01037b2 <handler5>:
TRAPHANDLER_NOEC(handler5, T_BOUND)
f01037b2:	6a 00                	push   $0x0
f01037b4:	6a 05                	push   $0x5
f01037b6:	eb 4c                	jmp    f0103804 <_alltraps>

f01037b8 <handler6>:
TRAPHANDLER_NOEC(handler6, T_ILLOP)
f01037b8:	6a 00                	push   $0x0
f01037ba:	6a 06                	push   $0x6
f01037bc:	eb 46                	jmp    f0103804 <_alltraps>

f01037be <handler7>:
TRAPHANDLER_NOEC(handler7, T_DEVICE)
f01037be:	6a 00                	push   $0x0
f01037c0:	6a 07                	push   $0x7
f01037c2:	eb 40                	jmp    f0103804 <_alltraps>

f01037c4 <handler8>:
TRAPHANDLER(handler8, T_DBLFLT)
f01037c4:	6a 08                	push   $0x8
f01037c6:	eb 3c                	jmp    f0103804 <_alltraps>

f01037c8 <handler9>:
TRAPHANDLER_NOEC(handler9, T_COPROC) /* reserved */
f01037c8:	6a 00                	push   $0x0
f01037ca:	6a 09                	push   $0x9
f01037cc:	eb 36                	jmp    f0103804 <_alltraps>

f01037ce <handler10>:
TRAPHANDLER(handler10, T_TSS)
f01037ce:	6a 0a                	push   $0xa
f01037d0:	eb 32                	jmp    f0103804 <_alltraps>

f01037d2 <handler11>:
TRAPHANDLER(handler11, T_SEGNP)
f01037d2:	6a 0b                	push   $0xb
f01037d4:	eb 2e                	jmp    f0103804 <_alltraps>

f01037d6 <handler12>:
TRAPHANDLER(handler12, T_STACK)
f01037d6:	6a 0c                	push   $0xc
f01037d8:	eb 2a                	jmp    f0103804 <_alltraps>

f01037da <handler13>:
TRAPHANDLER(handler13, T_GPFLT)
f01037da:	6a 0d                	push   $0xd
f01037dc:	eb 26                	jmp    f0103804 <_alltraps>

f01037de <handler14>:
TRAPHANDLER(handler14, T_PGFLT)
f01037de:	6a 0e                	push   $0xe
f01037e0:	eb 22                	jmp    f0103804 <_alltraps>

f01037e2 <handler15>:
TRAPHANDLER_NOEC(handler15, T_RES)  /* reserved */
f01037e2:	6a 00                	push   $0x0
f01037e4:	6a 0f                	push   $0xf
f01037e6:	eb 1c                	jmp    f0103804 <_alltraps>

f01037e8 <handler16>:
TRAPHANDLER_NOEC(handler16, T_FPERR)
f01037e8:	6a 00                	push   $0x0
f01037ea:	6a 10                	push   $0x10
f01037ec:	eb 16                	jmp    f0103804 <_alltraps>

f01037ee <handler17>:
TRAPHANDLER(handler17, T_ALIGN)
f01037ee:	6a 11                	push   $0x11
f01037f0:	eb 12                	jmp    f0103804 <_alltraps>

f01037f2 <handler18>:
TRAPHANDLER_NOEC(handler18, T_MCHK)
f01037f2:	6a 00                	push   $0x0
f01037f4:	6a 12                	push   $0x12
f01037f6:	eb 0c                	jmp    f0103804 <_alltraps>

f01037f8 <handler19>:
TRAPHANDLER_NOEC(handler19, T_SIMDERR)
f01037f8:	6a 00                	push   $0x0
f01037fa:	6a 13                	push   $0x13
f01037fc:	eb 06                	jmp    f0103804 <_alltraps>

f01037fe <handler_syscall>:

TRAPHANDLER_NOEC(handler_syscall, T_SYSCALL)
f01037fe:	6a 00                	push   $0x0
f0103800:	6a 30                	push   $0x30
f0103802:	eb 00                	jmp    f0103804 <_alltraps>

f0103804 <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */
.globl _alltraps
_alltraps:
pushl %ds                                                                                  
f0103804:	1e                   	push   %ds
pushl %es
f0103805:	06                   	push   %es
pushal
f0103806:	60                   	pusha  

movw $GD_KD, %ax
f0103807:	66 b8 10 00          	mov    $0x10,%ax
movw %ax, %ds
f010380b:	8e d8                	mov    %eax,%ds
movw %ax, %es
f010380d:	8e c0                	mov    %eax,%es

pushl %esp  /* trap(%esp) */
f010380f:	54                   	push   %esp
call trap
f0103810:	e8 29 fe ff ff       	call   f010363e <trap>

f0103815 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0103815:	55                   	push   %ebp
f0103816:	89 e5                	mov    %esp,%ebp
f0103818:	83 ec 18             	sub    $0x18,%esp
f010381b:	8b 45 08             	mov    0x8(%ebp),%eax
        SYS_env_destroy,
        NSYSCALLS
    };
    */

	switch (syscallno) {
f010381e:	83 f8 04             	cmp    $0x4,%eax
f0103821:	77 07                	ja     f010382a <syscall+0x15>
f0103823:	ff 24 85 08 5f 10 f0 	jmp    *-0xfefa0f8(,%eax,4)
        return sys_env_destroy(a1);
    case NSYSCALLS:
        return 0;
        break;
	default:
		return -E_NO_SYS;
f010382a:	b8 f9 ff ff ff       	mov    $0xfffffff9,%eax
f010382f:	e9 ab 00 00 00       	jmp    f01038df <syscall+0xca>
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
    user_mem_assert(curenv, s, len, PTE_U);
f0103834:	6a 04                	push   $0x4
f0103836:	ff 75 10             	pushl  0x10(%ebp)
f0103839:	ff 75 0c             	pushl  0xc(%ebp)
f010383c:	ff 35 48 ce 17 f0    	pushl  0xf017ce48
f0103842:	e8 82 f0 ff ff       	call   f01028c9 <user_mem_assert>

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0103847:	83 c4 0c             	add    $0xc,%esp
f010384a:	ff 75 0c             	pushl  0xc(%ebp)
f010384d:	ff 75 10             	pushl  0x10(%ebp)
f0103850:	68 d0 5e 10 f0       	push   $0xf0105ed0
f0103855:	e8 a0 f7 ff ff       	call   f0102ffa <cprintf>
f010385a:	83 c4 10             	add    $0x10,%esp
    */

	switch (syscallno) {
    case SYS_cputs:
        sys_cputs((const char *)a1, (size_t)a2);
        return 0;
f010385d:	b8 00 00 00 00       	mov    $0x0,%eax
f0103862:	eb 7b                	jmp    f01038df <syscall+0xca>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0103864:	e8 88 cc ff ff       	call   f01004f1 <cons_getc>
	switch (syscallno) {
    case SYS_cputs:
        sys_cputs((const char *)a1, (size_t)a2);
        return 0;
    case SYS_cgetc:
        return sys_cgetc();
f0103869:	eb 74                	jmp    f01038df <syscall+0xca>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f010386b:	a1 48 ce 17 f0       	mov    0xf017ce48,%eax
f0103870:	8b 40 48             	mov    0x48(%eax),%eax
        sys_cputs((const char *)a1, (size_t)a2);
        return 0;
    case SYS_cgetc:
        return sys_cgetc();
    case SYS_getenvid:
        return sys_getenvid();
f0103873:	eb 6a                	jmp    f01038df <syscall+0xca>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0103875:	83 ec 04             	sub    $0x4,%esp
f0103878:	6a 01                	push   $0x1
f010387a:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010387d:	50                   	push   %eax
f010387e:	ff 75 0c             	pushl  0xc(%ebp)
f0103881:	e8 f7 f0 ff ff       	call   f010297d <envid2env>
f0103886:	83 c4 10             	add    $0x10,%esp
f0103889:	85 c0                	test   %eax,%eax
f010388b:	78 52                	js     f01038df <syscall+0xca>
		return r;
	if (e == curenv)
f010388d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103890:	8b 15 48 ce 17 f0    	mov    0xf017ce48,%edx
f0103896:	39 d0                	cmp    %edx,%eax
f0103898:	75 15                	jne    f01038af <syscall+0x9a>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f010389a:	83 ec 08             	sub    $0x8,%esp
f010389d:	ff 70 48             	pushl  0x48(%eax)
f01038a0:	68 d5 5e 10 f0       	push   $0xf0105ed5
f01038a5:	e8 50 f7 ff ff       	call   f0102ffa <cprintf>
f01038aa:	83 c4 10             	add    $0x10,%esp
f01038ad:	eb 16                	jmp    f01038c5 <syscall+0xb0>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f01038af:	83 ec 04             	sub    $0x4,%esp
f01038b2:	ff 70 48             	pushl  0x48(%eax)
f01038b5:	ff 72 48             	pushl  0x48(%edx)
f01038b8:	68 f0 5e 10 f0       	push   $0xf0105ef0
f01038bd:	e8 38 f7 ff ff       	call   f0102ffa <cprintf>
f01038c2:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f01038c5:	83 ec 0c             	sub    $0xc,%esp
f01038c8:	ff 75 f4             	pushl  -0xc(%ebp)
f01038cb:	e8 11 f6 ff ff       	call   f0102ee1 <env_destroy>
f01038d0:	83 c4 10             	add    $0x10,%esp
	return 0;
f01038d3:	b8 00 00 00 00       	mov    $0x0,%eax
f01038d8:	eb 05                	jmp    f01038df <syscall+0xca>
    case SYS_getenvid:
        return sys_getenvid();
    case SYS_env_destroy:
        return sys_env_destroy(a1);
    case NSYSCALLS:
        return 0;
f01038da:	b8 00 00 00 00       	mov    $0x0,%eax
	default:
		return -E_NO_SYS;
	}

    return 0;
}
f01038df:	c9                   	leave  
f01038e0:	c3                   	ret    

f01038e1 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01038e1:	55                   	push   %ebp
f01038e2:	89 e5                	mov    %esp,%ebp
f01038e4:	57                   	push   %edi
f01038e5:	56                   	push   %esi
f01038e6:	53                   	push   %ebx
f01038e7:	83 ec 14             	sub    $0x14,%esp
f01038ea:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01038ed:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01038f0:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01038f3:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f01038f6:	8b 1a                	mov    (%edx),%ebx
f01038f8:	8b 01                	mov    (%ecx),%eax
f01038fa:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01038fd:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0103904:	eb 7f                	jmp    f0103985 <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f0103906:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103909:	01 d8                	add    %ebx,%eax
f010390b:	89 c6                	mov    %eax,%esi
f010390d:	c1 ee 1f             	shr    $0x1f,%esi
f0103910:	01 c6                	add    %eax,%esi
f0103912:	d1 fe                	sar    %esi
f0103914:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0103917:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010391a:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f010391d:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010391f:	eb 03                	jmp    f0103924 <stab_binsearch+0x43>
			m--;
f0103921:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0103924:	39 c3                	cmp    %eax,%ebx
f0103926:	7f 0d                	jg     f0103935 <stab_binsearch+0x54>
f0103928:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f010392c:	83 ea 0c             	sub    $0xc,%edx
f010392f:	39 f9                	cmp    %edi,%ecx
f0103931:	75 ee                	jne    f0103921 <stab_binsearch+0x40>
f0103933:	eb 05                	jmp    f010393a <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0103935:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f0103938:	eb 4b                	jmp    f0103985 <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f010393a:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010393d:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0103940:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0103944:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0103947:	76 11                	jbe    f010395a <stab_binsearch+0x79>
			*region_left = m;
f0103949:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f010394c:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f010394e:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103951:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0103958:	eb 2b                	jmp    f0103985 <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f010395a:	39 55 0c             	cmp    %edx,0xc(%ebp)
f010395d:	73 14                	jae    f0103973 <stab_binsearch+0x92>
			*region_right = m - 1;
f010395f:	83 e8 01             	sub    $0x1,%eax
f0103962:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103965:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0103968:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010396a:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0103971:	eb 12                	jmp    f0103985 <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0103973:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0103976:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0103978:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f010397c:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010397e:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0103985:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0103988:	0f 8e 78 ff ff ff    	jle    f0103906 <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f010398e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0103992:	75 0f                	jne    f01039a3 <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f0103994:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103997:	8b 00                	mov    (%eax),%eax
f0103999:	83 e8 01             	sub    $0x1,%eax
f010399c:	8b 75 e0             	mov    -0x20(%ebp),%esi
f010399f:	89 06                	mov    %eax,(%esi)
f01039a1:	eb 2c                	jmp    f01039cf <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01039a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01039a6:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f01039a8:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01039ab:	8b 0e                	mov    (%esi),%ecx
f01039ad:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01039b0:	8b 75 ec             	mov    -0x14(%ebp),%esi
f01039b3:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01039b6:	eb 03                	jmp    f01039bb <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f01039b8:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01039bb:	39 c8                	cmp    %ecx,%eax
f01039bd:	7e 0b                	jle    f01039ca <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f01039bf:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f01039c3:	83 ea 0c             	sub    $0xc,%edx
f01039c6:	39 df                	cmp    %ebx,%edi
f01039c8:	75 ee                	jne    f01039b8 <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f01039ca:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01039cd:	89 06                	mov    %eax,(%esi)
	}
}
f01039cf:	83 c4 14             	add    $0x14,%esp
f01039d2:	5b                   	pop    %ebx
f01039d3:	5e                   	pop    %esi
f01039d4:	5f                   	pop    %edi
f01039d5:	5d                   	pop    %ebp
f01039d6:	c3                   	ret    

f01039d7 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01039d7:	55                   	push   %ebp
f01039d8:	89 e5                	mov    %esp,%ebp
f01039da:	57                   	push   %edi
f01039db:	56                   	push   %esi
f01039dc:	53                   	push   %ebx
f01039dd:	83 ec 3c             	sub    $0x3c,%esp
f01039e0:	8b 75 08             	mov    0x8(%ebp),%esi
f01039e3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;
    size_t stablen, strlen;

	// Initialize *info
	info->eip_file = "<unknown>";
f01039e6:	c7 03 1c 5f 10 f0    	movl   $0xf0105f1c,(%ebx)
	info->eip_line = 0;
f01039ec:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f01039f3:	c7 43 08 1c 5f 10 f0 	movl   $0xf0105f1c,0x8(%ebx)
	info->eip_fn_namelen = 9;
f01039fa:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0103a01:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0103a04:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0103a0b:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0103a11:	0f 87 92 00 00 00    	ja     f0103aa9 <debuginfo_eip+0xd2>
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
        if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U) < 0)
f0103a17:	6a 04                	push   $0x4
f0103a19:	6a 10                	push   $0x10
f0103a1b:	68 00 00 20 00       	push   $0x200000
f0103a20:	ff 35 48 ce 17 f0    	pushl  0xf017ce48
f0103a26:	e8 02 ee ff ff       	call   f010282d <user_mem_check>
f0103a2b:	83 c4 10             	add    $0x10,%esp
f0103a2e:	85 c0                	test   %eax,%eax
f0103a30:	0f 88 4d 02 00 00    	js     f0103c83 <debuginfo_eip+0x2ac>
        {
            return -1;
        }

		stabs = usd->stabs;
f0103a36:	a1 00 00 20 00       	mov    0x200000,%eax
f0103a3b:	89 c1                	mov    %eax,%ecx
f0103a3d:	89 45 c0             	mov    %eax,-0x40(%ebp)
		stab_end = usd->stab_end;
f0103a40:	8b 3d 04 00 20 00    	mov    0x200004,%edi
		stabstr = usd->stabstr;
f0103a46:	a1 08 00 20 00       	mov    0x200008,%eax
f0103a4b:	89 c2                	mov    %eax,%edx
		stabstr_end = usd->stabstr_end;
f0103a4d:	a1 0c 00 20 00       	mov    0x20000c,%eax
f0103a52:	89 45 bc             	mov    %eax,-0x44(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
        stablen = stab_end - stabs + 1;
        strlen = stabstr_end - stabstr + 1;
f0103a55:	89 55 b8             	mov    %edx,-0x48(%ebp)
f0103a58:	29 d0                	sub    %edx,%eax
f0103a5a:	83 c0 01             	add    $0x1,%eax
f0103a5d:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        if (user_mem_check(curenv, stabs, stablen, PTE_U) < 0)
f0103a60:	6a 04                	push   $0x4
f0103a62:	89 f8                	mov    %edi,%eax
f0103a64:	29 c8                	sub    %ecx,%eax
f0103a66:	c1 f8 02             	sar    $0x2,%eax
f0103a69:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0103a6f:	83 c0 01             	add    $0x1,%eax
f0103a72:	50                   	push   %eax
f0103a73:	51                   	push   %ecx
f0103a74:	ff 35 48 ce 17 f0    	pushl  0xf017ce48
f0103a7a:	e8 ae ed ff ff       	call   f010282d <user_mem_check>
f0103a7f:	83 c4 10             	add    $0x10,%esp
f0103a82:	85 c0                	test   %eax,%eax
f0103a84:	0f 88 00 02 00 00    	js     f0103c8a <debuginfo_eip+0x2b3>
        {
            return -1;
        }
        if (user_mem_check(curenv, stabstr, strlen, PTE_U) < 0)
f0103a8a:	6a 04                	push   $0x4
f0103a8c:	ff 75 c4             	pushl  -0x3c(%ebp)
f0103a8f:	ff 75 b8             	pushl  -0x48(%ebp)
f0103a92:	ff 35 48 ce 17 f0    	pushl  0xf017ce48
f0103a98:	e8 90 ed ff ff       	call   f010282d <user_mem_check>
f0103a9d:	83 c4 10             	add    $0x10,%esp
f0103aa0:	85 c0                	test   %eax,%eax
f0103aa2:	79 1f                	jns    f0103ac3 <debuginfo_eip+0xec>
f0103aa4:	e9 e8 01 00 00       	jmp    f0103c91 <debuginfo_eip+0x2ba>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0103aa9:	c7 45 bc 7f 05 11 f0 	movl   $0xf011057f,-0x44(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0103ab0:	c7 45 b8 3d db 10 f0 	movl   $0xf010db3d,-0x48(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0103ab7:	bf 3c db 10 f0       	mov    $0xf010db3c,%edi
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0103abc:	c7 45 c0 50 61 10 f0 	movl   $0xf0106150,-0x40(%ebp)
            return -1;
        }
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0103ac3:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0103ac6:	39 45 b8             	cmp    %eax,-0x48(%ebp)
f0103ac9:	0f 83 c9 01 00 00    	jae    f0103c98 <debuginfo_eip+0x2c1>
f0103acf:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0103ad3:	0f 85 c6 01 00 00    	jne    f0103c9f <debuginfo_eip+0x2c8>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0103ad9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0103ae0:	2b 7d c0             	sub    -0x40(%ebp),%edi
f0103ae3:	c1 ff 02             	sar    $0x2,%edi
f0103ae6:	69 c7 ab aa aa aa    	imul   $0xaaaaaaab,%edi,%eax
f0103aec:	83 e8 01             	sub    $0x1,%eax
f0103aef:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0103af2:	83 ec 08             	sub    $0x8,%esp
f0103af5:	56                   	push   %esi
f0103af6:	6a 64                	push   $0x64
f0103af8:	8d 55 e0             	lea    -0x20(%ebp),%edx
f0103afb:	89 d1                	mov    %edx,%ecx
f0103afd:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0103b00:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0103b03:	89 f8                	mov    %edi,%eax
f0103b05:	e8 d7 fd ff ff       	call   f01038e1 <stab_binsearch>
	if (lfile == 0)
f0103b0a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103b0d:	83 c4 10             	add    $0x10,%esp
f0103b10:	85 c0                	test   %eax,%eax
f0103b12:	0f 84 8e 01 00 00    	je     f0103ca6 <debuginfo_eip+0x2cf>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0103b18:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0103b1b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103b1e:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0103b21:	83 ec 08             	sub    $0x8,%esp
f0103b24:	56                   	push   %esi
f0103b25:	6a 24                	push   $0x24
f0103b27:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0103b2a:	89 d1                	mov    %edx,%ecx
f0103b2c:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0103b2f:	89 f8                	mov    %edi,%eax
f0103b31:	e8 ab fd ff ff       	call   f01038e1 <stab_binsearch>

	if (lfun <= rfun) {
f0103b36:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103b39:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103b3c:	89 55 c4             	mov    %edx,-0x3c(%ebp)
f0103b3f:	83 c4 10             	add    $0x10,%esp
f0103b42:	39 d0                	cmp    %edx,%eax
f0103b44:	7f 2b                	jg     f0103b71 <debuginfo_eip+0x19a>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0103b46:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103b49:	8d 0c 97             	lea    (%edi,%edx,4),%ecx
f0103b4c:	8b 11                	mov    (%ecx),%edx
f0103b4e:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0103b51:	2b 7d b8             	sub    -0x48(%ebp),%edi
f0103b54:	39 fa                	cmp    %edi,%edx
f0103b56:	73 06                	jae    f0103b5e <debuginfo_eip+0x187>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0103b58:	03 55 b8             	add    -0x48(%ebp),%edx
f0103b5b:	89 53 08             	mov    %edx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0103b5e:	8b 51 08             	mov    0x8(%ecx),%edx
f0103b61:	89 53 10             	mov    %edx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0103b64:	29 d6                	sub    %edx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0103b66:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0103b69:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0103b6c:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0103b6f:	eb 0f                	jmp    f0103b80 <debuginfo_eip+0x1a9>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0103b71:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0103b74:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103b77:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0103b7a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103b7d:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0103b80:	83 ec 08             	sub    $0x8,%esp
f0103b83:	6a 3a                	push   $0x3a
f0103b85:	ff 73 08             	pushl  0x8(%ebx)
f0103b88:	e8 86 09 00 00       	call   f0104513 <strfind>
f0103b8d:	2b 43 08             	sub    0x8(%ebx),%eax
f0103b90:	89 43 0c             	mov    %eax,0xc(%ebx)
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.

    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0103b93:	83 c4 08             	add    $0x8,%esp
f0103b96:	56                   	push   %esi
f0103b97:	6a 44                	push   $0x44
f0103b99:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0103b9c:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0103b9f:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0103ba2:	89 f8                	mov    %edi,%eax
f0103ba4:	e8 38 fd ff ff       	call   f01038e1 <stab_binsearch>
    if (lline <= rline) {
f0103ba9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103bac:	83 c4 10             	add    $0x10,%esp
f0103baf:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0103bb2:	7f 0d                	jg     f0103bc1 <debuginfo_eip+0x1ea>
        info->eip_line = stabs[lline].n_desc;
f0103bb4:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0103bb7:	0f b7 44 87 06       	movzwl 0x6(%edi,%eax,4),%eax
f0103bbc:	89 43 04             	mov    %eax,0x4(%ebx)
f0103bbf:	eb 10                	jmp    f0103bd1 <debuginfo_eip+0x1fa>
    }
    else {
        cprintf("line not find\n");
f0103bc1:	83 ec 0c             	sub    $0xc,%esp
f0103bc4:	68 26 5f 10 f0       	push   $0xf0105f26
f0103bc9:	e8 2c f4 ff ff       	call   f0102ffa <cprintf>
f0103bce:	83 c4 10             	add    $0x10,%esp
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0103bd1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103bd4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103bd7:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103bda:	8b 75 c0             	mov    -0x40(%ebp),%esi
f0103bdd:	8d 14 96             	lea    (%esi,%edx,4),%edx
f0103be0:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f0103be4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0103be7:	eb 0a                	jmp    f0103bf3 <debuginfo_eip+0x21c>
f0103be9:	83 e8 01             	sub    $0x1,%eax
f0103bec:	83 ea 0c             	sub    $0xc,%edx
f0103bef:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f0103bf3:	39 c7                	cmp    %eax,%edi
f0103bf5:	7e 05                	jle    f0103bfc <debuginfo_eip+0x225>
f0103bf7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103bfa:	eb 47                	jmp    f0103c43 <debuginfo_eip+0x26c>
	       && stabs[lline].n_type != N_SOL
f0103bfc:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0103c00:	80 f9 84             	cmp    $0x84,%cl
f0103c03:	75 0e                	jne    f0103c13 <debuginfo_eip+0x23c>
f0103c05:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103c08:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0103c0c:	74 1c                	je     f0103c2a <debuginfo_eip+0x253>
f0103c0e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0103c11:	eb 17                	jmp    f0103c2a <debuginfo_eip+0x253>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0103c13:	80 f9 64             	cmp    $0x64,%cl
f0103c16:	75 d1                	jne    f0103be9 <debuginfo_eip+0x212>
f0103c18:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f0103c1c:	74 cb                	je     f0103be9 <debuginfo_eip+0x212>
f0103c1e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103c21:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0103c25:	74 03                	je     f0103c2a <debuginfo_eip+0x253>
f0103c27:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0103c2a:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0103c2d:	8b 75 c0             	mov    -0x40(%ebp),%esi
f0103c30:	8b 14 86             	mov    (%esi,%eax,4),%edx
f0103c33:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0103c36:	8b 7d b8             	mov    -0x48(%ebp),%edi
f0103c39:	29 f8                	sub    %edi,%eax
f0103c3b:	39 c2                	cmp    %eax,%edx
f0103c3d:	73 04                	jae    f0103c43 <debuginfo_eip+0x26c>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0103c3f:	01 fa                	add    %edi,%edx
f0103c41:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0103c43:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103c46:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103c49:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0103c4e:	39 f2                	cmp    %esi,%edx
f0103c50:	7d 60                	jge    f0103cb2 <debuginfo_eip+0x2db>
		for (lline = lfun + 1;
f0103c52:	83 c2 01             	add    $0x1,%edx
f0103c55:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0103c58:	89 d0                	mov    %edx,%eax
f0103c5a:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0103c5d:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0103c60:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0103c63:	eb 04                	jmp    f0103c69 <debuginfo_eip+0x292>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0103c65:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0103c69:	39 c6                	cmp    %eax,%esi
f0103c6b:	7e 40                	jle    f0103cad <debuginfo_eip+0x2d6>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0103c6d:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0103c71:	83 c0 01             	add    $0x1,%eax
f0103c74:	83 c2 0c             	add    $0xc,%edx
f0103c77:	80 f9 a0             	cmp    $0xa0,%cl
f0103c7a:	74 e9                	je     f0103c65 <debuginfo_eip+0x28e>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103c7c:	b8 00 00 00 00       	mov    $0x0,%eax
f0103c81:	eb 2f                	jmp    f0103cb2 <debuginfo_eip+0x2db>
		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
        if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U) < 0)
        {
            return -1;
f0103c83:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103c88:	eb 28                	jmp    f0103cb2 <debuginfo_eip+0x2db>
		// LAB 3: Your code here.
        stablen = stab_end - stabs + 1;
        strlen = stabstr_end - stabstr + 1;
        if (user_mem_check(curenv, stabs, stablen, PTE_U) < 0)
        {
            return -1;
f0103c8a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103c8f:	eb 21                	jmp    f0103cb2 <debuginfo_eip+0x2db>
        }
        if (user_mem_check(curenv, stabstr, strlen, PTE_U) < 0)
        {
            return -1;
f0103c91:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103c96:	eb 1a                	jmp    f0103cb2 <debuginfo_eip+0x2db>
        }
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0103c98:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103c9d:	eb 13                	jmp    f0103cb2 <debuginfo_eip+0x2db>
f0103c9f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103ca4:	eb 0c                	jmp    f0103cb2 <debuginfo_eip+0x2db>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0103ca6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103cab:	eb 05                	jmp    f0103cb2 <debuginfo_eip+0x2db>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103cad:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103cb2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103cb5:	5b                   	pop    %ebx
f0103cb6:	5e                   	pop    %esi
f0103cb7:	5f                   	pop    %edi
f0103cb8:	5d                   	pop    %ebp
f0103cb9:	c3                   	ret    

f0103cba <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0103cba:	55                   	push   %ebp
f0103cbb:	89 e5                	mov    %esp,%ebp
f0103cbd:	57                   	push   %edi
f0103cbe:	56                   	push   %esi
f0103cbf:	53                   	push   %ebx
f0103cc0:	83 ec 1c             	sub    $0x1c,%esp
f0103cc3:	89 c7                	mov    %eax,%edi
f0103cc5:	89 d6                	mov    %edx,%esi
f0103cc7:	8b 45 08             	mov    0x8(%ebp),%eax
f0103cca:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103ccd:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103cd0:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0103cd3:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0103cd6:	bb 00 00 00 00       	mov    $0x0,%ebx
f0103cdb:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0103cde:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0103ce1:	39 d3                	cmp    %edx,%ebx
f0103ce3:	72 05                	jb     f0103cea <printnum+0x30>
f0103ce5:	39 45 10             	cmp    %eax,0x10(%ebp)
f0103ce8:	77 45                	ja     f0103d2f <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0103cea:	83 ec 0c             	sub    $0xc,%esp
f0103ced:	ff 75 18             	pushl  0x18(%ebp)
f0103cf0:	8b 45 14             	mov    0x14(%ebp),%eax
f0103cf3:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0103cf6:	53                   	push   %ebx
f0103cf7:	ff 75 10             	pushl  0x10(%ebp)
f0103cfa:	83 ec 08             	sub    $0x8,%esp
f0103cfd:	ff 75 e4             	pushl  -0x1c(%ebp)
f0103d00:	ff 75 e0             	pushl  -0x20(%ebp)
f0103d03:	ff 75 dc             	pushl  -0x24(%ebp)
f0103d06:	ff 75 d8             	pushl  -0x28(%ebp)
f0103d09:	e8 32 0a 00 00       	call   f0104740 <__udivdi3>
f0103d0e:	83 c4 18             	add    $0x18,%esp
f0103d11:	52                   	push   %edx
f0103d12:	50                   	push   %eax
f0103d13:	89 f2                	mov    %esi,%edx
f0103d15:	89 f8                	mov    %edi,%eax
f0103d17:	e8 9e ff ff ff       	call   f0103cba <printnum>
f0103d1c:	83 c4 20             	add    $0x20,%esp
f0103d1f:	eb 18                	jmp    f0103d39 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0103d21:	83 ec 08             	sub    $0x8,%esp
f0103d24:	56                   	push   %esi
f0103d25:	ff 75 18             	pushl  0x18(%ebp)
f0103d28:	ff d7                	call   *%edi
f0103d2a:	83 c4 10             	add    $0x10,%esp
f0103d2d:	eb 03                	jmp    f0103d32 <printnum+0x78>
f0103d2f:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0103d32:	83 eb 01             	sub    $0x1,%ebx
f0103d35:	85 db                	test   %ebx,%ebx
f0103d37:	7f e8                	jg     f0103d21 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0103d39:	83 ec 08             	sub    $0x8,%esp
f0103d3c:	56                   	push   %esi
f0103d3d:	83 ec 04             	sub    $0x4,%esp
f0103d40:	ff 75 e4             	pushl  -0x1c(%ebp)
f0103d43:	ff 75 e0             	pushl  -0x20(%ebp)
f0103d46:	ff 75 dc             	pushl  -0x24(%ebp)
f0103d49:	ff 75 d8             	pushl  -0x28(%ebp)
f0103d4c:	e8 1f 0b 00 00       	call   f0104870 <__umoddi3>
f0103d51:	83 c4 14             	add    $0x14,%esp
f0103d54:	0f be 80 35 5f 10 f0 	movsbl -0xfefa0cb(%eax),%eax
f0103d5b:	50                   	push   %eax
f0103d5c:	ff d7                	call   *%edi
}
f0103d5e:	83 c4 10             	add    $0x10,%esp
f0103d61:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103d64:	5b                   	pop    %ebx
f0103d65:	5e                   	pop    %esi
f0103d66:	5f                   	pop    %edi
f0103d67:	5d                   	pop    %ebp
f0103d68:	c3                   	ret    

f0103d69 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0103d69:	55                   	push   %ebp
f0103d6a:	89 e5                	mov    %esp,%ebp
f0103d6c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0103d6f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0103d73:	8b 10                	mov    (%eax),%edx
f0103d75:	3b 50 04             	cmp    0x4(%eax),%edx
f0103d78:	73 0a                	jae    f0103d84 <sprintputch+0x1b>
		*b->buf++ = ch;
f0103d7a:	8d 4a 01             	lea    0x1(%edx),%ecx
f0103d7d:	89 08                	mov    %ecx,(%eax)
f0103d7f:	8b 45 08             	mov    0x8(%ebp),%eax
f0103d82:	88 02                	mov    %al,(%edx)
}
f0103d84:	5d                   	pop    %ebp
f0103d85:	c3                   	ret    

f0103d86 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0103d86:	55                   	push   %ebp
f0103d87:	89 e5                	mov    %esp,%ebp
f0103d89:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0103d8c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0103d8f:	50                   	push   %eax
f0103d90:	ff 75 10             	pushl  0x10(%ebp)
f0103d93:	ff 75 0c             	pushl  0xc(%ebp)
f0103d96:	ff 75 08             	pushl  0x8(%ebp)
f0103d99:	e8 05 00 00 00       	call   f0103da3 <vprintfmt>
	va_end(ap);
}
f0103d9e:	83 c4 10             	add    $0x10,%esp
f0103da1:	c9                   	leave  
f0103da2:	c3                   	ret    

f0103da3 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0103da3:	55                   	push   %ebp
f0103da4:	89 e5                	mov    %esp,%ebp
f0103da6:	57                   	push   %edi
f0103da7:	56                   	push   %esi
f0103da8:	53                   	push   %ebx
f0103da9:	83 ec 2c             	sub    $0x2c,%esp
f0103dac:	8b 75 08             	mov    0x8(%ebp),%esi
f0103daf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103db2:	8b 7d 10             	mov    0x10(%ebp),%edi
f0103db5:	eb 12                	jmp    f0103dc9 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0103db7:	85 c0                	test   %eax,%eax
f0103db9:	0f 84 a9 04 00 00    	je     f0104268 <vprintfmt+0x4c5>
				return;
			putch(ch, putdat);
f0103dbf:	83 ec 08             	sub    $0x8,%esp
f0103dc2:	53                   	push   %ebx
f0103dc3:	50                   	push   %eax
f0103dc4:	ff d6                	call   *%esi
f0103dc6:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0103dc9:	83 c7 01             	add    $0x1,%edi
f0103dcc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0103dd0:	83 f8 25             	cmp    $0x25,%eax
f0103dd3:	75 e2                	jne    f0103db7 <vprintfmt+0x14>
f0103dd5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0103dd9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0103de0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0103de7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0103dee:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103df3:	eb 07                	jmp    f0103dfc <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103df5:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0103df8:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103dfc:	8d 47 01             	lea    0x1(%edi),%eax
f0103dff:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103e02:	0f b6 07             	movzbl (%edi),%eax
f0103e05:	0f b6 d0             	movzbl %al,%edx
f0103e08:	83 e8 23             	sub    $0x23,%eax
f0103e0b:	3c 55                	cmp    $0x55,%al
f0103e0d:	0f 87 3a 04 00 00    	ja     f010424d <vprintfmt+0x4aa>
f0103e13:	0f b6 c0             	movzbl %al,%eax
f0103e16:	ff 24 85 c0 5f 10 f0 	jmp    *-0xfefa040(,%eax,4)
f0103e1d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0103e20:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0103e24:	eb d6                	jmp    f0103dfc <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103e26:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103e29:	b8 00 00 00 00       	mov    $0x0,%eax
f0103e2e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0103e31:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0103e34:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f0103e38:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f0103e3b:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0103e3e:	83 f9 09             	cmp    $0x9,%ecx
f0103e41:	77 3f                	ja     f0103e82 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0103e43:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0103e46:	eb e9                	jmp    f0103e31 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0103e48:	8b 45 14             	mov    0x14(%ebp),%eax
f0103e4b:	8b 00                	mov    (%eax),%eax
f0103e4d:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0103e50:	8b 45 14             	mov    0x14(%ebp),%eax
f0103e53:	8d 40 04             	lea    0x4(%eax),%eax
f0103e56:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103e59:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0103e5c:	eb 2a                	jmp    f0103e88 <vprintfmt+0xe5>
f0103e5e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103e61:	85 c0                	test   %eax,%eax
f0103e63:	ba 00 00 00 00       	mov    $0x0,%edx
f0103e68:	0f 49 d0             	cmovns %eax,%edx
f0103e6b:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103e6e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103e71:	eb 89                	jmp    f0103dfc <vprintfmt+0x59>
f0103e73:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0103e76:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0103e7d:	e9 7a ff ff ff       	jmp    f0103dfc <vprintfmt+0x59>
f0103e82:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0103e85:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0103e88:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0103e8c:	0f 89 6a ff ff ff    	jns    f0103dfc <vprintfmt+0x59>
				width = precision, precision = -1;
f0103e92:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103e95:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103e98:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0103e9f:	e9 58 ff ff ff       	jmp    f0103dfc <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0103ea4:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103ea7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0103eaa:	e9 4d ff ff ff       	jmp    f0103dfc <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0103eaf:	8b 45 14             	mov    0x14(%ebp),%eax
f0103eb2:	8d 78 04             	lea    0x4(%eax),%edi
f0103eb5:	83 ec 08             	sub    $0x8,%esp
f0103eb8:	53                   	push   %ebx
f0103eb9:	ff 30                	pushl  (%eax)
f0103ebb:	ff d6                	call   *%esi
			break;
f0103ebd:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0103ec0:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103ec3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0103ec6:	e9 fe fe ff ff       	jmp    f0103dc9 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0103ecb:	8b 45 14             	mov    0x14(%ebp),%eax
f0103ece:	8d 78 04             	lea    0x4(%eax),%edi
f0103ed1:	8b 00                	mov    (%eax),%eax
f0103ed3:	99                   	cltd   
f0103ed4:	31 d0                	xor    %edx,%eax
f0103ed6:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0103ed8:	83 f8 07             	cmp    $0x7,%eax
f0103edb:	7f 0b                	jg     f0103ee8 <vprintfmt+0x145>
f0103edd:	8b 14 85 20 61 10 f0 	mov    -0xfef9ee0(,%eax,4),%edx
f0103ee4:	85 d2                	test   %edx,%edx
f0103ee6:	75 1b                	jne    f0103f03 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
f0103ee8:	50                   	push   %eax
f0103ee9:	68 4d 5f 10 f0       	push   $0xf0105f4d
f0103eee:	53                   	push   %ebx
f0103eef:	56                   	push   %esi
f0103ef0:	e8 91 fe ff ff       	call   f0103d86 <printfmt>
f0103ef5:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
f0103ef8:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103efb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0103efe:	e9 c6 fe ff ff       	jmp    f0103dc9 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f0103f03:	52                   	push   %edx
f0103f04:	68 4d 57 10 f0       	push   $0xf010574d
f0103f09:	53                   	push   %ebx
f0103f0a:	56                   	push   %esi
f0103f0b:	e8 76 fe ff ff       	call   f0103d86 <printfmt>
f0103f10:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
f0103f13:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103f16:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103f19:	e9 ab fe ff ff       	jmp    f0103dc9 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0103f1e:	8b 45 14             	mov    0x14(%ebp),%eax
f0103f21:	83 c0 04             	add    $0x4,%eax
f0103f24:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0103f27:	8b 45 14             	mov    0x14(%ebp),%eax
f0103f2a:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0103f2c:	85 ff                	test   %edi,%edi
f0103f2e:	b8 46 5f 10 f0       	mov    $0xf0105f46,%eax
f0103f33:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0103f36:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0103f3a:	0f 8e 94 00 00 00    	jle    f0103fd4 <vprintfmt+0x231>
f0103f40:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0103f44:	0f 84 98 00 00 00    	je     f0103fe2 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
f0103f4a:	83 ec 08             	sub    $0x8,%esp
f0103f4d:	ff 75 d0             	pushl  -0x30(%ebp)
f0103f50:	57                   	push   %edi
f0103f51:	e8 73 04 00 00       	call   f01043c9 <strnlen>
f0103f56:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103f59:	29 c1                	sub    %eax,%ecx
f0103f5b:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0103f5e:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0103f61:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0103f65:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103f68:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0103f6b:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0103f6d:	eb 0f                	jmp    f0103f7e <vprintfmt+0x1db>
					putch(padc, putdat);
f0103f6f:	83 ec 08             	sub    $0x8,%esp
f0103f72:	53                   	push   %ebx
f0103f73:	ff 75 e0             	pushl  -0x20(%ebp)
f0103f76:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0103f78:	83 ef 01             	sub    $0x1,%edi
f0103f7b:	83 c4 10             	add    $0x10,%esp
f0103f7e:	85 ff                	test   %edi,%edi
f0103f80:	7f ed                	jg     f0103f6f <vprintfmt+0x1cc>
f0103f82:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103f85:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0103f88:	85 c9                	test   %ecx,%ecx
f0103f8a:	b8 00 00 00 00       	mov    $0x0,%eax
f0103f8f:	0f 49 c1             	cmovns %ecx,%eax
f0103f92:	29 c1                	sub    %eax,%ecx
f0103f94:	89 75 08             	mov    %esi,0x8(%ebp)
f0103f97:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0103f9a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0103f9d:	89 cb                	mov    %ecx,%ebx
f0103f9f:	eb 4d                	jmp    f0103fee <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0103fa1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0103fa5:	74 1b                	je     f0103fc2 <vprintfmt+0x21f>
f0103fa7:	0f be c0             	movsbl %al,%eax
f0103faa:	83 e8 20             	sub    $0x20,%eax
f0103fad:	83 f8 5e             	cmp    $0x5e,%eax
f0103fb0:	76 10                	jbe    f0103fc2 <vprintfmt+0x21f>
					putch('?', putdat);
f0103fb2:	83 ec 08             	sub    $0x8,%esp
f0103fb5:	ff 75 0c             	pushl  0xc(%ebp)
f0103fb8:	6a 3f                	push   $0x3f
f0103fba:	ff 55 08             	call   *0x8(%ebp)
f0103fbd:	83 c4 10             	add    $0x10,%esp
f0103fc0:	eb 0d                	jmp    f0103fcf <vprintfmt+0x22c>
				else
					putch(ch, putdat);
f0103fc2:	83 ec 08             	sub    $0x8,%esp
f0103fc5:	ff 75 0c             	pushl  0xc(%ebp)
f0103fc8:	52                   	push   %edx
f0103fc9:	ff 55 08             	call   *0x8(%ebp)
f0103fcc:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0103fcf:	83 eb 01             	sub    $0x1,%ebx
f0103fd2:	eb 1a                	jmp    f0103fee <vprintfmt+0x24b>
f0103fd4:	89 75 08             	mov    %esi,0x8(%ebp)
f0103fd7:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0103fda:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0103fdd:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0103fe0:	eb 0c                	jmp    f0103fee <vprintfmt+0x24b>
f0103fe2:	89 75 08             	mov    %esi,0x8(%ebp)
f0103fe5:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0103fe8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0103feb:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0103fee:	83 c7 01             	add    $0x1,%edi
f0103ff1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0103ff5:	0f be d0             	movsbl %al,%edx
f0103ff8:	85 d2                	test   %edx,%edx
f0103ffa:	74 23                	je     f010401f <vprintfmt+0x27c>
f0103ffc:	85 f6                	test   %esi,%esi
f0103ffe:	78 a1                	js     f0103fa1 <vprintfmt+0x1fe>
f0104000:	83 ee 01             	sub    $0x1,%esi
f0104003:	79 9c                	jns    f0103fa1 <vprintfmt+0x1fe>
f0104005:	89 df                	mov    %ebx,%edi
f0104007:	8b 75 08             	mov    0x8(%ebp),%esi
f010400a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010400d:	eb 18                	jmp    f0104027 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f010400f:	83 ec 08             	sub    $0x8,%esp
f0104012:	53                   	push   %ebx
f0104013:	6a 20                	push   $0x20
f0104015:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0104017:	83 ef 01             	sub    $0x1,%edi
f010401a:	83 c4 10             	add    $0x10,%esp
f010401d:	eb 08                	jmp    f0104027 <vprintfmt+0x284>
f010401f:	89 df                	mov    %ebx,%edi
f0104021:	8b 75 08             	mov    0x8(%ebp),%esi
f0104024:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104027:	85 ff                	test   %edi,%edi
f0104029:	7f e4                	jg     f010400f <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f010402b:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010402e:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104031:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104034:	e9 90 fd ff ff       	jmp    f0103dc9 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0104039:	83 f9 01             	cmp    $0x1,%ecx
f010403c:	7e 19                	jle    f0104057 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
f010403e:	8b 45 14             	mov    0x14(%ebp),%eax
f0104041:	8b 50 04             	mov    0x4(%eax),%edx
f0104044:	8b 00                	mov    (%eax),%eax
f0104046:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104049:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010404c:	8b 45 14             	mov    0x14(%ebp),%eax
f010404f:	8d 40 08             	lea    0x8(%eax),%eax
f0104052:	89 45 14             	mov    %eax,0x14(%ebp)
f0104055:	eb 38                	jmp    f010408f <vprintfmt+0x2ec>
	else if (lflag)
f0104057:	85 c9                	test   %ecx,%ecx
f0104059:	74 1b                	je     f0104076 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
f010405b:	8b 45 14             	mov    0x14(%ebp),%eax
f010405e:	8b 00                	mov    (%eax),%eax
f0104060:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104063:	89 c1                	mov    %eax,%ecx
f0104065:	c1 f9 1f             	sar    $0x1f,%ecx
f0104068:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f010406b:	8b 45 14             	mov    0x14(%ebp),%eax
f010406e:	8d 40 04             	lea    0x4(%eax),%eax
f0104071:	89 45 14             	mov    %eax,0x14(%ebp)
f0104074:	eb 19                	jmp    f010408f <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
f0104076:	8b 45 14             	mov    0x14(%ebp),%eax
f0104079:	8b 00                	mov    (%eax),%eax
f010407b:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010407e:	89 c1                	mov    %eax,%ecx
f0104080:	c1 f9 1f             	sar    $0x1f,%ecx
f0104083:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0104086:	8b 45 14             	mov    0x14(%ebp),%eax
f0104089:	8d 40 04             	lea    0x4(%eax),%eax
f010408c:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f010408f:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104092:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0104095:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f010409a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f010409e:	0f 89 75 01 00 00    	jns    f0104219 <vprintfmt+0x476>
				putch('-', putdat);
f01040a4:	83 ec 08             	sub    $0x8,%esp
f01040a7:	53                   	push   %ebx
f01040a8:	6a 2d                	push   $0x2d
f01040aa:	ff d6                	call   *%esi
				num = -(long long) num;
f01040ac:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01040af:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f01040b2:	f7 da                	neg    %edx
f01040b4:	83 d1 00             	adc    $0x0,%ecx
f01040b7:	f7 d9                	neg    %ecx
f01040b9:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f01040bc:	b8 0a 00 00 00       	mov    $0xa,%eax
f01040c1:	e9 53 01 00 00       	jmp    f0104219 <vprintfmt+0x476>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01040c6:	83 f9 01             	cmp    $0x1,%ecx
f01040c9:	7e 18                	jle    f01040e3 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
f01040cb:	8b 45 14             	mov    0x14(%ebp),%eax
f01040ce:	8b 10                	mov    (%eax),%edx
f01040d0:	8b 48 04             	mov    0x4(%eax),%ecx
f01040d3:	8d 40 08             	lea    0x8(%eax),%eax
f01040d6:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f01040d9:	b8 0a 00 00 00       	mov    $0xa,%eax
f01040de:	e9 36 01 00 00       	jmp    f0104219 <vprintfmt+0x476>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
f01040e3:	85 c9                	test   %ecx,%ecx
f01040e5:	74 1a                	je     f0104101 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
f01040e7:	8b 45 14             	mov    0x14(%ebp),%eax
f01040ea:	8b 10                	mov    (%eax),%edx
f01040ec:	b9 00 00 00 00       	mov    $0x0,%ecx
f01040f1:	8d 40 04             	lea    0x4(%eax),%eax
f01040f4:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f01040f7:	b8 0a 00 00 00       	mov    $0xa,%eax
f01040fc:	e9 18 01 00 00       	jmp    f0104219 <vprintfmt+0x476>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
f0104101:	8b 45 14             	mov    0x14(%ebp),%eax
f0104104:	8b 10                	mov    (%eax),%edx
f0104106:	b9 00 00 00 00       	mov    $0x0,%ecx
f010410b:	8d 40 04             	lea    0x4(%eax),%eax
f010410e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f0104111:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104116:	e9 fe 00 00 00       	jmp    f0104219 <vprintfmt+0x476>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f010411b:	83 f9 01             	cmp    $0x1,%ecx
f010411e:	7e 19                	jle    f0104139 <vprintfmt+0x396>
		return va_arg(*ap, long long);
f0104120:	8b 45 14             	mov    0x14(%ebp),%eax
f0104123:	8b 50 04             	mov    0x4(%eax),%edx
f0104126:	8b 00                	mov    (%eax),%eax
f0104128:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010412b:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010412e:	8b 45 14             	mov    0x14(%ebp),%eax
f0104131:	8d 40 08             	lea    0x8(%eax),%eax
f0104134:	89 45 14             	mov    %eax,0x14(%ebp)
f0104137:	eb 38                	jmp    f0104171 <vprintfmt+0x3ce>
	else if (lflag)
f0104139:	85 c9                	test   %ecx,%ecx
f010413b:	74 1b                	je     f0104158 <vprintfmt+0x3b5>
		return va_arg(*ap, long);
f010413d:	8b 45 14             	mov    0x14(%ebp),%eax
f0104140:	8b 00                	mov    (%eax),%eax
f0104142:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104145:	89 c1                	mov    %eax,%ecx
f0104147:	c1 f9 1f             	sar    $0x1f,%ecx
f010414a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f010414d:	8b 45 14             	mov    0x14(%ebp),%eax
f0104150:	8d 40 04             	lea    0x4(%eax),%eax
f0104153:	89 45 14             	mov    %eax,0x14(%ebp)
f0104156:	eb 19                	jmp    f0104171 <vprintfmt+0x3ce>
	else
		return va_arg(*ap, int);
f0104158:	8b 45 14             	mov    0x14(%ebp),%eax
f010415b:	8b 00                	mov    (%eax),%eax
f010415d:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104160:	89 c1                	mov    %eax,%ecx
f0104162:	c1 f9 1f             	sar    $0x1f,%ecx
f0104165:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0104168:	8b 45 14             	mov    0x14(%ebp),%eax
f010416b:	8d 40 04             	lea    0x4(%eax),%eax
f010416e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
			goto number;

		// (unsigned) octal
		case 'o':
			num = getint(&ap, lflag);
f0104171:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104174:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 8;
f0104177:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;

		// (unsigned) octal
		case 'o':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f010417c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0104180:	0f 89 93 00 00 00    	jns    f0104219 <vprintfmt+0x476>
				putch('-', putdat);
f0104186:	83 ec 08             	sub    $0x8,%esp
f0104189:	53                   	push   %ebx
f010418a:	6a 2d                	push   $0x2d
f010418c:	ff d6                	call   *%esi
				num = -(long long) num;
f010418e:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104191:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0104194:	f7 da                	neg    %edx
f0104196:	83 d1 00             	adc    $0x0,%ecx
f0104199:	f7 d9                	neg    %ecx
f010419b:	83 c4 10             	add    $0x10,%esp
			}
			base = 8;
f010419e:	b8 08 00 00 00       	mov    $0x8,%eax
f01041a3:	eb 74                	jmp    f0104219 <vprintfmt+0x476>
			goto number;

		// pointer
		case 'p':
			putch('0', putdat);
f01041a5:	83 ec 08             	sub    $0x8,%esp
f01041a8:	53                   	push   %ebx
f01041a9:	6a 30                	push   $0x30
f01041ab:	ff d6                	call   *%esi
			putch('x', putdat);
f01041ad:	83 c4 08             	add    $0x8,%esp
f01041b0:	53                   	push   %ebx
f01041b1:	6a 78                	push   $0x78
f01041b3:	ff d6                	call   *%esi
			num = (unsigned long long)
f01041b5:	8b 45 14             	mov    0x14(%ebp),%eax
f01041b8:	8b 10                	mov    (%eax),%edx
f01041ba:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f01041bf:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f01041c2:	8d 40 04             	lea    0x4(%eax),%eax
f01041c5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01041c8:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f01041cd:	eb 4a                	jmp    f0104219 <vprintfmt+0x476>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01041cf:	83 f9 01             	cmp    $0x1,%ecx
f01041d2:	7e 15                	jle    f01041e9 <vprintfmt+0x446>
		return va_arg(*ap, unsigned long long);
f01041d4:	8b 45 14             	mov    0x14(%ebp),%eax
f01041d7:	8b 10                	mov    (%eax),%edx
f01041d9:	8b 48 04             	mov    0x4(%eax),%ecx
f01041dc:	8d 40 08             	lea    0x8(%eax),%eax
f01041df:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f01041e2:	b8 10 00 00 00       	mov    $0x10,%eax
f01041e7:	eb 30                	jmp    f0104219 <vprintfmt+0x476>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
f01041e9:	85 c9                	test   %ecx,%ecx
f01041eb:	74 17                	je     f0104204 <vprintfmt+0x461>
		return va_arg(*ap, unsigned long);
f01041ed:	8b 45 14             	mov    0x14(%ebp),%eax
f01041f0:	8b 10                	mov    (%eax),%edx
f01041f2:	b9 00 00 00 00       	mov    $0x0,%ecx
f01041f7:	8d 40 04             	lea    0x4(%eax),%eax
f01041fa:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f01041fd:	b8 10 00 00 00       	mov    $0x10,%eax
f0104202:	eb 15                	jmp    f0104219 <vprintfmt+0x476>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
f0104204:	8b 45 14             	mov    0x14(%ebp),%eax
f0104207:	8b 10                	mov    (%eax),%edx
f0104209:	b9 00 00 00 00       	mov    $0x0,%ecx
f010420e:	8d 40 04             	lea    0x4(%eax),%eax
f0104211:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f0104214:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f0104219:	83 ec 0c             	sub    $0xc,%esp
f010421c:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0104220:	57                   	push   %edi
f0104221:	ff 75 e0             	pushl  -0x20(%ebp)
f0104224:	50                   	push   %eax
f0104225:	51                   	push   %ecx
f0104226:	52                   	push   %edx
f0104227:	89 da                	mov    %ebx,%edx
f0104229:	89 f0                	mov    %esi,%eax
f010422b:	e8 8a fa ff ff       	call   f0103cba <printnum>
			break;
f0104230:	83 c4 20             	add    $0x20,%esp
f0104233:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104236:	e9 8e fb ff ff       	jmp    f0103dc9 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f010423b:	83 ec 08             	sub    $0x8,%esp
f010423e:	53                   	push   %ebx
f010423f:	52                   	push   %edx
f0104240:	ff d6                	call   *%esi
			break;
f0104242:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104245:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0104248:	e9 7c fb ff ff       	jmp    f0103dc9 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f010424d:	83 ec 08             	sub    $0x8,%esp
f0104250:	53                   	push   %ebx
f0104251:	6a 25                	push   $0x25
f0104253:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0104255:	83 c4 10             	add    $0x10,%esp
f0104258:	eb 03                	jmp    f010425d <vprintfmt+0x4ba>
f010425a:	83 ef 01             	sub    $0x1,%edi
f010425d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0104261:	75 f7                	jne    f010425a <vprintfmt+0x4b7>
f0104263:	e9 61 fb ff ff       	jmp    f0103dc9 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f0104268:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010426b:	5b                   	pop    %ebx
f010426c:	5e                   	pop    %esi
f010426d:	5f                   	pop    %edi
f010426e:	5d                   	pop    %ebp
f010426f:	c3                   	ret    

f0104270 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0104270:	55                   	push   %ebp
f0104271:	89 e5                	mov    %esp,%ebp
f0104273:	83 ec 18             	sub    $0x18,%esp
f0104276:	8b 45 08             	mov    0x8(%ebp),%eax
f0104279:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010427c:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010427f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0104283:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0104286:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010428d:	85 c0                	test   %eax,%eax
f010428f:	74 26                	je     f01042b7 <vsnprintf+0x47>
f0104291:	85 d2                	test   %edx,%edx
f0104293:	7e 22                	jle    f01042b7 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0104295:	ff 75 14             	pushl  0x14(%ebp)
f0104298:	ff 75 10             	pushl  0x10(%ebp)
f010429b:	8d 45 ec             	lea    -0x14(%ebp),%eax
f010429e:	50                   	push   %eax
f010429f:	68 69 3d 10 f0       	push   $0xf0103d69
f01042a4:	e8 fa fa ff ff       	call   f0103da3 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01042a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01042ac:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01042af:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01042b2:	83 c4 10             	add    $0x10,%esp
f01042b5:	eb 05                	jmp    f01042bc <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f01042b7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f01042bc:	c9                   	leave  
f01042bd:	c3                   	ret    

f01042be <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01042be:	55                   	push   %ebp
f01042bf:	89 e5                	mov    %esp,%ebp
f01042c1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01042c4:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01042c7:	50                   	push   %eax
f01042c8:	ff 75 10             	pushl  0x10(%ebp)
f01042cb:	ff 75 0c             	pushl  0xc(%ebp)
f01042ce:	ff 75 08             	pushl  0x8(%ebp)
f01042d1:	e8 9a ff ff ff       	call   f0104270 <vsnprintf>
	va_end(ap);

	return rc;
}
f01042d6:	c9                   	leave  
f01042d7:	c3                   	ret    

f01042d8 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01042d8:	55                   	push   %ebp
f01042d9:	89 e5                	mov    %esp,%ebp
f01042db:	57                   	push   %edi
f01042dc:	56                   	push   %esi
f01042dd:	53                   	push   %ebx
f01042de:	83 ec 0c             	sub    $0xc,%esp
f01042e1:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01042e4:	85 c0                	test   %eax,%eax
f01042e6:	74 11                	je     f01042f9 <readline+0x21>
		cprintf("%s", prompt);
f01042e8:	83 ec 08             	sub    $0x8,%esp
f01042eb:	50                   	push   %eax
f01042ec:	68 4d 57 10 f0       	push   $0xf010574d
f01042f1:	e8 04 ed ff ff       	call   f0102ffa <cprintf>
f01042f6:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f01042f9:	83 ec 0c             	sub    $0xc,%esp
f01042fc:	6a 00                	push   $0x0
f01042fe:	e8 61 c3 ff ff       	call   f0100664 <iscons>
f0104303:	89 c7                	mov    %eax,%edi
f0104305:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0104308:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f010430d:	e8 41 c3 ff ff       	call   f0100653 <getchar>
f0104312:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0104314:	85 c0                	test   %eax,%eax
f0104316:	79 18                	jns    f0104330 <readline+0x58>
			cprintf("read error: %e\n", c);
f0104318:	83 ec 08             	sub    $0x8,%esp
f010431b:	50                   	push   %eax
f010431c:	68 40 61 10 f0       	push   $0xf0106140
f0104321:	e8 d4 ec ff ff       	call   f0102ffa <cprintf>
			return NULL;
f0104326:	83 c4 10             	add    $0x10,%esp
f0104329:	b8 00 00 00 00       	mov    $0x0,%eax
f010432e:	eb 79                	jmp    f01043a9 <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0104330:	83 f8 08             	cmp    $0x8,%eax
f0104333:	0f 94 c2             	sete   %dl
f0104336:	83 f8 7f             	cmp    $0x7f,%eax
f0104339:	0f 94 c0             	sete   %al
f010433c:	08 c2                	or     %al,%dl
f010433e:	74 1a                	je     f010435a <readline+0x82>
f0104340:	85 f6                	test   %esi,%esi
f0104342:	7e 16                	jle    f010435a <readline+0x82>
			if (echoing)
f0104344:	85 ff                	test   %edi,%edi
f0104346:	74 0d                	je     f0104355 <readline+0x7d>
				cputchar('\b');
f0104348:	83 ec 0c             	sub    $0xc,%esp
f010434b:	6a 08                	push   $0x8
f010434d:	e8 f1 c2 ff ff       	call   f0100643 <cputchar>
f0104352:	83 c4 10             	add    $0x10,%esp
			i--;
f0104355:	83 ee 01             	sub    $0x1,%esi
f0104358:	eb b3                	jmp    f010430d <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010435a:	83 fb 1f             	cmp    $0x1f,%ebx
f010435d:	7e 23                	jle    f0104382 <readline+0xaa>
f010435f:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0104365:	7f 1b                	jg     f0104382 <readline+0xaa>
			if (echoing)
f0104367:	85 ff                	test   %edi,%edi
f0104369:	74 0c                	je     f0104377 <readline+0x9f>
				cputchar(c);
f010436b:	83 ec 0c             	sub    $0xc,%esp
f010436e:	53                   	push   %ebx
f010436f:	e8 cf c2 ff ff       	call   f0100643 <cputchar>
f0104374:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0104377:	88 9e 00 d7 17 f0    	mov    %bl,-0xfe82900(%esi)
f010437d:	8d 76 01             	lea    0x1(%esi),%esi
f0104380:	eb 8b                	jmp    f010430d <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0104382:	83 fb 0a             	cmp    $0xa,%ebx
f0104385:	74 05                	je     f010438c <readline+0xb4>
f0104387:	83 fb 0d             	cmp    $0xd,%ebx
f010438a:	75 81                	jne    f010430d <readline+0x35>
			if (echoing)
f010438c:	85 ff                	test   %edi,%edi
f010438e:	74 0d                	je     f010439d <readline+0xc5>
				cputchar('\n');
f0104390:	83 ec 0c             	sub    $0xc,%esp
f0104393:	6a 0a                	push   $0xa
f0104395:	e8 a9 c2 ff ff       	call   f0100643 <cputchar>
f010439a:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f010439d:	c6 86 00 d7 17 f0 00 	movb   $0x0,-0xfe82900(%esi)
			return buf;
f01043a4:	b8 00 d7 17 f0       	mov    $0xf017d700,%eax
		}
	}
}
f01043a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01043ac:	5b                   	pop    %ebx
f01043ad:	5e                   	pop    %esi
f01043ae:	5f                   	pop    %edi
f01043af:	5d                   	pop    %ebp
f01043b0:	c3                   	ret    

f01043b1 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01043b1:	55                   	push   %ebp
f01043b2:	89 e5                	mov    %esp,%ebp
f01043b4:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01043b7:	b8 00 00 00 00       	mov    $0x0,%eax
f01043bc:	eb 03                	jmp    f01043c1 <strlen+0x10>
		n++;
f01043be:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01043c1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01043c5:	75 f7                	jne    f01043be <strlen+0xd>
		n++;
	return n;
}
f01043c7:	5d                   	pop    %ebp
f01043c8:	c3                   	ret    

f01043c9 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01043c9:	55                   	push   %ebp
f01043ca:	89 e5                	mov    %esp,%ebp
f01043cc:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01043cf:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01043d2:	ba 00 00 00 00       	mov    $0x0,%edx
f01043d7:	eb 03                	jmp    f01043dc <strnlen+0x13>
		n++;
f01043d9:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01043dc:	39 c2                	cmp    %eax,%edx
f01043de:	74 08                	je     f01043e8 <strnlen+0x1f>
f01043e0:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f01043e4:	75 f3                	jne    f01043d9 <strnlen+0x10>
f01043e6:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f01043e8:	5d                   	pop    %ebp
f01043e9:	c3                   	ret    

f01043ea <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01043ea:	55                   	push   %ebp
f01043eb:	89 e5                	mov    %esp,%ebp
f01043ed:	53                   	push   %ebx
f01043ee:	8b 45 08             	mov    0x8(%ebp),%eax
f01043f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01043f4:	89 c2                	mov    %eax,%edx
f01043f6:	83 c2 01             	add    $0x1,%edx
f01043f9:	83 c1 01             	add    $0x1,%ecx
f01043fc:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0104400:	88 5a ff             	mov    %bl,-0x1(%edx)
f0104403:	84 db                	test   %bl,%bl
f0104405:	75 ef                	jne    f01043f6 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0104407:	5b                   	pop    %ebx
f0104408:	5d                   	pop    %ebp
f0104409:	c3                   	ret    

f010440a <strcat>:

char *
strcat(char *dst, const char *src)
{
f010440a:	55                   	push   %ebp
f010440b:	89 e5                	mov    %esp,%ebp
f010440d:	53                   	push   %ebx
f010440e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0104411:	53                   	push   %ebx
f0104412:	e8 9a ff ff ff       	call   f01043b1 <strlen>
f0104417:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f010441a:	ff 75 0c             	pushl  0xc(%ebp)
f010441d:	01 d8                	add    %ebx,%eax
f010441f:	50                   	push   %eax
f0104420:	e8 c5 ff ff ff       	call   f01043ea <strcpy>
	return dst;
}
f0104425:	89 d8                	mov    %ebx,%eax
f0104427:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010442a:	c9                   	leave  
f010442b:	c3                   	ret    

f010442c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f010442c:	55                   	push   %ebp
f010442d:	89 e5                	mov    %esp,%ebp
f010442f:	56                   	push   %esi
f0104430:	53                   	push   %ebx
f0104431:	8b 75 08             	mov    0x8(%ebp),%esi
f0104434:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104437:	89 f3                	mov    %esi,%ebx
f0104439:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010443c:	89 f2                	mov    %esi,%edx
f010443e:	eb 0f                	jmp    f010444f <strncpy+0x23>
		*dst++ = *src;
f0104440:	83 c2 01             	add    $0x1,%edx
f0104443:	0f b6 01             	movzbl (%ecx),%eax
f0104446:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0104449:	80 39 01             	cmpb   $0x1,(%ecx)
f010444c:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010444f:	39 da                	cmp    %ebx,%edx
f0104451:	75 ed                	jne    f0104440 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0104453:	89 f0                	mov    %esi,%eax
f0104455:	5b                   	pop    %ebx
f0104456:	5e                   	pop    %esi
f0104457:	5d                   	pop    %ebp
f0104458:	c3                   	ret    

f0104459 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0104459:	55                   	push   %ebp
f010445a:	89 e5                	mov    %esp,%ebp
f010445c:	56                   	push   %esi
f010445d:	53                   	push   %ebx
f010445e:	8b 75 08             	mov    0x8(%ebp),%esi
f0104461:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104464:	8b 55 10             	mov    0x10(%ebp),%edx
f0104467:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0104469:	85 d2                	test   %edx,%edx
f010446b:	74 21                	je     f010448e <strlcpy+0x35>
f010446d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0104471:	89 f2                	mov    %esi,%edx
f0104473:	eb 09                	jmp    f010447e <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0104475:	83 c2 01             	add    $0x1,%edx
f0104478:	83 c1 01             	add    $0x1,%ecx
f010447b:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f010447e:	39 c2                	cmp    %eax,%edx
f0104480:	74 09                	je     f010448b <strlcpy+0x32>
f0104482:	0f b6 19             	movzbl (%ecx),%ebx
f0104485:	84 db                	test   %bl,%bl
f0104487:	75 ec                	jne    f0104475 <strlcpy+0x1c>
f0104489:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f010448b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f010448e:	29 f0                	sub    %esi,%eax
}
f0104490:	5b                   	pop    %ebx
f0104491:	5e                   	pop    %esi
f0104492:	5d                   	pop    %ebp
f0104493:	c3                   	ret    

f0104494 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0104494:	55                   	push   %ebp
f0104495:	89 e5                	mov    %esp,%ebp
f0104497:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010449a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f010449d:	eb 06                	jmp    f01044a5 <strcmp+0x11>
		p++, q++;
f010449f:	83 c1 01             	add    $0x1,%ecx
f01044a2:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01044a5:	0f b6 01             	movzbl (%ecx),%eax
f01044a8:	84 c0                	test   %al,%al
f01044aa:	74 04                	je     f01044b0 <strcmp+0x1c>
f01044ac:	3a 02                	cmp    (%edx),%al
f01044ae:	74 ef                	je     f010449f <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01044b0:	0f b6 c0             	movzbl %al,%eax
f01044b3:	0f b6 12             	movzbl (%edx),%edx
f01044b6:	29 d0                	sub    %edx,%eax
}
f01044b8:	5d                   	pop    %ebp
f01044b9:	c3                   	ret    

f01044ba <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01044ba:	55                   	push   %ebp
f01044bb:	89 e5                	mov    %esp,%ebp
f01044bd:	53                   	push   %ebx
f01044be:	8b 45 08             	mov    0x8(%ebp),%eax
f01044c1:	8b 55 0c             	mov    0xc(%ebp),%edx
f01044c4:	89 c3                	mov    %eax,%ebx
f01044c6:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01044c9:	eb 06                	jmp    f01044d1 <strncmp+0x17>
		n--, p++, q++;
f01044cb:	83 c0 01             	add    $0x1,%eax
f01044ce:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01044d1:	39 d8                	cmp    %ebx,%eax
f01044d3:	74 15                	je     f01044ea <strncmp+0x30>
f01044d5:	0f b6 08             	movzbl (%eax),%ecx
f01044d8:	84 c9                	test   %cl,%cl
f01044da:	74 04                	je     f01044e0 <strncmp+0x26>
f01044dc:	3a 0a                	cmp    (%edx),%cl
f01044de:	74 eb                	je     f01044cb <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01044e0:	0f b6 00             	movzbl (%eax),%eax
f01044e3:	0f b6 12             	movzbl (%edx),%edx
f01044e6:	29 d0                	sub    %edx,%eax
f01044e8:	eb 05                	jmp    f01044ef <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f01044ea:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01044ef:	5b                   	pop    %ebx
f01044f0:	5d                   	pop    %ebp
f01044f1:	c3                   	ret    

f01044f2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01044f2:	55                   	push   %ebp
f01044f3:	89 e5                	mov    %esp,%ebp
f01044f5:	8b 45 08             	mov    0x8(%ebp),%eax
f01044f8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01044fc:	eb 07                	jmp    f0104505 <strchr+0x13>
		if (*s == c)
f01044fe:	38 ca                	cmp    %cl,%dl
f0104500:	74 0f                	je     f0104511 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0104502:	83 c0 01             	add    $0x1,%eax
f0104505:	0f b6 10             	movzbl (%eax),%edx
f0104508:	84 d2                	test   %dl,%dl
f010450a:	75 f2                	jne    f01044fe <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f010450c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104511:	5d                   	pop    %ebp
f0104512:	c3                   	ret    

f0104513 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0104513:	55                   	push   %ebp
f0104514:	89 e5                	mov    %esp,%ebp
f0104516:	8b 45 08             	mov    0x8(%ebp),%eax
f0104519:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f010451d:	eb 03                	jmp    f0104522 <strfind+0xf>
f010451f:	83 c0 01             	add    $0x1,%eax
f0104522:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0104525:	38 ca                	cmp    %cl,%dl
f0104527:	74 04                	je     f010452d <strfind+0x1a>
f0104529:	84 d2                	test   %dl,%dl
f010452b:	75 f2                	jne    f010451f <strfind+0xc>
			break;
	return (char *) s;
}
f010452d:	5d                   	pop    %ebp
f010452e:	c3                   	ret    

f010452f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f010452f:	55                   	push   %ebp
f0104530:	89 e5                	mov    %esp,%ebp
f0104532:	57                   	push   %edi
f0104533:	56                   	push   %esi
f0104534:	53                   	push   %ebx
f0104535:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104538:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f010453b:	85 c9                	test   %ecx,%ecx
f010453d:	74 36                	je     f0104575 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f010453f:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0104545:	75 28                	jne    f010456f <memset+0x40>
f0104547:	f6 c1 03             	test   $0x3,%cl
f010454a:	75 23                	jne    f010456f <memset+0x40>
		c &= 0xFF;
f010454c:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0104550:	89 d3                	mov    %edx,%ebx
f0104552:	c1 e3 08             	shl    $0x8,%ebx
f0104555:	89 d6                	mov    %edx,%esi
f0104557:	c1 e6 18             	shl    $0x18,%esi
f010455a:	89 d0                	mov    %edx,%eax
f010455c:	c1 e0 10             	shl    $0x10,%eax
f010455f:	09 f0                	or     %esi,%eax
f0104561:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f0104563:	89 d8                	mov    %ebx,%eax
f0104565:	09 d0                	or     %edx,%eax
f0104567:	c1 e9 02             	shr    $0x2,%ecx
f010456a:	fc                   	cld    
f010456b:	f3 ab                	rep stos %eax,%es:(%edi)
f010456d:	eb 06                	jmp    f0104575 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f010456f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104572:	fc                   	cld    
f0104573:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0104575:	89 f8                	mov    %edi,%eax
f0104577:	5b                   	pop    %ebx
f0104578:	5e                   	pop    %esi
f0104579:	5f                   	pop    %edi
f010457a:	5d                   	pop    %ebp
f010457b:	c3                   	ret    

f010457c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f010457c:	55                   	push   %ebp
f010457d:	89 e5                	mov    %esp,%ebp
f010457f:	57                   	push   %edi
f0104580:	56                   	push   %esi
f0104581:	8b 45 08             	mov    0x8(%ebp),%eax
f0104584:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104587:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f010458a:	39 c6                	cmp    %eax,%esi
f010458c:	73 35                	jae    f01045c3 <memmove+0x47>
f010458e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0104591:	39 d0                	cmp    %edx,%eax
f0104593:	73 2e                	jae    f01045c3 <memmove+0x47>
		s += n;
		d += n;
f0104595:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104598:	89 d6                	mov    %edx,%esi
f010459a:	09 fe                	or     %edi,%esi
f010459c:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01045a2:	75 13                	jne    f01045b7 <memmove+0x3b>
f01045a4:	f6 c1 03             	test   $0x3,%cl
f01045a7:	75 0e                	jne    f01045b7 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f01045a9:	83 ef 04             	sub    $0x4,%edi
f01045ac:	8d 72 fc             	lea    -0x4(%edx),%esi
f01045af:	c1 e9 02             	shr    $0x2,%ecx
f01045b2:	fd                   	std    
f01045b3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01045b5:	eb 09                	jmp    f01045c0 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01045b7:	83 ef 01             	sub    $0x1,%edi
f01045ba:	8d 72 ff             	lea    -0x1(%edx),%esi
f01045bd:	fd                   	std    
f01045be:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01045c0:	fc                   	cld    
f01045c1:	eb 1d                	jmp    f01045e0 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01045c3:	89 f2                	mov    %esi,%edx
f01045c5:	09 c2                	or     %eax,%edx
f01045c7:	f6 c2 03             	test   $0x3,%dl
f01045ca:	75 0f                	jne    f01045db <memmove+0x5f>
f01045cc:	f6 c1 03             	test   $0x3,%cl
f01045cf:	75 0a                	jne    f01045db <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f01045d1:	c1 e9 02             	shr    $0x2,%ecx
f01045d4:	89 c7                	mov    %eax,%edi
f01045d6:	fc                   	cld    
f01045d7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01045d9:	eb 05                	jmp    f01045e0 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01045db:	89 c7                	mov    %eax,%edi
f01045dd:	fc                   	cld    
f01045de:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01045e0:	5e                   	pop    %esi
f01045e1:	5f                   	pop    %edi
f01045e2:	5d                   	pop    %ebp
f01045e3:	c3                   	ret    

f01045e4 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01045e4:	55                   	push   %ebp
f01045e5:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f01045e7:	ff 75 10             	pushl  0x10(%ebp)
f01045ea:	ff 75 0c             	pushl  0xc(%ebp)
f01045ed:	ff 75 08             	pushl  0x8(%ebp)
f01045f0:	e8 87 ff ff ff       	call   f010457c <memmove>
}
f01045f5:	c9                   	leave  
f01045f6:	c3                   	ret    

f01045f7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01045f7:	55                   	push   %ebp
f01045f8:	89 e5                	mov    %esp,%ebp
f01045fa:	56                   	push   %esi
f01045fb:	53                   	push   %ebx
f01045fc:	8b 45 08             	mov    0x8(%ebp),%eax
f01045ff:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104602:	89 c6                	mov    %eax,%esi
f0104604:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0104607:	eb 1a                	jmp    f0104623 <memcmp+0x2c>
		if (*s1 != *s2)
f0104609:	0f b6 08             	movzbl (%eax),%ecx
f010460c:	0f b6 1a             	movzbl (%edx),%ebx
f010460f:	38 d9                	cmp    %bl,%cl
f0104611:	74 0a                	je     f010461d <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f0104613:	0f b6 c1             	movzbl %cl,%eax
f0104616:	0f b6 db             	movzbl %bl,%ebx
f0104619:	29 d8                	sub    %ebx,%eax
f010461b:	eb 0f                	jmp    f010462c <memcmp+0x35>
		s1++, s2++;
f010461d:	83 c0 01             	add    $0x1,%eax
f0104620:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0104623:	39 f0                	cmp    %esi,%eax
f0104625:	75 e2                	jne    f0104609 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0104627:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010462c:	5b                   	pop    %ebx
f010462d:	5e                   	pop    %esi
f010462e:	5d                   	pop    %ebp
f010462f:	c3                   	ret    

f0104630 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0104630:	55                   	push   %ebp
f0104631:	89 e5                	mov    %esp,%ebp
f0104633:	53                   	push   %ebx
f0104634:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0104637:	89 c1                	mov    %eax,%ecx
f0104639:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f010463c:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0104640:	eb 0a                	jmp    f010464c <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f0104642:	0f b6 10             	movzbl (%eax),%edx
f0104645:	39 da                	cmp    %ebx,%edx
f0104647:	74 07                	je     f0104650 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0104649:	83 c0 01             	add    $0x1,%eax
f010464c:	39 c8                	cmp    %ecx,%eax
f010464e:	72 f2                	jb     f0104642 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0104650:	5b                   	pop    %ebx
f0104651:	5d                   	pop    %ebp
f0104652:	c3                   	ret    

f0104653 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0104653:	55                   	push   %ebp
f0104654:	89 e5                	mov    %esp,%ebp
f0104656:	57                   	push   %edi
f0104657:	56                   	push   %esi
f0104658:	53                   	push   %ebx
f0104659:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010465c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010465f:	eb 03                	jmp    f0104664 <strtol+0x11>
		s++;
f0104661:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0104664:	0f b6 01             	movzbl (%ecx),%eax
f0104667:	3c 20                	cmp    $0x20,%al
f0104669:	74 f6                	je     f0104661 <strtol+0xe>
f010466b:	3c 09                	cmp    $0x9,%al
f010466d:	74 f2                	je     f0104661 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f010466f:	3c 2b                	cmp    $0x2b,%al
f0104671:	75 0a                	jne    f010467d <strtol+0x2a>
		s++;
f0104673:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0104676:	bf 00 00 00 00       	mov    $0x0,%edi
f010467b:	eb 11                	jmp    f010468e <strtol+0x3b>
f010467d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0104682:	3c 2d                	cmp    $0x2d,%al
f0104684:	75 08                	jne    f010468e <strtol+0x3b>
		s++, neg = 1;
f0104686:	83 c1 01             	add    $0x1,%ecx
f0104689:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010468e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0104694:	75 15                	jne    f01046ab <strtol+0x58>
f0104696:	80 39 30             	cmpb   $0x30,(%ecx)
f0104699:	75 10                	jne    f01046ab <strtol+0x58>
f010469b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f010469f:	75 7c                	jne    f010471d <strtol+0xca>
		s += 2, base = 16;
f01046a1:	83 c1 02             	add    $0x2,%ecx
f01046a4:	bb 10 00 00 00       	mov    $0x10,%ebx
f01046a9:	eb 16                	jmp    f01046c1 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f01046ab:	85 db                	test   %ebx,%ebx
f01046ad:	75 12                	jne    f01046c1 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01046af:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01046b4:	80 39 30             	cmpb   $0x30,(%ecx)
f01046b7:	75 08                	jne    f01046c1 <strtol+0x6e>
		s++, base = 8;
f01046b9:	83 c1 01             	add    $0x1,%ecx
f01046bc:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f01046c1:	b8 00 00 00 00       	mov    $0x0,%eax
f01046c6:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01046c9:	0f b6 11             	movzbl (%ecx),%edx
f01046cc:	8d 72 d0             	lea    -0x30(%edx),%esi
f01046cf:	89 f3                	mov    %esi,%ebx
f01046d1:	80 fb 09             	cmp    $0x9,%bl
f01046d4:	77 08                	ja     f01046de <strtol+0x8b>
			dig = *s - '0';
f01046d6:	0f be d2             	movsbl %dl,%edx
f01046d9:	83 ea 30             	sub    $0x30,%edx
f01046dc:	eb 22                	jmp    f0104700 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f01046de:	8d 72 9f             	lea    -0x61(%edx),%esi
f01046e1:	89 f3                	mov    %esi,%ebx
f01046e3:	80 fb 19             	cmp    $0x19,%bl
f01046e6:	77 08                	ja     f01046f0 <strtol+0x9d>
			dig = *s - 'a' + 10;
f01046e8:	0f be d2             	movsbl %dl,%edx
f01046eb:	83 ea 57             	sub    $0x57,%edx
f01046ee:	eb 10                	jmp    f0104700 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f01046f0:	8d 72 bf             	lea    -0x41(%edx),%esi
f01046f3:	89 f3                	mov    %esi,%ebx
f01046f5:	80 fb 19             	cmp    $0x19,%bl
f01046f8:	77 16                	ja     f0104710 <strtol+0xbd>
			dig = *s - 'A' + 10;
f01046fa:	0f be d2             	movsbl %dl,%edx
f01046fd:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f0104700:	3b 55 10             	cmp    0x10(%ebp),%edx
f0104703:	7d 0b                	jge    f0104710 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f0104705:	83 c1 01             	add    $0x1,%ecx
f0104708:	0f af 45 10          	imul   0x10(%ebp),%eax
f010470c:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f010470e:	eb b9                	jmp    f01046c9 <strtol+0x76>

	if (endptr)
f0104710:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0104714:	74 0d                	je     f0104723 <strtol+0xd0>
		*endptr = (char *) s;
f0104716:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104719:	89 0e                	mov    %ecx,(%esi)
f010471b:	eb 06                	jmp    f0104723 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f010471d:	85 db                	test   %ebx,%ebx
f010471f:	74 98                	je     f01046b9 <strtol+0x66>
f0104721:	eb 9e                	jmp    f01046c1 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f0104723:	89 c2                	mov    %eax,%edx
f0104725:	f7 da                	neg    %edx
f0104727:	85 ff                	test   %edi,%edi
f0104729:	0f 45 c2             	cmovne %edx,%eax
}
f010472c:	5b                   	pop    %ebx
f010472d:	5e                   	pop    %esi
f010472e:	5f                   	pop    %edi
f010472f:	5d                   	pop    %ebp
f0104730:	c3                   	ret    
f0104731:	66 90                	xchg   %ax,%ax
f0104733:	66 90                	xchg   %ax,%ax
f0104735:	66 90                	xchg   %ax,%ax
f0104737:	66 90                	xchg   %ax,%ax
f0104739:	66 90                	xchg   %ax,%ax
f010473b:	66 90                	xchg   %ax,%ax
f010473d:	66 90                	xchg   %ax,%ax
f010473f:	90                   	nop

f0104740 <__udivdi3>:
f0104740:	55                   	push   %ebp
f0104741:	57                   	push   %edi
f0104742:	56                   	push   %esi
f0104743:	53                   	push   %ebx
f0104744:	83 ec 1c             	sub    $0x1c,%esp
f0104747:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f010474b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f010474f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f0104753:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0104757:	85 f6                	test   %esi,%esi
f0104759:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010475d:	89 ca                	mov    %ecx,%edx
f010475f:	89 f8                	mov    %edi,%eax
f0104761:	75 3d                	jne    f01047a0 <__udivdi3+0x60>
f0104763:	39 cf                	cmp    %ecx,%edi
f0104765:	0f 87 c5 00 00 00    	ja     f0104830 <__udivdi3+0xf0>
f010476b:	85 ff                	test   %edi,%edi
f010476d:	89 fd                	mov    %edi,%ebp
f010476f:	75 0b                	jne    f010477c <__udivdi3+0x3c>
f0104771:	b8 01 00 00 00       	mov    $0x1,%eax
f0104776:	31 d2                	xor    %edx,%edx
f0104778:	f7 f7                	div    %edi
f010477a:	89 c5                	mov    %eax,%ebp
f010477c:	89 c8                	mov    %ecx,%eax
f010477e:	31 d2                	xor    %edx,%edx
f0104780:	f7 f5                	div    %ebp
f0104782:	89 c1                	mov    %eax,%ecx
f0104784:	89 d8                	mov    %ebx,%eax
f0104786:	89 cf                	mov    %ecx,%edi
f0104788:	f7 f5                	div    %ebp
f010478a:	89 c3                	mov    %eax,%ebx
f010478c:	89 d8                	mov    %ebx,%eax
f010478e:	89 fa                	mov    %edi,%edx
f0104790:	83 c4 1c             	add    $0x1c,%esp
f0104793:	5b                   	pop    %ebx
f0104794:	5e                   	pop    %esi
f0104795:	5f                   	pop    %edi
f0104796:	5d                   	pop    %ebp
f0104797:	c3                   	ret    
f0104798:	90                   	nop
f0104799:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01047a0:	39 ce                	cmp    %ecx,%esi
f01047a2:	77 74                	ja     f0104818 <__udivdi3+0xd8>
f01047a4:	0f bd fe             	bsr    %esi,%edi
f01047a7:	83 f7 1f             	xor    $0x1f,%edi
f01047aa:	0f 84 98 00 00 00    	je     f0104848 <__udivdi3+0x108>
f01047b0:	bb 20 00 00 00       	mov    $0x20,%ebx
f01047b5:	89 f9                	mov    %edi,%ecx
f01047b7:	89 c5                	mov    %eax,%ebp
f01047b9:	29 fb                	sub    %edi,%ebx
f01047bb:	d3 e6                	shl    %cl,%esi
f01047bd:	89 d9                	mov    %ebx,%ecx
f01047bf:	d3 ed                	shr    %cl,%ebp
f01047c1:	89 f9                	mov    %edi,%ecx
f01047c3:	d3 e0                	shl    %cl,%eax
f01047c5:	09 ee                	or     %ebp,%esi
f01047c7:	89 d9                	mov    %ebx,%ecx
f01047c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01047cd:	89 d5                	mov    %edx,%ebp
f01047cf:	8b 44 24 08          	mov    0x8(%esp),%eax
f01047d3:	d3 ed                	shr    %cl,%ebp
f01047d5:	89 f9                	mov    %edi,%ecx
f01047d7:	d3 e2                	shl    %cl,%edx
f01047d9:	89 d9                	mov    %ebx,%ecx
f01047db:	d3 e8                	shr    %cl,%eax
f01047dd:	09 c2                	or     %eax,%edx
f01047df:	89 d0                	mov    %edx,%eax
f01047e1:	89 ea                	mov    %ebp,%edx
f01047e3:	f7 f6                	div    %esi
f01047e5:	89 d5                	mov    %edx,%ebp
f01047e7:	89 c3                	mov    %eax,%ebx
f01047e9:	f7 64 24 0c          	mull   0xc(%esp)
f01047ed:	39 d5                	cmp    %edx,%ebp
f01047ef:	72 10                	jb     f0104801 <__udivdi3+0xc1>
f01047f1:	8b 74 24 08          	mov    0x8(%esp),%esi
f01047f5:	89 f9                	mov    %edi,%ecx
f01047f7:	d3 e6                	shl    %cl,%esi
f01047f9:	39 c6                	cmp    %eax,%esi
f01047fb:	73 07                	jae    f0104804 <__udivdi3+0xc4>
f01047fd:	39 d5                	cmp    %edx,%ebp
f01047ff:	75 03                	jne    f0104804 <__udivdi3+0xc4>
f0104801:	83 eb 01             	sub    $0x1,%ebx
f0104804:	31 ff                	xor    %edi,%edi
f0104806:	89 d8                	mov    %ebx,%eax
f0104808:	89 fa                	mov    %edi,%edx
f010480a:	83 c4 1c             	add    $0x1c,%esp
f010480d:	5b                   	pop    %ebx
f010480e:	5e                   	pop    %esi
f010480f:	5f                   	pop    %edi
f0104810:	5d                   	pop    %ebp
f0104811:	c3                   	ret    
f0104812:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0104818:	31 ff                	xor    %edi,%edi
f010481a:	31 db                	xor    %ebx,%ebx
f010481c:	89 d8                	mov    %ebx,%eax
f010481e:	89 fa                	mov    %edi,%edx
f0104820:	83 c4 1c             	add    $0x1c,%esp
f0104823:	5b                   	pop    %ebx
f0104824:	5e                   	pop    %esi
f0104825:	5f                   	pop    %edi
f0104826:	5d                   	pop    %ebp
f0104827:	c3                   	ret    
f0104828:	90                   	nop
f0104829:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0104830:	89 d8                	mov    %ebx,%eax
f0104832:	f7 f7                	div    %edi
f0104834:	31 ff                	xor    %edi,%edi
f0104836:	89 c3                	mov    %eax,%ebx
f0104838:	89 d8                	mov    %ebx,%eax
f010483a:	89 fa                	mov    %edi,%edx
f010483c:	83 c4 1c             	add    $0x1c,%esp
f010483f:	5b                   	pop    %ebx
f0104840:	5e                   	pop    %esi
f0104841:	5f                   	pop    %edi
f0104842:	5d                   	pop    %ebp
f0104843:	c3                   	ret    
f0104844:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104848:	39 ce                	cmp    %ecx,%esi
f010484a:	72 0c                	jb     f0104858 <__udivdi3+0x118>
f010484c:	31 db                	xor    %ebx,%ebx
f010484e:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0104852:	0f 87 34 ff ff ff    	ja     f010478c <__udivdi3+0x4c>
f0104858:	bb 01 00 00 00       	mov    $0x1,%ebx
f010485d:	e9 2a ff ff ff       	jmp    f010478c <__udivdi3+0x4c>
f0104862:	66 90                	xchg   %ax,%ax
f0104864:	66 90                	xchg   %ax,%ax
f0104866:	66 90                	xchg   %ax,%ax
f0104868:	66 90                	xchg   %ax,%ax
f010486a:	66 90                	xchg   %ax,%ax
f010486c:	66 90                	xchg   %ax,%ax
f010486e:	66 90                	xchg   %ax,%ax

f0104870 <__umoddi3>:
f0104870:	55                   	push   %ebp
f0104871:	57                   	push   %edi
f0104872:	56                   	push   %esi
f0104873:	53                   	push   %ebx
f0104874:	83 ec 1c             	sub    $0x1c,%esp
f0104877:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010487b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f010487f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0104883:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0104887:	85 d2                	test   %edx,%edx
f0104889:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010488d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0104891:	89 f3                	mov    %esi,%ebx
f0104893:	89 3c 24             	mov    %edi,(%esp)
f0104896:	89 74 24 04          	mov    %esi,0x4(%esp)
f010489a:	75 1c                	jne    f01048b8 <__umoddi3+0x48>
f010489c:	39 f7                	cmp    %esi,%edi
f010489e:	76 50                	jbe    f01048f0 <__umoddi3+0x80>
f01048a0:	89 c8                	mov    %ecx,%eax
f01048a2:	89 f2                	mov    %esi,%edx
f01048a4:	f7 f7                	div    %edi
f01048a6:	89 d0                	mov    %edx,%eax
f01048a8:	31 d2                	xor    %edx,%edx
f01048aa:	83 c4 1c             	add    $0x1c,%esp
f01048ad:	5b                   	pop    %ebx
f01048ae:	5e                   	pop    %esi
f01048af:	5f                   	pop    %edi
f01048b0:	5d                   	pop    %ebp
f01048b1:	c3                   	ret    
f01048b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01048b8:	39 f2                	cmp    %esi,%edx
f01048ba:	89 d0                	mov    %edx,%eax
f01048bc:	77 52                	ja     f0104910 <__umoddi3+0xa0>
f01048be:	0f bd ea             	bsr    %edx,%ebp
f01048c1:	83 f5 1f             	xor    $0x1f,%ebp
f01048c4:	75 5a                	jne    f0104920 <__umoddi3+0xb0>
f01048c6:	3b 54 24 04          	cmp    0x4(%esp),%edx
f01048ca:	0f 82 e0 00 00 00    	jb     f01049b0 <__umoddi3+0x140>
f01048d0:	39 0c 24             	cmp    %ecx,(%esp)
f01048d3:	0f 86 d7 00 00 00    	jbe    f01049b0 <__umoddi3+0x140>
f01048d9:	8b 44 24 08          	mov    0x8(%esp),%eax
f01048dd:	8b 54 24 04          	mov    0x4(%esp),%edx
f01048e1:	83 c4 1c             	add    $0x1c,%esp
f01048e4:	5b                   	pop    %ebx
f01048e5:	5e                   	pop    %esi
f01048e6:	5f                   	pop    %edi
f01048e7:	5d                   	pop    %ebp
f01048e8:	c3                   	ret    
f01048e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01048f0:	85 ff                	test   %edi,%edi
f01048f2:	89 fd                	mov    %edi,%ebp
f01048f4:	75 0b                	jne    f0104901 <__umoddi3+0x91>
f01048f6:	b8 01 00 00 00       	mov    $0x1,%eax
f01048fb:	31 d2                	xor    %edx,%edx
f01048fd:	f7 f7                	div    %edi
f01048ff:	89 c5                	mov    %eax,%ebp
f0104901:	89 f0                	mov    %esi,%eax
f0104903:	31 d2                	xor    %edx,%edx
f0104905:	f7 f5                	div    %ebp
f0104907:	89 c8                	mov    %ecx,%eax
f0104909:	f7 f5                	div    %ebp
f010490b:	89 d0                	mov    %edx,%eax
f010490d:	eb 99                	jmp    f01048a8 <__umoddi3+0x38>
f010490f:	90                   	nop
f0104910:	89 c8                	mov    %ecx,%eax
f0104912:	89 f2                	mov    %esi,%edx
f0104914:	83 c4 1c             	add    $0x1c,%esp
f0104917:	5b                   	pop    %ebx
f0104918:	5e                   	pop    %esi
f0104919:	5f                   	pop    %edi
f010491a:	5d                   	pop    %ebp
f010491b:	c3                   	ret    
f010491c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104920:	8b 34 24             	mov    (%esp),%esi
f0104923:	bf 20 00 00 00       	mov    $0x20,%edi
f0104928:	89 e9                	mov    %ebp,%ecx
f010492a:	29 ef                	sub    %ebp,%edi
f010492c:	d3 e0                	shl    %cl,%eax
f010492e:	89 f9                	mov    %edi,%ecx
f0104930:	89 f2                	mov    %esi,%edx
f0104932:	d3 ea                	shr    %cl,%edx
f0104934:	89 e9                	mov    %ebp,%ecx
f0104936:	09 c2                	or     %eax,%edx
f0104938:	89 d8                	mov    %ebx,%eax
f010493a:	89 14 24             	mov    %edx,(%esp)
f010493d:	89 f2                	mov    %esi,%edx
f010493f:	d3 e2                	shl    %cl,%edx
f0104941:	89 f9                	mov    %edi,%ecx
f0104943:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104947:	8b 54 24 0c          	mov    0xc(%esp),%edx
f010494b:	d3 e8                	shr    %cl,%eax
f010494d:	89 e9                	mov    %ebp,%ecx
f010494f:	89 c6                	mov    %eax,%esi
f0104951:	d3 e3                	shl    %cl,%ebx
f0104953:	89 f9                	mov    %edi,%ecx
f0104955:	89 d0                	mov    %edx,%eax
f0104957:	d3 e8                	shr    %cl,%eax
f0104959:	89 e9                	mov    %ebp,%ecx
f010495b:	09 d8                	or     %ebx,%eax
f010495d:	89 d3                	mov    %edx,%ebx
f010495f:	89 f2                	mov    %esi,%edx
f0104961:	f7 34 24             	divl   (%esp)
f0104964:	89 d6                	mov    %edx,%esi
f0104966:	d3 e3                	shl    %cl,%ebx
f0104968:	f7 64 24 04          	mull   0x4(%esp)
f010496c:	39 d6                	cmp    %edx,%esi
f010496e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0104972:	89 d1                	mov    %edx,%ecx
f0104974:	89 c3                	mov    %eax,%ebx
f0104976:	72 08                	jb     f0104980 <__umoddi3+0x110>
f0104978:	75 11                	jne    f010498b <__umoddi3+0x11b>
f010497a:	39 44 24 08          	cmp    %eax,0x8(%esp)
f010497e:	73 0b                	jae    f010498b <__umoddi3+0x11b>
f0104980:	2b 44 24 04          	sub    0x4(%esp),%eax
f0104984:	1b 14 24             	sbb    (%esp),%edx
f0104987:	89 d1                	mov    %edx,%ecx
f0104989:	89 c3                	mov    %eax,%ebx
f010498b:	8b 54 24 08          	mov    0x8(%esp),%edx
f010498f:	29 da                	sub    %ebx,%edx
f0104991:	19 ce                	sbb    %ecx,%esi
f0104993:	89 f9                	mov    %edi,%ecx
f0104995:	89 f0                	mov    %esi,%eax
f0104997:	d3 e0                	shl    %cl,%eax
f0104999:	89 e9                	mov    %ebp,%ecx
f010499b:	d3 ea                	shr    %cl,%edx
f010499d:	89 e9                	mov    %ebp,%ecx
f010499f:	d3 ee                	shr    %cl,%esi
f01049a1:	09 d0                	or     %edx,%eax
f01049a3:	89 f2                	mov    %esi,%edx
f01049a5:	83 c4 1c             	add    $0x1c,%esp
f01049a8:	5b                   	pop    %ebx
f01049a9:	5e                   	pop    %esi
f01049aa:	5f                   	pop    %edi
f01049ab:	5d                   	pop    %ebp
f01049ac:	c3                   	ret    
f01049ad:	8d 76 00             	lea    0x0(%esi),%esi
f01049b0:	29 f9                	sub    %edi,%ecx
f01049b2:	19 d6                	sbb    %edx,%esi
f01049b4:	89 74 24 04          	mov    %esi,0x4(%esp)
f01049b8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01049bc:	e9 18 ff ff ff       	jmp    f01048d9 <__umoddi3+0x69>
