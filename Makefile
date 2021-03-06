BIN=bin

all: smlnj

smlnj:
	mkdir -p bin
	sml build/go-nj.sml
	build/mkexec.sh `which sml` `pwd` jonprl

test:
	bin/jonprl example/test.cfg
	bin/jonprl example/image.jonprl
	bin/jonprl example/subtype.jonprl
	bin/jonprl stdlib/*.jonprl
	bin/jonprl example/tautology.jonprl
	bin/jonprl example/computational-equality.jonprl
	bin/jonprl example/container.jonprl
	bin/jonprl example/list.jonprl
	bin/jonprl example/foundations/sources.cfg
	bin/jonprl example/polymorphic-id-unique.jonprl
	bin/jonprl example/identity-types.cfg
	bin/jonprl example/per.cfg
	bin/jonprl example/category-theory/sources.cfg
	bin/jonprl example/synthetic-topology/sources.cfg

clean:
	rm -f bin/.heapimg.*
	rm -f bin/jonprl
	rm -rf .cm

install:
	rm -f $(DESTDIR)/bin/jonprl.new
	cp bin/jonprl $(DESTDIR)/bin/jonprl.new
	mv $(DESTDIR)/bin/jonprl.new $(DESTDIR)/bin/jonprl
