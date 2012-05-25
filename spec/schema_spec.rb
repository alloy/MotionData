# Specs to experiment with the schema

describe Schema do

  describe ".current" do
    it "creates a new schema with version identifier as 'current'" do
      Schema.current.versionIdentifiers.allObjects.should == ['current']
    end

    it "returns the same schema if called twice" do
      Schema.current.should === Schema.current
    end
  end

end
