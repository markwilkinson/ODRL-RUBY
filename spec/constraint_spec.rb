require_relative "./spec_helper.rb"



describe ODRL::Constraint do 
   context "When testing the Constraint class" do 
      
      it "should init the right class" do 
         p = ODRL::Constraint.new(leftOperand: "event", rightOperand: "http://biohack.org", operator: "eq")
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
         result = p.serialize(format: :turtle)
         expect(result.length).to eq 484
      end

   end

end