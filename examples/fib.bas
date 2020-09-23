
# %* - i8
# %- - i16
# % - i32
# %+ - i64
# &* - u8
# &- - u16
# & - u32
# &+ - u64
# ! - f32
# # - f64

fib1(n&) = | n<=1, 1
		   | n>1 , fib1(n-1) + fib1(n-2)

fib2(n&) = | 1						if n<=1
		   | fib2(n-1) + fib2(n-2) 	if n>1

fib(n&) = a&=1: b&=1: [for i=2 to n do c=b: b=a+b: a=c]: b

| fib1(6) = fib2(6) = fib2(6) = 13, print "всё верно"
| _, raise "никак"

