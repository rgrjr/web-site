## Compute n!.
.sub factorial
	.param pmc n

	.local pmc result
	unless n > 0 goto zero
gt_zero:
	.local pmc nm1
	nm1 = new 'Integer'
	nm1 = n - 1
	result = factorial(nm1)
	result = result * n
	goto done
zero:
	result = new 'Integer'
	result = 1
done:
	.return (result)
.end

## Driver for factorial.
.sub main :main
	## Testing factorial.
	.local pmc result
	.local int i
	i = 0
again:
	if i > 20 goto done
	result = factorial(i)
	print i
	print '! = '
	print result
	print "\n"
	inc i
	goto again
done:
.end
