/* ************************************************************************** */
/** Forth Subsystem Task

  @Company
 HackRVA

  @File Name
    forth.h

  @Description
    Declarations for the forth subsytem for interface with C code.

 */
/* ************************************************************************** */

#ifndef _FORTH_H    /* Guard against multiple inclusion */
#define _FORTH_H

#include <stdint.h>
#include <stddef.h>

#ifdef __cplusplus  // Provide C++ Compatibility

extern "C" {

#endif

/* size allocated as stack for forth_task() */
#define FORTHTASK_STACK 32  /* words */
/* runtime priority of forth_task() */
#define FORTHTASK_PRIO 1
/* dynamic memory allocation for forth machine */
#define FORTH_MEM_SIZE 1024  /* bytes */

// defines for C compiler data structure used by forth

typedef struct {
    uint32_t error_code;
    const char *error_msg;
} forth_return;

// *****************************************************************************
// *****************************************************************************
// Section: Interface Functions
// *****************************************************************************
// *****************************************************************************

/*
 */

/* actual task function, with main loop */
/******************************************************************************
 forth_task() SHOULD: (not yet implemented)

 run in loop awaiting message
 when other process sends message
   start forth:
     allocates memory for forth process
     calls forth_init
   send to forth:
     sends data to forth process through nkey_get
   terminate forth:
     send shutdown command to forth process
     wait for shutdown
     deallocate memory
 *****************************************************************************/
void forth_task(void *parameters);

/* gets a value from USB queue */
int ForthUSB(void);

//forth_init is defined in paulforth.S
// note: passing example_program here is temporary for debugging
extern forth_return *forth_init(void *, size_t mem_size, const char *forth_str,
        const char *example_program);

#ifdef __cplusplus
}
#endif
#endif /* _FORTH_H */
