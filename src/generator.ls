swapper-generator = (c) ->
  re =
    gex1: new RegExp "{\\#c}([^{]+){\\#c([^\\#c]?[^}]*)}" \g
    fn1: (m, a, b) -> "{#c}#b{#c#a}"
    gex2: new RegExp "{\\#c\\#c([^}]+)}" \g
    fn2: (m, a) -> "{#c}#a{#c}"
    gex3: new RegExp "{\\#c}{\\#c" \g
    fn3: -> "{#c#c"
    gex: new RegExp "{\\#c" "g"
  fn = (string) ->
    return string
      .replace re.gex1, re.fn1
      .replace re.gex2, re.fn2
      .replace re.gex3, re.fn3
  fn.test = (string) ->
    re.gex.test string
  return fn

module.exports = swapper-generator