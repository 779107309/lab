
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
f0100015:	b8 00 00 11 00       	mov    $0x110000,%eax
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
f0100034:	bc 00 00 11 f0       	mov    $0xf0110000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 56 00 00 00       	call   f0100094 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:


// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	53                   	push   %ebx
f0100044:	83 ec 0c             	sub    $0xc,%esp
f0100047:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("entering test_backtrace %d\n", x);
f010004a:	53                   	push   %ebx
f010004b:	68 e0 18 10 f0       	push   $0xf01018e0
f0100050:	e8 3c 09 00 00       	call   f0100991 <cprintf>
  if (x > 0)
f0100055:	83 c4 10             	add    $0x10,%esp
f0100058:	85 db                	test   %ebx,%ebx
f010005a:	7e 11                	jle    f010006d <test_backtrace+0x2d>
    test_backtrace(x-1);
f010005c:	83 ec 0c             	sub    $0xc,%esp
f010005f:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0100062:	50                   	push   %eax
f0100063:	e8 d8 ff ff ff       	call   f0100040 <test_backtrace>
f0100068:	83 c4 10             	add    $0x10,%esp
f010006b:	eb 11                	jmp    f010007e <test_backtrace+0x3e>
  else
    mon_backtrace(0, 0, 0);
f010006d:	83 ec 04             	sub    $0x4,%esp
f0100070:	6a 00                	push   $0x0
f0100072:	6a 00                	push   $0x0
f0100074:	6a 00                	push   $0x0
f0100076:	e8 f3 06 00 00       	call   f010076e <mon_backtrace>
f010007b:	83 c4 10             	add    $0x10,%esp
  cprintf("leaving test_backtrace %d\n", x);
f010007e:	83 ec 08             	sub    $0x8,%esp
f0100081:	53                   	push   %ebx
f0100082:	68 fc 18 10 f0       	push   $0xf01018fc
f0100087:	e8 05 09 00 00       	call   f0100991 <cprintf>
}
f010008c:	83 c4 10             	add    $0x10,%esp
f010008f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100092:	c9                   	leave  
f0100093:	c3                   	ret    

f0100094 <i386_init>:

void
i386_init(void)
{
f0100094:	55                   	push   %ebp
f0100095:	89 e5                	mov    %esp,%ebp
f0100097:	83 ec 0c             	sub    $0xc,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f010009a:	b8 44 29 11 f0       	mov    $0xf0112944,%eax
f010009f:	2d 00 23 11 f0       	sub    $0xf0112300,%eax
f01000a4:	50                   	push   %eax
f01000a5:	6a 00                	push   $0x0
f01000a7:	68 00 23 11 f0       	push   $0xf0112300
f01000ac:	e8 89 13 00 00       	call   f010143a <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000b1:	e8 9d 04 00 00       	call   f0100553 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000b6:	83 c4 08             	add    $0x8,%esp
f01000b9:	68 ac 1a 00 00       	push   $0x1aac
f01000be:	68 17 19 10 f0       	push   $0xf0101917
f01000c3:	e8 c9 08 00 00       	call   f0100991 <cprintf>

	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f01000c8:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f01000cf:	e8 6c ff ff ff       	call   f0100040 <test_backtrace>
f01000d4:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f01000d7:	83 ec 0c             	sub    $0xc,%esp
f01000da:	6a 00                	push   $0x0
f01000dc:	e8 30 07 00 00       	call   f0100811 <monitor>
f01000e1:	83 c4 10             	add    $0x10,%esp
f01000e4:	eb f1                	jmp    f01000d7 <i386_init+0x43>

f01000e6 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000e6:	55                   	push   %ebp
f01000e7:	89 e5                	mov    %esp,%ebp
f01000e9:	56                   	push   %esi
f01000ea:	53                   	push   %ebx
f01000eb:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f01000ee:	83 3d 40 29 11 f0 00 	cmpl   $0x0,0xf0112940
f01000f5:	75 37                	jne    f010012e <_panic+0x48>
		goto dead;
	panicstr = fmt;
f01000f7:	89 35 40 29 11 f0    	mov    %esi,0xf0112940

	// Be extra sure that the machine is in as reasonable state
	asm volatile("cli; cld");
f01000fd:	fa                   	cli    
f01000fe:	fc                   	cld    

	va_start(ap, fmt);
f01000ff:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f0100102:	83 ec 04             	sub    $0x4,%esp
f0100105:	ff 75 0c             	pushl  0xc(%ebp)
f0100108:	ff 75 08             	pushl  0x8(%ebp)
f010010b:	68 32 19 10 f0       	push   $0xf0101932
f0100110:	e8 7c 08 00 00       	call   f0100991 <cprintf>
	vcprintf(fmt, ap);
f0100115:	83 c4 08             	add    $0x8,%esp
f0100118:	53                   	push   %ebx
f0100119:	56                   	push   %esi
f010011a:	e8 4c 08 00 00       	call   f010096b <vcprintf>
	cprintf("\n");
f010011f:	c7 04 24 6e 19 10 f0 	movl   $0xf010196e,(%esp)
f0100126:	e8 66 08 00 00       	call   f0100991 <cprintf>
	va_end(ap);
f010012b:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010012e:	83 ec 0c             	sub    $0xc,%esp
f0100131:	6a 00                	push   $0x0
f0100133:	e8 d9 06 00 00       	call   f0100811 <monitor>
f0100138:	83 c4 10             	add    $0x10,%esp
f010013b:	eb f1                	jmp    f010012e <_panic+0x48>

f010013d <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010013d:	55                   	push   %ebp
f010013e:	89 e5                	mov    %esp,%ebp
f0100140:	53                   	push   %ebx
f0100141:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100144:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100147:	ff 75 0c             	pushl  0xc(%ebp)
f010014a:	ff 75 08             	pushl  0x8(%ebp)
f010014d:	68 4a 19 10 f0       	push   $0xf010194a
f0100152:	e8 3a 08 00 00       	call   f0100991 <cprintf>
	vcprintf(fmt, ap);
f0100157:	83 c4 08             	add    $0x8,%esp
f010015a:	53                   	push   %ebx
f010015b:	ff 75 10             	pushl  0x10(%ebp)
f010015e:	e8 08 08 00 00       	call   f010096b <vcprintf>
	cprintf("\n");
f0100163:	c7 04 24 6e 19 10 f0 	movl   $0xf010196e,(%esp)
f010016a:	e8 22 08 00 00       	call   f0100991 <cprintf>
	va_end(ap);
}
f010016f:	83 c4 10             	add    $0x10,%esp
f0100172:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100175:	c9                   	leave  
f0100176:	c3                   	ret    

f0100177 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100177:	55                   	push   %ebp
f0100178:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010017a:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010017f:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100180:	a8 01                	test   $0x1,%al
f0100182:	74 0b                	je     f010018f <serial_proc_data+0x18>
f0100184:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100189:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010018a:	0f b6 c0             	movzbl %al,%eax
f010018d:	eb 05                	jmp    f0100194 <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f010018f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100194:	5d                   	pop    %ebp
f0100195:	c3                   	ret    

f0100196 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100196:	55                   	push   %ebp
f0100197:	89 e5                	mov    %esp,%ebp
f0100199:	53                   	push   %ebx
f010019a:	83 ec 04             	sub    $0x4,%esp
f010019d:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f010019f:	eb 2b                	jmp    f01001cc <cons_intr+0x36>
		if (c == 0)
f01001a1:	85 c0                	test   %eax,%eax
f01001a3:	74 27                	je     f01001cc <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f01001a5:	8b 0d 24 25 11 f0    	mov    0xf0112524,%ecx
f01001ab:	8d 51 01             	lea    0x1(%ecx),%edx
f01001ae:	89 15 24 25 11 f0    	mov    %edx,0xf0112524
f01001b4:	88 81 20 23 11 f0    	mov    %al,-0xfeedce0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01001ba:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01001c0:	75 0a                	jne    f01001cc <cons_intr+0x36>
			cons.wpos = 0;
f01001c2:	c7 05 24 25 11 f0 00 	movl   $0x0,0xf0112524
f01001c9:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01001cc:	ff d3                	call   *%ebx
f01001ce:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001d1:	75 ce                	jne    f01001a1 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01001d3:	83 c4 04             	add    $0x4,%esp
f01001d6:	5b                   	pop    %ebx
f01001d7:	5d                   	pop    %ebp
f01001d8:	c3                   	ret    

f01001d9 <kbd_proc_data>:
f01001d9:	ba 64 00 00 00       	mov    $0x64,%edx
f01001de:	ec                   	in     (%dx),%al
	int c;
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
f01001df:	a8 01                	test   $0x1,%al
f01001e1:	0f 84 f8 00 00 00    	je     f01002df <kbd_proc_data+0x106>
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
f01001e7:	a8 20                	test   $0x20,%al
f01001e9:	0f 85 f6 00 00 00    	jne    f01002e5 <kbd_proc_data+0x10c>
f01001ef:	ba 60 00 00 00       	mov    $0x60,%edx
f01001f4:	ec                   	in     (%dx),%al
f01001f5:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01001f7:	3c e0                	cmp    $0xe0,%al
f01001f9:	75 0d                	jne    f0100208 <kbd_proc_data+0x2f>
		// E0 escape character
		shift |= E0ESC;
f01001fb:	83 0d 00 23 11 f0 40 	orl    $0x40,0xf0112300
		return 0;
f0100202:	b8 00 00 00 00       	mov    $0x0,%eax
f0100207:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100208:	55                   	push   %ebp
f0100209:	89 e5                	mov    %esp,%ebp
f010020b:	53                   	push   %ebx
f010020c:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f010020f:	84 c0                	test   %al,%al
f0100211:	79 36                	jns    f0100249 <kbd_proc_data+0x70>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100213:	8b 0d 00 23 11 f0    	mov    0xf0112300,%ecx
f0100219:	89 cb                	mov    %ecx,%ebx
f010021b:	83 e3 40             	and    $0x40,%ebx
f010021e:	83 e0 7f             	and    $0x7f,%eax
f0100221:	85 db                	test   %ebx,%ebx
f0100223:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100226:	0f b6 d2             	movzbl %dl,%edx
f0100229:	0f b6 82 c0 1a 10 f0 	movzbl -0xfefe540(%edx),%eax
f0100230:	83 c8 40             	or     $0x40,%eax
f0100233:	0f b6 c0             	movzbl %al,%eax
f0100236:	f7 d0                	not    %eax
f0100238:	21 c8                	and    %ecx,%eax
f010023a:	a3 00 23 11 f0       	mov    %eax,0xf0112300
		return 0;
f010023f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100244:	e9 a4 00 00 00       	jmp    f01002ed <kbd_proc_data+0x114>
	} else if (shift & E0ESC) {
f0100249:	8b 0d 00 23 11 f0    	mov    0xf0112300,%ecx
f010024f:	f6 c1 40             	test   $0x40,%cl
f0100252:	74 0e                	je     f0100262 <kbd_proc_data+0x89>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100254:	83 c8 80             	or     $0xffffff80,%eax
f0100257:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100259:	83 e1 bf             	and    $0xffffffbf,%ecx
f010025c:	89 0d 00 23 11 f0    	mov    %ecx,0xf0112300
	}

	shift |= shiftcode[data];
f0100262:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f0100265:	0f b6 82 c0 1a 10 f0 	movzbl -0xfefe540(%edx),%eax
f010026c:	0b 05 00 23 11 f0    	or     0xf0112300,%eax
f0100272:	0f b6 8a c0 19 10 f0 	movzbl -0xfefe640(%edx),%ecx
f0100279:	31 c8                	xor    %ecx,%eax
f010027b:	a3 00 23 11 f0       	mov    %eax,0xf0112300

	c = charcode[shift & (CTL | SHIFT)][data];
f0100280:	89 c1                	mov    %eax,%ecx
f0100282:	83 e1 03             	and    $0x3,%ecx
f0100285:	8b 0c 8d a0 19 10 f0 	mov    -0xfefe660(,%ecx,4),%ecx
f010028c:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100290:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100293:	a8 08                	test   $0x8,%al
f0100295:	74 1b                	je     f01002b2 <kbd_proc_data+0xd9>
		if ('a' <= c && c <= 'z')
f0100297:	89 da                	mov    %ebx,%edx
f0100299:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f010029c:	83 f9 19             	cmp    $0x19,%ecx
f010029f:	77 05                	ja     f01002a6 <kbd_proc_data+0xcd>
			c += 'A' - 'a';
f01002a1:	83 eb 20             	sub    $0x20,%ebx
f01002a4:	eb 0c                	jmp    f01002b2 <kbd_proc_data+0xd9>
		else if ('A' <= c && c <= 'Z')
f01002a6:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01002a9:	8d 4b 20             	lea    0x20(%ebx),%ecx
f01002ac:	83 fa 19             	cmp    $0x19,%edx
f01002af:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01002b2:	f7 d0                	not    %eax
f01002b4:	a8 06                	test   $0x6,%al
f01002b6:	75 33                	jne    f01002eb <kbd_proc_data+0x112>
f01002b8:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01002be:	75 2b                	jne    f01002eb <kbd_proc_data+0x112>
		cprintf("Rebooting!\n");
f01002c0:	83 ec 0c             	sub    $0xc,%esp
f01002c3:	68 64 19 10 f0       	push   $0xf0101964
f01002c8:	e8 c4 06 00 00       	call   f0100991 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002cd:	ba 92 00 00 00       	mov    $0x92,%edx
f01002d2:	b8 03 00 00 00       	mov    $0x3,%eax
f01002d7:	ee                   	out    %al,(%dx)
f01002d8:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01002db:	89 d8                	mov    %ebx,%eax
f01002dd:	eb 0e                	jmp    f01002ed <kbd_proc_data+0x114>
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
f01002df:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01002e4:	c3                   	ret    
	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
		return -1;
f01002e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01002ea:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01002eb:	89 d8                	mov    %ebx,%eax
}
f01002ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01002f0:	c9                   	leave  
f01002f1:	c3                   	ret    

f01002f2 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01002f2:	55                   	push   %ebp
f01002f3:	89 e5                	mov    %esp,%ebp
f01002f5:	57                   	push   %edi
f01002f6:	56                   	push   %esi
f01002f7:	53                   	push   %ebx
f01002f8:	83 ec 1c             	sub    $0x1c,%esp
f01002fb:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01002fd:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100302:	be fd 03 00 00       	mov    $0x3fd,%esi
f0100307:	b9 84 00 00 00       	mov    $0x84,%ecx
f010030c:	eb 09                	jmp    f0100317 <cons_putc+0x25>
f010030e:	89 ca                	mov    %ecx,%edx
f0100310:	ec                   	in     (%dx),%al
f0100311:	ec                   	in     (%dx),%al
f0100312:	ec                   	in     (%dx),%al
f0100313:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f0100314:	83 c3 01             	add    $0x1,%ebx
f0100317:	89 f2                	mov    %esi,%edx
f0100319:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010031a:	a8 20                	test   $0x20,%al
f010031c:	75 08                	jne    f0100326 <cons_putc+0x34>
f010031e:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100324:	7e e8                	jle    f010030e <cons_putc+0x1c>
f0100326:	89 f8                	mov    %edi,%eax
f0100328:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010032b:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100330:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100331:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100336:	be 79 03 00 00       	mov    $0x379,%esi
f010033b:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100340:	eb 09                	jmp    f010034b <cons_putc+0x59>
f0100342:	89 ca                	mov    %ecx,%edx
f0100344:	ec                   	in     (%dx),%al
f0100345:	ec                   	in     (%dx),%al
f0100346:	ec                   	in     (%dx),%al
f0100347:	ec                   	in     (%dx),%al
f0100348:	83 c3 01             	add    $0x1,%ebx
f010034b:	89 f2                	mov    %esi,%edx
f010034d:	ec                   	in     (%dx),%al
f010034e:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100354:	7f 04                	jg     f010035a <cons_putc+0x68>
f0100356:	84 c0                	test   %al,%al
f0100358:	79 e8                	jns    f0100342 <cons_putc+0x50>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010035a:	ba 78 03 00 00       	mov    $0x378,%edx
f010035f:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100363:	ee                   	out    %al,(%dx)
f0100364:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100369:	b8 0d 00 00 00       	mov    $0xd,%eax
f010036e:	ee                   	out    %al,(%dx)
f010036f:	b8 08 00 00 00       	mov    $0x8,%eax
f0100374:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100375:	89 fa                	mov    %edi,%edx
f0100377:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f010037d:	89 f8                	mov    %edi,%eax
f010037f:	80 cc 07             	or     $0x7,%ah
f0100382:	85 d2                	test   %edx,%edx
f0100384:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f0100387:	89 f8                	mov    %edi,%eax
f0100389:	0f b6 c0             	movzbl %al,%eax
f010038c:	83 f8 09             	cmp    $0x9,%eax
f010038f:	74 74                	je     f0100405 <cons_putc+0x113>
f0100391:	83 f8 09             	cmp    $0x9,%eax
f0100394:	7f 0a                	jg     f01003a0 <cons_putc+0xae>
f0100396:	83 f8 08             	cmp    $0x8,%eax
f0100399:	74 14                	je     f01003af <cons_putc+0xbd>
f010039b:	e9 99 00 00 00       	jmp    f0100439 <cons_putc+0x147>
f01003a0:	83 f8 0a             	cmp    $0xa,%eax
f01003a3:	74 3a                	je     f01003df <cons_putc+0xed>
f01003a5:	83 f8 0d             	cmp    $0xd,%eax
f01003a8:	74 3d                	je     f01003e7 <cons_putc+0xf5>
f01003aa:	e9 8a 00 00 00       	jmp    f0100439 <cons_putc+0x147>
	case '\b':
		if (crt_pos > 0) {
f01003af:	0f b7 05 28 25 11 f0 	movzwl 0xf0112528,%eax
f01003b6:	66 85 c0             	test   %ax,%ax
f01003b9:	0f 84 e6 00 00 00    	je     f01004a5 <cons_putc+0x1b3>
			crt_pos--;
f01003bf:	83 e8 01             	sub    $0x1,%eax
f01003c2:	66 a3 28 25 11 f0    	mov    %ax,0xf0112528
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01003c8:	0f b7 c0             	movzwl %ax,%eax
f01003cb:	66 81 e7 00 ff       	and    $0xff00,%di
f01003d0:	83 cf 20             	or     $0x20,%edi
f01003d3:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f01003d9:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01003dd:	eb 78                	jmp    f0100457 <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01003df:	66 83 05 28 25 11 f0 	addw   $0x50,0xf0112528
f01003e6:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01003e7:	0f b7 05 28 25 11 f0 	movzwl 0xf0112528,%eax
f01003ee:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01003f4:	c1 e8 16             	shr    $0x16,%eax
f01003f7:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01003fa:	c1 e0 04             	shl    $0x4,%eax
f01003fd:	66 a3 28 25 11 f0    	mov    %ax,0xf0112528
f0100403:	eb 52                	jmp    f0100457 <cons_putc+0x165>
		break;
	case '\t':
		cons_putc(' ');
f0100405:	b8 20 00 00 00       	mov    $0x20,%eax
f010040a:	e8 e3 fe ff ff       	call   f01002f2 <cons_putc>
		cons_putc(' ');
f010040f:	b8 20 00 00 00       	mov    $0x20,%eax
f0100414:	e8 d9 fe ff ff       	call   f01002f2 <cons_putc>
		cons_putc(' ');
f0100419:	b8 20 00 00 00       	mov    $0x20,%eax
f010041e:	e8 cf fe ff ff       	call   f01002f2 <cons_putc>
		cons_putc(' ');
f0100423:	b8 20 00 00 00       	mov    $0x20,%eax
f0100428:	e8 c5 fe ff ff       	call   f01002f2 <cons_putc>
		cons_putc(' ');
f010042d:	b8 20 00 00 00       	mov    $0x20,%eax
f0100432:	e8 bb fe ff ff       	call   f01002f2 <cons_putc>
f0100437:	eb 1e                	jmp    f0100457 <cons_putc+0x165>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100439:	0f b7 05 28 25 11 f0 	movzwl 0xf0112528,%eax
f0100440:	8d 50 01             	lea    0x1(%eax),%edx
f0100443:	66 89 15 28 25 11 f0 	mov    %dx,0xf0112528
f010044a:	0f b7 c0             	movzwl %ax,%eax
f010044d:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f0100453:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100457:	66 81 3d 28 25 11 f0 	cmpw   $0x7cf,0xf0112528
f010045e:	cf 07 
f0100460:	76 43                	jbe    f01004a5 <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100462:	a1 2c 25 11 f0       	mov    0xf011252c,%eax
f0100467:	83 ec 04             	sub    $0x4,%esp
f010046a:	68 00 0f 00 00       	push   $0xf00
f010046f:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100475:	52                   	push   %edx
f0100476:	50                   	push   %eax
f0100477:	e8 0b 10 00 00       	call   f0101487 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f010047c:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f0100482:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100488:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f010048e:	83 c4 10             	add    $0x10,%esp
f0100491:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100496:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100499:	39 d0                	cmp    %edx,%eax
f010049b:	75 f4                	jne    f0100491 <cons_putc+0x19f>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f010049d:	66 83 2d 28 25 11 f0 	subw   $0x50,0xf0112528
f01004a4:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01004a5:	8b 0d 30 25 11 f0    	mov    0xf0112530,%ecx
f01004ab:	b8 0e 00 00 00       	mov    $0xe,%eax
f01004b0:	89 ca                	mov    %ecx,%edx
f01004b2:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004b3:	0f b7 1d 28 25 11 f0 	movzwl 0xf0112528,%ebx
f01004ba:	8d 71 01             	lea    0x1(%ecx),%esi
f01004bd:	89 d8                	mov    %ebx,%eax
f01004bf:	66 c1 e8 08          	shr    $0x8,%ax
f01004c3:	89 f2                	mov    %esi,%edx
f01004c5:	ee                   	out    %al,(%dx)
f01004c6:	b8 0f 00 00 00       	mov    $0xf,%eax
f01004cb:	89 ca                	mov    %ecx,%edx
f01004cd:	ee                   	out    %al,(%dx)
f01004ce:	89 d8                	mov    %ebx,%eax
f01004d0:	89 f2                	mov    %esi,%edx
f01004d2:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01004d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01004d6:	5b                   	pop    %ebx
f01004d7:	5e                   	pop    %esi
f01004d8:	5f                   	pop    %edi
f01004d9:	5d                   	pop    %ebp
f01004da:	c3                   	ret    

f01004db <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f01004db:	80 3d 34 25 11 f0 00 	cmpb   $0x0,0xf0112534
f01004e2:	74 11                	je     f01004f5 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01004e4:	55                   	push   %ebp
f01004e5:	89 e5                	mov    %esp,%ebp
f01004e7:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f01004ea:	b8 77 01 10 f0       	mov    $0xf0100177,%eax
f01004ef:	e8 a2 fc ff ff       	call   f0100196 <cons_intr>
}
f01004f4:	c9                   	leave  
f01004f5:	f3 c3                	repz ret 

f01004f7 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01004f7:	55                   	push   %ebp
f01004f8:	89 e5                	mov    %esp,%ebp
f01004fa:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01004fd:	b8 d9 01 10 f0       	mov    $0xf01001d9,%eax
f0100502:	e8 8f fc ff ff       	call   f0100196 <cons_intr>
}
f0100507:	c9                   	leave  
f0100508:	c3                   	ret    

f0100509 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100509:	55                   	push   %ebp
f010050a:	89 e5                	mov    %esp,%ebp
f010050c:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f010050f:	e8 c7 ff ff ff       	call   f01004db <serial_intr>
	kbd_intr();
f0100514:	e8 de ff ff ff       	call   f01004f7 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100519:	a1 20 25 11 f0       	mov    0xf0112520,%eax
f010051e:	3b 05 24 25 11 f0    	cmp    0xf0112524,%eax
f0100524:	74 26                	je     f010054c <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100526:	8d 50 01             	lea    0x1(%eax),%edx
f0100529:	89 15 20 25 11 f0    	mov    %edx,0xf0112520
f010052f:	0f b6 88 20 23 11 f0 	movzbl -0xfeedce0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f0100536:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f0100538:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010053e:	75 11                	jne    f0100551 <cons_getc+0x48>
			cons.rpos = 0;
f0100540:	c7 05 20 25 11 f0 00 	movl   $0x0,0xf0112520
f0100547:	00 00 00 
f010054a:	eb 05                	jmp    f0100551 <cons_getc+0x48>
		return c;
	}
	return 0;
f010054c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100551:	c9                   	leave  
f0100552:	c3                   	ret    

f0100553 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100553:	55                   	push   %ebp
f0100554:	89 e5                	mov    %esp,%ebp
f0100556:	57                   	push   %edi
f0100557:	56                   	push   %esi
f0100558:	53                   	push   %ebx
f0100559:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f010055c:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100563:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010056a:	5a a5 
	if (*cp != 0xA55A) {
f010056c:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100573:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100577:	74 11                	je     f010058a <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100579:	c7 05 30 25 11 f0 b4 	movl   $0x3b4,0xf0112530
f0100580:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100583:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100588:	eb 16                	jmp    f01005a0 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f010058a:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100591:	c7 05 30 25 11 f0 d4 	movl   $0x3d4,0xf0112530
f0100598:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010059b:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f01005a0:	8b 3d 30 25 11 f0    	mov    0xf0112530,%edi
f01005a6:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005ab:	89 fa                	mov    %edi,%edx
f01005ad:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01005ae:	8d 5f 01             	lea    0x1(%edi),%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005b1:	89 da                	mov    %ebx,%edx
f01005b3:	ec                   	in     (%dx),%al
f01005b4:	0f b6 c8             	movzbl %al,%ecx
f01005b7:	c1 e1 08             	shl    $0x8,%ecx
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005ba:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005bf:	89 fa                	mov    %edi,%edx
f01005c1:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005c2:	89 da                	mov    %ebx,%edx
f01005c4:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01005c5:	89 35 2c 25 11 f0    	mov    %esi,0xf011252c
	crt_pos = pos;
f01005cb:	0f b6 c0             	movzbl %al,%eax
f01005ce:	09 c8                	or     %ecx,%eax
f01005d0:	66 a3 28 25 11 f0    	mov    %ax,0xf0112528
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005d6:	be fa 03 00 00       	mov    $0x3fa,%esi
f01005db:	b8 00 00 00 00       	mov    $0x0,%eax
f01005e0:	89 f2                	mov    %esi,%edx
f01005e2:	ee                   	out    %al,(%dx)
f01005e3:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01005e8:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01005ed:	ee                   	out    %al,(%dx)
f01005ee:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f01005f3:	b8 0c 00 00 00       	mov    $0xc,%eax
f01005f8:	89 da                	mov    %ebx,%edx
f01005fa:	ee                   	out    %al,(%dx)
f01005fb:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100600:	b8 00 00 00 00       	mov    $0x0,%eax
f0100605:	ee                   	out    %al,(%dx)
f0100606:	ba fb 03 00 00       	mov    $0x3fb,%edx
f010060b:	b8 03 00 00 00       	mov    $0x3,%eax
f0100610:	ee                   	out    %al,(%dx)
f0100611:	ba fc 03 00 00       	mov    $0x3fc,%edx
f0100616:	b8 00 00 00 00       	mov    $0x0,%eax
f010061b:	ee                   	out    %al,(%dx)
f010061c:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100621:	b8 01 00 00 00       	mov    $0x1,%eax
f0100626:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100627:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010062c:	ec                   	in     (%dx),%al
f010062d:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f010062f:	3c ff                	cmp    $0xff,%al
f0100631:	0f 95 05 34 25 11 f0 	setne  0xf0112534
f0100638:	89 f2                	mov    %esi,%edx
f010063a:	ec                   	in     (%dx),%al
f010063b:	89 da                	mov    %ebx,%edx
f010063d:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f010063e:	80 f9 ff             	cmp    $0xff,%cl
f0100641:	75 10                	jne    f0100653 <cons_init+0x100>
		cprintf("Serial port does not exist!\n");
f0100643:	83 ec 0c             	sub    $0xc,%esp
f0100646:	68 70 19 10 f0       	push   $0xf0101970
f010064b:	e8 41 03 00 00       	call   f0100991 <cprintf>
f0100650:	83 c4 10             	add    $0x10,%esp
}
f0100653:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100656:	5b                   	pop    %ebx
f0100657:	5e                   	pop    %esi
f0100658:	5f                   	pop    %edi
f0100659:	5d                   	pop    %ebp
f010065a:	c3                   	ret    

f010065b <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010065b:	55                   	push   %ebp
f010065c:	89 e5                	mov    %esp,%ebp
f010065e:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100661:	8b 45 08             	mov    0x8(%ebp),%eax
f0100664:	e8 89 fc ff ff       	call   f01002f2 <cons_putc>
}
f0100669:	c9                   	leave  
f010066a:	c3                   	ret    

f010066b <getchar>:

int
getchar(void)
{
f010066b:	55                   	push   %ebp
f010066c:	89 e5                	mov    %esp,%ebp
f010066e:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100671:	e8 93 fe ff ff       	call   f0100509 <cons_getc>
f0100676:	85 c0                	test   %eax,%eax
f0100678:	74 f7                	je     f0100671 <getchar+0x6>
		/* do nothing */;
	return c;
}
f010067a:	c9                   	leave  
f010067b:	c3                   	ret    

f010067c <iscons>:

int
iscons(int fdnum)
{
f010067c:	55                   	push   %ebp
f010067d:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f010067f:	b8 01 00 00 00       	mov    $0x1,%eax
f0100684:	5d                   	pop    %ebp
f0100685:	c3                   	ret    

f0100686 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100686:	55                   	push   %ebp
f0100687:	89 e5                	mov    %esp,%ebp
f0100689:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f010068c:	68 c0 1b 10 f0       	push   $0xf0101bc0
f0100691:	68 de 1b 10 f0       	push   $0xf0101bde
f0100696:	68 e3 1b 10 f0       	push   $0xf0101be3
f010069b:	e8 f1 02 00 00       	call   f0100991 <cprintf>
f01006a0:	83 c4 0c             	add    $0xc,%esp
f01006a3:	68 8c 1c 10 f0       	push   $0xf0101c8c
f01006a8:	68 ec 1b 10 f0       	push   $0xf0101bec
f01006ad:	68 e3 1b 10 f0       	push   $0xf0101be3
f01006b2:	e8 da 02 00 00       	call   f0100991 <cprintf>
	return 0;
}
f01006b7:	b8 00 00 00 00       	mov    $0x0,%eax
f01006bc:	c9                   	leave  
f01006bd:	c3                   	ret    

f01006be <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01006be:	55                   	push   %ebp
f01006bf:	89 e5                	mov    %esp,%ebp
f01006c1:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01006c4:	68 f5 1b 10 f0       	push   $0xf0101bf5
f01006c9:	e8 c3 02 00 00       	call   f0100991 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01006ce:	83 c4 08             	add    $0x8,%esp
f01006d1:	68 0c 00 10 00       	push   $0x10000c
f01006d6:	68 b4 1c 10 f0       	push   $0xf0101cb4
f01006db:	e8 b1 02 00 00       	call   f0100991 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01006e0:	83 c4 0c             	add    $0xc,%esp
f01006e3:	68 0c 00 10 00       	push   $0x10000c
f01006e8:	68 0c 00 10 f0       	push   $0xf010000c
f01006ed:	68 dc 1c 10 f0       	push   $0xf0101cdc
f01006f2:	e8 9a 02 00 00       	call   f0100991 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01006f7:	83 c4 0c             	add    $0xc,%esp
f01006fa:	68 c1 18 10 00       	push   $0x1018c1
f01006ff:	68 c1 18 10 f0       	push   $0xf01018c1
f0100704:	68 00 1d 10 f0       	push   $0xf0101d00
f0100709:	e8 83 02 00 00       	call   f0100991 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010070e:	83 c4 0c             	add    $0xc,%esp
f0100711:	68 00 23 11 00       	push   $0x112300
f0100716:	68 00 23 11 f0       	push   $0xf0112300
f010071b:	68 24 1d 10 f0       	push   $0xf0101d24
f0100720:	e8 6c 02 00 00       	call   f0100991 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100725:	83 c4 0c             	add    $0xc,%esp
f0100728:	68 44 29 11 00       	push   $0x112944
f010072d:	68 44 29 11 f0       	push   $0xf0112944
f0100732:	68 48 1d 10 f0       	push   $0xf0101d48
f0100737:	e8 55 02 00 00       	call   f0100991 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f010073c:	b8 43 2d 11 f0       	mov    $0xf0112d43,%eax
f0100741:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100746:	83 c4 08             	add    $0x8,%esp
f0100749:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f010074e:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100754:	85 c0                	test   %eax,%eax
f0100756:	0f 48 c2             	cmovs  %edx,%eax
f0100759:	c1 f8 0a             	sar    $0xa,%eax
f010075c:	50                   	push   %eax
f010075d:	68 6c 1d 10 f0       	push   $0xf0101d6c
f0100762:	e8 2a 02 00 00       	call   f0100991 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f0100767:	b8 00 00 00 00       	mov    $0x0,%eax
f010076c:	c9                   	leave  
f010076d:	c3                   	ret    

f010076e <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010076e:	55                   	push   %ebp
f010076f:	89 e5                	mov    %esp,%ebp
f0100771:	57                   	push   %edi
f0100772:	56                   	push   %esi
f0100773:	53                   	push   %ebx
f0100774:	83 ec 48             	sub    $0x48,%esp

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0100777:	89 ee                	mov    %ebp,%esi
  uint32_t* ebp = (uint32_t*) read_ebp();
  cprintf("Stack backtrace:\n");
f0100779:	68 0e 1c 10 f0       	push   $0xf0101c0e
f010077e:	e8 0e 02 00 00       	call   f0100991 <cprintf>
  while (ebp) {
f0100783:	83 c4 10             	add    $0x10,%esp
f0100786:	eb 78                	jmp    f0100800 <mon_backtrace+0x92>
   uint32_t eip = ebp[1];
f0100788:	8b 46 04             	mov    0x4(%esi),%eax
f010078b:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    cprintf("ebp %x  eip %x  args", ebp, eip);
f010078e:	83 ec 04             	sub    $0x4,%esp
f0100791:	50                   	push   %eax
f0100792:	56                   	push   %esi
f0100793:	68 20 1c 10 f0       	push   $0xf0101c20
f0100798:	e8 f4 01 00 00       	call   f0100991 <cprintf>
f010079d:	8d 5e 08             	lea    0x8(%esi),%ebx
f01007a0:	8d 7e 1c             	lea    0x1c(%esi),%edi
f01007a3:	83 c4 10             	add    $0x10,%esp
    int i;
    for (i = 2; i <= 6; ++i)
      cprintf(" %08.x", ebp[i]);
f01007a6:	83 ec 08             	sub    $0x8,%esp
f01007a9:	ff 33                	pushl  (%ebx)
f01007ab:	68 35 1c 10 f0       	push   $0xf0101c35
f01007b0:	e8 dc 01 00 00       	call   f0100991 <cprintf>
f01007b5:	83 c3 04             	add    $0x4,%ebx
  cprintf("Stack backtrace:\n");
  while (ebp) {
   uint32_t eip = ebp[1];
    cprintf("ebp %x  eip %x  args", ebp, eip);
    int i;
    for (i = 2; i <= 6; ++i)
f01007b8:	83 c4 10             	add    $0x10,%esp
f01007bb:	39 fb                	cmp    %edi,%ebx
f01007bd:	75 e7                	jne    f01007a6 <mon_backtrace+0x38>
      cprintf(" %08.x", ebp[i]);
    cprintf("\n");
f01007bf:	83 ec 0c             	sub    $0xc,%esp
f01007c2:	68 6e 19 10 f0       	push   $0xf010196e
f01007c7:	e8 c5 01 00 00       	call   f0100991 <cprintf>
    struct Eipdebuginfo info;
    debuginfo_eip(eip, &info);
f01007cc:	83 c4 08             	add    $0x8,%esp
f01007cf:	8d 45 d0             	lea    -0x30(%ebp),%eax
f01007d2:	50                   	push   %eax
f01007d3:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f01007d6:	57                   	push   %edi
f01007d7:	e8 bf 02 00 00       	call   f0100a9b <debuginfo_eip>
    cprintf("\t%s:%d: %.*s+%d\n", 
f01007dc:	83 c4 08             	add    $0x8,%esp
f01007df:	89 f8                	mov    %edi,%eax
f01007e1:	2b 45 e0             	sub    -0x20(%ebp),%eax
f01007e4:	50                   	push   %eax
f01007e5:	ff 75 d8             	pushl  -0x28(%ebp)
f01007e8:	ff 75 dc             	pushl  -0x24(%ebp)
f01007eb:	ff 75 d4             	pushl  -0x2c(%ebp)
f01007ee:	ff 75 d0             	pushl  -0x30(%ebp)
f01007f1:	68 3c 1c 10 f0       	push   $0xf0101c3c
f01007f6:	e8 96 01 00 00       	call   f0100991 <cprintf>
      info.eip_file, info.eip_line,
      info.eip_fn_namelen, info.eip_fn_name,
      eip-info.eip_fn_addr);
//         kern/monitor.c:143: monitor+106
    ebp = (uint32_t*) *ebp;
f01007fb:	8b 36                	mov    (%esi),%esi
f01007fd:	83 c4 20             	add    $0x20,%esp
int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
  uint32_t* ebp = (uint32_t*) read_ebp();
  cprintf("Stack backtrace:\n");
  while (ebp) {
f0100800:	85 f6                	test   %esi,%esi
f0100802:	75 84                	jne    f0100788 <mon_backtrace+0x1a>
//         kern/monitor.c:143: monitor+106
    ebp = (uint32_t*) *ebp;
  //ebp f0109e58  eip f0100a62  args 00000001 f0109e80 f0109e98 f0100ed2 00000031
  }
  return 0;
}
f0100804:	b8 00 00 00 00       	mov    $0x0,%eax
f0100809:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010080c:	5b                   	pop    %ebx
f010080d:	5e                   	pop    %esi
f010080e:	5f                   	pop    %edi
f010080f:	5d                   	pop    %ebp
f0100810:	c3                   	ret    

f0100811 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100811:	55                   	push   %ebp
f0100812:	89 e5                	mov    %esp,%ebp
f0100814:	57                   	push   %edi
f0100815:	56                   	push   %esi
f0100816:	53                   	push   %ebx
f0100817:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f010081a:	68 98 1d 10 f0       	push   $0xf0101d98
f010081f:	e8 6d 01 00 00       	call   f0100991 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100824:	c7 04 24 bc 1d 10 f0 	movl   $0xf0101dbc,(%esp)
f010082b:	e8 61 01 00 00       	call   f0100991 <cprintf>
f0100830:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f0100833:	83 ec 0c             	sub    $0xc,%esp
f0100836:	68 4d 1c 10 f0       	push   $0xf0101c4d
f010083b:	e8 a3 09 00 00       	call   f01011e3 <readline>
f0100840:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100842:	83 c4 10             	add    $0x10,%esp
f0100845:	85 c0                	test   %eax,%eax
f0100847:	74 ea                	je     f0100833 <monitor+0x22>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100849:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100850:	be 00 00 00 00       	mov    $0x0,%esi
f0100855:	eb 0a                	jmp    f0100861 <monitor+0x50>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100857:	c6 03 00             	movb   $0x0,(%ebx)
f010085a:	89 f7                	mov    %esi,%edi
f010085c:	8d 5b 01             	lea    0x1(%ebx),%ebx
f010085f:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100861:	0f b6 03             	movzbl (%ebx),%eax
f0100864:	84 c0                	test   %al,%al
f0100866:	74 63                	je     f01008cb <monitor+0xba>
f0100868:	83 ec 08             	sub    $0x8,%esp
f010086b:	0f be c0             	movsbl %al,%eax
f010086e:	50                   	push   %eax
f010086f:	68 51 1c 10 f0       	push   $0xf0101c51
f0100874:	e8 84 0b 00 00       	call   f01013fd <strchr>
f0100879:	83 c4 10             	add    $0x10,%esp
f010087c:	85 c0                	test   %eax,%eax
f010087e:	75 d7                	jne    f0100857 <monitor+0x46>
			*buf++ = 0;
		if (*buf == 0)
f0100880:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100883:	74 46                	je     f01008cb <monitor+0xba>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100885:	83 fe 0f             	cmp    $0xf,%esi
f0100888:	75 14                	jne    f010089e <monitor+0x8d>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f010088a:	83 ec 08             	sub    $0x8,%esp
f010088d:	6a 10                	push   $0x10
f010088f:	68 56 1c 10 f0       	push   $0xf0101c56
f0100894:	e8 f8 00 00 00       	call   f0100991 <cprintf>
f0100899:	83 c4 10             	add    $0x10,%esp
f010089c:	eb 95                	jmp    f0100833 <monitor+0x22>
			return 0;
		}
		argv[argc++] = buf;
f010089e:	8d 7e 01             	lea    0x1(%esi),%edi
f01008a1:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f01008a5:	eb 03                	jmp    f01008aa <monitor+0x99>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f01008a7:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f01008aa:	0f b6 03             	movzbl (%ebx),%eax
f01008ad:	84 c0                	test   %al,%al
f01008af:	74 ae                	je     f010085f <monitor+0x4e>
f01008b1:	83 ec 08             	sub    $0x8,%esp
f01008b4:	0f be c0             	movsbl %al,%eax
f01008b7:	50                   	push   %eax
f01008b8:	68 51 1c 10 f0       	push   $0xf0101c51
f01008bd:	e8 3b 0b 00 00       	call   f01013fd <strchr>
f01008c2:	83 c4 10             	add    $0x10,%esp
f01008c5:	85 c0                	test   %eax,%eax
f01008c7:	74 de                	je     f01008a7 <monitor+0x96>
f01008c9:	eb 94                	jmp    f010085f <monitor+0x4e>
			buf++;
	}
	argv[argc] = 0;
f01008cb:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f01008d2:	00 

	// Lookup and invoke the command
	if (argc == 0)
f01008d3:	85 f6                	test   %esi,%esi
f01008d5:	0f 84 58 ff ff ff    	je     f0100833 <monitor+0x22>
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f01008db:	83 ec 08             	sub    $0x8,%esp
f01008de:	68 de 1b 10 f0       	push   $0xf0101bde
f01008e3:	ff 75 a8             	pushl  -0x58(%ebp)
f01008e6:	e8 b4 0a 00 00       	call   f010139f <strcmp>
f01008eb:	83 c4 10             	add    $0x10,%esp
f01008ee:	85 c0                	test   %eax,%eax
f01008f0:	74 1e                	je     f0100910 <monitor+0xff>
f01008f2:	83 ec 08             	sub    $0x8,%esp
f01008f5:	68 ec 1b 10 f0       	push   $0xf0101bec
f01008fa:	ff 75 a8             	pushl  -0x58(%ebp)
f01008fd:	e8 9d 0a 00 00       	call   f010139f <strcmp>
f0100902:	83 c4 10             	add    $0x10,%esp
f0100905:	85 c0                	test   %eax,%eax
f0100907:	75 2f                	jne    f0100938 <monitor+0x127>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100909:	b8 01 00 00 00       	mov    $0x1,%eax
f010090e:	eb 05                	jmp    f0100915 <monitor+0x104>
		if (strcmp(argv[0], commands[i].name) == 0)
f0100910:	b8 00 00 00 00       	mov    $0x0,%eax
			return commands[i].func(argc, argv, tf);
f0100915:	83 ec 04             	sub    $0x4,%esp
f0100918:	8d 14 00             	lea    (%eax,%eax,1),%edx
f010091b:	01 d0                	add    %edx,%eax
f010091d:	ff 75 08             	pushl  0x8(%ebp)
f0100920:	8d 4d a8             	lea    -0x58(%ebp),%ecx
f0100923:	51                   	push   %ecx
f0100924:	56                   	push   %esi
f0100925:	ff 14 85 ec 1d 10 f0 	call   *-0xfefe214(,%eax,4)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f010092c:	83 c4 10             	add    $0x10,%esp
f010092f:	85 c0                	test   %eax,%eax
f0100931:	78 1d                	js     f0100950 <monitor+0x13f>
f0100933:	e9 fb fe ff ff       	jmp    f0100833 <monitor+0x22>
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100938:	83 ec 08             	sub    $0x8,%esp
f010093b:	ff 75 a8             	pushl  -0x58(%ebp)
f010093e:	68 73 1c 10 f0       	push   $0xf0101c73
f0100943:	e8 49 00 00 00       	call   f0100991 <cprintf>
f0100948:	83 c4 10             	add    $0x10,%esp
f010094b:	e9 e3 fe ff ff       	jmp    f0100833 <monitor+0x22>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100950:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100953:	5b                   	pop    %ebx
f0100954:	5e                   	pop    %esi
f0100955:	5f                   	pop    %edi
f0100956:	5d                   	pop    %ebp
f0100957:	c3                   	ret    

f0100958 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100958:	55                   	push   %ebp
f0100959:	89 e5                	mov    %esp,%ebp
f010095b:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f010095e:	ff 75 08             	pushl  0x8(%ebp)
f0100961:	e8 f5 fc ff ff       	call   f010065b <cputchar>
	*cnt++;
}
f0100966:	83 c4 10             	add    $0x10,%esp
f0100969:	c9                   	leave  
f010096a:	c3                   	ret    

f010096b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f010096b:	55                   	push   %ebp
f010096c:	89 e5                	mov    %esp,%ebp
f010096e:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0100971:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100978:	ff 75 0c             	pushl  0xc(%ebp)
f010097b:	ff 75 08             	pushl  0x8(%ebp)
f010097e:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100981:	50                   	push   %eax
f0100982:	68 58 09 10 f0       	push   $0xf0100958
f0100987:	e8 42 04 00 00       	call   f0100dce <vprintfmt>
	return cnt;
}
f010098c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010098f:	c9                   	leave  
f0100990:	c3                   	ret    

f0100991 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0100991:	55                   	push   %ebp
f0100992:	89 e5                	mov    %esp,%ebp
f0100994:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0100997:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f010099a:	50                   	push   %eax
f010099b:	ff 75 08             	pushl  0x8(%ebp)
f010099e:	e8 c8 ff ff ff       	call   f010096b <vcprintf>
	va_end(ap);

	return cnt;
}
f01009a3:	c9                   	leave  
f01009a4:	c3                   	ret    

f01009a5 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01009a5:	55                   	push   %ebp
f01009a6:	89 e5                	mov    %esp,%ebp
f01009a8:	57                   	push   %edi
f01009a9:	56                   	push   %esi
f01009aa:	53                   	push   %ebx
f01009ab:	83 ec 14             	sub    $0x14,%esp
f01009ae:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01009b1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01009b4:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01009b7:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f01009ba:	8b 1a                	mov    (%edx),%ebx
f01009bc:	8b 01                	mov    (%ecx),%eax
f01009be:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01009c1:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f01009c8:	eb 7f                	jmp    f0100a49 <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f01009ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01009cd:	01 d8                	add    %ebx,%eax
f01009cf:	89 c6                	mov    %eax,%esi
f01009d1:	c1 ee 1f             	shr    $0x1f,%esi
f01009d4:	01 c6                	add    %eax,%esi
f01009d6:	d1 fe                	sar    %esi
f01009d8:	8d 04 76             	lea    (%esi,%esi,2),%eax
f01009db:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01009de:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f01009e1:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01009e3:	eb 03                	jmp    f01009e8 <stab_binsearch+0x43>
			m--;
f01009e5:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01009e8:	39 c3                	cmp    %eax,%ebx
f01009ea:	7f 0d                	jg     f01009f9 <stab_binsearch+0x54>
f01009ec:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f01009f0:	83 ea 0c             	sub    $0xc,%edx
f01009f3:	39 f9                	cmp    %edi,%ecx
f01009f5:	75 ee                	jne    f01009e5 <stab_binsearch+0x40>
f01009f7:	eb 05                	jmp    f01009fe <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f01009f9:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f01009fc:	eb 4b                	jmp    f0100a49 <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01009fe:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100a01:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100a04:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0100a08:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0100a0b:	76 11                	jbe    f0100a1e <stab_binsearch+0x79>
			*region_left = m;
f0100a0d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100a10:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0100a12:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100a15:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100a1c:	eb 2b                	jmp    f0100a49 <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0100a1e:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0100a21:	73 14                	jae    f0100a37 <stab_binsearch+0x92>
			*region_right = m - 1;
f0100a23:	83 e8 01             	sub    $0x1,%eax
f0100a26:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100a29:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0100a2c:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100a2e:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100a35:	eb 12                	jmp    f0100a49 <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100a37:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100a3a:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0100a3c:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0100a40:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100a42:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0100a49:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0100a4c:	0f 8e 78 ff ff ff    	jle    f01009ca <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0100a52:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0100a56:	75 0f                	jne    f0100a67 <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f0100a58:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a5b:	8b 00                	mov    (%eax),%eax
f0100a5d:	83 e8 01             	sub    $0x1,%eax
f0100a60:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0100a63:	89 06                	mov    %eax,(%esi)
f0100a65:	eb 2c                	jmp    f0100a93 <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100a67:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100a6a:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100a6c:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100a6f:	8b 0e                	mov    (%esi),%ecx
f0100a71:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100a74:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0100a77:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100a7a:	eb 03                	jmp    f0100a7f <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0100a7c:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100a7f:	39 c8                	cmp    %ecx,%eax
f0100a81:	7e 0b                	jle    f0100a8e <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f0100a83:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0100a87:	83 ea 0c             	sub    $0xc,%edx
f0100a8a:	39 df                	cmp    %ebx,%edi
f0100a8c:	75 ee                	jne    f0100a7c <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f0100a8e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100a91:	89 06                	mov    %eax,(%esi)
	}
}
f0100a93:	83 c4 14             	add    $0x14,%esp
f0100a96:	5b                   	pop    %ebx
f0100a97:	5e                   	pop    %esi
f0100a98:	5f                   	pop    %edi
f0100a99:	5d                   	pop    %ebp
f0100a9a:	c3                   	ret    

f0100a9b <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100a9b:	55                   	push   %ebp
f0100a9c:	89 e5                	mov    %esp,%ebp
f0100a9e:	57                   	push   %edi
f0100a9f:	56                   	push   %esi
f0100aa0:	53                   	push   %ebx
f0100aa1:	83 ec 3c             	sub    $0x3c,%esp
f0100aa4:	8b 75 08             	mov    0x8(%ebp),%esi
f0100aa7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100aaa:	c7 03 fc 1d 10 f0    	movl   $0xf0101dfc,(%ebx)
	info->eip_line = 0;
f0100ab0:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0100ab7:	c7 43 08 fc 1d 10 f0 	movl   $0xf0101dfc,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0100abe:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0100ac5:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0100ac8:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100acf:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0100ad5:	76 11                	jbe    f0100ae8 <debuginfo_eip+0x4d>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100ad7:	b8 ef 72 10 f0       	mov    $0xf01072ef,%eax
f0100adc:	3d d1 59 10 f0       	cmp    $0xf01059d1,%eax
f0100ae1:	77 19                	ja     f0100afc <debuginfo_eip+0x61>
f0100ae3:	e9 a1 01 00 00       	jmp    f0100c89 <debuginfo_eip+0x1ee>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0100ae8:	83 ec 04             	sub    $0x4,%esp
f0100aeb:	68 06 1e 10 f0       	push   $0xf0101e06
f0100af0:	6a 7e                	push   $0x7e
f0100af2:	68 13 1e 10 f0       	push   $0xf0101e13
f0100af7:	e8 ea f5 ff ff       	call   f01000e6 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100afc:	80 3d ee 72 10 f0 00 	cmpb   $0x0,0xf01072ee
f0100b03:	0f 85 87 01 00 00    	jne    f0100c90 <debuginfo_eip+0x1f5>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100b09:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100b10:	b8 d0 59 10 f0       	mov    $0xf01059d0,%eax
f0100b15:	2d 34 20 10 f0       	sub    $0xf0102034,%eax
f0100b1a:	c1 f8 02             	sar    $0x2,%eax
f0100b1d:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0100b23:	83 e8 01             	sub    $0x1,%eax
f0100b26:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100b29:	83 ec 08             	sub    $0x8,%esp
f0100b2c:	56                   	push   %esi
f0100b2d:	6a 64                	push   $0x64
f0100b2f:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100b32:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100b35:	b8 34 20 10 f0       	mov    $0xf0102034,%eax
f0100b3a:	e8 66 fe ff ff       	call   f01009a5 <stab_binsearch>
	if (lfile == 0)
f0100b3f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100b42:	83 c4 10             	add    $0x10,%esp
f0100b45:	85 c0                	test   %eax,%eax
f0100b47:	0f 84 4a 01 00 00    	je     f0100c97 <debuginfo_eip+0x1fc>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100b4d:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0100b50:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100b53:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100b56:	83 ec 08             	sub    $0x8,%esp
f0100b59:	56                   	push   %esi
f0100b5a:	6a 24                	push   $0x24
f0100b5c:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100b5f:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100b62:	b8 34 20 10 f0       	mov    $0xf0102034,%eax
f0100b67:	e8 39 fe ff ff       	call   f01009a5 <stab_binsearch>

	if (lfun <= rfun) {
f0100b6c:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100b6f:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100b72:	83 c4 10             	add    $0x10,%esp
f0100b75:	39 d0                	cmp    %edx,%eax
f0100b77:	7f 40                	jg     f0100bb9 <debuginfo_eip+0x11e>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100b79:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0100b7c:	c1 e1 02             	shl    $0x2,%ecx
f0100b7f:	8d b9 34 20 10 f0    	lea    -0xfefdfcc(%ecx),%edi
f0100b85:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f0100b88:	8b b9 34 20 10 f0    	mov    -0xfefdfcc(%ecx),%edi
f0100b8e:	b9 ef 72 10 f0       	mov    $0xf01072ef,%ecx
f0100b93:	81 e9 d1 59 10 f0    	sub    $0xf01059d1,%ecx
f0100b99:	39 cf                	cmp    %ecx,%edi
f0100b9b:	73 09                	jae    f0100ba6 <debuginfo_eip+0x10b>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100b9d:	81 c7 d1 59 10 f0    	add    $0xf01059d1,%edi
f0100ba3:	89 7b 08             	mov    %edi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100ba6:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0100ba9:	8b 4f 08             	mov    0x8(%edi),%ecx
f0100bac:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0100baf:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0100bb1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0100bb4:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0100bb7:	eb 0f                	jmp    f0100bc8 <debuginfo_eip+0x12d>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0100bb9:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0100bbc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100bbf:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0100bc2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100bc5:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100bc8:	83 ec 08             	sub    $0x8,%esp
f0100bcb:	6a 3a                	push   $0x3a
f0100bcd:	ff 73 08             	pushl  0x8(%ebx)
f0100bd0:	e8 49 08 00 00       	call   f010141e <strfind>
f0100bd5:	2b 43 08             	sub    0x8(%ebx),%eax
f0100bd8:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0100bdb:	83 c4 08             	add    $0x8,%esp
f0100bde:	56                   	push   %esi
f0100bdf:	6a 44                	push   $0x44
f0100be1:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0100be4:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0100be7:	b8 34 20 10 f0       	mov    $0xf0102034,%eax
f0100bec:	e8 b4 fd ff ff       	call   f01009a5 <stab_binsearch>
	info->eip_line = stabs[lline].n_desc;
f0100bf1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0100bf4:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0100bf7:	8d 04 85 34 20 10 f0 	lea    -0xfefdfcc(,%eax,4),%eax
f0100bfe:	0f b7 48 06          	movzwl 0x6(%eax),%ecx
f0100c02:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100c05:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100c08:	83 c4 10             	add    $0x10,%esp
f0100c0b:	eb 06                	jmp    f0100c13 <debuginfo_eip+0x178>
f0100c0d:	83 ea 01             	sub    $0x1,%edx
f0100c10:	83 e8 0c             	sub    $0xc,%eax
f0100c13:	39 d6                	cmp    %edx,%esi
f0100c15:	7f 34                	jg     f0100c4b <debuginfo_eip+0x1b0>
	       && stabs[lline].n_type != N_SOL
f0100c17:	0f b6 48 04          	movzbl 0x4(%eax),%ecx
f0100c1b:	80 f9 84             	cmp    $0x84,%cl
f0100c1e:	74 0b                	je     f0100c2b <debuginfo_eip+0x190>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100c20:	80 f9 64             	cmp    $0x64,%cl
f0100c23:	75 e8                	jne    f0100c0d <debuginfo_eip+0x172>
f0100c25:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f0100c29:	74 e2                	je     f0100c0d <debuginfo_eip+0x172>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100c2b:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0100c2e:	8b 14 85 34 20 10 f0 	mov    -0xfefdfcc(,%eax,4),%edx
f0100c35:	b8 ef 72 10 f0       	mov    $0xf01072ef,%eax
f0100c3a:	2d d1 59 10 f0       	sub    $0xf01059d1,%eax
f0100c3f:	39 c2                	cmp    %eax,%edx
f0100c41:	73 08                	jae    f0100c4b <debuginfo_eip+0x1b0>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100c43:	81 c2 d1 59 10 f0    	add    $0xf01059d1,%edx
f0100c49:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100c4b:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100c4e:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100c51:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100c56:	39 f2                	cmp    %esi,%edx
f0100c58:	7d 49                	jge    f0100ca3 <debuginfo_eip+0x208>
		for (lline = lfun + 1;
f0100c5a:	83 c2 01             	add    $0x1,%edx
f0100c5d:	89 d0                	mov    %edx,%eax
f0100c5f:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0100c62:	8d 14 95 34 20 10 f0 	lea    -0xfefdfcc(,%edx,4),%edx
f0100c69:	eb 04                	jmp    f0100c6f <debuginfo_eip+0x1d4>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0100c6b:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0100c6f:	39 c6                	cmp    %eax,%esi
f0100c71:	7e 2b                	jle    f0100c9e <debuginfo_eip+0x203>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100c73:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0100c77:	83 c0 01             	add    $0x1,%eax
f0100c7a:	83 c2 0c             	add    $0xc,%edx
f0100c7d:	80 f9 a0             	cmp    $0xa0,%cl
f0100c80:	74 e9                	je     f0100c6b <debuginfo_eip+0x1d0>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100c82:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c87:	eb 1a                	jmp    f0100ca3 <debuginfo_eip+0x208>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0100c89:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100c8e:	eb 13                	jmp    f0100ca3 <debuginfo_eip+0x208>
f0100c90:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100c95:	eb 0c                	jmp    f0100ca3 <debuginfo_eip+0x208>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0100c97:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100c9c:	eb 05                	jmp    f0100ca3 <debuginfo_eip+0x208>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100c9e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100ca3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100ca6:	5b                   	pop    %ebx
f0100ca7:	5e                   	pop    %esi
f0100ca8:	5f                   	pop    %edi
f0100ca9:	5d                   	pop    %ebp
f0100caa:	c3                   	ret    

f0100cab <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100cab:	55                   	push   %ebp
f0100cac:	89 e5                	mov    %esp,%ebp
f0100cae:	57                   	push   %edi
f0100caf:	56                   	push   %esi
f0100cb0:	53                   	push   %ebx
f0100cb1:	83 ec 1c             	sub    $0x1c,%esp
f0100cb4:	89 c7                	mov    %eax,%edi
f0100cb6:	89 d6                	mov    %edx,%esi
f0100cb8:	8b 45 08             	mov    0x8(%ebp),%eax
f0100cbb:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100cbe:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100cc1:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100cc4:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0100cc7:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100ccc:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100ccf:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0100cd2:	39 d3                	cmp    %edx,%ebx
f0100cd4:	72 05                	jb     f0100cdb <printnum+0x30>
f0100cd6:	39 45 10             	cmp    %eax,0x10(%ebp)
f0100cd9:	77 45                	ja     f0100d20 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100cdb:	83 ec 0c             	sub    $0xc,%esp
f0100cde:	ff 75 18             	pushl  0x18(%ebp)
f0100ce1:	8b 45 14             	mov    0x14(%ebp),%eax
f0100ce4:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0100ce7:	53                   	push   %ebx
f0100ce8:	ff 75 10             	pushl  0x10(%ebp)
f0100ceb:	83 ec 08             	sub    $0x8,%esp
f0100cee:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100cf1:	ff 75 e0             	pushl  -0x20(%ebp)
f0100cf4:	ff 75 dc             	pushl  -0x24(%ebp)
f0100cf7:	ff 75 d8             	pushl  -0x28(%ebp)
f0100cfa:	e8 41 09 00 00       	call   f0101640 <__udivdi3>
f0100cff:	83 c4 18             	add    $0x18,%esp
f0100d02:	52                   	push   %edx
f0100d03:	50                   	push   %eax
f0100d04:	89 f2                	mov    %esi,%edx
f0100d06:	89 f8                	mov    %edi,%eax
f0100d08:	e8 9e ff ff ff       	call   f0100cab <printnum>
f0100d0d:	83 c4 20             	add    $0x20,%esp
f0100d10:	eb 18                	jmp    f0100d2a <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100d12:	83 ec 08             	sub    $0x8,%esp
f0100d15:	56                   	push   %esi
f0100d16:	ff 75 18             	pushl  0x18(%ebp)
f0100d19:	ff d7                	call   *%edi
f0100d1b:	83 c4 10             	add    $0x10,%esp
f0100d1e:	eb 03                	jmp    f0100d23 <printnum+0x78>
f0100d20:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0100d23:	83 eb 01             	sub    $0x1,%ebx
f0100d26:	85 db                	test   %ebx,%ebx
f0100d28:	7f e8                	jg     f0100d12 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100d2a:	83 ec 08             	sub    $0x8,%esp
f0100d2d:	56                   	push   %esi
f0100d2e:	83 ec 04             	sub    $0x4,%esp
f0100d31:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100d34:	ff 75 e0             	pushl  -0x20(%ebp)
f0100d37:	ff 75 dc             	pushl  -0x24(%ebp)
f0100d3a:	ff 75 d8             	pushl  -0x28(%ebp)
f0100d3d:	e8 2e 0a 00 00       	call   f0101770 <__umoddi3>
f0100d42:	83 c4 14             	add    $0x14,%esp
f0100d45:	0f be 80 21 1e 10 f0 	movsbl -0xfefe1df(%eax),%eax
f0100d4c:	50                   	push   %eax
f0100d4d:	ff d7                	call   *%edi
}
f0100d4f:	83 c4 10             	add    $0x10,%esp
f0100d52:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100d55:	5b                   	pop    %ebx
f0100d56:	5e                   	pop    %esi
f0100d57:	5f                   	pop    %edi
f0100d58:	5d                   	pop    %ebp
f0100d59:	c3                   	ret    

f0100d5a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0100d5a:	55                   	push   %ebp
f0100d5b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0100d5d:	83 fa 01             	cmp    $0x1,%edx
f0100d60:	7e 0e                	jle    f0100d70 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0100d62:	8b 10                	mov    (%eax),%edx
f0100d64:	8d 4a 08             	lea    0x8(%edx),%ecx
f0100d67:	89 08                	mov    %ecx,(%eax)
f0100d69:	8b 02                	mov    (%edx),%eax
f0100d6b:	8b 52 04             	mov    0x4(%edx),%edx
f0100d6e:	eb 22                	jmp    f0100d92 <getuint+0x38>
	else if (lflag)
f0100d70:	85 d2                	test   %edx,%edx
f0100d72:	74 10                	je     f0100d84 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0100d74:	8b 10                	mov    (%eax),%edx
f0100d76:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100d79:	89 08                	mov    %ecx,(%eax)
f0100d7b:	8b 02                	mov    (%edx),%eax
f0100d7d:	ba 00 00 00 00       	mov    $0x0,%edx
f0100d82:	eb 0e                	jmp    f0100d92 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0100d84:	8b 10                	mov    (%eax),%edx
f0100d86:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100d89:	89 08                	mov    %ecx,(%eax)
f0100d8b:	8b 02                	mov    (%edx),%eax
f0100d8d:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0100d92:	5d                   	pop    %ebp
f0100d93:	c3                   	ret    

f0100d94 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100d94:	55                   	push   %ebp
f0100d95:	89 e5                	mov    %esp,%ebp
f0100d97:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100d9a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0100d9e:	8b 10                	mov    (%eax),%edx
f0100da0:	3b 50 04             	cmp    0x4(%eax),%edx
f0100da3:	73 0a                	jae    f0100daf <sprintputch+0x1b>
		*b->buf++ = ch;
f0100da5:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100da8:	89 08                	mov    %ecx,(%eax)
f0100daa:	8b 45 08             	mov    0x8(%ebp),%eax
f0100dad:	88 02                	mov    %al,(%edx)
}
f0100daf:	5d                   	pop    %ebp
f0100db0:	c3                   	ret    

f0100db1 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0100db1:	55                   	push   %ebp
f0100db2:	89 e5                	mov    %esp,%ebp
f0100db4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100db7:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0100dba:	50                   	push   %eax
f0100dbb:	ff 75 10             	pushl  0x10(%ebp)
f0100dbe:	ff 75 0c             	pushl  0xc(%ebp)
f0100dc1:	ff 75 08             	pushl  0x8(%ebp)
f0100dc4:	e8 05 00 00 00       	call   f0100dce <vprintfmt>
	va_end(ap);
}
f0100dc9:	83 c4 10             	add    $0x10,%esp
f0100dcc:	c9                   	leave  
f0100dcd:	c3                   	ret    

f0100dce <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0100dce:	55                   	push   %ebp
f0100dcf:	89 e5                	mov    %esp,%ebp
f0100dd1:	57                   	push   %edi
f0100dd2:	56                   	push   %esi
f0100dd3:	53                   	push   %ebx
f0100dd4:	83 ec 2c             	sub    $0x2c,%esp
f0100dd7:	8b 75 08             	mov    0x8(%ebp),%esi
f0100dda:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100ddd:	8b 7d 10             	mov    0x10(%ebp),%edi
f0100de0:	eb 12                	jmp    f0100df4 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0100de2:	85 c0                	test   %eax,%eax
f0100de4:	0f 84 89 03 00 00    	je     f0101173 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
f0100dea:	83 ec 08             	sub    $0x8,%esp
f0100ded:	53                   	push   %ebx
f0100dee:	50                   	push   %eax
f0100def:	ff d6                	call   *%esi
f0100df1:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0100df4:	83 c7 01             	add    $0x1,%edi
f0100df7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0100dfb:	83 f8 25             	cmp    $0x25,%eax
f0100dfe:	75 e2                	jne    f0100de2 <vprintfmt+0x14>
f0100e00:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0100e04:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0100e0b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0100e12:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0100e19:	ba 00 00 00 00       	mov    $0x0,%edx
f0100e1e:	eb 07                	jmp    f0100e27 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e20:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0100e23:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e27:	8d 47 01             	lea    0x1(%edi),%eax
f0100e2a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100e2d:	0f b6 07             	movzbl (%edi),%eax
f0100e30:	0f b6 c8             	movzbl %al,%ecx
f0100e33:	83 e8 23             	sub    $0x23,%eax
f0100e36:	3c 55                	cmp    $0x55,%al
f0100e38:	0f 87 1a 03 00 00    	ja     f0101158 <vprintfmt+0x38a>
f0100e3e:	0f b6 c0             	movzbl %al,%eax
f0100e41:	ff 24 85 b0 1e 10 f0 	jmp    *-0xfefe150(,%eax,4)
f0100e48:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0100e4b:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0100e4f:	eb d6                	jmp    f0100e27 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e51:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100e54:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e59:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0100e5c:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100e5f:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f0100e63:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f0100e66:	8d 51 d0             	lea    -0x30(%ecx),%edx
f0100e69:	83 fa 09             	cmp    $0x9,%edx
f0100e6c:	77 39                	ja     f0100ea7 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0100e6e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0100e71:	eb e9                	jmp    f0100e5c <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0100e73:	8b 45 14             	mov    0x14(%ebp),%eax
f0100e76:	8d 48 04             	lea    0x4(%eax),%ecx
f0100e79:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0100e7c:	8b 00                	mov    (%eax),%eax
f0100e7e:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e81:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0100e84:	eb 27                	jmp    f0100ead <vprintfmt+0xdf>
f0100e86:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100e89:	85 c0                	test   %eax,%eax
f0100e8b:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100e90:	0f 49 c8             	cmovns %eax,%ecx
f0100e93:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e96:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100e99:	eb 8c                	jmp    f0100e27 <vprintfmt+0x59>
f0100e9b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0100e9e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0100ea5:	eb 80                	jmp    f0100e27 <vprintfmt+0x59>
f0100ea7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100eaa:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0100ead:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0100eb1:	0f 89 70 ff ff ff    	jns    f0100e27 <vprintfmt+0x59>
				width = precision, precision = -1;
f0100eb7:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100eba:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100ebd:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0100ec4:	e9 5e ff ff ff       	jmp    f0100e27 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0100ec9:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100ecc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0100ecf:	e9 53 ff ff ff       	jmp    f0100e27 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0100ed4:	8b 45 14             	mov    0x14(%ebp),%eax
f0100ed7:	8d 50 04             	lea    0x4(%eax),%edx
f0100eda:	89 55 14             	mov    %edx,0x14(%ebp)
f0100edd:	83 ec 08             	sub    $0x8,%esp
f0100ee0:	53                   	push   %ebx
f0100ee1:	ff 30                	pushl  (%eax)
f0100ee3:	ff d6                	call   *%esi
			break;
f0100ee5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100ee8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0100eeb:	e9 04 ff ff ff       	jmp    f0100df4 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0100ef0:	8b 45 14             	mov    0x14(%ebp),%eax
f0100ef3:	8d 50 04             	lea    0x4(%eax),%edx
f0100ef6:	89 55 14             	mov    %edx,0x14(%ebp)
f0100ef9:	8b 00                	mov    (%eax),%eax
f0100efb:	99                   	cltd   
f0100efc:	31 d0                	xor    %edx,%eax
f0100efe:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0100f00:	83 f8 06             	cmp    $0x6,%eax
f0100f03:	7f 0b                	jg     f0100f10 <vprintfmt+0x142>
f0100f05:	8b 14 85 08 20 10 f0 	mov    -0xfefdff8(,%eax,4),%edx
f0100f0c:	85 d2                	test   %edx,%edx
f0100f0e:	75 18                	jne    f0100f28 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f0100f10:	50                   	push   %eax
f0100f11:	68 39 1e 10 f0       	push   $0xf0101e39
f0100f16:	53                   	push   %ebx
f0100f17:	56                   	push   %esi
f0100f18:	e8 94 fe ff ff       	call   f0100db1 <printfmt>
f0100f1d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f20:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0100f23:	e9 cc fe ff ff       	jmp    f0100df4 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f0100f28:	52                   	push   %edx
f0100f29:	68 42 1e 10 f0       	push   $0xf0101e42
f0100f2e:	53                   	push   %ebx
f0100f2f:	56                   	push   %esi
f0100f30:	e8 7c fe ff ff       	call   f0100db1 <printfmt>
f0100f35:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f38:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100f3b:	e9 b4 fe ff ff       	jmp    f0100df4 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0100f40:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f43:	8d 50 04             	lea    0x4(%eax),%edx
f0100f46:	89 55 14             	mov    %edx,0x14(%ebp)
f0100f49:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0100f4b:	85 ff                	test   %edi,%edi
f0100f4d:	b8 32 1e 10 f0       	mov    $0xf0101e32,%eax
f0100f52:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0100f55:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0100f59:	0f 8e 94 00 00 00    	jle    f0100ff3 <vprintfmt+0x225>
f0100f5f:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0100f63:	0f 84 98 00 00 00    	je     f0101001 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
f0100f69:	83 ec 08             	sub    $0x8,%esp
f0100f6c:	ff 75 d0             	pushl  -0x30(%ebp)
f0100f6f:	57                   	push   %edi
f0100f70:	e8 5f 03 00 00       	call   f01012d4 <strnlen>
f0100f75:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100f78:	29 c1                	sub    %eax,%ecx
f0100f7a:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0100f7d:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0100f80:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0100f84:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100f87:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0100f8a:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0100f8c:	eb 0f                	jmp    f0100f9d <vprintfmt+0x1cf>
					putch(padc, putdat);
f0100f8e:	83 ec 08             	sub    $0x8,%esp
f0100f91:	53                   	push   %ebx
f0100f92:	ff 75 e0             	pushl  -0x20(%ebp)
f0100f95:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0100f97:	83 ef 01             	sub    $0x1,%edi
f0100f9a:	83 c4 10             	add    $0x10,%esp
f0100f9d:	85 ff                	test   %edi,%edi
f0100f9f:	7f ed                	jg     f0100f8e <vprintfmt+0x1c0>
f0100fa1:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0100fa4:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0100fa7:	85 c9                	test   %ecx,%ecx
f0100fa9:	b8 00 00 00 00       	mov    $0x0,%eax
f0100fae:	0f 49 c1             	cmovns %ecx,%eax
f0100fb1:	29 c1                	sub    %eax,%ecx
f0100fb3:	89 75 08             	mov    %esi,0x8(%ebp)
f0100fb6:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0100fb9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0100fbc:	89 cb                	mov    %ecx,%ebx
f0100fbe:	eb 4d                	jmp    f010100d <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0100fc0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0100fc4:	74 1b                	je     f0100fe1 <vprintfmt+0x213>
f0100fc6:	0f be c0             	movsbl %al,%eax
f0100fc9:	83 e8 20             	sub    $0x20,%eax
f0100fcc:	83 f8 5e             	cmp    $0x5e,%eax
f0100fcf:	76 10                	jbe    f0100fe1 <vprintfmt+0x213>
					putch('?', putdat);
f0100fd1:	83 ec 08             	sub    $0x8,%esp
f0100fd4:	ff 75 0c             	pushl  0xc(%ebp)
f0100fd7:	6a 3f                	push   $0x3f
f0100fd9:	ff 55 08             	call   *0x8(%ebp)
f0100fdc:	83 c4 10             	add    $0x10,%esp
f0100fdf:	eb 0d                	jmp    f0100fee <vprintfmt+0x220>
				else
					putch(ch, putdat);
f0100fe1:	83 ec 08             	sub    $0x8,%esp
f0100fe4:	ff 75 0c             	pushl  0xc(%ebp)
f0100fe7:	52                   	push   %edx
f0100fe8:	ff 55 08             	call   *0x8(%ebp)
f0100feb:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0100fee:	83 eb 01             	sub    $0x1,%ebx
f0100ff1:	eb 1a                	jmp    f010100d <vprintfmt+0x23f>
f0100ff3:	89 75 08             	mov    %esi,0x8(%ebp)
f0100ff6:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0100ff9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0100ffc:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0100fff:	eb 0c                	jmp    f010100d <vprintfmt+0x23f>
f0101001:	89 75 08             	mov    %esi,0x8(%ebp)
f0101004:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0101007:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f010100a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f010100d:	83 c7 01             	add    $0x1,%edi
f0101010:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0101014:	0f be d0             	movsbl %al,%edx
f0101017:	85 d2                	test   %edx,%edx
f0101019:	74 23                	je     f010103e <vprintfmt+0x270>
f010101b:	85 f6                	test   %esi,%esi
f010101d:	78 a1                	js     f0100fc0 <vprintfmt+0x1f2>
f010101f:	83 ee 01             	sub    $0x1,%esi
f0101022:	79 9c                	jns    f0100fc0 <vprintfmt+0x1f2>
f0101024:	89 df                	mov    %ebx,%edi
f0101026:	8b 75 08             	mov    0x8(%ebp),%esi
f0101029:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010102c:	eb 18                	jmp    f0101046 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f010102e:	83 ec 08             	sub    $0x8,%esp
f0101031:	53                   	push   %ebx
f0101032:	6a 20                	push   $0x20
f0101034:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0101036:	83 ef 01             	sub    $0x1,%edi
f0101039:	83 c4 10             	add    $0x10,%esp
f010103c:	eb 08                	jmp    f0101046 <vprintfmt+0x278>
f010103e:	89 df                	mov    %ebx,%edi
f0101040:	8b 75 08             	mov    0x8(%ebp),%esi
f0101043:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101046:	85 ff                	test   %edi,%edi
f0101048:	7f e4                	jg     f010102e <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010104a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010104d:	e9 a2 fd ff ff       	jmp    f0100df4 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0101052:	83 fa 01             	cmp    $0x1,%edx
f0101055:	7e 16                	jle    f010106d <vprintfmt+0x29f>
		return va_arg(*ap, long long);
f0101057:	8b 45 14             	mov    0x14(%ebp),%eax
f010105a:	8d 50 08             	lea    0x8(%eax),%edx
f010105d:	89 55 14             	mov    %edx,0x14(%ebp)
f0101060:	8b 50 04             	mov    0x4(%eax),%edx
f0101063:	8b 00                	mov    (%eax),%eax
f0101065:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101068:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010106b:	eb 32                	jmp    f010109f <vprintfmt+0x2d1>
	else if (lflag)
f010106d:	85 d2                	test   %edx,%edx
f010106f:	74 18                	je     f0101089 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
f0101071:	8b 45 14             	mov    0x14(%ebp),%eax
f0101074:	8d 50 04             	lea    0x4(%eax),%edx
f0101077:	89 55 14             	mov    %edx,0x14(%ebp)
f010107a:	8b 00                	mov    (%eax),%eax
f010107c:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010107f:	89 c1                	mov    %eax,%ecx
f0101081:	c1 f9 1f             	sar    $0x1f,%ecx
f0101084:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0101087:	eb 16                	jmp    f010109f <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
f0101089:	8b 45 14             	mov    0x14(%ebp),%eax
f010108c:	8d 50 04             	lea    0x4(%eax),%edx
f010108f:	89 55 14             	mov    %edx,0x14(%ebp)
f0101092:	8b 00                	mov    (%eax),%eax
f0101094:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101097:	89 c1                	mov    %eax,%ecx
f0101099:	c1 f9 1f             	sar    $0x1f,%ecx
f010109c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f010109f:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01010a2:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f01010a5:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f01010aa:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f01010ae:	79 74                	jns    f0101124 <vprintfmt+0x356>
				putch('-', putdat);
f01010b0:	83 ec 08             	sub    $0x8,%esp
f01010b3:	53                   	push   %ebx
f01010b4:	6a 2d                	push   $0x2d
f01010b6:	ff d6                	call   *%esi
				num = -(long long) num;
f01010b8:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01010bb:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01010be:	f7 d8                	neg    %eax
f01010c0:	83 d2 00             	adc    $0x0,%edx
f01010c3:	f7 da                	neg    %edx
f01010c5:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f01010c8:	b9 0a 00 00 00       	mov    $0xa,%ecx
f01010cd:	eb 55                	jmp    f0101124 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f01010cf:	8d 45 14             	lea    0x14(%ebp),%eax
f01010d2:	e8 83 fc ff ff       	call   f0100d5a <getuint>
			base = 10;
f01010d7:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f01010dc:	eb 46                	jmp    f0101124 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num=getuint(&ap,lflag);
f01010de:	8d 45 14             	lea    0x14(%ebp),%eax
f01010e1:	e8 74 fc ff ff       	call   f0100d5a <getuint>
                        base=8;
f01010e6:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
f01010eb:	eb 37                	jmp    f0101124 <vprintfmt+0x356>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
f01010ed:	83 ec 08             	sub    $0x8,%esp
f01010f0:	53                   	push   %ebx
f01010f1:	6a 30                	push   $0x30
f01010f3:	ff d6                	call   *%esi
			putch('x', putdat);
f01010f5:	83 c4 08             	add    $0x8,%esp
f01010f8:	53                   	push   %ebx
f01010f9:	6a 78                	push   $0x78
f01010fb:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f01010fd:	8b 45 14             	mov    0x14(%ebp),%eax
f0101100:	8d 50 04             	lea    0x4(%eax),%edx
f0101103:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0101106:	8b 00                	mov    (%eax),%eax
f0101108:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f010110d:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0101110:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f0101115:	eb 0d                	jmp    f0101124 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0101117:	8d 45 14             	lea    0x14(%ebp),%eax
f010111a:	e8 3b fc ff ff       	call   f0100d5a <getuint>
			base = 16;
f010111f:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f0101124:	83 ec 0c             	sub    $0xc,%esp
f0101127:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f010112b:	57                   	push   %edi
f010112c:	ff 75 e0             	pushl  -0x20(%ebp)
f010112f:	51                   	push   %ecx
f0101130:	52                   	push   %edx
f0101131:	50                   	push   %eax
f0101132:	89 da                	mov    %ebx,%edx
f0101134:	89 f0                	mov    %esi,%eax
f0101136:	e8 70 fb ff ff       	call   f0100cab <printnum>
			break;
f010113b:	83 c4 20             	add    $0x20,%esp
f010113e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101141:	e9 ae fc ff ff       	jmp    f0100df4 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0101146:	83 ec 08             	sub    $0x8,%esp
f0101149:	53                   	push   %ebx
f010114a:	51                   	push   %ecx
f010114b:	ff d6                	call   *%esi
			break;
f010114d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101150:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0101153:	e9 9c fc ff ff       	jmp    f0100df4 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0101158:	83 ec 08             	sub    $0x8,%esp
f010115b:	53                   	push   %ebx
f010115c:	6a 25                	push   $0x25
f010115e:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0101160:	83 c4 10             	add    $0x10,%esp
f0101163:	eb 03                	jmp    f0101168 <vprintfmt+0x39a>
f0101165:	83 ef 01             	sub    $0x1,%edi
f0101168:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f010116c:	75 f7                	jne    f0101165 <vprintfmt+0x397>
f010116e:	e9 81 fc ff ff       	jmp    f0100df4 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f0101173:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101176:	5b                   	pop    %ebx
f0101177:	5e                   	pop    %esi
f0101178:	5f                   	pop    %edi
f0101179:	5d                   	pop    %ebp
f010117a:	c3                   	ret    

f010117b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010117b:	55                   	push   %ebp
f010117c:	89 e5                	mov    %esp,%ebp
f010117e:	83 ec 18             	sub    $0x18,%esp
f0101181:	8b 45 08             	mov    0x8(%ebp),%eax
f0101184:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0101187:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010118a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f010118e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0101191:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0101198:	85 c0                	test   %eax,%eax
f010119a:	74 26                	je     f01011c2 <vsnprintf+0x47>
f010119c:	85 d2                	test   %edx,%edx
f010119e:	7e 22                	jle    f01011c2 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01011a0:	ff 75 14             	pushl  0x14(%ebp)
f01011a3:	ff 75 10             	pushl  0x10(%ebp)
f01011a6:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01011a9:	50                   	push   %eax
f01011aa:	68 94 0d 10 f0       	push   $0xf0100d94
f01011af:	e8 1a fc ff ff       	call   f0100dce <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01011b4:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01011b7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01011ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01011bd:	83 c4 10             	add    $0x10,%esp
f01011c0:	eb 05                	jmp    f01011c7 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f01011c2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f01011c7:	c9                   	leave  
f01011c8:	c3                   	ret    

f01011c9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01011c9:	55                   	push   %ebp
f01011ca:	89 e5                	mov    %esp,%ebp
f01011cc:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01011cf:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01011d2:	50                   	push   %eax
f01011d3:	ff 75 10             	pushl  0x10(%ebp)
f01011d6:	ff 75 0c             	pushl  0xc(%ebp)
f01011d9:	ff 75 08             	pushl  0x8(%ebp)
f01011dc:	e8 9a ff ff ff       	call   f010117b <vsnprintf>
	va_end(ap);

	return rc;
}
f01011e1:	c9                   	leave  
f01011e2:	c3                   	ret    

f01011e3 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01011e3:	55                   	push   %ebp
f01011e4:	89 e5                	mov    %esp,%ebp
f01011e6:	57                   	push   %edi
f01011e7:	56                   	push   %esi
f01011e8:	53                   	push   %ebx
f01011e9:	83 ec 0c             	sub    $0xc,%esp
f01011ec:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01011ef:	85 c0                	test   %eax,%eax
f01011f1:	74 11                	je     f0101204 <readline+0x21>
		cprintf("%s", prompt);
f01011f3:	83 ec 08             	sub    $0x8,%esp
f01011f6:	50                   	push   %eax
f01011f7:	68 42 1e 10 f0       	push   $0xf0101e42
f01011fc:	e8 90 f7 ff ff       	call   f0100991 <cprintf>
f0101201:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0101204:	83 ec 0c             	sub    $0xc,%esp
f0101207:	6a 00                	push   $0x0
f0101209:	e8 6e f4 ff ff       	call   f010067c <iscons>
f010120e:	89 c7                	mov    %eax,%edi
f0101210:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0101213:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0101218:	e8 4e f4 ff ff       	call   f010066b <getchar>
f010121d:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010121f:	85 c0                	test   %eax,%eax
f0101221:	79 18                	jns    f010123b <readline+0x58>
			cprintf("read error: %e\n", c);
f0101223:	83 ec 08             	sub    $0x8,%esp
f0101226:	50                   	push   %eax
f0101227:	68 24 20 10 f0       	push   $0xf0102024
f010122c:	e8 60 f7 ff ff       	call   f0100991 <cprintf>
			return NULL;
f0101231:	83 c4 10             	add    $0x10,%esp
f0101234:	b8 00 00 00 00       	mov    $0x0,%eax
f0101239:	eb 79                	jmp    f01012b4 <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f010123b:	83 f8 08             	cmp    $0x8,%eax
f010123e:	0f 94 c2             	sete   %dl
f0101241:	83 f8 7f             	cmp    $0x7f,%eax
f0101244:	0f 94 c0             	sete   %al
f0101247:	08 c2                	or     %al,%dl
f0101249:	74 1a                	je     f0101265 <readline+0x82>
f010124b:	85 f6                	test   %esi,%esi
f010124d:	7e 16                	jle    f0101265 <readline+0x82>
			if (echoing)
f010124f:	85 ff                	test   %edi,%edi
f0101251:	74 0d                	je     f0101260 <readline+0x7d>
				cputchar('\b');
f0101253:	83 ec 0c             	sub    $0xc,%esp
f0101256:	6a 08                	push   $0x8
f0101258:	e8 fe f3 ff ff       	call   f010065b <cputchar>
f010125d:	83 c4 10             	add    $0x10,%esp
			i--;
f0101260:	83 ee 01             	sub    $0x1,%esi
f0101263:	eb b3                	jmp    f0101218 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0101265:	83 fb 1f             	cmp    $0x1f,%ebx
f0101268:	7e 23                	jle    f010128d <readline+0xaa>
f010126a:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0101270:	7f 1b                	jg     f010128d <readline+0xaa>
			if (echoing)
f0101272:	85 ff                	test   %edi,%edi
f0101274:	74 0c                	je     f0101282 <readline+0x9f>
				cputchar(c);
f0101276:	83 ec 0c             	sub    $0xc,%esp
f0101279:	53                   	push   %ebx
f010127a:	e8 dc f3 ff ff       	call   f010065b <cputchar>
f010127f:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0101282:	88 9e 40 25 11 f0    	mov    %bl,-0xfeedac0(%esi)
f0101288:	8d 76 01             	lea    0x1(%esi),%esi
f010128b:	eb 8b                	jmp    f0101218 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f010128d:	83 fb 0a             	cmp    $0xa,%ebx
f0101290:	74 05                	je     f0101297 <readline+0xb4>
f0101292:	83 fb 0d             	cmp    $0xd,%ebx
f0101295:	75 81                	jne    f0101218 <readline+0x35>
			if (echoing)
f0101297:	85 ff                	test   %edi,%edi
f0101299:	74 0d                	je     f01012a8 <readline+0xc5>
				cputchar('\n');
f010129b:	83 ec 0c             	sub    $0xc,%esp
f010129e:	6a 0a                	push   $0xa
f01012a0:	e8 b6 f3 ff ff       	call   f010065b <cputchar>
f01012a5:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f01012a8:	c6 86 40 25 11 f0 00 	movb   $0x0,-0xfeedac0(%esi)
			return buf;
f01012af:	b8 40 25 11 f0       	mov    $0xf0112540,%eax
		}
	}
}
f01012b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01012b7:	5b                   	pop    %ebx
f01012b8:	5e                   	pop    %esi
f01012b9:	5f                   	pop    %edi
f01012ba:	5d                   	pop    %ebp
f01012bb:	c3                   	ret    

f01012bc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01012bc:	55                   	push   %ebp
f01012bd:	89 e5                	mov    %esp,%ebp
f01012bf:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01012c2:	b8 00 00 00 00       	mov    $0x0,%eax
f01012c7:	eb 03                	jmp    f01012cc <strlen+0x10>
		n++;
f01012c9:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01012cc:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01012d0:	75 f7                	jne    f01012c9 <strlen+0xd>
		n++;
	return n;
}
f01012d2:	5d                   	pop    %ebp
f01012d3:	c3                   	ret    

f01012d4 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01012d4:	55                   	push   %ebp
f01012d5:	89 e5                	mov    %esp,%ebp
f01012d7:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01012da:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01012dd:	ba 00 00 00 00       	mov    $0x0,%edx
f01012e2:	eb 03                	jmp    f01012e7 <strnlen+0x13>
		n++;
f01012e4:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01012e7:	39 c2                	cmp    %eax,%edx
f01012e9:	74 08                	je     f01012f3 <strnlen+0x1f>
f01012eb:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f01012ef:	75 f3                	jne    f01012e4 <strnlen+0x10>
f01012f1:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f01012f3:	5d                   	pop    %ebp
f01012f4:	c3                   	ret    

f01012f5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01012f5:	55                   	push   %ebp
f01012f6:	89 e5                	mov    %esp,%ebp
f01012f8:	53                   	push   %ebx
f01012f9:	8b 45 08             	mov    0x8(%ebp),%eax
f01012fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01012ff:	89 c2                	mov    %eax,%edx
f0101301:	83 c2 01             	add    $0x1,%edx
f0101304:	83 c1 01             	add    $0x1,%ecx
f0101307:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f010130b:	88 5a ff             	mov    %bl,-0x1(%edx)
f010130e:	84 db                	test   %bl,%bl
f0101310:	75 ef                	jne    f0101301 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0101312:	5b                   	pop    %ebx
f0101313:	5d                   	pop    %ebp
f0101314:	c3                   	ret    

f0101315 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0101315:	55                   	push   %ebp
f0101316:	89 e5                	mov    %esp,%ebp
f0101318:	53                   	push   %ebx
f0101319:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f010131c:	53                   	push   %ebx
f010131d:	e8 9a ff ff ff       	call   f01012bc <strlen>
f0101322:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0101325:	ff 75 0c             	pushl  0xc(%ebp)
f0101328:	01 d8                	add    %ebx,%eax
f010132a:	50                   	push   %eax
f010132b:	e8 c5 ff ff ff       	call   f01012f5 <strcpy>
	return dst;
}
f0101330:	89 d8                	mov    %ebx,%eax
f0101332:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101335:	c9                   	leave  
f0101336:	c3                   	ret    

f0101337 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0101337:	55                   	push   %ebp
f0101338:	89 e5                	mov    %esp,%ebp
f010133a:	56                   	push   %esi
f010133b:	53                   	push   %ebx
f010133c:	8b 75 08             	mov    0x8(%ebp),%esi
f010133f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101342:	89 f3                	mov    %esi,%ebx
f0101344:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101347:	89 f2                	mov    %esi,%edx
f0101349:	eb 0f                	jmp    f010135a <strncpy+0x23>
		*dst++ = *src;
f010134b:	83 c2 01             	add    $0x1,%edx
f010134e:	0f b6 01             	movzbl (%ecx),%eax
f0101351:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0101354:	80 39 01             	cmpb   $0x1,(%ecx)
f0101357:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010135a:	39 da                	cmp    %ebx,%edx
f010135c:	75 ed                	jne    f010134b <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f010135e:	89 f0                	mov    %esi,%eax
f0101360:	5b                   	pop    %ebx
f0101361:	5e                   	pop    %esi
f0101362:	5d                   	pop    %ebp
f0101363:	c3                   	ret    

f0101364 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0101364:	55                   	push   %ebp
f0101365:	89 e5                	mov    %esp,%ebp
f0101367:	56                   	push   %esi
f0101368:	53                   	push   %ebx
f0101369:	8b 75 08             	mov    0x8(%ebp),%esi
f010136c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010136f:	8b 55 10             	mov    0x10(%ebp),%edx
f0101372:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0101374:	85 d2                	test   %edx,%edx
f0101376:	74 21                	je     f0101399 <strlcpy+0x35>
f0101378:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f010137c:	89 f2                	mov    %esi,%edx
f010137e:	eb 09                	jmp    f0101389 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0101380:	83 c2 01             	add    $0x1,%edx
f0101383:	83 c1 01             	add    $0x1,%ecx
f0101386:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0101389:	39 c2                	cmp    %eax,%edx
f010138b:	74 09                	je     f0101396 <strlcpy+0x32>
f010138d:	0f b6 19             	movzbl (%ecx),%ebx
f0101390:	84 db                	test   %bl,%bl
f0101392:	75 ec                	jne    f0101380 <strlcpy+0x1c>
f0101394:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f0101396:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0101399:	29 f0                	sub    %esi,%eax
}
f010139b:	5b                   	pop    %ebx
f010139c:	5e                   	pop    %esi
f010139d:	5d                   	pop    %ebp
f010139e:	c3                   	ret    

f010139f <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010139f:	55                   	push   %ebp
f01013a0:	89 e5                	mov    %esp,%ebp
f01013a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01013a5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01013a8:	eb 06                	jmp    f01013b0 <strcmp+0x11>
		p++, q++;
f01013aa:	83 c1 01             	add    $0x1,%ecx
f01013ad:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01013b0:	0f b6 01             	movzbl (%ecx),%eax
f01013b3:	84 c0                	test   %al,%al
f01013b5:	74 04                	je     f01013bb <strcmp+0x1c>
f01013b7:	3a 02                	cmp    (%edx),%al
f01013b9:	74 ef                	je     f01013aa <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01013bb:	0f b6 c0             	movzbl %al,%eax
f01013be:	0f b6 12             	movzbl (%edx),%edx
f01013c1:	29 d0                	sub    %edx,%eax
}
f01013c3:	5d                   	pop    %ebp
f01013c4:	c3                   	ret    

f01013c5 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01013c5:	55                   	push   %ebp
f01013c6:	89 e5                	mov    %esp,%ebp
f01013c8:	53                   	push   %ebx
f01013c9:	8b 45 08             	mov    0x8(%ebp),%eax
f01013cc:	8b 55 0c             	mov    0xc(%ebp),%edx
f01013cf:	89 c3                	mov    %eax,%ebx
f01013d1:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01013d4:	eb 06                	jmp    f01013dc <strncmp+0x17>
		n--, p++, q++;
f01013d6:	83 c0 01             	add    $0x1,%eax
f01013d9:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01013dc:	39 d8                	cmp    %ebx,%eax
f01013de:	74 15                	je     f01013f5 <strncmp+0x30>
f01013e0:	0f b6 08             	movzbl (%eax),%ecx
f01013e3:	84 c9                	test   %cl,%cl
f01013e5:	74 04                	je     f01013eb <strncmp+0x26>
f01013e7:	3a 0a                	cmp    (%edx),%cl
f01013e9:	74 eb                	je     f01013d6 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01013eb:	0f b6 00             	movzbl (%eax),%eax
f01013ee:	0f b6 12             	movzbl (%edx),%edx
f01013f1:	29 d0                	sub    %edx,%eax
f01013f3:	eb 05                	jmp    f01013fa <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f01013f5:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01013fa:	5b                   	pop    %ebx
f01013fb:	5d                   	pop    %ebp
f01013fc:	c3                   	ret    

f01013fd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01013fd:	55                   	push   %ebp
f01013fe:	89 e5                	mov    %esp,%ebp
f0101400:	8b 45 08             	mov    0x8(%ebp),%eax
f0101403:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101407:	eb 07                	jmp    f0101410 <strchr+0x13>
		if (*s == c)
f0101409:	38 ca                	cmp    %cl,%dl
f010140b:	74 0f                	je     f010141c <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f010140d:	83 c0 01             	add    $0x1,%eax
f0101410:	0f b6 10             	movzbl (%eax),%edx
f0101413:	84 d2                	test   %dl,%dl
f0101415:	75 f2                	jne    f0101409 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0101417:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010141c:	5d                   	pop    %ebp
f010141d:	c3                   	ret    

f010141e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010141e:	55                   	push   %ebp
f010141f:	89 e5                	mov    %esp,%ebp
f0101421:	8b 45 08             	mov    0x8(%ebp),%eax
f0101424:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101428:	eb 03                	jmp    f010142d <strfind+0xf>
f010142a:	83 c0 01             	add    $0x1,%eax
f010142d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0101430:	38 ca                	cmp    %cl,%dl
f0101432:	74 04                	je     f0101438 <strfind+0x1a>
f0101434:	84 d2                	test   %dl,%dl
f0101436:	75 f2                	jne    f010142a <strfind+0xc>
			break;
	return (char *) s;
}
f0101438:	5d                   	pop    %ebp
f0101439:	c3                   	ret    

f010143a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f010143a:	55                   	push   %ebp
f010143b:	89 e5                	mov    %esp,%ebp
f010143d:	57                   	push   %edi
f010143e:	56                   	push   %esi
f010143f:	53                   	push   %ebx
f0101440:	8b 7d 08             	mov    0x8(%ebp),%edi
f0101443:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0101446:	85 c9                	test   %ecx,%ecx
f0101448:	74 36                	je     f0101480 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f010144a:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0101450:	75 28                	jne    f010147a <memset+0x40>
f0101452:	f6 c1 03             	test   $0x3,%cl
f0101455:	75 23                	jne    f010147a <memset+0x40>
		c &= 0xFF;
f0101457:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f010145b:	89 d3                	mov    %edx,%ebx
f010145d:	c1 e3 08             	shl    $0x8,%ebx
f0101460:	89 d6                	mov    %edx,%esi
f0101462:	c1 e6 18             	shl    $0x18,%esi
f0101465:	89 d0                	mov    %edx,%eax
f0101467:	c1 e0 10             	shl    $0x10,%eax
f010146a:	09 f0                	or     %esi,%eax
f010146c:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f010146e:	89 d8                	mov    %ebx,%eax
f0101470:	09 d0                	or     %edx,%eax
f0101472:	c1 e9 02             	shr    $0x2,%ecx
f0101475:	fc                   	cld    
f0101476:	f3 ab                	rep stos %eax,%es:(%edi)
f0101478:	eb 06                	jmp    f0101480 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f010147a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010147d:	fc                   	cld    
f010147e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0101480:	89 f8                	mov    %edi,%eax
f0101482:	5b                   	pop    %ebx
f0101483:	5e                   	pop    %esi
f0101484:	5f                   	pop    %edi
f0101485:	5d                   	pop    %ebp
f0101486:	c3                   	ret    

f0101487 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0101487:	55                   	push   %ebp
f0101488:	89 e5                	mov    %esp,%ebp
f010148a:	57                   	push   %edi
f010148b:	56                   	push   %esi
f010148c:	8b 45 08             	mov    0x8(%ebp),%eax
f010148f:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101492:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0101495:	39 c6                	cmp    %eax,%esi
f0101497:	73 35                	jae    f01014ce <memmove+0x47>
f0101499:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f010149c:	39 d0                	cmp    %edx,%eax
f010149e:	73 2e                	jae    f01014ce <memmove+0x47>
		s += n;
		d += n;
f01014a0:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01014a3:	89 d6                	mov    %edx,%esi
f01014a5:	09 fe                	or     %edi,%esi
f01014a7:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01014ad:	75 13                	jne    f01014c2 <memmove+0x3b>
f01014af:	f6 c1 03             	test   $0x3,%cl
f01014b2:	75 0e                	jne    f01014c2 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f01014b4:	83 ef 04             	sub    $0x4,%edi
f01014b7:	8d 72 fc             	lea    -0x4(%edx),%esi
f01014ba:	c1 e9 02             	shr    $0x2,%ecx
f01014bd:	fd                   	std    
f01014be:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01014c0:	eb 09                	jmp    f01014cb <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01014c2:	83 ef 01             	sub    $0x1,%edi
f01014c5:	8d 72 ff             	lea    -0x1(%edx),%esi
f01014c8:	fd                   	std    
f01014c9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01014cb:	fc                   	cld    
f01014cc:	eb 1d                	jmp    f01014eb <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01014ce:	89 f2                	mov    %esi,%edx
f01014d0:	09 c2                	or     %eax,%edx
f01014d2:	f6 c2 03             	test   $0x3,%dl
f01014d5:	75 0f                	jne    f01014e6 <memmove+0x5f>
f01014d7:	f6 c1 03             	test   $0x3,%cl
f01014da:	75 0a                	jne    f01014e6 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f01014dc:	c1 e9 02             	shr    $0x2,%ecx
f01014df:	89 c7                	mov    %eax,%edi
f01014e1:	fc                   	cld    
f01014e2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01014e4:	eb 05                	jmp    f01014eb <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01014e6:	89 c7                	mov    %eax,%edi
f01014e8:	fc                   	cld    
f01014e9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01014eb:	5e                   	pop    %esi
f01014ec:	5f                   	pop    %edi
f01014ed:	5d                   	pop    %ebp
f01014ee:	c3                   	ret    

f01014ef <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01014ef:	55                   	push   %ebp
f01014f0:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f01014f2:	ff 75 10             	pushl  0x10(%ebp)
f01014f5:	ff 75 0c             	pushl  0xc(%ebp)
f01014f8:	ff 75 08             	pushl  0x8(%ebp)
f01014fb:	e8 87 ff ff ff       	call   f0101487 <memmove>
}
f0101500:	c9                   	leave  
f0101501:	c3                   	ret    

f0101502 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0101502:	55                   	push   %ebp
f0101503:	89 e5                	mov    %esp,%ebp
f0101505:	56                   	push   %esi
f0101506:	53                   	push   %ebx
f0101507:	8b 45 08             	mov    0x8(%ebp),%eax
f010150a:	8b 55 0c             	mov    0xc(%ebp),%edx
f010150d:	89 c6                	mov    %eax,%esi
f010150f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0101512:	eb 1a                	jmp    f010152e <memcmp+0x2c>
		if (*s1 != *s2)
f0101514:	0f b6 08             	movzbl (%eax),%ecx
f0101517:	0f b6 1a             	movzbl (%edx),%ebx
f010151a:	38 d9                	cmp    %bl,%cl
f010151c:	74 0a                	je     f0101528 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f010151e:	0f b6 c1             	movzbl %cl,%eax
f0101521:	0f b6 db             	movzbl %bl,%ebx
f0101524:	29 d8                	sub    %ebx,%eax
f0101526:	eb 0f                	jmp    f0101537 <memcmp+0x35>
		s1++, s2++;
f0101528:	83 c0 01             	add    $0x1,%eax
f010152b:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010152e:	39 f0                	cmp    %esi,%eax
f0101530:	75 e2                	jne    f0101514 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0101532:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101537:	5b                   	pop    %ebx
f0101538:	5e                   	pop    %esi
f0101539:	5d                   	pop    %ebp
f010153a:	c3                   	ret    

f010153b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f010153b:	55                   	push   %ebp
f010153c:	89 e5                	mov    %esp,%ebp
f010153e:	53                   	push   %ebx
f010153f:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0101542:	89 c1                	mov    %eax,%ecx
f0101544:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f0101547:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f010154b:	eb 0a                	jmp    f0101557 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f010154d:	0f b6 10             	movzbl (%eax),%edx
f0101550:	39 da                	cmp    %ebx,%edx
f0101552:	74 07                	je     f010155b <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0101554:	83 c0 01             	add    $0x1,%eax
f0101557:	39 c8                	cmp    %ecx,%eax
f0101559:	72 f2                	jb     f010154d <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f010155b:	5b                   	pop    %ebx
f010155c:	5d                   	pop    %ebp
f010155d:	c3                   	ret    

f010155e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010155e:	55                   	push   %ebp
f010155f:	89 e5                	mov    %esp,%ebp
f0101561:	57                   	push   %edi
f0101562:	56                   	push   %esi
f0101563:	53                   	push   %ebx
f0101564:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101567:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010156a:	eb 03                	jmp    f010156f <strtol+0x11>
		s++;
f010156c:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010156f:	0f b6 01             	movzbl (%ecx),%eax
f0101572:	3c 20                	cmp    $0x20,%al
f0101574:	74 f6                	je     f010156c <strtol+0xe>
f0101576:	3c 09                	cmp    $0x9,%al
f0101578:	74 f2                	je     f010156c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f010157a:	3c 2b                	cmp    $0x2b,%al
f010157c:	75 0a                	jne    f0101588 <strtol+0x2a>
		s++;
f010157e:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0101581:	bf 00 00 00 00       	mov    $0x0,%edi
f0101586:	eb 11                	jmp    f0101599 <strtol+0x3b>
f0101588:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f010158d:	3c 2d                	cmp    $0x2d,%al
f010158f:	75 08                	jne    f0101599 <strtol+0x3b>
		s++, neg = 1;
f0101591:	83 c1 01             	add    $0x1,%ecx
f0101594:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101599:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f010159f:	75 15                	jne    f01015b6 <strtol+0x58>
f01015a1:	80 39 30             	cmpb   $0x30,(%ecx)
f01015a4:	75 10                	jne    f01015b6 <strtol+0x58>
f01015a6:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01015aa:	75 7c                	jne    f0101628 <strtol+0xca>
		s += 2, base = 16;
f01015ac:	83 c1 02             	add    $0x2,%ecx
f01015af:	bb 10 00 00 00       	mov    $0x10,%ebx
f01015b4:	eb 16                	jmp    f01015cc <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f01015b6:	85 db                	test   %ebx,%ebx
f01015b8:	75 12                	jne    f01015cc <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01015ba:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01015bf:	80 39 30             	cmpb   $0x30,(%ecx)
f01015c2:	75 08                	jne    f01015cc <strtol+0x6e>
		s++, base = 8;
f01015c4:	83 c1 01             	add    $0x1,%ecx
f01015c7:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f01015cc:	b8 00 00 00 00       	mov    $0x0,%eax
f01015d1:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01015d4:	0f b6 11             	movzbl (%ecx),%edx
f01015d7:	8d 72 d0             	lea    -0x30(%edx),%esi
f01015da:	89 f3                	mov    %esi,%ebx
f01015dc:	80 fb 09             	cmp    $0x9,%bl
f01015df:	77 08                	ja     f01015e9 <strtol+0x8b>
			dig = *s - '0';
f01015e1:	0f be d2             	movsbl %dl,%edx
f01015e4:	83 ea 30             	sub    $0x30,%edx
f01015e7:	eb 22                	jmp    f010160b <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f01015e9:	8d 72 9f             	lea    -0x61(%edx),%esi
f01015ec:	89 f3                	mov    %esi,%ebx
f01015ee:	80 fb 19             	cmp    $0x19,%bl
f01015f1:	77 08                	ja     f01015fb <strtol+0x9d>
			dig = *s - 'a' + 10;
f01015f3:	0f be d2             	movsbl %dl,%edx
f01015f6:	83 ea 57             	sub    $0x57,%edx
f01015f9:	eb 10                	jmp    f010160b <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f01015fb:	8d 72 bf             	lea    -0x41(%edx),%esi
f01015fe:	89 f3                	mov    %esi,%ebx
f0101600:	80 fb 19             	cmp    $0x19,%bl
f0101603:	77 16                	ja     f010161b <strtol+0xbd>
			dig = *s - 'A' + 10;
f0101605:	0f be d2             	movsbl %dl,%edx
f0101608:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f010160b:	3b 55 10             	cmp    0x10(%ebp),%edx
f010160e:	7d 0b                	jge    f010161b <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f0101610:	83 c1 01             	add    $0x1,%ecx
f0101613:	0f af 45 10          	imul   0x10(%ebp),%eax
f0101617:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f0101619:	eb b9                	jmp    f01015d4 <strtol+0x76>

	if (endptr)
f010161b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f010161f:	74 0d                	je     f010162e <strtol+0xd0>
		*endptr = (char *) s;
f0101621:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101624:	89 0e                	mov    %ecx,(%esi)
f0101626:	eb 06                	jmp    f010162e <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0101628:	85 db                	test   %ebx,%ebx
f010162a:	74 98                	je     f01015c4 <strtol+0x66>
f010162c:	eb 9e                	jmp    f01015cc <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f010162e:	89 c2                	mov    %eax,%edx
f0101630:	f7 da                	neg    %edx
f0101632:	85 ff                	test   %edi,%edi
f0101634:	0f 45 c2             	cmovne %edx,%eax
}
f0101637:	5b                   	pop    %ebx
f0101638:	5e                   	pop    %esi
f0101639:	5f                   	pop    %edi
f010163a:	5d                   	pop    %ebp
f010163b:	c3                   	ret    
f010163c:	66 90                	xchg   %ax,%ax
f010163e:	66 90                	xchg   %ax,%ax

f0101640 <__udivdi3>:
f0101640:	55                   	push   %ebp
f0101641:	57                   	push   %edi
f0101642:	56                   	push   %esi
f0101643:	53                   	push   %ebx
f0101644:	83 ec 1c             	sub    $0x1c,%esp
f0101647:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f010164b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f010164f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f0101653:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0101657:	85 f6                	test   %esi,%esi
f0101659:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010165d:	89 ca                	mov    %ecx,%edx
f010165f:	89 f8                	mov    %edi,%eax
f0101661:	75 3d                	jne    f01016a0 <__udivdi3+0x60>
f0101663:	39 cf                	cmp    %ecx,%edi
f0101665:	0f 87 c5 00 00 00    	ja     f0101730 <__udivdi3+0xf0>
f010166b:	85 ff                	test   %edi,%edi
f010166d:	89 fd                	mov    %edi,%ebp
f010166f:	75 0b                	jne    f010167c <__udivdi3+0x3c>
f0101671:	b8 01 00 00 00       	mov    $0x1,%eax
f0101676:	31 d2                	xor    %edx,%edx
f0101678:	f7 f7                	div    %edi
f010167a:	89 c5                	mov    %eax,%ebp
f010167c:	89 c8                	mov    %ecx,%eax
f010167e:	31 d2                	xor    %edx,%edx
f0101680:	f7 f5                	div    %ebp
f0101682:	89 c1                	mov    %eax,%ecx
f0101684:	89 d8                	mov    %ebx,%eax
f0101686:	89 cf                	mov    %ecx,%edi
f0101688:	f7 f5                	div    %ebp
f010168a:	89 c3                	mov    %eax,%ebx
f010168c:	89 d8                	mov    %ebx,%eax
f010168e:	89 fa                	mov    %edi,%edx
f0101690:	83 c4 1c             	add    $0x1c,%esp
f0101693:	5b                   	pop    %ebx
f0101694:	5e                   	pop    %esi
f0101695:	5f                   	pop    %edi
f0101696:	5d                   	pop    %ebp
f0101697:	c3                   	ret    
f0101698:	90                   	nop
f0101699:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01016a0:	39 ce                	cmp    %ecx,%esi
f01016a2:	77 74                	ja     f0101718 <__udivdi3+0xd8>
f01016a4:	0f bd fe             	bsr    %esi,%edi
f01016a7:	83 f7 1f             	xor    $0x1f,%edi
f01016aa:	0f 84 98 00 00 00    	je     f0101748 <__udivdi3+0x108>
f01016b0:	bb 20 00 00 00       	mov    $0x20,%ebx
f01016b5:	89 f9                	mov    %edi,%ecx
f01016b7:	89 c5                	mov    %eax,%ebp
f01016b9:	29 fb                	sub    %edi,%ebx
f01016bb:	d3 e6                	shl    %cl,%esi
f01016bd:	89 d9                	mov    %ebx,%ecx
f01016bf:	d3 ed                	shr    %cl,%ebp
f01016c1:	89 f9                	mov    %edi,%ecx
f01016c3:	d3 e0                	shl    %cl,%eax
f01016c5:	09 ee                	or     %ebp,%esi
f01016c7:	89 d9                	mov    %ebx,%ecx
f01016c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01016cd:	89 d5                	mov    %edx,%ebp
f01016cf:	8b 44 24 08          	mov    0x8(%esp),%eax
f01016d3:	d3 ed                	shr    %cl,%ebp
f01016d5:	89 f9                	mov    %edi,%ecx
f01016d7:	d3 e2                	shl    %cl,%edx
f01016d9:	89 d9                	mov    %ebx,%ecx
f01016db:	d3 e8                	shr    %cl,%eax
f01016dd:	09 c2                	or     %eax,%edx
f01016df:	89 d0                	mov    %edx,%eax
f01016e1:	89 ea                	mov    %ebp,%edx
f01016e3:	f7 f6                	div    %esi
f01016e5:	89 d5                	mov    %edx,%ebp
f01016e7:	89 c3                	mov    %eax,%ebx
f01016e9:	f7 64 24 0c          	mull   0xc(%esp)
f01016ed:	39 d5                	cmp    %edx,%ebp
f01016ef:	72 10                	jb     f0101701 <__udivdi3+0xc1>
f01016f1:	8b 74 24 08          	mov    0x8(%esp),%esi
f01016f5:	89 f9                	mov    %edi,%ecx
f01016f7:	d3 e6                	shl    %cl,%esi
f01016f9:	39 c6                	cmp    %eax,%esi
f01016fb:	73 07                	jae    f0101704 <__udivdi3+0xc4>
f01016fd:	39 d5                	cmp    %edx,%ebp
f01016ff:	75 03                	jne    f0101704 <__udivdi3+0xc4>
f0101701:	83 eb 01             	sub    $0x1,%ebx
f0101704:	31 ff                	xor    %edi,%edi
f0101706:	89 d8                	mov    %ebx,%eax
f0101708:	89 fa                	mov    %edi,%edx
f010170a:	83 c4 1c             	add    $0x1c,%esp
f010170d:	5b                   	pop    %ebx
f010170e:	5e                   	pop    %esi
f010170f:	5f                   	pop    %edi
f0101710:	5d                   	pop    %ebp
f0101711:	c3                   	ret    
f0101712:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101718:	31 ff                	xor    %edi,%edi
f010171a:	31 db                	xor    %ebx,%ebx
f010171c:	89 d8                	mov    %ebx,%eax
f010171e:	89 fa                	mov    %edi,%edx
f0101720:	83 c4 1c             	add    $0x1c,%esp
f0101723:	5b                   	pop    %ebx
f0101724:	5e                   	pop    %esi
f0101725:	5f                   	pop    %edi
f0101726:	5d                   	pop    %ebp
f0101727:	c3                   	ret    
f0101728:	90                   	nop
f0101729:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101730:	89 d8                	mov    %ebx,%eax
f0101732:	f7 f7                	div    %edi
f0101734:	31 ff                	xor    %edi,%edi
f0101736:	89 c3                	mov    %eax,%ebx
f0101738:	89 d8                	mov    %ebx,%eax
f010173a:	89 fa                	mov    %edi,%edx
f010173c:	83 c4 1c             	add    $0x1c,%esp
f010173f:	5b                   	pop    %ebx
f0101740:	5e                   	pop    %esi
f0101741:	5f                   	pop    %edi
f0101742:	5d                   	pop    %ebp
f0101743:	c3                   	ret    
f0101744:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101748:	39 ce                	cmp    %ecx,%esi
f010174a:	72 0c                	jb     f0101758 <__udivdi3+0x118>
f010174c:	31 db                	xor    %ebx,%ebx
f010174e:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0101752:	0f 87 34 ff ff ff    	ja     f010168c <__udivdi3+0x4c>
f0101758:	bb 01 00 00 00       	mov    $0x1,%ebx
f010175d:	e9 2a ff ff ff       	jmp    f010168c <__udivdi3+0x4c>
f0101762:	66 90                	xchg   %ax,%ax
f0101764:	66 90                	xchg   %ax,%ax
f0101766:	66 90                	xchg   %ax,%ax
f0101768:	66 90                	xchg   %ax,%ax
f010176a:	66 90                	xchg   %ax,%ax
f010176c:	66 90                	xchg   %ax,%ax
f010176e:	66 90                	xchg   %ax,%ax

f0101770 <__umoddi3>:
f0101770:	55                   	push   %ebp
f0101771:	57                   	push   %edi
f0101772:	56                   	push   %esi
f0101773:	53                   	push   %ebx
f0101774:	83 ec 1c             	sub    $0x1c,%esp
f0101777:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010177b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f010177f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0101783:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0101787:	85 d2                	test   %edx,%edx
f0101789:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010178d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101791:	89 f3                	mov    %esi,%ebx
f0101793:	89 3c 24             	mov    %edi,(%esp)
f0101796:	89 74 24 04          	mov    %esi,0x4(%esp)
f010179a:	75 1c                	jne    f01017b8 <__umoddi3+0x48>
f010179c:	39 f7                	cmp    %esi,%edi
f010179e:	76 50                	jbe    f01017f0 <__umoddi3+0x80>
f01017a0:	89 c8                	mov    %ecx,%eax
f01017a2:	89 f2                	mov    %esi,%edx
f01017a4:	f7 f7                	div    %edi
f01017a6:	89 d0                	mov    %edx,%eax
f01017a8:	31 d2                	xor    %edx,%edx
f01017aa:	83 c4 1c             	add    $0x1c,%esp
f01017ad:	5b                   	pop    %ebx
f01017ae:	5e                   	pop    %esi
f01017af:	5f                   	pop    %edi
f01017b0:	5d                   	pop    %ebp
f01017b1:	c3                   	ret    
f01017b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01017b8:	39 f2                	cmp    %esi,%edx
f01017ba:	89 d0                	mov    %edx,%eax
f01017bc:	77 52                	ja     f0101810 <__umoddi3+0xa0>
f01017be:	0f bd ea             	bsr    %edx,%ebp
f01017c1:	83 f5 1f             	xor    $0x1f,%ebp
f01017c4:	75 5a                	jne    f0101820 <__umoddi3+0xb0>
f01017c6:	3b 54 24 04          	cmp    0x4(%esp),%edx
f01017ca:	0f 82 e0 00 00 00    	jb     f01018b0 <__umoddi3+0x140>
f01017d0:	39 0c 24             	cmp    %ecx,(%esp)
f01017d3:	0f 86 d7 00 00 00    	jbe    f01018b0 <__umoddi3+0x140>
f01017d9:	8b 44 24 08          	mov    0x8(%esp),%eax
f01017dd:	8b 54 24 04          	mov    0x4(%esp),%edx
f01017e1:	83 c4 1c             	add    $0x1c,%esp
f01017e4:	5b                   	pop    %ebx
f01017e5:	5e                   	pop    %esi
f01017e6:	5f                   	pop    %edi
f01017e7:	5d                   	pop    %ebp
f01017e8:	c3                   	ret    
f01017e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01017f0:	85 ff                	test   %edi,%edi
f01017f2:	89 fd                	mov    %edi,%ebp
f01017f4:	75 0b                	jne    f0101801 <__umoddi3+0x91>
f01017f6:	b8 01 00 00 00       	mov    $0x1,%eax
f01017fb:	31 d2                	xor    %edx,%edx
f01017fd:	f7 f7                	div    %edi
f01017ff:	89 c5                	mov    %eax,%ebp
f0101801:	89 f0                	mov    %esi,%eax
f0101803:	31 d2                	xor    %edx,%edx
f0101805:	f7 f5                	div    %ebp
f0101807:	89 c8                	mov    %ecx,%eax
f0101809:	f7 f5                	div    %ebp
f010180b:	89 d0                	mov    %edx,%eax
f010180d:	eb 99                	jmp    f01017a8 <__umoddi3+0x38>
f010180f:	90                   	nop
f0101810:	89 c8                	mov    %ecx,%eax
f0101812:	89 f2                	mov    %esi,%edx
f0101814:	83 c4 1c             	add    $0x1c,%esp
f0101817:	5b                   	pop    %ebx
f0101818:	5e                   	pop    %esi
f0101819:	5f                   	pop    %edi
f010181a:	5d                   	pop    %ebp
f010181b:	c3                   	ret    
f010181c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101820:	8b 34 24             	mov    (%esp),%esi
f0101823:	bf 20 00 00 00       	mov    $0x20,%edi
f0101828:	89 e9                	mov    %ebp,%ecx
f010182a:	29 ef                	sub    %ebp,%edi
f010182c:	d3 e0                	shl    %cl,%eax
f010182e:	89 f9                	mov    %edi,%ecx
f0101830:	89 f2                	mov    %esi,%edx
f0101832:	d3 ea                	shr    %cl,%edx
f0101834:	89 e9                	mov    %ebp,%ecx
f0101836:	09 c2                	or     %eax,%edx
f0101838:	89 d8                	mov    %ebx,%eax
f010183a:	89 14 24             	mov    %edx,(%esp)
f010183d:	89 f2                	mov    %esi,%edx
f010183f:	d3 e2                	shl    %cl,%edx
f0101841:	89 f9                	mov    %edi,%ecx
f0101843:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101847:	8b 54 24 0c          	mov    0xc(%esp),%edx
f010184b:	d3 e8                	shr    %cl,%eax
f010184d:	89 e9                	mov    %ebp,%ecx
f010184f:	89 c6                	mov    %eax,%esi
f0101851:	d3 e3                	shl    %cl,%ebx
f0101853:	89 f9                	mov    %edi,%ecx
f0101855:	89 d0                	mov    %edx,%eax
f0101857:	d3 e8                	shr    %cl,%eax
f0101859:	89 e9                	mov    %ebp,%ecx
f010185b:	09 d8                	or     %ebx,%eax
f010185d:	89 d3                	mov    %edx,%ebx
f010185f:	89 f2                	mov    %esi,%edx
f0101861:	f7 34 24             	divl   (%esp)
f0101864:	89 d6                	mov    %edx,%esi
f0101866:	d3 e3                	shl    %cl,%ebx
f0101868:	f7 64 24 04          	mull   0x4(%esp)
f010186c:	39 d6                	cmp    %edx,%esi
f010186e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0101872:	89 d1                	mov    %edx,%ecx
f0101874:	89 c3                	mov    %eax,%ebx
f0101876:	72 08                	jb     f0101880 <__umoddi3+0x110>
f0101878:	75 11                	jne    f010188b <__umoddi3+0x11b>
f010187a:	39 44 24 08          	cmp    %eax,0x8(%esp)
f010187e:	73 0b                	jae    f010188b <__umoddi3+0x11b>
f0101880:	2b 44 24 04          	sub    0x4(%esp),%eax
f0101884:	1b 14 24             	sbb    (%esp),%edx
f0101887:	89 d1                	mov    %edx,%ecx
f0101889:	89 c3                	mov    %eax,%ebx
f010188b:	8b 54 24 08          	mov    0x8(%esp),%edx
f010188f:	29 da                	sub    %ebx,%edx
f0101891:	19 ce                	sbb    %ecx,%esi
f0101893:	89 f9                	mov    %edi,%ecx
f0101895:	89 f0                	mov    %esi,%eax
f0101897:	d3 e0                	shl    %cl,%eax
f0101899:	89 e9                	mov    %ebp,%ecx
f010189b:	d3 ea                	shr    %cl,%edx
f010189d:	89 e9                	mov    %ebp,%ecx
f010189f:	d3 ee                	shr    %cl,%esi
f01018a1:	09 d0                	or     %edx,%eax
f01018a3:	89 f2                	mov    %esi,%edx
f01018a5:	83 c4 1c             	add    $0x1c,%esp
f01018a8:	5b                   	pop    %ebx
f01018a9:	5e                   	pop    %esi
f01018aa:	5f                   	pop    %edi
f01018ab:	5d                   	pop    %ebp
f01018ac:	c3                   	ret    
f01018ad:	8d 76 00             	lea    0x0(%esi),%esi
f01018b0:	29 f9                	sub    %edi,%ecx
f01018b2:	19 d6                	sbb    %edx,%esi
f01018b4:	89 74 24 04          	mov    %esi,0x4(%esp)
f01018b8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01018bc:	e9 18 ff ff ff       	jmp    f01017d9 <__umoddi3+0x69>
