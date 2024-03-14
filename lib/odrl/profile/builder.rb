require "linkeddata"

RDFS = RDF::Vocabulary.new("http://www.w3.org/2000/01/rdf-schema#")
DCAT = RDF::Vocabulary.new("http://www.w3.org/ns/dcat#")
DC = RDF::Vocabulary.new("http://purl.org/dc/elements/1.1/")
DCT = RDF::Vocabulary.new("http://purl.org/dc/terms/")
FUND = RDF::Vocabulary.new("http://vocab.ox.ac.uk/projectfunding#")
SKOS = RDF::Vocabulary.new("http://www.w3.org/2004/02/skos/core#")
ODRLV = RDF::Vocabulary.new("http://www.w3.org/ns/odrl/2/")
OBO = RDF::Vocabulary.new("http://purl.obolibrary.org/obo/")
XSD = RDF::Vocabulary.new("http://www.w3.org/2001/XMLSchema#")
SCHEMA = RDF::Vocabulary.new("https://schema.org/")
OWL = RDF::Vocabulary.new("http://www.w3.org/2002/07/owl#")
PROFILE = RDF::Vocabulary.new("http://www.w3.org/ns/dx/prof/")

module ODRL
  module Profile
    class Builder
      attr_accessor :uri, :repository, :title, :description, :authors, :version, :license, :prefix, :separator, :fullURI
      attr_accessor :prefixes, :policies, :asset_relations, :party_functional_roles, :actions, :leftOperands, :rightOperands, :operators, :skosMembers

      # attr_accessor :logicalConstraints, :conflict_strategies, :rules
      def initialize(uri:, title:, description:, authors:, version:, license:, prefix: "ex", separator: "#")
        @uri = uri
        @title = title
        @description = description
        @authors = authors
        @version = version
        @license = license
        @prefix = prefix
        @separator = separator
        @repository = RDF::Repository.new
        @prefixes = {}
        @policies = []
        @asset_relations = []
        @party_functional_roles = []
        @actions = []
        @leftOperands = []
        @rightOperands = []
        @operators = []
        @skosMembers = []

        @fullURI = @uri + @separator

        @prefixes.store(@prefix, @fullURI)

        ODRL::Profile::Builder.triplify(@uri, RDF.type, OWL.Ontology, @repository)
        ODRL::Profile::Builder.triplify(@uri, RDF.type, PROFILE.Profile, @repository)
        ODRL::Profile::Builder.triplify(@uri, RDFS.label, @title, @repository)
        ODRL::Profile::Builder.triplify(@uri, OWL.versionInfo, @version, @repository)
        ODRL::Profile::Builder.triplify(@uri, DCT.title, title, @repository)
        ODRL::Profile::Builder.triplify(@uri, DCT.description, description, @repository)
        ODRL::Profile::Builder.triplify(@uri, DCT.license, license, @repository)

        @authors.each do |author|
          ODRL::Profile::Builder.triplify(@uri, DCT.creator, author, @repository)
        end

        # SKOS
        ODRL::Profile::Builder.triplify(@fullURI, RDF.type, SKOS.Collection, @repository)
        ODRL::Profile::Builder.triplify(@fullURI, SKOS.prefLabel, "Profile Vocabulary", @repository)
      end

      def build
        repo = repository # just shorter :-)

        [policies, asset_relations, party_functional_roles, actions, leftOperands, rightOperands, operators].flatten.each do |elem|
          ODRL::Profile::Builder.triplify(elem.uri, RDFS.isDefinedBy, @fullURI, repo)
          elem.parent_property and ODRL::Profile::Builder.triplify(elem.uri, RDFS.subPropertyOf, elem.parent_property, repo)
          elem.parent_class and ODRL::Profile::Builder.triplify(elem.uri, RDFS.subClassOf, elem.parent_class, repo)

          elem.build(repo: repo)

          @skosMembers << elem.uri
        end
      end

      def build_skos(uri, members, label, repo)
        ODRL::Profile::Builder.triplify(uri, RDF.type, SKOS.Collection, repo)
        ODRL::Profile::Builder.triplify(uri, SKOS.prefLabel, label, repo)

        members.each do |member|
          ODRL::Profile::Builder.triplify(uri, SKOS.member, member.uri, repo)
        end
      end

      def serialize(format: :turtle)
        format = format.to_sym

        ## All profile SKOS members
        @skosMembers.each do |member|
          ODRL::Profile::Builder.triplify(@fullURI, SKOS.member, member, @repository)
        end

        ## Specific profile SKOS members
        build_skos(@fullURI + "policies", @actions, "Policies", @repository)
        build_skos(@fullURI + "actions", @actions, "Actions for Rules", @repository)
        build_skos(@fullURI + "asset_relations", @asset_relations, "Asset Relations", @repository)
        build_skos(@fullURI + "partyFunctions", @party_functional_roles, "Party Functions", @repository)
        build_skos(@fullURI + "constraintLeftOperand", @leftOperands, "Left Operands", @repository)
        build_skos(@fullURI + "constraintRightOperand", @rightOperands, "Right Operands", @repository)
        build_skos(@fullURI + "operators", @operators, "Operators", @repository)

        w = get_writer(type: format)
        w.dump(repository, nil, prefixes: @prefixes)
      end

      def get_writer(type: :turtle)
        RDF::Writer.for(type)
      end

      def self.triplify(s, p, o, repo)
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
    end # end of Class Builder

    class ProfileElement
      attr_accessor :uri, :label, :definition, :parent_class, :parent_property

      # parent_class => subClassOf
      # parent_property => subPropertyOf
      def initialize(uri:, label:, definition:, parent_class: nil, parent_property: nil, **_args)
        @uri = uri
        @label = label
        @definition = definition
        @parent_class = parent_class
        @parent_property = parent_property
      end
    end

    class Policy < ProfileElement
      attr_accessor :disjoints

      def initialize(disjoints: [], **args)
        # Additional disjoints can added for custom policies
        @disjoints = [
          ODRLV.Agreement,
          ODRLV.Offer,
          ODRLV.Privacy,
          ODRLV.Request,
          ODRLV.Ticket,
          ODRLV.Assertion
        ].concat(disjoints)

        super(**args)
      end

      # ex:myPolicy a odrl:Policy .
      def build(repo:)
        ODRL::Profile::Builder.triplify(uri, RDF.type, RDFS.Class, repo)
        ODRL::Profile::Builder.triplify(uri, RDF.type, OWL.Class, repo)
        ODRL::Profile::Builder.triplify(uri, RDF.type, SKOS.Concept, repo)
        ODRL::Profile::Builder.triplify(uri, RDFS.label, label, repo)
        ODRL::Profile::Builder.triplify(uri, SKOS.defintion, definition, repo)

        # Required declarations of disjointedness
        ODRL::Profile::Builder.triplify(uri, RDFS.subClassOf, ODRLV.Policy, repo)

        disjoints.each do |disjoint|
          ODRL::Profile::Builder.triplify(uri, OWL.disjointWith, disjoint, repo)
        end
      end
    end

    class AssetRelation < ProfileElement
      # ex:myRelation rdfs:subPropertyOf odrl:relation .
      def build(repo:)
        ODRL::Profile::Builder.triplify(uri, RDF.type, RDF.Property, repo)
        ODRL::Profile::Builder.triplify(uri, RDF.type, OWL.ObjectProperty, repo)
        ODRL::Profile::Builder.triplify(uri, RDF.type, SKOS.Concept, repo)
        ODRL::Profile::Builder.triplify(uri, RDFS.subPropertyOf, ODRLV.relation, repo)
        ODRL::Profile::Builder.triplify(uri, RDFS.label, label, repo)
        ODRL::Profile::Builder.triplify(uri, SKOS.defintion, definition, repo)
        ODRL::Profile::Builder.triplify(uri, RDFS.domain, ODRLV.Rule, repo)
        ODRL::Profile::Builder.triplify(uri, RDFS.range, ODRLV.Asset, repo)
      end
    end

    class PartyFunction < ProfileElement
      # ex:myFunctionRole rdfs:subPropertyOf odrl:function
      def build(repo:)
        ODRL::Profile::Builder.triplify(uri, RDF.type, RDF.Property, repo)
        ODRL::Profile::Builder.triplify(uri, RDF.type, OWL.ObjectProperty, repo)
        ODRL::Profile::Builder.triplify(uri, RDF.type, SKOS.Concept, repo)
        ODRL::Profile::Builder.triplify(uri, RDFS.subPropertyOf, ODRLV.function, repo)
        ODRL::Profile::Builder.triplify(uri, RDFS.label, label, repo)
        ODRL::Profile::Builder.triplify(uri, SKOS.defintion, definition, repo)
      end
    end

    class Action < ProfileElement
      # ex:myAction a odrl:Action .
      # ex:myAction odrl:includedIn odrl:use .
      # ex:myAction odrl:implies odrl:distribute .
      attr_accessor :implies, :included_in

      def initialize(implies: nil, included_in: ODRLV.use, **args)
        @implies = implies
        @included_in = included_in
        super(**args)
      end

      def build(repo:)
        ODRL::Profile::Builder.triplify(uri, RDF.type, ODRLV.Action, repo)
        ODRL::Profile::Builder.triplify(uri, RDF.type, SKOS.Concept, repo)
        ODRL::Profile::Builder.triplify(uri, RDFS.label, label, repo)
        ODRL::Profile::Builder.triplify(uri, SKOS.defintion, definition, repo)
        ODRL::Profile::Builder.triplify(uri, ODRLV.includedIn, included_in, repo)
        return unless implies
        ODRL::Profile::Builder.triplify(uri, ODRLV.implies, implies, repo)
      end
    end

    class LeftOperand < ProfileElement
      # ex:myLeftOperand a odrl:LeftOperand .
      def build(repo:)
        ODRL::Profile::Builder.triplify(uri, RDF.type, ODRLV.LeftOperand, repo)
        ODRL::Profile::Builder.triplify(uri, RDF.type, OWL.NamedIndividual, repo)
        ODRL::Profile::Builder.triplify(uri, RDF.type, SKOS.Concept, repo)
        ODRL::Profile::Builder.triplify(uri, RDFS.label, label, repo)
        ODRL::Profile::Builder.triplify(uri, SKOS.defintion, definition, repo)
      end
    end

    class RightOperand < ProfileElement
      # ex:myRightOperand a odrl:RightOperand .
      def build(repo:)
        ODRL::Profile::Builder.triplify(uri, RDF.type, ODRLV.RightOperand, repo)
        ODRL::Profile::Builder.triplify(uri, RDFS.label, label, repo)
        ODRL::Profile::Builder.triplify(uri, SKOS.defintion, definition, repo)
      end
    end

    class Operator < ProfileElement
      # ex:myOperator a odrl:Operator .
      def build(repo:)
        ODRL::Profile::Builder.triplify(uri, RDF.type, ODRLV.Operator, repo)
        ODRL::Profile::Builder.triplify(uri, RDFS.label, label, repo)
        ODRL::Profile::Builder.triplify(uri, SKOS.defintion, definition, repo)
      end
    end
  end
end
