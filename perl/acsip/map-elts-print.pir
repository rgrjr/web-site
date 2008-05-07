## Produces equivalent output to map-elts-print.pl.text.

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

.sub number_leaves
	.param pmc tree

	## Create the $count lexical
	.local pmc count
	.lex '$count', count
	count = new 'Integer'
	count = 0

	## Create a closure of our internal sub.
	.local pmc number_one_leaf, number_closure
	.const .Sub number_one_leaf = "_number_one_leaf"
        number_closure = newclosure number_one_leaf
	map_elts(tree, number_closure)
.end

.sub _number_one_leaf :outer('number_leaves')
	.param pmc thing

	.local pmc count
	count = find_lex '$count'
	inc count	## by side effect.
	print count
	print ": "
	print thing
	print "\n"
.end

.sub main :main
	.local pmc tree, branch4, branch5, branch51
	## Build our test case data.
	tree = new 'FixedPMCArray'
	tree = 5
	tree[0] = 1
	tree[1] = 2
	tree[2] = 3
	branch4 = new 'FixedPMCArray'
	branch4 = 2
	branch4[0] = '4a'
	branch4[1] = '4b'
	tree[3] = branch4
	branch5 = new 'FixedPMCArray'
	branch5 = 2
	branch51 = new 'FixedPMCArray'
	branch51 = 1
	branch51[0] = '5aa'
	branch5[0] = branch51
	branch5[1] = '5b'
	tree[4] = branch5
	## Now number the leaves.
	number_leaves(tree)
.end
