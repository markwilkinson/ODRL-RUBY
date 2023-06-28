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
            **args)
            @uid = uid

            unless @uid
                @uid = Base.baseURI + "#rule_" + Base.getuuid
            end
            super(uid: @uid, type: type, **args)
            
            @constraints = Hash.new
            @assets = Hash.new
            @assigner = Hash.new
            @assignee = Hash.new
            @action = Hash.new

            assets = [assets] unless assets.is_a? Array
            if !assets.first.nil?
                assets.each do |c|
                    self.addAsset(asset: c)
                end
            end
            constraints = [constraints] unless constraints.is_a? Array
            if !constraints.first.nil?
                constraints.each do |c|
                    self.addConstraint(constraint:  c)
                end
            end
        end


        def addAsset(asset:)
            unless asset.is_a?(Asset)
                raise "Asset is not an ODRL Asset" 
            else
                uid = asset.uid
                self.assets[uid] = [PASSET, asset] 
            end
        end

        def addConstraint(constraint:)
            unless constraint.is_a?(Constraint)
                raise "Constraint is not an ODRL Constraint" 
            else
                self.constraints[constraint.uid] = [PCONSTRAINT, constraint] 
            end
        end

        def addAction(action:)
            unless action.is_a?(Action)
                raise "Action is not an ODRL Action" 
            else
                self.action[action.uid] = [PACTION, action] 
            end
        end

        def addAssigner(party:)
            unless party.is_a?(Party)
                raise "Assigner is not an ODRL Party" 
            else
                self.assigner[party.uid] = [PASSIGNER, party] 
            end
        end

        def addAssignee(party:)
            unless party.is_a?(Party)
                raise "Asigner is not an ODRL Party" 
            else
                self.assignee[party.uid] = [PASSIGNEE, party] 
            end
        end

        def load_graph
            super
            [:constraints, :assets, :action, :assigner, :assignee].each do |connected_object_type|
                next unless self.send(connected_object_type)
                self.send(connected_object_type).each do |uid, typedconnection|
                    predicate, odrlobject = typedconnection  # e.g. "action", ActionObject
                    object = odrlobject.uid
                    subject = self.uid
                    repo = self.repository
                    triplify(subject, predicate, object, repo)
                    odrlobject.load_graph  # start the cascade
                end
            end
        end

        def serialize(format:)
            super
        end
    end


    class Permission  < Rule
        def initialize(predicate: PPERMISSION, type: CPERMISSION, **args)
            super(predicate: predicate, type: type, **args)
        end
    end

    class Duty  < Rule
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
