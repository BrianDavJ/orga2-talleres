/* ** por compatibilidad se omiten tildes **
================================================================================
 TALLER System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================

  Rutinas del controlador de interrupciones.
*/
#include "pic.h"

#define PIC1_PORT 0x20
#define PIC2_PORT 0xA0

static __inline __attribute__((always_inline)) void outb(uint32_t port,
                                                         uint8_t data) {
  __asm __volatile("outb %0,%w1" : : "a"(data), "d"(port));
}

void pic_finish1(void) { outb(PIC1_PORT, 0x20); }

void pic_finish2(void) {
  outb(PIC1_PORT, 0x20);
  outb(PIC2_PORT, 0x20);
}

// COMPLETAR: implementar pic_reset()
void pic_reset() {
  // remapeo pic1
  outb(PIC1_PORT, 0x11);
  outb(PIC1_PORT+1, 32);
  outb(PIC1_PORT+1, 0X04);
  outb(PIC1_PORT+1, 0X01);
  outb(PIC1_PORT+1, 0xff);
  //remapeo pic2
  outb(PIC2_PORT, 0x11);
  outb(PIC2_PORT+1, 40);
  outb(PIC2_PORT+1, 0X02);
  outb(PIC2_PORT+1, 0X01);
  

}

void pic_enable() {
  outb(PIC1_PORT + 1, 0x00);
  outb(PIC2_PORT + 1, 0x00);
}

void pic_disable() {
  outb(PIC1_PORT + 1, 0xFF);
  outb(PIC2_PORT + 1, 0xFF);
}
