#
# NiftyLogic Build system Makefile
#
# Some habits die hard.   Like running `make test', when you
# should be running `./Build test'.  Here's a makefile for
# the oldtimers who just can't let go.
#
# Oh, and it also provides some additional make targets
# that do not belong in Module::Build.
#

###############################################################

default: test;
Build.PL:;
Makefile:;

###############################################################

Build :: Build.PL
	perl Build.PL

ddist: dist
ddist: dist
	rename 's/Paste-Bin-v/libpaste-bin-perl_/' *.tar.gz
	rename 's/Paste-Bin-/libpaste-bin-perl_/' *.tar.gz
	rename 's/.tar.gz/.orig.tar.gz/' *.tar.gz
	mv libpaste-bin-perl_*.orig.tar.gz ..



%: Build
	./Build $@
