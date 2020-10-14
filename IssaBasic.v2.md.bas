Issa Basic транслируется на С

## 


## Вызов методов


```basic
fib(n) = if n<=1 then 1 else fib(n-1) + fib(n-2) fi
' В конце строки fi необязательно

fib(n) = | n <= 1, 	1
         | *,		fib(n-1) + fib(n-2)
fib(n) = | 1 					if n <= 1
		 | fib(n-1) + fib(n-2) 	if *
fib(n) = case n
         0, 1) 1
            *) fib(n-1) + fib(n-2)
         cend

fib(n) = case n
         0, 1) 1
            *) (n-1 fib) + (n-2 fib)
         cend




' Вначале строки:
print fib(10)
print (10 fib)

' Метод находится в отдельном файле с расширением *.is в каталоге c 

@@ Unsigned Integer/fib.is
CATEGORY Number sequences

' Параметры передаются через переменные A, B, C...
' Они - неизменяемые
' Возврат значения производится через оператор return, 
' который может быть использован только раз в конце файла


a=1
b=1
for i=2 to A
	x=a+b
	b=a
	a=x
next i


return a

' Цикл repeat

a=1
b=1
i=0
repeat
	x=a+b
	b=a
	a=x
	i=i+1
until i=A

REM Цикл while
a=1
b=1
i=0
while i<A
	x=a+b
	b=a
	a=x
	i=i+1
wend 


' Выбор
case n
0,1) 1
*) 


```