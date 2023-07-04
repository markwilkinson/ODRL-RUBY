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

module ODRL
  module Profile
    class Builder
      attr_accessor :uri, :profile_class, :repository, :title, :description, :author 
      attr_accessor :asset_relations, :party_functional_roles, :actions, :leftOperands, :rightOperands, :operators

      # attr_accessor :logicalConstraints, :conflict_strategies, :rules
      def initialize(uri:, profile_class:, title:, description:, author:)
        @uri = uri
        @profile_class = profile_class
        @title = title
        @description = description
        @author = author
        @repository = RDF::Repository.new
        @asset_relations = []
        @party_functional_roles = []
        @actions = []
        @leftOperands = []
        @rightOperands = []
        @operators = []
        @asset_relations = []

        # Required declarations of disjointedness
        ODRL::Profile::Builder.triplify(@profile_class, RDFS.subClassOf, ODRLV.Policy, @repository)
        ODRL::Profile::Builder.triplify(@profile_class, OWL.disjointWith, ODRLV.Agreement, @repository)
        ODRL::Profile::Builder.triplify(@profile_class, OWL.disjointWith, ODRLV.Offer, @repository)
        ODRL::Profile::Builder.triplify(@profile_class, OWL.disjointWith, ODRLV.Privacy, @repository)
        ODRL::Profile::Builder.triplify(@profile_class, OWL.disjointWith, ODRLV.Request, @repository)
        ODRL::Profile::Builder.triplify(@profile_class, OWL.disjointWith, ODRLV.Ticket, @repository)
        ODRL::Profile::Builder.triplify(@profile_class, OWL.disjointWith, ODRLV.Assertion, @repository)
      end

      def build
        repo = repository # just shorter :-)
        title and ODRL::Profile::Builder.triplify(uri, DCT.title, title, repo)
        description and ODRL::Profile::Builder.triplify(uri, DCT.title, description, repo)
        author and ODRL::Profile::Builder.triplify(uri, DC.creator, author, repo)

        [asset_relations, party_functional_roles, actions, leftOperands, rightOperands, operators].flatten.each do |elem|
          elem.build(repo: repo)
        end
      end

      def serialize(format: :turtle)
        format = format.to_sym
        w = get_writer(type: format)
        w.dump(repository)
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
      attr_accessor :uri, :label, :definition

      def initialize(uri:, label:, definition:, **_args)
        @uri = uri
        @label = label
        @definition = definition
      end
    end

    class AssetRelation < ProfileElement
      # ex:myRelation rdfs:subPropertyOf odrl:relation .
      def build(repo:)
        ODRL::Profile::Builder.triplify(uri, RDFS.subPropertyOf, ODRLV.relation, repo)
        ODRL::Profile::Builder.triplify(uri, RDFS.label, label, repo)
        ODRL::Profile::Builder.triplify(uri, SKOS.defintion, definition, repo)
      end
    end

    class PartyFunction < ProfileElement
      # ex:myFunctionRole rdfs:subPropertyOf odrl:function
      def build(repo:)
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
