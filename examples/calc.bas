

input "введите число [+-*/] число", a#, o$, b#

| o='+', print a+b
| o='-', print a-b
| o='*', print a*b
| o='/', print a/b

