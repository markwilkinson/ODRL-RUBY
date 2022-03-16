# frozen_string_literal: true

require_relative "odrl/version"
# require "ODRL::Asset"
# require "ODRL::Constraint"

module ODRL
    class Rule
        attr_accessor :uid
        attr_accessor :assets

        def initialize(args)
            @uid = args[:uid]
            unless @uid
                @uid = $baseURI + "#rule_" + Base.getuuid
            end
            @assets = Hash.new
        end


        def addAsset(asset: args)
            raise "Asset is not an ODRL Asset" unless asset.is_a?(Asset)
            uid = asset.uid
            self.assets[uid] = ["target", asset] 
        end
    end


    class Permission  < Rule
        def initialize(args)
            super(args)


        end
    end

    class Duty  < Rule
        def initialize(args)
            super(args)


        end
    end

    class Prohibition < Rule
        def initialize(args)
            super(args)


        end
    end

end
