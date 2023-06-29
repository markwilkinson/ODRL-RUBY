# frozen_string_literal: true

require_relative "odrl/version"
# require "ODRL::Asset"
# require "ODRL::Constraint"

module ODRL
  class Rule < Base
    attr_accessor :uid, :constraints, :assets, :predicate, :type, :action, :assigner, :assignee

    def initialize(
      uid: nil,
      constraints: nil,
      assets: nil,
      predicate: nil,
      action: nil,
      assigner: nil,
      assignee: nil,
      type: CRULE,
      **args
    )
      @uid = uid

      @uid ||= Base.baseURI + "#rule_" + Base.getuuid
      super(uid: @uid, type: type, **args)

      @constraints = {}
      @assets = {}
      @assigner = {}
      @assignee = {}
      @action = {}

      assets = [assets] unless assets.is_a? Array
      unless assets.first.nil?
        assets.each do |c|
          addAsset(asset: c)
        end
      end
      constraints = [constraints] unless constraints.is_a? Array
      return if constraints.first.nil?

      constraints.each do |c|
        addConstraint(constraint: c)
      end
    end

    def addAsset(asset:)
      raise "Asset is not an ODRL Asset" unless asset.is_a?(Asset)

      uid = asset.uid
      assets[uid] = [PASSET, asset]
    end

    def addConstraint(constraint:)
      raise "Constraint is not an ODRL Constraint" unless constraint.is_a?(Constraint)

      constraints[constraint.uid] = [PCONSTRAINT, constraint]
    end

    def addAction(action:)
      raise "Action is not an ODRL Action" unless action.is_a?(Action)

      self.action[action.uid] = [PACTION, action]
    end

    def addAssigner(party:)
      raise "Assigner is not an ODRL Party" unless party.is_a?(Party)

      assigner[party.uid] = [PASSIGNER, party]
    end

    def addAssignee(party:)
      raise "Asigner is not an ODRL Party" unless party.is_a?(Party)

      assignee[party.uid] = [PASSIGNEE, party]
    end

    def load_graph
      super
      %i[constraints assets action assigner assignee].each do |connected_object_type|
        next unless send(connected_object_type)

        send(connected_object_type).each do |_uid, typedconnection|
          predicate, odrlobject = typedconnection # e.g. "action", ActionObject
          object = odrlobject.uid
          subject = uid
          repo = repository
          triplify(subject, predicate, object, repo)
          odrlobject.load_graph  # start the cascade
        end
      end
    end

    def serialize(format:)
      super
    end
  end

  class Permission < Rule
    def initialize(predicate: PPERMISSION, type: CPERMISSION, **args)
      super(predicate: predicate, type: type, **args)
    end
  end

  class Duty < Rule
    def initialize(predicate: PDUTY, type: CDUTY, **args)
      super(predicate: predicate, type: type, **args)
    end
  end

  class Prohibition < Rule
    def initialize(predicate: PPROHIBITION, type: CPROHIBITION, **args)
      super(predicate: predicate, type: type, **args)
    end
  end
end
