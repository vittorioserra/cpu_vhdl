#include "lib.hpp"

u64 stopwatch(bool restart)
{
    volatile u64* const timer = (u64*)0xCCCC0000;
    static u64 lastTime = 1;
    u64 time = *timer;
    u64 diff = time - lastTime;
    if (restart)
        lastTime = time;
    return diff;
}

u32 mod(u32 n, u32 d)
{
    u32 r = 0;
    for (u32 i = 0; i < 32; i++)
    {
        r <<= 1;
        if (ISSET(n, 31))
            r++;
        n <<= 1;
        if (r >= d)
            r -= d;
    }
    return r;
}

bool isPrime(u32 value)
{
    volatile u32* const gpio = (u32*)0x77770000;
    static u32 bar = 0x7;

    // 2 is prime
    if (value == 2)
        return true;

    // Check if smaller than 2 or divisible by 2
    if (value < 2 || ISUNSET(value, 0))
        return false;

    // Check if divisible by a value from 3 to value / 2
    for (u32 i = 3; i <= value / 2; i++)
    {
        if (stopwatch(false) > 1000 / 8 * 100000) // one step every 1/8 s
        {
            stopwatch(true);
            *gpio = bar;
            bar <<= 1;
            if (ISSET(bar, 8))
                bar++;
        }
        if (mod(value, i) == 0)
            return false;
    }
    return true;
}

s32 main()
{
    volatile u64* const timer = (u64*)0xCCCC0000;
    volatile u32* const gpio = (u32*)0x77770000;
    u32 lastButtons = 0;
    u32 displaySelect = 0;
    u32 displaySelectTarget = 0;
    s32 searchDirection = 0;
    u32 searchedPrime = 0;
    u32 bar = 0x7;

    stopwatch(true);

    while (true)
    {
        // Check if buttons are toggled on
        u32 buttons = *gpio;
        buttons = EXTRACT(buttons, 8, 5);
        u32 toggledOn = buttons ^ lastButtons & buttons;
        lastButtons = buttons;

        searchDirection = 0;
        if (ISSET(toggledOn, 0)) // up
            searchDirection += 1;
        if (ISSET(toggledOn, 1)) // right
            displaySelectTarget -= (displaySelectTarget != 0) ? 8 : 0;
        if (ISSET(toggledOn, 2)) // left
            displaySelectTarget += (displaySelectTarget != 16) ? 8 : 0;
        if (ISSET(toggledOn, 3)) // down
            searchDirection -= 1;
        if (ISSET(toggledOn, 4)) // center
            displaySelectTarget = 0;

        // search the next/prev prime number
        if (searchDirection != 0)
        {
            searchedPrime += searchDirection;
            searchedPrime &= 0xFFFFF;
            while (!isPrime(searchedPrime))
            {
                searchedPrime += searchDirection;
                searchedPrime &= 0xFFFFF;
            }
        }

        // update the displaySelect animated
        if (displaySelect != displaySelectTarget)
        {
            if (stopwatch(false) > 1000 / 8 * 100000) // one step every 1/8 s
            {
                stopwatch(true);
                displaySelect += (displaySelect < displaySelectTarget) ? 1 : -1;
            }
        }

        // display the prime number
        *gpio = EXTRACT(searchedPrime, displaySelect, 8);
    }
    return 0;
}