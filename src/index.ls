require! {
  swapper: './generator'
  swap-table: './table'
}

pad = (n, m = 2) -> \0 * (m - (""+n).length) + n

swap = (script, re) !->
  for line in script.events
    if line.style.match /^Default|^Alternative|^Top/
      t = line.text
      t = re t
      if (re.test t) and !(t.match /^{\\q2}/) then
        t = '{\\q2}' + t
      line.text = t

bits = (n, m) ->
  for i in pad (n.to-string 2), m
    parse-int i, 10

subswap = (script, key) ->
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
        swap cur, swappers[j]
        index += char[j]
    lang = swap-table[index]
    ret[lang] = cur

  return ret

module.exports = subswap

