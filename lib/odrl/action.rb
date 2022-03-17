# frozen_string_literal: true

module ODRL

    class Action
        attr_accessor :uid, :refinements, :predicate, :type
        def initialize(args)
            @uid = args[:uid]
            unless @uid
                @uid = $baseURI + "#action_" + Base.getuuid
            end
            @refinements = Hash.new

            args[:refinements] = [args[:refinements]] unless args[:refinements].is_a? Array
            if !(args[:refinements].first.nil?)
                args[:refinements].each do |c|
                    self.addRefinement(refinement:  c)
                end
            end

            self.predicate = "http://www.w3.org/ns/odrl/2/action" unless self.predicate

        end

        def addRefinement(refinement: args)
            unless refinement.is_a?(Constraint)
                raise "Refinement is not an ODRL Constraint" 
            else
                self.refinements[refinement.uid] = ["refinement", refinement] 
            end
        end
    end



    class Use < Action 
        def initialize(args)
            super(args)
            self.type = "http://www.w3.org/ns/odrl/2/action/use" unless self.type
        end
    end
    class Transfer < Action
        def initialize(args)
            super(args)
            self.type = "http://www.w3.org/ns/odrl/2/action/transfer" unless self.type
        end
    end

end
