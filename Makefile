.PHONY: all

objects := $(patsubst coffee/%.coffee,js/%.js,$(wildcard coffee/*.coffee))



all: $(objects)
	node js/iss.js


js/%.js: coffee/%.coffee
	yarn run coffee -b -c -o $@ $^


clean:
	rm js/*.js