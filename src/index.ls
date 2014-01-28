require! {
  swapper: './generator'
  swap-table: './table'
}

pad = (n, m = 2) -> \0 * (m - (""+n).length) + n

swap = (script, re, styles) !->
  for line in script.events
    cont = true
    if line.style.match /^Default|^Alternative|^Top/ then cont = false
    if styles and line.style.match styles then cont = false
    if cont then continue
    t = line.text
    t = re t
    if (re.test t) and !(t.match /^{\\q2}/) then
      t = '{\\q2}' + t
    line.text = t

bits = (n, m) ->
  for i in pad (n.to-string 2), m
    parse-int i, 10

# How subswap works
# =================
# Let's say we get a key like '*/' as input.
# We break this key into a char array like ['*','/']
# and then create another array with swapper functions
# generated with these characters.
#
# We then calculate the number of possible combinations
# with 2^array.length, which in this case is 4.
# We then start a loop from 0 to 3 and on each iteration
# we generate a binary array for the number, for example:
#
# dec    bin    array
#   0 ->  00 -> [0,0]
#   1 ->  01 -> [0,1]
#   2 ->  10 -> [1,0]
#   3 ->  11 -> [1,1]
#
# The binary value is zero-padded to key.length,
# as that is the number of bits we need for this.
# 
# We then use this binary array to deduce which
# swapper functions to apply in this iteration, eg.
#
# [*,/] (the swap functions)
# [0,0] -> skip  *, skip  /, index   '', lang 'eng'
# [0,1] -> skip  *, apply /, index  '/', lang 'mah'
# [1,0] -> apply *, skip  /, index  '*', lang 'enm'
# [1,1] -> apply *, apply /, index '*/', lang 'map'
#
# We also construct an index string of the swaps performed
# in the iteration, which we then use to look up the
# language tag of the result from swap-table.
#
# Finally, we return an object containing all the
# swap-modified scripts under their language keys.

subswap = (script, key, styles) ->
  ret = {}
  char = key.split ''
  klen = key.length
  swappers = []
  len = 2 ^ char.length
  
  for _,i in char
    swappers[i] = swapper char[i]

  for l from 0 til len
    cur = script.clone!
    k = bits l, klen
    index = ''
    for j from 0 til k.length
      if k[j] then
        swap cur, swappers[j], styles
        index += char[j]
    lang = swap-table[index]
    ret[lang] = cur

  return ret

module.exports = subswap

