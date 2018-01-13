
obj/kern/kernel:     file format elf32-i386


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
f0100015:	b8 00 40 11 00       	mov    $0x114000,%eax
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
f0100034:	bc 00 40 11 f0       	mov    $0xf0114000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 02 00 00 00       	call   f0100040 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <i386_init>:
#include <kern/kclock.h>


void
i386_init(void)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	83 ec 0c             	sub    $0xc,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100046:	b8 70 69 11 f0       	mov    $0xf0116970,%eax
f010004b:	2d 00 63 11 f0       	sub    $0xf0116300,%eax
f0100050:	50                   	push   %eax
f0100051:	6a 00                	push   $0x0
f0100053:	68 00 63 11 f0       	push   $0xf0116300
f0100058:	e8 f1 31 00 00       	call   f010324e <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f010005d:	e8 96 04 00 00       	call   f01004f8 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f0100062:	83 c4 08             	add    $0x8,%esp
f0100065:	68 ac 1a 00 00       	push   $0x1aac
f010006a:	68 e0 36 10 f0       	push   $0xf01036e0
f010006f:	e8 ff 26 00 00       	call   f0102773 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100074:	e8 d7 0f 00 00       	call   f0101050 <mem_init>
f0100079:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f010007c:	83 ec 0c             	sub    $0xc,%esp
f010007f:	6a 00                	push   $0x0
f0100081:	e8 1f 07 00 00       	call   f01007a5 <monitor>
f0100086:	83 c4 10             	add    $0x10,%esp
f0100089:	eb f1                	jmp    f010007c <i386_init+0x3c>

f010008b <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f010008b:	55                   	push   %ebp
f010008c:	89 e5                	mov    %esp,%ebp
f010008e:	56                   	push   %esi
f010008f:	53                   	push   %ebx
f0100090:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f0100093:	83 3d 60 69 11 f0 00 	cmpl   $0x0,0xf0116960
f010009a:	75 37                	jne    f01000d3 <_panic+0x48>
		goto dead;
	panicstr = fmt;
f010009c:	89 35 60 69 11 f0    	mov    %esi,0xf0116960

	// Be extra sure that the machine is in as reasonable state
	asm volatile("cli; cld");
f01000a2:	fa                   	cli    
f01000a3:	fc                   	cld    

	va_start(ap, fmt);
f01000a4:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f01000a7:	83 ec 04             	sub    $0x4,%esp
f01000aa:	ff 75 0c             	pushl  0xc(%ebp)
f01000ad:	ff 75 08             	pushl  0x8(%ebp)
f01000b0:	68 fb 36 10 f0       	push   $0xf01036fb
f01000b5:	e8 b9 26 00 00       	call   f0102773 <cprintf>
	vcprintf(fmt, ap);
f01000ba:	83 c4 08             	add    $0x8,%esp
f01000bd:	53                   	push   %ebx
f01000be:	56                   	push   %esi
f01000bf:	e8 89 26 00 00       	call   f010274d <vcprintf>
	cprintf("\n");
f01000c4:	c7 04 24 00 46 10 f0 	movl   $0xf0104600,(%esp)
f01000cb:	e8 a3 26 00 00       	call   f0102773 <cprintf>
	va_end(ap);
f01000d0:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000d3:	83 ec 0c             	sub    $0xc,%esp
f01000d6:	6a 00                	push   $0x0
f01000d8:	e8 c8 06 00 00       	call   f01007a5 <monitor>
f01000dd:	83 c4 10             	add    $0x10,%esp
f01000e0:	eb f1                	jmp    f01000d3 <_panic+0x48>

f01000e2 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f01000e2:	55                   	push   %ebp
f01000e3:	89 e5                	mov    %esp,%ebp
f01000e5:	53                   	push   %ebx
f01000e6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f01000e9:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f01000ec:	ff 75 0c             	pushl  0xc(%ebp)
f01000ef:	ff 75 08             	pushl  0x8(%ebp)
f01000f2:	68 13 37 10 f0       	push   $0xf0103713
f01000f7:	e8 77 26 00 00       	call   f0102773 <cprintf>
	vcprintf(fmt, ap);
f01000fc:	83 c4 08             	add    $0x8,%esp
f01000ff:	53                   	push   %ebx
f0100100:	ff 75 10             	pushl  0x10(%ebp)
f0100103:	e8 45 26 00 00       	call   f010274d <vcprintf>
	cprintf("\n");
f0100108:	c7 04 24 00 46 10 f0 	movl   $0xf0104600,(%esp)
f010010f:	e8 5f 26 00 00       	call   f0102773 <cprintf>
	va_end(ap);
}
f0100114:	83 c4 10             	add    $0x10,%esp
f0100117:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010011a:	c9                   	leave  
f010011b:	c3                   	ret    

f010011c <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f010011c:	55                   	push   %ebp
f010011d:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010011f:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100124:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100125:	a8 01                	test   $0x1,%al
f0100127:	74 0b                	je     f0100134 <serial_proc_data+0x18>
f0100129:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010012e:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010012f:	0f b6 c0             	movzbl %al,%eax
f0100132:	eb 05                	jmp    f0100139 <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f0100134:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100139:	5d                   	pop    %ebp
f010013a:	c3                   	ret    

f010013b <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010013b:	55                   	push   %ebp
f010013c:	89 e5                	mov    %esp,%ebp
f010013e:	53                   	push   %ebx
f010013f:	83 ec 04             	sub    $0x4,%esp
f0100142:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100144:	eb 2b                	jmp    f0100171 <cons_intr+0x36>
		if (c == 0)
f0100146:	85 c0                	test   %eax,%eax
f0100148:	74 27                	je     f0100171 <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f010014a:	8b 0d 24 65 11 f0    	mov    0xf0116524,%ecx
f0100150:	8d 51 01             	lea    0x1(%ecx),%edx
f0100153:	89 15 24 65 11 f0    	mov    %edx,0xf0116524
f0100159:	88 81 20 63 11 f0    	mov    %al,-0xfee9ce0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f010015f:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100165:	75 0a                	jne    f0100171 <cons_intr+0x36>
			cons.wpos = 0;
f0100167:	c7 05 24 65 11 f0 00 	movl   $0x0,0xf0116524
f010016e:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100171:	ff d3                	call   *%ebx
f0100173:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100176:	75 ce                	jne    f0100146 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f0100178:	83 c4 04             	add    $0x4,%esp
f010017b:	5b                   	pop    %ebx
f010017c:	5d                   	pop    %ebp
f010017d:	c3                   	ret    

f010017e <kbd_proc_data>:
f010017e:	ba 64 00 00 00       	mov    $0x64,%edx
f0100183:	ec                   	in     (%dx),%al
	int c;
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
f0100184:	a8 01                	test   $0x1,%al
f0100186:	0f 84 f8 00 00 00    	je     f0100284 <kbd_proc_data+0x106>
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
f010018c:	a8 20                	test   $0x20,%al
f010018e:	0f 85 f6 00 00 00    	jne    f010028a <kbd_proc_data+0x10c>
f0100194:	ba 60 00 00 00       	mov    $0x60,%edx
f0100199:	ec                   	in     (%dx),%al
f010019a:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f010019c:	3c e0                	cmp    $0xe0,%al
f010019e:	75 0d                	jne    f01001ad <kbd_proc_data+0x2f>
		// E0 escape character
		shift |= E0ESC;
f01001a0:	83 0d 00 63 11 f0 40 	orl    $0x40,0xf0116300
		return 0;
f01001a7:	b8 00 00 00 00       	mov    $0x0,%eax
f01001ac:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01001ad:	55                   	push   %ebp
f01001ae:	89 e5                	mov    %esp,%ebp
f01001b0:	53                   	push   %ebx
f01001b1:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f01001b4:	84 c0                	test   %al,%al
f01001b6:	79 36                	jns    f01001ee <kbd_proc_data+0x70>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01001b8:	8b 0d 00 63 11 f0    	mov    0xf0116300,%ecx
f01001be:	89 cb                	mov    %ecx,%ebx
f01001c0:	83 e3 40             	and    $0x40,%ebx
f01001c3:	83 e0 7f             	and    $0x7f,%eax
f01001c6:	85 db                	test   %ebx,%ebx
f01001c8:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01001cb:	0f b6 d2             	movzbl %dl,%edx
f01001ce:	0f b6 82 80 38 10 f0 	movzbl -0xfefc780(%edx),%eax
f01001d5:	83 c8 40             	or     $0x40,%eax
f01001d8:	0f b6 c0             	movzbl %al,%eax
f01001db:	f7 d0                	not    %eax
f01001dd:	21 c8                	and    %ecx,%eax
f01001df:	a3 00 63 11 f0       	mov    %eax,0xf0116300
		return 0;
f01001e4:	b8 00 00 00 00       	mov    $0x0,%eax
f01001e9:	e9 a4 00 00 00       	jmp    f0100292 <kbd_proc_data+0x114>
	} else if (shift & E0ESC) {
f01001ee:	8b 0d 00 63 11 f0    	mov    0xf0116300,%ecx
f01001f4:	f6 c1 40             	test   $0x40,%cl
f01001f7:	74 0e                	je     f0100207 <kbd_proc_data+0x89>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f01001f9:	83 c8 80             	or     $0xffffff80,%eax
f01001fc:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f01001fe:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100201:	89 0d 00 63 11 f0    	mov    %ecx,0xf0116300
	}

	shift |= shiftcode[data];
f0100207:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f010020a:	0f b6 82 80 38 10 f0 	movzbl -0xfefc780(%edx),%eax
f0100211:	0b 05 00 63 11 f0    	or     0xf0116300,%eax
f0100217:	0f b6 8a 80 37 10 f0 	movzbl -0xfefc880(%edx),%ecx
f010021e:	31 c8                	xor    %ecx,%eax
f0100220:	a3 00 63 11 f0       	mov    %eax,0xf0116300

	c = charcode[shift & (CTL | SHIFT)][data];
f0100225:	89 c1                	mov    %eax,%ecx
f0100227:	83 e1 03             	and    $0x3,%ecx
f010022a:	8b 0c 8d 60 37 10 f0 	mov    -0xfefc8a0(,%ecx,4),%ecx
f0100231:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100235:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100238:	a8 08                	test   $0x8,%al
f010023a:	74 1b                	je     f0100257 <kbd_proc_data+0xd9>
		if ('a' <= c && c <= 'z')
f010023c:	89 da                	mov    %ebx,%edx
f010023e:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100241:	83 f9 19             	cmp    $0x19,%ecx
f0100244:	77 05                	ja     f010024b <kbd_proc_data+0xcd>
			c += 'A' - 'a';
f0100246:	83 eb 20             	sub    $0x20,%ebx
f0100249:	eb 0c                	jmp    f0100257 <kbd_proc_data+0xd9>
		else if ('A' <= c && c <= 'Z')
f010024b:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f010024e:	8d 4b 20             	lea    0x20(%ebx),%ecx
f0100251:	83 fa 19             	cmp    $0x19,%edx
f0100254:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100257:	f7 d0                	not    %eax
f0100259:	a8 06                	test   $0x6,%al
f010025b:	75 33                	jne    f0100290 <kbd_proc_data+0x112>
f010025d:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100263:	75 2b                	jne    f0100290 <kbd_proc_data+0x112>
		cprintf("Rebooting!\n");
f0100265:	83 ec 0c             	sub    $0xc,%esp
f0100268:	68 2d 37 10 f0       	push   $0xf010372d
f010026d:	e8 01 25 00 00       	call   f0102773 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100272:	ba 92 00 00 00       	mov    $0x92,%edx
f0100277:	b8 03 00 00 00       	mov    $0x3,%eax
f010027c:	ee                   	out    %al,(%dx)
f010027d:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f0100280:	89 d8                	mov    %ebx,%eax
f0100282:	eb 0e                	jmp    f0100292 <kbd_proc_data+0x114>
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
f0100284:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f0100289:	c3                   	ret    
	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
		return -1;
f010028a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010028f:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f0100290:	89 d8                	mov    %ebx,%eax
}
f0100292:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100295:	c9                   	leave  
f0100296:	c3                   	ret    

f0100297 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100297:	55                   	push   %ebp
f0100298:	89 e5                	mov    %esp,%ebp
f010029a:	57                   	push   %edi
f010029b:	56                   	push   %esi
f010029c:	53                   	push   %ebx
f010029d:	83 ec 1c             	sub    $0x1c,%esp
f01002a0:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01002a2:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002a7:	be fd 03 00 00       	mov    $0x3fd,%esi
f01002ac:	b9 84 00 00 00       	mov    $0x84,%ecx
f01002b1:	eb 09                	jmp    f01002bc <cons_putc+0x25>
f01002b3:	89 ca                	mov    %ecx,%edx
f01002b5:	ec                   	in     (%dx),%al
f01002b6:	ec                   	in     (%dx),%al
f01002b7:	ec                   	in     (%dx),%al
f01002b8:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f01002b9:	83 c3 01             	add    $0x1,%ebx
f01002bc:	89 f2                	mov    %esi,%edx
f01002be:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01002bf:	a8 20                	test   $0x20,%al
f01002c1:	75 08                	jne    f01002cb <cons_putc+0x34>
f01002c3:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f01002c9:	7e e8                	jle    f01002b3 <cons_putc+0x1c>
f01002cb:	89 f8                	mov    %edi,%eax
f01002cd:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002d0:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01002d5:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01002d6:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002db:	be 79 03 00 00       	mov    $0x379,%esi
f01002e0:	b9 84 00 00 00       	mov    $0x84,%ecx
f01002e5:	eb 09                	jmp    f01002f0 <cons_putc+0x59>
f01002e7:	89 ca                	mov    %ecx,%edx
f01002e9:	ec                   	in     (%dx),%al
f01002ea:	ec                   	in     (%dx),%al
f01002eb:	ec                   	in     (%dx),%al
f01002ec:	ec                   	in     (%dx),%al
f01002ed:	83 c3 01             	add    $0x1,%ebx
f01002f0:	89 f2                	mov    %esi,%edx
f01002f2:	ec                   	in     (%dx),%al
f01002f3:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f01002f9:	7f 04                	jg     f01002ff <cons_putc+0x68>
f01002fb:	84 c0                	test   %al,%al
f01002fd:	79 e8                	jns    f01002e7 <cons_putc+0x50>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002ff:	ba 78 03 00 00       	mov    $0x378,%edx
f0100304:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100308:	ee                   	out    %al,(%dx)
f0100309:	ba 7a 03 00 00       	mov    $0x37a,%edx
f010030e:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100313:	ee                   	out    %al,(%dx)
f0100314:	b8 08 00 00 00       	mov    $0x8,%eax
f0100319:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f010031a:	89 fa                	mov    %edi,%edx
f010031c:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f0100322:	89 f8                	mov    %edi,%eax
f0100324:	80 cc 07             	or     $0x7,%ah
f0100327:	85 d2                	test   %edx,%edx
f0100329:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f010032c:	89 f8                	mov    %edi,%eax
f010032e:	0f b6 c0             	movzbl %al,%eax
f0100331:	83 f8 09             	cmp    $0x9,%eax
f0100334:	74 74                	je     f01003aa <cons_putc+0x113>
f0100336:	83 f8 09             	cmp    $0x9,%eax
f0100339:	7f 0a                	jg     f0100345 <cons_putc+0xae>
f010033b:	83 f8 08             	cmp    $0x8,%eax
f010033e:	74 14                	je     f0100354 <cons_putc+0xbd>
f0100340:	e9 99 00 00 00       	jmp    f01003de <cons_putc+0x147>
f0100345:	83 f8 0a             	cmp    $0xa,%eax
f0100348:	74 3a                	je     f0100384 <cons_putc+0xed>
f010034a:	83 f8 0d             	cmp    $0xd,%eax
f010034d:	74 3d                	je     f010038c <cons_putc+0xf5>
f010034f:	e9 8a 00 00 00       	jmp    f01003de <cons_putc+0x147>
	case '\b':
		if (crt_pos > 0) {
f0100354:	0f b7 05 28 65 11 f0 	movzwl 0xf0116528,%eax
f010035b:	66 85 c0             	test   %ax,%ax
f010035e:	0f 84 e6 00 00 00    	je     f010044a <cons_putc+0x1b3>
			crt_pos--;
f0100364:	83 e8 01             	sub    $0x1,%eax
f0100367:	66 a3 28 65 11 f0    	mov    %ax,0xf0116528
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010036d:	0f b7 c0             	movzwl %ax,%eax
f0100370:	66 81 e7 00 ff       	and    $0xff00,%di
f0100375:	83 cf 20             	or     $0x20,%edi
f0100378:	8b 15 2c 65 11 f0    	mov    0xf011652c,%edx
f010037e:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100382:	eb 78                	jmp    f01003fc <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100384:	66 83 05 28 65 11 f0 	addw   $0x50,0xf0116528
f010038b:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f010038c:	0f b7 05 28 65 11 f0 	movzwl 0xf0116528,%eax
f0100393:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100399:	c1 e8 16             	shr    $0x16,%eax
f010039c:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010039f:	c1 e0 04             	shl    $0x4,%eax
f01003a2:	66 a3 28 65 11 f0    	mov    %ax,0xf0116528
f01003a8:	eb 52                	jmp    f01003fc <cons_putc+0x165>
		break;
	case '\t':
		cons_putc(' ');
f01003aa:	b8 20 00 00 00       	mov    $0x20,%eax
f01003af:	e8 e3 fe ff ff       	call   f0100297 <cons_putc>
		cons_putc(' ');
f01003b4:	b8 20 00 00 00       	mov    $0x20,%eax
f01003b9:	e8 d9 fe ff ff       	call   f0100297 <cons_putc>
		cons_putc(' ');
f01003be:	b8 20 00 00 00       	mov    $0x20,%eax
f01003c3:	e8 cf fe ff ff       	call   f0100297 <cons_putc>
		cons_putc(' ');
f01003c8:	b8 20 00 00 00       	mov    $0x20,%eax
f01003cd:	e8 c5 fe ff ff       	call   f0100297 <cons_putc>
		cons_putc(' ');
f01003d2:	b8 20 00 00 00       	mov    $0x20,%eax
f01003d7:	e8 bb fe ff ff       	call   f0100297 <cons_putc>
f01003dc:	eb 1e                	jmp    f01003fc <cons_putc+0x165>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f01003de:	0f b7 05 28 65 11 f0 	movzwl 0xf0116528,%eax
f01003e5:	8d 50 01             	lea    0x1(%eax),%edx
f01003e8:	66 89 15 28 65 11 f0 	mov    %dx,0xf0116528
f01003ef:	0f b7 c0             	movzwl %ax,%eax
f01003f2:	8b 15 2c 65 11 f0    	mov    0xf011652c,%edx
f01003f8:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f01003fc:	66 81 3d 28 65 11 f0 	cmpw   $0x7cf,0xf0116528
f0100403:	cf 07 
f0100405:	76 43                	jbe    f010044a <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100407:	a1 2c 65 11 f0       	mov    0xf011652c,%eax
f010040c:	83 ec 04             	sub    $0x4,%esp
f010040f:	68 00 0f 00 00       	push   $0xf00
f0100414:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010041a:	52                   	push   %edx
f010041b:	50                   	push   %eax
f010041c:	e8 7a 2e 00 00       	call   f010329b <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100421:	8b 15 2c 65 11 f0    	mov    0xf011652c,%edx
f0100427:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f010042d:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100433:	83 c4 10             	add    $0x10,%esp
f0100436:	66 c7 00 20 07       	movw   $0x720,(%eax)
f010043b:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010043e:	39 d0                	cmp    %edx,%eax
f0100440:	75 f4                	jne    f0100436 <cons_putc+0x19f>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f0100442:	66 83 2d 28 65 11 f0 	subw   $0x50,0xf0116528
f0100449:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f010044a:	8b 0d 30 65 11 f0    	mov    0xf0116530,%ecx
f0100450:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100455:	89 ca                	mov    %ecx,%edx
f0100457:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100458:	0f b7 1d 28 65 11 f0 	movzwl 0xf0116528,%ebx
f010045f:	8d 71 01             	lea    0x1(%ecx),%esi
f0100462:	89 d8                	mov    %ebx,%eax
f0100464:	66 c1 e8 08          	shr    $0x8,%ax
f0100468:	89 f2                	mov    %esi,%edx
f010046a:	ee                   	out    %al,(%dx)
f010046b:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100470:	89 ca                	mov    %ecx,%edx
f0100472:	ee                   	out    %al,(%dx)
f0100473:	89 d8                	mov    %ebx,%eax
f0100475:	89 f2                	mov    %esi,%edx
f0100477:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100478:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010047b:	5b                   	pop    %ebx
f010047c:	5e                   	pop    %esi
f010047d:	5f                   	pop    %edi
f010047e:	5d                   	pop    %ebp
f010047f:	c3                   	ret    

f0100480 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f0100480:	80 3d 34 65 11 f0 00 	cmpb   $0x0,0xf0116534
f0100487:	74 11                	je     f010049a <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100489:	55                   	push   %ebp
f010048a:	89 e5                	mov    %esp,%ebp
f010048c:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f010048f:	b8 1c 01 10 f0       	mov    $0xf010011c,%eax
f0100494:	e8 a2 fc ff ff       	call   f010013b <cons_intr>
}
f0100499:	c9                   	leave  
f010049a:	f3 c3                	repz ret 

f010049c <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f010049c:	55                   	push   %ebp
f010049d:	89 e5                	mov    %esp,%ebp
f010049f:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01004a2:	b8 7e 01 10 f0       	mov    $0xf010017e,%eax
f01004a7:	e8 8f fc ff ff       	call   f010013b <cons_intr>
}
f01004ac:	c9                   	leave  
f01004ad:	c3                   	ret    

f01004ae <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01004ae:	55                   	push   %ebp
f01004af:	89 e5                	mov    %esp,%ebp
f01004b1:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01004b4:	e8 c7 ff ff ff       	call   f0100480 <serial_intr>
	kbd_intr();
f01004b9:	e8 de ff ff ff       	call   f010049c <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01004be:	a1 20 65 11 f0       	mov    0xf0116520,%eax
f01004c3:	3b 05 24 65 11 f0    	cmp    0xf0116524,%eax
f01004c9:	74 26                	je     f01004f1 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f01004cb:	8d 50 01             	lea    0x1(%eax),%edx
f01004ce:	89 15 20 65 11 f0    	mov    %edx,0xf0116520
f01004d4:	0f b6 88 20 63 11 f0 	movzbl -0xfee9ce0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f01004db:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f01004dd:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01004e3:	75 11                	jne    f01004f6 <cons_getc+0x48>
			cons.rpos = 0;
f01004e5:	c7 05 20 65 11 f0 00 	movl   $0x0,0xf0116520
f01004ec:	00 00 00 
f01004ef:	eb 05                	jmp    f01004f6 <cons_getc+0x48>
		return c;
	}
	return 0;
f01004f1:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01004f6:	c9                   	leave  
f01004f7:	c3                   	ret    

f01004f8 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f01004f8:	55                   	push   %ebp
f01004f9:	89 e5                	mov    %esp,%ebp
f01004fb:	57                   	push   %edi
f01004fc:	56                   	push   %esi
f01004fd:	53                   	push   %ebx
f01004fe:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100501:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100508:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010050f:	5a a5 
	if (*cp != 0xA55A) {
f0100511:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100518:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010051c:	74 11                	je     f010052f <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f010051e:	c7 05 30 65 11 f0 b4 	movl   $0x3b4,0xf0116530
f0100525:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100528:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f010052d:	eb 16                	jmp    f0100545 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f010052f:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100536:	c7 05 30 65 11 f0 d4 	movl   $0x3d4,0xf0116530
f010053d:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100540:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f0100545:	8b 3d 30 65 11 f0    	mov    0xf0116530,%edi
f010054b:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100550:	89 fa                	mov    %edi,%edx
f0100552:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100553:	8d 5f 01             	lea    0x1(%edi),%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100556:	89 da                	mov    %ebx,%edx
f0100558:	ec                   	in     (%dx),%al
f0100559:	0f b6 c8             	movzbl %al,%ecx
f010055c:	c1 e1 08             	shl    $0x8,%ecx
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010055f:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100564:	89 fa                	mov    %edi,%edx
f0100566:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100567:	89 da                	mov    %ebx,%edx
f0100569:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f010056a:	89 35 2c 65 11 f0    	mov    %esi,0xf011652c
	crt_pos = pos;
f0100570:	0f b6 c0             	movzbl %al,%eax
f0100573:	09 c8                	or     %ecx,%eax
f0100575:	66 a3 28 65 11 f0    	mov    %ax,0xf0116528
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010057b:	be fa 03 00 00       	mov    $0x3fa,%esi
f0100580:	b8 00 00 00 00       	mov    $0x0,%eax
f0100585:	89 f2                	mov    %esi,%edx
f0100587:	ee                   	out    %al,(%dx)
f0100588:	ba fb 03 00 00       	mov    $0x3fb,%edx
f010058d:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100592:	ee                   	out    %al,(%dx)
f0100593:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f0100598:	b8 0c 00 00 00       	mov    $0xc,%eax
f010059d:	89 da                	mov    %ebx,%edx
f010059f:	ee                   	out    %al,(%dx)
f01005a0:	ba f9 03 00 00       	mov    $0x3f9,%edx
f01005a5:	b8 00 00 00 00       	mov    $0x0,%eax
f01005aa:	ee                   	out    %al,(%dx)
f01005ab:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01005b0:	b8 03 00 00 00       	mov    $0x3,%eax
f01005b5:	ee                   	out    %al,(%dx)
f01005b6:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01005bb:	b8 00 00 00 00       	mov    $0x0,%eax
f01005c0:	ee                   	out    %al,(%dx)
f01005c1:	ba f9 03 00 00       	mov    $0x3f9,%edx
f01005c6:	b8 01 00 00 00       	mov    $0x1,%eax
f01005cb:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005cc:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01005d1:	ec                   	in     (%dx),%al
f01005d2:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01005d4:	3c ff                	cmp    $0xff,%al
f01005d6:	0f 95 05 34 65 11 f0 	setne  0xf0116534
f01005dd:	89 f2                	mov    %esi,%edx
f01005df:	ec                   	in     (%dx),%al
f01005e0:	89 da                	mov    %ebx,%edx
f01005e2:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01005e3:	80 f9 ff             	cmp    $0xff,%cl
f01005e6:	75 10                	jne    f01005f8 <cons_init+0x100>
		cprintf("Serial port does not exist!\n");
f01005e8:	83 ec 0c             	sub    $0xc,%esp
f01005eb:	68 39 37 10 f0       	push   $0xf0103739
f01005f0:	e8 7e 21 00 00       	call   f0102773 <cprintf>
f01005f5:	83 c4 10             	add    $0x10,%esp
}
f01005f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01005fb:	5b                   	pop    %ebx
f01005fc:	5e                   	pop    %esi
f01005fd:	5f                   	pop    %edi
f01005fe:	5d                   	pop    %ebp
f01005ff:	c3                   	ret    

f0100600 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100600:	55                   	push   %ebp
f0100601:	89 e5                	mov    %esp,%ebp
f0100603:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100606:	8b 45 08             	mov    0x8(%ebp),%eax
f0100609:	e8 89 fc ff ff       	call   f0100297 <cons_putc>
}
f010060e:	c9                   	leave  
f010060f:	c3                   	ret    

f0100610 <getchar>:

int
getchar(void)
{
f0100610:	55                   	push   %ebp
f0100611:	89 e5                	mov    %esp,%ebp
f0100613:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100616:	e8 93 fe ff ff       	call   f01004ae <cons_getc>
f010061b:	85 c0                	test   %eax,%eax
f010061d:	74 f7                	je     f0100616 <getchar+0x6>
		/* do nothing */;
	return c;
}
f010061f:	c9                   	leave  
f0100620:	c3                   	ret    

f0100621 <iscons>:

int
iscons(int fdnum)
{
f0100621:	55                   	push   %ebp
f0100622:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100624:	b8 01 00 00 00       	mov    $0x1,%eax
f0100629:	5d                   	pop    %ebp
f010062a:	c3                   	ret    

f010062b <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f010062b:	55                   	push   %ebp
f010062c:	89 e5                	mov    %esp,%ebp
f010062e:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100631:	68 80 39 10 f0       	push   $0xf0103980
f0100636:	68 9e 39 10 f0       	push   $0xf010399e
f010063b:	68 a3 39 10 f0       	push   $0xf01039a3
f0100640:	e8 2e 21 00 00       	call   f0102773 <cprintf>
f0100645:	83 c4 0c             	add    $0xc,%esp
f0100648:	68 50 3a 10 f0       	push   $0xf0103a50
f010064d:	68 ac 39 10 f0       	push   $0xf01039ac
f0100652:	68 a3 39 10 f0       	push   $0xf01039a3
f0100657:	e8 17 21 00 00       	call   f0102773 <cprintf>
	return 0;
}
f010065c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100661:	c9                   	leave  
f0100662:	c3                   	ret    

f0100663 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100663:	55                   	push   %ebp
f0100664:	89 e5                	mov    %esp,%ebp
f0100666:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100669:	68 b5 39 10 f0       	push   $0xf01039b5
f010066e:	e8 00 21 00 00       	call   f0102773 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100673:	83 c4 08             	add    $0x8,%esp
f0100676:	68 0c 00 10 00       	push   $0x10000c
f010067b:	68 78 3a 10 f0       	push   $0xf0103a78
f0100680:	e8 ee 20 00 00       	call   f0102773 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100685:	83 c4 0c             	add    $0xc,%esp
f0100688:	68 0c 00 10 00       	push   $0x10000c
f010068d:	68 0c 00 10 f0       	push   $0xf010000c
f0100692:	68 a0 3a 10 f0       	push   $0xf0103aa0
f0100697:	e8 d7 20 00 00       	call   f0102773 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010069c:	83 c4 0c             	add    $0xc,%esp
f010069f:	68 d1 36 10 00       	push   $0x1036d1
f01006a4:	68 d1 36 10 f0       	push   $0xf01036d1
f01006a9:	68 c4 3a 10 f0       	push   $0xf0103ac4
f01006ae:	e8 c0 20 00 00       	call   f0102773 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01006b3:	83 c4 0c             	add    $0xc,%esp
f01006b6:	68 00 63 11 00       	push   $0x116300
f01006bb:	68 00 63 11 f0       	push   $0xf0116300
f01006c0:	68 e8 3a 10 f0       	push   $0xf0103ae8
f01006c5:	e8 a9 20 00 00       	call   f0102773 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01006ca:	83 c4 0c             	add    $0xc,%esp
f01006cd:	68 70 69 11 00       	push   $0x116970
f01006d2:	68 70 69 11 f0       	push   $0xf0116970
f01006d7:	68 0c 3b 10 f0       	push   $0xf0103b0c
f01006dc:	e8 92 20 00 00       	call   f0102773 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f01006e1:	b8 6f 6d 11 f0       	mov    $0xf0116d6f,%eax
f01006e6:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f01006eb:	83 c4 08             	add    $0x8,%esp
f01006ee:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f01006f3:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f01006f9:	85 c0                	test   %eax,%eax
f01006fb:	0f 48 c2             	cmovs  %edx,%eax
f01006fe:	c1 f8 0a             	sar    $0xa,%eax
f0100701:	50                   	push   %eax
f0100702:	68 30 3b 10 f0       	push   $0xf0103b30
f0100707:	e8 67 20 00 00       	call   f0102773 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f010070c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100711:	c9                   	leave  
f0100712:	c3                   	ret    

f0100713 <mon_backtrace>:
int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100713:	55                   	push   %ebp
f0100714:	89 e5                	mov    %esp,%ebp
f0100716:	57                   	push   %edi
f0100717:	56                   	push   %esi
f0100718:	53                   	push   %ebx
f0100719:	83 ec 38             	sub    $0x38,%esp

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f010071c:	89 ee                	mov    %ebp,%esi
	// Your code here.
struct Eipdebuginfo info;
uint32_t *ebp = (uint32_t *) read_ebp();
cprintf("Stack backtrace:\n");
f010071e:	68 ce 39 10 f0       	push   $0xf01039ce
f0100723:	e8 4b 20 00 00       	call   f0102773 <cprintf>
while (ebp) {
f0100728:	83 c4 10             	add    $0x10,%esp
f010072b:	eb 67                	jmp    f0100794 <mon_backtrace+0x81>
    cprintf(" ebp %08x eip %08x args", ebp, ebp[1]);
f010072d:	83 ec 04             	sub    $0x4,%esp
f0100730:	ff 76 04             	pushl  0x4(%esi)
f0100733:	56                   	push   %esi
f0100734:	68 e0 39 10 f0       	push   $0xf01039e0
f0100739:	e8 35 20 00 00       	call   f0102773 <cprintf>
f010073e:	8d 5e 08             	lea    0x8(%esi),%ebx
f0100741:	8d 7e 1c             	lea    0x1c(%esi),%edi
f0100744:	83 c4 10             	add    $0x10,%esp
    for (int j = 2; j != 7; ++j) {
        cprintf(" %08x", ebp[j]);   
f0100747:	83 ec 08             	sub    $0x8,%esp
f010074a:	ff 33                	pushl  (%ebx)
f010074c:	68 f8 39 10 f0       	push   $0xf01039f8
f0100751:	e8 1d 20 00 00       	call   f0102773 <cprintf>
f0100756:	83 c3 04             	add    $0x4,%ebx
struct Eipdebuginfo info;
uint32_t *ebp = (uint32_t *) read_ebp();
cprintf("Stack backtrace:\n");
while (ebp) {
    cprintf(" ebp %08x eip %08x args", ebp, ebp[1]);
    for (int j = 2; j != 7; ++j) {
f0100759:	83 c4 10             	add    $0x10,%esp
f010075c:	39 fb                	cmp    %edi,%ebx
f010075e:	75 e7                	jne    f0100747 <mon_backtrace+0x34>
        cprintf(" %08x", ebp[j]);   
    }
    debuginfo_eip(ebp[1], &info);
f0100760:	83 ec 08             	sub    $0x8,%esp
f0100763:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0100766:	50                   	push   %eax
f0100767:	ff 76 04             	pushl  0x4(%esi)
f010076a:	e8 0e 21 00 00       	call   f010287d <debuginfo_eip>
    cprintf("\n     %s:%d: %.*s+%d\n", info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name, ebp[1] - info.eip_fn_addr);
f010076f:	83 c4 08             	add    $0x8,%esp
f0100772:	8b 46 04             	mov    0x4(%esi),%eax
f0100775:	2b 45 e0             	sub    -0x20(%ebp),%eax
f0100778:	50                   	push   %eax
f0100779:	ff 75 d8             	pushl  -0x28(%ebp)
f010077c:	ff 75 dc             	pushl  -0x24(%ebp)
f010077f:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100782:	ff 75 d0             	pushl  -0x30(%ebp)
f0100785:	68 fe 39 10 f0       	push   $0xf01039fe
f010078a:	e8 e4 1f 00 00       	call   f0102773 <cprintf>
    ebp = (uint32_t *) (*ebp);
f010078f:	8b 36                	mov    (%esi),%esi
f0100791:	83 c4 20             	add    $0x20,%esp
{
	// Your code here.
struct Eipdebuginfo info;
uint32_t *ebp = (uint32_t *) read_ebp();
cprintf("Stack backtrace:\n");
while (ebp) {
f0100794:	85 f6                	test   %esi,%esi
f0100796:	75 95                	jne    f010072d <mon_backtrace+0x1a>
    debuginfo_eip(ebp[1], &info);
    cprintf("\n     %s:%d: %.*s+%d\n", info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name, ebp[1] - info.eip_fn_addr);
    ebp = (uint32_t *) (*ebp);
}
	return 0;
}
f0100798:	b8 00 00 00 00       	mov    $0x0,%eax
f010079d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01007a0:	5b                   	pop    %ebx
f01007a1:	5e                   	pop    %esi
f01007a2:	5f                   	pop    %edi
f01007a3:	5d                   	pop    %ebp
f01007a4:	c3                   	ret    

f01007a5 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01007a5:	55                   	push   %ebp
f01007a6:	89 e5                	mov    %esp,%ebp
f01007a8:	57                   	push   %edi
f01007a9:	56                   	push   %esi
f01007aa:	53                   	push   %ebx
f01007ab:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01007ae:	68 5c 3b 10 f0       	push   $0xf0103b5c
f01007b3:	e8 bb 1f 00 00       	call   f0102773 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01007b8:	c7 04 24 80 3b 10 f0 	movl   $0xf0103b80,(%esp)
f01007bf:	e8 af 1f 00 00       	call   f0102773 <cprintf>
f01007c4:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f01007c7:	83 ec 0c             	sub    $0xc,%esp
f01007ca:	68 14 3a 10 f0       	push   $0xf0103a14
f01007cf:	e8 23 28 00 00       	call   f0102ff7 <readline>
f01007d4:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f01007d6:	83 c4 10             	add    $0x10,%esp
f01007d9:	85 c0                	test   %eax,%eax
f01007db:	74 ea                	je     f01007c7 <monitor+0x22>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f01007dd:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f01007e4:	be 00 00 00 00       	mov    $0x0,%esi
f01007e9:	eb 0a                	jmp    f01007f5 <monitor+0x50>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f01007eb:	c6 03 00             	movb   $0x0,(%ebx)
f01007ee:	89 f7                	mov    %esi,%edi
f01007f0:	8d 5b 01             	lea    0x1(%ebx),%ebx
f01007f3:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f01007f5:	0f b6 03             	movzbl (%ebx),%eax
f01007f8:	84 c0                	test   %al,%al
f01007fa:	74 63                	je     f010085f <monitor+0xba>
f01007fc:	83 ec 08             	sub    $0x8,%esp
f01007ff:	0f be c0             	movsbl %al,%eax
f0100802:	50                   	push   %eax
f0100803:	68 18 3a 10 f0       	push   $0xf0103a18
f0100808:	e8 04 2a 00 00       	call   f0103211 <strchr>
f010080d:	83 c4 10             	add    $0x10,%esp
f0100810:	85 c0                	test   %eax,%eax
f0100812:	75 d7                	jne    f01007eb <monitor+0x46>
			*buf++ = 0;
		if (*buf == 0)
f0100814:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100817:	74 46                	je     f010085f <monitor+0xba>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100819:	83 fe 0f             	cmp    $0xf,%esi
f010081c:	75 14                	jne    f0100832 <monitor+0x8d>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f010081e:	83 ec 08             	sub    $0x8,%esp
f0100821:	6a 10                	push   $0x10
f0100823:	68 1d 3a 10 f0       	push   $0xf0103a1d
f0100828:	e8 46 1f 00 00       	call   f0102773 <cprintf>
f010082d:	83 c4 10             	add    $0x10,%esp
f0100830:	eb 95                	jmp    f01007c7 <monitor+0x22>
			return 0;
		}
		argv[argc++] = buf;
f0100832:	8d 7e 01             	lea    0x1(%esi),%edi
f0100835:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100839:	eb 03                	jmp    f010083e <monitor+0x99>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f010083b:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f010083e:	0f b6 03             	movzbl (%ebx),%eax
f0100841:	84 c0                	test   %al,%al
f0100843:	74 ae                	je     f01007f3 <monitor+0x4e>
f0100845:	83 ec 08             	sub    $0x8,%esp
f0100848:	0f be c0             	movsbl %al,%eax
f010084b:	50                   	push   %eax
f010084c:	68 18 3a 10 f0       	push   $0xf0103a18
f0100851:	e8 bb 29 00 00       	call   f0103211 <strchr>
f0100856:	83 c4 10             	add    $0x10,%esp
f0100859:	85 c0                	test   %eax,%eax
f010085b:	74 de                	je     f010083b <monitor+0x96>
f010085d:	eb 94                	jmp    f01007f3 <monitor+0x4e>
			buf++;
	}
	argv[argc] = 0;
f010085f:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100866:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100867:	85 f6                	test   %esi,%esi
f0100869:	0f 84 58 ff ff ff    	je     f01007c7 <monitor+0x22>
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f010086f:	83 ec 08             	sub    $0x8,%esp
f0100872:	68 9e 39 10 f0       	push   $0xf010399e
f0100877:	ff 75 a8             	pushl  -0x58(%ebp)
f010087a:	e8 34 29 00 00       	call   f01031b3 <strcmp>
f010087f:	83 c4 10             	add    $0x10,%esp
f0100882:	85 c0                	test   %eax,%eax
f0100884:	74 1e                	je     f01008a4 <monitor+0xff>
f0100886:	83 ec 08             	sub    $0x8,%esp
f0100889:	68 ac 39 10 f0       	push   $0xf01039ac
f010088e:	ff 75 a8             	pushl  -0x58(%ebp)
f0100891:	e8 1d 29 00 00       	call   f01031b3 <strcmp>
f0100896:	83 c4 10             	add    $0x10,%esp
f0100899:	85 c0                	test   %eax,%eax
f010089b:	75 2f                	jne    f01008cc <monitor+0x127>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f010089d:	b8 01 00 00 00       	mov    $0x1,%eax
f01008a2:	eb 05                	jmp    f01008a9 <monitor+0x104>
		if (strcmp(argv[0], commands[i].name) == 0)
f01008a4:	b8 00 00 00 00       	mov    $0x0,%eax
			return commands[i].func(argc, argv, tf);
f01008a9:	83 ec 04             	sub    $0x4,%esp
f01008ac:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01008af:	01 d0                	add    %edx,%eax
f01008b1:	ff 75 08             	pushl  0x8(%ebp)
f01008b4:	8d 4d a8             	lea    -0x58(%ebp),%ecx
f01008b7:	51                   	push   %ecx
f01008b8:	56                   	push   %esi
f01008b9:	ff 14 85 b0 3b 10 f0 	call   *-0xfefc450(,%eax,4)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f01008c0:	83 c4 10             	add    $0x10,%esp
f01008c3:	85 c0                	test   %eax,%eax
f01008c5:	78 1d                	js     f01008e4 <monitor+0x13f>
f01008c7:	e9 fb fe ff ff       	jmp    f01007c7 <monitor+0x22>
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f01008cc:	83 ec 08             	sub    $0x8,%esp
f01008cf:	ff 75 a8             	pushl  -0x58(%ebp)
f01008d2:	68 3a 3a 10 f0       	push   $0xf0103a3a
f01008d7:	e8 97 1e 00 00       	call   f0102773 <cprintf>
f01008dc:	83 c4 10             	add    $0x10,%esp
f01008df:	e9 e3 fe ff ff       	jmp    f01007c7 <monitor+0x22>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f01008e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01008e7:	5b                   	pop    %ebx
f01008e8:	5e                   	pop    %esi
f01008e9:	5f                   	pop    %edi
f01008ea:	5d                   	pop    %ebp
f01008eb:	c3                   	ret    

f01008ec <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f01008ec:	55                   	push   %ebp
f01008ed:	89 e5                	mov    %esp,%ebp
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f01008ef:	83 3d 38 65 11 f0 00 	cmpl   $0x0,0xf0116538
f01008f6:	75 11                	jne    f0100909 <boot_alloc+0x1d>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f01008f8:	ba 6f 79 11 f0       	mov    $0xf011796f,%edx
f01008fd:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100903:	89 15 38 65 11 f0    	mov    %edx,0xf0116538
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	//char* 一个字节 所以用这个来表示地址
	//roundup实现对齐
	if(n == 0)
f0100909:	85 c0                	test   %eax,%eax
f010090b:	75 07                	jne    f0100914 <boot_alloc+0x28>
		return nextfree;
f010090d:	a1 38 65 11 f0       	mov    0xf0116538,%eax
f0100912:	eb 19                	jmp    f010092d <boot_alloc+0x41>
	result = nextfree;
f0100914:	8b 15 38 65 11 f0    	mov    0xf0116538,%edx
	nextfree += n;
	nextfree = ROUNDUP(nextfree, PGSIZE);
f010091a:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
f0100921:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100926:	a3 38 65 11 f0       	mov    %eax,0xf0116538
	return result;
f010092b:	89 d0                	mov    %edx,%eax
}
f010092d:	5d                   	pop    %ebp
f010092e:	c3                   	ret    

f010092f <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f010092f:	55                   	push   %ebp
f0100930:	89 e5                	mov    %esp,%ebp
f0100932:	56                   	push   %esi
f0100933:	53                   	push   %ebx
f0100934:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100936:	83 ec 0c             	sub    $0xc,%esp
f0100939:	50                   	push   %eax
f010093a:	e8 cd 1d 00 00       	call   f010270c <mc146818_read>
f010093f:	89 c6                	mov    %eax,%esi
f0100941:	83 c3 01             	add    $0x1,%ebx
f0100944:	89 1c 24             	mov    %ebx,(%esp)
f0100947:	e8 c0 1d 00 00       	call   f010270c <mc146818_read>
f010094c:	c1 e0 08             	shl    $0x8,%eax
f010094f:	09 f0                	or     %esi,%eax
}
f0100951:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100954:	5b                   	pop    %ebx
f0100955:	5e                   	pop    %esi
f0100956:	5d                   	pop    %ebp
f0100957:	c3                   	ret    

f0100958 <check_va2pa>:
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f0100958:	89 d1                	mov    %edx,%ecx
f010095a:	c1 e9 16             	shr    $0x16,%ecx
f010095d:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100960:	a8 01                	test   $0x1,%al
f0100962:	74 52                	je     f01009b6 <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100964:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100969:	89 c1                	mov    %eax,%ecx
f010096b:	c1 e9 0c             	shr    $0xc,%ecx
f010096e:	3b 0d 64 69 11 f0    	cmp    0xf0116964,%ecx
f0100974:	72 1b                	jb     f0100991 <check_va2pa+0x39>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100976:	55                   	push   %ebp
f0100977:	89 e5                	mov    %esp,%ebp
f0100979:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010097c:	50                   	push   %eax
f010097d:	68 c0 3b 10 f0       	push   $0xf0103bc0
f0100982:	68 f7 02 00 00       	push   $0x2f7
f0100987:	68 38 43 10 f0       	push   $0xf0104338
f010098c:	e8 fa f6 ff ff       	call   f010008b <_panic>

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f0100991:	c1 ea 0c             	shr    $0xc,%edx
f0100994:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f010099a:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f01009a1:	89 c2                	mov    %eax,%edx
f01009a3:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f01009a6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01009ab:	85 d2                	test   %edx,%edx
f01009ad:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f01009b2:	0f 44 c2             	cmove  %edx,%eax
f01009b5:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f01009b6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f01009bb:	c3                   	ret    

f01009bc <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f01009bc:	55                   	push   %ebp
f01009bd:	89 e5                	mov    %esp,%ebp
f01009bf:	57                   	push   %edi
f01009c0:	56                   	push   %esi
f01009c1:	53                   	push   %ebx
f01009c2:	83 ec 2c             	sub    $0x2c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f01009c5:	84 c0                	test   %al,%al
f01009c7:	0f 85 81 02 00 00    	jne    f0100c4e <check_page_free_list+0x292>
f01009cd:	e9 8e 02 00 00       	jmp    f0100c60 <check_page_free_list+0x2a4>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f01009d2:	83 ec 04             	sub    $0x4,%esp
f01009d5:	68 e4 3b 10 f0       	push   $0xf0103be4
f01009da:	68 38 02 00 00       	push   $0x238
f01009df:	68 38 43 10 f0       	push   $0xf0104338
f01009e4:	e8 a2 f6 ff ff       	call   f010008b <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f01009e9:	8d 55 d8             	lea    -0x28(%ebp),%edx
f01009ec:	89 55 e0             	mov    %edx,-0x20(%ebp)
f01009ef:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01009f2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f01009f5:	89 c2                	mov    %eax,%edx
f01009f7:	2b 15 6c 69 11 f0    	sub    0xf011696c,%edx
f01009fd:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100a03:	0f 95 c2             	setne  %dl
f0100a06:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100a09:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100a0d:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100a0f:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100a13:	8b 00                	mov    (%eax),%eax
f0100a15:	85 c0                	test   %eax,%eax
f0100a17:	75 dc                	jne    f01009f5 <check_page_free_list+0x39>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100a19:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a1c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100a22:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100a25:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100a28:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100a2a:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100a2d:	a3 3c 65 11 f0       	mov    %eax,0xf011653c
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100a32:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100a37:	8b 1d 3c 65 11 f0    	mov    0xf011653c,%ebx
f0100a3d:	eb 53                	jmp    f0100a92 <check_page_free_list+0xd6>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100a3f:	89 d8                	mov    %ebx,%eax
f0100a41:	2b 05 6c 69 11 f0    	sub    0xf011696c,%eax
f0100a47:	c1 f8 03             	sar    $0x3,%eax
f0100a4a:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100a4d:	89 c2                	mov    %eax,%edx
f0100a4f:	c1 ea 16             	shr    $0x16,%edx
f0100a52:	39 f2                	cmp    %esi,%edx
f0100a54:	73 3a                	jae    f0100a90 <check_page_free_list+0xd4>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100a56:	89 c2                	mov    %eax,%edx
f0100a58:	c1 ea 0c             	shr    $0xc,%edx
f0100a5b:	3b 15 64 69 11 f0    	cmp    0xf0116964,%edx
f0100a61:	72 12                	jb     f0100a75 <check_page_free_list+0xb9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100a63:	50                   	push   %eax
f0100a64:	68 c0 3b 10 f0       	push   $0xf0103bc0
f0100a69:	6a 52                	push   $0x52
f0100a6b:	68 44 43 10 f0       	push   $0xf0104344
f0100a70:	e8 16 f6 ff ff       	call   f010008b <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100a75:	83 ec 04             	sub    $0x4,%esp
f0100a78:	68 80 00 00 00       	push   $0x80
f0100a7d:	68 97 00 00 00       	push   $0x97
f0100a82:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100a87:	50                   	push   %eax
f0100a88:	e8 c1 27 00 00       	call   f010324e <memset>
f0100a8d:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100a90:	8b 1b                	mov    (%ebx),%ebx
f0100a92:	85 db                	test   %ebx,%ebx
f0100a94:	75 a9                	jne    f0100a3f <check_page_free_list+0x83>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100a96:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a9b:	e8 4c fe ff ff       	call   f01008ec <boot_alloc>
f0100aa0:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100aa3:	8b 15 3c 65 11 f0    	mov    0xf011653c,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100aa9:	8b 0d 6c 69 11 f0    	mov    0xf011696c,%ecx
		assert(pp < pages + npages);
f0100aaf:	a1 64 69 11 f0       	mov    0xf0116964,%eax
f0100ab4:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100ab7:	8d 3c c1             	lea    (%ecx,%eax,8),%edi
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100aba:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100abd:	be 00 00 00 00       	mov    $0x0,%esi
f0100ac2:	89 5d d0             	mov    %ebx,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ac5:	e9 30 01 00 00       	jmp    f0100bfa <check_page_free_list+0x23e>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100aca:	39 ca                	cmp    %ecx,%edx
f0100acc:	73 19                	jae    f0100ae7 <check_page_free_list+0x12b>
f0100ace:	68 52 43 10 f0       	push   $0xf0104352
f0100ad3:	68 5e 43 10 f0       	push   $0xf010435e
f0100ad8:	68 52 02 00 00       	push   $0x252
f0100add:	68 38 43 10 f0       	push   $0xf0104338
f0100ae2:	e8 a4 f5 ff ff       	call   f010008b <_panic>
		assert(pp < pages + npages);
f0100ae7:	39 fa                	cmp    %edi,%edx
f0100ae9:	72 19                	jb     f0100b04 <check_page_free_list+0x148>
f0100aeb:	68 73 43 10 f0       	push   $0xf0104373
f0100af0:	68 5e 43 10 f0       	push   $0xf010435e
f0100af5:	68 53 02 00 00       	push   $0x253
f0100afa:	68 38 43 10 f0       	push   $0xf0104338
f0100aff:	e8 87 f5 ff ff       	call   f010008b <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100b04:	89 d0                	mov    %edx,%eax
f0100b06:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f0100b09:	a8 07                	test   $0x7,%al
f0100b0b:	74 19                	je     f0100b26 <check_page_free_list+0x16a>
f0100b0d:	68 08 3c 10 f0       	push   $0xf0103c08
f0100b12:	68 5e 43 10 f0       	push   $0xf010435e
f0100b17:	68 54 02 00 00       	push   $0x254
f0100b1c:	68 38 43 10 f0       	push   $0xf0104338
f0100b21:	e8 65 f5 ff ff       	call   f010008b <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100b26:	c1 f8 03             	sar    $0x3,%eax
f0100b29:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100b2c:	85 c0                	test   %eax,%eax
f0100b2e:	75 19                	jne    f0100b49 <check_page_free_list+0x18d>
f0100b30:	68 87 43 10 f0       	push   $0xf0104387
f0100b35:	68 5e 43 10 f0       	push   $0xf010435e
f0100b3a:	68 57 02 00 00       	push   $0x257
f0100b3f:	68 38 43 10 f0       	push   $0xf0104338
f0100b44:	e8 42 f5 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100b49:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100b4e:	75 19                	jne    f0100b69 <check_page_free_list+0x1ad>
f0100b50:	68 98 43 10 f0       	push   $0xf0104398
f0100b55:	68 5e 43 10 f0       	push   $0xf010435e
f0100b5a:	68 58 02 00 00       	push   $0x258
f0100b5f:	68 38 43 10 f0       	push   $0xf0104338
f0100b64:	e8 22 f5 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100b69:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100b6e:	75 19                	jne    f0100b89 <check_page_free_list+0x1cd>
f0100b70:	68 3c 3c 10 f0       	push   $0xf0103c3c
f0100b75:	68 5e 43 10 f0       	push   $0xf010435e
f0100b7a:	68 59 02 00 00       	push   $0x259
f0100b7f:	68 38 43 10 f0       	push   $0xf0104338
f0100b84:	e8 02 f5 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100b89:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100b8e:	75 19                	jne    f0100ba9 <check_page_free_list+0x1ed>
f0100b90:	68 b1 43 10 f0       	push   $0xf01043b1
f0100b95:	68 5e 43 10 f0       	push   $0xf010435e
f0100b9a:	68 5a 02 00 00       	push   $0x25a
f0100b9f:	68 38 43 10 f0       	push   $0xf0104338
f0100ba4:	e8 e2 f4 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100ba9:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100bae:	76 3f                	jbe    f0100bef <check_page_free_list+0x233>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100bb0:	89 c3                	mov    %eax,%ebx
f0100bb2:	c1 eb 0c             	shr    $0xc,%ebx
f0100bb5:	39 5d c8             	cmp    %ebx,-0x38(%ebp)
f0100bb8:	77 12                	ja     f0100bcc <check_page_free_list+0x210>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100bba:	50                   	push   %eax
f0100bbb:	68 c0 3b 10 f0       	push   $0xf0103bc0
f0100bc0:	6a 52                	push   $0x52
f0100bc2:	68 44 43 10 f0       	push   $0xf0104344
f0100bc7:	e8 bf f4 ff ff       	call   f010008b <_panic>
f0100bcc:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100bd1:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0100bd4:	76 1e                	jbe    f0100bf4 <check_page_free_list+0x238>
f0100bd6:	68 60 3c 10 f0       	push   $0xf0103c60
f0100bdb:	68 5e 43 10 f0       	push   $0xf010435e
f0100be0:	68 5b 02 00 00       	push   $0x25b
f0100be5:	68 38 43 10 f0       	push   $0xf0104338
f0100bea:	e8 9c f4 ff ff       	call   f010008b <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100bef:	83 c6 01             	add    $0x1,%esi
f0100bf2:	eb 04                	jmp    f0100bf8 <check_page_free_list+0x23c>
		else
			++nfree_extmem;
f0100bf4:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100bf8:	8b 12                	mov    (%edx),%edx
f0100bfa:	85 d2                	test   %edx,%edx
f0100bfc:	0f 85 c8 fe ff ff    	jne    f0100aca <check_page_free_list+0x10e>
f0100c02:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100c05:	85 f6                	test   %esi,%esi
f0100c07:	7f 19                	jg     f0100c22 <check_page_free_list+0x266>
f0100c09:	68 cb 43 10 f0       	push   $0xf01043cb
f0100c0e:	68 5e 43 10 f0       	push   $0xf010435e
f0100c13:	68 63 02 00 00       	push   $0x263
f0100c18:	68 38 43 10 f0       	push   $0xf0104338
f0100c1d:	e8 69 f4 ff ff       	call   f010008b <_panic>
	assert(nfree_extmem > 0);
f0100c22:	85 db                	test   %ebx,%ebx
f0100c24:	7f 19                	jg     f0100c3f <check_page_free_list+0x283>
f0100c26:	68 dd 43 10 f0       	push   $0xf01043dd
f0100c2b:	68 5e 43 10 f0       	push   $0xf010435e
f0100c30:	68 64 02 00 00       	push   $0x264
f0100c35:	68 38 43 10 f0       	push   $0xf0104338
f0100c3a:	e8 4c f4 ff ff       	call   f010008b <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f0100c3f:	83 ec 0c             	sub    $0xc,%esp
f0100c42:	68 a8 3c 10 f0       	push   $0xf0103ca8
f0100c47:	e8 27 1b 00 00       	call   f0102773 <cprintf>
}
f0100c4c:	eb 29                	jmp    f0100c77 <check_page_free_list+0x2bb>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100c4e:	a1 3c 65 11 f0       	mov    0xf011653c,%eax
f0100c53:	85 c0                	test   %eax,%eax
f0100c55:	0f 85 8e fd ff ff    	jne    f01009e9 <check_page_free_list+0x2d>
f0100c5b:	e9 72 fd ff ff       	jmp    f01009d2 <check_page_free_list+0x16>
f0100c60:	83 3d 3c 65 11 f0 00 	cmpl   $0x0,0xf011653c
f0100c67:	0f 84 65 fd ff ff    	je     f01009d2 <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100c6d:	be 00 04 00 00       	mov    $0x400,%esi
f0100c72:	e9 c0 fd ff ff       	jmp    f0100a37 <check_page_free_list+0x7b>

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);

	cprintf("check_page_free_list() succeeded!\n");
}
f0100c77:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100c7a:	5b                   	pop    %ebx
f0100c7b:	5e                   	pop    %esi
f0100c7c:	5f                   	pop    %edi
f0100c7d:	5d                   	pop    %ebp
f0100c7e:	c3                   	ret    

f0100c7f <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100c7f:	55                   	push   %ebp
f0100c80:	89 e5                	mov    %esp,%ebp
f0100c82:	56                   	push   %esi
f0100c83:	53                   	push   %ebx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {  
f0100c84:	be 00 00 00 00       	mov    $0x0,%esi
f0100c89:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100c8e:	e9 c5 00 00 00       	jmp    f0100d58 <page_init+0xd9>
        	if(i == 0)  
f0100c93:	85 db                	test   %ebx,%ebx
f0100c95:	75 16                	jne    f0100cad <page_init+0x2e>
            	{   
			pages[i].pp_ref = 1;  
f0100c97:	a1 6c 69 11 f0       	mov    0xf011696c,%eax
f0100c9c:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
                	pages[i].pp_link = NULL;  
f0100ca2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100ca8:	e9 a5 00 00 00       	jmp    f0100d52 <page_init+0xd3>
            	}  
        	else if(i>=1 && i<npages_basemem)  
f0100cad:	3b 1d 40 65 11 f0    	cmp    0xf0116540,%ebx
f0100cb3:	73 25                	jae    f0100cda <page_init+0x5b>
        	{  
            		pages[i].pp_ref = 0;  
f0100cb5:	89 f0                	mov    %esi,%eax
f0100cb7:	03 05 6c 69 11 f0    	add    0xf011696c,%eax
f0100cbd:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
            		pages[i].pp_link = page_free_list;   
f0100cc3:	8b 15 3c 65 11 f0    	mov    0xf011653c,%edx
f0100cc9:	89 10                	mov    %edx,(%eax)
            		page_free_list = &pages[i];  
f0100ccb:	89 f0                	mov    %esi,%eax
f0100ccd:	03 05 6c 69 11 f0    	add    0xf011696c,%eax
f0100cd3:	a3 3c 65 11 f0       	mov    %eax,0xf011653c
f0100cd8:	eb 78                	jmp    f0100d52 <page_init+0xd3>
        	}  
        	else if(i>=IOPHYSMEM/PGSIZE && i< EXTPHYSMEM/PGSIZE )  
f0100cda:	8d 83 60 ff ff ff    	lea    -0xa0(%ebx),%eax
f0100ce0:	83 f8 5f             	cmp    $0x5f,%eax
f0100ce3:	77 16                	ja     f0100cfb <page_init+0x7c>
        	{  
            		pages[i].pp_ref = 1;  
f0100ce5:	89 f0                	mov    %esi,%eax
f0100ce7:	03 05 6c 69 11 f0    	add    0xf011696c,%eax
f0100ced:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
            		pages[i].pp_link = NULL;  
f0100cf3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100cf9:	eb 57                	jmp    f0100d52 <page_init+0xd3>
        	}  
      
        	else if( i >= EXTPHYSMEM / PGSIZE &&   i < ( (int)(boot_alloc(0)) - KERNBASE)/PGSIZE)  
f0100cfb:	81 fb ff 00 00 00    	cmp    $0xff,%ebx
f0100d01:	76 2c                	jbe    f0100d2f <page_init+0xb0>
f0100d03:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d08:	e8 df fb ff ff       	call   f01008ec <boot_alloc>
f0100d0d:	05 00 00 00 10       	add    $0x10000000,%eax
f0100d12:	c1 e8 0c             	shr    $0xc,%eax
f0100d15:	39 c3                	cmp    %eax,%ebx
f0100d17:	73 16                	jae    f0100d2f <page_init+0xb0>
        	{  
            		pages[i].pp_ref = 1;  
f0100d19:	89 f0                	mov    %esi,%eax
f0100d1b:	03 05 6c 69 11 f0    	add    0xf011696c,%eax
f0100d21:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
            		pages[i].pp_link =NULL;  
f0100d27:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100d2d:	eb 23                	jmp    f0100d52 <page_init+0xd3>
        	}  
        	else  
        	{  
            		pages[i].pp_ref = 0;  
f0100d2f:	89 f0                	mov    %esi,%eax
f0100d31:	03 05 6c 69 11 f0    	add    0xf011696c,%eax
f0100d37:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
            		pages[i].pp_link = page_free_list;  
f0100d3d:	8b 15 3c 65 11 f0    	mov    0xf011653c,%edx
f0100d43:	89 10                	mov    %edx,(%eax)
            		page_free_list = &pages[i];  
f0100d45:	89 f0                	mov    %esi,%eax
f0100d47:	03 05 6c 69 11 f0    	add    0xf011696c,%eax
f0100d4d:	a3 3c 65 11 f0       	mov    %eax,0xf011653c
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {  
f0100d52:	83 c3 01             	add    $0x1,%ebx
f0100d55:	83 c6 08             	add    $0x8,%esi
f0100d58:	3b 1d 64 69 11 f0    	cmp    0xf0116964,%ebx
f0100d5e:	0f 82 2f ff ff ff    	jb     f0100c93 <page_init+0x14>
	/*for (i = 0; i < npages; i++) {
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}*/
}
f0100d64:	5b                   	pop    %ebx
f0100d65:	5e                   	pop    %esi
f0100d66:	5d                   	pop    %ebp
f0100d67:	c3                   	ret    

f0100d68 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100d68:	55                   	push   %ebp
f0100d69:	89 e5                	mov    %esp,%ebp
f0100d6b:	53                   	push   %ebx
f0100d6c:	83 ec 04             	sub    $0x4,%esp
	// Fill this function in
	if(page_free_list == NULL)  
f0100d6f:	8b 1d 3c 65 11 f0    	mov    0xf011653c,%ebx
f0100d75:	85 db                	test   %ebx,%ebx
f0100d77:	74 58                	je     f0100dd1 <page_alloc+0x69>
        	return NULL;  
  
    	struct PageInfo* page = page_free_list;  
    	page_free_list = page->pp_link;  
f0100d79:	8b 03                	mov    (%ebx),%eax
f0100d7b:	a3 3c 65 11 f0       	mov    %eax,0xf011653c
    	page->pp_link = NULL;  
f0100d80:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    	if(alloc_flags & ALLOC_ZERO)  
f0100d86:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100d8a:	74 45                	je     f0100dd1 <page_alloc+0x69>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100d8c:	89 d8                	mov    %ebx,%eax
f0100d8e:	2b 05 6c 69 11 f0    	sub    0xf011696c,%eax
f0100d94:	c1 f8 03             	sar    $0x3,%eax
f0100d97:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100d9a:	89 c2                	mov    %eax,%edx
f0100d9c:	c1 ea 0c             	shr    $0xc,%edx
f0100d9f:	3b 15 64 69 11 f0    	cmp    0xf0116964,%edx
f0100da5:	72 12                	jb     f0100db9 <page_alloc+0x51>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100da7:	50                   	push   %eax
f0100da8:	68 c0 3b 10 f0       	push   $0xf0103bc0
f0100dad:	6a 52                	push   $0x52
f0100daf:	68 44 43 10 f0       	push   $0xf0104344
f0100db4:	e8 d2 f2 ff ff       	call   f010008b <_panic>
        	memset(page2kva(page), 0, PGSIZE);  
f0100db9:	83 ec 04             	sub    $0x4,%esp
f0100dbc:	68 00 10 00 00       	push   $0x1000
f0100dc1:	6a 00                	push   $0x0
f0100dc3:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100dc8:	50                   	push   %eax
f0100dc9:	e8 80 24 00 00       	call   f010324e <memset>
f0100dce:	83 c4 10             	add    $0x10,%esp
    	return page;
}
f0100dd1:	89 d8                	mov    %ebx,%eax
f0100dd3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100dd6:	c9                   	leave  
f0100dd7:	c3                   	ret    

f0100dd8 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100dd8:	55                   	push   %ebp
f0100dd9:	89 e5                	mov    %esp,%ebp
f0100ddb:	83 ec 08             	sub    $0x8,%esp
f0100dde:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	if(pp->pp_link != NULL  || pp->pp_ref != 0)  
f0100de1:	83 38 00             	cmpl   $0x0,(%eax)
f0100de4:	75 07                	jne    f0100ded <page_free+0x15>
f0100de6:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100deb:	74 17                	je     f0100e04 <page_free+0x2c>
        	panic("page_free is not right");  
f0100ded:	83 ec 04             	sub    $0x4,%esp
f0100df0:	68 ee 43 10 f0       	push   $0xf01043ee
f0100df5:	68 5b 01 00 00       	push   $0x15b
f0100dfa:	68 38 43 10 f0       	push   $0xf0104338
f0100dff:	e8 87 f2 ff ff       	call   f010008b <_panic>
    	pp->pp_link = page_free_list;  
f0100e04:	8b 15 3c 65 11 f0    	mov    0xf011653c,%edx
f0100e0a:	89 10                	mov    %edx,(%eax)
    	page_free_list = pp;  
f0100e0c:	a3 3c 65 11 f0       	mov    %eax,0xf011653c
    	return;   
}
f0100e11:	c9                   	leave  
f0100e12:	c3                   	ret    

f0100e13 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0100e13:	55                   	push   %ebp
f0100e14:	89 e5                	mov    %esp,%ebp
f0100e16:	83 ec 08             	sub    $0x8,%esp
f0100e19:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0100e1c:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0100e20:	83 e8 01             	sub    $0x1,%eax
f0100e23:	66 89 42 04          	mov    %ax,0x4(%edx)
f0100e27:	66 85 c0             	test   %ax,%ax
f0100e2a:	75 0c                	jne    f0100e38 <page_decref+0x25>
		page_free(pp);
f0100e2c:	83 ec 0c             	sub    $0xc,%esp
f0100e2f:	52                   	push   %edx
f0100e30:	e8 a3 ff ff ff       	call   f0100dd8 <page_free>
f0100e35:	83 c4 10             	add    $0x10,%esp
}
f0100e38:	c9                   	leave  
f0100e39:	c3                   	ret    

f0100e3a <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0100e3a:	55                   	push   %ebp
f0100e3b:	89 e5                	mov    %esp,%ebp
f0100e3d:	57                   	push   %edi
f0100e3e:	56                   	push   %esi
f0100e3f:	53                   	push   %ebx
f0100e40:	83 ec 0c             	sub    $0xc,%esp
f0100e43:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	pde_t *pde = NULL;  
    	pte_t *pgtable = NULL;  
      
    	struct PageInfo *pp;  
  
    	pde = &pgdir[PDX(va)];  
f0100e46:	89 de                	mov    %ebx,%esi
f0100e48:	c1 ee 16             	shr    $0x16,%esi
f0100e4b:	c1 e6 02             	shl    $0x2,%esi
f0100e4e:	03 75 08             	add    0x8(%ebp),%esi
    	if(*pde & PTE_P)  
f0100e51:	8b 06                	mov    (%esi),%eax
f0100e53:	a8 01                	test   $0x1,%al
f0100e55:	74 2f                	je     f0100e86 <pgdir_walk+0x4c>
    	{  
        	pgtable = (KADDR(PTE_ADDR(*pde)));  
f0100e57:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100e5c:	89 c2                	mov    %eax,%edx
f0100e5e:	c1 ea 0c             	shr    $0xc,%edx
f0100e61:	39 15 64 69 11 f0    	cmp    %edx,0xf0116964
f0100e67:	77 15                	ja     f0100e7e <pgdir_walk+0x44>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e69:	50                   	push   %eax
f0100e6a:	68 c0 3b 10 f0       	push   $0xf0103bc0
f0100e6f:	68 8f 01 00 00       	push   $0x18f
f0100e74:	68 38 43 10 f0       	push   $0xf0104338
f0100e79:	e8 0d f2 ff ff       	call   f010008b <_panic>
	return (void *)(pa + KERNBASE);
f0100e7e:	8d 90 00 00 00 f0    	lea    -0x10000000(%eax),%edx
f0100e84:	eb 77                	jmp    f0100efd <pgdir_walk+0xc3>
    	}  
    	else  
    	{  
        	if(!create ||  !(pp = page_alloc(ALLOC_ZERO)) ||  !(pgtable = (pte_t*)page2kva(pp)))  
f0100e86:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0100e8a:	74 7f                	je     f0100f0b <pgdir_walk+0xd1>
f0100e8c:	83 ec 0c             	sub    $0xc,%esp
f0100e8f:	6a 01                	push   $0x1
f0100e91:	e8 d2 fe ff ff       	call   f0100d68 <page_alloc>
f0100e96:	83 c4 10             	add    $0x10,%esp
f0100e99:	85 c0                	test   %eax,%eax
f0100e9b:	74 75                	je     f0100f12 <pgdir_walk+0xd8>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100e9d:	89 c1                	mov    %eax,%ecx
f0100e9f:	2b 0d 6c 69 11 f0    	sub    0xf011696c,%ecx
f0100ea5:	c1 f9 03             	sar    $0x3,%ecx
f0100ea8:	c1 e1 0c             	shl    $0xc,%ecx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100eab:	89 ca                	mov    %ecx,%edx
f0100ead:	c1 ea 0c             	shr    $0xc,%edx
f0100eb0:	3b 15 64 69 11 f0    	cmp    0xf0116964,%edx
f0100eb6:	72 12                	jb     f0100eca <pgdir_walk+0x90>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100eb8:	51                   	push   %ecx
f0100eb9:	68 c0 3b 10 f0       	push   $0xf0103bc0
f0100ebe:	6a 52                	push   $0x52
f0100ec0:	68 44 43 10 f0       	push   $0xf0104344
f0100ec5:	e8 c1 f1 ff ff       	call   f010008b <_panic>
	return (void *)(pa + KERNBASE);
f0100eca:	8d b9 00 00 00 f0    	lea    -0x10000000(%ecx),%edi
f0100ed0:	89 fa                	mov    %edi,%edx
f0100ed2:	85 ff                	test   %edi,%edi
f0100ed4:	74 43                	je     f0100f19 <pgdir_walk+0xdf>
            		return NULL;    
  
        	pp->pp_ref++;  
f0100ed6:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100edb:	81 ff ff ff ff ef    	cmp    $0xefffffff,%edi
f0100ee1:	77 15                	ja     f0100ef8 <pgdir_walk+0xbe>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100ee3:	57                   	push   %edi
f0100ee4:	68 cc 3c 10 f0       	push   $0xf0103ccc
f0100ee9:	68 97 01 00 00       	push   $0x197
f0100eee:	68 38 43 10 f0       	push   $0xf0104338
f0100ef3:	e8 93 f1 ff ff       	call   f010008b <_panic>
        	*pde = PADDR(pgtable) | PTE_P |PTE_W | PTE_U;  
f0100ef8:	83 c9 07             	or     $0x7,%ecx
f0100efb:	89 0e                	mov    %ecx,(%esi)
    	}
    	return &pgtable[PTX(va)];
f0100efd:	c1 eb 0a             	shr    $0xa,%ebx
f0100f00:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
f0100f06:	8d 04 1a             	lea    (%edx,%ebx,1),%eax
f0100f09:	eb 13                	jmp    f0100f1e <pgdir_walk+0xe4>
        	pgtable = (KADDR(PTE_ADDR(*pde)));  
    	}  
    	else  
    	{  
        	if(!create ||  !(pp = page_alloc(ALLOC_ZERO)) ||  !(pgtable = (pte_t*)page2kva(pp)))  
            		return NULL;    
f0100f0b:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f10:	eb 0c                	jmp    f0100f1e <pgdir_walk+0xe4>
f0100f12:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f17:	eb 05                	jmp    f0100f1e <pgdir_walk+0xe4>
f0100f19:	b8 00 00 00 00       	mov    $0x0,%eax
  
        	pp->pp_ref++;  
        	*pde = PADDR(pgtable) | PTE_P |PTE_W | PTE_U;  
    	}
    	return &pgtable[PTX(va)];
}
f0100f1e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100f21:	5b                   	pop    %ebx
f0100f22:	5e                   	pop    %esi
f0100f23:	5f                   	pop    %edi
f0100f24:	5d                   	pop    %ebp
f0100f25:	c3                   	ret    

f0100f26 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0100f26:	55                   	push   %ebp
f0100f27:	89 e5                	mov    %esp,%ebp
f0100f29:	83 ec 0c             	sub    $0xc,%esp
	// Fill this function in
	//返回虚拟地址对应的页
	pte_t* pte = pgdir_walk(pgdir,va,0);  
f0100f2c:	6a 00                	push   $0x0
f0100f2e:	ff 75 0c             	pushl  0xc(%ebp)
f0100f31:	ff 75 08             	pushl  0x8(%ebp)
f0100f34:	e8 01 ff ff ff       	call   f0100e3a <pgdir_walk>
    	if(!pte)  
f0100f39:	83 c4 10             	add    $0x10,%esp
f0100f3c:	85 c0                	test   %eax,%eax
f0100f3e:	74 31                	je     f0100f71 <page_lookup+0x4b>
    	{  
        	return NULL;  
    	}  
  
    	*pte_store = pte;    
f0100f40:	8b 55 10             	mov    0x10(%ebp),%edx
f0100f43:	89 02                	mov    %eax,(%edx)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100f45:	8b 00                	mov    (%eax),%eax
f0100f47:	c1 e8 0c             	shr    $0xc,%eax
f0100f4a:	3b 05 64 69 11 f0    	cmp    0xf0116964,%eax
f0100f50:	72 14                	jb     f0100f66 <page_lookup+0x40>
		panic("pa2page called with invalid pa");
f0100f52:	83 ec 04             	sub    $0x4,%esp
f0100f55:	68 f0 3c 10 f0       	push   $0xf0103cf0
f0100f5a:	6a 4b                	push   $0x4b
f0100f5c:	68 44 43 10 f0       	push   $0xf0104344
f0100f61:	e8 25 f1 ff ff       	call   f010008b <_panic>
	return &pages[PGNUM(pa)];
f0100f66:	8b 15 6c 69 11 f0    	mov    0xf011696c,%edx
f0100f6c:	8d 04 c2             	lea    (%edx,%eax,8),%eax
    	return pa2page(PTE_ADDR(*pte));
f0100f6f:	eb 05                	jmp    f0100f76 <page_lookup+0x50>
	// Fill this function in
	//返回虚拟地址对应的页
	pte_t* pte = pgdir_walk(pgdir,va,0);  
    	if(!pte)  
    	{  
        	return NULL;  
f0100f71:	b8 00 00 00 00       	mov    $0x0,%eax
    	}  
  
    	*pte_store = pte;    
    	return pa2page(PTE_ADDR(*pte));
}
f0100f76:	c9                   	leave  
f0100f77:	c3                   	ret    

f0100f78 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0100f78:	55                   	push   %ebp
f0100f79:	89 e5                	mov    %esp,%ebp
f0100f7b:	56                   	push   %esi
f0100f7c:	53                   	push   %ebx
f0100f7d:	83 ec 14             	sub    $0x14,%esp
f0100f80:	8b 75 08             	mov    0x8(%ebp),%esi
f0100f83:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	pte_t*  pte = pgdir_walk(pgdir,va,0);  
f0100f86:	6a 00                	push   $0x0
f0100f88:	53                   	push   %ebx
f0100f89:	56                   	push   %esi
f0100f8a:	e8 ab fe ff ff       	call   f0100e3a <pgdir_walk>
f0100f8f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    	pte_t** pte_store = &pte;  
    	struct PageInfo* pp = page_lookup(pgdir,va,pte_store);   
f0100f92:	83 c4 0c             	add    $0xc,%esp
f0100f95:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100f98:	50                   	push   %eax
f0100f99:	53                   	push   %ebx
f0100f9a:	56                   	push   %esi
f0100f9b:	e8 86 ff ff ff       	call   f0100f26 <page_lookup>
    	if(!pp)  
f0100fa0:	83 c4 10             	add    $0x10,%esp
f0100fa3:	85 c0                	test   %eax,%eax
f0100fa5:	74 18                	je     f0100fbf <page_remove+0x47>
    	{  
        	return ;  
    	}  
    	page_decref(pp);  
f0100fa7:	83 ec 0c             	sub    $0xc,%esp
f0100faa:	50                   	push   %eax
f0100fab:	e8 63 fe ff ff       	call   f0100e13 <page_decref>
    	**pte_store = 0; //关键一步  
f0100fb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100fb3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0100fb9:	0f 01 3b             	invlpg (%ebx)
f0100fbc:	83 c4 10             	add    $0x10,%esp
    	tlb_invalidate(pgdir,va);
}
f0100fbf:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100fc2:	5b                   	pop    %ebx
f0100fc3:	5e                   	pop    %esi
f0100fc4:	5d                   	pop    %ebp
f0100fc5:	c3                   	ret    

f0100fc6 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0100fc6:	55                   	push   %ebp
f0100fc7:	89 e5                	mov    %esp,%ebp
f0100fc9:	57                   	push   %edi
f0100fca:	56                   	push   %esi
f0100fcb:	53                   	push   %ebx
f0100fcc:	83 ec 10             	sub    $0x10,%esp
f0100fcf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100fd2:	8b 7d 10             	mov    0x10(%ebp),%edi
	// Fill this function in
	pte_t* pte = pgdir_walk(pgdir, va, 1);  
f0100fd5:	6a 01                	push   $0x1
f0100fd7:	57                   	push   %edi
f0100fd8:	ff 75 08             	pushl  0x8(%ebp)
f0100fdb:	e8 5a fe ff ff       	call   f0100e3a <pgdir_walk>
    	if(pte == NULL)  
f0100fe0:	83 c4 10             	add    $0x10,%esp
f0100fe3:	85 c0                	test   %eax,%eax
f0100fe5:	74 5c                	je     f0101043 <page_insert+0x7d>
f0100fe7:	89 c6                	mov    %eax,%esi
        	return -E_NO_MEM;  
    	if( (pte[0] &  ~0xfff) == page2pa(pp))  
f0100fe9:	8b 10                	mov    (%eax),%edx
f0100feb:	89 d1                	mov    %edx,%ecx
f0100fed:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0100ff3:	89 d8                	mov    %ebx,%eax
f0100ff5:	2b 05 6c 69 11 f0    	sub    0xf011696c,%eax
f0100ffb:	c1 f8 03             	sar    $0x3,%eax
f0100ffe:	c1 e0 0c             	shl    $0xc,%eax
f0101001:	39 c1                	cmp    %eax,%ecx
f0101003:	75 07                	jne    f010100c <page_insert+0x46>
        	pp->pp_ref--;  
f0101005:	66 83 6b 04 01       	subw   $0x1,0x4(%ebx)
f010100a:	eb 13                	jmp    f010101f <page_insert+0x59>
    	else if(*pte != 0)  
f010100c:	85 d2                	test   %edx,%edx
f010100e:	74 0f                	je     f010101f <page_insert+0x59>
        	page_remove(pgdir, va);  
f0101010:	83 ec 08             	sub    $0x8,%esp
f0101013:	57                   	push   %edi
f0101014:	ff 75 08             	pushl  0x8(%ebp)
f0101017:	e8 5c ff ff ff       	call   f0100f78 <page_remove>
f010101c:	83 c4 10             	add    $0x10,%esp
  
    	*pte = (page2pa(pp) & ~0xfff) | perm | PTE_P;  
f010101f:	89 d8                	mov    %ebx,%eax
f0101021:	2b 05 6c 69 11 f0    	sub    0xf011696c,%eax
f0101027:	c1 f8 03             	sar    $0x3,%eax
f010102a:	c1 e0 0c             	shl    $0xc,%eax
f010102d:	8b 55 14             	mov    0x14(%ebp),%edx
f0101030:	83 ca 01             	or     $0x1,%edx
f0101033:	09 d0                	or     %edx,%eax
f0101035:	89 06                	mov    %eax,(%esi)
    	pp->pp_ref++;
f0101037:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
	return 0;
f010103c:	b8 00 00 00 00       	mov    $0x0,%eax
f0101041:	eb 05                	jmp    f0101048 <page_insert+0x82>
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
	// Fill this function in
	pte_t* pte = pgdir_walk(pgdir, va, 1);  
    	if(pte == NULL)  
        	return -E_NO_MEM;  
f0101043:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
        	page_remove(pgdir, va);  
  
    	*pte = (page2pa(pp) & ~0xfff) | perm | PTE_P;  
    	pp->pp_ref++;
	return 0;
}
f0101048:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010104b:	5b                   	pop    %ebx
f010104c:	5e                   	pop    %esi
f010104d:	5f                   	pop    %edi
f010104e:	5d                   	pop    %ebp
f010104f:	c3                   	ret    

f0101050 <mem_init>:
// 创建内核地址空间
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0101050:	55                   	push   %ebp
f0101051:	89 e5                	mov    %esp,%ebp
f0101053:	57                   	push   %edi
f0101054:	56                   	push   %esi
f0101055:	53                   	push   %ebx
f0101056:	83 ec 2c             	sub    $0x2c,%esp
{
	size_t basemem, extmem, ext16mem, totalmem;

	// Use CMOS calls to measure available base & extended memory.使用cmos函数查看可用的内存大小
	// (CMOS calls return results in kilobytes.)	返回kb值
	basemem = nvram_read(NVRAM_BASELO);
f0101059:	b8 15 00 00 00       	mov    $0x15,%eax
f010105e:	e8 cc f8 ff ff       	call   f010092f <nvram_read>
f0101063:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f0101065:	b8 17 00 00 00       	mov    $0x17,%eax
f010106a:	e8 c0 f8 ff ff       	call   f010092f <nvram_read>
f010106f:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f0101071:	b8 34 00 00 00       	mov    $0x34,%eax
f0101076:	e8 b4 f8 ff ff       	call   f010092f <nvram_read>
f010107b:	c1 e0 06             	shl    $0x6,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (ext16mem)
f010107e:	85 c0                	test   %eax,%eax
f0101080:	74 07                	je     f0101089 <mem_init+0x39>
		totalmem = 16 * 1024 + ext16mem;
f0101082:	05 00 40 00 00       	add    $0x4000,%eax
f0101087:	eb 0b                	jmp    f0101094 <mem_init+0x44>
	else if (extmem)
		totalmem = 1 * 1024 + extmem;
f0101089:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f010108f:	85 f6                	test   %esi,%esi
f0101091:	0f 44 c3             	cmove  %ebx,%eax
	else
		totalmem = basemem;

	npages = totalmem / (PGSIZE / 1024);
f0101094:	89 c2                	mov    %eax,%edx
f0101096:	c1 ea 02             	shr    $0x2,%edx
f0101099:	89 15 64 69 11 f0    	mov    %edx,0xf0116964
	npages_basemem = basemem / (PGSIZE / 1024);
f010109f:	89 da                	mov    %ebx,%edx
f01010a1:	c1 ea 02             	shr    $0x2,%edx
f01010a4:	89 15 40 65 11 f0    	mov    %edx,0xf0116540

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01010aa:	89 c2                	mov    %eax,%edx
f01010ac:	29 da                	sub    %ebx,%edx
f01010ae:	52                   	push   %edx
f01010af:	53                   	push   %ebx
f01010b0:	50                   	push   %eax
f01010b1:	68 10 3d 10 f0       	push   $0xf0103d10
f01010b6:	e8 b8 16 00 00       	call   f0102773 <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01010bb:	b8 00 10 00 00       	mov    $0x1000,%eax
f01010c0:	e8 27 f8 ff ff       	call   f01008ec <boot_alloc>
f01010c5:	a3 68 69 11 f0       	mov    %eax,0xf0116968
	memset(kern_pgdir, 0, PGSIZE);
f01010ca:	83 c4 0c             	add    $0xc,%esp
f01010cd:	68 00 10 00 00       	push   $0x1000
f01010d2:	6a 00                	push   $0x0
f01010d4:	50                   	push   %eax
f01010d5:	e8 74 21 00 00       	call   f010324e <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01010da:	a1 68 69 11 f0       	mov    0xf0116968,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01010df:	83 c4 10             	add    $0x10,%esp
f01010e2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01010e7:	77 15                	ja     f01010fe <mem_init+0xae>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01010e9:	50                   	push   %eax
f01010ea:	68 cc 3c 10 f0       	push   $0xf0103ccc
f01010ef:	68 92 00 00 00       	push   $0x92
f01010f4:	68 38 43 10 f0       	push   $0xf0104338
f01010f9:	e8 8d ef ff ff       	call   f010008b <_panic>
f01010fe:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101104:	83 ca 05             	or     $0x5,%edx
f0101107:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
	// 创建一个npages页个数个PageInfo数组 并初始化
	pages = boot_alloc(npages * sizeof (struct PageInfo));
f010110d:	a1 64 69 11 f0       	mov    0xf0116964,%eax
f0101112:	c1 e0 03             	shl    $0x3,%eax
f0101115:	e8 d2 f7 ff ff       	call   f01008ec <boot_alloc>
f010111a:	a3 6c 69 11 f0       	mov    %eax,0xf011696c
	memset(pages, 0, npages*sizeof(struct PageInfo));
f010111f:	83 ec 04             	sub    $0x4,%esp
f0101122:	8b 0d 64 69 11 f0    	mov    0xf0116964,%ecx
f0101128:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f010112f:	52                   	push   %edx
f0101130:	6a 00                	push   $0x0
f0101132:	50                   	push   %eax
f0101133:	e8 16 21 00 00       	call   f010324e <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0101138:	e8 42 fb ff ff       	call   f0100c7f <page_init>

	check_page_free_list(1);
f010113d:	b8 01 00 00 00       	mov    $0x1,%eax
f0101142:	e8 75 f8 ff ff       	call   f01009bc <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0101147:	83 c4 10             	add    $0x10,%esp
f010114a:	83 3d 6c 69 11 f0 00 	cmpl   $0x0,0xf011696c
f0101151:	75 17                	jne    f010116a <mem_init+0x11a>
		panic("'pages' is a null pointer!");
f0101153:	83 ec 04             	sub    $0x4,%esp
f0101156:	68 05 44 10 f0       	push   $0xf0104405
f010115b:	68 77 02 00 00       	push   $0x277
f0101160:	68 38 43 10 f0       	push   $0xf0104338
f0101165:	e8 21 ef ff ff       	call   f010008b <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010116a:	a1 3c 65 11 f0       	mov    0xf011653c,%eax
f010116f:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101174:	eb 05                	jmp    f010117b <mem_init+0x12b>
		++nfree;
f0101176:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101179:	8b 00                	mov    (%eax),%eax
f010117b:	85 c0                	test   %eax,%eax
f010117d:	75 f7                	jne    f0101176 <mem_init+0x126>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010117f:	83 ec 0c             	sub    $0xc,%esp
f0101182:	6a 00                	push   $0x0
f0101184:	e8 df fb ff ff       	call   f0100d68 <page_alloc>
f0101189:	89 c7                	mov    %eax,%edi
f010118b:	83 c4 10             	add    $0x10,%esp
f010118e:	85 c0                	test   %eax,%eax
f0101190:	75 19                	jne    f01011ab <mem_init+0x15b>
f0101192:	68 20 44 10 f0       	push   $0xf0104420
f0101197:	68 5e 43 10 f0       	push   $0xf010435e
f010119c:	68 7f 02 00 00       	push   $0x27f
f01011a1:	68 38 43 10 f0       	push   $0xf0104338
f01011a6:	e8 e0 ee ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f01011ab:	83 ec 0c             	sub    $0xc,%esp
f01011ae:	6a 00                	push   $0x0
f01011b0:	e8 b3 fb ff ff       	call   f0100d68 <page_alloc>
f01011b5:	89 c6                	mov    %eax,%esi
f01011b7:	83 c4 10             	add    $0x10,%esp
f01011ba:	85 c0                	test   %eax,%eax
f01011bc:	75 19                	jne    f01011d7 <mem_init+0x187>
f01011be:	68 36 44 10 f0       	push   $0xf0104436
f01011c3:	68 5e 43 10 f0       	push   $0xf010435e
f01011c8:	68 80 02 00 00       	push   $0x280
f01011cd:	68 38 43 10 f0       	push   $0xf0104338
f01011d2:	e8 b4 ee ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f01011d7:	83 ec 0c             	sub    $0xc,%esp
f01011da:	6a 00                	push   $0x0
f01011dc:	e8 87 fb ff ff       	call   f0100d68 <page_alloc>
f01011e1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01011e4:	83 c4 10             	add    $0x10,%esp
f01011e7:	85 c0                	test   %eax,%eax
f01011e9:	75 19                	jne    f0101204 <mem_init+0x1b4>
f01011eb:	68 4c 44 10 f0       	push   $0xf010444c
f01011f0:	68 5e 43 10 f0       	push   $0xf010435e
f01011f5:	68 81 02 00 00       	push   $0x281
f01011fa:	68 38 43 10 f0       	push   $0xf0104338
f01011ff:	e8 87 ee ff ff       	call   f010008b <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101204:	39 f7                	cmp    %esi,%edi
f0101206:	75 19                	jne    f0101221 <mem_init+0x1d1>
f0101208:	68 62 44 10 f0       	push   $0xf0104462
f010120d:	68 5e 43 10 f0       	push   $0xf010435e
f0101212:	68 84 02 00 00       	push   $0x284
f0101217:	68 38 43 10 f0       	push   $0xf0104338
f010121c:	e8 6a ee ff ff       	call   f010008b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101221:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101224:	39 c6                	cmp    %eax,%esi
f0101226:	74 04                	je     f010122c <mem_init+0x1dc>
f0101228:	39 c7                	cmp    %eax,%edi
f010122a:	75 19                	jne    f0101245 <mem_init+0x1f5>
f010122c:	68 4c 3d 10 f0       	push   $0xf0103d4c
f0101231:	68 5e 43 10 f0       	push   $0xf010435e
f0101236:	68 85 02 00 00       	push   $0x285
f010123b:	68 38 43 10 f0       	push   $0xf0104338
f0101240:	e8 46 ee ff ff       	call   f010008b <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101245:	8b 0d 6c 69 11 f0    	mov    0xf011696c,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f010124b:	8b 15 64 69 11 f0    	mov    0xf0116964,%edx
f0101251:	c1 e2 0c             	shl    $0xc,%edx
f0101254:	89 f8                	mov    %edi,%eax
f0101256:	29 c8                	sub    %ecx,%eax
f0101258:	c1 f8 03             	sar    $0x3,%eax
f010125b:	c1 e0 0c             	shl    $0xc,%eax
f010125e:	39 d0                	cmp    %edx,%eax
f0101260:	72 19                	jb     f010127b <mem_init+0x22b>
f0101262:	68 74 44 10 f0       	push   $0xf0104474
f0101267:	68 5e 43 10 f0       	push   $0xf010435e
f010126c:	68 86 02 00 00       	push   $0x286
f0101271:	68 38 43 10 f0       	push   $0xf0104338
f0101276:	e8 10 ee ff ff       	call   f010008b <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f010127b:	89 f0                	mov    %esi,%eax
f010127d:	29 c8                	sub    %ecx,%eax
f010127f:	c1 f8 03             	sar    $0x3,%eax
f0101282:	c1 e0 0c             	shl    $0xc,%eax
f0101285:	39 c2                	cmp    %eax,%edx
f0101287:	77 19                	ja     f01012a2 <mem_init+0x252>
f0101289:	68 91 44 10 f0       	push   $0xf0104491
f010128e:	68 5e 43 10 f0       	push   $0xf010435e
f0101293:	68 87 02 00 00       	push   $0x287
f0101298:	68 38 43 10 f0       	push   $0xf0104338
f010129d:	e8 e9 ed ff ff       	call   f010008b <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f01012a2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01012a5:	29 c8                	sub    %ecx,%eax
f01012a7:	c1 f8 03             	sar    $0x3,%eax
f01012aa:	c1 e0 0c             	shl    $0xc,%eax
f01012ad:	39 c2                	cmp    %eax,%edx
f01012af:	77 19                	ja     f01012ca <mem_init+0x27a>
f01012b1:	68 ae 44 10 f0       	push   $0xf01044ae
f01012b6:	68 5e 43 10 f0       	push   $0xf010435e
f01012bb:	68 88 02 00 00       	push   $0x288
f01012c0:	68 38 43 10 f0       	push   $0xf0104338
f01012c5:	e8 c1 ed ff ff       	call   f010008b <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01012ca:	a1 3c 65 11 f0       	mov    0xf011653c,%eax
f01012cf:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01012d2:	c7 05 3c 65 11 f0 00 	movl   $0x0,0xf011653c
f01012d9:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01012dc:	83 ec 0c             	sub    $0xc,%esp
f01012df:	6a 00                	push   $0x0
f01012e1:	e8 82 fa ff ff       	call   f0100d68 <page_alloc>
f01012e6:	83 c4 10             	add    $0x10,%esp
f01012e9:	85 c0                	test   %eax,%eax
f01012eb:	74 19                	je     f0101306 <mem_init+0x2b6>
f01012ed:	68 cb 44 10 f0       	push   $0xf01044cb
f01012f2:	68 5e 43 10 f0       	push   $0xf010435e
f01012f7:	68 8f 02 00 00       	push   $0x28f
f01012fc:	68 38 43 10 f0       	push   $0xf0104338
f0101301:	e8 85 ed ff ff       	call   f010008b <_panic>

	// free and re-allocate?
	page_free(pp0);
f0101306:	83 ec 0c             	sub    $0xc,%esp
f0101309:	57                   	push   %edi
f010130a:	e8 c9 fa ff ff       	call   f0100dd8 <page_free>
	page_free(pp1);
f010130f:	89 34 24             	mov    %esi,(%esp)
f0101312:	e8 c1 fa ff ff       	call   f0100dd8 <page_free>
	page_free(pp2);
f0101317:	83 c4 04             	add    $0x4,%esp
f010131a:	ff 75 d4             	pushl  -0x2c(%ebp)
f010131d:	e8 b6 fa ff ff       	call   f0100dd8 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101322:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101329:	e8 3a fa ff ff       	call   f0100d68 <page_alloc>
f010132e:	89 c6                	mov    %eax,%esi
f0101330:	83 c4 10             	add    $0x10,%esp
f0101333:	85 c0                	test   %eax,%eax
f0101335:	75 19                	jne    f0101350 <mem_init+0x300>
f0101337:	68 20 44 10 f0       	push   $0xf0104420
f010133c:	68 5e 43 10 f0       	push   $0xf010435e
f0101341:	68 96 02 00 00       	push   $0x296
f0101346:	68 38 43 10 f0       	push   $0xf0104338
f010134b:	e8 3b ed ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f0101350:	83 ec 0c             	sub    $0xc,%esp
f0101353:	6a 00                	push   $0x0
f0101355:	e8 0e fa ff ff       	call   f0100d68 <page_alloc>
f010135a:	89 c7                	mov    %eax,%edi
f010135c:	83 c4 10             	add    $0x10,%esp
f010135f:	85 c0                	test   %eax,%eax
f0101361:	75 19                	jne    f010137c <mem_init+0x32c>
f0101363:	68 36 44 10 f0       	push   $0xf0104436
f0101368:	68 5e 43 10 f0       	push   $0xf010435e
f010136d:	68 97 02 00 00       	push   $0x297
f0101372:	68 38 43 10 f0       	push   $0xf0104338
f0101377:	e8 0f ed ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f010137c:	83 ec 0c             	sub    $0xc,%esp
f010137f:	6a 00                	push   $0x0
f0101381:	e8 e2 f9 ff ff       	call   f0100d68 <page_alloc>
f0101386:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101389:	83 c4 10             	add    $0x10,%esp
f010138c:	85 c0                	test   %eax,%eax
f010138e:	75 19                	jne    f01013a9 <mem_init+0x359>
f0101390:	68 4c 44 10 f0       	push   $0xf010444c
f0101395:	68 5e 43 10 f0       	push   $0xf010435e
f010139a:	68 98 02 00 00       	push   $0x298
f010139f:	68 38 43 10 f0       	push   $0xf0104338
f01013a4:	e8 e2 ec ff ff       	call   f010008b <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01013a9:	39 fe                	cmp    %edi,%esi
f01013ab:	75 19                	jne    f01013c6 <mem_init+0x376>
f01013ad:	68 62 44 10 f0       	push   $0xf0104462
f01013b2:	68 5e 43 10 f0       	push   $0xf010435e
f01013b7:	68 9a 02 00 00       	push   $0x29a
f01013bc:	68 38 43 10 f0       	push   $0xf0104338
f01013c1:	e8 c5 ec ff ff       	call   f010008b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01013c6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01013c9:	39 c7                	cmp    %eax,%edi
f01013cb:	74 04                	je     f01013d1 <mem_init+0x381>
f01013cd:	39 c6                	cmp    %eax,%esi
f01013cf:	75 19                	jne    f01013ea <mem_init+0x39a>
f01013d1:	68 4c 3d 10 f0       	push   $0xf0103d4c
f01013d6:	68 5e 43 10 f0       	push   $0xf010435e
f01013db:	68 9b 02 00 00       	push   $0x29b
f01013e0:	68 38 43 10 f0       	push   $0xf0104338
f01013e5:	e8 a1 ec ff ff       	call   f010008b <_panic>
	assert(!page_alloc(0));
f01013ea:	83 ec 0c             	sub    $0xc,%esp
f01013ed:	6a 00                	push   $0x0
f01013ef:	e8 74 f9 ff ff       	call   f0100d68 <page_alloc>
f01013f4:	83 c4 10             	add    $0x10,%esp
f01013f7:	85 c0                	test   %eax,%eax
f01013f9:	74 19                	je     f0101414 <mem_init+0x3c4>
f01013fb:	68 cb 44 10 f0       	push   $0xf01044cb
f0101400:	68 5e 43 10 f0       	push   $0xf010435e
f0101405:	68 9c 02 00 00       	push   $0x29c
f010140a:	68 38 43 10 f0       	push   $0xf0104338
f010140f:	e8 77 ec ff ff       	call   f010008b <_panic>
f0101414:	89 f0                	mov    %esi,%eax
f0101416:	2b 05 6c 69 11 f0    	sub    0xf011696c,%eax
f010141c:	c1 f8 03             	sar    $0x3,%eax
f010141f:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101422:	89 c2                	mov    %eax,%edx
f0101424:	c1 ea 0c             	shr    $0xc,%edx
f0101427:	3b 15 64 69 11 f0    	cmp    0xf0116964,%edx
f010142d:	72 12                	jb     f0101441 <mem_init+0x3f1>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010142f:	50                   	push   %eax
f0101430:	68 c0 3b 10 f0       	push   $0xf0103bc0
f0101435:	6a 52                	push   $0x52
f0101437:	68 44 43 10 f0       	push   $0xf0104344
f010143c:	e8 4a ec ff ff       	call   f010008b <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101441:	83 ec 04             	sub    $0x4,%esp
f0101444:	68 00 10 00 00       	push   $0x1000
f0101449:	6a 01                	push   $0x1
f010144b:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101450:	50                   	push   %eax
f0101451:	e8 f8 1d 00 00       	call   f010324e <memset>
	page_free(pp0);
f0101456:	89 34 24             	mov    %esi,(%esp)
f0101459:	e8 7a f9 ff ff       	call   f0100dd8 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f010145e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101465:	e8 fe f8 ff ff       	call   f0100d68 <page_alloc>
f010146a:	83 c4 10             	add    $0x10,%esp
f010146d:	85 c0                	test   %eax,%eax
f010146f:	75 19                	jne    f010148a <mem_init+0x43a>
f0101471:	68 da 44 10 f0       	push   $0xf01044da
f0101476:	68 5e 43 10 f0       	push   $0xf010435e
f010147b:	68 a1 02 00 00       	push   $0x2a1
f0101480:	68 38 43 10 f0       	push   $0xf0104338
f0101485:	e8 01 ec ff ff       	call   f010008b <_panic>
	assert(pp && pp0 == pp);
f010148a:	39 c6                	cmp    %eax,%esi
f010148c:	74 19                	je     f01014a7 <mem_init+0x457>
f010148e:	68 f8 44 10 f0       	push   $0xf01044f8
f0101493:	68 5e 43 10 f0       	push   $0xf010435e
f0101498:	68 a2 02 00 00       	push   $0x2a2
f010149d:	68 38 43 10 f0       	push   $0xf0104338
f01014a2:	e8 e4 eb ff ff       	call   f010008b <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01014a7:	89 f0                	mov    %esi,%eax
f01014a9:	2b 05 6c 69 11 f0    	sub    0xf011696c,%eax
f01014af:	c1 f8 03             	sar    $0x3,%eax
f01014b2:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01014b5:	89 c2                	mov    %eax,%edx
f01014b7:	c1 ea 0c             	shr    $0xc,%edx
f01014ba:	3b 15 64 69 11 f0    	cmp    0xf0116964,%edx
f01014c0:	72 12                	jb     f01014d4 <mem_init+0x484>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01014c2:	50                   	push   %eax
f01014c3:	68 c0 3b 10 f0       	push   $0xf0103bc0
f01014c8:	6a 52                	push   $0x52
f01014ca:	68 44 43 10 f0       	push   $0xf0104344
f01014cf:	e8 b7 eb ff ff       	call   f010008b <_panic>
f01014d4:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f01014da:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f01014e0:	80 38 00             	cmpb   $0x0,(%eax)
f01014e3:	74 19                	je     f01014fe <mem_init+0x4ae>
f01014e5:	68 08 45 10 f0       	push   $0xf0104508
f01014ea:	68 5e 43 10 f0       	push   $0xf010435e
f01014ef:	68 a5 02 00 00       	push   $0x2a5
f01014f4:	68 38 43 10 f0       	push   $0xf0104338
f01014f9:	e8 8d eb ff ff       	call   f010008b <_panic>
f01014fe:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101501:	39 d0                	cmp    %edx,%eax
f0101503:	75 db                	jne    f01014e0 <mem_init+0x490>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101505:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101508:	a3 3c 65 11 f0       	mov    %eax,0xf011653c

	// free the pages we took
	page_free(pp0);
f010150d:	83 ec 0c             	sub    $0xc,%esp
f0101510:	56                   	push   %esi
f0101511:	e8 c2 f8 ff ff       	call   f0100dd8 <page_free>
	page_free(pp1);
f0101516:	89 3c 24             	mov    %edi,(%esp)
f0101519:	e8 ba f8 ff ff       	call   f0100dd8 <page_free>
	page_free(pp2);
f010151e:	83 c4 04             	add    $0x4,%esp
f0101521:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101524:	e8 af f8 ff ff       	call   f0100dd8 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101529:	a1 3c 65 11 f0       	mov    0xf011653c,%eax
f010152e:	83 c4 10             	add    $0x10,%esp
f0101531:	eb 05                	jmp    f0101538 <mem_init+0x4e8>
		--nfree;
f0101533:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101536:	8b 00                	mov    (%eax),%eax
f0101538:	85 c0                	test   %eax,%eax
f010153a:	75 f7                	jne    f0101533 <mem_init+0x4e3>
		--nfree;
	assert(nfree == 0);
f010153c:	85 db                	test   %ebx,%ebx
f010153e:	74 19                	je     f0101559 <mem_init+0x509>
f0101540:	68 12 45 10 f0       	push   $0xf0104512
f0101545:	68 5e 43 10 f0       	push   $0xf010435e
f010154a:	68 b2 02 00 00       	push   $0x2b2
f010154f:	68 38 43 10 f0       	push   $0xf0104338
f0101554:	e8 32 eb ff ff       	call   f010008b <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101559:	83 ec 0c             	sub    $0xc,%esp
f010155c:	68 6c 3d 10 f0       	push   $0xf0103d6c
f0101561:	e8 0d 12 00 00       	call   f0102773 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101566:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010156d:	e8 f6 f7 ff ff       	call   f0100d68 <page_alloc>
f0101572:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101575:	83 c4 10             	add    $0x10,%esp
f0101578:	85 c0                	test   %eax,%eax
f010157a:	75 19                	jne    f0101595 <mem_init+0x545>
f010157c:	68 20 44 10 f0       	push   $0xf0104420
f0101581:	68 5e 43 10 f0       	push   $0xf010435e
f0101586:	68 0b 03 00 00       	push   $0x30b
f010158b:	68 38 43 10 f0       	push   $0xf0104338
f0101590:	e8 f6 ea ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f0101595:	83 ec 0c             	sub    $0xc,%esp
f0101598:	6a 00                	push   $0x0
f010159a:	e8 c9 f7 ff ff       	call   f0100d68 <page_alloc>
f010159f:	89 c3                	mov    %eax,%ebx
f01015a1:	83 c4 10             	add    $0x10,%esp
f01015a4:	85 c0                	test   %eax,%eax
f01015a6:	75 19                	jne    f01015c1 <mem_init+0x571>
f01015a8:	68 36 44 10 f0       	push   $0xf0104436
f01015ad:	68 5e 43 10 f0       	push   $0xf010435e
f01015b2:	68 0c 03 00 00       	push   $0x30c
f01015b7:	68 38 43 10 f0       	push   $0xf0104338
f01015bc:	e8 ca ea ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f01015c1:	83 ec 0c             	sub    $0xc,%esp
f01015c4:	6a 00                	push   $0x0
f01015c6:	e8 9d f7 ff ff       	call   f0100d68 <page_alloc>
f01015cb:	89 c6                	mov    %eax,%esi
f01015cd:	83 c4 10             	add    $0x10,%esp
f01015d0:	85 c0                	test   %eax,%eax
f01015d2:	75 19                	jne    f01015ed <mem_init+0x59d>
f01015d4:	68 4c 44 10 f0       	push   $0xf010444c
f01015d9:	68 5e 43 10 f0       	push   $0xf010435e
f01015de:	68 0d 03 00 00       	push   $0x30d
f01015e3:	68 38 43 10 f0       	push   $0xf0104338
f01015e8:	e8 9e ea ff ff       	call   f010008b <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01015ed:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f01015f0:	75 19                	jne    f010160b <mem_init+0x5bb>
f01015f2:	68 62 44 10 f0       	push   $0xf0104462
f01015f7:	68 5e 43 10 f0       	push   $0xf010435e
f01015fc:	68 10 03 00 00       	push   $0x310
f0101601:	68 38 43 10 f0       	push   $0xf0104338
f0101606:	e8 80 ea ff ff       	call   f010008b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010160b:	39 c3                	cmp    %eax,%ebx
f010160d:	74 05                	je     f0101614 <mem_init+0x5c4>
f010160f:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101612:	75 19                	jne    f010162d <mem_init+0x5dd>
f0101614:	68 4c 3d 10 f0       	push   $0xf0103d4c
f0101619:	68 5e 43 10 f0       	push   $0xf010435e
f010161e:	68 11 03 00 00       	push   $0x311
f0101623:	68 38 43 10 f0       	push   $0xf0104338
f0101628:	e8 5e ea ff ff       	call   f010008b <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f010162d:	a1 3c 65 11 f0       	mov    0xf011653c,%eax
f0101632:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101635:	c7 05 3c 65 11 f0 00 	movl   $0x0,0xf011653c
f010163c:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f010163f:	83 ec 0c             	sub    $0xc,%esp
f0101642:	6a 00                	push   $0x0
f0101644:	e8 1f f7 ff ff       	call   f0100d68 <page_alloc>
f0101649:	83 c4 10             	add    $0x10,%esp
f010164c:	85 c0                	test   %eax,%eax
f010164e:	74 19                	je     f0101669 <mem_init+0x619>
f0101650:	68 cb 44 10 f0       	push   $0xf01044cb
f0101655:	68 5e 43 10 f0       	push   $0xf010435e
f010165a:	68 18 03 00 00       	push   $0x318
f010165f:	68 38 43 10 f0       	push   $0xf0104338
f0101664:	e8 22 ea ff ff       	call   f010008b <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101669:	83 ec 04             	sub    $0x4,%esp
f010166c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010166f:	50                   	push   %eax
f0101670:	6a 00                	push   $0x0
f0101672:	ff 35 68 69 11 f0    	pushl  0xf0116968
f0101678:	e8 a9 f8 ff ff       	call   f0100f26 <page_lookup>
f010167d:	83 c4 10             	add    $0x10,%esp
f0101680:	85 c0                	test   %eax,%eax
f0101682:	74 19                	je     f010169d <mem_init+0x64d>
f0101684:	68 8c 3d 10 f0       	push   $0xf0103d8c
f0101689:	68 5e 43 10 f0       	push   $0xf010435e
f010168e:	68 1b 03 00 00       	push   $0x31b
f0101693:	68 38 43 10 f0       	push   $0xf0104338
f0101698:	e8 ee e9 ff ff       	call   f010008b <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f010169d:	6a 02                	push   $0x2
f010169f:	6a 00                	push   $0x0
f01016a1:	53                   	push   %ebx
f01016a2:	ff 35 68 69 11 f0    	pushl  0xf0116968
f01016a8:	e8 19 f9 ff ff       	call   f0100fc6 <page_insert>
f01016ad:	83 c4 10             	add    $0x10,%esp
f01016b0:	85 c0                	test   %eax,%eax
f01016b2:	78 19                	js     f01016cd <mem_init+0x67d>
f01016b4:	68 c4 3d 10 f0       	push   $0xf0103dc4
f01016b9:	68 5e 43 10 f0       	push   $0xf010435e
f01016be:	68 1e 03 00 00       	push   $0x31e
f01016c3:	68 38 43 10 f0       	push   $0xf0104338
f01016c8:	e8 be e9 ff ff       	call   f010008b <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f01016cd:	83 ec 0c             	sub    $0xc,%esp
f01016d0:	ff 75 d4             	pushl  -0x2c(%ebp)
f01016d3:	e8 00 f7 ff ff       	call   f0100dd8 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01016d8:	6a 02                	push   $0x2
f01016da:	6a 00                	push   $0x0
f01016dc:	53                   	push   %ebx
f01016dd:	ff 35 68 69 11 f0    	pushl  0xf0116968
f01016e3:	e8 de f8 ff ff       	call   f0100fc6 <page_insert>
f01016e8:	83 c4 20             	add    $0x20,%esp
f01016eb:	85 c0                	test   %eax,%eax
f01016ed:	74 19                	je     f0101708 <mem_init+0x6b8>
f01016ef:	68 f4 3d 10 f0       	push   $0xf0103df4
f01016f4:	68 5e 43 10 f0       	push   $0xf010435e
f01016f9:	68 22 03 00 00       	push   $0x322
f01016fe:	68 38 43 10 f0       	push   $0xf0104338
f0101703:	e8 83 e9 ff ff       	call   f010008b <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101708:	8b 3d 68 69 11 f0    	mov    0xf0116968,%edi
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010170e:	a1 6c 69 11 f0       	mov    0xf011696c,%eax
f0101713:	89 c1                	mov    %eax,%ecx
f0101715:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101718:	8b 17                	mov    (%edi),%edx
f010171a:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101720:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101723:	29 c8                	sub    %ecx,%eax
f0101725:	c1 f8 03             	sar    $0x3,%eax
f0101728:	c1 e0 0c             	shl    $0xc,%eax
f010172b:	39 c2                	cmp    %eax,%edx
f010172d:	74 19                	je     f0101748 <mem_init+0x6f8>
f010172f:	68 24 3e 10 f0       	push   $0xf0103e24
f0101734:	68 5e 43 10 f0       	push   $0xf010435e
f0101739:	68 23 03 00 00       	push   $0x323
f010173e:	68 38 43 10 f0       	push   $0xf0104338
f0101743:	e8 43 e9 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101748:	ba 00 00 00 00       	mov    $0x0,%edx
f010174d:	89 f8                	mov    %edi,%eax
f010174f:	e8 04 f2 ff ff       	call   f0100958 <check_va2pa>
f0101754:	89 da                	mov    %ebx,%edx
f0101756:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101759:	c1 fa 03             	sar    $0x3,%edx
f010175c:	c1 e2 0c             	shl    $0xc,%edx
f010175f:	39 d0                	cmp    %edx,%eax
f0101761:	74 19                	je     f010177c <mem_init+0x72c>
f0101763:	68 4c 3e 10 f0       	push   $0xf0103e4c
f0101768:	68 5e 43 10 f0       	push   $0xf010435e
f010176d:	68 24 03 00 00       	push   $0x324
f0101772:	68 38 43 10 f0       	push   $0xf0104338
f0101777:	e8 0f e9 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 1);
f010177c:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101781:	74 19                	je     f010179c <mem_init+0x74c>
f0101783:	68 1d 45 10 f0       	push   $0xf010451d
f0101788:	68 5e 43 10 f0       	push   $0xf010435e
f010178d:	68 25 03 00 00       	push   $0x325
f0101792:	68 38 43 10 f0       	push   $0xf0104338
f0101797:	e8 ef e8 ff ff       	call   f010008b <_panic>
	assert(pp0->pp_ref == 1);
f010179c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010179f:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f01017a4:	74 19                	je     f01017bf <mem_init+0x76f>
f01017a6:	68 2e 45 10 f0       	push   $0xf010452e
f01017ab:	68 5e 43 10 f0       	push   $0xf010435e
f01017b0:	68 26 03 00 00       	push   $0x326
f01017b5:	68 38 43 10 f0       	push   $0xf0104338
f01017ba:	e8 cc e8 ff ff       	call   f010008b <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01017bf:	6a 02                	push   $0x2
f01017c1:	68 00 10 00 00       	push   $0x1000
f01017c6:	56                   	push   %esi
f01017c7:	57                   	push   %edi
f01017c8:	e8 f9 f7 ff ff       	call   f0100fc6 <page_insert>
f01017cd:	83 c4 10             	add    $0x10,%esp
f01017d0:	85 c0                	test   %eax,%eax
f01017d2:	74 19                	je     f01017ed <mem_init+0x79d>
f01017d4:	68 7c 3e 10 f0       	push   $0xf0103e7c
f01017d9:	68 5e 43 10 f0       	push   $0xf010435e
f01017de:	68 29 03 00 00       	push   $0x329
f01017e3:	68 38 43 10 f0       	push   $0xf0104338
f01017e8:	e8 9e e8 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01017ed:	ba 00 10 00 00       	mov    $0x1000,%edx
f01017f2:	a1 68 69 11 f0       	mov    0xf0116968,%eax
f01017f7:	e8 5c f1 ff ff       	call   f0100958 <check_va2pa>
f01017fc:	89 f2                	mov    %esi,%edx
f01017fe:	2b 15 6c 69 11 f0    	sub    0xf011696c,%edx
f0101804:	c1 fa 03             	sar    $0x3,%edx
f0101807:	c1 e2 0c             	shl    $0xc,%edx
f010180a:	39 d0                	cmp    %edx,%eax
f010180c:	74 19                	je     f0101827 <mem_init+0x7d7>
f010180e:	68 b8 3e 10 f0       	push   $0xf0103eb8
f0101813:	68 5e 43 10 f0       	push   $0xf010435e
f0101818:	68 2a 03 00 00       	push   $0x32a
f010181d:	68 38 43 10 f0       	push   $0xf0104338
f0101822:	e8 64 e8 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f0101827:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010182c:	74 19                	je     f0101847 <mem_init+0x7f7>
f010182e:	68 3f 45 10 f0       	push   $0xf010453f
f0101833:	68 5e 43 10 f0       	push   $0xf010435e
f0101838:	68 2b 03 00 00       	push   $0x32b
f010183d:	68 38 43 10 f0       	push   $0xf0104338
f0101842:	e8 44 e8 ff ff       	call   f010008b <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101847:	83 ec 0c             	sub    $0xc,%esp
f010184a:	6a 00                	push   $0x0
f010184c:	e8 17 f5 ff ff       	call   f0100d68 <page_alloc>
f0101851:	83 c4 10             	add    $0x10,%esp
f0101854:	85 c0                	test   %eax,%eax
f0101856:	74 19                	je     f0101871 <mem_init+0x821>
f0101858:	68 cb 44 10 f0       	push   $0xf01044cb
f010185d:	68 5e 43 10 f0       	push   $0xf010435e
f0101862:	68 2e 03 00 00       	push   $0x32e
f0101867:	68 38 43 10 f0       	push   $0xf0104338
f010186c:	e8 1a e8 ff ff       	call   f010008b <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101871:	6a 02                	push   $0x2
f0101873:	68 00 10 00 00       	push   $0x1000
f0101878:	56                   	push   %esi
f0101879:	ff 35 68 69 11 f0    	pushl  0xf0116968
f010187f:	e8 42 f7 ff ff       	call   f0100fc6 <page_insert>
f0101884:	83 c4 10             	add    $0x10,%esp
f0101887:	85 c0                	test   %eax,%eax
f0101889:	74 19                	je     f01018a4 <mem_init+0x854>
f010188b:	68 7c 3e 10 f0       	push   $0xf0103e7c
f0101890:	68 5e 43 10 f0       	push   $0xf010435e
f0101895:	68 31 03 00 00       	push   $0x331
f010189a:	68 38 43 10 f0       	push   $0xf0104338
f010189f:	e8 e7 e7 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01018a4:	ba 00 10 00 00       	mov    $0x1000,%edx
f01018a9:	a1 68 69 11 f0       	mov    0xf0116968,%eax
f01018ae:	e8 a5 f0 ff ff       	call   f0100958 <check_va2pa>
f01018b3:	89 f2                	mov    %esi,%edx
f01018b5:	2b 15 6c 69 11 f0    	sub    0xf011696c,%edx
f01018bb:	c1 fa 03             	sar    $0x3,%edx
f01018be:	c1 e2 0c             	shl    $0xc,%edx
f01018c1:	39 d0                	cmp    %edx,%eax
f01018c3:	74 19                	je     f01018de <mem_init+0x88e>
f01018c5:	68 b8 3e 10 f0       	push   $0xf0103eb8
f01018ca:	68 5e 43 10 f0       	push   $0xf010435e
f01018cf:	68 32 03 00 00       	push   $0x332
f01018d4:	68 38 43 10 f0       	push   $0xf0104338
f01018d9:	e8 ad e7 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f01018de:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01018e3:	74 19                	je     f01018fe <mem_init+0x8ae>
f01018e5:	68 3f 45 10 f0       	push   $0xf010453f
f01018ea:	68 5e 43 10 f0       	push   $0xf010435e
f01018ef:	68 33 03 00 00       	push   $0x333
f01018f4:	68 38 43 10 f0       	push   $0xf0104338
f01018f9:	e8 8d e7 ff ff       	call   f010008b <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f01018fe:	83 ec 0c             	sub    $0xc,%esp
f0101901:	6a 00                	push   $0x0
f0101903:	e8 60 f4 ff ff       	call   f0100d68 <page_alloc>
f0101908:	83 c4 10             	add    $0x10,%esp
f010190b:	85 c0                	test   %eax,%eax
f010190d:	74 19                	je     f0101928 <mem_init+0x8d8>
f010190f:	68 cb 44 10 f0       	push   $0xf01044cb
f0101914:	68 5e 43 10 f0       	push   $0xf010435e
f0101919:	68 37 03 00 00       	push   $0x337
f010191e:	68 38 43 10 f0       	push   $0xf0104338
f0101923:	e8 63 e7 ff ff       	call   f010008b <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101928:	8b 15 68 69 11 f0    	mov    0xf0116968,%edx
f010192e:	8b 02                	mov    (%edx),%eax
f0101930:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101935:	89 c1                	mov    %eax,%ecx
f0101937:	c1 e9 0c             	shr    $0xc,%ecx
f010193a:	3b 0d 64 69 11 f0    	cmp    0xf0116964,%ecx
f0101940:	72 15                	jb     f0101957 <mem_init+0x907>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101942:	50                   	push   %eax
f0101943:	68 c0 3b 10 f0       	push   $0xf0103bc0
f0101948:	68 3a 03 00 00       	push   $0x33a
f010194d:	68 38 43 10 f0       	push   $0xf0104338
f0101952:	e8 34 e7 ff ff       	call   f010008b <_panic>
f0101957:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010195c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f010195f:	83 ec 04             	sub    $0x4,%esp
f0101962:	6a 00                	push   $0x0
f0101964:	68 00 10 00 00       	push   $0x1000
f0101969:	52                   	push   %edx
f010196a:	e8 cb f4 ff ff       	call   f0100e3a <pgdir_walk>
f010196f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101972:	8d 57 04             	lea    0x4(%edi),%edx
f0101975:	83 c4 10             	add    $0x10,%esp
f0101978:	39 d0                	cmp    %edx,%eax
f010197a:	74 19                	je     f0101995 <mem_init+0x945>
f010197c:	68 e8 3e 10 f0       	push   $0xf0103ee8
f0101981:	68 5e 43 10 f0       	push   $0xf010435e
f0101986:	68 3b 03 00 00       	push   $0x33b
f010198b:	68 38 43 10 f0       	push   $0xf0104338
f0101990:	e8 f6 e6 ff ff       	call   f010008b <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101995:	6a 06                	push   $0x6
f0101997:	68 00 10 00 00       	push   $0x1000
f010199c:	56                   	push   %esi
f010199d:	ff 35 68 69 11 f0    	pushl  0xf0116968
f01019a3:	e8 1e f6 ff ff       	call   f0100fc6 <page_insert>
f01019a8:	83 c4 10             	add    $0x10,%esp
f01019ab:	85 c0                	test   %eax,%eax
f01019ad:	74 19                	je     f01019c8 <mem_init+0x978>
f01019af:	68 28 3f 10 f0       	push   $0xf0103f28
f01019b4:	68 5e 43 10 f0       	push   $0xf010435e
f01019b9:	68 3e 03 00 00       	push   $0x33e
f01019be:	68 38 43 10 f0       	push   $0xf0104338
f01019c3:	e8 c3 e6 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01019c8:	8b 3d 68 69 11 f0    	mov    0xf0116968,%edi
f01019ce:	ba 00 10 00 00       	mov    $0x1000,%edx
f01019d3:	89 f8                	mov    %edi,%eax
f01019d5:	e8 7e ef ff ff       	call   f0100958 <check_va2pa>
f01019da:	89 f2                	mov    %esi,%edx
f01019dc:	2b 15 6c 69 11 f0    	sub    0xf011696c,%edx
f01019e2:	c1 fa 03             	sar    $0x3,%edx
f01019e5:	c1 e2 0c             	shl    $0xc,%edx
f01019e8:	39 d0                	cmp    %edx,%eax
f01019ea:	74 19                	je     f0101a05 <mem_init+0x9b5>
f01019ec:	68 b8 3e 10 f0       	push   $0xf0103eb8
f01019f1:	68 5e 43 10 f0       	push   $0xf010435e
f01019f6:	68 3f 03 00 00       	push   $0x33f
f01019fb:	68 38 43 10 f0       	push   $0xf0104338
f0101a00:	e8 86 e6 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f0101a05:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101a0a:	74 19                	je     f0101a25 <mem_init+0x9d5>
f0101a0c:	68 3f 45 10 f0       	push   $0xf010453f
f0101a11:	68 5e 43 10 f0       	push   $0xf010435e
f0101a16:	68 40 03 00 00       	push   $0x340
f0101a1b:	68 38 43 10 f0       	push   $0xf0104338
f0101a20:	e8 66 e6 ff ff       	call   f010008b <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101a25:	83 ec 04             	sub    $0x4,%esp
f0101a28:	6a 00                	push   $0x0
f0101a2a:	68 00 10 00 00       	push   $0x1000
f0101a2f:	57                   	push   %edi
f0101a30:	e8 05 f4 ff ff       	call   f0100e3a <pgdir_walk>
f0101a35:	83 c4 10             	add    $0x10,%esp
f0101a38:	f6 00 04             	testb  $0x4,(%eax)
f0101a3b:	75 19                	jne    f0101a56 <mem_init+0xa06>
f0101a3d:	68 68 3f 10 f0       	push   $0xf0103f68
f0101a42:	68 5e 43 10 f0       	push   $0xf010435e
f0101a47:	68 41 03 00 00       	push   $0x341
f0101a4c:	68 38 43 10 f0       	push   $0xf0104338
f0101a51:	e8 35 e6 ff ff       	call   f010008b <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101a56:	a1 68 69 11 f0       	mov    0xf0116968,%eax
f0101a5b:	f6 00 04             	testb  $0x4,(%eax)
f0101a5e:	75 19                	jne    f0101a79 <mem_init+0xa29>
f0101a60:	68 50 45 10 f0       	push   $0xf0104550
f0101a65:	68 5e 43 10 f0       	push   $0xf010435e
f0101a6a:	68 42 03 00 00       	push   $0x342
f0101a6f:	68 38 43 10 f0       	push   $0xf0104338
f0101a74:	e8 12 e6 ff ff       	call   f010008b <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101a79:	6a 02                	push   $0x2
f0101a7b:	68 00 10 00 00       	push   $0x1000
f0101a80:	56                   	push   %esi
f0101a81:	50                   	push   %eax
f0101a82:	e8 3f f5 ff ff       	call   f0100fc6 <page_insert>
f0101a87:	83 c4 10             	add    $0x10,%esp
f0101a8a:	85 c0                	test   %eax,%eax
f0101a8c:	74 19                	je     f0101aa7 <mem_init+0xa57>
f0101a8e:	68 7c 3e 10 f0       	push   $0xf0103e7c
f0101a93:	68 5e 43 10 f0       	push   $0xf010435e
f0101a98:	68 45 03 00 00       	push   $0x345
f0101a9d:	68 38 43 10 f0       	push   $0xf0104338
f0101aa2:	e8 e4 e5 ff ff       	call   f010008b <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101aa7:	83 ec 04             	sub    $0x4,%esp
f0101aaa:	6a 00                	push   $0x0
f0101aac:	68 00 10 00 00       	push   $0x1000
f0101ab1:	ff 35 68 69 11 f0    	pushl  0xf0116968
f0101ab7:	e8 7e f3 ff ff       	call   f0100e3a <pgdir_walk>
f0101abc:	83 c4 10             	add    $0x10,%esp
f0101abf:	f6 00 02             	testb  $0x2,(%eax)
f0101ac2:	75 19                	jne    f0101add <mem_init+0xa8d>
f0101ac4:	68 9c 3f 10 f0       	push   $0xf0103f9c
f0101ac9:	68 5e 43 10 f0       	push   $0xf010435e
f0101ace:	68 46 03 00 00       	push   $0x346
f0101ad3:	68 38 43 10 f0       	push   $0xf0104338
f0101ad8:	e8 ae e5 ff ff       	call   f010008b <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101add:	83 ec 04             	sub    $0x4,%esp
f0101ae0:	6a 00                	push   $0x0
f0101ae2:	68 00 10 00 00       	push   $0x1000
f0101ae7:	ff 35 68 69 11 f0    	pushl  0xf0116968
f0101aed:	e8 48 f3 ff ff       	call   f0100e3a <pgdir_walk>
f0101af2:	83 c4 10             	add    $0x10,%esp
f0101af5:	f6 00 04             	testb  $0x4,(%eax)
f0101af8:	74 19                	je     f0101b13 <mem_init+0xac3>
f0101afa:	68 d0 3f 10 f0       	push   $0xf0103fd0
f0101aff:	68 5e 43 10 f0       	push   $0xf010435e
f0101b04:	68 47 03 00 00       	push   $0x347
f0101b09:	68 38 43 10 f0       	push   $0xf0104338
f0101b0e:	e8 78 e5 ff ff       	call   f010008b <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101b13:	6a 02                	push   $0x2
f0101b15:	68 00 00 40 00       	push   $0x400000
f0101b1a:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101b1d:	ff 35 68 69 11 f0    	pushl  0xf0116968
f0101b23:	e8 9e f4 ff ff       	call   f0100fc6 <page_insert>
f0101b28:	83 c4 10             	add    $0x10,%esp
f0101b2b:	85 c0                	test   %eax,%eax
f0101b2d:	78 19                	js     f0101b48 <mem_init+0xaf8>
f0101b2f:	68 08 40 10 f0       	push   $0xf0104008
f0101b34:	68 5e 43 10 f0       	push   $0xf010435e
f0101b39:	68 4a 03 00 00       	push   $0x34a
f0101b3e:	68 38 43 10 f0       	push   $0xf0104338
f0101b43:	e8 43 e5 ff ff       	call   f010008b <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101b48:	6a 02                	push   $0x2
f0101b4a:	68 00 10 00 00       	push   $0x1000
f0101b4f:	53                   	push   %ebx
f0101b50:	ff 35 68 69 11 f0    	pushl  0xf0116968
f0101b56:	e8 6b f4 ff ff       	call   f0100fc6 <page_insert>
f0101b5b:	83 c4 10             	add    $0x10,%esp
f0101b5e:	85 c0                	test   %eax,%eax
f0101b60:	74 19                	je     f0101b7b <mem_init+0xb2b>
f0101b62:	68 40 40 10 f0       	push   $0xf0104040
f0101b67:	68 5e 43 10 f0       	push   $0xf010435e
f0101b6c:	68 4d 03 00 00       	push   $0x34d
f0101b71:	68 38 43 10 f0       	push   $0xf0104338
f0101b76:	e8 10 e5 ff ff       	call   f010008b <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101b7b:	83 ec 04             	sub    $0x4,%esp
f0101b7e:	6a 00                	push   $0x0
f0101b80:	68 00 10 00 00       	push   $0x1000
f0101b85:	ff 35 68 69 11 f0    	pushl  0xf0116968
f0101b8b:	e8 aa f2 ff ff       	call   f0100e3a <pgdir_walk>
f0101b90:	83 c4 10             	add    $0x10,%esp
f0101b93:	f6 00 04             	testb  $0x4,(%eax)
f0101b96:	74 19                	je     f0101bb1 <mem_init+0xb61>
f0101b98:	68 d0 3f 10 f0       	push   $0xf0103fd0
f0101b9d:	68 5e 43 10 f0       	push   $0xf010435e
f0101ba2:	68 4e 03 00 00       	push   $0x34e
f0101ba7:	68 38 43 10 f0       	push   $0xf0104338
f0101bac:	e8 da e4 ff ff       	call   f010008b <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101bb1:	8b 3d 68 69 11 f0    	mov    0xf0116968,%edi
f0101bb7:	ba 00 00 00 00       	mov    $0x0,%edx
f0101bbc:	89 f8                	mov    %edi,%eax
f0101bbe:	e8 95 ed ff ff       	call   f0100958 <check_va2pa>
f0101bc3:	89 c1                	mov    %eax,%ecx
f0101bc5:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101bc8:	89 d8                	mov    %ebx,%eax
f0101bca:	2b 05 6c 69 11 f0    	sub    0xf011696c,%eax
f0101bd0:	c1 f8 03             	sar    $0x3,%eax
f0101bd3:	c1 e0 0c             	shl    $0xc,%eax
f0101bd6:	39 c1                	cmp    %eax,%ecx
f0101bd8:	74 19                	je     f0101bf3 <mem_init+0xba3>
f0101bda:	68 7c 40 10 f0       	push   $0xf010407c
f0101bdf:	68 5e 43 10 f0       	push   $0xf010435e
f0101be4:	68 51 03 00 00       	push   $0x351
f0101be9:	68 38 43 10 f0       	push   $0xf0104338
f0101bee:	e8 98 e4 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101bf3:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101bf8:	89 f8                	mov    %edi,%eax
f0101bfa:	e8 59 ed ff ff       	call   f0100958 <check_va2pa>
f0101bff:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101c02:	74 19                	je     f0101c1d <mem_init+0xbcd>
f0101c04:	68 a8 40 10 f0       	push   $0xf01040a8
f0101c09:	68 5e 43 10 f0       	push   $0xf010435e
f0101c0e:	68 52 03 00 00       	push   $0x352
f0101c13:	68 38 43 10 f0       	push   $0xf0104338
f0101c18:	e8 6e e4 ff ff       	call   f010008b <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101c1d:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0101c22:	74 19                	je     f0101c3d <mem_init+0xbed>
f0101c24:	68 66 45 10 f0       	push   $0xf0104566
f0101c29:	68 5e 43 10 f0       	push   $0xf010435e
f0101c2e:	68 54 03 00 00       	push   $0x354
f0101c33:	68 38 43 10 f0       	push   $0xf0104338
f0101c38:	e8 4e e4 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 0);
f0101c3d:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101c42:	74 19                	je     f0101c5d <mem_init+0xc0d>
f0101c44:	68 77 45 10 f0       	push   $0xf0104577
f0101c49:	68 5e 43 10 f0       	push   $0xf010435e
f0101c4e:	68 55 03 00 00       	push   $0x355
f0101c53:	68 38 43 10 f0       	push   $0xf0104338
f0101c58:	e8 2e e4 ff ff       	call   f010008b <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101c5d:	83 ec 0c             	sub    $0xc,%esp
f0101c60:	6a 00                	push   $0x0
f0101c62:	e8 01 f1 ff ff       	call   f0100d68 <page_alloc>
f0101c67:	83 c4 10             	add    $0x10,%esp
f0101c6a:	39 c6                	cmp    %eax,%esi
f0101c6c:	75 04                	jne    f0101c72 <mem_init+0xc22>
f0101c6e:	85 c0                	test   %eax,%eax
f0101c70:	75 19                	jne    f0101c8b <mem_init+0xc3b>
f0101c72:	68 d8 40 10 f0       	push   $0xf01040d8
f0101c77:	68 5e 43 10 f0       	push   $0xf010435e
f0101c7c:	68 58 03 00 00       	push   $0x358
f0101c81:	68 38 43 10 f0       	push   $0xf0104338
f0101c86:	e8 00 e4 ff ff       	call   f010008b <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101c8b:	83 ec 08             	sub    $0x8,%esp
f0101c8e:	6a 00                	push   $0x0
f0101c90:	ff 35 68 69 11 f0    	pushl  0xf0116968
f0101c96:	e8 dd f2 ff ff       	call   f0100f78 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101c9b:	8b 3d 68 69 11 f0    	mov    0xf0116968,%edi
f0101ca1:	ba 00 00 00 00       	mov    $0x0,%edx
f0101ca6:	89 f8                	mov    %edi,%eax
f0101ca8:	e8 ab ec ff ff       	call   f0100958 <check_va2pa>
f0101cad:	83 c4 10             	add    $0x10,%esp
f0101cb0:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101cb3:	74 19                	je     f0101cce <mem_init+0xc7e>
f0101cb5:	68 fc 40 10 f0       	push   $0xf01040fc
f0101cba:	68 5e 43 10 f0       	push   $0xf010435e
f0101cbf:	68 5c 03 00 00       	push   $0x35c
f0101cc4:	68 38 43 10 f0       	push   $0xf0104338
f0101cc9:	e8 bd e3 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101cce:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101cd3:	89 f8                	mov    %edi,%eax
f0101cd5:	e8 7e ec ff ff       	call   f0100958 <check_va2pa>
f0101cda:	89 da                	mov    %ebx,%edx
f0101cdc:	2b 15 6c 69 11 f0    	sub    0xf011696c,%edx
f0101ce2:	c1 fa 03             	sar    $0x3,%edx
f0101ce5:	c1 e2 0c             	shl    $0xc,%edx
f0101ce8:	39 d0                	cmp    %edx,%eax
f0101cea:	74 19                	je     f0101d05 <mem_init+0xcb5>
f0101cec:	68 a8 40 10 f0       	push   $0xf01040a8
f0101cf1:	68 5e 43 10 f0       	push   $0xf010435e
f0101cf6:	68 5d 03 00 00       	push   $0x35d
f0101cfb:	68 38 43 10 f0       	push   $0xf0104338
f0101d00:	e8 86 e3 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 1);
f0101d05:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101d0a:	74 19                	je     f0101d25 <mem_init+0xcd5>
f0101d0c:	68 1d 45 10 f0       	push   $0xf010451d
f0101d11:	68 5e 43 10 f0       	push   $0xf010435e
f0101d16:	68 5e 03 00 00       	push   $0x35e
f0101d1b:	68 38 43 10 f0       	push   $0xf0104338
f0101d20:	e8 66 e3 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 0);
f0101d25:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101d2a:	74 19                	je     f0101d45 <mem_init+0xcf5>
f0101d2c:	68 77 45 10 f0       	push   $0xf0104577
f0101d31:	68 5e 43 10 f0       	push   $0xf010435e
f0101d36:	68 5f 03 00 00       	push   $0x35f
f0101d3b:	68 38 43 10 f0       	push   $0xf0104338
f0101d40:	e8 46 e3 ff ff       	call   f010008b <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101d45:	6a 00                	push   $0x0
f0101d47:	68 00 10 00 00       	push   $0x1000
f0101d4c:	53                   	push   %ebx
f0101d4d:	57                   	push   %edi
f0101d4e:	e8 73 f2 ff ff       	call   f0100fc6 <page_insert>
f0101d53:	83 c4 10             	add    $0x10,%esp
f0101d56:	85 c0                	test   %eax,%eax
f0101d58:	74 19                	je     f0101d73 <mem_init+0xd23>
f0101d5a:	68 20 41 10 f0       	push   $0xf0104120
f0101d5f:	68 5e 43 10 f0       	push   $0xf010435e
f0101d64:	68 62 03 00 00       	push   $0x362
f0101d69:	68 38 43 10 f0       	push   $0xf0104338
f0101d6e:	e8 18 e3 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref);
f0101d73:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101d78:	75 19                	jne    f0101d93 <mem_init+0xd43>
f0101d7a:	68 88 45 10 f0       	push   $0xf0104588
f0101d7f:	68 5e 43 10 f0       	push   $0xf010435e
f0101d84:	68 63 03 00 00       	push   $0x363
f0101d89:	68 38 43 10 f0       	push   $0xf0104338
f0101d8e:	e8 f8 e2 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_link == NULL);
f0101d93:	83 3b 00             	cmpl   $0x0,(%ebx)
f0101d96:	74 19                	je     f0101db1 <mem_init+0xd61>
f0101d98:	68 94 45 10 f0       	push   $0xf0104594
f0101d9d:	68 5e 43 10 f0       	push   $0xf010435e
f0101da2:	68 64 03 00 00       	push   $0x364
f0101da7:	68 38 43 10 f0       	push   $0xf0104338
f0101dac:	e8 da e2 ff ff       	call   f010008b <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101db1:	83 ec 08             	sub    $0x8,%esp
f0101db4:	68 00 10 00 00       	push   $0x1000
f0101db9:	ff 35 68 69 11 f0    	pushl  0xf0116968
f0101dbf:	e8 b4 f1 ff ff       	call   f0100f78 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101dc4:	8b 3d 68 69 11 f0    	mov    0xf0116968,%edi
f0101dca:	ba 00 00 00 00       	mov    $0x0,%edx
f0101dcf:	89 f8                	mov    %edi,%eax
f0101dd1:	e8 82 eb ff ff       	call   f0100958 <check_va2pa>
f0101dd6:	83 c4 10             	add    $0x10,%esp
f0101dd9:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101ddc:	74 19                	je     f0101df7 <mem_init+0xda7>
f0101dde:	68 fc 40 10 f0       	push   $0xf01040fc
f0101de3:	68 5e 43 10 f0       	push   $0xf010435e
f0101de8:	68 68 03 00 00       	push   $0x368
f0101ded:	68 38 43 10 f0       	push   $0xf0104338
f0101df2:	e8 94 e2 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101df7:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101dfc:	89 f8                	mov    %edi,%eax
f0101dfe:	e8 55 eb ff ff       	call   f0100958 <check_va2pa>
f0101e03:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101e06:	74 19                	je     f0101e21 <mem_init+0xdd1>
f0101e08:	68 58 41 10 f0       	push   $0xf0104158
f0101e0d:	68 5e 43 10 f0       	push   $0xf010435e
f0101e12:	68 69 03 00 00       	push   $0x369
f0101e17:	68 38 43 10 f0       	push   $0xf0104338
f0101e1c:	e8 6a e2 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 0);
f0101e21:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101e26:	74 19                	je     f0101e41 <mem_init+0xdf1>
f0101e28:	68 a9 45 10 f0       	push   $0xf01045a9
f0101e2d:	68 5e 43 10 f0       	push   $0xf010435e
f0101e32:	68 6a 03 00 00       	push   $0x36a
f0101e37:	68 38 43 10 f0       	push   $0xf0104338
f0101e3c:	e8 4a e2 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 0);
f0101e41:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101e46:	74 19                	je     f0101e61 <mem_init+0xe11>
f0101e48:	68 77 45 10 f0       	push   $0xf0104577
f0101e4d:	68 5e 43 10 f0       	push   $0xf010435e
f0101e52:	68 6b 03 00 00       	push   $0x36b
f0101e57:	68 38 43 10 f0       	push   $0xf0104338
f0101e5c:	e8 2a e2 ff ff       	call   f010008b <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101e61:	83 ec 0c             	sub    $0xc,%esp
f0101e64:	6a 00                	push   $0x0
f0101e66:	e8 fd ee ff ff       	call   f0100d68 <page_alloc>
f0101e6b:	83 c4 10             	add    $0x10,%esp
f0101e6e:	85 c0                	test   %eax,%eax
f0101e70:	74 04                	je     f0101e76 <mem_init+0xe26>
f0101e72:	39 c3                	cmp    %eax,%ebx
f0101e74:	74 19                	je     f0101e8f <mem_init+0xe3f>
f0101e76:	68 80 41 10 f0       	push   $0xf0104180
f0101e7b:	68 5e 43 10 f0       	push   $0xf010435e
f0101e80:	68 6e 03 00 00       	push   $0x36e
f0101e85:	68 38 43 10 f0       	push   $0xf0104338
f0101e8a:	e8 fc e1 ff ff       	call   f010008b <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101e8f:	83 ec 0c             	sub    $0xc,%esp
f0101e92:	6a 00                	push   $0x0
f0101e94:	e8 cf ee ff ff       	call   f0100d68 <page_alloc>
f0101e99:	83 c4 10             	add    $0x10,%esp
f0101e9c:	85 c0                	test   %eax,%eax
f0101e9e:	74 19                	je     f0101eb9 <mem_init+0xe69>
f0101ea0:	68 cb 44 10 f0       	push   $0xf01044cb
f0101ea5:	68 5e 43 10 f0       	push   $0xf010435e
f0101eaa:	68 71 03 00 00       	push   $0x371
f0101eaf:	68 38 43 10 f0       	push   $0xf0104338
f0101eb4:	e8 d2 e1 ff ff       	call   f010008b <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101eb9:	8b 0d 68 69 11 f0    	mov    0xf0116968,%ecx
f0101ebf:	8b 11                	mov    (%ecx),%edx
f0101ec1:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101ec7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101eca:	2b 05 6c 69 11 f0    	sub    0xf011696c,%eax
f0101ed0:	c1 f8 03             	sar    $0x3,%eax
f0101ed3:	c1 e0 0c             	shl    $0xc,%eax
f0101ed6:	39 c2                	cmp    %eax,%edx
f0101ed8:	74 19                	je     f0101ef3 <mem_init+0xea3>
f0101eda:	68 24 3e 10 f0       	push   $0xf0103e24
f0101edf:	68 5e 43 10 f0       	push   $0xf010435e
f0101ee4:	68 74 03 00 00       	push   $0x374
f0101ee9:	68 38 43 10 f0       	push   $0xf0104338
f0101eee:	e8 98 e1 ff ff       	call   f010008b <_panic>
	kern_pgdir[0] = 0;
f0101ef3:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0101ef9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101efc:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101f01:	74 19                	je     f0101f1c <mem_init+0xecc>
f0101f03:	68 2e 45 10 f0       	push   $0xf010452e
f0101f08:	68 5e 43 10 f0       	push   $0xf010435e
f0101f0d:	68 76 03 00 00       	push   $0x376
f0101f12:	68 38 43 10 f0       	push   $0xf0104338
f0101f17:	e8 6f e1 ff ff       	call   f010008b <_panic>
	pp0->pp_ref = 0;
f0101f1c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f1f:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0101f25:	83 ec 0c             	sub    $0xc,%esp
f0101f28:	50                   	push   %eax
f0101f29:	e8 aa ee ff ff       	call   f0100dd8 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0101f2e:	83 c4 0c             	add    $0xc,%esp
f0101f31:	6a 01                	push   $0x1
f0101f33:	68 00 10 40 00       	push   $0x401000
f0101f38:	ff 35 68 69 11 f0    	pushl  0xf0116968
f0101f3e:	e8 f7 ee ff ff       	call   f0100e3a <pgdir_walk>
f0101f43:	89 c7                	mov    %eax,%edi
f0101f45:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0101f48:	a1 68 69 11 f0       	mov    0xf0116968,%eax
f0101f4d:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101f50:	8b 40 04             	mov    0x4(%eax),%eax
f0101f53:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101f58:	8b 0d 64 69 11 f0    	mov    0xf0116964,%ecx
f0101f5e:	89 c2                	mov    %eax,%edx
f0101f60:	c1 ea 0c             	shr    $0xc,%edx
f0101f63:	83 c4 10             	add    $0x10,%esp
f0101f66:	39 ca                	cmp    %ecx,%edx
f0101f68:	72 15                	jb     f0101f7f <mem_init+0xf2f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101f6a:	50                   	push   %eax
f0101f6b:	68 c0 3b 10 f0       	push   $0xf0103bc0
f0101f70:	68 7d 03 00 00       	push   $0x37d
f0101f75:	68 38 43 10 f0       	push   $0xf0104338
f0101f7a:	e8 0c e1 ff ff       	call   f010008b <_panic>
	assert(ptep == ptep1 + PTX(va));
f0101f7f:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f0101f84:	39 c7                	cmp    %eax,%edi
f0101f86:	74 19                	je     f0101fa1 <mem_init+0xf51>
f0101f88:	68 ba 45 10 f0       	push   $0xf01045ba
f0101f8d:	68 5e 43 10 f0       	push   $0xf010435e
f0101f92:	68 7e 03 00 00       	push   $0x37e
f0101f97:	68 38 43 10 f0       	push   $0xf0104338
f0101f9c:	e8 ea e0 ff ff       	call   f010008b <_panic>
	kern_pgdir[PDX(va)] = 0;
f0101fa1:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101fa4:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f0101fab:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101fae:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101fb4:	2b 05 6c 69 11 f0    	sub    0xf011696c,%eax
f0101fba:	c1 f8 03             	sar    $0x3,%eax
f0101fbd:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101fc0:	89 c2                	mov    %eax,%edx
f0101fc2:	c1 ea 0c             	shr    $0xc,%edx
f0101fc5:	39 d1                	cmp    %edx,%ecx
f0101fc7:	77 12                	ja     f0101fdb <mem_init+0xf8b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101fc9:	50                   	push   %eax
f0101fca:	68 c0 3b 10 f0       	push   $0xf0103bc0
f0101fcf:	6a 52                	push   $0x52
f0101fd1:	68 44 43 10 f0       	push   $0xf0104344
f0101fd6:	e8 b0 e0 ff ff       	call   f010008b <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0101fdb:	83 ec 04             	sub    $0x4,%esp
f0101fde:	68 00 10 00 00       	push   $0x1000
f0101fe3:	68 ff 00 00 00       	push   $0xff
f0101fe8:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101fed:	50                   	push   %eax
f0101fee:	e8 5b 12 00 00       	call   f010324e <memset>
	page_free(pp0);
f0101ff3:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0101ff6:	89 3c 24             	mov    %edi,(%esp)
f0101ff9:	e8 da ed ff ff       	call   f0100dd8 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0101ffe:	83 c4 0c             	add    $0xc,%esp
f0102001:	6a 01                	push   $0x1
f0102003:	6a 00                	push   $0x0
f0102005:	ff 35 68 69 11 f0    	pushl  0xf0116968
f010200b:	e8 2a ee ff ff       	call   f0100e3a <pgdir_walk>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102010:	89 fa                	mov    %edi,%edx
f0102012:	2b 15 6c 69 11 f0    	sub    0xf011696c,%edx
f0102018:	c1 fa 03             	sar    $0x3,%edx
f010201b:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010201e:	89 d0                	mov    %edx,%eax
f0102020:	c1 e8 0c             	shr    $0xc,%eax
f0102023:	83 c4 10             	add    $0x10,%esp
f0102026:	3b 05 64 69 11 f0    	cmp    0xf0116964,%eax
f010202c:	72 12                	jb     f0102040 <mem_init+0xff0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010202e:	52                   	push   %edx
f010202f:	68 c0 3b 10 f0       	push   $0xf0103bc0
f0102034:	6a 52                	push   $0x52
f0102036:	68 44 43 10 f0       	push   $0xf0104344
f010203b:	e8 4b e0 ff ff       	call   f010008b <_panic>
	return (void *)(pa + KERNBASE);
f0102040:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102046:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102049:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f010204f:	f6 00 01             	testb  $0x1,(%eax)
f0102052:	74 19                	je     f010206d <mem_init+0x101d>
f0102054:	68 d2 45 10 f0       	push   $0xf01045d2
f0102059:	68 5e 43 10 f0       	push   $0xf010435e
f010205e:	68 88 03 00 00       	push   $0x388
f0102063:	68 38 43 10 f0       	push   $0xf0104338
f0102068:	e8 1e e0 ff ff       	call   f010008b <_panic>
f010206d:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0102070:	39 c2                	cmp    %eax,%edx
f0102072:	75 db                	jne    f010204f <mem_init+0xfff>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0102074:	a1 68 69 11 f0       	mov    0xf0116968,%eax
f0102079:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f010207f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102082:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0102088:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f010208b:	89 0d 3c 65 11 f0    	mov    %ecx,0xf011653c

	// free the pages we took
	page_free(pp0);
f0102091:	83 ec 0c             	sub    $0xc,%esp
f0102094:	50                   	push   %eax
f0102095:	e8 3e ed ff ff       	call   f0100dd8 <page_free>
	page_free(pp1);
f010209a:	89 1c 24             	mov    %ebx,(%esp)
f010209d:	e8 36 ed ff ff       	call   f0100dd8 <page_free>
	page_free(pp2);
f01020a2:	89 34 24             	mov    %esi,(%esp)
f01020a5:	e8 2e ed ff ff       	call   f0100dd8 <page_free>

	cprintf("check_page() succeeded!\n");
f01020aa:	c7 04 24 e9 45 10 f0 	movl   $0xf01045e9,(%esp)
f01020b1:	e8 bd 06 00 00       	call   f0102773 <cprintf>
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	int perm = PTE_U | PTE_P;  
    	int i=0;
     	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);  
f01020b6:	a1 64 69 11 f0       	mov    0xf0116964,%eax
f01020bb:	8d 34 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%esi
f01020c2:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    	for(i=0; i<n; i= i+PGSIZE)  
f01020c8:	83 c4 10             	add    $0x10,%esp
f01020cb:	bb 00 00 00 00       	mov    $0x0,%ebx
f01020d0:	eb 6a                	jmp    f010213c <mem_init+0x10ec>
f01020d2:	8d 8b 00 00 00 ef    	lea    -0x11000000(%ebx),%ecx
        	page_insert(kern_pgdir, pa2page(PADDR(pages) + i), (void *) (UPAGES +i), perm);
f01020d8:	8b 15 6c 69 11 f0    	mov    0xf011696c,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01020de:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f01020e4:	77 15                	ja     f01020fb <mem_init+0x10ab>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01020e6:	52                   	push   %edx
f01020e7:	68 cc 3c 10 f0       	push   $0xf0103ccc
f01020ec:	68 b9 00 00 00       	push   $0xb9
f01020f1:	68 38 43 10 f0       	push   $0xf0104338
f01020f6:	e8 90 df ff ff       	call   f010008b <_panic>
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01020fb:	8d 84 02 00 00 00 10 	lea    0x10000000(%edx,%eax,1),%eax
f0102102:	c1 e8 0c             	shr    $0xc,%eax
f0102105:	3b 05 64 69 11 f0    	cmp    0xf0116964,%eax
f010210b:	72 14                	jb     f0102121 <mem_init+0x10d1>
		panic("pa2page called with invalid pa");
f010210d:	83 ec 04             	sub    $0x4,%esp
f0102110:	68 f0 3c 10 f0       	push   $0xf0103cf0
f0102115:	6a 4b                	push   $0x4b
f0102117:	68 44 43 10 f0       	push   $0xf0104344
f010211c:	e8 6a df ff ff       	call   f010008b <_panic>
f0102121:	6a 05                	push   $0x5
f0102123:	51                   	push   %ecx
f0102124:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0102127:	50                   	push   %eax
f0102128:	ff 35 68 69 11 f0    	pushl  0xf0116968
f010212e:	e8 93 ee ff ff       	call   f0100fc6 <page_insert>
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	int perm = PTE_U | PTE_P;  
    	int i=0;
     	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);  
    	for(i=0; i<n; i= i+PGSIZE)  
f0102133:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102139:	83 c4 10             	add    $0x10,%esp
f010213c:	89 d8                	mov    %ebx,%eax
f010213e:	39 de                	cmp    %ebx,%esi
f0102140:	77 90                	ja     f01020d2 <mem_init+0x1082>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102142:	b8 00 c0 10 f0       	mov    $0xf010c000,%eax
f0102147:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010214c:	77 15                	ja     f0102163 <mem_init+0x1113>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010214e:	50                   	push   %eax
f010214f:	68 cc 3c 10 f0       	push   $0xf0103ccc
f0102154:	68 c7 00 00 00       	push   $0xc7
f0102159:	68 38 43 10 f0       	push   $0xf0104338
f010215e:	e8 28 df ff ff       	call   f010008b <_panic>
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	perm =0;  
	perm = PTE_P |PTE_W;
	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, ROUNDUP(KSTKSIZE, PGSIZE), PADDR(bootstack), perm);
f0102163:	8b 3d 68 69 11 f0    	mov    0xf0116968,%edi
f0102169:	bb 00 80 ff ef       	mov    $0xefff8000,%ebx
f010216e:	8d b3 00 40 11 10    	lea    0x10114000(%ebx),%esi
{
	// Fill this function in
	//将虚拟地址转换成物理地址
	while(size)  
    	{  
        	pte_t* pte = pgdir_walk(pgdir, (void* )va, 1);  
f0102174:	83 ec 04             	sub    $0x4,%esp
f0102177:	6a 01                	push   $0x1
f0102179:	53                   	push   %ebx
f010217a:	57                   	push   %edi
f010217b:	e8 ba ec ff ff       	call   f0100e3a <pgdir_walk>
        	if(pte == NULL)  
f0102180:	83 c4 10             	add    $0x10,%esp
f0102183:	85 c0                	test   %eax,%eax
f0102185:	74 13                	je     f010219a <mem_init+0x114a>
            		return;  
        	*pte= pa |perm|PTE_P;
f0102187:	83 ce 03             	or     $0x3,%esi
f010218a:	89 30                	mov    %esi,(%eax)
        	size -= PGSIZE;  
        	pa  += PGSIZE;  
        	va  += PGSIZE;  
f010218c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
	//将虚拟地址转换成物理地址
	while(size)  
f0102192:	81 fb 00 00 00 f0    	cmp    $0xf0000000,%ebx
f0102198:	75 d4                	jne    f010216e <mem_init+0x111e>
	int size = ~0;  
	size = size - KERNBASE +1;  
	size = ROUNDUP(size, PGSIZE);  
	perm = 0;  
	perm = PTE_P | PTE_W;  
	boot_map_region(kern_pgdir, KERNBASE, size, 0, perm );
f010219a:	8b 3d 68 69 11 f0    	mov    0xf0116968,%edi
f01021a0:	bb 00 00 00 f0       	mov    $0xf0000000,%ebx
f01021a5:	8d b3 00 00 00 10    	lea    0x10000000(%ebx),%esi
{
	// Fill this function in
	//将虚拟地址转换成物理地址
	while(size)  
    	{  
        	pte_t* pte = pgdir_walk(pgdir, (void* )va, 1);  
f01021ab:	83 ec 04             	sub    $0x4,%esp
f01021ae:	6a 01                	push   $0x1
f01021b0:	53                   	push   %ebx
f01021b1:	57                   	push   %edi
f01021b2:	e8 83 ec ff ff       	call   f0100e3a <pgdir_walk>
        	if(pte == NULL)  
f01021b7:	83 c4 10             	add    $0x10,%esp
f01021ba:	85 c0                	test   %eax,%eax
f01021bc:	74 0d                	je     f01021cb <mem_init+0x117b>
            		return;  
        	*pte= pa |perm|PTE_P;
f01021be:	83 ce 03             	or     $0x3,%esi
f01021c1:	89 30                	mov    %esi,(%eax)
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
	//将虚拟地址转换成物理地址
	while(size)  
f01021c3:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01021c9:	75 da                	jne    f01021a5 <mem_init+0x1155>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f01021cb:	8b 35 68 69 11 f0    	mov    0xf0116968,%esi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f01021d1:	a1 64 69 11 f0       	mov    0xf0116964,%eax
f01021d6:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01021d9:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f01021e0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01021e5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01021e8:	8b 3d 6c 69 11 f0    	mov    0xf011696c,%edi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01021ee:	89 7d d0             	mov    %edi,-0x30(%ebp)

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01021f1:	bb 00 00 00 00       	mov    $0x0,%ebx
f01021f6:	eb 55                	jmp    f010224d <mem_init+0x11fd>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01021f8:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f01021fe:	89 f0                	mov    %esi,%eax
f0102200:	e8 53 e7 ff ff       	call   f0100958 <check_va2pa>
f0102205:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f010220c:	77 15                	ja     f0102223 <mem_init+0x11d3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010220e:	57                   	push   %edi
f010220f:	68 cc 3c 10 f0       	push   $0xf0103ccc
f0102214:	68 ca 02 00 00       	push   $0x2ca
f0102219:	68 38 43 10 f0       	push   $0xf0104338
f010221e:	e8 68 de ff ff       	call   f010008b <_panic>
f0102223:	8d 94 1f 00 00 00 10 	lea    0x10000000(%edi,%ebx,1),%edx
f010222a:	39 c2                	cmp    %eax,%edx
f010222c:	74 19                	je     f0102247 <mem_init+0x11f7>
f010222e:	68 a4 41 10 f0       	push   $0xf01041a4
f0102233:	68 5e 43 10 f0       	push   $0xf010435e
f0102238:	68 ca 02 00 00       	push   $0x2ca
f010223d:	68 38 43 10 f0       	push   $0xf0104338
f0102242:	e8 44 de ff ff       	call   f010008b <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102247:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010224d:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0102250:	77 a6                	ja     f01021f8 <mem_init+0x11a8>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102252:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0102255:	c1 e7 0c             	shl    $0xc,%edi
f0102258:	bb 00 00 00 00       	mov    $0x0,%ebx
f010225d:	eb 30                	jmp    f010228f <mem_init+0x123f>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f010225f:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f0102265:	89 f0                	mov    %esi,%eax
f0102267:	e8 ec e6 ff ff       	call   f0100958 <check_va2pa>
f010226c:	39 c3                	cmp    %eax,%ebx
f010226e:	74 19                	je     f0102289 <mem_init+0x1239>
f0102270:	68 d8 41 10 f0       	push   $0xf01041d8
f0102275:	68 5e 43 10 f0       	push   $0xf010435e
f010227a:	68 cf 02 00 00       	push   $0x2cf
f010227f:	68 38 43 10 f0       	push   $0xf0104338
f0102284:	e8 02 de ff ff       	call   f010008b <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102289:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010228f:	39 fb                	cmp    %edi,%ebx
f0102291:	72 cc                	jb     f010225f <mem_init+0x120f>
f0102293:	bb 00 80 ff ef       	mov    $0xefff8000,%ebx
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102298:	89 da                	mov    %ebx,%edx
f010229a:	89 f0                	mov    %esi,%eax
f010229c:	e8 b7 e6 ff ff       	call   f0100958 <check_va2pa>
f01022a1:	8d 93 00 40 11 10    	lea    0x10114000(%ebx),%edx
f01022a7:	39 c2                	cmp    %eax,%edx
f01022a9:	74 19                	je     f01022c4 <mem_init+0x1274>
f01022ab:	68 00 42 10 f0       	push   $0xf0104200
f01022b0:	68 5e 43 10 f0       	push   $0xf010435e
f01022b5:	68 d3 02 00 00       	push   $0x2d3
f01022ba:	68 38 43 10 f0       	push   $0xf0104338
f01022bf:	e8 c7 dd ff ff       	call   f010008b <_panic>
f01022c4:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f01022ca:	81 fb 00 00 00 f0    	cmp    $0xf0000000,%ebx
f01022d0:	75 c6                	jne    f0102298 <mem_init+0x1248>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f01022d2:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f01022d7:	89 f0                	mov    %esi,%eax
f01022d9:	e8 7a e6 ff ff       	call   f0100958 <check_va2pa>
f01022de:	83 f8 ff             	cmp    $0xffffffff,%eax
f01022e1:	74 51                	je     f0102334 <mem_init+0x12e4>
f01022e3:	68 48 42 10 f0       	push   $0xf0104248
f01022e8:	68 5e 43 10 f0       	push   $0xf010435e
f01022ed:	68 d4 02 00 00       	push   $0x2d4
f01022f2:	68 38 43 10 f0       	push   $0xf0104338
f01022f7:	e8 8f dd ff ff       	call   f010008b <_panic>

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f01022fc:	3d bc 03 00 00       	cmp    $0x3bc,%eax
f0102301:	72 36                	jb     f0102339 <mem_init+0x12e9>
f0102303:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f0102308:	76 07                	jbe    f0102311 <mem_init+0x12c1>
f010230a:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f010230f:	75 28                	jne    f0102339 <mem_init+0x12e9>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
			assert(pgdir[i] & PTE_P);
f0102311:	f6 04 86 01          	testb  $0x1,(%esi,%eax,4)
f0102315:	0f 85 83 00 00 00    	jne    f010239e <mem_init+0x134e>
f010231b:	68 02 46 10 f0       	push   $0xf0104602
f0102320:	68 5e 43 10 f0       	push   $0xf010435e
f0102325:	68 dc 02 00 00       	push   $0x2dc
f010232a:	68 38 43 10 f0       	push   $0xf0104338
f010232f:	e8 57 dd ff ff       	call   f010008b <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102334:	b8 00 00 00 00       	mov    $0x0,%eax
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
			assert(pgdir[i] & PTE_P);
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0102339:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f010233e:	76 3f                	jbe    f010237f <mem_init+0x132f>
				assert(pgdir[i] & PTE_P);
f0102340:	8b 14 86             	mov    (%esi,%eax,4),%edx
f0102343:	f6 c2 01             	test   $0x1,%dl
f0102346:	75 19                	jne    f0102361 <mem_init+0x1311>
f0102348:	68 02 46 10 f0       	push   $0xf0104602
f010234d:	68 5e 43 10 f0       	push   $0xf010435e
f0102352:	68 e0 02 00 00       	push   $0x2e0
f0102357:	68 38 43 10 f0       	push   $0xf0104338
f010235c:	e8 2a dd ff ff       	call   f010008b <_panic>
				assert(pgdir[i] & PTE_W);
f0102361:	f6 c2 02             	test   $0x2,%dl
f0102364:	75 38                	jne    f010239e <mem_init+0x134e>
f0102366:	68 13 46 10 f0       	push   $0xf0104613
f010236b:	68 5e 43 10 f0       	push   $0xf010435e
f0102370:	68 e1 02 00 00       	push   $0x2e1
f0102375:	68 38 43 10 f0       	push   $0xf0104338
f010237a:	e8 0c dd ff ff       	call   f010008b <_panic>
			} else
				assert(pgdir[i] == 0);
f010237f:	83 3c 86 00          	cmpl   $0x0,(%esi,%eax,4)
f0102383:	74 19                	je     f010239e <mem_init+0x134e>
f0102385:	68 24 46 10 f0       	push   $0xf0104624
f010238a:	68 5e 43 10 f0       	push   $0xf010435e
f010238f:	68 e3 02 00 00       	push   $0x2e3
f0102394:	68 38 43 10 f0       	push   $0xf0104338
f0102399:	e8 ed dc ff ff       	call   f010008b <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f010239e:	83 c0 01             	add    $0x1,%eax
f01023a1:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f01023a6:	0f 86 50 ff ff ff    	jbe    f01022fc <mem_init+0x12ac>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f01023ac:	83 ec 0c             	sub    $0xc,%esp
f01023af:	68 78 42 10 f0       	push   $0xf0104278
f01023b4:	e8 ba 03 00 00       	call   f0102773 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f01023b9:	a1 68 69 11 f0       	mov    0xf0116968,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01023be:	83 c4 10             	add    $0x10,%esp
f01023c1:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01023c6:	77 15                	ja     f01023dd <mem_init+0x138d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01023c8:	50                   	push   %eax
f01023c9:	68 cc 3c 10 f0       	push   $0xf0103ccc
f01023ce:	68 e0 00 00 00       	push   $0xe0
f01023d3:	68 38 43 10 f0       	push   $0xf0104338
f01023d8:	e8 ae dc ff ff       	call   f010008b <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01023dd:	05 00 00 00 10       	add    $0x10000000,%eax
f01023e2:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f01023e5:	b8 00 00 00 00       	mov    $0x0,%eax
f01023ea:	e8 cd e5 ff ff       	call   f01009bc <check_page_free_list>

static inline uint32_t
rcr0(void)
{
	uint32_t val;
	asm volatile("movl %%cr0,%0" : "=r" (val));
f01023ef:	0f 20 c0             	mov    %cr0,%eax
f01023f2:	83 e0 f3             	and    $0xfffffff3,%eax
}

static inline void
lcr0(uint32_t val)
{
	asm volatile("movl %0,%%cr0" : : "r" (val));
f01023f5:	0d 23 00 05 80       	or     $0x80050023,%eax
f01023fa:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01023fd:	83 ec 0c             	sub    $0xc,%esp
f0102400:	6a 00                	push   $0x0
f0102402:	e8 61 e9 ff ff       	call   f0100d68 <page_alloc>
f0102407:	89 c3                	mov    %eax,%ebx
f0102409:	83 c4 10             	add    $0x10,%esp
f010240c:	85 c0                	test   %eax,%eax
f010240e:	75 19                	jne    f0102429 <mem_init+0x13d9>
f0102410:	68 20 44 10 f0       	push   $0xf0104420
f0102415:	68 5e 43 10 f0       	push   $0xf010435e
f010241a:	68 a3 03 00 00       	push   $0x3a3
f010241f:	68 38 43 10 f0       	push   $0xf0104338
f0102424:	e8 62 dc ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f0102429:	83 ec 0c             	sub    $0xc,%esp
f010242c:	6a 00                	push   $0x0
f010242e:	e8 35 e9 ff ff       	call   f0100d68 <page_alloc>
f0102433:	89 c7                	mov    %eax,%edi
f0102435:	83 c4 10             	add    $0x10,%esp
f0102438:	85 c0                	test   %eax,%eax
f010243a:	75 19                	jne    f0102455 <mem_init+0x1405>
f010243c:	68 36 44 10 f0       	push   $0xf0104436
f0102441:	68 5e 43 10 f0       	push   $0xf010435e
f0102446:	68 a4 03 00 00       	push   $0x3a4
f010244b:	68 38 43 10 f0       	push   $0xf0104338
f0102450:	e8 36 dc ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f0102455:	83 ec 0c             	sub    $0xc,%esp
f0102458:	6a 00                	push   $0x0
f010245a:	e8 09 e9 ff ff       	call   f0100d68 <page_alloc>
f010245f:	89 c6                	mov    %eax,%esi
f0102461:	83 c4 10             	add    $0x10,%esp
f0102464:	85 c0                	test   %eax,%eax
f0102466:	75 19                	jne    f0102481 <mem_init+0x1431>
f0102468:	68 4c 44 10 f0       	push   $0xf010444c
f010246d:	68 5e 43 10 f0       	push   $0xf010435e
f0102472:	68 a5 03 00 00       	push   $0x3a5
f0102477:	68 38 43 10 f0       	push   $0xf0104338
f010247c:	e8 0a dc ff ff       	call   f010008b <_panic>
	page_free(pp0);
f0102481:	83 ec 0c             	sub    $0xc,%esp
f0102484:	53                   	push   %ebx
f0102485:	e8 4e e9 ff ff       	call   f0100dd8 <page_free>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010248a:	89 f8                	mov    %edi,%eax
f010248c:	2b 05 6c 69 11 f0    	sub    0xf011696c,%eax
f0102492:	c1 f8 03             	sar    $0x3,%eax
f0102495:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102498:	89 c2                	mov    %eax,%edx
f010249a:	c1 ea 0c             	shr    $0xc,%edx
f010249d:	83 c4 10             	add    $0x10,%esp
f01024a0:	3b 15 64 69 11 f0    	cmp    0xf0116964,%edx
f01024a6:	72 12                	jb     f01024ba <mem_init+0x146a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01024a8:	50                   	push   %eax
f01024a9:	68 c0 3b 10 f0       	push   $0xf0103bc0
f01024ae:	6a 52                	push   $0x52
f01024b0:	68 44 43 10 f0       	push   $0xf0104344
f01024b5:	e8 d1 db ff ff       	call   f010008b <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f01024ba:	83 ec 04             	sub    $0x4,%esp
f01024bd:	68 00 10 00 00       	push   $0x1000
f01024c2:	6a 01                	push   $0x1
f01024c4:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01024c9:	50                   	push   %eax
f01024ca:	e8 7f 0d 00 00       	call   f010324e <memset>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01024cf:	89 f0                	mov    %esi,%eax
f01024d1:	2b 05 6c 69 11 f0    	sub    0xf011696c,%eax
f01024d7:	c1 f8 03             	sar    $0x3,%eax
f01024da:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01024dd:	89 c2                	mov    %eax,%edx
f01024df:	c1 ea 0c             	shr    $0xc,%edx
f01024e2:	83 c4 10             	add    $0x10,%esp
f01024e5:	3b 15 64 69 11 f0    	cmp    0xf0116964,%edx
f01024eb:	72 12                	jb     f01024ff <mem_init+0x14af>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01024ed:	50                   	push   %eax
f01024ee:	68 c0 3b 10 f0       	push   $0xf0103bc0
f01024f3:	6a 52                	push   $0x52
f01024f5:	68 44 43 10 f0       	push   $0xf0104344
f01024fa:	e8 8c db ff ff       	call   f010008b <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f01024ff:	83 ec 04             	sub    $0x4,%esp
f0102502:	68 00 10 00 00       	push   $0x1000
f0102507:	6a 02                	push   $0x2
f0102509:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010250e:	50                   	push   %eax
f010250f:	e8 3a 0d 00 00       	call   f010324e <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102514:	6a 02                	push   $0x2
f0102516:	68 00 10 00 00       	push   $0x1000
f010251b:	57                   	push   %edi
f010251c:	ff 35 68 69 11 f0    	pushl  0xf0116968
f0102522:	e8 9f ea ff ff       	call   f0100fc6 <page_insert>
	assert(pp1->pp_ref == 1);
f0102527:	83 c4 20             	add    $0x20,%esp
f010252a:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f010252f:	74 19                	je     f010254a <mem_init+0x14fa>
f0102531:	68 1d 45 10 f0       	push   $0xf010451d
f0102536:	68 5e 43 10 f0       	push   $0xf010435e
f010253b:	68 aa 03 00 00       	push   $0x3aa
f0102540:	68 38 43 10 f0       	push   $0xf0104338
f0102545:	e8 41 db ff ff       	call   f010008b <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f010254a:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102551:	01 01 01 
f0102554:	74 19                	je     f010256f <mem_init+0x151f>
f0102556:	68 98 42 10 f0       	push   $0xf0104298
f010255b:	68 5e 43 10 f0       	push   $0xf010435e
f0102560:	68 ab 03 00 00       	push   $0x3ab
f0102565:	68 38 43 10 f0       	push   $0xf0104338
f010256a:	e8 1c db ff ff       	call   f010008b <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f010256f:	6a 02                	push   $0x2
f0102571:	68 00 10 00 00       	push   $0x1000
f0102576:	56                   	push   %esi
f0102577:	ff 35 68 69 11 f0    	pushl  0xf0116968
f010257d:	e8 44 ea ff ff       	call   f0100fc6 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102582:	83 c4 10             	add    $0x10,%esp
f0102585:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f010258c:	02 02 02 
f010258f:	74 19                	je     f01025aa <mem_init+0x155a>
f0102591:	68 bc 42 10 f0       	push   $0xf01042bc
f0102596:	68 5e 43 10 f0       	push   $0xf010435e
f010259b:	68 ad 03 00 00       	push   $0x3ad
f01025a0:	68 38 43 10 f0       	push   $0xf0104338
f01025a5:	e8 e1 da ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f01025aa:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01025af:	74 19                	je     f01025ca <mem_init+0x157a>
f01025b1:	68 3f 45 10 f0       	push   $0xf010453f
f01025b6:	68 5e 43 10 f0       	push   $0xf010435e
f01025bb:	68 ae 03 00 00       	push   $0x3ae
f01025c0:	68 38 43 10 f0       	push   $0xf0104338
f01025c5:	e8 c1 da ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 0);
f01025ca:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f01025cf:	74 19                	je     f01025ea <mem_init+0x159a>
f01025d1:	68 a9 45 10 f0       	push   $0xf01045a9
f01025d6:	68 5e 43 10 f0       	push   $0xf010435e
f01025db:	68 af 03 00 00       	push   $0x3af
f01025e0:	68 38 43 10 f0       	push   $0xf0104338
f01025e5:	e8 a1 da ff ff       	call   f010008b <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f01025ea:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f01025f1:	03 03 03 
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01025f4:	89 f0                	mov    %esi,%eax
f01025f6:	2b 05 6c 69 11 f0    	sub    0xf011696c,%eax
f01025fc:	c1 f8 03             	sar    $0x3,%eax
f01025ff:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102602:	89 c2                	mov    %eax,%edx
f0102604:	c1 ea 0c             	shr    $0xc,%edx
f0102607:	3b 15 64 69 11 f0    	cmp    0xf0116964,%edx
f010260d:	72 12                	jb     f0102621 <mem_init+0x15d1>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010260f:	50                   	push   %eax
f0102610:	68 c0 3b 10 f0       	push   $0xf0103bc0
f0102615:	6a 52                	push   $0x52
f0102617:	68 44 43 10 f0       	push   $0xf0104344
f010261c:	e8 6a da ff ff       	call   f010008b <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102621:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102628:	03 03 03 
f010262b:	74 19                	je     f0102646 <mem_init+0x15f6>
f010262d:	68 e0 42 10 f0       	push   $0xf01042e0
f0102632:	68 5e 43 10 f0       	push   $0xf010435e
f0102637:	68 b1 03 00 00       	push   $0x3b1
f010263c:	68 38 43 10 f0       	push   $0xf0104338
f0102641:	e8 45 da ff ff       	call   f010008b <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102646:	83 ec 08             	sub    $0x8,%esp
f0102649:	68 00 10 00 00       	push   $0x1000
f010264e:	ff 35 68 69 11 f0    	pushl  0xf0116968
f0102654:	e8 1f e9 ff ff       	call   f0100f78 <page_remove>
	assert(pp2->pp_ref == 0);
f0102659:	83 c4 10             	add    $0x10,%esp
f010265c:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102661:	74 19                	je     f010267c <mem_init+0x162c>
f0102663:	68 77 45 10 f0       	push   $0xf0104577
f0102668:	68 5e 43 10 f0       	push   $0xf010435e
f010266d:	68 b3 03 00 00       	push   $0x3b3
f0102672:	68 38 43 10 f0       	push   $0xf0104338
f0102677:	e8 0f da ff ff       	call   f010008b <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010267c:	8b 0d 68 69 11 f0    	mov    0xf0116968,%ecx
f0102682:	8b 11                	mov    (%ecx),%edx
f0102684:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010268a:	89 d8                	mov    %ebx,%eax
f010268c:	2b 05 6c 69 11 f0    	sub    0xf011696c,%eax
f0102692:	c1 f8 03             	sar    $0x3,%eax
f0102695:	c1 e0 0c             	shl    $0xc,%eax
f0102698:	39 c2                	cmp    %eax,%edx
f010269a:	74 19                	je     f01026b5 <mem_init+0x1665>
f010269c:	68 24 3e 10 f0       	push   $0xf0103e24
f01026a1:	68 5e 43 10 f0       	push   $0xf010435e
f01026a6:	68 b6 03 00 00       	push   $0x3b6
f01026ab:	68 38 43 10 f0       	push   $0xf0104338
f01026b0:	e8 d6 d9 ff ff       	call   f010008b <_panic>
	kern_pgdir[0] = 0;
f01026b5:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f01026bb:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01026c0:	74 19                	je     f01026db <mem_init+0x168b>
f01026c2:	68 2e 45 10 f0       	push   $0xf010452e
f01026c7:	68 5e 43 10 f0       	push   $0xf010435e
f01026cc:	68 b8 03 00 00       	push   $0x3b8
f01026d1:	68 38 43 10 f0       	push   $0xf0104338
f01026d6:	e8 b0 d9 ff ff       	call   f010008b <_panic>
	pp0->pp_ref = 0;
f01026db:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f01026e1:	83 ec 0c             	sub    $0xc,%esp
f01026e4:	53                   	push   %ebx
f01026e5:	e8 ee e6 ff ff       	call   f0100dd8 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f01026ea:	c7 04 24 0c 43 10 f0 	movl   $0xf010430c,(%esp)
f01026f1:	e8 7d 00 00 00       	call   f0102773 <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f01026f6:	83 c4 10             	add    $0x10,%esp
f01026f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01026fc:	5b                   	pop    %ebx
f01026fd:	5e                   	pop    %esi
f01026fe:	5f                   	pop    %edi
f01026ff:	5d                   	pop    %ebp
f0102700:	c3                   	ret    

f0102701 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0102701:	55                   	push   %ebp
f0102702:	89 e5                	mov    %esp,%ebp
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0102704:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102707:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f010270a:	5d                   	pop    %ebp
f010270b:	c3                   	ret    

f010270c <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f010270c:	55                   	push   %ebp
f010270d:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010270f:	ba 70 00 00 00       	mov    $0x70,%edx
f0102714:	8b 45 08             	mov    0x8(%ebp),%eax
f0102717:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0102718:	ba 71 00 00 00       	mov    $0x71,%edx
f010271d:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f010271e:	0f b6 c0             	movzbl %al,%eax
}
f0102721:	5d                   	pop    %ebp
f0102722:	c3                   	ret    

f0102723 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0102723:	55                   	push   %ebp
f0102724:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102726:	ba 70 00 00 00       	mov    $0x70,%edx
f010272b:	8b 45 08             	mov    0x8(%ebp),%eax
f010272e:	ee                   	out    %al,(%dx)
f010272f:	ba 71 00 00 00       	mov    $0x71,%edx
f0102734:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102737:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0102738:	5d                   	pop    %ebp
f0102739:	c3                   	ret    

f010273a <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f010273a:	55                   	push   %ebp
f010273b:	89 e5                	mov    %esp,%ebp
f010273d:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0102740:	ff 75 08             	pushl  0x8(%ebp)
f0102743:	e8 b8 de ff ff       	call   f0100600 <cputchar>
	*cnt++;
}
f0102748:	83 c4 10             	add    $0x10,%esp
f010274b:	c9                   	leave  
f010274c:	c3                   	ret    

f010274d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f010274d:	55                   	push   %ebp
f010274e:	89 e5                	mov    %esp,%ebp
f0102750:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0102753:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f010275a:	ff 75 0c             	pushl  0xc(%ebp)
f010275d:	ff 75 08             	pushl  0x8(%ebp)
f0102760:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0102763:	50                   	push   %eax
f0102764:	68 3a 27 10 f0       	push   $0xf010273a
f0102769:	e8 74 04 00 00       	call   f0102be2 <vprintfmt>
	return cnt;
}
f010276e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102771:	c9                   	leave  
f0102772:	c3                   	ret    

f0102773 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0102773:	55                   	push   %ebp
f0102774:	89 e5                	mov    %esp,%ebp
f0102776:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0102779:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f010277c:	50                   	push   %eax
f010277d:	ff 75 08             	pushl  0x8(%ebp)
f0102780:	e8 c8 ff ff ff       	call   f010274d <vcprintf>
	va_end(ap);

	return cnt;
}
f0102785:	c9                   	leave  
f0102786:	c3                   	ret    

f0102787 <stab_binsearch>:
											//	will exit setting left = 118, right = 554.
											//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	int type, uintptr_t addr)
{
f0102787:	55                   	push   %ebp
f0102788:	89 e5                	mov    %esp,%ebp
f010278a:	57                   	push   %edi
f010278b:	56                   	push   %esi
f010278c:	53                   	push   %ebx
f010278d:	83 ec 14             	sub    $0x14,%esp
f0102790:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0102793:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0102796:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0102799:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f010279c:	8b 1a                	mov    (%edx),%ebx
f010279e:	8b 01                	mov    (%ecx),%eax
f01027a0:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01027a3:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f01027aa:	eb 7f                	jmp    f010282b <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f01027ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01027af:	01 d8                	add    %ebx,%eax
f01027b1:	89 c6                	mov    %eax,%esi
f01027b3:	c1 ee 1f             	shr    $0x1f,%esi
f01027b6:	01 c6                	add    %eax,%esi
f01027b8:	d1 fe                	sar    %esi
f01027ba:	8d 04 76             	lea    (%esi,%esi,2),%eax
f01027bd:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01027c0:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f01027c3:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01027c5:	eb 03                	jmp    f01027ca <stab_binsearch+0x43>
			m--;
f01027c7:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01027ca:	39 c3                	cmp    %eax,%ebx
f01027cc:	7f 0d                	jg     f01027db <stab_binsearch+0x54>
f01027ce:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f01027d2:	83 ea 0c             	sub    $0xc,%edx
f01027d5:	39 f9                	cmp    %edi,%ecx
f01027d7:	75 ee                	jne    f01027c7 <stab_binsearch+0x40>
f01027d9:	eb 05                	jmp    f01027e0 <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f01027db:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f01027de:	eb 4b                	jmp    f010282b <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01027e0:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01027e3:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01027e6:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01027ea:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01027ed:	76 11                	jbe    f0102800 <stab_binsearch+0x79>
			*region_left = m;
f01027ef:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01027f2:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f01027f4:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01027f7:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01027fe:	eb 2b                	jmp    f010282b <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		}
		else if (stabs[m].n_value > addr) {
f0102800:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0102803:	73 14                	jae    f0102819 <stab_binsearch+0x92>
			*region_right = m - 1;
f0102805:	83 e8 01             	sub    $0x1,%eax
f0102808:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010280b:	8b 75 e0             	mov    -0x20(%ebp),%esi
f010280e:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0102810:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0102817:	eb 12                	jmp    f010282b <stab_binsearch+0xa4>
			r = m - 1;
		}
		else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0102819:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010281c:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f010281e:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0102822:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0102824:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f010282b:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f010282e:	0f 8e 78 ff ff ff    	jle    f01027ac <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0102834:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0102838:	75 0f                	jne    f0102849 <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f010283a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010283d:	8b 00                	mov    (%eax),%eax
f010283f:	83 e8 01             	sub    $0x1,%eax
f0102842:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0102845:	89 06                	mov    %eax,(%esi)
f0102847:	eb 2c                	jmp    f0102875 <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102849:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010284c:	8b 00                	mov    (%eax),%eax
			l > *region_left && stabs[l].n_type != type;
f010284e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0102851:	8b 0e                	mov    (%esi),%ecx
f0102853:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0102856:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0102859:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010285c:	eb 03                	jmp    f0102861 <stab_binsearch+0xda>
			l > *region_left && stabs[l].n_type != type;
			l--)
f010285e:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102861:	39 c8                	cmp    %ecx,%eax
f0102863:	7e 0b                	jle    f0102870 <stab_binsearch+0xe9>
			l > *region_left && stabs[l].n_type != type;
f0102865:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0102869:	83 ea 0c             	sub    $0xc,%edx
f010286c:	39 df                	cmp    %ebx,%edi
f010286e:	75 ee                	jne    f010285e <stab_binsearch+0xd7>
			l--)
			/* do nothing */;
		*region_left = l;
f0102870:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0102873:	89 06                	mov    %eax,(%esi)
	}
}
f0102875:	83 c4 14             	add    $0x14,%esp
f0102878:	5b                   	pop    %ebx
f0102879:	5e                   	pop    %esi
f010287a:	5f                   	pop    %edi
f010287b:	5d                   	pop    %ebp
f010287c:	c3                   	ret    

f010287d <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f010287d:	55                   	push   %ebp
f010287e:	89 e5                	mov    %esp,%ebp
f0102880:	57                   	push   %edi
f0102881:	56                   	push   %esi
f0102882:	53                   	push   %ebx
f0102883:	83 ec 3c             	sub    $0x3c,%esp
f0102886:	8b 75 08             	mov    0x8(%ebp),%esi
f0102889:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f010288c:	c7 03 32 46 10 f0    	movl   $0xf0104632,(%ebx)
	info->eip_line = 0;
f0102892:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0102899:	c7 43 08 32 46 10 f0 	movl   $0xf0104632,0x8(%ebx)
	info->eip_fn_namelen = 9;
f01028a0:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f01028a7:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f01028aa:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f01028b1:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f01028b7:	76 11                	jbe    f01028ca <debuginfo_eip+0x4d>
		// Can't search for user-level addresses yet!
		panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01028b9:	b8 ef bf 10 f0       	mov    $0xf010bfef,%eax
f01028be:	3d 51 a2 10 f0       	cmp    $0xf010a251,%eax
f01028c3:	77 1c                	ja     f01028e1 <debuginfo_eip+0x64>
f01028c5:	e9 cc 01 00 00       	jmp    f0102a96 <debuginfo_eip+0x219>
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	}
	else {
		// Can't search for user-level addresses yet!
		panic("User address");
f01028ca:	83 ec 04             	sub    $0x4,%esp
f01028cd:	68 3c 46 10 f0       	push   $0xf010463c
f01028d2:	68 82 00 00 00       	push   $0x82
f01028d7:	68 49 46 10 f0       	push   $0xf0104649
f01028dc:	e8 aa d7 ff ff       	call   f010008b <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01028e1:	80 3d ee bf 10 f0 00 	cmpb   $0x0,0xf010bfee
f01028e8:	0f 85 af 01 00 00    	jne    f0102a9d <debuginfo_eip+0x220>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01028ee:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f01028f5:	b8 50 a2 10 f0       	mov    $0xf010a250,%eax
f01028fa:	2d 68 48 10 f0       	sub    $0xf0104868,%eax
f01028ff:	c1 f8 02             	sar    $0x2,%eax
f0102902:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0102908:	83 e8 01             	sub    $0x1,%eax
f010290b:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f010290e:	83 ec 08             	sub    $0x8,%esp
f0102911:	56                   	push   %esi
f0102912:	6a 64                	push   $0x64
f0102914:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0102917:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f010291a:	b8 68 48 10 f0       	mov    $0xf0104868,%eax
f010291f:	e8 63 fe ff ff       	call   f0102787 <stab_binsearch>
	if (lfile == 0)
f0102924:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102927:	83 c4 10             	add    $0x10,%esp
f010292a:	85 c0                	test   %eax,%eax
f010292c:	0f 84 72 01 00 00    	je     f0102aa4 <debuginfo_eip+0x227>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0102932:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0102935:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102938:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f010293b:	83 ec 08             	sub    $0x8,%esp
f010293e:	56                   	push   %esi
f010293f:	6a 24                	push   $0x24
f0102941:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0102944:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0102947:	b8 68 48 10 f0       	mov    $0xf0104868,%eax
f010294c:	e8 36 fe ff ff       	call   f0102787 <stab_binsearch>

	if (lfun <= rfun) {
f0102951:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102954:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0102957:	83 c4 10             	add    $0x10,%esp
f010295a:	39 d0                	cmp    %edx,%eax
f010295c:	7f 40                	jg     f010299e <debuginfo_eip+0x121>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f010295e:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0102961:	c1 e1 02             	shl    $0x2,%ecx
f0102964:	8d b9 68 48 10 f0    	lea    -0xfefb798(%ecx),%edi
f010296a:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f010296d:	8b b9 68 48 10 f0    	mov    -0xfefb798(%ecx),%edi
f0102973:	b9 ef bf 10 f0       	mov    $0xf010bfef,%ecx
f0102978:	81 e9 51 a2 10 f0    	sub    $0xf010a251,%ecx
f010297e:	39 cf                	cmp    %ecx,%edi
f0102980:	73 09                	jae    f010298b <debuginfo_eip+0x10e>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0102982:	81 c7 51 a2 10 f0    	add    $0xf010a251,%edi
f0102988:	89 7b 08             	mov    %edi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f010298b:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f010298e:	8b 4f 08             	mov    0x8(%edi),%ecx
f0102991:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0102994:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0102996:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0102999:	89 55 d0             	mov    %edx,-0x30(%ebp)
f010299c:	eb 0f                	jmp    f01029ad <debuginfo_eip+0x130>
	}
	else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f010299e:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f01029a1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01029a4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f01029a7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01029aa:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f01029ad:	83 ec 08             	sub    $0x8,%esp
f01029b0:	6a 3a                	push   $0x3a
f01029b2:	ff 73 08             	pushl  0x8(%ebx)
f01029b5:	e8 78 08 00 00       	call   f0103232 <strfind>
f01029ba:	2b 43 08             	sub    0x8(%ebx),%eax
f01029bd:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	info->eip_file = stabstr + stabs[lfile].n_strx;
f01029c0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01029c3:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01029c6:	8b 04 85 68 48 10 f0 	mov    -0xfefb798(,%eax,4),%eax
f01029cd:	05 51 a2 10 f0       	add    $0xf010a251,%eax
f01029d2:	89 03                	mov    %eax,(%ebx)

	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f01029d4:	83 c4 08             	add    $0x8,%esp
f01029d7:	56                   	push   %esi
f01029d8:	6a 44                	push   $0x44
f01029da:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f01029dd:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f01029e0:	b8 68 48 10 f0       	mov    $0xf0104868,%eax
f01029e5:	e8 9d fd ff ff       	call   f0102787 <stab_binsearch>
	if (lline > rline) {
f01029ea:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01029ed:	8b 55 d0             	mov    -0x30(%ebp),%edx
f01029f0:	83 c4 10             	add    $0x10,%esp
f01029f3:	39 d0                	cmp    %edx,%eax
f01029f5:	0f 8f b0 00 00 00    	jg     f0102aab <debuginfo_eip+0x22e>
		return -1;
	}
	else {
		info->eip_line = stabs[rline].n_desc;
f01029fb:	8d 14 52             	lea    (%edx,%edx,2),%edx
f01029fe:	0f b7 14 95 6e 48 10 	movzwl -0xfefb792(,%edx,4),%edx
f0102a05:	f0 
f0102a06:	89 53 04             	mov    %edx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0102a09:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102a0c:	89 c2                	mov    %eax,%edx
f0102a0e:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0102a11:	8d 04 85 68 48 10 f0 	lea    -0xfefb798(,%eax,4),%eax
f0102a18:	eb 06                	jmp    f0102a20 <debuginfo_eip+0x1a3>
f0102a1a:	83 ea 01             	sub    $0x1,%edx
f0102a1d:	83 e8 0c             	sub    $0xc,%eax
f0102a20:	39 d7                	cmp    %edx,%edi
f0102a22:	7f 34                	jg     f0102a58 <debuginfo_eip+0x1db>
		&& stabs[lline].n_type != N_SOL
f0102a24:	0f b6 48 04          	movzbl 0x4(%eax),%ecx
f0102a28:	80 f9 84             	cmp    $0x84,%cl
f0102a2b:	74 0b                	je     f0102a38 <debuginfo_eip+0x1bb>
		&& (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0102a2d:	80 f9 64             	cmp    $0x64,%cl
f0102a30:	75 e8                	jne    f0102a1a <debuginfo_eip+0x19d>
f0102a32:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f0102a36:	74 e2                	je     f0102a1a <debuginfo_eip+0x19d>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0102a38:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0102a3b:	8b 14 85 68 48 10 f0 	mov    -0xfefb798(,%eax,4),%edx
f0102a42:	b8 ef bf 10 f0       	mov    $0xf010bfef,%eax
f0102a47:	2d 51 a2 10 f0       	sub    $0xf010a251,%eax
f0102a4c:	39 c2                	cmp    %eax,%edx
f0102a4e:	73 08                	jae    f0102a58 <debuginfo_eip+0x1db>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0102a50:	81 c2 51 a2 10 f0    	add    $0xf010a251,%edx
f0102a56:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0102a58:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102a5b:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
			lline < rfun && stabs[lline].n_type == N_PSYM;
			lline++)
			info->eip_fn_narg++;

	return 0;
f0102a5e:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0102a63:	39 f2                	cmp    %esi,%edx
f0102a65:	7d 50                	jge    f0102ab7 <debuginfo_eip+0x23a>
		for (lline = lfun + 1;
f0102a67:	83 c2 01             	add    $0x1,%edx
f0102a6a:	89 d0                	mov    %edx,%eax
f0102a6c:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0102a6f:	8d 14 95 68 48 10 f0 	lea    -0xfefb798(,%edx,4),%edx
f0102a76:	eb 04                	jmp    f0102a7c <debuginfo_eip+0x1ff>
			lline < rfun && stabs[lline].n_type == N_PSYM;
			lline++)
			info->eip_fn_narg++;
f0102a78:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0102a7c:	39 c6                	cmp    %eax,%esi
f0102a7e:	7e 32                	jle    f0102ab2 <debuginfo_eip+0x235>
			lline < rfun && stabs[lline].n_type == N_PSYM;
f0102a80:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0102a84:	83 c0 01             	add    $0x1,%eax
f0102a87:	83 c2 0c             	add    $0xc,%edx
f0102a8a:	80 f9 a0             	cmp    $0xa0,%cl
f0102a8d:	74 e9                	je     f0102a78 <debuginfo_eip+0x1fb>
			lline++)
			info->eip_fn_narg++;

	return 0;
f0102a8f:	b8 00 00 00 00       	mov    $0x0,%eax
f0102a94:	eb 21                	jmp    f0102ab7 <debuginfo_eip+0x23a>
		panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0102a96:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102a9b:	eb 1a                	jmp    f0102ab7 <debuginfo_eip+0x23a>
f0102a9d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102aa2:	eb 13                	jmp    f0102ab7 <debuginfo_eip+0x23a>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0102aa4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102aa9:	eb 0c                	jmp    f0102ab7 <debuginfo_eip+0x23a>
	// Your code here.
	info->eip_file = stabstr + stabs[lfile].n_strx;

	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if (lline > rline) {
		return -1;
f0102aab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102ab0:	eb 05                	jmp    f0102ab7 <debuginfo_eip+0x23a>
		for (lline = lfun + 1;
			lline < rfun && stabs[lline].n_type == N_PSYM;
			lline++)
			info->eip_fn_narg++;

	return 0;
f0102ab2:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102ab7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102aba:	5b                   	pop    %ebx
f0102abb:	5e                   	pop    %esi
f0102abc:	5f                   	pop    %edi
f0102abd:	5d                   	pop    %ebp
f0102abe:	c3                   	ret    

f0102abf <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0102abf:	55                   	push   %ebp
f0102ac0:	89 e5                	mov    %esp,%ebp
f0102ac2:	57                   	push   %edi
f0102ac3:	56                   	push   %esi
f0102ac4:	53                   	push   %ebx
f0102ac5:	83 ec 1c             	sub    $0x1c,%esp
f0102ac8:	89 c7                	mov    %eax,%edi
f0102aca:	89 d6                	mov    %edx,%esi
f0102acc:	8b 45 08             	mov    0x8(%ebp),%eax
f0102acf:	8b 55 0c             	mov    0xc(%ebp),%edx
f0102ad2:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102ad5:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0102ad8:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0102adb:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102ae0:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0102ae3:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0102ae6:	39 d3                	cmp    %edx,%ebx
f0102ae8:	72 05                	jb     f0102aef <printnum+0x30>
f0102aea:	39 45 10             	cmp    %eax,0x10(%ebp)
f0102aed:	77 45                	ja     f0102b34 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0102aef:	83 ec 0c             	sub    $0xc,%esp
f0102af2:	ff 75 18             	pushl  0x18(%ebp)
f0102af5:	8b 45 14             	mov    0x14(%ebp),%eax
f0102af8:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0102afb:	53                   	push   %ebx
f0102afc:	ff 75 10             	pushl  0x10(%ebp)
f0102aff:	83 ec 08             	sub    $0x8,%esp
f0102b02:	ff 75 e4             	pushl  -0x1c(%ebp)
f0102b05:	ff 75 e0             	pushl  -0x20(%ebp)
f0102b08:	ff 75 dc             	pushl  -0x24(%ebp)
f0102b0b:	ff 75 d8             	pushl  -0x28(%ebp)
f0102b0e:	e8 3d 09 00 00       	call   f0103450 <__udivdi3>
f0102b13:	83 c4 18             	add    $0x18,%esp
f0102b16:	52                   	push   %edx
f0102b17:	50                   	push   %eax
f0102b18:	89 f2                	mov    %esi,%edx
f0102b1a:	89 f8                	mov    %edi,%eax
f0102b1c:	e8 9e ff ff ff       	call   f0102abf <printnum>
f0102b21:	83 c4 20             	add    $0x20,%esp
f0102b24:	eb 18                	jmp    f0102b3e <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0102b26:	83 ec 08             	sub    $0x8,%esp
f0102b29:	56                   	push   %esi
f0102b2a:	ff 75 18             	pushl  0x18(%ebp)
f0102b2d:	ff d7                	call   *%edi
f0102b2f:	83 c4 10             	add    $0x10,%esp
f0102b32:	eb 03                	jmp    f0102b37 <printnum+0x78>
f0102b34:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0102b37:	83 eb 01             	sub    $0x1,%ebx
f0102b3a:	85 db                	test   %ebx,%ebx
f0102b3c:	7f e8                	jg     f0102b26 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0102b3e:	83 ec 08             	sub    $0x8,%esp
f0102b41:	56                   	push   %esi
f0102b42:	83 ec 04             	sub    $0x4,%esp
f0102b45:	ff 75 e4             	pushl  -0x1c(%ebp)
f0102b48:	ff 75 e0             	pushl  -0x20(%ebp)
f0102b4b:	ff 75 dc             	pushl  -0x24(%ebp)
f0102b4e:	ff 75 d8             	pushl  -0x28(%ebp)
f0102b51:	e8 2a 0a 00 00       	call   f0103580 <__umoddi3>
f0102b56:	83 c4 14             	add    $0x14,%esp
f0102b59:	0f be 80 57 46 10 f0 	movsbl -0xfefb9a9(%eax),%eax
f0102b60:	50                   	push   %eax
f0102b61:	ff d7                	call   *%edi
}
f0102b63:	83 c4 10             	add    $0x10,%esp
f0102b66:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102b69:	5b                   	pop    %ebx
f0102b6a:	5e                   	pop    %esi
f0102b6b:	5f                   	pop    %edi
f0102b6c:	5d                   	pop    %ebp
f0102b6d:	c3                   	ret    

f0102b6e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0102b6e:	55                   	push   %ebp
f0102b6f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0102b71:	83 fa 01             	cmp    $0x1,%edx
f0102b74:	7e 0e                	jle    f0102b84 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0102b76:	8b 10                	mov    (%eax),%edx
f0102b78:	8d 4a 08             	lea    0x8(%edx),%ecx
f0102b7b:	89 08                	mov    %ecx,(%eax)
f0102b7d:	8b 02                	mov    (%edx),%eax
f0102b7f:	8b 52 04             	mov    0x4(%edx),%edx
f0102b82:	eb 22                	jmp    f0102ba6 <getuint+0x38>
	else if (lflag)
f0102b84:	85 d2                	test   %edx,%edx
f0102b86:	74 10                	je     f0102b98 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0102b88:	8b 10                	mov    (%eax),%edx
f0102b8a:	8d 4a 04             	lea    0x4(%edx),%ecx
f0102b8d:	89 08                	mov    %ecx,(%eax)
f0102b8f:	8b 02                	mov    (%edx),%eax
f0102b91:	ba 00 00 00 00       	mov    $0x0,%edx
f0102b96:	eb 0e                	jmp    f0102ba6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0102b98:	8b 10                	mov    (%eax),%edx
f0102b9a:	8d 4a 04             	lea    0x4(%edx),%ecx
f0102b9d:	89 08                	mov    %ecx,(%eax)
f0102b9f:	8b 02                	mov    (%edx),%eax
f0102ba1:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0102ba6:	5d                   	pop    %ebp
f0102ba7:	c3                   	ret    

f0102ba8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0102ba8:	55                   	push   %ebp
f0102ba9:	89 e5                	mov    %esp,%ebp
f0102bab:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0102bae:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0102bb2:	8b 10                	mov    (%eax),%edx
f0102bb4:	3b 50 04             	cmp    0x4(%eax),%edx
f0102bb7:	73 0a                	jae    f0102bc3 <sprintputch+0x1b>
		*b->buf++ = ch;
f0102bb9:	8d 4a 01             	lea    0x1(%edx),%ecx
f0102bbc:	89 08                	mov    %ecx,(%eax)
f0102bbe:	8b 45 08             	mov    0x8(%ebp),%eax
f0102bc1:	88 02                	mov    %al,(%edx)
}
f0102bc3:	5d                   	pop    %ebp
f0102bc4:	c3                   	ret    

f0102bc5 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0102bc5:	55                   	push   %ebp
f0102bc6:	89 e5                	mov    %esp,%ebp
f0102bc8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0102bcb:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0102bce:	50                   	push   %eax
f0102bcf:	ff 75 10             	pushl  0x10(%ebp)
f0102bd2:	ff 75 0c             	pushl  0xc(%ebp)
f0102bd5:	ff 75 08             	pushl  0x8(%ebp)
f0102bd8:	e8 05 00 00 00       	call   f0102be2 <vprintfmt>
	va_end(ap);
}
f0102bdd:	83 c4 10             	add    $0x10,%esp
f0102be0:	c9                   	leave  
f0102be1:	c3                   	ret    

f0102be2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0102be2:	55                   	push   %ebp
f0102be3:	89 e5                	mov    %esp,%ebp
f0102be5:	57                   	push   %edi
f0102be6:	56                   	push   %esi
f0102be7:	53                   	push   %ebx
f0102be8:	83 ec 2c             	sub    $0x2c,%esp
f0102beb:	8b 75 08             	mov    0x8(%ebp),%esi
f0102bee:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102bf1:	8b 7d 10             	mov    0x10(%ebp),%edi
f0102bf4:	eb 12                	jmp    f0102c08 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0102bf6:	85 c0                	test   %eax,%eax
f0102bf8:	0f 84 89 03 00 00    	je     f0102f87 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
f0102bfe:	83 ec 08             	sub    $0x8,%esp
f0102c01:	53                   	push   %ebx
f0102c02:	50                   	push   %eax
f0102c03:	ff d6                	call   *%esi
f0102c05:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0102c08:	83 c7 01             	add    $0x1,%edi
f0102c0b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0102c0f:	83 f8 25             	cmp    $0x25,%eax
f0102c12:	75 e2                	jne    f0102bf6 <vprintfmt+0x14>
f0102c14:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0102c18:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0102c1f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0102c26:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0102c2d:	ba 00 00 00 00       	mov    $0x0,%edx
f0102c32:	eb 07                	jmp    f0102c3b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102c34:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0102c37:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102c3b:	8d 47 01             	lea    0x1(%edi),%eax
f0102c3e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102c41:	0f b6 07             	movzbl (%edi),%eax
f0102c44:	0f b6 c8             	movzbl %al,%ecx
f0102c47:	83 e8 23             	sub    $0x23,%eax
f0102c4a:	3c 55                	cmp    $0x55,%al
f0102c4c:	0f 87 1a 03 00 00    	ja     f0102f6c <vprintfmt+0x38a>
f0102c52:	0f b6 c0             	movzbl %al,%eax
f0102c55:	ff 24 85 e4 46 10 f0 	jmp    *-0xfefb91c(,%eax,4)
f0102c5c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0102c5f:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0102c63:	eb d6                	jmp    f0102c3b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102c65:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102c68:	b8 00 00 00 00       	mov    $0x0,%eax
f0102c6d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0102c70:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0102c73:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f0102c77:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f0102c7a:	8d 51 d0             	lea    -0x30(%ecx),%edx
f0102c7d:	83 fa 09             	cmp    $0x9,%edx
f0102c80:	77 39                	ja     f0102cbb <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0102c82:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0102c85:	eb e9                	jmp    f0102c70 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0102c87:	8b 45 14             	mov    0x14(%ebp),%eax
f0102c8a:	8d 48 04             	lea    0x4(%eax),%ecx
f0102c8d:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0102c90:	8b 00                	mov    (%eax),%eax
f0102c92:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102c95:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0102c98:	eb 27                	jmp    f0102cc1 <vprintfmt+0xdf>
f0102c9a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102c9d:	85 c0                	test   %eax,%eax
f0102c9f:	b9 00 00 00 00       	mov    $0x0,%ecx
f0102ca4:	0f 49 c8             	cmovns %eax,%ecx
f0102ca7:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102caa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102cad:	eb 8c                	jmp    f0102c3b <vprintfmt+0x59>
f0102caf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0102cb2:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0102cb9:	eb 80                	jmp    f0102c3b <vprintfmt+0x59>
f0102cbb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0102cbe:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0102cc1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0102cc5:	0f 89 70 ff ff ff    	jns    f0102c3b <vprintfmt+0x59>
				width = precision, precision = -1;
f0102ccb:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102cce:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0102cd1:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0102cd8:	e9 5e ff ff ff       	jmp    f0102c3b <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0102cdd:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102ce0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0102ce3:	e9 53 ff ff ff       	jmp    f0102c3b <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0102ce8:	8b 45 14             	mov    0x14(%ebp),%eax
f0102ceb:	8d 50 04             	lea    0x4(%eax),%edx
f0102cee:	89 55 14             	mov    %edx,0x14(%ebp)
f0102cf1:	83 ec 08             	sub    $0x8,%esp
f0102cf4:	53                   	push   %ebx
f0102cf5:	ff 30                	pushl  (%eax)
f0102cf7:	ff d6                	call   *%esi
			break;
f0102cf9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102cfc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0102cff:	e9 04 ff ff ff       	jmp    f0102c08 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0102d04:	8b 45 14             	mov    0x14(%ebp),%eax
f0102d07:	8d 50 04             	lea    0x4(%eax),%edx
f0102d0a:	89 55 14             	mov    %edx,0x14(%ebp)
f0102d0d:	8b 00                	mov    (%eax),%eax
f0102d0f:	99                   	cltd   
f0102d10:	31 d0                	xor    %edx,%eax
f0102d12:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0102d14:	83 f8 06             	cmp    $0x6,%eax
f0102d17:	7f 0b                	jg     f0102d24 <vprintfmt+0x142>
f0102d19:	8b 14 85 3c 48 10 f0 	mov    -0xfefb7c4(,%eax,4),%edx
f0102d20:	85 d2                	test   %edx,%edx
f0102d22:	75 18                	jne    f0102d3c <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f0102d24:	50                   	push   %eax
f0102d25:	68 6f 46 10 f0       	push   $0xf010466f
f0102d2a:	53                   	push   %ebx
f0102d2b:	56                   	push   %esi
f0102d2c:	e8 94 fe ff ff       	call   f0102bc5 <printfmt>
f0102d31:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102d34:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0102d37:	e9 cc fe ff ff       	jmp    f0102c08 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f0102d3c:	52                   	push   %edx
f0102d3d:	68 70 43 10 f0       	push   $0xf0104370
f0102d42:	53                   	push   %ebx
f0102d43:	56                   	push   %esi
f0102d44:	e8 7c fe ff ff       	call   f0102bc5 <printfmt>
f0102d49:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102d4c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102d4f:	e9 b4 fe ff ff       	jmp    f0102c08 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0102d54:	8b 45 14             	mov    0x14(%ebp),%eax
f0102d57:	8d 50 04             	lea    0x4(%eax),%edx
f0102d5a:	89 55 14             	mov    %edx,0x14(%ebp)
f0102d5d:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0102d5f:	85 ff                	test   %edi,%edi
f0102d61:	b8 68 46 10 f0       	mov    $0xf0104668,%eax
f0102d66:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0102d69:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0102d6d:	0f 8e 94 00 00 00    	jle    f0102e07 <vprintfmt+0x225>
f0102d73:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0102d77:	0f 84 98 00 00 00    	je     f0102e15 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
f0102d7d:	83 ec 08             	sub    $0x8,%esp
f0102d80:	ff 75 d0             	pushl  -0x30(%ebp)
f0102d83:	57                   	push   %edi
f0102d84:	e8 5f 03 00 00       	call   f01030e8 <strnlen>
f0102d89:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0102d8c:	29 c1                	sub    %eax,%ecx
f0102d8e:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0102d91:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0102d94:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0102d98:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0102d9b:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0102d9e:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0102da0:	eb 0f                	jmp    f0102db1 <vprintfmt+0x1cf>
					putch(padc, putdat);
f0102da2:	83 ec 08             	sub    $0x8,%esp
f0102da5:	53                   	push   %ebx
f0102da6:	ff 75 e0             	pushl  -0x20(%ebp)
f0102da9:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0102dab:	83 ef 01             	sub    $0x1,%edi
f0102dae:	83 c4 10             	add    $0x10,%esp
f0102db1:	85 ff                	test   %edi,%edi
f0102db3:	7f ed                	jg     f0102da2 <vprintfmt+0x1c0>
f0102db5:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102db8:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0102dbb:	85 c9                	test   %ecx,%ecx
f0102dbd:	b8 00 00 00 00       	mov    $0x0,%eax
f0102dc2:	0f 49 c1             	cmovns %ecx,%eax
f0102dc5:	29 c1                	sub    %eax,%ecx
f0102dc7:	89 75 08             	mov    %esi,0x8(%ebp)
f0102dca:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0102dcd:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0102dd0:	89 cb                	mov    %ecx,%ebx
f0102dd2:	eb 4d                	jmp    f0102e21 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0102dd4:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0102dd8:	74 1b                	je     f0102df5 <vprintfmt+0x213>
f0102dda:	0f be c0             	movsbl %al,%eax
f0102ddd:	83 e8 20             	sub    $0x20,%eax
f0102de0:	83 f8 5e             	cmp    $0x5e,%eax
f0102de3:	76 10                	jbe    f0102df5 <vprintfmt+0x213>
					putch('?', putdat);
f0102de5:	83 ec 08             	sub    $0x8,%esp
f0102de8:	ff 75 0c             	pushl  0xc(%ebp)
f0102deb:	6a 3f                	push   $0x3f
f0102ded:	ff 55 08             	call   *0x8(%ebp)
f0102df0:	83 c4 10             	add    $0x10,%esp
f0102df3:	eb 0d                	jmp    f0102e02 <vprintfmt+0x220>
				else
					putch(ch, putdat);
f0102df5:	83 ec 08             	sub    $0x8,%esp
f0102df8:	ff 75 0c             	pushl  0xc(%ebp)
f0102dfb:	52                   	push   %edx
f0102dfc:	ff 55 08             	call   *0x8(%ebp)
f0102dff:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0102e02:	83 eb 01             	sub    $0x1,%ebx
f0102e05:	eb 1a                	jmp    f0102e21 <vprintfmt+0x23f>
f0102e07:	89 75 08             	mov    %esi,0x8(%ebp)
f0102e0a:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0102e0d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0102e10:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0102e13:	eb 0c                	jmp    f0102e21 <vprintfmt+0x23f>
f0102e15:	89 75 08             	mov    %esi,0x8(%ebp)
f0102e18:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0102e1b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0102e1e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0102e21:	83 c7 01             	add    $0x1,%edi
f0102e24:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0102e28:	0f be d0             	movsbl %al,%edx
f0102e2b:	85 d2                	test   %edx,%edx
f0102e2d:	74 23                	je     f0102e52 <vprintfmt+0x270>
f0102e2f:	85 f6                	test   %esi,%esi
f0102e31:	78 a1                	js     f0102dd4 <vprintfmt+0x1f2>
f0102e33:	83 ee 01             	sub    $0x1,%esi
f0102e36:	79 9c                	jns    f0102dd4 <vprintfmt+0x1f2>
f0102e38:	89 df                	mov    %ebx,%edi
f0102e3a:	8b 75 08             	mov    0x8(%ebp),%esi
f0102e3d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102e40:	eb 18                	jmp    f0102e5a <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0102e42:	83 ec 08             	sub    $0x8,%esp
f0102e45:	53                   	push   %ebx
f0102e46:	6a 20                	push   $0x20
f0102e48:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0102e4a:	83 ef 01             	sub    $0x1,%edi
f0102e4d:	83 c4 10             	add    $0x10,%esp
f0102e50:	eb 08                	jmp    f0102e5a <vprintfmt+0x278>
f0102e52:	89 df                	mov    %ebx,%edi
f0102e54:	8b 75 08             	mov    0x8(%ebp),%esi
f0102e57:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102e5a:	85 ff                	test   %edi,%edi
f0102e5c:	7f e4                	jg     f0102e42 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102e5e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102e61:	e9 a2 fd ff ff       	jmp    f0102c08 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0102e66:	83 fa 01             	cmp    $0x1,%edx
f0102e69:	7e 16                	jle    f0102e81 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
f0102e6b:	8b 45 14             	mov    0x14(%ebp),%eax
f0102e6e:	8d 50 08             	lea    0x8(%eax),%edx
f0102e71:	89 55 14             	mov    %edx,0x14(%ebp)
f0102e74:	8b 50 04             	mov    0x4(%eax),%edx
f0102e77:	8b 00                	mov    (%eax),%eax
f0102e79:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102e7c:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0102e7f:	eb 32                	jmp    f0102eb3 <vprintfmt+0x2d1>
	else if (lflag)
f0102e81:	85 d2                	test   %edx,%edx
f0102e83:	74 18                	je     f0102e9d <vprintfmt+0x2bb>
		return va_arg(*ap, long);
f0102e85:	8b 45 14             	mov    0x14(%ebp),%eax
f0102e88:	8d 50 04             	lea    0x4(%eax),%edx
f0102e8b:	89 55 14             	mov    %edx,0x14(%ebp)
f0102e8e:	8b 00                	mov    (%eax),%eax
f0102e90:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102e93:	89 c1                	mov    %eax,%ecx
f0102e95:	c1 f9 1f             	sar    $0x1f,%ecx
f0102e98:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0102e9b:	eb 16                	jmp    f0102eb3 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
f0102e9d:	8b 45 14             	mov    0x14(%ebp),%eax
f0102ea0:	8d 50 04             	lea    0x4(%eax),%edx
f0102ea3:	89 55 14             	mov    %edx,0x14(%ebp)
f0102ea6:	8b 00                	mov    (%eax),%eax
f0102ea8:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102eab:	89 c1                	mov    %eax,%ecx
f0102ead:	c1 f9 1f             	sar    $0x1f,%ecx
f0102eb0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0102eb3:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0102eb6:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0102eb9:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0102ebe:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0102ec2:	79 74                	jns    f0102f38 <vprintfmt+0x356>
				putch('-', putdat);
f0102ec4:	83 ec 08             	sub    $0x8,%esp
f0102ec7:	53                   	push   %ebx
f0102ec8:	6a 2d                	push   $0x2d
f0102eca:	ff d6                	call   *%esi
				num = -(long long) num;
f0102ecc:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0102ecf:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102ed2:	f7 d8                	neg    %eax
f0102ed4:	83 d2 00             	adc    $0x0,%edx
f0102ed7:	f7 da                	neg    %edx
f0102ed9:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f0102edc:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0102ee1:	eb 55                	jmp    f0102f38 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0102ee3:	8d 45 14             	lea    0x14(%ebp),%eax
f0102ee6:	e8 83 fc ff ff       	call   f0102b6e <getuint>
			base = 10;
f0102eeb:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f0102ef0:	eb 46                	jmp    f0102f38 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
f0102ef2:	8d 45 14             	lea    0x14(%ebp),%eax
f0102ef5:	e8 74 fc ff ff       	call   f0102b6e <getuint>
			base = 8;
f0102efa:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
f0102eff:	eb 37                	jmp    f0102f38 <vprintfmt+0x356>
                        break;
		// pointer
		case 'p':
			putch('0', putdat);
f0102f01:	83 ec 08             	sub    $0x8,%esp
f0102f04:	53                   	push   %ebx
f0102f05:	6a 30                	push   $0x30
f0102f07:	ff d6                	call   *%esi
			putch('x', putdat);
f0102f09:	83 c4 08             	add    $0x8,%esp
f0102f0c:	53                   	push   %ebx
f0102f0d:	6a 78                	push   $0x78
f0102f0f:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0102f11:	8b 45 14             	mov    0x14(%ebp),%eax
f0102f14:	8d 50 04             	lea    0x4(%eax),%edx
f0102f17:	89 55 14             	mov    %edx,0x14(%ebp)
                        break;
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0102f1a:	8b 00                	mov    (%eax),%eax
f0102f1c:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0102f21:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0102f24:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f0102f29:	eb 0d                	jmp    f0102f38 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0102f2b:	8d 45 14             	lea    0x14(%ebp),%eax
f0102f2e:	e8 3b fc ff ff       	call   f0102b6e <getuint>
			base = 16;
f0102f33:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f0102f38:	83 ec 0c             	sub    $0xc,%esp
f0102f3b:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0102f3f:	57                   	push   %edi
f0102f40:	ff 75 e0             	pushl  -0x20(%ebp)
f0102f43:	51                   	push   %ecx
f0102f44:	52                   	push   %edx
f0102f45:	50                   	push   %eax
f0102f46:	89 da                	mov    %ebx,%edx
f0102f48:	89 f0                	mov    %esi,%eax
f0102f4a:	e8 70 fb ff ff       	call   f0102abf <printnum>
			break;
f0102f4f:	83 c4 20             	add    $0x20,%esp
f0102f52:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102f55:	e9 ae fc ff ff       	jmp    f0102c08 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0102f5a:	83 ec 08             	sub    $0x8,%esp
f0102f5d:	53                   	push   %ebx
f0102f5e:	51                   	push   %ecx
f0102f5f:	ff d6                	call   *%esi
			break;
f0102f61:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102f64:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0102f67:	e9 9c fc ff ff       	jmp    f0102c08 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0102f6c:	83 ec 08             	sub    $0x8,%esp
f0102f6f:	53                   	push   %ebx
f0102f70:	6a 25                	push   $0x25
f0102f72:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0102f74:	83 c4 10             	add    $0x10,%esp
f0102f77:	eb 03                	jmp    f0102f7c <vprintfmt+0x39a>
f0102f79:	83 ef 01             	sub    $0x1,%edi
f0102f7c:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0102f80:	75 f7                	jne    f0102f79 <vprintfmt+0x397>
f0102f82:	e9 81 fc ff ff       	jmp    f0102c08 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f0102f87:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102f8a:	5b                   	pop    %ebx
f0102f8b:	5e                   	pop    %esi
f0102f8c:	5f                   	pop    %edi
f0102f8d:	5d                   	pop    %ebp
f0102f8e:	c3                   	ret    

f0102f8f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0102f8f:	55                   	push   %ebp
f0102f90:	89 e5                	mov    %esp,%ebp
f0102f92:	83 ec 18             	sub    $0x18,%esp
f0102f95:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f98:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0102f9b:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0102f9e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0102fa2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0102fa5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0102fac:	85 c0                	test   %eax,%eax
f0102fae:	74 26                	je     f0102fd6 <vsnprintf+0x47>
f0102fb0:	85 d2                	test   %edx,%edx
f0102fb2:	7e 22                	jle    f0102fd6 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0102fb4:	ff 75 14             	pushl  0x14(%ebp)
f0102fb7:	ff 75 10             	pushl  0x10(%ebp)
f0102fba:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0102fbd:	50                   	push   %eax
f0102fbe:	68 a8 2b 10 f0       	push   $0xf0102ba8
f0102fc3:	e8 1a fc ff ff       	call   f0102be2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0102fc8:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102fcb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0102fce:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102fd1:	83 c4 10             	add    $0x10,%esp
f0102fd4:	eb 05                	jmp    f0102fdb <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0102fd6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0102fdb:	c9                   	leave  
f0102fdc:	c3                   	ret    

f0102fdd <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0102fdd:	55                   	push   %ebp
f0102fde:	89 e5                	mov    %esp,%ebp
f0102fe0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0102fe3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0102fe6:	50                   	push   %eax
f0102fe7:	ff 75 10             	pushl  0x10(%ebp)
f0102fea:	ff 75 0c             	pushl  0xc(%ebp)
f0102fed:	ff 75 08             	pushl  0x8(%ebp)
f0102ff0:	e8 9a ff ff ff       	call   f0102f8f <vsnprintf>
	va_end(ap);

	return rc;
}
f0102ff5:	c9                   	leave  
f0102ff6:	c3                   	ret    

f0102ff7 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0102ff7:	55                   	push   %ebp
f0102ff8:	89 e5                	mov    %esp,%ebp
f0102ffa:	57                   	push   %edi
f0102ffb:	56                   	push   %esi
f0102ffc:	53                   	push   %ebx
f0102ffd:	83 ec 0c             	sub    $0xc,%esp
f0103000:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0103003:	85 c0                	test   %eax,%eax
f0103005:	74 11                	je     f0103018 <readline+0x21>
		cprintf("%s", prompt);
f0103007:	83 ec 08             	sub    $0x8,%esp
f010300a:	50                   	push   %eax
f010300b:	68 70 43 10 f0       	push   $0xf0104370
f0103010:	e8 5e f7 ff ff       	call   f0102773 <cprintf>
f0103015:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0103018:	83 ec 0c             	sub    $0xc,%esp
f010301b:	6a 00                	push   $0x0
f010301d:	e8 ff d5 ff ff       	call   f0100621 <iscons>
f0103022:	89 c7                	mov    %eax,%edi
f0103024:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0103027:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f010302c:	e8 df d5 ff ff       	call   f0100610 <getchar>
f0103031:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0103033:	85 c0                	test   %eax,%eax
f0103035:	79 18                	jns    f010304f <readline+0x58>
			cprintf("read error: %e\n", c);
f0103037:	83 ec 08             	sub    $0x8,%esp
f010303a:	50                   	push   %eax
f010303b:	68 58 48 10 f0       	push   $0xf0104858
f0103040:	e8 2e f7 ff ff       	call   f0102773 <cprintf>
			return NULL;
f0103045:	83 c4 10             	add    $0x10,%esp
f0103048:	b8 00 00 00 00       	mov    $0x0,%eax
f010304d:	eb 79                	jmp    f01030c8 <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f010304f:	83 f8 08             	cmp    $0x8,%eax
f0103052:	0f 94 c2             	sete   %dl
f0103055:	83 f8 7f             	cmp    $0x7f,%eax
f0103058:	0f 94 c0             	sete   %al
f010305b:	08 c2                	or     %al,%dl
f010305d:	74 1a                	je     f0103079 <readline+0x82>
f010305f:	85 f6                	test   %esi,%esi
f0103061:	7e 16                	jle    f0103079 <readline+0x82>
			if (echoing)
f0103063:	85 ff                	test   %edi,%edi
f0103065:	74 0d                	je     f0103074 <readline+0x7d>
				cputchar('\b');
f0103067:	83 ec 0c             	sub    $0xc,%esp
f010306a:	6a 08                	push   $0x8
f010306c:	e8 8f d5 ff ff       	call   f0100600 <cputchar>
f0103071:	83 c4 10             	add    $0x10,%esp
			i--;
f0103074:	83 ee 01             	sub    $0x1,%esi
f0103077:	eb b3                	jmp    f010302c <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0103079:	83 fb 1f             	cmp    $0x1f,%ebx
f010307c:	7e 23                	jle    f01030a1 <readline+0xaa>
f010307e:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0103084:	7f 1b                	jg     f01030a1 <readline+0xaa>
			if (echoing)
f0103086:	85 ff                	test   %edi,%edi
f0103088:	74 0c                	je     f0103096 <readline+0x9f>
				cputchar(c);
f010308a:	83 ec 0c             	sub    $0xc,%esp
f010308d:	53                   	push   %ebx
f010308e:	e8 6d d5 ff ff       	call   f0100600 <cputchar>
f0103093:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0103096:	88 9e 60 65 11 f0    	mov    %bl,-0xfee9aa0(%esi)
f010309c:	8d 76 01             	lea    0x1(%esi),%esi
f010309f:	eb 8b                	jmp    f010302c <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f01030a1:	83 fb 0a             	cmp    $0xa,%ebx
f01030a4:	74 05                	je     f01030ab <readline+0xb4>
f01030a6:	83 fb 0d             	cmp    $0xd,%ebx
f01030a9:	75 81                	jne    f010302c <readline+0x35>
			if (echoing)
f01030ab:	85 ff                	test   %edi,%edi
f01030ad:	74 0d                	je     f01030bc <readline+0xc5>
				cputchar('\n');
f01030af:	83 ec 0c             	sub    $0xc,%esp
f01030b2:	6a 0a                	push   $0xa
f01030b4:	e8 47 d5 ff ff       	call   f0100600 <cputchar>
f01030b9:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f01030bc:	c6 86 60 65 11 f0 00 	movb   $0x0,-0xfee9aa0(%esi)
			return buf;
f01030c3:	b8 60 65 11 f0       	mov    $0xf0116560,%eax
		}
	}
}
f01030c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01030cb:	5b                   	pop    %ebx
f01030cc:	5e                   	pop    %esi
f01030cd:	5f                   	pop    %edi
f01030ce:	5d                   	pop    %ebp
f01030cf:	c3                   	ret    

f01030d0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01030d0:	55                   	push   %ebp
f01030d1:	89 e5                	mov    %esp,%ebp
f01030d3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01030d6:	b8 00 00 00 00       	mov    $0x0,%eax
f01030db:	eb 03                	jmp    f01030e0 <strlen+0x10>
		n++;
f01030dd:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01030e0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01030e4:	75 f7                	jne    f01030dd <strlen+0xd>
		n++;
	return n;
}
f01030e6:	5d                   	pop    %ebp
f01030e7:	c3                   	ret    

f01030e8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01030e8:	55                   	push   %ebp
f01030e9:	89 e5                	mov    %esp,%ebp
f01030eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01030ee:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01030f1:	ba 00 00 00 00       	mov    $0x0,%edx
f01030f6:	eb 03                	jmp    f01030fb <strnlen+0x13>
		n++;
f01030f8:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01030fb:	39 c2                	cmp    %eax,%edx
f01030fd:	74 08                	je     f0103107 <strnlen+0x1f>
f01030ff:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f0103103:	75 f3                	jne    f01030f8 <strnlen+0x10>
f0103105:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f0103107:	5d                   	pop    %ebp
f0103108:	c3                   	ret    

f0103109 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0103109:	55                   	push   %ebp
f010310a:	89 e5                	mov    %esp,%ebp
f010310c:	53                   	push   %ebx
f010310d:	8b 45 08             	mov    0x8(%ebp),%eax
f0103110:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0103113:	89 c2                	mov    %eax,%edx
f0103115:	83 c2 01             	add    $0x1,%edx
f0103118:	83 c1 01             	add    $0x1,%ecx
f010311b:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f010311f:	88 5a ff             	mov    %bl,-0x1(%edx)
f0103122:	84 db                	test   %bl,%bl
f0103124:	75 ef                	jne    f0103115 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0103126:	5b                   	pop    %ebx
f0103127:	5d                   	pop    %ebp
f0103128:	c3                   	ret    

f0103129 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0103129:	55                   	push   %ebp
f010312a:	89 e5                	mov    %esp,%ebp
f010312c:	53                   	push   %ebx
f010312d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0103130:	53                   	push   %ebx
f0103131:	e8 9a ff ff ff       	call   f01030d0 <strlen>
f0103136:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0103139:	ff 75 0c             	pushl  0xc(%ebp)
f010313c:	01 d8                	add    %ebx,%eax
f010313e:	50                   	push   %eax
f010313f:	e8 c5 ff ff ff       	call   f0103109 <strcpy>
	return dst;
}
f0103144:	89 d8                	mov    %ebx,%eax
f0103146:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103149:	c9                   	leave  
f010314a:	c3                   	ret    

f010314b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f010314b:	55                   	push   %ebp
f010314c:	89 e5                	mov    %esp,%ebp
f010314e:	56                   	push   %esi
f010314f:	53                   	push   %ebx
f0103150:	8b 75 08             	mov    0x8(%ebp),%esi
f0103153:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103156:	89 f3                	mov    %esi,%ebx
f0103158:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010315b:	89 f2                	mov    %esi,%edx
f010315d:	eb 0f                	jmp    f010316e <strncpy+0x23>
		*dst++ = *src;
f010315f:	83 c2 01             	add    $0x1,%edx
f0103162:	0f b6 01             	movzbl (%ecx),%eax
f0103165:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0103168:	80 39 01             	cmpb   $0x1,(%ecx)
f010316b:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010316e:	39 da                	cmp    %ebx,%edx
f0103170:	75 ed                	jne    f010315f <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0103172:	89 f0                	mov    %esi,%eax
f0103174:	5b                   	pop    %ebx
f0103175:	5e                   	pop    %esi
f0103176:	5d                   	pop    %ebp
f0103177:	c3                   	ret    

f0103178 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0103178:	55                   	push   %ebp
f0103179:	89 e5                	mov    %esp,%ebp
f010317b:	56                   	push   %esi
f010317c:	53                   	push   %ebx
f010317d:	8b 75 08             	mov    0x8(%ebp),%esi
f0103180:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103183:	8b 55 10             	mov    0x10(%ebp),%edx
f0103186:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0103188:	85 d2                	test   %edx,%edx
f010318a:	74 21                	je     f01031ad <strlcpy+0x35>
f010318c:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0103190:	89 f2                	mov    %esi,%edx
f0103192:	eb 09                	jmp    f010319d <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0103194:	83 c2 01             	add    $0x1,%edx
f0103197:	83 c1 01             	add    $0x1,%ecx
f010319a:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f010319d:	39 c2                	cmp    %eax,%edx
f010319f:	74 09                	je     f01031aa <strlcpy+0x32>
f01031a1:	0f b6 19             	movzbl (%ecx),%ebx
f01031a4:	84 db                	test   %bl,%bl
f01031a6:	75 ec                	jne    f0103194 <strlcpy+0x1c>
f01031a8:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f01031aa:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01031ad:	29 f0                	sub    %esi,%eax
}
f01031af:	5b                   	pop    %ebx
f01031b0:	5e                   	pop    %esi
f01031b1:	5d                   	pop    %ebp
f01031b2:	c3                   	ret    

f01031b3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01031b3:	55                   	push   %ebp
f01031b4:	89 e5                	mov    %esp,%ebp
f01031b6:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01031b9:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01031bc:	eb 06                	jmp    f01031c4 <strcmp+0x11>
		p++, q++;
f01031be:	83 c1 01             	add    $0x1,%ecx
f01031c1:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01031c4:	0f b6 01             	movzbl (%ecx),%eax
f01031c7:	84 c0                	test   %al,%al
f01031c9:	74 04                	je     f01031cf <strcmp+0x1c>
f01031cb:	3a 02                	cmp    (%edx),%al
f01031cd:	74 ef                	je     f01031be <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01031cf:	0f b6 c0             	movzbl %al,%eax
f01031d2:	0f b6 12             	movzbl (%edx),%edx
f01031d5:	29 d0                	sub    %edx,%eax
}
f01031d7:	5d                   	pop    %ebp
f01031d8:	c3                   	ret    

f01031d9 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01031d9:	55                   	push   %ebp
f01031da:	89 e5                	mov    %esp,%ebp
f01031dc:	53                   	push   %ebx
f01031dd:	8b 45 08             	mov    0x8(%ebp),%eax
f01031e0:	8b 55 0c             	mov    0xc(%ebp),%edx
f01031e3:	89 c3                	mov    %eax,%ebx
f01031e5:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01031e8:	eb 06                	jmp    f01031f0 <strncmp+0x17>
		n--, p++, q++;
f01031ea:	83 c0 01             	add    $0x1,%eax
f01031ed:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01031f0:	39 d8                	cmp    %ebx,%eax
f01031f2:	74 15                	je     f0103209 <strncmp+0x30>
f01031f4:	0f b6 08             	movzbl (%eax),%ecx
f01031f7:	84 c9                	test   %cl,%cl
f01031f9:	74 04                	je     f01031ff <strncmp+0x26>
f01031fb:	3a 0a                	cmp    (%edx),%cl
f01031fd:	74 eb                	je     f01031ea <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01031ff:	0f b6 00             	movzbl (%eax),%eax
f0103202:	0f b6 12             	movzbl (%edx),%edx
f0103205:	29 d0                	sub    %edx,%eax
f0103207:	eb 05                	jmp    f010320e <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0103209:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f010320e:	5b                   	pop    %ebx
f010320f:	5d                   	pop    %ebp
f0103210:	c3                   	ret    

f0103211 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0103211:	55                   	push   %ebp
f0103212:	89 e5                	mov    %esp,%ebp
f0103214:	8b 45 08             	mov    0x8(%ebp),%eax
f0103217:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f010321b:	eb 07                	jmp    f0103224 <strchr+0x13>
		if (*s == c)
f010321d:	38 ca                	cmp    %cl,%dl
f010321f:	74 0f                	je     f0103230 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0103221:	83 c0 01             	add    $0x1,%eax
f0103224:	0f b6 10             	movzbl (%eax),%edx
f0103227:	84 d2                	test   %dl,%dl
f0103229:	75 f2                	jne    f010321d <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f010322b:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103230:	5d                   	pop    %ebp
f0103231:	c3                   	ret    

f0103232 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0103232:	55                   	push   %ebp
f0103233:	89 e5                	mov    %esp,%ebp
f0103235:	8b 45 08             	mov    0x8(%ebp),%eax
f0103238:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f010323c:	eb 03                	jmp    f0103241 <strfind+0xf>
f010323e:	83 c0 01             	add    $0x1,%eax
f0103241:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0103244:	38 ca                	cmp    %cl,%dl
f0103246:	74 04                	je     f010324c <strfind+0x1a>
f0103248:	84 d2                	test   %dl,%dl
f010324a:	75 f2                	jne    f010323e <strfind+0xc>
			break;
	return (char *) s;
}
f010324c:	5d                   	pop    %ebp
f010324d:	c3                   	ret    

f010324e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f010324e:	55                   	push   %ebp
f010324f:	89 e5                	mov    %esp,%ebp
f0103251:	57                   	push   %edi
f0103252:	56                   	push   %esi
f0103253:	53                   	push   %ebx
f0103254:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103257:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f010325a:	85 c9                	test   %ecx,%ecx
f010325c:	74 36                	je     f0103294 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f010325e:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0103264:	75 28                	jne    f010328e <memset+0x40>
f0103266:	f6 c1 03             	test   $0x3,%cl
f0103269:	75 23                	jne    f010328e <memset+0x40>
		c &= 0xFF;
f010326b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f010326f:	89 d3                	mov    %edx,%ebx
f0103271:	c1 e3 08             	shl    $0x8,%ebx
f0103274:	89 d6                	mov    %edx,%esi
f0103276:	c1 e6 18             	shl    $0x18,%esi
f0103279:	89 d0                	mov    %edx,%eax
f010327b:	c1 e0 10             	shl    $0x10,%eax
f010327e:	09 f0                	or     %esi,%eax
f0103280:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f0103282:	89 d8                	mov    %ebx,%eax
f0103284:	09 d0                	or     %edx,%eax
f0103286:	c1 e9 02             	shr    $0x2,%ecx
f0103289:	fc                   	cld    
f010328a:	f3 ab                	rep stos %eax,%es:(%edi)
f010328c:	eb 06                	jmp    f0103294 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f010328e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103291:	fc                   	cld    
f0103292:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0103294:	89 f8                	mov    %edi,%eax
f0103296:	5b                   	pop    %ebx
f0103297:	5e                   	pop    %esi
f0103298:	5f                   	pop    %edi
f0103299:	5d                   	pop    %ebp
f010329a:	c3                   	ret    

f010329b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f010329b:	55                   	push   %ebp
f010329c:	89 e5                	mov    %esp,%ebp
f010329e:	57                   	push   %edi
f010329f:	56                   	push   %esi
f01032a0:	8b 45 08             	mov    0x8(%ebp),%eax
f01032a3:	8b 75 0c             	mov    0xc(%ebp),%esi
f01032a6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01032a9:	39 c6                	cmp    %eax,%esi
f01032ab:	73 35                	jae    f01032e2 <memmove+0x47>
f01032ad:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01032b0:	39 d0                	cmp    %edx,%eax
f01032b2:	73 2e                	jae    f01032e2 <memmove+0x47>
		s += n;
		d += n;
f01032b4:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01032b7:	89 d6                	mov    %edx,%esi
f01032b9:	09 fe                	or     %edi,%esi
f01032bb:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01032c1:	75 13                	jne    f01032d6 <memmove+0x3b>
f01032c3:	f6 c1 03             	test   $0x3,%cl
f01032c6:	75 0e                	jne    f01032d6 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f01032c8:	83 ef 04             	sub    $0x4,%edi
f01032cb:	8d 72 fc             	lea    -0x4(%edx),%esi
f01032ce:	c1 e9 02             	shr    $0x2,%ecx
f01032d1:	fd                   	std    
f01032d2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01032d4:	eb 09                	jmp    f01032df <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01032d6:	83 ef 01             	sub    $0x1,%edi
f01032d9:	8d 72 ff             	lea    -0x1(%edx),%esi
f01032dc:	fd                   	std    
f01032dd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01032df:	fc                   	cld    
f01032e0:	eb 1d                	jmp    f01032ff <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01032e2:	89 f2                	mov    %esi,%edx
f01032e4:	09 c2                	or     %eax,%edx
f01032e6:	f6 c2 03             	test   $0x3,%dl
f01032e9:	75 0f                	jne    f01032fa <memmove+0x5f>
f01032eb:	f6 c1 03             	test   $0x3,%cl
f01032ee:	75 0a                	jne    f01032fa <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f01032f0:	c1 e9 02             	shr    $0x2,%ecx
f01032f3:	89 c7                	mov    %eax,%edi
f01032f5:	fc                   	cld    
f01032f6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01032f8:	eb 05                	jmp    f01032ff <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01032fa:	89 c7                	mov    %eax,%edi
f01032fc:	fc                   	cld    
f01032fd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01032ff:	5e                   	pop    %esi
f0103300:	5f                   	pop    %edi
f0103301:	5d                   	pop    %ebp
f0103302:	c3                   	ret    

f0103303 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0103303:	55                   	push   %ebp
f0103304:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0103306:	ff 75 10             	pushl  0x10(%ebp)
f0103309:	ff 75 0c             	pushl  0xc(%ebp)
f010330c:	ff 75 08             	pushl  0x8(%ebp)
f010330f:	e8 87 ff ff ff       	call   f010329b <memmove>
}
f0103314:	c9                   	leave  
f0103315:	c3                   	ret    

f0103316 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0103316:	55                   	push   %ebp
f0103317:	89 e5                	mov    %esp,%ebp
f0103319:	56                   	push   %esi
f010331a:	53                   	push   %ebx
f010331b:	8b 45 08             	mov    0x8(%ebp),%eax
f010331e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103321:	89 c6                	mov    %eax,%esi
f0103323:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0103326:	eb 1a                	jmp    f0103342 <memcmp+0x2c>
		if (*s1 != *s2)
f0103328:	0f b6 08             	movzbl (%eax),%ecx
f010332b:	0f b6 1a             	movzbl (%edx),%ebx
f010332e:	38 d9                	cmp    %bl,%cl
f0103330:	74 0a                	je     f010333c <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f0103332:	0f b6 c1             	movzbl %cl,%eax
f0103335:	0f b6 db             	movzbl %bl,%ebx
f0103338:	29 d8                	sub    %ebx,%eax
f010333a:	eb 0f                	jmp    f010334b <memcmp+0x35>
		s1++, s2++;
f010333c:	83 c0 01             	add    $0x1,%eax
f010333f:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0103342:	39 f0                	cmp    %esi,%eax
f0103344:	75 e2                	jne    f0103328 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0103346:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010334b:	5b                   	pop    %ebx
f010334c:	5e                   	pop    %esi
f010334d:	5d                   	pop    %ebp
f010334e:	c3                   	ret    

f010334f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f010334f:	55                   	push   %ebp
f0103350:	89 e5                	mov    %esp,%ebp
f0103352:	53                   	push   %ebx
f0103353:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0103356:	89 c1                	mov    %eax,%ecx
f0103358:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f010335b:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f010335f:	eb 0a                	jmp    f010336b <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f0103361:	0f b6 10             	movzbl (%eax),%edx
f0103364:	39 da                	cmp    %ebx,%edx
f0103366:	74 07                	je     f010336f <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0103368:	83 c0 01             	add    $0x1,%eax
f010336b:	39 c8                	cmp    %ecx,%eax
f010336d:	72 f2                	jb     f0103361 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f010336f:	5b                   	pop    %ebx
f0103370:	5d                   	pop    %ebp
f0103371:	c3                   	ret    

f0103372 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0103372:	55                   	push   %ebp
f0103373:	89 e5                	mov    %esp,%ebp
f0103375:	57                   	push   %edi
f0103376:	56                   	push   %esi
f0103377:	53                   	push   %ebx
f0103378:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010337b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010337e:	eb 03                	jmp    f0103383 <strtol+0x11>
		s++;
f0103380:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0103383:	0f b6 01             	movzbl (%ecx),%eax
f0103386:	3c 20                	cmp    $0x20,%al
f0103388:	74 f6                	je     f0103380 <strtol+0xe>
f010338a:	3c 09                	cmp    $0x9,%al
f010338c:	74 f2                	je     f0103380 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f010338e:	3c 2b                	cmp    $0x2b,%al
f0103390:	75 0a                	jne    f010339c <strtol+0x2a>
		s++;
f0103392:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0103395:	bf 00 00 00 00       	mov    $0x0,%edi
f010339a:	eb 11                	jmp    f01033ad <strtol+0x3b>
f010339c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01033a1:	3c 2d                	cmp    $0x2d,%al
f01033a3:	75 08                	jne    f01033ad <strtol+0x3b>
		s++, neg = 1;
f01033a5:	83 c1 01             	add    $0x1,%ecx
f01033a8:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01033ad:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f01033b3:	75 15                	jne    f01033ca <strtol+0x58>
f01033b5:	80 39 30             	cmpb   $0x30,(%ecx)
f01033b8:	75 10                	jne    f01033ca <strtol+0x58>
f01033ba:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01033be:	75 7c                	jne    f010343c <strtol+0xca>
		s += 2, base = 16;
f01033c0:	83 c1 02             	add    $0x2,%ecx
f01033c3:	bb 10 00 00 00       	mov    $0x10,%ebx
f01033c8:	eb 16                	jmp    f01033e0 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f01033ca:	85 db                	test   %ebx,%ebx
f01033cc:	75 12                	jne    f01033e0 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01033ce:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01033d3:	80 39 30             	cmpb   $0x30,(%ecx)
f01033d6:	75 08                	jne    f01033e0 <strtol+0x6e>
		s++, base = 8;
f01033d8:	83 c1 01             	add    $0x1,%ecx
f01033db:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f01033e0:	b8 00 00 00 00       	mov    $0x0,%eax
f01033e5:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01033e8:	0f b6 11             	movzbl (%ecx),%edx
f01033eb:	8d 72 d0             	lea    -0x30(%edx),%esi
f01033ee:	89 f3                	mov    %esi,%ebx
f01033f0:	80 fb 09             	cmp    $0x9,%bl
f01033f3:	77 08                	ja     f01033fd <strtol+0x8b>
			dig = *s - '0';
f01033f5:	0f be d2             	movsbl %dl,%edx
f01033f8:	83 ea 30             	sub    $0x30,%edx
f01033fb:	eb 22                	jmp    f010341f <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f01033fd:	8d 72 9f             	lea    -0x61(%edx),%esi
f0103400:	89 f3                	mov    %esi,%ebx
f0103402:	80 fb 19             	cmp    $0x19,%bl
f0103405:	77 08                	ja     f010340f <strtol+0x9d>
			dig = *s - 'a' + 10;
f0103407:	0f be d2             	movsbl %dl,%edx
f010340a:	83 ea 57             	sub    $0x57,%edx
f010340d:	eb 10                	jmp    f010341f <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f010340f:	8d 72 bf             	lea    -0x41(%edx),%esi
f0103412:	89 f3                	mov    %esi,%ebx
f0103414:	80 fb 19             	cmp    $0x19,%bl
f0103417:	77 16                	ja     f010342f <strtol+0xbd>
			dig = *s - 'A' + 10;
f0103419:	0f be d2             	movsbl %dl,%edx
f010341c:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f010341f:	3b 55 10             	cmp    0x10(%ebp),%edx
f0103422:	7d 0b                	jge    f010342f <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f0103424:	83 c1 01             	add    $0x1,%ecx
f0103427:	0f af 45 10          	imul   0x10(%ebp),%eax
f010342b:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f010342d:	eb b9                	jmp    f01033e8 <strtol+0x76>

	if (endptr)
f010342f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0103433:	74 0d                	je     f0103442 <strtol+0xd0>
		*endptr = (char *) s;
f0103435:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103438:	89 0e                	mov    %ecx,(%esi)
f010343a:	eb 06                	jmp    f0103442 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f010343c:	85 db                	test   %ebx,%ebx
f010343e:	74 98                	je     f01033d8 <strtol+0x66>
f0103440:	eb 9e                	jmp    f01033e0 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f0103442:	89 c2                	mov    %eax,%edx
f0103444:	f7 da                	neg    %edx
f0103446:	85 ff                	test   %edi,%edi
f0103448:	0f 45 c2             	cmovne %edx,%eax
}
f010344b:	5b                   	pop    %ebx
f010344c:	5e                   	pop    %esi
f010344d:	5f                   	pop    %edi
f010344e:	5d                   	pop    %ebp
f010344f:	c3                   	ret    

f0103450 <__udivdi3>:
f0103450:	55                   	push   %ebp
f0103451:	57                   	push   %edi
f0103452:	56                   	push   %esi
f0103453:	53                   	push   %ebx
f0103454:	83 ec 1c             	sub    $0x1c,%esp
f0103457:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f010345b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f010345f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f0103463:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0103467:	85 f6                	test   %esi,%esi
f0103469:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010346d:	89 ca                	mov    %ecx,%edx
f010346f:	89 f8                	mov    %edi,%eax
f0103471:	75 3d                	jne    f01034b0 <__udivdi3+0x60>
f0103473:	39 cf                	cmp    %ecx,%edi
f0103475:	0f 87 c5 00 00 00    	ja     f0103540 <__udivdi3+0xf0>
f010347b:	85 ff                	test   %edi,%edi
f010347d:	89 fd                	mov    %edi,%ebp
f010347f:	75 0b                	jne    f010348c <__udivdi3+0x3c>
f0103481:	b8 01 00 00 00       	mov    $0x1,%eax
f0103486:	31 d2                	xor    %edx,%edx
f0103488:	f7 f7                	div    %edi
f010348a:	89 c5                	mov    %eax,%ebp
f010348c:	89 c8                	mov    %ecx,%eax
f010348e:	31 d2                	xor    %edx,%edx
f0103490:	f7 f5                	div    %ebp
f0103492:	89 c1                	mov    %eax,%ecx
f0103494:	89 d8                	mov    %ebx,%eax
f0103496:	89 cf                	mov    %ecx,%edi
f0103498:	f7 f5                	div    %ebp
f010349a:	89 c3                	mov    %eax,%ebx
f010349c:	89 d8                	mov    %ebx,%eax
f010349e:	89 fa                	mov    %edi,%edx
f01034a0:	83 c4 1c             	add    $0x1c,%esp
f01034a3:	5b                   	pop    %ebx
f01034a4:	5e                   	pop    %esi
f01034a5:	5f                   	pop    %edi
f01034a6:	5d                   	pop    %ebp
f01034a7:	c3                   	ret    
f01034a8:	90                   	nop
f01034a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01034b0:	39 ce                	cmp    %ecx,%esi
f01034b2:	77 74                	ja     f0103528 <__udivdi3+0xd8>
f01034b4:	0f bd fe             	bsr    %esi,%edi
f01034b7:	83 f7 1f             	xor    $0x1f,%edi
f01034ba:	0f 84 98 00 00 00    	je     f0103558 <__udivdi3+0x108>
f01034c0:	bb 20 00 00 00       	mov    $0x20,%ebx
f01034c5:	89 f9                	mov    %edi,%ecx
f01034c7:	89 c5                	mov    %eax,%ebp
f01034c9:	29 fb                	sub    %edi,%ebx
f01034cb:	d3 e6                	shl    %cl,%esi
f01034cd:	89 d9                	mov    %ebx,%ecx
f01034cf:	d3 ed                	shr    %cl,%ebp
f01034d1:	89 f9                	mov    %edi,%ecx
f01034d3:	d3 e0                	shl    %cl,%eax
f01034d5:	09 ee                	or     %ebp,%esi
f01034d7:	89 d9                	mov    %ebx,%ecx
f01034d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01034dd:	89 d5                	mov    %edx,%ebp
f01034df:	8b 44 24 08          	mov    0x8(%esp),%eax
f01034e3:	d3 ed                	shr    %cl,%ebp
f01034e5:	89 f9                	mov    %edi,%ecx
f01034e7:	d3 e2                	shl    %cl,%edx
f01034e9:	89 d9                	mov    %ebx,%ecx
f01034eb:	d3 e8                	shr    %cl,%eax
f01034ed:	09 c2                	or     %eax,%edx
f01034ef:	89 d0                	mov    %edx,%eax
f01034f1:	89 ea                	mov    %ebp,%edx
f01034f3:	f7 f6                	div    %esi
f01034f5:	89 d5                	mov    %edx,%ebp
f01034f7:	89 c3                	mov    %eax,%ebx
f01034f9:	f7 64 24 0c          	mull   0xc(%esp)
f01034fd:	39 d5                	cmp    %edx,%ebp
f01034ff:	72 10                	jb     f0103511 <__udivdi3+0xc1>
f0103501:	8b 74 24 08          	mov    0x8(%esp),%esi
f0103505:	89 f9                	mov    %edi,%ecx
f0103507:	d3 e6                	shl    %cl,%esi
f0103509:	39 c6                	cmp    %eax,%esi
f010350b:	73 07                	jae    f0103514 <__udivdi3+0xc4>
f010350d:	39 d5                	cmp    %edx,%ebp
f010350f:	75 03                	jne    f0103514 <__udivdi3+0xc4>
f0103511:	83 eb 01             	sub    $0x1,%ebx
f0103514:	31 ff                	xor    %edi,%edi
f0103516:	89 d8                	mov    %ebx,%eax
f0103518:	89 fa                	mov    %edi,%edx
f010351a:	83 c4 1c             	add    $0x1c,%esp
f010351d:	5b                   	pop    %ebx
f010351e:	5e                   	pop    %esi
f010351f:	5f                   	pop    %edi
f0103520:	5d                   	pop    %ebp
f0103521:	c3                   	ret    
f0103522:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0103528:	31 ff                	xor    %edi,%edi
f010352a:	31 db                	xor    %ebx,%ebx
f010352c:	89 d8                	mov    %ebx,%eax
f010352e:	89 fa                	mov    %edi,%edx
f0103530:	83 c4 1c             	add    $0x1c,%esp
f0103533:	5b                   	pop    %ebx
f0103534:	5e                   	pop    %esi
f0103535:	5f                   	pop    %edi
f0103536:	5d                   	pop    %ebp
f0103537:	c3                   	ret    
f0103538:	90                   	nop
f0103539:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0103540:	89 d8                	mov    %ebx,%eax
f0103542:	f7 f7                	div    %edi
f0103544:	31 ff                	xor    %edi,%edi
f0103546:	89 c3                	mov    %eax,%ebx
f0103548:	89 d8                	mov    %ebx,%eax
f010354a:	89 fa                	mov    %edi,%edx
f010354c:	83 c4 1c             	add    $0x1c,%esp
f010354f:	5b                   	pop    %ebx
f0103550:	5e                   	pop    %esi
f0103551:	5f                   	pop    %edi
f0103552:	5d                   	pop    %ebp
f0103553:	c3                   	ret    
f0103554:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0103558:	39 ce                	cmp    %ecx,%esi
f010355a:	72 0c                	jb     f0103568 <__udivdi3+0x118>
f010355c:	31 db                	xor    %ebx,%ebx
f010355e:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0103562:	0f 87 34 ff ff ff    	ja     f010349c <__udivdi3+0x4c>
f0103568:	bb 01 00 00 00       	mov    $0x1,%ebx
f010356d:	e9 2a ff ff ff       	jmp    f010349c <__udivdi3+0x4c>
f0103572:	66 90                	xchg   %ax,%ax
f0103574:	66 90                	xchg   %ax,%ax
f0103576:	66 90                	xchg   %ax,%ax
f0103578:	66 90                	xchg   %ax,%ax
f010357a:	66 90                	xchg   %ax,%ax
f010357c:	66 90                	xchg   %ax,%ax
f010357e:	66 90                	xchg   %ax,%ax

f0103580 <__umoddi3>:
f0103580:	55                   	push   %ebp
f0103581:	57                   	push   %edi
f0103582:	56                   	push   %esi
f0103583:	53                   	push   %ebx
f0103584:	83 ec 1c             	sub    $0x1c,%esp
f0103587:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010358b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f010358f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0103593:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0103597:	85 d2                	test   %edx,%edx
f0103599:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010359d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01035a1:	89 f3                	mov    %esi,%ebx
f01035a3:	89 3c 24             	mov    %edi,(%esp)
f01035a6:	89 74 24 04          	mov    %esi,0x4(%esp)
f01035aa:	75 1c                	jne    f01035c8 <__umoddi3+0x48>
f01035ac:	39 f7                	cmp    %esi,%edi
f01035ae:	76 50                	jbe    f0103600 <__umoddi3+0x80>
f01035b0:	89 c8                	mov    %ecx,%eax
f01035b2:	89 f2                	mov    %esi,%edx
f01035b4:	f7 f7                	div    %edi
f01035b6:	89 d0                	mov    %edx,%eax
f01035b8:	31 d2                	xor    %edx,%edx
f01035ba:	83 c4 1c             	add    $0x1c,%esp
f01035bd:	5b                   	pop    %ebx
f01035be:	5e                   	pop    %esi
f01035bf:	5f                   	pop    %edi
f01035c0:	5d                   	pop    %ebp
f01035c1:	c3                   	ret    
f01035c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01035c8:	39 f2                	cmp    %esi,%edx
f01035ca:	89 d0                	mov    %edx,%eax
f01035cc:	77 52                	ja     f0103620 <__umoddi3+0xa0>
f01035ce:	0f bd ea             	bsr    %edx,%ebp
f01035d1:	83 f5 1f             	xor    $0x1f,%ebp
f01035d4:	75 5a                	jne    f0103630 <__umoddi3+0xb0>
f01035d6:	3b 54 24 04          	cmp    0x4(%esp),%edx
f01035da:	0f 82 e0 00 00 00    	jb     f01036c0 <__umoddi3+0x140>
f01035e0:	39 0c 24             	cmp    %ecx,(%esp)
f01035e3:	0f 86 d7 00 00 00    	jbe    f01036c0 <__umoddi3+0x140>
f01035e9:	8b 44 24 08          	mov    0x8(%esp),%eax
f01035ed:	8b 54 24 04          	mov    0x4(%esp),%edx
f01035f1:	83 c4 1c             	add    $0x1c,%esp
f01035f4:	5b                   	pop    %ebx
f01035f5:	5e                   	pop    %esi
f01035f6:	5f                   	pop    %edi
f01035f7:	5d                   	pop    %ebp
f01035f8:	c3                   	ret    
f01035f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0103600:	85 ff                	test   %edi,%edi
f0103602:	89 fd                	mov    %edi,%ebp
f0103604:	75 0b                	jne    f0103611 <__umoddi3+0x91>
f0103606:	b8 01 00 00 00       	mov    $0x1,%eax
f010360b:	31 d2                	xor    %edx,%edx
f010360d:	f7 f7                	div    %edi
f010360f:	89 c5                	mov    %eax,%ebp
f0103611:	89 f0                	mov    %esi,%eax
f0103613:	31 d2                	xor    %edx,%edx
f0103615:	f7 f5                	div    %ebp
f0103617:	89 c8                	mov    %ecx,%eax
f0103619:	f7 f5                	div    %ebp
f010361b:	89 d0                	mov    %edx,%eax
f010361d:	eb 99                	jmp    f01035b8 <__umoddi3+0x38>
f010361f:	90                   	nop
f0103620:	89 c8                	mov    %ecx,%eax
f0103622:	89 f2                	mov    %esi,%edx
f0103624:	83 c4 1c             	add    $0x1c,%esp
f0103627:	5b                   	pop    %ebx
f0103628:	5e                   	pop    %esi
f0103629:	5f                   	pop    %edi
f010362a:	5d                   	pop    %ebp
f010362b:	c3                   	ret    
f010362c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0103630:	8b 34 24             	mov    (%esp),%esi
f0103633:	bf 20 00 00 00       	mov    $0x20,%edi
f0103638:	89 e9                	mov    %ebp,%ecx
f010363a:	29 ef                	sub    %ebp,%edi
f010363c:	d3 e0                	shl    %cl,%eax
f010363e:	89 f9                	mov    %edi,%ecx
f0103640:	89 f2                	mov    %esi,%edx
f0103642:	d3 ea                	shr    %cl,%edx
f0103644:	89 e9                	mov    %ebp,%ecx
f0103646:	09 c2                	or     %eax,%edx
f0103648:	89 d8                	mov    %ebx,%eax
f010364a:	89 14 24             	mov    %edx,(%esp)
f010364d:	89 f2                	mov    %esi,%edx
f010364f:	d3 e2                	shl    %cl,%edx
f0103651:	89 f9                	mov    %edi,%ecx
f0103653:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103657:	8b 54 24 0c          	mov    0xc(%esp),%edx
f010365b:	d3 e8                	shr    %cl,%eax
f010365d:	89 e9                	mov    %ebp,%ecx
f010365f:	89 c6                	mov    %eax,%esi
f0103661:	d3 e3                	shl    %cl,%ebx
f0103663:	89 f9                	mov    %edi,%ecx
f0103665:	89 d0                	mov    %edx,%eax
f0103667:	d3 e8                	shr    %cl,%eax
f0103669:	89 e9                	mov    %ebp,%ecx
f010366b:	09 d8                	or     %ebx,%eax
f010366d:	89 d3                	mov    %edx,%ebx
f010366f:	89 f2                	mov    %esi,%edx
f0103671:	f7 34 24             	divl   (%esp)
f0103674:	89 d6                	mov    %edx,%esi
f0103676:	d3 e3                	shl    %cl,%ebx
f0103678:	f7 64 24 04          	mull   0x4(%esp)
f010367c:	39 d6                	cmp    %edx,%esi
f010367e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103682:	89 d1                	mov    %edx,%ecx
f0103684:	89 c3                	mov    %eax,%ebx
f0103686:	72 08                	jb     f0103690 <__umoddi3+0x110>
f0103688:	75 11                	jne    f010369b <__umoddi3+0x11b>
f010368a:	39 44 24 08          	cmp    %eax,0x8(%esp)
f010368e:	73 0b                	jae    f010369b <__umoddi3+0x11b>
f0103690:	2b 44 24 04          	sub    0x4(%esp),%eax
f0103694:	1b 14 24             	sbb    (%esp),%edx
f0103697:	89 d1                	mov    %edx,%ecx
f0103699:	89 c3                	mov    %eax,%ebx
f010369b:	8b 54 24 08          	mov    0x8(%esp),%edx
f010369f:	29 da                	sub    %ebx,%edx
f01036a1:	19 ce                	sbb    %ecx,%esi
f01036a3:	89 f9                	mov    %edi,%ecx
f01036a5:	89 f0                	mov    %esi,%eax
f01036a7:	d3 e0                	shl    %cl,%eax
f01036a9:	89 e9                	mov    %ebp,%ecx
f01036ab:	d3 ea                	shr    %cl,%edx
f01036ad:	89 e9                	mov    %ebp,%ecx
f01036af:	d3 ee                	shr    %cl,%esi
f01036b1:	09 d0                	or     %edx,%eax
f01036b3:	89 f2                	mov    %esi,%edx
f01036b5:	83 c4 1c             	add    $0x1c,%esp
f01036b8:	5b                   	pop    %ebx
f01036b9:	5e                   	pop    %esi
f01036ba:	5f                   	pop    %edi
f01036bb:	5d                   	pop    %ebp
f01036bc:	c3                   	ret    
f01036bd:	8d 76 00             	lea    0x0(%esi),%esi
f01036c0:	29 f9                	sub    %edi,%ecx
f01036c2:	19 d6                	sbb    %edx,%esi
f01036c4:	89 74 24 04          	mov    %esi,0x4(%esp)
f01036c8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01036cc:	e9 18 ff ff ff       	jmp    f01035e9 <__umoddi3+0x69>
