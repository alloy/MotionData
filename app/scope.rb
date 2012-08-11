module MotionData
  class Scope
    attr_reader :target, :predicate, :sortDescriptors, :context

    def initWithTarget(target)
      initWithTarget(target, predicate:nil, sortDescriptors:nil, inContext:nil)
    end

    def initWithTarget(target, predicate:predicate, sortDescriptors:sortDescriptors, inContext:context)
      if init
        @target, @predicate = target, predicate
        @sortDescriptors    = sortDescriptors ? sortDescriptors.dup : []
        @context            = context || Context.current
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
      Scope.alloc.initWithTarget(@target,
                       predicate:predicate,
                 sortDescriptors:@sortDescriptors,
                       inContext:@context)
    end

    # Sort ascending by a key-path, or a NSSortDescriptor.
    def sortBy(keyPathOrSortDescriptor)
      if keyPathOrSortDescriptor.is_a?(NSSortDescriptor)
        addSortDescriptor(keyPathOrSortDescriptor)
      else
        sortBy(keyPathOrSortDescriptor, ascending:true)
      end
    end

    # Sort by a key-path.
    def sortBy(keyPath, ascending:ascending)
      addSortDescriptor NSSortDescriptor.alloc.initWithKey(keyPath.to_s, ascending:ascending)
    end

    # Factory methods

    # Returns a NSFetchRequest with the current scope.
    def request
      
    end

    # Executes the request and returns the results as a set.
    def set
      set = @target

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

    # Returns a NSFetchedResultsController with this fetch request.
    def controller(options = {})
      NSFetchedResultsController.alloc.initWithFetchRequest(self,
                                       managedObjectContext:MotionData::Context.current,
                                         sectionNameKeyPath:options[:sectionNameKeyPath],
                                                  cacheName:options[:cacheName])
    end

    private

    def addSortDescriptor(sortDescriptor)
      sortDescriptors = @sortDescriptors.dup
      sortDescriptors << sortDescriptor
      Scope.alloc.initWithTarget(@target,
                       predicate:@predicate,
                 sortDescriptors:sortDescriptors,
                       inContext:@context)
    end

    #class ToManyRelationship < Scope
      ## Returns the relationship set, normally provided by a Core Data to-many
      ## relationship.
      #def set
        
      #end
    #end
  end
end
