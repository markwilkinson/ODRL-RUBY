require_relative "spec_helper"

describe ODRL::Policy do
  context "When testing the Policy class" do
    # it "should create raise error without base uri" do
    #    ENV['ODRL_BASEURI'] = nil
    #    expect{ODRL::Policy.new({})}.to raise_error(Exception)
    # end

    it "should accept a new title and be a policy type, including the uid" do
      p = ODRL::Set.new(title: "rspec test")
      expect(p.title).to eq "rspec test"
      expect(p.type).to eq CSET
      expect(p.uid).to match(/\#policy_\d+/)
      $baseURI = nil
    end

    it "should accept full init" do
      p = ODRL::Set.new(
        title: "test1",
        creator: "test2",
        baseURI: "http://abc.def"
      )
      title = p.title
      creator = p.creator
      baseURI = p.baseURI
      expect(title).to eq "test1"
      expect(creator).to eq "test2"
      expect(baseURI).to eq "http://abc.def"
    end

    it "should init as an agreement" do
      p = ODRL::Agreement.new(title: "test1", author: "test2")
      type = p.type
      expect(type).to eq CAGREEMENT
    end

    it "should add a prohibition to list of rules" do
      p = ODRL::Agreement.new(title: "test1", author: "test2")
      pro = ODRL::Prohibition.new
      p.addProhibition(rule: pro)
      expect(p.rules.length).to eq(1)
      expect(p.rules[p.rules.keys.first][1].class.to_s).to eq "ODRL::Prohibition"
    end

    it "should allow serialize" do
      ODRL::Base.clear_repository
      p = ODRL::Offer.new(title: "test1", author: "test2")
      pro = ODRL::Prohibition.new
      p.addProhibition(rule: pro)
      p.load_graph
      result = p.serialize(format: :turtle)
      expect(result.length).to eq 779
    end
  end
end
