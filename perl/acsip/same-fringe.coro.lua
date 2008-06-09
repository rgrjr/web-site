-- Solving the "same fringe" problem using Lua coroutines.

function enumerate_elts(tree)
   -- Yield each of the leaves in turn.
   if type(tree) == 'table' then
      -- Note that table.foreach doesn't work in this case,
      -- because it introduces a C call boundary across
      -- which we can't yield.
      for i = 1, table.getn(tree) do
	 enumerate_elts(tree[i])
      end
   else
      -- It's a leaf.
      coroutine.yield(tree)
   end
end

function same_fringe_p(tree1, tree2)
   -- Return true iff the two trees have the same leaves.
   local coro1 = coroutine.wrap(enumerate_elts)
   local coro2 = coroutine.wrap(enumerate_elts)

   local leaf1 = coro1(tree1)
   local leaf2 = coro2(tree2)
   while leaf1 ~= nil and leaf2 ~= nil do
      if leaf1 ~= leaf2 then
	 -- print('mismatch of', leaf1, 'vs', leaf2)
	 return false
      end
      -- print('matching', leaf1, 'and', leaf2)
      leaf1 = coro1()
      leaf2 = coro2()
   end
   -- We win if we finish both trees simultaneously.
   return leaf1 == nil and leaf2 == nil
end

-- Basic test structure.
local s1 = {1, 2, {3, 4}, {{5, {6, 7}, 8}, 9, {10, 11}}}
print('test1', same_fringe_p(s1, s1))
-- Same structure, different values.
local s2 = {1, 2, {3, 4}, {{5, {6, 8}, 7}, 9, {10, 11}}}
print('test2', same_fringe_p(s1, s2))
-- Different structure, different values.
local s3 = {1, 2, {3, 4}, {{5, {6, 7}}, 9, {10, 11}}}
print('test3', same_fringe_p(s1, s3))
-- Different structure, same values.
local s4 = {1, {2, {3}, 4}, {5, {{{6, 7}, 8}, 9, {10, 11}}}}
print('test4', same_fringe_p(s1, s4))
-- Different structure, prefix values.
local s5 = {1, {2, {3}, 4}, {5, {{{6, 7}, 8}, 9}}}
print('test5', same_fringe_p(s1, s5))
print('test6', same_fringe_p(s5, s1))

-- (hack-local-variables)
-- Local Variables:
--   lisp-comment-fill-column: 60
-- End:
