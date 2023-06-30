# frozen_string_literal: true

require_relative "odrl/version"
require "linkeddata"

CPOLICY = ODRLV.Policy.to_s

PPROFILE = ODRLV.profile.to_s

CSET = ODRLV.Set.to_s
COFFER = ODRLV.Offer.to_s
CREQUEST = ODRLV.Request.to_s
CAGREEMENT = ODRLV.Agreement.to_s
CPRIVACY = ODRLV.Privacy.to_s
PASSET = ODRLV.target.to_s
CASSET = ODRLV.Asset.to_s
CASSETCOLLECTION = ODRLV.Asset.to_s

CRULE = ODRLV.Rule.to_s
CPERMISSION = ODRLV.Permission.to_s
PPERMISSION = ODRLV.permission.to_s
CPROHIBITION = ODRLV.Prohibition.to_s
PPROHIBITION = ODRLV.prohibition.to_s
PDUTY = ODRLV.obligation.to_s
CDUTY = ODRLV.Duty.to_s

PRULE = ODRLV.Rule.to_s

PACTION = ODRLV.action.to_s
VUSE = ODRLV.use.to_s # this is goofy ODRL stuff...
VTRANSFER = ODRLV.transfer.to_s # this is goofy ODRL stuff...
CACTION = ODRLV.Action.to_s

PREFINEMENT = ODRLV.refinement.to_s

PASSIGNER = ODRLV.assigner.to_s # now in PARTYFUNCTIONS
PASSIGNEE = ODRLV.assignee.to_s
CPARTY = ODRLV.Party.to_s
CPARTYCOLLECTION = ODRLV.Party.to_s

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
  issued: DCT.issued
}

OPERATORS =  %w[eq gt gteq hasPart isA isAllOf isAnyOf isNoneOf isPartOf lt lteq neq]
LEFTOPERANDS = %w[absolutePosition absoluteSize absoluteSpatialPosition absoluteTemporalPosition
                  count dateTime delayPeriod deliveryChannel device elapsedTime event
                  fileFormat industry language media meteredTime payAmount percentage
                  product purpose recipient relativePosition relativeSize relativeSpatialPosition
                  relativeTemporalPosition resolution spatial spatialCoordinates system
                  systemDevice timeInterval unitOfCount version virtualLocation]

PARTYFUNCTIONS = %w[assignee assigner attributedParty attributingParty compensatedParty
                    compensatingParty consentedParty consentingParty contractedParty contractingParty informedParty
                    informingParty trackedParty trackingParty]

# INTERESTING>>>> THIS COULD BE USED IF THERE IS A PROFILE...
# module RemovableConstants
#         def def_if_not_defined(const, value)
#           self.class.const_set(const, value) unless self.class.const_defined?(const)
#         end

#         def redef_without_warning(const, value)
#           self.class.send(:remove_const, const) if self.class.const_defined?(const)
#           self.class.const_set(const, value)
#         end
# end

module ODRL
  class Base
    @@repository = RDF::Repository.new

    # If you add an attribute, you mustr also add it to the constructor,
    # and to the @attribute list
    # andn to the .load_graph
    attr_accessor :title, :creator, :description, :subject, :baseURI, :uid, :id, :type, :label, :issued

    def self.baseURI
      ENV["ODRL_BASEURI"] || "http://example.org"
    end

    def self.repository
      @@repository
    end

    def repository
      @@repository
    end

    def self.clear_repository
      @@repository.clear!
      true
    end

    def initialize(
      uid:, type:, title: nil,
      creator: nil,
      description: nil,
      issued: nil,
      subject: nil,
      baseURI: "http://example.org",
      id: nil,
      label: nil,
      **_
    )

      @title = title
      @creator = creator
      @issued = issued
      @description = description
      @subject = subject
      @baseURI = baseURI || ODRL::Base.baseURI
      @uid = uid
      @type = type
      @label = label || @title
      @id = @uid

      raise "Every object must have a uid - attempt to create #{@type}" unless @uid
      raise "Every object must have a type - " unless @type

      $g = RDF::Graph.new
      $format = if ENV["TRIPLES_FORMAT"]
                  ENV["TRIPLES_FORMAT"].to_sym
                else
                  :jsonld
                end
    end

    def get_writer(type:)
      RDF::Writer.for(type)
      # w.prefix(:foaf, RDF::URI.new("http://xmlns.com/foaf/0.1/"))
      # w.prefix(:dc, RDF::URI.new("http://purl.org/dc/terms/"))
      # w.prefix(:rdf, RDF::URI.new("http://www.w3.org/1999/02/22-rdf-syntax-ns#"))
      # w.prefix(:rdfs, RDF::URI.new("http://www.w3.org/2000/01/rdf-schema#"))
      # w.prefix(:vcard, RDF::URI.new("http://www.w3.org/2006/vcard/ns#"))
      # w.prefix(:odrl, RDF::URI.new("http://www.w3.org/ns/odrl/2/"))
      # w.prefix(:this, RDF::URI.new("http://w3id.org/FAIR_Training_LDP/DAV/home/LDP/DUC-CCE/IPGB#"))
      # w.prefix(:obo, RDF::URI.new("http://purl.obolibrary.org/obo/"))
      # w.prefix(:xsd, RDF::URI.new("http://www.w3.org/2001/XMLSchema#"))
      # w.prefix(:orcid, RDF::URI.new("https://orcid.org/"))
      # warn "W"
      # warn w.prefixes.inspect
    end

    def triplify(s, p, o, repo)
      s = s.strip if s.instance_of?(String)
      p = p.strip if p.instance_of?(String)
      o = o.strip if o.instance_of?(String)

      unless s.respond_to?("uri")

        raise "Subject #{s} must be a URI-compatible thingy #{s}, #{p}, #{o}" unless s.to_s =~ %r{^\w+:/?/?[^\s]+}

        s = RDF::URI.new(s.to_s)

      end

      unless p.respond_to?("uri")

        raise "Predicate #{p} must be a URI-compatible thingy #{s}, #{p}, #{o}" unless p.to_s =~ %r{^\w+:/?/?[^\s]+}

        p = RDF::URI.new(p.to_s)

      end
      unless o.respond_to?("uri")
        o = if o.to_s =~ %r{^\w+:/?/?[^\s]+}
              RDF::URI.new(o.to_s)
            elsif o.to_s =~ /^\d{4}-[01]\d-[0-3]\dT[0-2]\d:[0-5]\d/
              RDF::Literal.new(o.to_s, datatype: RDF::XSD.date)
            elsif o.to_s =~ /^\d\.\d/
              RDF::Literal.new(o.to_s, datatype: RDF::XSD.float)
            elsif o.to_s =~ /^[0-9]+$/
              RDF::Literal.new(o.to_s, datatype: RDF::XSD.int)
            else
              RDF::Literal.new(o.to_s, language: :en)
            end
      end

      triple = RDF::Statement(s, p, o)
      repo.insert(triple)

      true
    end

    def self.getuuid
      Time.now.to_f.to_s.gsub(".", "")[1..14]
    end

    def load_graph
      %i[title label issued creator description subject uid id type].each do |method|
        next unless send(method)
        next if send(method).empty?

        subject = uid # me!
        predicate = PROPERTIES[method] # look up the predicate for this property
        # warn "prediate #{predicate} for method #{method}"
        object = send(method) # get the value of this property from self
        # warn "value #{object.to_s}"
        repo = repository
        triplify(subject, predicate, object, repo)
      end
    end

    def serialize(format: $format)
      format = format.to_sym
      w = get_writer(type: format)
      w.dump(repository)
    end
  end
end
