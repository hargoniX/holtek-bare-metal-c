#include <stddef.h>
#include <stdint.h>

typedef struct __attribute__((packed)) {
    uint32_t r0;
    uint32_t r1;
    uint32_t r2;
    uint32_t r3;
    uint32_t r12;
    uint32_t lr;
    uint32_t pc;
    uint32_t xpsr;
} ExceptionFrame;

int main();
extern void Reset();
extern void HardFaultTrampoline();
void HardFault(ExceptionFrame*);
void svcall_handler();
void pendsv_handler();
void systick_handler();
void nmi_handler();
void __pre_init();

void (*reset_vector_pointer)(void) __attribute__ ((section (".vector_table.reset_vector"))) = &Reset;
void *exception_vector_pointers[14] __attribute__ ((section (".vector_table.exceptions"))) = {
    nmi_handler,
    HardFaultTrampoline,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    svcall_handler,
    NULL,
    NULL,
    pendsv_handler,
    systick_handler
};

void __pre_init() {

}

void systick_handler() {
    while(1) {}
}

void pendsv_handler() {
    while(1) {}
}

void svcall_handler() {
    while(1) {}
}

void nmi_handler() {
    while(1) {}
}

void HardFault(ExceptionFrame *frame) {
    while(1) {}
}
