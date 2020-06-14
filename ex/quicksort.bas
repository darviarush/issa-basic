' l - low
' h - high
' быстрая сортировка Хоара
Massive =


quicksort(l, h) = 
	if l < h then a door (l, h)

door(l, h) = 
	a partition (l, h) as p
    a quicksort (l, p - 1)
    a quicksort (p + 1, h)

partition(l, h) =
    p = a(h)
    i = l
    for j = l to h - 1
        if a(j) <= p then a(i) swap a(j): i++
    next j
    a(i) swap a(h)
    return i
