# frozen_string_literal: true

require_relative "odrl/version"
# require "ODRL::Asset"
# require "ODRL::Constraint"

module ODRL
    class Rule < Base
        attr_accessor :uid, :constraints, :assets, :predicate, :type, :actions
        def initialize(args)
            @uid = args[:uid]

            unless @uid
                @uid = Base.baseURI + "#rule_" + Base.getuuid
            end
            super(args.merge({uid: @uid}))
            
            @constraints = Hash.new
            @assets = Hash.new

            args[:assets] = [args[:assets]] unless args[:assets].is_a? Array
            if !(args[:assets].first.nil?)
                args[:assets].each do |c|
                    self.addAsset(asset: c)
                end
            end
            args[:constraints] = [args[:constraints]] unless args[:constraints].is_a? Array
            if !(args[:constraints].first.nil?)
                args[:constraints].each do |c|
                    self.addConstraint(constraint:  c)
                end
            end
        end


        def addAsset(asset: args)
            unless asset.is_a?(Asset)
                raise "Asset is not an ODRL Asset" 
            else
                uid = asset.uid
                self.assets[uid] = [PASSET, asset] 
            end
        end

        def addConstraint(constraint: args)
            unless constraint.is_a?(Constraint)
                raise "Constraint is not an ODRL Constraint" 
            else
                self.constraints[constraint.uid] = [PCONSTRAINT, constraint] 
            end
        end

        def addAction(action: args)
            unless action.is_a?(Action)
                raise "Action is not an ODRL Action" 
            else
                self.actions[action.uid] = [PACTION, action] 
            end
        end

        def load_graph
            super
            [:constraints, :assets, :actions].each do |connected_object_type|
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

        def serialize
            # :title, :author, :baseURI, :uid, :type from parent
            super()
        end
    end


    class Permission  < Rule
        def initialize(args)
            super(args)
            self.predicate = PPERMISSION
            self.type = CPERMISSION


        end
    end

    class Duty  < Rule
        def initialize(args)
            super(args)
            self.predicate = PDUTY
            self.type = CDUTY


        end
    end

    class Prohibition < Rule
        def initialize(args)
            super(args)
            self.predicate = PPROHIBITION
            self.type = CPROHIBITION


        end
    end

end
