# frozen_string_literal: true

module ODRL

    class Constraint < Base
        
        attr_accessor :uid, :rightOperand, :leftOperand, :operator, :rightOperandReference, :dataType, :unit, :status
        def initialize(
            uid: nil,
            rightOperand:,
            operator:,
            leftOperand:,
            rightOPerandReference: nil, 
            dataType: nil,
            unit: nil,
            status: nil,
            type: CCONSTRAINT,
            **args)

            @uid = uid
            unless @uid
                @uid = Base.baseURI + "#constraint_" + Base.getuuid
            end
            super(uid: @uid, type: type, **args)

            @rightOperand = rightOperand
            raise "Constraints must haves a Right operand such as 'event' - I'm dead!" unless @rightOperand
            @rightOperand = "http://www.w3.org/ns/odrl/2/#{@rightOperand}" unless @rightOperand =~ /https?:\/\//  # if it is already a URI, then let it go

            @leftOperand = leftOperand
            raise "Constraints must haves a Left Operand such as 'http://some.event.org/on-now' - I'm dead!" unless @leftOperand
            @leftOperand = "http://www.w3.org/ns/odrl/2/#{@leftOperand}" unless @leftOperand =~ /https?:\/\//  # if it is already a URI, then let it go

            @operator = operator
            raise "Constraints must haves an operator such as 'eq' - I'm dead!" unless @operator
            @operator = "http://www.w3.org/ns/odrl/2/#{@operator}" unless @operator =~ /https?:\/\//  # if it is already a URI, then let it go

            @rightOperandReference = rightOperandReference
            @dataType = dataType
            @unit = unit
            @status = status
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
                predicate = PLEFT
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

        def serialize(format:)
            super
        end

    end

end
