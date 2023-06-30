require "odrl/ruby"

# an offer to toshiaki from mark to use the polyA resource during the biohackathon

# core annotatons are:  :title, :creator, :description, :subject :baseURI, :uid, :type
policy = ODRL::Offer.new(
  title: "Offer for the use of BGV Germplasm",
  creator: "https://orcid.org/0000-0001-6960-357X",
  description: "An offer any non-Commercial entity to use Germplasm from the BGV - UPM",
  subject: "nagoya-constraint", # this is a tag
  issued: "2022-06-29"
)

asset = ODRL::Asset.new(uid: "https://fdp.bgv.cbgp.upm.es/dataset/65ffbf3d-bed1-4a9a-abf9-0116cc35b40a",
                        title: "César Gómez Campo Banco de Germoplasma Vegetal de la UPM")

# you indicate the type of party by assigning the predicate (either assigner or assignee)
# ODRLV is the RDF::Vocabulary for ODRL, exported to this namespace
ministerio = ODRL::Party.new(
  uid: "https://absch.cbd.int/en/database/CON/ABSCH-CON-ES-241810/2",
  predicate: ODRLV.assigner,
  title: " Ministerio para la Transición Ecológica y el Reto Demográfico",
  label: " Ministerio para la Transición Ecológica y el Reto Demográfico"
)

# Rules
permission = ODRL::Permission.new(title: "Permission to use")

use = ODRL::Use.new(value: "use") # subclass of action

# Constraints: :uid, :rightOperand, :leftOperand, :operator, :rightOperandReference, :dataType, :unit, :status
constraint_nonprofit = ODRL::Constraint.new(
  title: "Use by non-profit organization",
  leftOperand: "industry",
  operator: "neq",
  rightOperand: "https://w3id.org/dingo#ForProfitOrganisation"
)
constraint_noncommercial = ODRL::Constraint.new(
  title: "Use for non-commercial purposes",
  leftOperand: "purpose",
  operator: "neq",
  rightOperand: "http://purl.obolibrary.org/obo/ExO_0000085"
)
permission.addConstraint(constraint: constraint_nonprofit)
permission.addConstraint(constraint: constraint_noncommercial)
permission.addAsset(asset: asset)
permission.addAssigner(party: ministerio)
permission.addAction(action: use)

policy.addPermission(rule: permission)

policy.load_graph
result = policy.serialize(format: "turtle")
puts result
