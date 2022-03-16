require_relative "../lib/odrl/policy.rb"
require_relative "../lib/odrl/rule.rb"
require_relative "../lib/odrl/base.rb"
require_relative "../lib/odrl/asset.rb"
require_relative "../lib/odrl/constraint.rb"


describe ODRL::Policy do 
   context "When testing the Policy class" do 
      
      it "should create raise error without base uri" do 
         expect{ODRL::Policy.new({})}.to raise_error(Exception)
      end


      it "should accept a new title and be a policy type" do 
         p = ODRL::Policy.new(baseURI: "https://this.is", title: "rspec test") 
         expect(p.title).to eq "rspec test"
         expect(p.type).to eq "Policy"
         $baseURI = nil
      end

      it "should accept full init" do 
         p = ODRL::Policy.new(      
            title: "test1",
            author: "test2",
            baseURI: "http://abc.def",
         ) 
         title = p.title 
         author = p.author
         baseURI = p.baseURI
         expect(title).to eq "test1"
         expect(author).to eq "test2"
         expect(baseURI).to eq "http://abc.def"
      end


      it "should init as an agreement" do 
         p = ODRL::Agreement.new(title: "test1", author: "test2", baseURI: "http://abc.def") 
         type = p.type 
         expect(type).to eq "Agreement"
      end
      
      
      it "should add a prohibition to list of rules" do 
         p = ODRL::Agreement.new(title: "test1", author: "test2", baseURI: "http://abc.def") 
         pro = ODRL::Prohibition.new({})
         p.addProhibition(rule: pro)
         expect(p.rules.length).to eq (1)
         expect(p.rules[p.rules.keys.first][1].class.to_s).to eq "ODRL::Prohibition"
         
      end



   end

end