PATH := $(PWD)/node_modules/.bin:$(PATH)

COFFEE_COMPILE = coffee -cpb
MKDIR = mkdir -p
RM = rm -rf

JS_TARGETS = $(shell find src -name '*.coffee'|sed -e 's/\.coffee/.js/' -e 's,^src/,,')

.PHONY: js
js: $(JS_TARGETS)

$(JS_TARGETS) : %.js : src/%.coffee
	@$(MKDIR) $(dir $@)
	$(COFFEE_COMPILE) "$<" > "$@"

.PHONY: clean
clean:
	@$(RM) lib test
