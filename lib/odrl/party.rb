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
      @partOf = {}
      @predicate = predicate.to_s

      if @predicate&.match(/https?:/)
        # do nothing! It's their choice to send a full predicate!
      elsif @predicate  # we're guessing it will be a string from the valid list?
        unless PARTYFUNCTIONS.include? @predicate
          raise "You didn't indicate a valid predicate"
          # @predicate = ODRLV.assigner
        else
          @predicate = "#{ODRLV.to_s}#{predicate}" # make the URI form of the valid predicate
        end
      elsif @predicate.nil?
        raise "If you don't indicate a predicate at all"
        # @predicate = ODRLV.assigner
      end

      refinements = [refinements] unless refinements.is_a? Array
      unless refinements.first.nil?
        refinements.each do |c|
          addRefinement(refinement: c)
        end
      end

      partOf = [partOf] unless partOf.is_a? Array
      unless partOf.first.nil?
        partOf.each do |p|
          p.addPart(part: self)
        end
      end

      unless @partOf and !(@partOf.is_a? PartyCollection) # if it exists and is the wrong type
        raise "The parent collection of a Party must be of type ODRL::PaertyCollection."
      end

    end

    def addRefinement(refinement: args)
      raise "Refinement is not an ODRL Constraint" unless refinement.is_a?(Constraint)

      refinements[refinement.uid] = [PREFINEMENT, refinement]
    end

    def addPart(part: args)
      raise "Party cannot be added as part of something that is not an PartyCollection" unless self.is_a?(PartyCollection)
      part.partOf[uid] = [PPARTOF, self]
    end

    def load_graph
      super
      # TODO: This is bad DRY!!  Put the bulk of this method into the base object
      # TODO:  Currently we don't support partOf
      %i[refinements].each do |connected_object_type|
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
