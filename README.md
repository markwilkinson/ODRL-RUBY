# ODRL::Ruby

This is a gem to build ODRL records, and serialize them. Does not cover the full ODRL model (yet!)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'odrl-ruby'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install odrl-ruby

## Usage

```
require 'odrl/ruby'

# an offer to toshiaki from mark to use the polyA resource during the biohackathon

# core annotatons are:  :title, :creator, :description, :subject :baseURI, :uid, :type
policy = ODRL::Offer.new(
    title: "Offer to Toshiaki-san", 
    creator: "https://orcid.org/0000-0001-6960-357X", 
    description: "An offer for Toshiaki-san to use the polyA data during the hackathon",
    subject: "collaboration", # this is the CCE category - useful for EJP-RD ONLYU
)

asset = ODRL::Asset.new(uid: "http://mark.wilkinson.org/data/polyA", title: "Mark's PolyA Database")

# you indicate the type of party by assigning the predicate (either assigner or assignee)
# ODRLV is the RDF::Vocabulary for ODRL, exported to this namespace
mark = ODRL::Party.new(uid: "https://orcid.org/0000-0001-6960-357X", predicate: ODRLV.assigner, title: "Mark D Wilkinson" )
toshiaki = ODRL::Party.new(uid: "https://orcid.org/0000-0003-2391-0384", predicate: ODRLV.assignee, title: "Toshiaki Katayama")

# Rules
permission = ODRL::Permission.new(title: "Permission to use")

use = ODRL::Use.new(value: "use") # subclass of ODRL::Action

# Constraints: :uid, :rightOperand, :leftOperand, :operator, :rightOperandReference, :dataType, :unit, :status
constraint = ODRL::Constraint.new(
    title: "Only during the hackathon",
    leftOperand: "event",
    operator: "eq",
    rightOperand: "https://2023.biohackathon.org"
)
permission.addConstraint(constraint: constraint)
permission.addAsset(asset: asset)
permission.addAssigner(party: toshiaki)
permission.addAssignee(party: mark)
permission.addAction(action: use)

policy.addPermission(rule: permission)

policy.load_graph  # this brings the triples into memory, cascading down all objects conneted to "policuy"
result = policy.serialize(format: 'turtle')  # get the RDF string
puts result
```


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
