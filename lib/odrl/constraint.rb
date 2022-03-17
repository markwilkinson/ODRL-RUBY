# frozen_string_literal: true

module ODRL

    class Constraint


        
        attr_accessor :uid, :rigthOperand, :leftOperand, :operator, :rightOperandReference, :dataType, :unit, :status
        def initialize(args)
            @uid = args[:uid]
            unless @uid
                @uid = $baseURI + "#constraint_" + Base.getuuid
            end


        end
    end

end
