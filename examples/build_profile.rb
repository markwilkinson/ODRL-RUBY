require 'odrl/profile/builder'

p = ODRL::Profile::Builder.new(
    uri: 'https://example.org/myprofiles/germplasm_odrl_profile.ttl',
    title: "ODRL Profile for Germplasm resources",
    description: "There are some properties and comparisons that only make sense in the Germplasm expert domain",
    author: "Mark D Wilkinson",
    profile_class: "https://example.org/myprofiles/ontology#SeedOffer"
)

p.asset_relations << ODRL::Profile::AssetRelation.new( 
    uri: "https://example.org/myprofiles/ontology#nagoya_permission",
    label: "Permission under Nagoya protocol", 
    definition: "Permission is a special thing in the Nagoya protocol")


p.party_functional_roles << ODRL::Profile::AssetRelation.new(  
    uri: "https://example.org/myprofiles/ontology#nagoya_assigner",
    label: "Assigner with Nagoya authority to assign", 
    definition: "Assigners have special responsibilities in the Nagoya protocol")

p.actions << ODRL::Profile::Rule.new( 
    uri: "https://example.org/myprofiles/ontology#nagoya_propogate",
    label: "Plant and Harvest", 
    definition: "the action of planting and harvesting the seed", 
    included_in: ODRLV.use,
    implies: ODRLV.distribute)


p.leftOperands << ODRL::Profile::LeftOperand.new( 
    uri: "https://example.org/myprofiles/ontology#at_risk_species",
    label: "At Risk Species", 
    definition: "A species that has been flagged as at-risk of extinction")

p.rightOperands << ODRL::Profile::RightOperand.new( 
    uri: "https://example.org/myprofiles/ontology#on_watchlist",
    label: "On Watchlist", 
    definition: "A species whose risk of extinction is on a watchlist")

p.rightOperands << ODRL::Profile::Relation.new( 
    uri: "https://example.org/myprofiles/ontology#within_risk_boundary",
    label: "Within Bounds", 
    definition: "comparison of risk boundaries")


p.build()
puts p.serialize
