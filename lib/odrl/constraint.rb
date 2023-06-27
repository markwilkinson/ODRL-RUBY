# frozen_string_literal: true

module ODRL

    class Constraint < Base
        
        attr_accessor :uid, :rightOperand, :leftOperand, :operator, :rightOperandReference, :dataType, :unit, :status
        def initialize(args)
            @uid = args[:uid]
            unless @uid
                @uid = Base.baseURI + "#constraint_" + Base.getuuid
            end
            super(args.merge({uid: @uid}))

            self.type = "http://www.w3.org/ns/odrl/2/Constraint"

            @rightOperand = args[:rightOperand]
            raise "Constraints must haves a Right operand such as 'event' - I'm dead!" unless @rightOperand
            @rightOperand = "http://www.w3.org/ns/odrl/2/#{@rightOperand}" unless @rightOperand =~ /http:\/\//  # if it is already a URI, then let it go

            @leftOperand = args[:leftOperand]
            raise "Constraints must haves a Left Operand such as 'http://some.event.org/on-now' - I'm dead!" unless @leftOperand
            @leftOperand = "http://www.w3.org/ns/odrl/2/#{@leftOperand}" unless @leftOperand =~ /http:\/\//  # if it is already a URI, then let it go

            @operator = args[:operator]
            raise "Constraints must haves an operator such as 'eq' - I'm dead!" unless @operator
            @operator = "http://www.w3.org/ns/odrl/2/#{@operator}" unless @operator =~ /http:\/\//  # if it is already a URI, then let it go

            @rightOperandReference = args[:rightOperandReference]
            @dataType = args[:dataType]
            @unit = args[:unit]
            @status = args[:status]
        end

        def load_graph
            super
            # TODO  This is bad DRY!!  Put the bulk of this method into the base object
            if self.rightOperand
                predicate = PRIGHT
                object = self.rightOperand
                subject = self.uid
                repo = self.repository
                triplify(subject, predicate, object, repo)
            end
            if self.leftOperand
                predicate = PRIGHT
                object = self.leftOperand
                subject = self.uid
                repo = self.repository
                triplify(subject, predicate, object, repo)
            end
            if self.operator
                predicate = POPERATOR
                object = self.operator
                subject = self.uid
                repo = self.repository
                triplify(subject, predicate, object, repo)
            end
            if self.rightOperandReference
                predicate = POPERANDREFERENCE
                object = self.rightOperandReference
                subject = self.uid
                repo = self.repository
                triplify(subject, predicate, object, repo)
            end
            if self.dataType
                predicate = PDATATYPE
                object = self.dataType
                subject = self.uid
                repo = self.repository
                triplify(subject, predicate, object, repo)
            end
            if self.unit
                predicate = PUNIT
                object = self.unit
                subject = self.uid
                repo = self.repository
                triplify(subject, predicate, object, repo)
            end
            if self.status
                predicate = PSTATUS
                object = self.status
                subject = self.uid
                repo = self.repository
                triplify(subject, predicate, object, repo)
            end
        end

        def serialize
            # :title, :author, :baseURI, :uid, :type from parent
            super()
        end

    end

end
