# frozen_string_literal: true

module ODRL

    class Asset
        attr_accessor :uid
        attr_accessor :constraints

        def initialize(args)
            @uid = args[:uid]
            unless @uid
                @uid = $baseURI + "#asset_" + Base.getuuid
            end
            @constraints = Hash.new
        end
    end


end
