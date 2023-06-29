# frozen_string_literal: true

require_relative "odrl/version"

module ODRL
  class Error < StandardError; end

  class Policy < Base
    attr_accessor :rules

    def initialize(uid: nil, type: CPOLICY, **args)
      @uid = uid
      self.uid = Base.baseURI + "#policy_" + Base.getuuid unless @uid
      super(uid: @uid, type: type, **args)

      @rules = {}
    end

    def addDuty(rule:)
      uid = rule.uid
      rules[uid] = [POBLIGATION, rule]
    end

    def addPermission(rule:)
      uid = rule.uid
      rules[uid] = [PPERMISSION, rule]
    end

    def addProhibition(rule:)
      uid = rule.uid
      rules[uid] = [PPROHIBITION, rule]
    end

    def load_graph
      super
      rules.each do |_uid, rulepair|
        predicate, ruleobject = rulepair # e.g. "permission", RuleObject
        object = ruleobject.uid
        subject = uid
        repo = repository
        triplify(subject, predicate, object, repo)
        ruleobject.load_graph # start the cascade
      end
    end

    def serialize(format:)
      super
    end
  end

  class Set < Policy
    def initialize(type: CSET, **args)
      super(type: type, **args)
    end
  end

  class Offer < Set
    def initialize(type: COFFER, **args)
      super(type: type, **args)
    end
  end

  class Agreement < Set
    def initialize(type: CAGREEMENT, **args)
      super(type: type, **args)
    end
  end

  class Request < Set
    def initialize(type: CREQUEST, **args)
      super(type: type, **args)
    end
  end

  class Privacy < Set
    def initialize(type: CPRIVACY, **args)
      super(type: type, **args)
    end
  end
  # ====================================================
end
