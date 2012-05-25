# Using this spec to prove out how models should work
describe "Model specs" do

  before do
    @context = NSManagedObjectContext.alloc.initWithConcurrencyType(NSMainQueueConcurrencyType)
  end

  it "sanity check to create an Author with a string property" do
    author = Author.newInManagedObjectContext(@context)
    author.name = 'test'
    author.name.should == 'test'
  end

end
