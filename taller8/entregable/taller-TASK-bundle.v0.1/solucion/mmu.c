/* ** por compatibilidad se omiten tildes **
================================================================================
 TRABAJO PRACTICO 3 - System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================

  Definicion de funciones del manejador de memoria
*/

#include "mmu.h"
#include "i386.h"

#include "kassert.h"

#define TASK_CODE_VADDR   0x08000000
#define TASK_STACK_VADDR  0x08003000
#define TASK_SHARED_VADDR 0x08004000

#define PD_ADDRESS  0x25000

static pd_entry_t *kpd = (pd_entry_t *)KERNEL_PAGE_DIR;
static pt_entry_t *kpt = (pt_entry_t *)KERNEL_PAGE_TABLE_0;

static const uint32_t identity_mapping_end = 0x003FFFFF;
static const uint32_t user_memory_pool_end = 0x02FFFFFF;

static paddr_t next_free_kernel_page = 0x100000;
static paddr_t next_free_user_page = 0x400000;

/**
 * kmemset asigna el valor c a un rango de memoria interpretado
 * como un rango de bytes de largo n que comienza en s
 * @param s es el puntero al comienzo del rango de memoria
 * @param c es el valor a asignar en cada byte de s[0..n-1]
 * @param n es el tamaño en bytes a asignar
 * @return devuelve el puntero al rango modificado (alias de s)
 */
static inline void *kmemset(void *s, int c, size_t n)
{
  uint8_t *dst = (uint8_t *)s;
  for (size_t i = 0; i < n; i++)
  {
    dst[i] = c;
  }
  return dst;
}

/**
 * zero_page limpia el contenido de una página que comienza en addr
 * @param addr es la dirección del comienzo de la página a limpiar
 */
static inline void zero_page(paddr_t addr)
{
  kmemset((void *)addr, 0x00, PAGE_SIZE);
}

void mmu_init(void) {}

/**
 * mmu_next_free_kernel_page devuelve la dirección física de la próxima página de kernel disponible.
 * Las páginas se obtienen en forma incremental, siendo la primera: next_free_kernel_page
 * @return devuelve la dirección de memoria de comienzo de la próxima página libre de kernel
 */
paddr_t mmu_next_free_kernel_page(void)
{
  //  if (next_free_kernel_page+0x1000<identity_mapping_end){
  next_free_kernel_page += 0x1000;
  /* }else{
    algo?
  } */

  return (next_free_kernel_page - 0x1000);
}

/**
 * mmu_next_free_user_page devuelve la dirección de la próxima página de usuarix disponible
 * @return devuelve la dirección de memoria de comienzo de la próxima página libre de usuarix
 */
paddr_t mmu_next_free_user_page(void)
{
  next_free_user_page += 0x1000;

  return (next_free_user_page - 0x1000);
}

/**
 * mmu_init_kernel_dir inicializa las estructuras de paginación vinculadas al kernel y
 * realiza el identity mapping
 * @return devuelve la dirección de memoria de la página donde se encuentra el directorio
 * de páginas usado por el kernel
 */
paddr_t mmu_init_kernel_dir(void)
{
  zero_page(KERNEL_PAGE_DIR);
  zero_page(KERNEL_PAGE_TABLE_0);
  kpd[0].attrs = 0x3;
  kpd[0].pt = ((uint32_t)KERNEL_PAGE_TABLE_0) >> 12;
  for (int i = 0; i < 1024; i++)
  {
    kpt[i].attrs = 0x3; // Present y RW
    kpt[i].page = i;
  }

  return KERNEL_PAGE_DIR;
} // rta a pregunta: Hace falta solo una entrada de Directorio de página que me deje configurar la tabla de?

/**
 * mmu_map_page agrega las entradas necesarias a las estructuras de paginación de modo de que
 * la dirección virtual virt se traduzca en la dirección física phy con los atributos definidos en attrs
 * @param cr3 el contenido que se ha de cargar en un registro CR3 al realizar la traducción
 * @param virt la dirección virtual que se ha de traducir en phy
 * @param phy la dirección física que debe ser accedida (dirección de destino)
 * @param attrs los atributos a asignar en la entrada de la tabla de páginas
 */
void mmu_map_page(uint32_t cr3, vaddr_t virt, paddr_t phy, uint32_t attrs)
{
  pd_entry_t *pd = CR3_TO_PAGE_DIR(cr3);           // un puntero a la base del directorio que quiero mappear
  uint32_t directorio_index = VIRT_PAGE_DIR(virt); // la entrada del directorio que contiene la tabla
  uint32_t tabla_index = VIRT_PAGE_TABLE(virt);    // la entrada de tabla que contiene la dirección física

  pt_entry_t *pt = pd[directorio_index].pt;
  if (!(pd[directorio_index].attrs & MMU_P)){
    paddr_t nuevo_pt= mmu_next_free_kernel_page();
    zero_page(nuevo_pt);
    pd[directorio_index].pt=(nuevo_pt>>12);
    pd[directorio_index].attrs = MMU_P;
  }
  pd[directorio_index].attrs |= attrs; // consultar

  pt[tabla_index].attrs=attrs;
  pt[tabla_index].page=phy>>12;
  tlbflush();
}

/**
 * mmu_unmap_page elimina la entrada vinculada a la dirección virt en la tabla de páginas correspondiente
 * @param virt la dirección virtual que se ha de desvincular
 * @return la dirección física de la página desvinculada
 */
paddr_t mmu_unmap_page(uint32_t cr3, vaddr_t virt)
{

    //primero consigo la direc fisica que voy a desvincular, apartir de la virtual, asi devuelvo eso q nos piden/
    //el cr3 me da la direccion de la page directory donde tengo que ir a buscar mi PDE y con eso mi PTE/
    pd_entry_t* cr3_dir =  CR3_TO_PAGE_DIR(cr3); //puntero a la PD
    
    //son los indices a las pd y pt correspondientes de la direccion virtual que nos dan/
    int32_t index_pt = VIRT_PAGE_TABLE(virt);
    int32_t index_pd = VIRT_PAGE_DIR(virt);
    int32_t index_offset = VIRT_PAGE_OFFSET(virt);
    pd_entry_t PDE=cr3_dir[index_pd];
    //vamos a preguntar si esta presente o no, si si lo esta hay que cambiar ese bit por no presente y realizar el tlbflush/
    uint32_t base_pt =  (uint32_t)PDE.pt;  //aca tenemos el atributo PT, que son los 20bits que me dan la base de la PT/
    //ya tenemos la base ahora queremos acceder a la PTE correspondiente/
    uint32_t pt = base_pt + index_pt; //ya tenemos la PTE correspondiente, es decir, nuestro puntero a la iesima pagina/

    pt_entry_t* punter_pt = pt;
    paddr_t base_direc_phy = (uint32_t)punter_pt->page; //base a la direccion fisica/
    paddr_t direc_phy = base_direc_phy + index_offset;  //ya tenemos la direcc que queremos devolver/
    
    if((punter_pt->attrs & MMU_P) == 0x01){ //estoy preguntando si el present esta en 1/
      punter_pt->attrs = punter_pt->attrs && 0xFFE; //0b111111111110/
      tlbflush();
    return direc_phy;  
    } else {
      return 0; //hay que devolver 0 ya que no hay ninguna pagina fisica asociada/
    }
}
#define DST_VIRT_PAGE 0xA00000
#define SRC_VIRT_PAGE 0xB00000

/**
 * copy_page copia el contenido de la página física localizada en la dirección src_addr a la página física ubicada en dst_addr
 * @param dst_addr la dirección a cuya página queremos copiar el contenido
 * @param src_addr la dirección de la página cuyo contenido queremos copiar
 *
 * Esta función mapea ambas páginas a las direcciones SRC_VIRT_PAGE y DST_VIRT_PAGE, respectivamente, realiza
 * la copia y luego desmapea las páginas. Usar la función rcr3 definida en i386.h para obtener el cr3 actual
 */
void copy_page(paddr_t dst_addr, paddr_t src_addr)
{
  pd_entry_t* cr3_actual=rcr3();
  
  mmu_map_page(cr3_actual,DST_VIRT_PAGE,dst_addr,MMU_P | MMU_W);
  mmu_map_page(cr3_actual,SRC_VIRT_PAGE,src_addr,MMU_P);

  uint8_t * src =(uint8_t*)SRC_VIRT_PAGE;
  uint8_t * dst =(uint8_t*)DST_VIRT_PAGE;

 for (int i=0;i<PAGE_SIZE;i++) {
  dst[i] = src[i];
 }
 mmu_unmap_page(cr3_actual,DST_VIRT_PAGE);
 mmu_unmap_page(cr3_actual,SRC_VIRT_PAGE);
 tlbflush();
}

/**
 * mmu_init_task_dir inicializa las estructuras de paginación vinculadas a una tarea cuyo código se encuentra en la dirección phy_start
 * @pararm phy_start es la dirección donde comienzan las dos páginas de código de la tarea asociada a esta llamada
 * @return el contenido que se ha de cargar en un registro CR3 para la tarea asociada a esta llamada
 */
paddr_t mmu_init_task_dir(paddr_t phy_start)
{
  // Primero hacemos el identity mapping del Kernel
  paddr_t cr3_actual=mmu_next_free_kernel_page();
 
  for (int i = 0; i < 1024; i++)
  {
    // pt_f[i].attrs = 0x3; // Present y RW
    // pt_f[i].page = i;
    mmu_map_page(cr3_actual,i>>12,i>>12,0x3);
  }

  paddr_t code_virt=0x08000000;
  paddr_t phy_end=phy_start+PAGE_SIZE;
  
  paddr_t stack_virt=0x08003000;
  paddr_t stack_phy=mmu_next_free_kernel_page();
  
  paddr_t compartido_phy=phy_end+PAGE_SIZE;
  paddr_t compartido_virt=stack_virt+PAGE_SIZE;

  //Mapeo 2 pagínas de código que empieza en phy en la mem_virtual designada
  mmu_map_page(cr3_actual,code_virt,phy_start,(MMU_U|MMU_P));
  mmu_map_page(cr3_actual,code_virt+PAGE_SIZE,phy_start,(MMU_U|MMU_P));

  //Mapeo la memoria de stack que pedimos al declarar la variable stack_phy a la mem_virtual designada
  mmu_map_page(cr3_actual,stack_virt-PAGE_SIZE,stack_phy,(MMU_P|MMU_U|MMU_W));
  //Mapeo la página compartida del kernel después del stack
  mmu_map_page(cr3_actual,compartido_virt,compartido_phy,(MMU_U|MMU_P));
  
  return cr3_actual;
}

// COMPLETAR: devuelve true si se atendió el page fault y puede continuar la ejecución
// y false si no se pudo atender
bool page_fault_handler(vaddr_t virt)
{

  print("Atendiendo page fault...", 0, 0, C_FG_WHITE | C_BG_BLACK);
  // Chequeemos si el acceso fue dentro del area on-demand
  if (virt<=ON_DEMAND_MEM_START_VIRTUAL && virt>=ON_DEMAND_MEM_END_VIRTUAL){
    if (!(virt&MMU_P))
    {
      pd_entry_t* cr3=rcr3();
      mmu_map_page(cr3,virt,ON_DEMAND_MEM_START_PHYSICAL,MMU_W|MMU_P);
    }
    return 1;
  }
  return 0;
  // En caso de que si, mapear la pagina

}
