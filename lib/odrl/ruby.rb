require 'linkeddata'
require 'rdf/raptor'

#RDF =  RDF::Vocabulary.new("http://www.w3.org/1999/02/22-rdf-syntax-ns#")


RDFS = RDF::Vocabulary.new("http://www.w3.org/2000/01/rdf-schema#")
DCAT = RDF::Vocabulary.new("http://www.w3.org/ns/dcat#")
DC = RDF::Vocabulary.new("http://purl.org/dc/elements/1.1/")
DCT = RDF::Vocabulary.new("http://purl.org/dc/terms/")
FUND = RDF::Vocabulary.new("http://vocab.ox.ac.uk/projectfunding#")
SKOS =  RDF::Vocabulary.new("http://www.w3.org/2004/02/skos/core#")
ODRLV =  RDF::Vocabulary.new("http://www.w3.org/ns/odrl/2/")
OBO = RDF::Vocabulary.new("http://purl.obolibrary.org/obo/")
XSD = RDF::Vocabulary.new("http://www.w3.org/2001/XMLSchema#")
SCHEMA = RDF::Vocabulary.new("https://schema.org/")

require_relative "./base"
require_relative "./action"
require_relative "./asset"
require_relative "./constraint"
require_relative "./party"
require_relative "./policy"
require_relative "./rule"

module ODRL
end
