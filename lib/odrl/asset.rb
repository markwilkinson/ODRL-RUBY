# frozen_string_literal: true

module ODRL
  # ODRL::Action
  # Describes an action like "use"
  #
  # @author Mark D Wilkinson
  class Asset < Base
    attr_accessor :uid, :hasPolicy, :refinements, :partOf

    def initialize(type: CASSET, hasPolicy: nil, refinements: nil, partOf: nil, **args)
      @uid = uid
      self.uid = Base.baseURI + "#asset_" + Base.getuuid unless @uid
      super(type: type, uid: @uid, **args)

      @partOf = partOf
      @hasPolicy = hasPolicy

      if @hasPolicy and !(@hasPolicy.is_a? Policy) # if it exists and is the wrong type
        raise "The policy of an Asset must be of type ODRL::Policy.  The provided value will be discarded"
        @hasPolicy = nil
      end
      if @partOf and !(@partOf.is_a? AssetCollection) # if it exists and is the wrong type
        raise "The parent collection of an Asset must be of type ODRL::AssetCollection.  The provided value will be discarded"
        @partOf = nil
      end

      @refinements = {}
      refinements = [refinements] unless refinements.is_a? Array
      return if refinements.first.nil?

      refinements.each do |c|
        addRefinement(refinement: c)
      end
    end

    def addPart(part: args)
      raise "Asset cannot be added as part of something that is not an asset collection" unless is_a?(AssetCollection)
      raise "Only Assets can be added as part of asset collections" unless part.is_a?(Asset)

      part.partOf[uid] = [PPARTOF, self]
    end

    def addRefinement(refinement: args)
      raise "Refinement is not an ODRL Constraint" unless refinement.is_a?(Constraint)

      refinements[refinement.uid] = [PREFINEMENT, refinement]
    end

    def load_graph
      super
      # TODO: This is bad DRY!!  Put the bulk of this method into the base object
      %i[refinements partOf hasPolicy].each do |connected_object_type|
        next unless send(connected_object_type)

        send(connected_object_type).each do |_uid, typedconnection|
          predicate, odrlobject = typedconnection # e.g. "refinement", RefinementObject
          object = odrlobject.uid
          subject = uid
          repo = repository
          triplify(subject, predicate, object, repo)
          odrlobject.load_graph  # start the cascade
        end
      end
    end

    def serialize(format:)
      super
    end
  end

  class AssetCollection < Asset
    def initialize(type: CASSETCOLLECTION, **args)
      super(type: type, **args)
    end
  end
end
