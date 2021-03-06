## Produces equivalent output to map-elts-return.lisp.

.include 'interpinfo.pasm'

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
	.param pmc limit1

	## Create the $limit lexical.
	.lex '$limit', limit1

	## Store our return continuation as exit_cont.
	.local pmc exit_cont1
	.lex 'exit_cont', exit_cont1
	exit_cont1 = interpinfo .INTERPINFO_CURRENT_CONT

	## Create a closure of our internal sub.
	.local pmc find_internal, find_closure
	.const .Sub find_internal = "_find_internal"
        find_closure = newclosure find_internal
	map_elts(tree, find_closure)

	## map_elts returned normally.
	.return ("nothing")
.end

.sub _find_internal :outer('find_if_greater')
	.param pmc value

	## Test value against limit
	.local pmc limit2
	# print "Testing $value.\n";
	limit2 = find_lex '$limit'
	unless value > limit2 goto nope

	## Print what we found.
	print "Found "
	print value
	print "\n"

	## Return it as the result from find_if_greater.
	.local pmc exit_cont2
	exit_cont2 = find_lex 'exit_cont'
	exit_cont2(value)
nope:
	.return ()
.end

.sub main :main
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
	print $P0
	print ' for '
	print x
	print ".\n"
	inc i
	goto again
done:
.end
