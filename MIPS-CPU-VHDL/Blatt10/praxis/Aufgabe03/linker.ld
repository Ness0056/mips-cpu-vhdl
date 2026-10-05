ENTRY(main)

SECTIONS
{
    . = 0x0000;

    /* Der Code beginnt bei 0x0000 und geht bis 0x07FF, also ramElements(0) bis ramElements(511) */
    .text 0x0000 : { *(.text) }

    /* Initialisierte Daten beginnen bei 0x0800 und geht bis 0x0BFF, also ramElements(512) bis ramElements(767) */
    .data 0x0800 : { *(.data) }

    /* Uninitialisierte Daten beginnen bei 0x0C00 und geht bis 0x0FFF, also ramElements(768) bis ramElements(1023) */
    .bss  0x0C00 : { *(.bss) }


    /* Wird benötigt damit Linken funktioniert, enthält die Struktur der ELF Datei */
    .shstrtab : {
       *(.shstrtab)
    }
    /* Alle anderen Sektionen werden entfernt */
    /DISCARD/ : {
      *(*)
    }
}
