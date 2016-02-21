#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <prussdrv.h>
#include <pruss_intc_mapping.h>

#include "../../pru/pru.h"

#define PRU0 0
#define PRU1 1

#define BUFFER_SIZE (4*1024)
#define RAM_BYTES BUFFER_SIZE
#define RAM_SIZE (RAM_BYTES / 4)
#define MAP_SIZE (RAM_BYTES + 4096UL)
#define PAGE_MASK (4096UL - 1)        /* BeagleBone Black page size: 4096 */
#define MMAP1_LOC   "/sys/class/uio/uio0/maps/map1/"


// Function to load the shared RAM memory information from sysfs
int getMemInfo(unsigned int *addr, unsigned int *size)
{
    FILE* pfile;

    // Read shared RAM address
    pfile = fopen(MMAP1_LOC "addr", "rt");
    fscanf(pfile, "%x", addr);
    fclose(pfile);

    // Read shared RAM size
    pfile = fopen(MMAP1_LOC "size", "rt");
    fscanf(pfile, "%x", size);
    fclose(pfile);

    return(0);
}


int main(int argc, char *argv[])
{
    int fd;
    void *mem_map, *ram_addr;
    unsigned int addr, size;

    uint32_t *pru0_mem;

    uint8_t *reg_read;


    /* PRU code only works if executed as root */
    if (getuid() != 0) {
        fprintf(stderr, "This program needs to run as root.\n");
        exit(EXIT_FAILURE);
    }


    /***** SHARED RAM SETUP *****/
    printf("Allocating RAM buffer... ");
    fflush(stdout);

    /* Get shared RAM information */
    getMemInfo(&addr, &size);
    if (size < BUFFER_SIZE) {
        printf("error.\n");
        fprintf(stderr, "External RAM pool must be at least %d bytes.\n", BUFFER_SIZE);
        exit(EXIT_FAILURE);
    }

    /* Get access to device memory */
    if ((fd = open("/dev/mem", O_RDWR | O_SYNC)) == -1) {
        printf("error.\n");
        perror("Failed to open memory!");
        exit(EXIT_FAILURE);
    }

    /* Map shared RAM */
    mem_map = mmap(0, RAM_BYTES, PROT_READ, MAP_SHARED, fd, addr & ~PAGE_MASK);

    /* Close file descriptor (not needed after memory mapping) */
    close(fd);

    if (mem_map == (void *) -1) {
        printf("error.\n");
        perror("Failed to map base address");
        exit(EXIT_FAILURE);
    }

    /* Memory mapping must be page aligned */
    ram_addr = mem_map + (addr & PAGE_MASK);

    printf("OK!\n");


    /***** PRU SET UP *****/
    printf("Setting up PRUs... ");
    fflush(stdout);

    if (pru_setup() != 0) {
        printf("error.\n");
        fprintf(stderr, "Error setting up the PRU.\n");
        pru_cleanup();
        munmap(mem_map, RAM_SIZE);
        exit(EXIT_FAILURE);
    }

    /* Set up the PRU data RAMs */
    pru_mmap(0, &pru0_mem);
    *(pru0_mem) = addr;

    printf("OK!\n");


    /***** BEGIN MAIN PROGRAM *****/
    printf("Starting main program.\n");

    /* Start up PRU0 */
    if (pru_start(PRU0, "pru/ads131e08_pru0.bin") != 0) {
        fprintf(stderr, "Error starting PRU0.\n");
        pru_cleanup();
        munmap(mem_map, RAM_SIZE);
        exit(EXIT_FAILURE);
    }

    /* Start up PRU1 */
    if (pru_start(PRU1, "pru/ads131e08_pru1.bin") != 0) {
        fprintf(stderr, "Error starting PRU1.\n");
        pru_cleanup();
        munmap(mem_map, RAM_SIZE);
        exit(EXIT_FAILURE);
    }

    /* Wait for PRU_EVTOUT_0 and send shared RAM data */
    prussdrv_pru_wait_event(PRU_EVTOUT_0);
    prussdrv_pru_clear_event(PRU_EVTOUT_0, PRU0_ARM_INTERRUPT);

    /* Print out ADS registers */
    reg_read = (uint8_t *) ram_addr;

    printf("\nADS registers before write:\n");
    printf("ID:          %#04x (default = 0xD2)\n", *(reg_read + 0));
    printf("CONFIG1:     %#04x (default = 0x91)\n", *(reg_read + 1));
    printf("CONFIG2:     %#04x (default = 0xE0)\n", *(reg_read + 2));
    /* Datasheet claims that CONFIG3 should end in 00, but it ends in 01. */
    printf("CONFIG3:     %#04x (default = 0x41)\n", *(reg_read + 3));
    printf("FAULT:       %#04x (default = 0x00)\n", *(reg_read + 4));
    printf("CH1SET:      %#04x (default = 0x10)\n", *(reg_read + 5));
    printf("CH2SET:      %#04x (default = 0x10)\n", *(reg_read + 6));
    printf("CH3SET:      %#04x (default = 0x10)\n", *(reg_read + 7));
    printf("CH4SET:      %#04x (default = 0x10)\n", *(reg_read + 8));
    printf("CH5SET:      %#04x (default = 0x10)\n", *(reg_read + 9));
    printf("CH6SET:      %#04x (default = 0x10)\n", *(reg_read + 10));
    printf("CH7SET:      %#04x (default = 0x10)\n", *(reg_read + 11));
    printf("CH8SET:      %#04x (default = 0x10)\n", *(reg_read + 12));
    printf("FAULT_STATP: %#04x (default = 0x00)\n", *(reg_read + 13));
    printf("FAULT_STATN: %#04x (default = 0x00)\n", *(reg_read + 14));
    /* Datasheet claims that GPIO should be 0x0F, but it ends in 0x00. */
    printf("GPIO:        %#04x (default = 0x00)\n", *(reg_read + 15));

    /* Wait for PRU_EVTOUT_0 and send shared RAM data */
    prussdrv_pru_wait_event(PRU_EVTOUT_0);
    prussdrv_pru_clear_event(PRU_EVTOUT_0, PRU0_ARM_INTERRUPT);

    /* Print out ADS registers */
    printf("\nADS registers after write:\n");
    printf("ID:          %#04x (0xD2)\n", *(reg_read + 0));
    printf("CONFIG1:     %#04x (0x95)\n", *(reg_read + 1));
    printf("CONFIG2:     %#04x (0xE3)\n", *(reg_read + 2));
    /* Datasheet claims that CONFIG3 should end in 00, but it ends in 01. */
    printf("CONFIG3:     %#04x (0xC1)\n", *(reg_read + 3));
    printf("FAULT:       %#04x (0x00)\n", *(reg_read + 4));
    printf("CH1SET:      %#04x (0x13)\n", *(reg_read + 5));
    printf("CH2SET:      %#04x (0x23)\n", *(reg_read + 6));
    printf("CH3SET:      %#04x (0x13)\n", *(reg_read + 7));
    printf("CH4SET:      %#04x (0x23)\n", *(reg_read + 8));
    printf("CH5SET:      %#04x (0x13)\n", *(reg_read + 9));
    printf("CH6SET:      %#04x (0x23)\n", *(reg_read + 10));
    printf("CH7SET:      %#04x (0x13)\n", *(reg_read + 11));
    printf("CH8SET:      %#04x (0x23)\n", *(reg_read + 12));
    printf("FAULT_STATP: %#04x (0x00)\n", *(reg_read + 13));
    printf("FAULT_STATN: %#04x (0x00)\n", *(reg_read + 14));
    /* Datasheet claims that GPIO should be 0x0F, but it ends in 0x00. */
    printf("GPIO:        %#04x (0x00)\n", *(reg_read + 15));


    /* PRU CLEAN UP */
    printf("\nStopping PRUs.\n");
    pru_stop(PRU1);
    pru_stop(PRU0);
    pru_cleanup();


    /* SHARED RAM CLEAN UP */
    if (munmap(mem_map, RAM_SIZE) == -1) {
        perror("Failed to unmap memory");
        exit(EXIT_FAILURE);
    }

    return(EXIT_SUCCESS);
}
