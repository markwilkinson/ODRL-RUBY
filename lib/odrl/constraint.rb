# frozen_string_literal: true

module ODRL
  class Constraint < Base
    attr_accessor :uid, :rightOperand, :leftOperand, :operator, :rightOperandReference, :dataType, :unit, :status

    def initialize(
      rightOperand:, operator:, leftOperand:, uid: nil,
      rightOPerandReference: nil,
      dataType: nil,
      unit: nil,
      status: nil,
      type: CCONSTRAINT,
      **args
    )

      @uid = uid
      @uid ||= Base.baseURI + "#constraint_" + Base.getuuid
      super(uid: @uid, type: type, **args)

      @rightOperand = rightOperand
      raise "Constraints must haves a Right operand such as 'event' - I'm dead!" unless @rightOperand

      # if it is already a URI, then let it go
      @rightOperand = "http://www.w3.org/ns/odrl/2/#{@rightOperand}" unless @rightOperand =~ %r{https?://}

      @leftOperand = leftOperand
      unless @leftOperand
        raise "Constraints must haves a Left Operand such as 'http://some.event.org/on-now' - I'm dead!"
      end

      # if it is already a URI, then let it go
      @leftOperand = "http://www.w3.org/ns/odrl/2/#{@leftOperand}" unless @leftOperand =~ %r{https?://}

      @operator = operator
      raise "Constraints must haves an operator such as 'eq' - I'm dead!" unless @operator

      # if it is already a URI, then let it go
      @operator = "http://www.w3.org/ns/odrl/2/#{@operator}" unless @operator =~ %r{https?://}

      @rightOperandReference = rightOperandReference
      @dataType = dataType
      @unit = unit
      @status = status
    end

    def load_graph
      super
      # TODO: This is bad DRY!!  Put the bulk of this method into the base object
      if rightOperand
        predicate = PRIGHT
        object = rightOperand
        subject = uid
        repo = repository
        triplify(subject, predicate, object, repo)
      end
      if leftOperand
        predicate = PLEFT
        object = leftOperand
        subject = uid
        repo = repository
        triplify(subject, predicate, object, repo)
      end
      if operator
        predicate = POPERATOR
        object = operator
        subject = uid
        repo = repository
        triplify(subject, predicate, object, repo)
      end
      if rightOperandReference
        predicate = POPERANDREFERENCE
        object = rightOperandReference
        subject = uid
        repo = repository
        triplify(subject, predicate, object, repo)
      end
      if dataType
        predicate = PDATATYPE
        object = dataType
        subject = uid
        repo = repository
        triplify(subject, predicate, object, repo)
      end
      if unit
        predicate = PUNIT
        object = unit
        subject = uid
        repo = repository
        triplify(subject, predicate, object, repo)
      end
      return unless status

      predicate = PSTATUS
      object = status
      subject = uid
      repo = repository
      triplify(subject, predicate, object, repo)
    end

    def serialize(format:)
      super
    end
  end
end
