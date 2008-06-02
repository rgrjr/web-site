## Produces equivalent output to map-elts-throw.lisp.

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

## Throw:  Search $catch_list for a matching tag, passing
## value to its continuation if found, and punting if not.
## [This is not called "throw" because that's a Parrot op.]
## The catch frame is represented as a three-element array,
## where the first is the tag, the second is the
## continuation, and the third is the outer $catch_list.
.sub Throw
	.param string tag
	.param pmc value

	## Get the current $catch_list value.
	.local pmc catch_list
	catch_list = get_hll_global '$catch_list'

again:
	## While not null,
	if null catch_list goto oops
	.local string pair_tag
	pair_tag = catch_list[0]
	if tag != pair_tag goto next
	## Got a winner.
	.local pmc continuation
	continuation = catch_list[1]
	.return continuation(value)
next:
	## Next pair.
	catch_list = catch_list[2]
	goto again
oops:
	error("No such tag:  ~S", tag)
.end

## catch:  Push the tag and our exit continuation onto
## $catch_list, and call the catch body.
.sub catch
	.param string tag
	.param pmc catch_body

	## Save off the old $catch_list value.
	.local pmc ocl1
	.lex 'old_catch_list', ocl1
	ocl1 = get_hll_global '$catch_list'

	## Define an action to restore it.
	.local pmc restore_sub, restore_closure
	.const .Sub restore_sub = '_restore_old_catch_list'
	restore_closure = newclosure restore_sub
	pushaction restore_closure

	## Find our return continuation.
	.local pmc exit_cont
	exit_cont = interpinfo .INTERPINFO_CURRENT_CONT

	## Push a catch entry with it.
	.local pmc new_catch_list
	new_catch_list = new 'FixedPMCArray'
	new_catch_list = 3
	new_catch_list[0] = tag
	new_catch_list[1] = exit_cont
	new_catch_list[2] = ocl1
	set_hll_global '$catch_list', new_catch_list

	## Call the catch body.
	.local pmc result
	result = catch_body()
	.return (result)
.end

.sub _restore_old_catch_list :outer('catch')
	.local pmc ocl2
	ocl2 = find_lex 'old_catch_list'
	set_hll_global '$catch_list', ocl2
.end

.sub process_elt
	.param pmc elt
	.param pmc limit

	## Test value against limit
	# print "Testing $value.\n";
	unless elt > limit goto nope

	## Print what we found.
	print "Found "
	print elt
	print "\n"
	Throw("found", elt)
nope:
	.return ()
.end

.sub process_elts
	.param pmc tree1
	.param pmc limit1

	## Create the $limit and $tree lexicals.
	.lex '$limit', limit1
	.lex '$tree', tree1

	## Create a closure of our internal sub.
	.local pmc internal_sub, internal_closure1
	.lex "internal_closure", internal_closure1
	.const .Sub internal_sub = "_process_elts_internal"
        internal_closure1 = newclosure internal_sub

	## Create a body closure, and call catch with it.
	.local pmc body_sub, body_closure, result
	.const .Sub body_sub = "_process_elts_body"
        body_closure = newclosure body_sub
	result = catch("found", body_closure)
	.return (result)
.end

## Implement the catch body within process_elts.
.sub _process_elts_body :outer('process_elts')
	## [no params.]

	.local pmc tree2, internal_closure2
	internal_closure2 = find_lex 'internal_closure'
	tree2 = find_lex '$tree'
	map_elts(tree2, internal_closure2)

	## map_elts returned normally.
	.return ("nothing")
.end

## Call process_elt with elt and limit.
.sub _process_elts_internal :outer('process_elts')
	.param pmc elt

	## Pass limit to process_elt.
	.local pmc limit2
	# print "Testing $elt.\n";
	limit2 = find_lex '$limit'
	process_elt(elt, limit2)
.end

.sub main :main
	## Initialize $catch_list.
	.local pmc catch_list
	null catch_list
	set_hll_global '$catch_list', catch_list

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
	$P0 = process_elts(data, x)
	print "Returned "
	print $P0
	print ' for '
	print x
	print ".\n"
	inc i
	goto again
done:
.end

## (hack-local-variables)
## Local Variables:
##   lisp-comment-fill-column: 60
## End:
