# frozen_string_literal: true

module ODRL

    class Asset
        attr_accessor :uid, :hasPolicy, :refinements, :partOf

        def initialize(args)
            @uid = args[:uid]
            unless @uid
                @uid = $baseURI + "#asset_" + Base.getuuid
            end
            @refinements = Hash.new
            @partOf = args[:partOf]
            @hasPolicy = args[:hasPolicy]

            if @hasPolicy and !(@hasPolicy.is_a? Policy) # if it exists and is the wrong type
                raise "The policy of an Asset must be of type ODRL::Policy.  The provided value will be discarded" 
                @hasPolicy = nil
            end
            if @partOf and !(@partOf.is_a? AssetCollection) # if it exists and is the wrong type
                raise "The parent collection of an Asset must be of type ODRL::AssetCollection.  The provided value will be discarded" 
                @partOf = nil
            end

            args[:refinements] = [args[:refinements]] unless args[:refinements].is_a? Array
            if !(args[:refinements].first.nil?)
                args[:refinements].each do |c|
                    self.addRefinement(refinement:  c)
                end
            end
        end

        def addRefinement(refinement: args)
            unless refinement.is_a?(Constraint)
                raise "Refinement is not an ODRL Constraint" 
            else
                self.refinements[refinement.uid] = [PREFINEMENT, refinement] 
            end
        end
    end

    class AssetCollection < Asset

        def initialize(args)
            super(args)
        end
    end


end
