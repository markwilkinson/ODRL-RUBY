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
            @leftOperand = args[:leftOperand]
            @operator = args[:operator]
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
