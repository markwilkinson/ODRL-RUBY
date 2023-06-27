# frozen_string_literal: true

require_relative "odrl/version"


CPOLICY= ODRLV.Policy.to_s

CSET= ODRLV.Set.to_s
COFFER= ODRLV.Offer.to_s
CREQUEST= ODRLV.Request.to_s
CAGREEMENT= ODRLV.Agreement.to_s
CPRIVACY= ODRLV.Privacy.to_s
PASSET = ODRLV.target.to_s
CASSET= ODRLV.Asset.to_s

CPERMISSION= ODRLV.Permission.to_s
PPERMISSION = ODRLV.permission.to_s
CPROHIBITION= ODRLV.Prohibition.to_s
PPROHIBITION = ODRLV.prohibition.to_s
PDUTY= ODRLV.obligation.to_s
CDUTY = ODRLV.Duty.to_s

PRULE = ODRLV.Rule.to_s


PACTION = ODRLV.action.to_s
CACTION= ODRLV.Action.to_s

PREFINEMENT = ODRLV.refinement.to_s

PASSIGNER = ODRLV.assigner.to_s
PASSIGNEE =  ODRLV.assignee.to_s
CPARTY= ODRLV.Party.to_s

PCONSTRAINT = ODRLV.constraint.to_s
CCONSTRAINT = ODRLV.Constraint.to_s
PLEFT = ODRLV.leftOperand.to_s
PRIGHT = ODRLV.rightOperand.to_s
POPERATOR = ODRLV.operator.to_s
POPERANDREFERENCE = ODRLV.rightOperandReference.to_s
PDATATYPE = ODRLV.dataType.to_s
PUNIT = ODRLV.unit.to_s
PSTATUS = ODRLV.status.to_s

PPARTOF = ODRLV.partOf.to_s


PROPERTIES = {
        title: DCT.title,
        creator: DCT.creator,
        description: DCT.description,
        id: DCT.identifier,
        type: RDF.type,
        subject: DCT.subject,
        uid: ODRLV.uid,
        label: RDFS.label,
}

module ODRL
        class Base

        @@repository = RDF::Repository.new()
                
        attr_accessor :title, :creator, :description, :subject, :baseURI, :uid, :id, :type, :label

        def self.baseURI
                return ENV['ODRL_BASEURI'] || "http://example.org"
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
                @label = args[:label] || @title 
                @id = args[:uid] || nil
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
                                raise "Subject #{s.to_s} must be a URI-compatible thingy #{s}, #{p}, #{o}"
                        end
                end
                
                unless p.respond_to?('uri')
        
                        if p.to_s =~ /^\w+:\/?\/?[^\s]+/
                                p = RDF::URI.new(p.to_s)
                        else
                                raise "Predicate #{p.to_s} must be a URI-compatible thingy #{s}, #{p}, #{o}"
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
                [:title, :label, :creator, :description, :subject, :uid, :type].each do |method|
                        next unless self.send(method)
                        next if self.send(method).empty?
                        subject = self.uid
                        predicate = PROPERTIES[method]
                        # warn "prediate #{predicate} for method #{method}"
                        object = self.send(method)
                        repo = self.repository
                        triplify(subject, predicate, object, repo)
                end
        end

        def serialize(format: $format)
                format = format.to_sym
                return self.repository.dump(format)
        end
        
        private  
        
        
        end
end
