require_relative "../lib/odrl/policy.rb"
require_relative "../lib/odrl/rule.rb"
require_relative "../lib/odrl/base.rb"
require_relative "../lib/odrl/asset.rb"
require_relative "../lib/odrl/constraint.rb"
require_relative "../lib/odrl/party.rb"
require_relative "../lib/odrl/action.rb"


describe ODRL::Constraint do 
   context "When testing the Constraint class" do 
      
      it "should init the right class" do 
         p = ODRL::Constraint.new({})
         expect(p.class).to be (ODRL::Constraint)
         expect(p.uid).to match (/\#constraint\_/)
      end

      # :rightOperand, :leftOperand, :operator,
      it "should allow addition of operands and operator" do 
         p = ODRL::Constraint.new({rightOperand: "https://example.org/business", 
                                 leftOperand: "https://example.org/thing", 
                                 operator: "eq"})
         expect(p.class).to be (ODRL::Constraint)
         expect(p.uid).to match (/\#constraint\_/)
      end

      it "should allow serialize" do 
         ODRL::Base.clear_repository
         p = ODRL::Constraint.new({rightOperand: "https://example.org/business", 
                                 leftOperand: "https://example.org/thing", 
                                 operator: "eq"})
         p.load_graph
         result = p.serialize
         expect(result.length).to eq 568
      end

   end

end