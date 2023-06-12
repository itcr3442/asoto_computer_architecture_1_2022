#include <stdio.h>

int main(void) {
    int sum = 0;

    int a[4][4] = {
        {1,  2,  3,  4},
        {5,  6,  7,  8},
        {9,  10, 11, 12},
        {13, 14, 15, 16}
    };
    int b[4][4] = {
        {16, 15, 14, 13},
        {12, 11, 10, 9},
        {8,  7,  6,  5},
        {4,  3,  2,  1}
    };
    int result[4][4] = {
        {0, 0, 0, 0},
        {0, 0, 0, 0},
        {0, 0, 0, 0},
        {0, 0, 0, 0}
    };

    result[0][0] += a[0][0] * b[0][0];
    result[0][0] += a[0][1] * b[1][0];
    result[0][0] += a[0][2] * b[2][0];
    result[0][0] += a[0][3] * b[3][0];

    result[0][1] += a[0][0] * b[0][1];
    result[0][1] += a[0][1] * b[1][1];
    result[0][1] += a[0][2] * b[2][1];
    result[0][1] += a[0][3] * b[3][1];

    result[0][2] += a[0][0] * b[0][2];
    result[0][2] += a[0][1] * b[1][2];
    result[0][2] += a[0][2] * b[2][2];
    result[0][2] += a[0][3] * b[3][2];

    result[0][3] += a[0][0] * b[0][3];
    result[0][3] += a[0][1] * b[1][3];
    result[0][3] += a[0][2] * b[2][3];
    result[0][3] += a[0][3] * b[3][3];

    result[1][0] += a[1][0] * b[0][0];
    result[1][0] += a[1][1] * b[1][0];
    result[1][0] += a[1][2] * b[2][0];
    result[1][0] += a[1][3] * b[3][0];

    result[1][1] += a[1][0] * b[0][1];
    result[1][1] += a[1][1] * b[1][1];
    result[1][1] += a[1][2] * b[2][1];
    result[1][1] += a[1][3] * b[3][1];

    result[1][2] += a[1][0] * b[0][2];
    result[1][2] += a[1][1] * b[1][2];
    result[1][2] += a[1][2] * b[2][2];
    result[1][2] += a[1][3] * b[3][2];

    result[1][3] += a[1][0] * b[0][3];
    result[1][3] += a[1][1] * b[1][3];
    result[1][3] += a[1][2] * b[2][3];
    result[1][3] += a[1][3] * b[3][3];

    result[2][0] += a[2][0] * b[0][0];
    result[2][0] += a[2][1] * b[1][0];
    result[2][0] += a[2][2] * b[2][0];
    result[2][0] += a[2][3] * b[3][0];

    result[2][1] += a[2][0] * b[0][1];
    result[2][1] += a[2][1] * b[1][1];
    result[2][1] += a[2][2] * b[2][1];
    result[2][1] += a[2][3] * b[3][1];

    result[2][2] += a[2][0] * b[0][2];
    result[2][2] += a[2][1] * b[1][2];
    result[2][2] += a[2][2] * b[2][2];
    result[2][2] += a[2][3] * b[3][2];

    result[2][3] += a[2][0] * b[0][3];
    result[2][3] += a[2][1] * b[1][3];
    result[2][3] += a[2][2] * b[2][3];
    result[2][3] += a[2][3] * b[3][3];

    result[3][0] += a[3][0] * b[0][0];
    result[3][0] += a[3][1] * b[1][0];
    result[3][0] += a[3][2] * b[2][0];
    result[3][0] += a[3][3] * b[3][0];

    result[3][1] += a[3][0] * b[0][1];
    result[3][1] += a[3][1] * b[1][1];
    result[3][1] += a[3][2] * b[2][1];
    result[3][1] += a[3][3] * b[3][1];

    result[3][2] += a[3][0] * b[0][2];
    result[3][2] += a[3][1] * b[1][2];
    result[3][2] += a[3][2] * b[2][2];
    result[3][2] += a[3][3] * b[3][2];

    result[3][3] += a[3][0] * b[0][3];
    result[3][3] += a[3][1] * b[1][3];
    result[3][3] += a[3][2] * b[2][3];
    result[3][3] += a[3][3] * b[3][3];

    sum += result[0][0];
    sum += result[0][1];
    sum += result[0][2];
    sum += result[0][3];

    sum += result[1][0];
    sum += result[1][1];
    sum += result[1][2];
    sum += result[1][3];

    sum += result[2][0];
    sum += result[2][1];
    sum += result[2][2];
    sum += result[2][3];

    sum += result[3][0];
    sum += result[3][1];
    sum += result[3][2];
    sum += result[3][3];

    printf("%d\n", sum);

    return 0;
}
