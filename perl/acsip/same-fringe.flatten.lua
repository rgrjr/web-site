-- Solving the "same fringe" problem using map_elts in Lua.

function map_elts(tree, functional)
   if type(tree) == 'table' then
      for i = 1, table.getn(tree) do
	 map_elts(tree[i], functional)
      end
   else
      -- It's a leaf.
      functional(tree)
   end
end

function flatten(tree)
   -- Return an arrayref of tree elements.
   local i = 0
   local elts = { }
   map_elts(tree,
	    function (elt)
	       i = i+1
	       elts[i] = elt
	    end)
   return elts
end

function same_fringe_p(tree1, tree2)
   -- Find out whether two trees have the same leaves
   -- the hard way:  By flattening both first.

   -- Flatten . . .
   local elts1 = flatten(tree1)
   local elts2 = flatten(tree2)
   local n = table.getn(elts1)

   -- . . . and check elements.
   if n ~= table.getn(elts2) then
      return false
   else
      for i = 1, n do
	 if elts1[i] ~= elts2[i] then
	    return false
	 end
      end
      -- Must not have found a difference.
      return true
   end
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
