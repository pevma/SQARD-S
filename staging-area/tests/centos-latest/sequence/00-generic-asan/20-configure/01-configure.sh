#!/bin/bash

#Bash disables history in noninteractive shells by default, but we turn it on here.
HISTFILE=~/.bash_history
set -o history


cd /opt/QA/sources/suricata/ && \
./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var \
--enable-hiredis --enable-unittests \
CC=clang CFLAGS="-ggdb3 -Werror -Wchar-subscripts -fno-strict-aliasing -fstack-protector-all -fsanitize=address -fno-omit-frame-pointer -Wno-unused-parameter -Wno-unused-function" \
ac_cv_func_malloc_0_nonnull=yes ac_cv_func_realloc_0_nonnull=yes
