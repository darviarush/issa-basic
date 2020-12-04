## Welcome to GitHub Pages

You can use the [editor on GitHub](https://github.com/darviarush/issa-basic/edit/gh-pages/index.md) to maintain and preview the content for your website in Markdown files.

Whenever you commit to this repository, GitHub Pages will run [Jekyll](https://jekyllrb.com/) to rebuild the pages in your site, from the content in your Markdown files.

### Markdown

Markdown is a lightweight and easy-to-use syntax for styling your writing. It includes conventions for

```markdown
Syntax highlighted code block

# Header 1
## Header 2
### Header 3

- Bulleted
- List

1. Numbered
2. List

**Bold** and _Italic_ and `Code` text

[Link](url) and ![Image](src)
```

For more details see [GitHub Flavored Markdown](https://guides.github.com/features/mastering-markdown/).

### Jekyll Themes

Your Pages site will use the layout and styles from the Jekyll theme you have selected in your [repository settings](https://github.com/darviarush/issa-basic/settings). The name of this theme is saved in the Jekyll `_config.yml` configuration file.

### Support or Contact

Having trouble with Pages? Check out our [documentation](https://docs.github.com/categories/github-pages-basics/) or [contact support](https://github.com/contact) and we’ll help you sort it out.


# issa-basic

Это язык программирования на основе языка basic.

## Обзор

## Установка

## Использование

## Справочник

### Функции

Файл `math_task.is`

```bash
square(x) = x^2
cube(x) = square(x) * x

print "square(3)="; square(3), "and cube(-2.2)="; cube(-2)
```

Файл `compute_with.c`

```c
#include <math.h>
#include <stdint.h>
#include <stdio.h>

double square(double x) { return pow(x, 2); }
double square(double x) { return square(x) * x; }

void compute_with(double a, double b) {
	printf("square(3)=%f and cube(-2)=%s\n", square(a), cube(b));
}
```

Файл `function.is`

```bash
compute 3 with -2
```

Файл `function.is`

### Строки

Строки берутся в `""` или `''` кавычки. И могут помещаться только на одной строке.
Многострочные строки

Файл `get_hello_word.is`

```bash
w = "Word"
return """Hello {w}!
	My friends!\n"""
```

Файл `get_hello_word.c`

```c
#include <issa-basic/string.h>

struct issa_string get_hello_word() {
	struct issa_string w = {length: 4, data: "Word"};
	char* _ref0;
	int32_t _ref1 = asprintf(*_ref0, "Hello %s!\n"
		"	My friends!\n");
	return {length: _ref1, data: _ref0};
}
```

### Массивы

Элементы массивов заполняются нулевыми значениями.

Файл `massive.is`

```bash
DIM e(5, 6, 10), m(2, 2)

v = [1, 2, 3]

print e, v, m 
```

Файл `massive.c`

```c
#include <issa-basic/dim.h>
#include <stdio.h>

void massive() {
	struct issa_dim3 e = {dim1: 5, dim2: 6, dim3: 10, data: NULL};
	struct issa_dim1 v = {dim1: 3, data: {1, 2, 3}};
	struct issa_dim2 v = {dim1: 2, dim2: 2, data: {1, 2, 3}};

	printf("%s %s %s\n", issa_dim3_as_string(e), issa_dim1_as_string(v), issa_dim2_as_string(m));
}
```

### Ассоциативные массивы

