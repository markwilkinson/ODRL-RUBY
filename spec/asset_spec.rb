require_relative "../lib/odrl/policy.rb"
require_relative "../lib/odrl/rule.rb"
require_relative "../lib/odrl/base.rb"
require_relative "../lib/odrl/asset.rb"
require_relative "../lib/odrl/constraint.rb"
require_relative "../lib/odrl/party.rb"
require_relative "../lib/odrl/action.rb"

$baseURI = "http://example.org"

describe ODRL::Asset do 
   context "When testing the Asset class" do 
      
      it "should init the right class" do 
         $baseURI = "http://example.org" unless $baseURI
         p = ODRL::Asset.new({})
         expect(p.class).to be (ODRL::Asset)
         expect(p.uid).to match (/\#asset\_/)

      end

      it "an AssetCollection should init the right class and be an Asset also" do 
         $baseURI = "http://example.org" unless $baseURI
         p = ODRL::AssetCollection.new({})
         expect(p.class).to be (ODRL::AssetCollection)
         expect(p.uid).to match (/\#asset\_/)
         expect(p.is_a? ODRL::AssetCollection).to be (true)

      end

      it "an asset should allow to be part of an AssetCollection" do 
         $baseURI = "http://example.org" unless $baseURI
         ac = ODRL::AssetCollection.new({})
         a = ODRL::Asset.new({partOf: ac})
         expect(a.partOf.class).to be (ODRL::AssetCollection)
      end

      it "an asset should refuse to be part of a non AssetCollection" do 
         $baseURI = "http://example.org" unless $baseURI
         r = ODRL::Rule.new({})
         expect{ODRL::Asset.new({partOf: r})}.to raise_error(Exception)
      end

      it "an asset should allow to be governed by a policy" do 
         $baseURI = "http://example.org" unless $baseURI
         p = ODRL::Policy.new({})
         a = ODRL::Asset.new({hasPolicy: p})
         expect(a.hasPolicy.is_a? ODRL::Policy).to be (true)
      end

      it "an asset should refuse to be part of a non AssetCollection" do 
         $baseURI = "http://example.org" unless $baseURI
         r = ODRL::Rule.new({})
         expect{ODRL::Asset.new({hasPolicy: r})}.to raise_error(Exception)
      end


      it "should allow adding refinements, either as a single, or as an array" do 
         $baseURI = "http://example.org" unless $baseURI
         c1 = ODRL::Constraint.new({})
         c2 = ODRL::Constraint.new({})
         d = ODRL::Asset.new({refinements: c1})
         expect(d.class.to_s).to eq "ODRL::Asset"
         d = ODRL::Asset.new(refinements: [c1])
         expect(d.class.to_s).to eq "ODRL::Asset"
         d = ODRL::Asset.new(refinements: [c1,c2])
         expect(d.refinements.keys.length).to eq 2
      end


      it "should allow adding constraints by method call" do 
         $baseURI = "http://example.org" unless $baseURI
         c1 = ODRL::Constraint.new({})
         d = ODRL::Asset.new({})
         d.addRefinement(refinement: c1)
         expect(d.refinements.keys.length).to eq 1
      end

   end

end