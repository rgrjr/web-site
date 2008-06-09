## PIR implementation of same-fringe.coro.lua in terms of
## the Parrot::Coroutine class.

.sub coroutine_wrap
	.param pmc functional

	.local pmc coro
	coro = new 'FixedPMCArray'
	coro = 3
	coro[0] = 'new'
	coro[1] = functional
	.return (functional)
.end

## Recursive coroutine to enumerate tree elements.  Each element that is not a
## FixedPMCArray is yielded in turn.
.sub enumerate_elts
	.param pmc coro
	.param pmc tree

	$I0 = isa tree, 'FixedPMCArray'
	unless $I0 goto leaf

	## Loop through array elements, recurring on each.
	.local int size, i
	i = 0
	size = tree
again:
	if i >= size goto done
	## print "[coro recur: elt "
	## print i
	## print "]\n"
	.local pmc elt
	elt = tree[i]
	enumerate_elts(coro, elt)
	inc i
	goto again

leaf:
	## Found a tree leaf.
	## print "[leaf "
	## print tree
	## print "]\n"
	coro.'yield'(tree)
	goto done

done:
	## Return nothing, to match the Lua conventions.
	.local pmc nil
	null nil
	.return (nil)
.end

## Solution to the "same fringe" problem that uses coroutines to enumerate each
## of two passed trees of numbers.  Returns 1 if the trees have the same fringe,
## else 0.
.sub same_fringe_p
	.param pmc tree1
	.param pmc tree2

	.local pmc coro_class
	coro_class = get_class 'Parrot::Coroutine'

	.local pmc coro1, coro2
	.const .Sub coro_sub = "enumerate_elts"
	coro1 = coro_class.'new'('initial_sub' => coro_sub)
	coro2 = coro_class.'new'('initial_sub' => coro_sub)

	.local pmc leaf1, leaf2
	leaf1 = coro1.'resume'(coro1, tree1)
	leaf2 = coro2.'resume'(coro2, tree2)

loop:
	if null leaf1 goto empty_first
	if null leaf2 goto not_equal

	## Now have results from both.
	## print "[got "
	## print leaf1
	## print ' and '
	## print leaf2
	## print "]\n"
	if leaf1 == leaf2 goto next
	.return (0)

	## Set up for the next iteration.
next:
	leaf1 = coro1.'resume'()
	leaf2 = coro2.'resume'()
	goto loop
empty_first:
	if null leaf2 goto equal
not_equal:
	.return (0)
equal:
	.return (1)
.end

## Test case helper sub.
.sub do_test
	.param string test
	.param pmc tree1
	.param pmc tree2

	.local int result
	(result) = same_fringe_p(tree1, tree2)
	.local string result_str
	result_str = 'true'
	if result goto true
	result_str = 'false'
true:
	print test
	print "\t"
	print result_str
	print "\n"
.end

.sub main :main
	load_bytecode 'Parrot/Coroutine.pir'

	## Initialize variables.
	.local pmc s1, s2, s3, s4, s5
	## s1 contains [1, 2, [3, 4], [[5, [6, 7], 8], 9, [10, 11]]]
	s1 = new 'FixedPMCArray'
	s1 = 4
	s1[0] = 1
	s1[1] = 2
	.local pmc s1_2
	## s1_2 contains [3, 4]
	s1_2 = new 'FixedPMCArray'
	s1_2 = 2
	s1_2[0] = 3
	s1_2[1] = 4
	s1[2] = s1_2
	.local pmc s1_3
	## s1_3 contains [[5, [6, 7], 8], 9, [10, 11]]
	s1_3 = new 'FixedPMCArray'
	s1_3 = 3
	.local pmc s1_3_0
	## s1_3_0 contains [5, [6, 7], 8]
	s1_3_0 = new 'FixedPMCArray'
	s1_3_0 = 3
	s1_3_0[0] = 5
	.local pmc s1_3_0_1
	## s1_3_0_1 contains [6, 7]
	s1_3_0_1 = new 'FixedPMCArray'
	s1_3_0_1 = 2
	s1_3_0_1[0] = 6
	s1_3_0_1[1] = 7
	s1_3_0[1] = s1_3_0_1
	s1_3_0[2] = 8
	s1_3[0] = s1_3_0
	s1_3[1] = 9
	.local pmc s1_3_2
	## s1_3_2 contains [10, 11]
	s1_3_2 = new 'FixedPMCArray'
	s1_3_2 = 2
	s1_3_2[0] = 10
	s1_3_2[1] = 11
	s1_3[2] = s1_3_2
	s1[3] = s1_3

	## s1 contains [1, 2, [3, 4], [[5, [6, 7], 8], 9, [10, 11]]]
	s1 = new 'FixedPMCArray'
	s1 = 4
	s1[0] = 1
	s1[1] = 2
	.local pmc s1_2
	## s1_2 contains [3, 4]
	s1_2 = new 'FixedPMCArray'
	s1_2 = 2
	s1_2[0] = 3
	s1_2[1] = 4
	s1[2] = s1_2
	.local pmc s1_3
	## s1_3 contains [[5, [6, 7], 8], 9, [10, 11]]
	s1_3 = new 'FixedPMCArray'
	s1_3 = 3
	.local pmc s1_3_0
	## s1_3_0 contains [5, [6, 7], 8]
	s1_3_0 = new 'FixedPMCArray'
	s1_3_0 = 3
	s1_3_0[0] = 5
	.local pmc s1_3_0_1
	## s1_3_0_1 contains [6, 7]
	s1_3_0_1 = new 'FixedPMCArray'
	s1_3_0_1 = 2
	s1_3_0_1[0] = 6
	s1_3_0_1[1] = 7
	s1_3_0[1] = s1_3_0_1
	s1_3_0[2] = 8
	s1_3[0] = s1_3_0
	s1_3[1] = 9
	.local pmc s1_3_2
	## s1_3_2 contains [10, 11]
	s1_3_2 = new 'FixedPMCArray'
	s1_3_2 = 2
	s1_3_2[0] = 10
	s1_3_2[1] = 11
	s1_3[2] = s1_3_2
	s1[3] = s1_3

	## s2 contains [1, 2, [3, 4], [[5, [6, 8], 7], 9, [10, 11]]]
	s2 = new 'FixedPMCArray'
	s2 = 4
	s2[0] = 1
	s2[1] = 2
	.local pmc s2_2
	## s2_2 contains [3, 4]
	s2_2 = new 'FixedPMCArray'
	s2_2 = 2
	s2_2[0] = 3
	s2_2[1] = 4
	s2[2] = s2_2
	.local pmc s2_3
	## s2_3 contains [[5, [6, 8], 7], 9, [10, 11]]
	s2_3 = new 'FixedPMCArray'
	s2_3 = 3
	.local pmc s2_3_0
	## s2_3_0 contains [5, [6, 8], 7]
	s2_3_0 = new 'FixedPMCArray'
	s2_3_0 = 3
	s2_3_0[0] = 5
	.local pmc s2_3_0_1
	## s2_3_0_1 contains [6, 8]
	s2_3_0_1 = new 'FixedPMCArray'
	s2_3_0_1 = 2
	s2_3_0_1[0] = 6
	s2_3_0_1[1] = 8
	s2_3_0[1] = s2_3_0_1
	s2_3_0[2] = 7
	s2_3[0] = s2_3_0
	s2_3[1] = 9
	.local pmc s2_3_2
	## s2_3_2 contains [10, 11]
	s2_3_2 = new 'FixedPMCArray'
	s2_3_2 = 2
	s2_3_2[0] = 10
	s2_3_2[1] = 11
	s2_3[2] = s2_3_2
	s2[3] = s2_3

	## s3 contains [1, 2, [3, 4], [[5, [6, 7]], 9, [10, 11]]]
	s3 = new 'FixedPMCArray'
	s3 = 4
	s3[0] = 1
	s3[1] = 2
	.local pmc s3_2
	## s3_2 contains [3, 4]
	s3_2 = new 'FixedPMCArray'
	s3_2 = 2
	s3_2[0] = 3
	s3_2[1] = 4
	s3[2] = s3_2
	.local pmc s3_3
	## s3_3 contains [[5, [6, 7]], 9, [10, 11]]
	s3_3 = new 'FixedPMCArray'
	s3_3 = 3
	.local pmc s3_3_0
	## s3_3_0 contains [5, [6, 7]]
	s3_3_0 = new 'FixedPMCArray'
	s3_3_0 = 2
	s3_3_0[0] = 5
	.local pmc s3_3_0_1
	## s3_3_0_1 contains [6, 7]
	s3_3_0_1 = new 'FixedPMCArray'
	s3_3_0_1 = 2
	s3_3_0_1[0] = 6
	s3_3_0_1[1] = 7
	s3_3_0[1] = s3_3_0_1
	s3_3[0] = s3_3_0
	s3_3[1] = 9
	.local pmc s3_3_2
	## s3_3_2 contains [10, 11]
	s3_3_2 = new 'FixedPMCArray'
	s3_3_2 = 2
	s3_3_2[0] = 10
	s3_3_2[1] = 11
	s3_3[2] = s3_3_2
	s3[3] = s3_3

	## s4 contains [1, [2, [3], 4], [5, [[[6, 7], 8], 9, [10, 11]]]]
	s4 = new 'FixedPMCArray'
	s4 = 3
	s4[0] = 1
	.local pmc s4_1
	## s4_1 contains [2, [3], 4]
	s4_1 = new 'FixedPMCArray'
	s4_1 = 3
	s4_1[0] = 2
	.local pmc s4_1_1
	## s4_1_1 contains [3]
	s4_1_1 = new 'FixedPMCArray'
	s4_1_1 = 1
	s4_1_1[0] = 3
	s4_1[1] = s4_1_1
	s4_1[2] = 4
	s4[1] = s4_1
	.local pmc s4_2
	## s4_2 contains [5, [[[6, 7], 8], 9, [10, 11]]]
	s4_2 = new 'FixedPMCArray'
	s4_2 = 2
	s4_2[0] = 5
	.local pmc s4_2_1
	## s4_2_1 contains [[[6, 7], 8], 9, [10, 11]]
	s4_2_1 = new 'FixedPMCArray'
	s4_2_1 = 3
	.local pmc s4_2_1_0
	## s4_2_1_0 contains [[6, 7], 8]
	s4_2_1_0 = new 'FixedPMCArray'
	s4_2_1_0 = 2
	.local pmc s4_2_1_0_0
	## s4_2_1_0_0 contains [6, 7]
	s4_2_1_0_0 = new 'FixedPMCArray'
	s4_2_1_0_0 = 2
	s4_2_1_0_0[0] = 6
	s4_2_1_0_0[1] = 7
	s4_2_1_0[0] = s4_2_1_0_0
	s4_2_1_0[1] = 8
	s4_2_1[0] = s4_2_1_0
	s4_2_1[1] = 9
	.local pmc s4_2_1_2
	## s4_2_1_2 contains [10, 11]
	s4_2_1_2 = new 'FixedPMCArray'
	s4_2_1_2 = 2
	s4_2_1_2[0] = 10
	s4_2_1_2[1] = 11
	s4_2_1[2] = s4_2_1_2
	s4_2[1] = s4_2_1
	s4[2] = s4_2

	## s5 contains [1, [2, [3], 4], [5, [[[6, 7], 8], 9]]]
	s5 = new 'FixedPMCArray'
	s5 = 3
	s5[0] = 1
	.local pmc s5_1
	## s5_1 contains [2, [3], 4]
	s5_1 = new 'FixedPMCArray'
	s5_1 = 3
	s5_1[0] = 2
	.local pmc s5_1_1
	## s5_1_1 contains [3]
	s5_1_1 = new 'FixedPMCArray'
	s5_1_1 = 1
	s5_1_1[0] = 3
	s5_1[1] = s5_1_1
	s5_1[2] = 4
	s5[1] = s5_1
	.local pmc s5_2
	## s5_2 contains [5, [[[6, 7], 8], 9]]
	s5_2 = new 'FixedPMCArray'
	s5_2 = 2
	s5_2[0] = 5
	.local pmc s5_2_1
	## s5_2_1 contains [[[6, 7], 8], 9]
	s5_2_1 = new 'FixedPMCArray'
	s5_2_1 = 2
	.local pmc s5_2_1_0
	## s5_2_1_0 contains [[6, 7], 8]
	s5_2_1_0 = new 'FixedPMCArray'
	s5_2_1_0 = 2
	.local pmc s5_2_1_0_0
	## s5_2_1_0_0 contains [6, 7]
	s5_2_1_0_0 = new 'FixedPMCArray'
	s5_2_1_0_0 = 2
	s5_2_1_0_0[0] = 6
	s5_2_1_0_0[1] = 7
	s5_2_1_0[0] = s5_2_1_0_0
	s5_2_1_0[1] = 8
	s5_2_1[0] = s5_2_1_0
	s5_2_1[1] = 9
	s5_2[1] = s5_2_1
	s5[2] = s5_2

	## Run tests.
	do_test('test1', s1, s1)
	do_test('test2', s1, s2)
	do_test('test3', s1, s3)
	do_test('test4', s1, s4)
	do_test('test5', s1, s5)
	do_test('test6', s5, s1)
.end
