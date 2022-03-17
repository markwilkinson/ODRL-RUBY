# frozen_string_literal: true

require_relative "odrl/version"
require_relative "./base"
#require "ODRL::Asset"
# require "ODRL::Rule"
# require "ODRL::Constraint"

module ODRL
    class Error < StandardError; end


    class Policy  < Base
        attr_accessor :rules
        def initialize(args)
            super(args)
            @rules = Hash.new
            uid = Base.getuuid
            self.uid = self.baseURI + "#policy_" + uid.to_s


        end
        def addDuty(rule:)
            uid = rule.uid
            self.rules[uid] = ["obligation", rule] 
        end

        def addPermission(rule:)
            uid = rule.uid
            self.rules[uid] = ["permission", rule] 

        end

        def addProhibition(rule:)
            uid = rule.uid
            self.rules[uid] = ["prohibition", rule] 
        end
    end

    class Set  < Policy
        def initialize(args)
            super({type: "Set"}.merge(args))
        end

    end

    class Offer  < Set
        def initialize(args)
            super({type: "Offer"}.merge(args))


        end
    end
    class Agreement  < Set
        def initialize(args)
            super({type: "Agreement"}.merge(args))


        end
    end
# ====================================================


end
