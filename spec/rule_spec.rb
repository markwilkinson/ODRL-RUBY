require_relative "../lib/odrl/policy.rb"
require_relative "../lib/odrl/rule.rb"
require_relative "../lib/odrl/base.rb"
require_relative "../lib/odrl/asset.rb"
require_relative "../lib/odrl/constraint.rb"
require_relative "../lib/odrl/party.rb"
require_relative "../lib/odrl/action.rb"


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

      it "should allow adding constraints, either as a single, or as an array" do 
         $baseURI = "http://example.org" unless $baseURI
         c1 = ODRL::Constraint.new({})
         c2 = ODRL::Constraint.new({})
         d = ODRL::Duty.new({constraints: c1})
         expect(d.class.to_s).to eq "ODRL::Duty"
         d = ODRL::Duty.new(constraints: [c1])
         expect(d.class.to_s).to eq "ODRL::Duty"
         d = ODRL::Duty.new(constraints: [c1,c2])
         expect(d.constraints.keys.length).to eq 2
      end
      it "should allow adding constraints by method call" do 
         $baseURI = "http://example.org" unless $baseURI
         c1 = ODRL::Constraint.new({})
         d = ODRL::Duty.new({})
         d.addConstraint(constraint: c1)
         expect(d.constraints.keys.length).to eq 1
      end
      it "should allow adding assets by method call" do 
         $baseURI = "http://example.org" unless $baseURI
         c1 = ODRL::Asset.new({})
         d = ODRL::Duty.new({})
         d.addAsset(asset: c1)
         expect(d.assets.keys.length).to eq 1
      end

   end

end