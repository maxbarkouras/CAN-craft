#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

typedef __uint128_t uint128_t;

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
    uint128_t packet;
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

    msg->packet = 0;
    msg->arb_id = id;
    msg->dlc = dlc;
    memcpy(msg->msg_packet, user_packet, dlc);
    return CAN_SUCCESS;
}

int craft_packet(can_msg *msg){

    if(!msg) return INVALID_MSG;
    if(msg->arb_id > 0x7FF) return INVALID_ID;
    if(msg->dlc > 8) return INVALID_DLC;
    
    msg->packet = 0;
    int bit_count = 0;

    // SOF
    msg->packet = (msg->packet << 1) | 0;
    bit_count++;

    // ID
    msg->packet = (msg->packet << 11) | (msg->arb_id & 0x7FF);
    bit_count+=11;

    // RTR
    msg->packet = (msg->packet << 1) | 0;
    bit_count++;

    // IDE (r1)
    msg->packet = (msg->packet << 1) | 0;
    bit_count++;

    // r0
    msg->packet = (msg->packet << 1) | 0;
    bit_count++;

    // DLC
    msg->packet = (msg->packet << 4) | (msg->dlc & 0x0F);
    bit_count+=4;

    // DATA
    for(int i=0;i<msg->dlc;i++){
        msg->packet = (msg->packet << 8) | msg->msg_packet[i];
        bit_count+=8;
    }
    
    return bit_count;
}

void print_u128_bin(uint128_t x, int packet_size) {
    for (int b = (packet_size-1); b >= 0; b--) putchar(((x >> b) & (uint128_t)1) ? '1' : '0');
    putchar('\n');
}

int main(){

    can_msg CAN1;
    can_init(&CAN1);

    uint8_t data[] = {0x10, 0x02, 0x01, 0x55, 0x21, 0x13, 0xff, 0x71};
    can_set(&CAN1, 0x7ff, data, 8);

    int packet_size = craft_packet(&CAN1);
    if(packet_size < 0) return packet_size;


    print_u128_bin(CAN1.packet, packet_size);

}