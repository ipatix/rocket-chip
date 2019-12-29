#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>
#include <string.h>

// registers

typedef volatile uint32_t vu32;

typedef struct {
    vu32 data;  // output fixed
    vu32 tri;
    vu32 data2; // input fixed
    vu32 tri2;
} AXIGPIO;

typedef struct {
    vu32 rxData;
    vu32 txData;
    vu32 status;
    vu32 control;
} AXIUartLite;

// This struct uses 32 bit registers instead of standard ns16550a 8 bit regs
typedef struct {
    union {
        vu32 bufTxRx;
        vu32 dll;
    };
    union {
        vu32 ier;
        vu32 dlm;
    };
    union {
        vu32 iir;
        vu32 fifoCtrl;
    };
    vu32 lineCtrl;
    vu32 modemCtrl;
    vu32 lineStat;
    vu32 modemStat;
    vu32 scratch;
} AXIUart16550;

// 50 MHz
#define AXI_CLOCK 150000000

#define UART16550_BAUD 115200
#define CONSOLE_BAUD 115200

#define GPIO_PORT ((AXIGPIO *)0x60100000)

#define UART_PORT_0 ((AXIUartLite *)0x60000000)
#define UART_PORT_1 ((AXIUartLite *)0x60010000)
#define UART16550_PORT ((AXIUart16550 *)0x60031000)

#define UART_CTRL_RESET_TX_FIFO 0x1
#define UART_CTRL_RESET_RX_FIFO 0x2
#define UART_CTRL_ENABLE_INT 0x10
#define UART_STAT_RX_FIFO_VALID 0x1
#define UART_STAT_RX_FIFO_FULL 0x2
#define UART_STAT_TX_FIFO_EMPTY 0x4
#define UART_STAT_TX_FIFO_FULL 0x8
#define UART_STAT_INT_ENABLED 0x10
#define UART_STAT_OVERRUN_ERR 0x20
#define UART_STAT_FRAME_ERROR 0x40
#define UART_STAT_PARITY_ERROR 0x80

#define UART16550_LSR_RX_AVAIL 0x1
#define UART16550_LSR_TX_EMPTY 0x20
#define UART16550_LSR_TX_ALLEMPTY 0x40

// program stuff

#define PROTOCOL_PING 0x10
#define PROTOCOL_PONG 0x11
#define PROTOCOL_DISCOVER 0x12
#define PROTOCOL_READ_MEM 0x20
#define PROTOCOL_WRITE_MEM 0x21
#define PROTOCOL_SET_MEM 0x22
#define PROTOCOL_READ_GPIO 0x23
#define PROTOCOL_BOOT 0x40
#define PROTOCOL_GET_NUM_HARTS 0x48
#define PROTOCOL_SET_BAUD 0x50
#define PROTOCOL_OK 0xF0
#define PROTOCOL_ERR 0xFE

#define LED_PATT_INIT 0x1
#define LED_PATT_WAITING 0x10
#define LED_PATT_DISCOVER 0x11
#define LED_PATT_NO_UART 0x12
#define LED_PATT_BOOT 0x2F

typedef struct {
    AXIUartLite *uartLite;
    AXIUart16550 *uart16550;
    uint64_t num_harts;
} MS;

static uint32_t div_round(uint32_t a, uint32_t b) {
    return (a + (b / 2)) / b;
}

static void delay(uint64_t d) {
    for (volatile uint64_t x = 0; x < d; x++) ;
}

static uint32_t gpio_read(void) {
    return GPIO_PORT->data2;
}

static void gpio_write(uint32_t x) {
    GPIO_PORT->data = x;
}

static void uartlite_read(AXIUartLite *ul, uint8_t *buf, size_t len) {
    while (len-- > 0) {
        // wait for valid data
        while (!(ul->status & UART_STAT_RX_FIFO_VALID)) ;
        *buf++ = (uint8_t)ul->rxData;
    }
}

static void uartlite_write(AXIUartLite *ul, const uint8_t *buf, size_t len) {
    while (len-- > 0) {
        // wait until fifo is not full anymore
        while (ul->status & UART_STAT_TX_FIFO_FULL) ;
        ul->txData = *buf++;
    }
}

static void uart16550_read(AXIUart16550 *u, uint8_t *buf, size_t len) {
    while (len-- > 0) {
        // wait for valid data
        while (!(u->lineStat & UART16550_LSR_RX_AVAIL)) ;
        *buf++ = u->bufTxRx;
    }
}

static void uart16550_write(AXIUart16550 *u, const uint8_t *buf, size_t len) {
    while (len-- > 0) {
        // wait until fifo is not full anymore
        while (!(u->lineStat & UART16550_LSR_TX_EMPTY)) ;
        u->bufTxRx = *buf++;
    }
}

static void uart_read(MS *ms, uint8_t *buf, size_t len) {
    if (ms->uartLite) {
        uartlite_read(ms->uartLite, buf, len);
    } else if (ms->uart16550) {
        uart16550_read(ms->uart16550, buf, len);
    } else {
        gpio_write(LED_PATT_NO_UART);
    }
}

static void uart_write(MS *ms, const uint8_t *buf, size_t len) {
    if (ms->uartLite) {
        uartlite_write(ms->uartLite, buf, len);
    } else if (ms->uart16550) {
        uart16550_write(ms->uart16550, buf, len);
    } else {
        gpio_write(LED_PATT_NO_UART);
    }
}

static uint64_t uart_read_u64(MS *ms) {
    union {
        uint8_t bytes[8];
        uint64_t val;
    } u;
    uart_read(ms, u.bytes, sizeof(u.bytes));
    return u.val;
}

static void uart_write_u64(MS *ms, uint64_t x) {
    union {
        uint8_t bytes[8];
        uint64_t val;
    } u;
    u.val = x;
    uart_write(ms, u.bytes, sizeof(u.bytes));
}

static void uart16550_init(AXIUart16550 *u, uint32_t baud) {
    uint32_t divisor = div_round(AXI_CLOCK, 16 * baud);
    u->ier = 0x00; // disable interrupts
    u->lineCtrl = 0x80; // enable DLAB (set baud divisor)
    u->dll = (uint8_t)divisor;
    u->dlm = (uint8_t)(divisor >> 8);
    u->lineCtrl = 0x03; // 8 bits, no parity, one stop bit
    u->fifoCtrl = 0xC7; // enable fifos, clear them, 14 byte thresh
}

static void uart_discover(MS *ms) {
    while (1) {
        if (UART_PORT_0->status & UART_STAT_RX_FIFO_VALID && UART_PORT_0->rxData == PROTOCOL_DISCOVER) {
            uint8_t ans = PROTOCOL_OK;
            ms->uartLite = UART_PORT_0;
            uartlite_write(ms->uartLite, &ans, 1);
            return;
        }
        if (UART16550_PORT->lineStat & UART16550_LSR_RX_AVAIL && UART16550_PORT->bufTxRx == PROTOCOL_DISCOVER) {
            uint8_t ans = PROTOCOL_OK;
            ms->uart16550 = UART16550_PORT;
            uart16550_write(ms->uart16550, &ans, 1);
            return;
        }
    }
}

static void protocol_ping(MS *ms) {
    uint8_t ans = PROTOCOL_PONG;
    uart_write(ms, &ans, 1);
}

static void protocol_err(MS *ms) {
    uint8_t errcode = PROTOCOL_ERR;
    uart_write(ms, &errcode, 1);
}

static void protocol_read_mem(MS *ms) {
    // rx address to read from
    uint64_t addr = uart_read_u64(ms);
    // rx amount of bytes to read
    uint64_t len = uart_read_u64(ms);

    uint8_t *ptr = (uint8_t *)addr;
    uint8_t *endptr = ptr + len;

    while (ptr != endptr) {
        uart_write(ms, ptr++, 1);
    }
}

static void protocol_write_mem(MS *ms) {
    // rx address to write to
    uint64_t addr = uart_read_u64(ms);
    // rx amount of bytes to write
    uint64_t len = uart_read_u64(ms);

    uint8_t *ptr = (uint8_t *)addr;
    uint8_t *endptr = ptr + len;

    while (ptr != endptr) {
        uart_read(ms, ptr++, 1);
    }
}

static void protocol_set_mem(MS *ms) {
    // rx address to write to
    uint64_t addr = uart_read_u64(ms);
    // rx amount of bytes to write
    uint64_t len = uart_read_u64(ms);

    uint8_t *ptr = (uint8_t *)addr;
    uint8_t *endptr = ptr + len;

    uint8_t fill;
    uart_read(ms, &fill, 1);

    while (ptr != endptr) {
        *ptr++ = fill;
    }

    uint8_t msg = PROTOCOL_OK;
    uart_write(ms, &msg, 1);
}

static void protocol_read_gpio(MS *ms) {
    uint8_t data = (uint8_t)gpio_read();
    uart_write(ms, &data, 1);
}

static void protocol_set_baud(MS *ms) {
    uint64_t baud = uart_read_u64(ms);
    if (ms->uart16550) {
        uint8_t ans = PROTOCOL_OK;
        uart_write(ms, &ans, 1);
        while (!(ms->uart16550->lineStat & UART16550_LSR_TX_EMPTY) ||
                !(ms->uart16550->lineStat & UART16550_LSR_TX_ALLEMPTY)) ;
        uart16550_init(ms->uart16550, (uint32_t)baud);
    } else {
        uint8_t ans = PROTOCOL_ERR;
        uart_write(ms, &ans, 1);
    }
}

static void protocol_get_num_harts(MS *ms) {
    uart_write_u64(ms, ms->num_harts);
}

void bootrom_main(uint64_t hart_count) {
    MS ms;
    memset(&ms, 0, sizeof(ms));
    ms.num_harts = hart_count;

    for (unsigned int i = 0; i < 8; i++) {
        gpio_write(LED_PATT_INIT << i);
        delay(500000);
    }

    uart16550_init(UART16550_PORT, UART16550_BAUD);
    gpio_write(LED_PATT_DISCOVER);
    uart_discover(&ms);

    bool bootrom_running = true;
    while (bootrom_running) {
        uint8_t cmd;

        gpio_write(LED_PATT_WAITING);
        uart_read(&ms, &cmd, 1);
        switch (cmd) {
            case PROTOCOL_PING:
                protocol_ping(&ms);
                break;
            case PROTOCOL_READ_MEM:
                protocol_read_mem(&ms);
                break;
            case PROTOCOL_WRITE_MEM:
                protocol_write_mem(&ms);
                break;
            case PROTOCOL_SET_MEM:
                protocol_set_mem(&ms);
                break;
            case PROTOCOL_READ_GPIO:
                protocol_read_gpio(&ms);
                break;
            case PROTOCOL_SET_BAUD:
                protocol_set_baud(&ms);
                break;
            case PROTOCOL_BOOT:
                bootrom_running = false;
                break;
            case PROTOCOL_GET_NUM_HARTS:
                protocol_get_num_harts(&ms);
                break;
            default:
                protocol_err(&ms);
        }
    }

    gpio_write(LED_PATT_BOOT);
}

void inc_hart_count(uint64_t *cnt) {
    volatile int i = 0;
    for (i = 0; i < 0x1000; i++) ;
    __atomic_add_fetch(cnt, 1, __ATOMIC_ACQ_REL);
    for (i = 0; i < 0x1000; i++) ;
}
