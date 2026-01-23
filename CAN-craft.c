#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

typedef __uint128_t uint128_t;
#define CRC_HEX_VAL 0x4599


enum CAN_ERROR{
    CAN_SUCCESS,
    INVALID_ID = -1,
    INVALID_MSG = -2,
    INVALID_DLC = -3,
    MEM_ERROR = -4
};

typedef struct can_msg{
    uint16_t arb_id;
    uint8_t dlc;
    uint8_t  msg_packet[8];
    uint128_t frame;
} can_msg;

int can_init(can_msg *msg){
    if (!msg) return INVALID_MSG;

    msg->arb_id = 0;
    msg->dlc = 0;
    memset(msg->msg_packet, 0, sizeof(msg->msg_packet));

    return CAN_SUCCESS;
}

int can_set(can_msg *msg, uint16_t id, const uint8_t* user_packet, uint8_t dlc){
    if(!msg) return INVALID_MSG;
    if(id > 0x7ff)return INVALID_ID;
    if(dlc > 8) return INVALID_DLC;
    if(!user_packet && dlc > 0) return INVALID_MSG;

    msg->frame = 0;
    msg->arb_id = id;
    msg->dlc = dlc;
    memcpy(msg->msg_packet, user_packet, dlc);
    return CAN_SUCCESS;
}

void print_u128_bin(uint128_t x, int frame_size) {
    for (int b = (frame_size-1); b >= 0; b--) putchar(((x >> b) & (uint128_t)1) ? '1' : '0');
    putchar('\n');
}

uint16_t calc_crc(uint128_t frame, int bit_count) {
    uint16_t crc = 0;
    for (int i = bit_count - 1; i >= 0; --i) {
        uint8_t next_bit = ((frame >> i) & 1);
        uint8_t crc_next  = (next_bit ^ ((crc >> 14) & 1));

        crc = ((crc << 1) & 0x7FFF);

        if (crc_next) {
            crc ^= (uint16_t)CRC_HEX_VAL;
        }
    }
    return crc & 0x7FFF;
}

int craft_frame(can_msg *msg){

    if(!msg) return INVALID_MSG;
    if(msg->arb_id > 0x7FF) return INVALID_ID;
    if(msg->dlc > 8) return INVALID_DLC;
    
    msg->frame = 0;
    int bit_count = 0;

    // SOF (1 dominant bit)
    msg->frame = (msg->frame << 1) | 0;
    bit_count++;

    // ID (11 bits)
    msg->frame = (msg->frame << 11) | (msg->arb_id & 0x7FF);
    bit_count+=11;

    // RTR (1 dominant bit)
    msg->frame = (msg->frame << 1) | 0;
    bit_count++;

    // IDE (1 dominant bit)
    msg->frame = (msg->frame << 1) | 0;
    bit_count++;

    // r0 (1 dominant bit)
    msg->frame = (msg->frame << 1) | 0;
    bit_count++;

    // DLC (4 bits)
    msg->frame = (msg->frame << 4) | (msg->dlc & 0xF);
    bit_count+=4;

    // DATA (0-64 bits)
    for(int i=0;i<msg->dlc;i++){
        msg->frame = (msg->frame << 8) | msg->msg_packet[i];
        bit_count+=8;
    }

    // CRC (15 bits)
    msg->frame = (msg->frame << 15) | ((calc_crc(msg->frame, bit_count)) & 0x7FFF);
    bit_count+=15;

    // CRC Delimeter (1 recessive bit)
    msg->frame = (msg->frame << 1) | 0x1;
    bit_count++;

    // ACK (1 recessive bit)
    msg->frame = (msg->frame << 1) | 0x1;
    bit_count++;
    
    // ACK Delimeter (1 recessive bit)
    msg->frame = (msg->frame << 1) | 0x1;
    bit_count++;

    // EOF (7 recessive bits)
    msg->frame = (msg->frame << 7) | 0x7f;
    bit_count+=7;

    //return total active bits
    return bit_count;
}

int main(){

    can_msg CAN1;
    can_init(&CAN1);

    uint8_t data[] = {0x55, 0x32, 0x18, 0x10, 0x01, 0x05};
    can_set(&CAN1, 0x150, data, 6);

    int frame_size = craft_frame(&CAN1);
    if(frame_size < 0) return frame_size;

    print_u128_bin(CAN1.frame, frame_size);

}