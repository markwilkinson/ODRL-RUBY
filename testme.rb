require_relative "./lib/odrl/policy.rb"
require_relative "./lib/odrl/rule.rb"
require_relative "./lib/odrl/base.rb"
require_relative "./lib/odrl/asset.rb"
require_relative "./lib/odrl/constraint.rb"


t = ODRL::Policy.new(
    title: "this",
    author: "mark",
    baseURI: "http://adsjfhalsdjfasdh",

)

pro = ODRL::Prohibition.new({})
# puts t.methods
# abort
# t.addProhibition(rule: pro)
# puts t.rules.length
# puts t.rules[t.rules.keys.first][1].inspect
# puts t.rules[t.rules.keys.first][1].class.to_s == "ODRL::Prohibition"

#p t.inspect
c1 = ODRL::Constraint.new({})
#p c1.inspect
c2 = ODRL::Constraint.new({})
d = ODRL::Duty.new({constraints: c1})
puts d.inspect