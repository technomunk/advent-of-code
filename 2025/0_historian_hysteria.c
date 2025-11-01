#include <stdio.h>
#include <stdlib.h>

#include "lib/types.h"
#include "lib/list.h"

int cmp_u32(const void* a, const void* b) {
    u32 av = *(const u32*)a;
    u32 bv = *(const u32*)b;
    if (av < bv) return -1;
    if (av > bv) return 1;
    return 0;
}

u32 part_1(list_t* left, list_t* right) {
    u32 diff = 0;
    u32 l, r;
    for (size_t idx = 0; idx < left->length; ++idx) {
        u32 l = *(u32*)list_nth(left, idx);
        u32 r = *(u32*)list_nth(right, idx);
        diff += max(l, r) - min(l, r);
    }
    return diff;
}

u32 count_elements(list_t* list, u32 element) {
    u32 count = 0;
    for (size_t i = 0; i < list->length; ++i) {
        count += *(u32*)list_nth(list, i) == element;
    }
    return count;
}

u32 part_2(list_t* left, list_t* right) {
    u32 result = 0;
    for (size_t i = 0; i < left->length; ++i) {
        u32 elem = *(u32*)list_nth(left, i);
        result += elem * count_elements(right, elem);
    }
    return result;
}

int main() {
    list_t left = list_create(sizeof(u32));
    list_t right = list_create(sizeof(u32));

    char line[64];
    u32 l, r;
    while (scanf_s("%u   %u", &l, &r) == 2) {
        list_push(&left, &l);
        list_push(&right, &r);
    }

    list_qsort(&left, &cmp_u32);
    list_qsort(&right, &cmp_u32);

    printf("Part 1: %u\nPart 2: %u", part_1(&left, &right), part_2(&left, &right));

    list_free(&left);
    list_free(&right);

    return 0;
}
