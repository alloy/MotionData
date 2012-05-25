# Specs to experiment with the schema

module MotionData

  describe Schema do

    describe ".current" do
      it "creates a new schema with version identifier as 'current'" do
        Schema.current.versionIdentifiers.allObjects.should == ['current']
      end

      it "returns the same schema if called twice" do
        Schema.current.should === Schema.current
      end
    end

    describe ".defineVersion" do
      it "returns a new schema with the given version identifier" do
        schema = Schema.defineVersion('this version')
        schema.versionIdentifiers.allObjects.should == ['this version']
      end
    end

    describe "when defining" do

      before do
      end

      describe "#addEntity" do
        it "yields an entity description to the block" do
          Schema.defineVersion('test') do |s|
            s.addEntity do |e|
              e.name = 'AnEntity' # Needed so Core Data doesn't gripe
              e.class.should == EntityDescription
            end
          end
        end

        it "registers the entity with the schema" do
          schema = Schema.defineVersion('test') do |s|
            s.addEntity do |e|
              e.name = 'AnEntity' # Needed so Core Data doesn't gripe
            end
          end

          schema.entities.first.name.should == 'AnEntity'
        end
      end

      describe "#addProperty" do
        after do
          MagicalRecord.cleanUp
        end

        it "creates attributes with the given name and type" do
          schema = Schema.defineVersion('test') do |s|
            s.addEntity do |e|
              e.name = 'AnEntity' # Needed so Core Data doesn't gripe
              e.addProperty :someProp, String
            end
          end
          schema.setupCoreDataStackWithInMemoryStore

          object = EntityDescription.insertNewObjectForEntityForName('AnEntity',
                                              inManagedObjectContext:NSManagedObjectContext.defaultContext)
          object.someProp = 'hey'
          object.someProp.should == 'hey'
        end

        #it "can create non optional types"
      end

    end

  end

end
