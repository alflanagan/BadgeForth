/* ************************************************************************** */
/** Forth Subsystem Task

  @Company
 HackRVA

  @File Name
    forth.c

  @Summary
 C code to create forth task.

  @Description
    C code to create forth task, initialize data, etc. Much of the actual guts
   of the forth interpreter will be in an assembly language file, this file acts
   as a sort of interface between the C code and the assembly bits.

 */
/* ************************************************************************** */
//#include <stdint.h>
//#include <stddef.h>
#include <FreeRTOS.h>
#include <task.h>
#include <stdlib.h>
#include "forth.h"


int ForthUSB(void) {
    //just a stub for now
    return 0;
}

void forth_task(void *parameters) {
    forth_return *err = NULL;
    void *forth_memory = pvPortMalloc(FORTH_MEM_SIZE);

    for (;;) {
        err = forth_init(forth_memory, sizeof(forth_memory), "forth",
                "0 0 120 30 fbline");
        if (err && err->error_code) {
        }
    }

    /* task should never reach the end of function, so this is just insurance. */
    vTaskDelete(NULL);

} // forth_task()

//static forth_return some_data;

//dummy stub
//forth_return *forth_init(void *forth_mem, size_t mem_size, const char *forth_str,
//                         const char *example_program) {
//    return &some_data;
//}
