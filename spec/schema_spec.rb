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

    describe ".define_version" do
      it "returns a new schema with the given version identifier" do
        schema = Schema.define_version('this version')
        schema.versionIdentifiers.allObjects.should == ['this version']
      end
    end

    describe "when defining" do

      describe "#add_entity" do
        it "yields an entity description to the block" do
          Schema.define_version('test') do |s|
            s.add_entity do |e|
              e.name = 'AnEntity' # Needed so Core Data doesn't gripe
              e.class.should == EntityDescription
            end
          end
        end

        it "registers the entity with the schema" do
          schema = Schema.define_version('test') do |s|
            s.add_entity do |e|
              e.name = 'AnEntity' # Needed so Core Data doesn't gripe
            end
          end

          schema.entities.first.name.should == 'AnEntity'
        end
      end

    end

  end

end
