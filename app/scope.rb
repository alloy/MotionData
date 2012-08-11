module MotionData
  class Scope
    include Enumerable

    attr_reader :target, :predicate, :sortDescriptors

    def initWithTarget(target)
      initWithTarget(target, predicate:nil, sortDescriptors:nil)
    end

    def initWithTarget(target, predicate:predicate, sortDescriptors:sortDescriptors)
      if init
        @target, @predicate = target, predicate
        @sortDescriptors    = sortDescriptors ? sortDescriptors.dup : []
      end
      self
    end

    # Add finder conditions as a hash of requirements, a Scope, a NSPredicate,
    # or a predicate format string with an optional list of arguments.
    #
    # The conditions are added using `AND`.
    def where(conditions, *formatArguments)
      predicate = case conditions
                  when Hash
                    NSCompoundPredicate.andPredicateWithSubpredicates(conditions.map do |keyPath, value|
                      Predicate::Builder.new(keyPath) == value
                    end)
                  when Scope
                    conditions.predicate
                  when NSPredicate
                    conditions
                  when String
                    NSPredicate.predicateWithFormat(conditions, argumentArray:formatArguments)
                  end

      predicate = @predicate.and(predicate) if @predicate
      scopeWithPredicate(predicate)
    end

    # Sort ascending by a key-path, or a NSSortDescriptor.
    def sortBy(keyPathOrSortDescriptor)
      if keyPathOrSortDescriptor.is_a?(NSSortDescriptor)
        scopeByAddingSortDescriptor(keyPathOrSortDescriptor)
      else
        sortBy(keyPathOrSortDescriptor, ascending:true)
      end
    end

    # Sort by a key-path.
    def sortBy(keyPath, ascending:ascending)
      scopeByAddingSortDescriptor(NSSortDescriptor.alloc.initWithKey(keyPath.to_s, ascending:ascending))
    end

    # Iterates over the array representation of the scope.
    def each(&block)
      array.each(&block)
    end

    # Factory methods that should be implemented by the subclass.

    def array
      raise "Not implemented"
    end

    # TODO RM bug? aliased methods in subclasses don't call overriden version of aliased method.
    #alias_method :to_a, :array

    def to_a
      array
    end

    def set
      raise "Not implemented."
    end

    private

    def scopeWithPredicate(predicate)
      scopeWithPredicate(predicate, sortDescriptors:@sortDescriptors)
    end

    def scopeByAddingSortDescriptor(sortDescriptor)
      sortDescriptors = @sortDescriptors.dup
      sortDescriptors << sortDescriptor
      scopeWithPredicate(@predicate, sortDescriptors:sortDescriptors)
    end

    def scopeWithPredicate(predicate, sortDescriptors:sortDescriptors)
      self.class.alloc.initWithTarget(@target, predicate:predicate, sortDescriptors:sortDescriptors)
    end
  end

  class Scope
    class Set < Scope
      def set
        setByApplyingConditionsToSet(@target)
      end

      def array
        set = self.set
        set.is_a?(NSOrderedSet) ? set.array : set.allObjects
      end

      private

      # Applies the finder and sort conditions and returns the result as a set.
      def setByApplyingConditionsToSet(set)
        if @predicate
          if set.is_a?(NSOrderedSet)
            # TODO not the most efficient way of doing this when there are also sort descriptors
            filtered = set.array.filteredArrayUsingPredicate(@predicate)
            set = NSOrderedSet.orderedSetWithArray(filtered)
          else
            set = set.filteredSetUsingPredicate(@predicate)
          end
        end

        unless @sortDescriptors.empty?
          set = set.set if set.is_a?(NSOrderedSet)
          sorted = set.sortedArrayUsingDescriptors(@sortDescriptors)
          set = NSOrderedSet.orderedSetWithArray(sorted)
        end

        set
      end
    end
  end

  class Scope
    class Relationship < Scope::Set
      attr_accessor :relationshipName, :owner, :ownerClass

      def initWithTarget(target, relationshipName:relationshipName, owner:owner, ownerClass:ownerClass)
        if initWithTarget(target)
          @relationshipName, @owner, @ownerClass = relationshipName, owner, ownerClass
        end
        self
      end

      def new(properties = nil)
        entity = targetClass.newInContext(@owner.managedObjectContext, properties)
        # Uses the Core Data dynamically generated method to add objects to the relationship.
        #
        # E.g. if the relationship is called 'articles', then this will call: addArticles()
        #
        # TODO we currently use the one that takes a set instead of just one object, this is
        #      so we don't yet have to do any singularization
        camelized = @relationshipName.to_s
        camelized[0] = camelized[0,1].upcase
        @owner.send("add#{camelized}", NSSet.setWithObject(entity))
        entity
      end

      # Returns a NSFetchRequest with the current scope.
      def fetchRequest
        # Start with a predicate which selects those entities that belong to the owner.
        predicate = Predicate::Builder.new(inverseRelationshipName) == @owner
        # Then apply the scope's predicate.
        predicate = predicate.and(@predicate) if @predicate

        request = NSFetchRequest.new
        request.entity = targetClass.entityDescription
        request.predicate = predicate
        request.sortDescriptors = @sortDescriptors unless @sortDescriptors.empty?
        request
      end

      private

      def relationshipDescription
        @ownerClass.entityDescription.relationshipsByName[@relationshipName]
      end

      def targetEntityDescription
        relationshipDescription.destinationEntity
      end

      def targetClass
        targetEntityDescription.klass
      end

      def inverseRelationshipName
        relationshipDescription.inverseRelationship.name
      end

      def scopeWithPredicate(predicate, sortDescriptors:sortDescriptors)
        scope = super
        scope.relationshipName = @relationshipName
        scope.owner = @owner
        scope.ownerClass = @ownerClass
        scope
      end
    end
  end

  class Scope
    class Model < Scope
      def set
        @sortDescriptors.empty? ? NSSet.setWithArray(array) : NSOrderedSet.orderedSetWithArray(array)
      end

      def array
        error = Pointer.new(:object)
        result = Context.current.executeFetchRequest(fetchRequest, error:error)
        if error[0]
          raise "Error while fetching: #{error[0].debugDescription}"
        end
        result
      end

      def fetchRequest
        request = NSFetchRequest.new
        request.entity = @target.entityDescription
        request.predicate = @predicate
        request.sortDescriptors = @sortDescriptors unless @sortDescriptors.empty?
        request
      end
    end
  end
end
