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

      describe "#entity" do
        it "yields an entity description to the block" do
          Schema.defineVersion('test') do |s|
            s.entity do |e|
              e.name = 'AnEntity' # Needed so Core Data doesn't gripe
              e.class.should == EntityDescription
            end
          end
        end

        it "registers the entity with the schema" do
          schema = Schema.defineVersion('test') do |s|
            s.entity do |e|
              e.name = 'AnEntity' # Needed so Core Data doesn't gripe
            end
          end

          schema.entities.first.name.should == 'AnEntity'
        end
      end

      describe "#property" do
        after do
          MagicalRecord.cleanUp
        end

        it "creates attributes with the given name and type" do
          schema = Schema.defineVersion('test') do |s|
            s.entity do |e|
              e.name = 'AnEntity' # Needed so Core Data doesn't gripe
              e.property :someProp, String
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

    #describe "when migrating" do
      #before do
        #@version_1 = Schema.defineVersion('migration-test-1') do |s|
          #s.entity do |e|
            #e.name = 'Entity1'
            #e.property :firstProperty, String
          #end
        #end
        #@version_2 = Schema.defineVersion('migration-test-2') do |s|
          #s.entity do |e|
            #e.name = 'Entity1'
            #e.property :firstProperty, String
            #e.property :secondProperty, CoreTypes::Boolean
          #end
          #s.entity do |e|
            #e.name = 'Entity2'
            #e.property :firstProperty, String
          #end
        #end
        #@version_3 = Schema.defineVersion('migration-test-3') do |s|
          #s.entity do |e|
            #e.name = 'Entity1'
            #e.property :firstProperty, String
            ## Removed secondProperty
          #end
          #s.entity do |e|
            #e.name = 'Entity2'
            ## Removed firstProperty
            #e.property :secondProperty, CoreTypes::Boolean
          #end
          #s.entity do |e|
            #e.name = 'Entity3'
            #e.property :firstProperty, String
            #e.property :secondProperty, CoreTypes::Boolean
          #end
        #end
      #end

      #after do
        #MagicalRecord.cleanUp
      #end

      #def ensure_schema_version_3_exists!
        #entity1 = NSEntityDescription.entityForName('Entity1', inManagedObjectContext:NSManagedObjectContext.defaultContext)
        #entity1.properties.size.should == 1
        #property = entity1.properties.first
        #property.name.should == :firstProperty
        #property.attributeType.should == NSStringAttributeType

        #entity2 = NSEntityDescription.entityForName('Entity2', inManagedObjectContext:NSManagedObjectContext.defaultContext)
        #entity2.properties.size.should == 1
        #property = entity2.properties.first
        #property.name.should == :secondProperty
        #property.attributeType.should == NSBooleanAttributeType

        #entity3 = NSEntityDescription.entityForName('Entity3', inManagedObjectContext:NSManagedObjectContext.defaultContext)
        #entity3.properties.size.should == 2
        #property = entity3.properties.first
        #property.name.should == :firstProperty
        #property.attributeType.should == NSStringAttributeType
        #property = entity3.properties.last
        #property.name.should == :secondProperty
        #property.attributeType.should == NSBooleanAttributeType
      #end

      ##it "migrates to the latest version from an clean slate" do
        ### nil -> @version_3
        ##@version_3.setupCoreDataStackWithInMemoryStore
        ##@version_3.migrate!
      ##end

      #it "migrates to the latest version from the first version" do
        ## @version_1 -> @version_3
        #@version_1.setupCoreDataStackWithInMemoryStore
        #entity1 = NSEntityDescription.entityForName('Entity1', inManagedObjectContext:NSManagedObjectContext.defaultContext)
        #entity1.properties.size.should == 1
        #property = entity1.properties.first
        #property.name.should == :firstProperty
        #property.attributeType.should == NSStringAttributeType

        #entity2 = NSEntityDescription.entityForName('Entity2', inManagedObjectContext:NSManagedObjectContext.defaultContext)
        #entity2.should == nil

        #entity3 = NSEntityDescription.entityForName('Entity3', inManagedObjectContext:NSManagedObjectContext.defaultContext)
        #entity3.should == nil

        ##@version_3.migrate!
        #@version_3.migrateFromSchema(@version_1)
        #ensure_schema_version_3_exists!
      #end

      ##it "migrates to the latest version from an arbitrary version" do
        ### @version_2 -> @version_3
        ##@version_2.setupCoreDataStackWithInMemoryStore
        ##@version_3.migrate!
      ##end
    #end

  end

end
