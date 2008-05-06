## Compute n!.
.sub factorial
	.param pmc n
	if n > 1 goto multiply
	.return (1)
multiply:
	.local pmc result, nm1
	nm1 = new 'Integer'
	nm1 = n - 1
	result = factorial(nm1)
	result = result * n
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
