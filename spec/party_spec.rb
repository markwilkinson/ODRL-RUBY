require_relative "spec_helper"

describe ODRL::Party do
  context "When testing the Party class" do
    it "should init the right class and know its ontological type" do
      $baseURI ||= "http://example.org"
      p = ODRL::Party.new(predicate: PASSIGNER)
      expect(p.class).to be(ODRL::Party)
      expect(p.uid).to match(/\#party_\d+/)
      expect(p.type).to eq(CPARTY)
      p = ODRL::PartyCollection.new(predicate: PASSIGNER)
      expect(p.class).to be(ODRL::PartyCollection)
      expect(p.uid).to match(/\#party_\d+/)
      expect(p.type).to eq(CPARTYCOLLECTION)
    end

    it "should allow adding refinements, either as a single, or as an array" do
      $baseURI ||= "http://example.org"
      c1 = ODRL::Constraint.new(leftOperand: "event", rightOperand: "http://biohack.org", operator: "eq")
      c2 = ODRL::Constraint.new(leftOperand: "event", rightOperand: "http://biohack.org", operator: "eq")
      d = ODRL::Party.new(predicate: PASSIGNER, refinements: c1)
      expect(d.class.to_s).to eq "ODRL::Party"
      d = ODRL::Party.new(predicate: PASSIGNER, refinements: [c1])
      expect(d.class.to_s).to eq "ODRL::Party"
      d = ODRL::Party.new(predicate: PASSIGNEE, refinements: [c1, c2])
      expect(d.refinements.keys.length).to eq 2
    end

    it "should allow adding constraints by method call" do
      $baseURI ||= "http://example.org"
      c1 = ODRL::Constraint.new(leftOperand: "event", rightOperand: "http://biohack.org", operator: "eq")
      d = ODRL::Party.new(predicate: PASSIGNER)
      d.addRefinement(refinement: c1)
      expect(d.refinements.keys.length).to eq 1
    end

    it "a PartyCollection should init the right class and be an Party also" do
      $baseURI ||= "http://example.org"
      p = ODRL::PartyCollection.new(predicate: PASSIGNER)
      expect(p.class).to be(ODRL::PartyCollection)
      expect(p.uid).to match(/\#party_/)
      expect(p.is_a?(ODRL::PartyCollection)).to be(true)
    end

    it "a Party should allow to be part of an PartyCollection" do
      $baseURI ||= "http://example.org"
      ac = ODRL::PartyCollection.new(predicate: PASSIGNER)
      a = ODRL::Party.new(predicate: PASSIGNER, partOf: ac)
      expect(a.partOf.class).to be(ODRL::PartyCollection)
    end

    it "a Party should refuse to be part of a non AssetCollection" do
      $baseURI ||= "http://example.org"
      r = ODRL::Rule.new
      expect { ODRL::Party.new(predicate: "assigner", partOf: r) }.to raise_error(Exception)
    end

    it "a Party must have a predicated type (assigner assignee)" do
      $baseURI ||= "http://example.org"
      expect { ODRL::Party.new }.to raise_error(Exception)
      expect { ODRL::PartyCollection.new }.to raise_error(Exception)
      p = ODRL::PartyCollection.new(predicate: PASSIGNEE)
      expect(p.predicate).to eq PASSIGNEE
      expect { ODRL::PartyCollection.new(predicate: "somethignelse") }.to raise_error(Exception)
    end

    it "should allow serialize" do
      ODRL::Base.clear_repository
      p = ODRL::Constraint.new(rightOperand: "https://example.org/business",
                               leftOperand: "https://example.org/thing",
                               operator: "eq")
      d = ODRL::Party.new(predicate: PASSIGNEE)
      d.addRefinement(refinement: p)
      d.load_graph
      result = d.serialize(format: :turtle)
      expect(result.length).to eq 920
    end
  end
end
