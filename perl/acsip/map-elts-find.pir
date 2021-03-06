## Produces equivalent output to map-elts-find.pl.text.

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

	## Create the $result and $limit lexicals.
	.lex '$limit', limit1
	.local pmc result1
	.lex '$result', result1
	result1 = new 'Undef'

	## Create an exit continuation
	.local pmc exit_cont1
	.lex 'exit_cont', exit_cont1
	exit_cont1 = new 'Continuation'
	set_addr exit_cont1, done

	## Create a closure of our internal sub.
	.local pmc find_internal, find_closure
	.const .Sub find_internal = "_find_internal"
        find_closure = newclosure find_internal
	map_elts(tree, find_closure)

	## map_elts returned normally.
	print "Nothing found greater than "
	print limit1
	print ".\n"
done:
	.return (result1)
.end

.sub _find_internal :outer('find_if_greater')
	.param pmc value

	## Test value against limit
	.local pmc limit2
	# print "Testing $value.\n";
	limit2 = find_lex '$limit'
	unless value > limit2 goto nope

	## Print and store in $result.
	print "Found "
	print value
	print "\n"
	store_lex '$result', value

	## Return to find_if_greater.
	.local pmc exit_cont2
	exit_cont2 = find_lex 'exit_cont'
	exit_cont2()
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

	## Main body.
	$P0 = find_if_greater(data, 7)
	print "Returned "
	print $P0
	print ".\n"
	find_if_greater(data, 99)
.end
