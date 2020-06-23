#!/bin/bash
cd `dirname $0`
exec erl -sname eda -config $PWD/sys.config \
-pa $PWD/_build/default/lib/*/ebin $PWD/test -boot start_sasl \
-setcookie start-dev -run c erlangrc .