// Some helper functions

// Replace in x from bit y on z bits with v
#define COPY(x, y, z, v) ((x) ^= ((((x) >> (y)) ^ (v)) & ~(-1 << (z))) << (y))

// Extract from x from bit y on z bits
#define EXTRACT(x, y, z) (((x) >> (y)) & ~(-1 << (z)))

// Modifies or tests bit y in x
#define SET(x, y) ((x) |= (1 << (y)))
#define UNSET(x, y) ((x) &= ~(1 << (y)))
#define ISSET(x, y) (((x) & (1 << (y))) != 0)
#define ISUNSET(x, y) (((x) & (1 << (y))) == 0)

typedef int s32;
typedef unsigned int u32;
typedef long long s64;
typedef unsigned long long u64;