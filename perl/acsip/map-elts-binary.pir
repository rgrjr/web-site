## Produces equivalent output to map-elts-find.pl.text.

.include 'interpinfo.pasm'

## Print the integer value in *PRINT-BASE*.
.sub int2str
	.param int value

	.local int high_order, digit, print_base
	.local pmc pmc_print_base
	pmc_print_base = get_hll_global '*PRINT-BASE*'
	print_base = pmc_print_base
	high_order = value / print_base
	.local string result
	unless high_order goto no_more
	result = int2str(high_order)
	goto add_digit
no_more:
	result = ''
add_digit:
	.local int digit
	.local string digit_str
	digit = value % print_base
	digit_str = digit
	result = concat result, digit_str
	.return (result)
.end

## Print a random thing, obeying *PRINT-BASE* if it's an Integer.
.sub print_thing
	.param pmc thing

	$I0 = isa thing, 'Integer'
	if $I0 goto got_int
	$S0 = thing
	goto print_it
got_int:
	$S0 = int2str(thing)
print_it:
	print $S0
.end

.sub map_elts
	.param pmc tree
	.param pmc functional

	$I0 = isa tree, 'FixedPMCArray'
	unless $I0 goto scalar
	## array case.
	.local int len, i
	len = tree	## compute length.
	i = 0
again:
	if i >= len goto done
	.local pmc elt
	elt = tree[i]
	map_elts(elt, functional)
	inc i
	goto again
scalar:
	## non-array case.
	functional(tree)
done:
.end

.sub find_if_greater
	.param pmc tree
	.param pmc limit

	## Create the $limit lexical.
	.lex '$limit', limit

	## Store our return continuation as exit_cont.
	.local pmc exit_cont
	.lex 'exit_cont', exit_cont
	exit_cont = interpinfo .INTERPINFO_CURRENT_CONT

	## Save off the old *PRINT-BASE* value.
	.local pmc old_print_base, new_print_base
	.lex 'old_print_base', old_print_base
	old_print_base = get_hll_global '*PRINT-BASE*'

	## Define an action to restore it.
	.local pmc restore_sub, restore_closure
	.const .Sub restore_sub = '_restore_old_print_base'
	restore_closure = newclosure restore_sub
	pushaction restore_closure

	## Set *PRINT-BASE* to 2.
	new_print_base = new 'Integer'
	new_print_base = 2
	set_hll_global '*PRINT-BASE*', new_print_base

	## Create a closure of our internal sub.
	.local pmc find_internal, find_closure
	.const .Sub find_internal = "_find_internal"
        find_closure = newclosure find_internal
	map_elts(tree, find_closure)

	## map_elts returned normally.
	.return ("nothing")
.end

.sub _restore_old_print_base :outer('find_if_greater')
	.local pmc old_print_base
	old_print_base = find_lex 'old_print_base'
	set_hll_global '*PRINT-BASE*', old_print_base
.end

.sub _find_internal :outer('find_if_greater')
	.param pmc value

	## Test value against limit
	.local pmc limit
	# print "Testing $value.\n";
	limit = find_lex '$limit'
	unless value > limit goto nope

	## Print what we found.
	print "Found "
	print_thing(value)
	print "\n"

	## Return it as the result from find_if_greater.
	.local pmc exit_cont
	exit_cont = find_lex 'exit_cont'
	exit_cont(value)
nope:
	.return ()
.end

.sub main :main
	## Initialize *print-base*.
	.local pmc print_base
	print_base = new 'Integer'
	print_base = 10
	set_hll_global '*PRINT-BASE*', print_base

	## Initialize $data.
	.local pmc data, branch3, branch4, branch40, branch402
	data = new 'FixedPMCArray'
	data = 5
	data[0] = 1
	data[1] = 2
	data[2] = 3
	branch3 = new 'FixedPMCArray'
	branch3 = 3
	branch3[0] = 4
	branch3[1] = 5
	branch3[2] = 4
	data[3] = branch3
	branch4 = new 'FixedPMCArray'
	branch4 = 2
	branch40 = new 'FixedPMCArray'
	branch40 = 3
	branch40[0] = 7
	branch40[1] = 8
	branch402 = new 'FixedPMCArray'
	branch402 = 2
	branch402[0] = 9
	branch402[1] = 10
	branch40[2] = branch402
	branch4[0] = branch40
	branch4[1] = 11
	data[4] = branch4

	## Initialize "list".
	.local pmc list
	list = new 'FixedIntegerArray'
	list = 3
	list[0] = 6
	list[1] = 8
	list[2] = 99

	## Main body.
	.local int i, x
	i = 0
again:
	if i >= 3 goto done
	x = list[i]
	$P0 = find_if_greater(data, x)
	print "Returned "
	print_thing($P0)
	print ' for '
	print_thing(x)
	print ".\n"
	inc i
	goto again
done:
.end
