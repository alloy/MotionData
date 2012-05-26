describe "MotionData::ManagedObject" do

  before do
    MotionData::Schema.current.setupCoreDataStackWithInMemoryStore
  end

  after do
    MagicalRecord.cleanUp
  end

  describe "property types" do
    it "includes String support" do
      author = Author.new
      author.name = "Edgar Allan Poe"
      author.name.should == "Edgar Allan Poe"
    end
  end

end
