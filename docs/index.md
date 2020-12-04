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

<table>
	<tr><td width=50%>

		Файл `function.is`

```basic
square(x) = x^2
cube(x) = square(x) * x

print "square(3)="; square(3), "and cube(-2.2)="; cube(-2)
```

	<td>

```c
#include <math.h>
#include <stdint.h>
#include <stdio.h>

double square(int32_t x) { return pow(x, 2); }
double square(double x) { return square(x) * x; }

int main(int ac, char** av, char** ev) {
	printf("square(3)=%f and cube(-2)=%s\n", square(3), cube(-2));
}
```

</table>