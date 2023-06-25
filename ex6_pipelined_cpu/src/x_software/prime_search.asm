	# step through the numbers 0 to 255 with button up and down
	li a0, 7
	li s0, 0x77770000
	li s1, 0
main_loop:
	# check if button is toggled on
	lb t0, 1(s0)
	xor t1, t0, s1
	mv s1, t0
	and t0, t1, t0

	li s2, 0 # search direction
	# check if button up is pressed
	andi t1, t0, 1
	beqz t1, main_test_btn_d
	addi s2, s2, 1
main_test_btn_d:
	# check if button down is pressed
	andi t1, t0, 8
	beqz t1, main_test_prime
	addi s2, s2, -1

main_test_prime:
	beqz s2, main_loop
	# check if a0 is prime
main_search_next:
	add a0, a0, s2 # step and wrap around
	andi a0, a0, 0xFF
	call is_prime
	beqz a1, main_search_next

	# output the number on the leds
main_search_end:
	sb a0, 0(s0)
	j main_loop


	# a0 contains the number to test
	# returns a1 = 1 if the number is prime otherwise 0
is_prime:
	# check if smaller than 2
	addi t0, a0, -1
	blez t0, is_prime_false

	# check if divisible by 2
	andi t0, a0, 1
	beqz t0, is_prime_false

	# t1 from 3 to t2 = a0 / 2
	li t1, 3
	beq a0, t1, is_prime_true
	srli t2, a0, 1
is_prime_test_loop:
	mv t0, a0

	# test if a0 is divisible by t1
is_prime_divide_loop:
	sub t0, t0, t1
	bgtz t0, is_prime_divide_loop
	beqz t0, is_prime_false
	addi t1, t1, 1
	ble t1, t2, is_prime_test_loop

is_prime_true:
	li a1, 1
	ret
is_prime_false:
	li a1, 0
	ret

