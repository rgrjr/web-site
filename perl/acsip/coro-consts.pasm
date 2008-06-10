
## Define the slots of our coroutine pseudo-object.
## (We have to do this in a separate PASM file, because
## (oddly) PIR doesn't support .macro_const.)
.macro_const CORO_STATE 0
.macro_const CORO_CONT  1

## Symbolic constant values for the CORO_STATE slot.
.macro_const CORO_DEAD_STATE    0
.macro_const CORO_OUTSIDE_STATE 1
.macro_const CORO_INSIDE_STATE  2
