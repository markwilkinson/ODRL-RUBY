# frozen_string_literal: true

require 'linkeddata'
require_relative "odrl/version"

RDFV =  RDF::Vocabulary.new("http://www.w3.org/1999/02/22-rdf-syntax-ns#")
RDFS = RDF::Vocabulary.new("http://www.w3.org/2000/01/rdf-schema#")
DCAT = RDF::Vocabulary.new("http://www.w3.org/ns/dcat#")
DC = RDF::Vocabulary.new("http://purl.org/dc/elements/1.1/")
DCT = RDF::Vocabulary.new("http://purl.org/dc/terms/")
FUND = RDF::Vocabulary.new("http://vocab.ox.ac.uk/projectfunding#")
SKOS =  RDF::Vocabulary.new("http://www.w3.org/2004/02/skos/core#")
ODRLV =  RDF::Vocabulary.new("http://www.w3.org/ns/odrl/2/")
OBO = RDF::Vocabulary.new("http://purl.obolibrary.org/obo/")
XSD = RDF::Vocabulary.new("http://www.w3.org/2001/XMLSchema#")
http://purl.org/dc/elements/subject
CPOLICY= "http://www.w3.org/ns/odrl/2/Policy"

CSET= "http://www.w3.org/ns/odrl/2/Set"
COFFER= "http://www.w3.org/ns/odrl/2/Offer"
CREQUEST= "http://www.w3.org/ns/odrl/2/Request"
CAGREEMENT= "http://www.w3.org/ns/odrl/2/Agreement"

PASSET = "http://www.w3.org/ns/odrl/2/target"
CASSET= "http://www.w3.org/ns/odrl/2/Asset"

CPERMISSION= "http://www.w3.org/ns/odrl/2/permission"
PPERMISSION = "http://www.w3.org/ns/odrl/2/Permission"
CPROHIBITION= "http://www.w3.org/ns/odrl/2/prohibition"
PPROHIBITION = "http://www.w3.org/ns/odrl/2/Prohibition"
PDUTY= "http://www.w3.org/ns/odrl/2/obligation"
CDUTY = "http://www.w3.org/ns/odrl/2/Duty"

PRULE = "http://www.w3.org/ns/odrl/2/Rule"


PACTION = "http://www.w3.org/ns/odrl/2/action"
CACTION= "http://www.w3.org/ns/odrl/2/Action"

PREFINEMENT = "http://www.w3.org/ns/odrl/2/refinement"

PASSIGNER = "http://www.w3.org/ns/odrl/2/assigner"
PASSIGNEE =  "http://www.w3.org/ns/odrl/2/assignee"
CPARTY= "http://www.w3.org/ns/odrl/2/Party"

PCONSTRAINT = "http://www.w3.org/ns/odrl/2/constraint"
CCONSTRAINT = "http://www.w3.org/ns/odrl/2/Constraint"
PLEFT = "http://www.w3.org/ns/odrl/2/leftOperand"
PRIGHT = "http://www.w3.org/ns/odrl/2/rightOperand"
POPERATOR = "http://www.w3.org/ns/odrl/2/operator"
POPERANDREFERENCE = "http://www.w3.org/ns/odrl/2/rightOperandReference"
PDATATYPE = "http://www.w3.org/ns/odrl/2/dataType"
PUNIT = "http://www.w3.org/ns/odrl/2/unit"
PSTATUS = "http://www.w3.org/ns/odrl/2/status"

PPARTOF = "http://www.w3.org/ns/odrl/2/partOf"


PROPERTIES = {
        title: DCT.title,
        author: DCT.creator,
        description: DCT.description,
        uid: DCT.identifier,
        type: RDF.type,
        subject: DCT.subject

}

module ODRL
        class Base

        @@repository = RDF::Repository.new()
                
        attr_accessor :title, :creator, :description, :subject :baseURI, :uid, :type

        def self.baseURI
                return ENV['ODRL_BASEURI'] || "http://example.org/"
        end

        def self.repository
                return @@repository
        end
        def repository
                return @@repository
        end

        def self.clear_repository
                @@repository.clear!
                return true
        end

        def initialize(args)
                #args = defaults.merge(args)

                @title = args[:title]
                @creator = args[:creator]
                @description = args[:description]
                @subject = args[:subject]
                @baseURI = args[:baseURI] || self.baseURI
                @uid = args[:uid]
                @type = args[:type]
                #@repository = RDF::Repository.new() unless self.repository

                raise "Every object must have a uid - attempt to create #{@type}" unless @uid

                $g = RDF::Graph.new()
                if ENV["TRIPLES_FORMAT"]
                        $format = ENV["TRIPLES_FORMAT"].to_sym
                else
                        $format = :jsonld
                end
                $writer = get_writer(type: $format)  # set it by default

        end

        def get_writer(type:)
                $writer = RDF::Writer.for(type).buffer do |w|
                w.prefix(:foaf, RDF::URI.new("http://xmlns.com/foaf/0.1/"))
                w.prefix(:dc, RDF::URI.new("http://purl.org/dc/terms/"))
                w.prefix(:rdf, RDF::URI.new("http://www.w3.org/1999/02/22-rdf-syntax-ns#"))
                w.prefix(:rdfs, RDF::URI.new("http://www.w3.org/2000/01/rdf-schema#"))
                w.prefix(:vcard, RDF::URI.new("http://www.w3.org/2006/vcard/ns#"))
                w.prefix(:odrl, RDF::URI.new("http://www.w3.org/ns/odrl/2/"))
                w.prefix(:this, RDF::URI.new("http://w3id.org/FAIR_Training_LDP/DAV/home/LDP/DUC-CCE/IPGB#"))
                w.prefix(:obo, RDF::URI.new("http://purl.obolibrary.org/obo/"))
                w.prefix(:xsd, RDF::URI.new("http://www.w3.org/2001/XMLSchema#"))
                end
                return $writer
        end

        def triplify(s, p, o, repo)
        
                if s.class == String
                        s = s.strip
                end
                if p.class == String
                        p = p.strip
                end
                if o.class == String
                        o = o.strip
                end
                
                unless s.respond_to?('uri')
                
                if s.to_s =~ /^\w+:\/?\/?[^\s]+/
                        s = RDF::URI.new(s.to_s)
                else
                abort "Subject #{s.to_s} must be a URI-compatible thingy"
                end
                end
                
                unless p.respond_to?('uri')
        
                if p.to_s =~ /^\w+:\/?\/?[^\s]+/
                        p = RDF::URI.new(p.to_s)
                else
                abort "Predicate #{p.to_s} must be a URI-compatible thingy"
                end
                end
        
                unless o.respond_to?('uri')
                if o.to_s =~ /^\w+:\/?\/?[^\s]+/
                        o = RDF::URI.new(o.to_s)
                elsif o.to_s =~ /^\d{4}-[01]\d-[0-3]\dT[0-2]\d:[0-5]\d/
                        o = RDF::Literal.new(o.to_s, :datatype => RDF::XSD.date)
                elsif o.to_s =~ /^\d\.\d/
                        o = RDF::Literal.new(o.to_s, :datatype => RDF::XSD.float)
                elsif o.to_s =~ /^[0-9]+$/
                        o = RDF::Literal.new(o.to_s, :datatype => RDF::XSD.int)
                else
                        o = RDF::Literal.new(o.to_s, :language => :en)
                end
                end
        
                triple = RDF::Statement(s, p, o) 
                repo.insert(triple)
        
                return true
        end

        def self.getuuid
                return  Time.now.to_f.to_s.gsub("\.", "")[1..14]               
        end

        def load_graph
                [:title, :creator, :description, :subject, :uid, :type].each do |method|
                        next unless self.send(method)
                        next if self.send(method).empty?
                        subject = self.uid
                        predicate = PROPERTIES[method]
                        object = self.send(method)
                        repo = self.repository
                        triplify(subject, predicate, object, repo)
                end
        end

        def serialize
                return self.repository.dump($format)
        end
        
        private  
        
        
        end
end
