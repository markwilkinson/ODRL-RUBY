require_relative "../lib/odrl/policy.rb"
require_relative "../lib/odrl/rule.rb"
require_relative "../lib/odrl/base.rb"
require_relative "../lib/odrl/asset.rb"
require_relative "../lib/odrl/constraint.rb"
require_relative "../lib/odrl/party.rb"
require_relative "../lib/odrl/action.rb"

require 'linkeddata'

RDF =  RDF::Vocabulary.new("http://www.w3.org/1999/02/22-rdf-syntax-ns#")
RDFS = RDF::Vocabulary.new("http://www.w3.org/2000/01/rdf-schema#")
DCAT = RDF::Vocabulary.new("http://www.w3.org/ns/dcat#")
DC = RDF::Vocabulary.new("http://purl.org/dc/elements/1.1/")
DCT = RDF::Vocabulary.new("http://purl.org/dc/terms/")
FUND = RDF::Vocabulary.new("http://vocab.ox.ac.uk/projectfunding#")
SKOS =  RDF::Vocabulary.new("http://www.w3.org/2004/02/skos/core#")
ODRL =  RDF::Vocabulary.new("http://www.w3.org/ns/odrl/2/")
OBO = RDF::Vocabulary.new("http://purl.obolibrary.org/obo/")
XSD = RDF::Vocabulary.new("http://www.w3.org/2001/XMLSchema#")

an offer to toshiaki from mark to use the polyA resource during the biohackathon

# core annotatons are:  :title, :creator, :description, :subject :baseURI, :uid, :type
policy = ODRL::Offer.new(
    title: "Offer to Toshiaki-san", 
    creator: "https://orcid.org/0000-0001-6960-357X", 
    description: "An offer for Toshiaki-san to use the polyA data during the hackathon",
    subject: "collaboration", # this is the CCE category
)

asset = ODRL::Asset.new(uid: "http://mark.wilkinson.org/data/polyA", title: "Mark's PolyA Database")

# you indicate the type of party by assigning the predicate (either assigner or assignee)
mark = ODRL::Party.new(predicate: ODRL.assigner, title: "Mark D Wilkinson" )
toshiaki = ODRL::Party.new(predicate: ODRL.assignee, title: "Toshiaki Katayama")

# Rules
permission = ODRL::Permission.new(value: "use")

# Constraints: :uid, :rightOperand, :leftOperand, :operator, :rightOperandReference, :dataType, :unit, :status
constraint = ODRL::Constraint.new(
    title: "Only during the hackathon",
    leftOperand: "event",
    operator: "eq",
    rightOperand: "https://2023.biohackathon.org"
)
permission.addConstraint(constraint: constraint)

policy.addAsset(asset: asset)
policy.addAssigner(party: toshiaki)
policy.addAssignee(party: mark)
policy.addPermission(rule: permission)

policy.load_graph
result = policy.serialize
puts result

