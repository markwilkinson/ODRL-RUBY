# frozen_string_literal: true

module ODRL
  # ODRL::Action
  # Describes an action like "use"
  #
  # @author Mark D Wilkinson
  # @attr [URI] (optional) uid the URI of the Action node
  # @attr [[ODRL::Refinement]] (optional) ODRL Refinement objects
  # @attr [URI] predicate (optional) the predicate you wish to use with this action
  # @attr [string] value (required) a string like "use"
  # @attr [string] vallabel (optional) a string like "use"
  class Action < Base
    attr_accessor :uid, :refinements, :predicate, :type, :value, :vallabel

    # constructor
    # @param  [Hash] opts  the options to create a message with.
    # @option opts [String] :value   the string value of rthe action, like "use"
    # @option opts [String] :vallabel    the string for the label, like "use"
    #
    def initialize(value:, vallabel: "", type: CACTION, **args)
      @value = value
      @vallabel = vallabel || @value
      raise "Actions must haves a value such as 'use' - I'm dead!" unless @value

      # if it is already a URI, then let it go
      @value = "http://www.w3.org/ns/odrl/2/#{@value}" unless @value =~ %r{http://}

      @uid = @value
      # unless @uid
      #     self.uid = Base.baseURI + "#action_" + Base.getuuid
      # end
      super(uid: @uid, type: type, **args)

      @refinements = {}

      args[:refinements] = [args[:refinements]] unless args[:refinements].is_a? Array
      unless args[:refinements].first.nil?
        args[:refinements].each do |c|
          addRefinement(refinement: c)
        end
      end

      self.predicate = PACTION unless predicate
    end

    # Adds an ODRL Refinement
    #
    # @param refinement [ODRL::Refinement]  the refinement to the action
    #
    def addRefinement(refinement: args)
      raise "Refinement is not an ODRL Constraint" unless refinement.is_a?(Constraint)

      refinements[refinement.uid] = [PREFINEMENT, refinement]
    end

    # Causes the triples of this object to be formed in the in-memory store
    # This includes any "cascading" objects for which this is the subject of the triple
    #
    def load_graph
      super
      # TODO: This is bad DRY!!  Put the bulk of this method into the base object
      [:refinements].each do |connected_object_type|
        next unless send(connected_object_type)

        send(connected_object_type).each do |_uid, typedconnection|
          predicate, odrlobject = typedconnection # e.g. "refinement", RefinementObject
          object = odrlobject.uid
          subject = uid
          repo = repository
          triplify(subject, predicate, object, repo)
          odrlobject.load_graph # start the cascade
        end
      end
      subject = uid
      object = vallabel
      predicate = SCHEMA.name
      repo = repository
      triplify(subject, predicate, object, repo)
      object = vallabel
      predicate = RDFS.label
      repo = repository
      triplify(subject, predicate, object, repo)
    end

    # Returns the serialized RDF for this object and cascading related objects
    #
    # @param format [Symbol] a valid RDF::Writer format (e.g. :turtle)
    #
    def serialize(format:)
      super
    end
  end

  class Use < Action
    def initialize(type: CACTION, **args)
      super(type: :type, **args)
    end
  end

  class Transfer < Action
    def initialize(type: CACTION, **args)
      super(type: :type, **args)
    end
  end
end
