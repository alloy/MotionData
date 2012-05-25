# Using this spec to prove out how models should work
describe "Model specs" do

  before do
    @context = NSManagedObjectContext.alloc.initWithConcurrencyType(NSMainQueueConcurrencyType)
  end

  it "can create an Author" do
    author = Author.newInManagedObjectContext(@context)
    author.name = 'test'
    author.name.should == 'test'
  end

end
