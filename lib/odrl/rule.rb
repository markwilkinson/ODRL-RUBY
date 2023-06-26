# frozen_string_literal: true

require_relative "odrl/version"
# require "ODRL::Asset"
# require "ODRL::Constraint"

module ODRL
    class Rule
        attr_accessor :uid, :constraints, :assets, :predicate, :type
        def initialize(args)
            @uid = args[:uid]
            unless @uid
                @uid = $baseURI + "#rule_" + Base.getuuid
            end
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
