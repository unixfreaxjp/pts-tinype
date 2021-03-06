;
; hh6a.nasm: tiny and ultraportable Win32 PE .exe
; Compile: nasm -O0 -f bin -o hh6a.exe hh6a.nasm
;
; This works on Windows NT 3.1--Windows 10.
;

; Asserts that we are at offset %1 from the beginning of the input file
%macro aa 1
times $-(%1) times 0 nop
times (%1)-$ times 0 nop
%endmacro

bits 32
cpu 386

IMAGE_DOS_HEADER:
aa $$+0x0000
.mz_signature: dw 'MZ';
image_size_lo: dw IMAGE_NT_HEADERS+0x10  ; Should be IMAGE_NT_HEADERS minimum.
dd 0x00000003, 0x00000004, 0x0000ffff
aa $$+0x0010
dd 0x000000b8, 0x00000000, 0x00000040, 0x00000000
aa $$+0x0020
dd 0x00000000, 0x00000000, 0x00000000, 0x00000000
aa $$+0x0030
dd 0x00000000, 0x00000000, 0x00000000, IMAGE_NT_HEADERS
aa $$+0x0040
dd 0x0eba1f0e, 0xcd09b400, 0x4c01b821
int 0x21
db 'This program cannot be run in DOS mode.', 13, 13, 10, '$'
times  0x80-($-$$) db 0  ; !! This can be decreased by making the PE stub smaller.

IMAGE_BASE equ 0x00400000

IMAGE_NT_HEADERS:
db 'PE', 0, 0

IMAGE_FILE_HEADER:
Machine: dw 0x14c  ; IMAGE_FILE_MACHINE_I386
NumberOfSections: dw (IMAGE_SECTION_HEADER_end-IMAGE_SECTION_HEADER)/40
TimeDateStamp: dd 0
PointerToSymbolTable: dd 0
NumberOfSymbols: dd 0
SizeOfOptionalHeader: dw IMAGE_OPTIONAL_HEADER32_end-IMAGE_OPTIONAL_HEADER32
Characteristics: dw 0x030f

IMAGE_OPTIONAL_HEADER32:
Magic: dw 0x10b  ; IMAGE_NT_OPTIONAL_HDR32_MAGIC
MajorLinkerVersion: db 6
MinorLinkerVersion: db 0
SizeOfCode: dd 0x00000000
SizeOfInitializedData: dd 0x00000000
SizeOfUninitializedData: dd 0x00000000
AddressOfEntryPoint: dd _start+(VADDR_TEXT-SECTION_TEXT)  ; Also called starting address.
BaseOfCode: dd VADDR_TEXT
BaseOfData: dd VADDR_DATA
ImageBase: dd IMAGE_BASE
SectionAlignment: dd 0x1000  ; Single allowed value for Windows XP.
FileAlignment: dd 0x200  ; Minimum value for Windows NT 3.1.
MajorOperatingSystemVersion: dw 4
MinorOperatingSystemVersion: dw 0
MajorImageVersion: dw 0
MinorImageVersion: dw 0
MajorSubsystemVersion: dw 3   ; Windows NT 3.1.
MinorSubsystemVersion: dw 10  ; Windows NT 3.1.
Win32VersionValue: dd 0
BSS_SIZE EQU 1  ; Why?
SizeOfImage: dd ((SECTION_TEXT_end-SECTION_TEXT+4095)&~4095)+((SECTION_DATA_end-SECTION_DATA+4095)&~4095)+((BSS_SIZE+4095)&~4095)
SizeOfHeaders: dd HEADERS_end_aligned
CheckSum: dd 0xd43c  ; !! Change to 0 to avoid checking.
Subsystem: dw 3  ; IMAGE_SUBSYSTEM_WINDOWS_CUI; gcc -mconsole
DllCharacteristics: dw 0
SizeOfStackReserve: dd 0x00100000
SizeOfStackCommit: dd 0x00001000
SizeOfHeapReserve: dd 0x100000  ; Why not 0?
SizeOfHeapCommit: dd 0x1000  ; Why not 0?
LoaderFlags: dd 0
NumberOfRvaAndSizes: dd (IMAGE_DATA_DIRECTORY_end-IMAGE_DATA_DIRECTORY)/8
IMAGE_DATA_DIRECTORY:
IMAGE_DIRECTORY_ENTRY_EXPORT:
.VirtualAddress: dd 0x00000000
.Size: dd 0x00000000
IMAGE_DIRECTORY_ENTRY_IMPORT:
.VirtualAddress: dd IMAGE_IMPORT_DESCRIPTORS+(VADDR_DATA-SECTION_DATA)
.Size: dd IMAGE_IMPORT_DESCRIPTORS_end-IMAGE_IMPORT_DESCRIPTORS
IMAGE_DIRECTORY_ENTRY_RESOURCE:
.VirtualAddress: dd 0x00000000
.Size: dd 0x00000000
IMAGE_DIRECTORY_ENTRY_EXCEPTION:
.VirtualAddress: dd 0
.Size: dd 0
IMAGE_DIRECTORY_ENTRY_SECURITY:
.VirtualAddress: dd 0
.Size: dd 0
IMAGE_DIRECTORY_ENTRY_BASERELOC:
.VirtualAddress: dd 0
.Size: dd 0
IMAGE_DIRECTORY_ENTRY_DEBUG:
.VirtualAddress: dd 0
.Size: dd 0
IMAGE_DIRECTORY_ENTRY_ARCHITECTURE:
.VirtualAddress: dd 0
.Size: dd 0
IMAGE_DIRECTORY_ENTRY_GLOBALPTR:
.VirtualAddress: dd 0
.Size: dd 0
IMAGE_DIRECTORY_ENTRY_TLS:
.VirtualAddress: dd 0
.Size: dd 0
IMAGE_DIRECTORY_ENTRY_LOAD_CONFIG:
.VirtualAddress: dd 0
.Size: dd 0
IMAGE_DIRECTORY_ENTRY_BOUND_IMPORT:
.VirtualAddress: dd 0
.Size: dd 0
IMAGE_DIRECTORY_ENTRY_IAT:  ; Import address table.
.VirtualAddress: dd IMPORT_ADDRESS_TABLE+(VADDR_DATA-SECTION_DATA)
.Size: dd IMPORT_ADDRESS_TABLE_end-IMPORT_ADDRESS_TABLE
IMAGE_DIRECTORY_ENTRY_DELAY_IMPORT:
.VirtualAddress: dd 0
.Size: dd 0
IMAGE_DIRECTORY_ENTRY_COM_DESCRIPTOR:  ; Nonzero for .NET .exe.
.VirtualAddress: dd 0
.Size: dd 0
IMAGE_DIRECTORY_ENTRY_RESERVED:
.VirtualAddress: dd 0
.Size: dd 0

IMAGE_DATA_DIRECTORY_end:
IMAGE_OPTIONAL_HEADER32_end:

aa $$+0x0178
IMAGE_SECTION_HEADER:
IMAGE_SECTION_HEADER__0:
.Name: db '.text'
times ($$-$)&7 db 0
.VirtualSize: dd SECTION_TEXT_end-SECTION_TEXT
VADDR_TEXT equ 0x1000
.VirtualAddress: dd VADDR_TEXT
.SizeOfRawData: dd SECTION_TEXT_end_aligned-SECTION_TEXT
.PointerToRawData: dd SECTION_TEXT
.PointerToRelocations: dd 0
.PointerToLineNumbers: dd 0
.NumberOfRelocations: dw 0
.NumberOfLineNumbers: dw 0
IMAGE_SCN_CNT_CODE equ 0x20
IMAGE_SCN_MEM_EXECUTE equ 0x20000000
IMAGE_SCN_MEM_READ equ 0x40000000
.Characteristics: dd IMAGE_SCN_CNT_CODE|IMAGE_SCN_MEM_EXECUTE|IMAGE_SCN_MEM_READ

IMAGE_SECTION_HEADER__1:
.Name: db '.data'
times ($$-$)&7 db 0
.VirtualSize: dd SECTION_DATA_end-SECTION_DATA
VADDR_DATA equ 0x2000
.VirtualAddress: dd VADDR_DATA
.SizeOfRawData: dd SECTION_DATA_end_aligned-SECTION_DATA  ; !! Can we decrease this and make the file smaller for Windows NT 3.1?
.PointerToRawData: dd SECTION_DATA
.PointerToRelocations: dd 0
.PointerToLineNumbers: dd 0
.NumberOfRelocations: dw 0
.NumberOfLineNumbers: dw 0
IMAGE_SCN_CNT_INITIALIZED_DATA equ 0x40
IMAGE_SCN_MEM_WRITE equ 0x80000000
.Characteristics: dd IMAGE_SCN_CNT_INITIALIZED_DATA|IMAGE_SCN_MEM_WRITE|IMAGE_SCN_MEM_READ

IMAGE_SECTION_HEADER_end:
times ($$-$)&511 db 0
HEADERS_end_aligned:

SECTION_TEXT:
aa $$+0x0200
_start:
push ebp
mov ebp,esp
sub esp,0x8
nop
mov eax, -11  ; STD_OUTPUT_HANDLE.
push eax
call __call__GetStdHandle@4
mov [ebp-0x8], eax
mov eax, 0
push eax
lea eax, [ebp-0x4]
push eax
mov eax, 0xf
push eax
mov eax, message+(IMAGE_BASE+VADDR_DATA-SECTION_DATA)
push eax
mov eax, [ebp-0x8]
push eax
call __call__WriteFile@20
mov eax, 0  ; EXIT_SUCCESS.
push eax
call __call__ExitProcess@4
leave
ret

IMPORTED_CALLS:
times ($$-$)&7 db 0
; TODO(pts): Replace these with indirect `call [...]'.
__call__GetStdHandle@4:
;dd 0x203825ff, 0x00000040
jmp [__imp__GetStdHandle@4+(IMAGE_BASE+VADDR_DATA-SECTION_DATA)]
dw 0
__call__WriteFile@20:
jmp [__imp__WriteFile@20+(IMAGE_BASE+VADDR_DATA-SECTION_DATA)]
dw 0
__call__ExitProcess@4:
jmp [__imp__ExitProcess@4+(IMAGE_BASE+VADDR_DATA-SECTION_DATA)]
dw 0
SECTION_TEXT_end:
times ($$-$)&511 db 0
SECTION_TEXT_end_aligned:

SECTION_DATA:
aa $$+0x0400
message:
db 'Hello, World!', 13, 10, 0
aa $$+0x0410
IMAGE_IMPORT_DESCRIPTORS:
IMAGE_IMPORT_DESCRIPTOR_0:
.OriginalFirstThunk: dd IMPORTED_SYMBOL_NAMES+(VADDR_DATA-SECTION_DATA)
.TimeDateStamp: dd 0
.ForwarderChain: dd 0
.Name: dd NAME_KERNEL32_DLL+(VADDR_DATA-SECTION_DATA)
.FirstThunk: dd IMPORT_ADDRESS_TABLE+(VADDR_DATA-SECTION_DATA)
dd 0, 0, 0, 0, 0  ; !! Why is this padding needed?
IMAGE_IMPORT_DESCRIPTORS_end:

aa $$+0x0438
IMPORT_ADDRESS_TABLE:  ; Import address table. Modified by the PE loader before jumping to _entry.
__imp__GetStdHandle@4: dd NAME_GetStdHandle+(VADDR_DATA-SECTION_DATA)
__imp__WriteFile@20: dd NAME_WriteFile+(VADDR_DATA-SECTION_DATA)
__imp__ExitProcess@4 dd NAME_ExitProcess+(VADDR_DATA-SECTION_DATA)
dd 0  ; Marks end-of-list.
IMPORT_ADDRESS_TABLE_end:

aa $$+0x0448
IMPORTED_SYMBOL_NAMES:
; !! To make it smaller, reuse IMPORT_ADDRESS_TABLE for this.
dd NAME_GetStdHandle+(VADDR_DATA-SECTION_DATA)
dd NAME_WriteFile+(VADDR_DATA-SECTION_DATA)
dd NAME_ExitProcess+(VADDR_DATA-SECTION_DATA)
dd 0  ; Marks end-of-list.
aa $$+0x0458
NAME_KERNEL32_DLL: db 'kernel32.dll', 0
aa $$+0x0465
; The `0, 0, ' is the .Hint.
NAME_GetStdHandle: db 0, 0, 'GetStdHandle', 0
NAME_WriteFile: db 0, 0, 'WriteFile', 0
NAME_ExitProcess: db 0, 0, 'ExitProcess', 0
dd 0  ; Why is this needed? A dw is not enough.
times ($$-$)&15 db 0
aa $$+0x04a0
SECTION_DATA_end:
times ($$-$)&511 db 0
SECTION_DATA_end_aligned:

aa $$+0x0600
