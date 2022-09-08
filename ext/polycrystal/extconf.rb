# frozen_string_literal: true

require 'mkmf'

$LDFLAGS << ' -framework AppKit' if RUBY_PLATFORM =~ /darwin/

MakeMakefile::LINK_SO.sub!('$(OBJS)', 'polycrystal.o')

create_header
create_makefile 'polycrystal/polycrystal'
