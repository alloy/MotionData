# Using this spec to prove out how models should work
describe "Model specs" do

  before do
    MotionData::Schema.current.setupCoreDataStackWithInMemoryStore
  end

  after do
    MagicalRecord.cleanUp
  end

  it "sanity check to create an Author with a string property" do
    #author = Author.newInContext(NSManagedObjectContext.defaultContext)
    author = Author.new
    author.name = 'test'
    author.name.should == 'test'
  end

end
