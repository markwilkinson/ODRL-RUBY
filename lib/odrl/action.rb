# frozen_string_literal: true

module ODRL

    class Action < Base
        attr_accessor :uid, :refinements, :predicate, :type
        def initialize(args)
            @uid = args[:uid]
            unless @uid
                self.uid = Base.baseURI + "#action_" + Base.getuuid
            end
            super(args.merge({uid: @uid}))

            self.type="http://www.w3.org/ns/odrl/2/Action"

            @refinements = Hash.new

            args[:refinements] = [args[:refinements]] unless args[:refinements].is_a? Array
            if !(args[:refinements].first.nil?)
                args[:refinements].each do |c|
                    self.addRefinement(refinement:  c)
                end
            end

            self.predicate = PACTION unless self.predicate

        end

        def addRefinement(refinement: args)
            unless refinement.is_a?(Constraint)
                raise "Refinement is not an ODRL Constraint" 
            else
                self.refinements[refinement.uid] = [PREFINEMENT, refinement] 
            end
        end


        def load_graph
            super
            # TODO  This is bad DRY!!  Put the bulk of this method into the base object
            [:refinements].each do |connected_object_type|
                next unless self.send(connected_object_type)
                self.send(connected_object_type).each do |uid, typedconnection|
                    predicate, odrlobject = typedconnection  # e.g. "refinement", RefinementObject
                    object = odrlobject.uid
                    subject = self.uid
                    repo = self.repository
                    triplify(subject, predicate, object, repo)
                    odrlobject.load_graph  # start the cascade
                end
            end
        end

        def serialize
            # :title, :author, :baseURI, :uid, :type from parent
            super()
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
