require_relative "../lib/odrl/policy.rb"
require_relative "../lib/odrl/rule.rb"
require_relative "../lib/odrl/base.rb"
require_relative "../lib/odrl/asset.rb"
require_relative "../lib/odrl/constraint.rb"

describe ODRL::Rule do 
   context "When testing the Rule class" do 
      
      it "should init the right class" do 
         p = ODRL::Prohibition.new({})
         expect(p.class).to be (ODRL::Prohibition)
      end


      it "should init the right class" do 
         $baseURI = "http://example.org" unless $baseURI
         p = ODRL::Prohibition.new({})
         expect(p.uid).to match (/\#rule\_/)
      end


      it "should allow adding assets" do 
         $baseURI = "http://example.org" unless $baseURI
         r = ODRL::Prohibition.new({})
         a = ODRL::Asset.new({})
         r.addAsset(asset: a)
         expect(r.assets.length).to eq (1)
         expect(r.assets[r.assets.keys.first][1].class.to_s).to eq "ODRL::Asset"
      end

   end

end