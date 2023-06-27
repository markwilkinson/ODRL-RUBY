require_relative "./spec_helper.rb"


describe ODRL::Action do 
   context "When testing the Action class" do 
      
      it "should init the right class" do 
         $baseURI = "http://example.org" unless $baseURI
         p = ODRL::Action.new(value: "use")
         expect(p.class).to be (ODRL::Action)
         expect(p.uid).to match (/use$/)

      end

      it "should init the right subclass (Use/Transfer)" do 
         $baseURI = "http://example.org" unless $baseURI
         p = ODRL::Use.new(value: "use")
         expect(p.class).to be (ODRL::Use)
         expect(p.is_a? ODRL::Action).to be (true)
         p = ODRL::Transfer.new(value: "transfer")
         expect(p.class).to be (ODRL::Transfer)
         expect(p.is_a? ODRL::Action).to be (true)

      end


      it "should allow adding refinements, either as a single, or as an array" do 
         $baseURI = "http://example.org" unless $baseURI
         c1 = ODRL::Constraint.new(rightOperand: "event", operator: "eq", leftOperand: "http://biohack/org")
         c2 = ODRL::Constraint.new(rightOperand: "event", operator: "eq", leftOperand: "http://biohack/org")
         d = ODRL::Use.new(value: "use", refinements: c1)
         expect(d.class.to_s).to eq "ODRL::Use"
         d = ODRL::Use.new(value: "use", refinements: [c1])
         expect(d.class.to_s).to eq "ODRL::Use"
         d = ODRL::Transfer.new(value: "transfer", refinements: [c1,c2])
         expect(d.refinements.keys.length).to eq 2
      end


      it "should allow adding constraints by method call" do 
         $baseURI = "http://example.org" unless $baseURI
         c1 = ODRL::Constraint.new(rightOperand: "event", operator: "eq", leftOperand: "http://biohack/org")
         d = ODRL::Use.new(value: "use")
         d.addRefinement(refinement: c1)
         expect(d.refinements.keys.length).to eq 1
      end

      it "should allow serialize" do 
         ODRL::Base.clear_repository
         p = ODRL::Constraint.new({rightOperand: "https://example.org/business", 
                                 leftOperand: "https://example.org/thing", 
                                 operator: "eq"})
         d = ODRL::Action.new(value: "use")
         d.addRefinement(refinement: p)
         d.load_graph
         result = d.serialize(format: 'turtle')
         expect(result.length).to eq 829
      end


   end

end