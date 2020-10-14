
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

| fib1(6) = fib2(6) = fib2(6) = 13, Ну "всё верно"
| _, raise "никак"


fib1(n) = case
			n<=1) 1
		   	n>1)  fib1(n-1) + fib1(n-2)
	  	  esac

fib1(n) = case n
			0,1) 1
		   	  *) fib1(n-1) + fib1(n-2)
	  	  end case

fib1(n) = case n
			0,1) 1
		   	  *) fib1(n-1) + fib1(n-2)
	  	  cend


fib1(n) = case n
			0,1 then 1
		   	  * then fib1(n-1) + fib1(n-2)


fib1(n) = if 	 n=0 then 1
          elseif n=1 then 1
		  else 		 	  fib1(n-1) + fib1(n-2)
