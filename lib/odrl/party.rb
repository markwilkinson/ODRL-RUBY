# frozen_string_literal: true

module ODRL
  class Party < Base
    attr_accessor :uid, :refinements, :partOf, :predicate, :type

    def initialize(
      uid: nil,
      refinements: nil,
      partOf: nil,
      predicate: nil,
      type: CPARTY,
      **args
    )

      @uid = uid
      @uid ||= Base.baseURI + "#party_" + Base.getuuid
      super(uid: @uid, type: type, **args)

      @refinements = {}
      @partOf = partOf
      @predicate = predicate

      if @predicate
        unless [PASSIGNER, PASSIGNEE].include? @predicate
          raise "You didn't indicate a valid predicate (assigner/assignee) so we will default to assigner.  This may not be what you want!"
          @predicate = PASSIGNER
        end
      else
        raise "If you don't indicate a predicate (assigner/assignee) we will default to assigner.  This may not be what you want!"
        @predicate = "http://www.w3.org/ns/odrl/2/assigner"
      end

      refinements = [refinements] unless refinements.is_a? Array
      unless refinements.first.nil?
        refinements.each do |c|
          addRefinement(refinement: c)
        end
      end

      return unless @partOf and !(@partOf.is_a? PartyCollection) # if it exists and is the wrong type

      raise "The parent collection of a Party must be of type ODRL::PaertyCollection.  The provided value will be discarded"
      @partOf = nil
    end

    def addRefinement(refinement: args)
      raise "Refinement is not an ODRL Constraint" unless refinement.is_a?(Constraint)

      refinements[refinement.uid] = [PREFINEMENT, refinement]
    end

    def addPart(part: args)
      raise "Party cannot be added as part of something that is not an PartyCollection" unless is_a?(PartyCollection)
      raise "Only Parties can be added as part of PartyCollections" unless part.is_a?(Asset)

      part.partOf[uid] = [PPARTOF, self]
    end

    def load_graph
      super
      # TODO: This is bad DRY!!  Put the bulk of this method into the base object
      %i[refinements partOf].each do |connected_object_type|
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
    end

    def serialize(format:)
      super
    end
  end

  class PartyCollection < Party
    def initialize(type: CPARTYCOLLECTION, **args)
      super(type: type, **args)
    end
  end
end
