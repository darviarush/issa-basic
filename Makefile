
all: test

test: lib/issa-basic.js
	node bin/issa-basic.js TestIssa 



lib/issa-basic.js: lib/issa-basic.coffee
	yarn run coffee -bc $^

clean:
	rm lib/issa-basic.js