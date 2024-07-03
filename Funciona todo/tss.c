/* ** por compatibilidad se omiten tildes **
================================================================================
 TALLER System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================

  Definicion de estructuras para administrar tareas
*/

#include "tss.h"
#include "defines.h"
#include "kassert.h"
#include "mmu.h"

//TSS de la tarea inicial (sólo se usa para almacenar el estado del procesador al hacer el salto a la tarea idle).
tss_t tss_initial = {0};


// TSS de la tarea idle
tss_t tss_idle = {
  .ss1 = 0,
  .cr3 = KERNEL_PAGE_DIR,
  .eip = TASK_IDLE_CODE_START,
  .eflags = EFLAGS_IF,
  .esp = KERNEL_STACK,
  .ebp = KERNEL_STACK,
  .cs = GDT_CODE_0_SEL,
  .ds = GDT_DATA_0_SEL,
  .es = GDT_DATA_0_SEL,
  .gs = GDT_DATA_0_SEL,
  .fs = GDT_DATA_0_SEL,
  .ss = GDT_DATA_0_SEL,
};


// Lista de tss, de aquí se cargan (guardan) las tss al hacer un cambio de contexto
tss_t tss_tasks[MAX_TASKS] = {0};


gdt_entry_t tss_gdt_entry_for_task(tss_t* tss) {
  return (gdt_entry_t) {
    .g = 0,
    .limit_15_0 = sizeof(tss_t) - 1,
    .limit_19_16 = 0x0,
    .base_15_0 = GDT_BASE_LOW(tss),
    .base_23_16 = GDT_BASE_MID(tss),
    .base_31_24 = GDT_BASE_HIGH(tss),
    .p = 1,
    .type = DESC_TYPE_32BIT_TSS,
    .s = DESC_SYSTEM,
    .dpl = 0,
  };
}


//Define el valor de la TSS para el indice task_id
void tss_set(tss_t tss, int8_t task_id) {

  kassert(task_id >= 0 && task_id < MAX_TASKS, "Invalid task_id");

  tss_tasks[task_id] = tss;
}


//Crea una TSS con los valores por defecto y el EIP en code_start
tss_t tss_create_user_task(paddr_t code_start) {

/*  ENUNCIADO
  Es correcta esta llamada a mmu_init_task_dir?
  uint32_t cr3 = mmu_init_task_dir(code_start);

  Si es correcta, porque esa funcion inicializa las estructuras de paginacion que nesecita una tarea nueva y 
  devuelve el puntero al directorio de tabla de paginas.

  Asignar valor inicial de la pila de la tarea
  vaddr_t stack = ??;

  Dir. virtual de comienzo del codigo
  vaddr_t code_virt = ??;

  Pedir pagina de kernel para la pila de nivel cero
  vaddr_t stack0 = ??;

  A donde deberia apuntar la pila de nivel cero?
  vaddr_t esp0 = stack0 + ??;
*/

  //inicializa las estructuras de paginacion de la nueva tarea.
  uint32_t cr3 = mmu_init_task_dir(code_start);

  //Inicializamos la base del stack
  vaddr_t stack = TASK_STACK_BASE;

  //Inicializamos la direccion desde la cual inician las paginas de codigo
  vaddr_t code_virt = TASK_CODE_VIRTUAL;
  
  //Direccion en la que comienza la pagina del kernel
  vaddr_t stack0 = mmu_next_free_kernel_page();

  //Como esp0 es un puntero a la una pagina del kernel que le vamos a asingnar al stack y el stack crece hacia direcciones menores de memoria, 
  //Entonces como stack0 apunta al principio de los 4kb de la proxima pagina de kernel libre, si el puntero a stack apuntace a stack0 el stack 
  //empezaria a crecer sobre la pagina anterior que no le fue asignada, dejando asi vacia la pagina que si le fue asignada, por eso el stack 
  //pointer debe apuntar a la direccion en la que empieza la pagina asignada al stack + 4096 es decir al ultimo byte de esa pagina, para que 
  //asi pueda crecer dentro de la pagina que le fue asignada.
  vaddr_t esp0 = stack0 + PAGE_SIZE;

  return (tss_t) {
        .ptl = 0,
        .unused0 = 0,
        .esp0 = esp0,
        .ss0 = GDT_DATA_0_SEL,
        .unused1 = 0,
        .esp1 = 0,
        .ss1 = 0,
        .unused2 = 0,
        .esp2 = 0,
        .ss2 = 0,
        .unused3 = 0,
        .cr3 = cr3,
        .eip = code_virt,
        .eflags = EFLAGS_IF,
        .eax = 0,
        .ecx = 0,
        .edx = 0,
        .ebx = 0,
        .esp = stack,
        .ebp = stack,
        .esi = 0,
        .edi = 0,
        .es = GDT_DATA_3_SEL,
        .unused4 = 0,
        .cs = GDT_CODE_3_SEL,
        .unused5 = 0,
        .ss = GDT_DATA_3_SEL,
        .unused6 = 0,
        .ds = GDT_DATA_3_SEL,
        .unused7 = 0,
        .fs = GDT_DATA_3_SEL,
        .unused8 = 0,
        .gs = GDT_DATA_3_SEL,
        .unused9 = 0,
        .ldt = 0,
        .unused10 = 0,
        .dtrap = 0,
        .iomap = 0
  };
}



//Inicializa las primeras entradas de tss (inicial y idle)
void tss_init(void) {

  tss_t *idle = &tss_idle;
  tss_t *init = &tss_initial;
  
  // COMPLETAR
  gdt[GDT_IDX_TASK_IDLE] = tss_gdt_entry_for_task(idle);

  gdt[GDT_IDX_TASK_INITIAL] = tss_gdt_entry_for_task(init);
}