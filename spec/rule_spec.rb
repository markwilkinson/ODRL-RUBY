
require_relative "./spec_helper.rb"



$baseURI = "http://example.org/"
describe ODRL::Rule do 
   context "When testing the Rule class" do 
      
      it "should init the right class" do 
         p = ODRL::Prohibition.new({})
         expect(p.class).to be (ODRL::Prohibition)
      end


      it "should init the right class" do 
         p = ODRL::Prohibition.new({})
         expect(p.uid).to match (/\#rule\_\d+/)
      end


      it "should allow adding assets" do 
         r = ODRL::Prohibition.new({})
         a = ODRL::Asset.new({})
         r.addAsset(asset: a)
         expect(r.assets.length).to eq (1)
         expect(r.assets[r.assets.keys.first][1].class.to_s).to eq "ODRL::Asset"
      end

      it "should allow adding constraints, either as a single, or as an array" do 
         c1 = ODRL::Constraint.new(leftOperand: "event", rightOperand: "http://biohack.org", operator: "eq")
         c2 = ODRL::Constraint.new(leftOperand: "event", rightOperand: "http://biohack.org", operator: "eq")
         d = ODRL::Duty.new({constraints: c1})
         expect(d.class.to_s).to eq "ODRL::Duty"
         d = ODRL::Duty.new(constraints: [c1])
         expect(d.class.to_s).to eq "ODRL::Duty"
         d = ODRL::Duty.new(constraints: [c1,c2])
         expect(d.constraints.keys.length).to eq 2
      end
      it "should allow adding constraints by method call" do 
         c1 = ODRL::Constraint.new(leftOperand: "event", rightOperand: "http://biohack.org", operator: "eq")
         d = ODRL::Duty.new({})
         d.addConstraint(constraint: c1)
         expect(d.constraints.keys.length).to eq 1
      end
      it "should allow adding assets by method call" do 
         c1 = ODRL::Asset.new({})
         d = ODRL::Duty.new({})
         d.addAsset(asset: c1)
         expect(d.assets.keys.length).to eq 1
      end

      it "should allow serialize" do
         ODRL::Base.clear_repository
         c1 = ODRL::Asset.new({})
         d = ODRL::Duty.new({})
         d.addAsset(asset: c1)
         d.load_graph
         result = d.serialize(format: :turtle)
         expect(result.length).to eq 490
      end

   end

end