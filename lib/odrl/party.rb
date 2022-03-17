# frozen_string_literal: true

module ODRL

    class Party
        attr_accessor :uid, :refinements, :partOf, :predicate, :type
        def initialize(args)
            @uid = args[:uid]
            @refinements = Hash.new
            @partOf = args[:partOf]
            @predicate = args[:predicate]
            @type = "http://www.w3.org/ns/odrl/2/Party"

            unless @predicate
                raise "If you don't indicate a predicate (assigner/assignee) we will default to assigner.  This may not be what you want!"
                @predicate = "http://www.w3.org/ns/odrl/2/assigner"
            else
                if @predicate == "assigner"
                    @predicate = "http://www.w3.org/ns/odrl/2/assigner"
                elsif @predicate == "assignee"
                    @predicate = "http://www.w3.org/ns/odrl/2/assignee"
                else
                    raise "You didn't indicate a valid predicate (assigner/assignee) so we will default to assigner.  This may not be what you want!"
                    @predicate = "http://www.w3.org/ns/odrl/2/assigner"
                end
            end

            unless @uid
                @uid = $baseURI + "#party_" + Base.getuuid
            end

            args[:refinements] = [args[:refinements]] unless args[:refinements].is_a? Array
            if !(args[:refinements].first.nil?)
                args[:refinements].each do |c|
                    self.addRefinement(refinement:  c)
                end
            end

            if @partOf and !(@partOf.is_a? PartyCollection) # if it exists and is the wrong type
                raise "The parent collection of a Party must be of type ODRL::PaertyCollection.  The provided value will be discarded" 
                @partOf = nil
            end

        end

        def addRefinement(refinement: args)
            unless refinement.is_a?(Constraint)
                raise "Refinement is not an ODRL Constraint" 
            else
                self.refinements[refinement.uid] = ["refinement", refinement] 
            end
        end
    end
    class PartyCollection < Party

        def initialize(args)
            super(args)
            self.type = "http://www.w3.org/ns/odrl/2/PartyCollection"
        end
    end


end
