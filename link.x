MEMORY
{
    FLASH  : ORIGIN = 0x00000000, LENGTH = 128K /* Note that the 42 version only has 64K*/
    RAM    : ORIGIN = 0x20000000, LENGTH = 16K
}

SECTIONS
{
  PROVIDE(_stack_start = ORIGIN(RAM) + LENGTH(RAM));

  /* ## Sections in FLASH */
  /* ### Vector table */
  .vector_table ORIGIN(FLASH) :
  {
    /* Initial Stack Pointer (SP) value */
    LONG(_stack_start);

    /* Reset vector */
    KEEP(*(.vector_table.reset_vector)); /* this is the `__RESET_VECTOR` symbol */
    __reset_vector = .;

    /* Exceptions */
    KEEP(*(.vector_table.exceptions)); /* this is the `__EXCEPTIONS` symbol */
    __eexceptions = .;

    /* Device specific interrupts */
    KEEP(*(.vector_table.interrupts)); /* this is the `__INTERRUPTS` symbol */
  } > FLASH

  PROVIDE(_stext = ADDR(.vector_table) + SIZEOF(.vector_table));

  /* ### .text */
  .text _stext :
  {
    *(.Reset);

    *(.text .text.*);

    /* The HardFaultTrampoline uses the `b` instruction to enter `HardFault`,
       so must be placed close to it. */
    *(.HardFaultTrampoline);
    *(.HardFault.*);

    . = ALIGN(4); /* Pad .text to the alignment to workaround overlapping load section bug in old lld */
  } > FLASH
  . = ALIGN(4); /* Ensure __etext is aligned if something unaligned is inserted after .text */
  __etext = .; /* Define outside of .text to allow using INSERT AFTER .text */

  /* ### .rodata */
  .rodata __etext : ALIGN(4)
  {
    *(.rodata .rodata.*);

    /* 4-byte align the end (VMA) of this section.
       This is required by LLD to ensure the LMA of the following .data
       section will have the correct alignment. */
    . = ALIGN(4);
  } > FLASH
  . = ALIGN(4); /* Ensure __erodata is aligned if something unaligned is inserted after .rodata */
  __erodata = .;

  /* ### .gnu.sgstubs
     This section contains the TrustZone-M veneers put there by the Arm GNU linker. */
  . = ALIGN(32); /* Security Attribution Unit blocks must be 32 bytes aligned. */
  __veneer_base = ALIGN(4);
  .gnu.sgstubs : ALIGN(4)
  {
    *(.gnu.sgstubs*)
    . = ALIGN(4); /* 4-byte align the end (VMA) of this section */
  } > FLASH
  . = ALIGN(4); /* Ensure __veneer_limit is aligned if something unaligned is inserted after .gnu.sgstubs */
  __veneer_limit = .;

  /* ## Sections in RAM */
  /* ### .data */
  .data : ALIGN(4)
  {
    . = ALIGN(4);
    __sdata = .;
    *(.data .data.*);
    . = ALIGN(4); /* 4-byte align the end (VMA) of this section */
  } > RAM AT>FLASH
  . = ALIGN(4); /* Ensure __edata is aligned if something unaligned is inserted after .data */
  __edata = .;

  /* LMA of .data */
  __sidata = LOADADDR(.data);

  /* ### .bss */
  . = ALIGN(4);
  __sbss = .; /* Define outside of section to include INSERT BEFORE/AFTER symbols */
  .bss (NOLOAD) : ALIGN(4)
  {
    *(.bss .bss.*);
    *(COMMON); /* Uninitialized C statics */
    . = ALIGN(4); /* 4-byte align the end (VMA) of this section */
  } > RAM
  . = ALIGN(4); /* Ensure __ebss is aligned if something unaligned is inserted after .bss */
  __ebss = .;

  /* ### .uninit */
  .uninit (NOLOAD) : ALIGN(4)
  {
    . = ALIGN(4);
    *(.uninit .uninit.*);
    . = ALIGN(4);
  } > RAM

  /* Place the heap right after `.uninit` */
  . = ALIGN(4);
  __sheap = .;

  /* ## .got */
  /* Dynamic relocations are unsupported. This section is only used to detect relocatable code in
     the input files and raise an error if relocatable code is found */
  .got (NOLOAD) :
  {
    KEEP(*(.got .got.*));
  }

  /* ## Discarded sections */
  /DISCARD/ :
  {
    /* Unused exception related info that only wastes space */
    *(.ARM.exidx);
    *(.ARM.exidx.*);
    *(.ARM.extab.*);
  }
}
