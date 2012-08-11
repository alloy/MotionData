module MotionData
  class Scope
    attr_reader :target, :predicate, :sortDescriptors, :context

    def initWithTarget(target)
      initWithTarget(target, predicate:nil, sortDescriptors:nil, inContext:Context.current)
    end

    def initWithTarget(target, predicate:predicate, sortDescriptors:sortDescriptors, inContext:context)
      if init
        @target, @predicate, @sortDescriptors, @context = target, predicate, sortDescriptors, context
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
                    CompoundPredicate.andPredicateWithSubpredicates(conditions.map do |keyPath, value|
                      ComparableKeyPathExpression.new(keyPath) == value
                    end)
                  when Scope
                    conditions.predicate
                  when Predicate::Ext
                    # this is one of the MotionData predicate subclasses which mixes in the Ext module.
                    conditions
                  when NSPredicate
                    conditions.extend(Predicate::Ext)
                    conditions
                  when String
                    conditions = NSPredicate.predicateWithFormat(conditions, argumentArray:formatArguments)
                    conditions.extend(Predicate::Ext)
                    conditions
                  end

      predicate = @predicate.and(predicate) if @predicate
      Scope.alloc.initWithTarget(@target,
                       predicate:predicate,
                 sortDescriptors:@sortDescriptors,
                       inContext:@context)
    end

    # Sort ascending by an attribute, or a NSSortDescriptor.
    def sortBy(attribute)
      sortBy(attribute, ascending:true)
    end

    # Sort by an attribute.
    def sortBy(attribute, ascending:ascending)
      
    end

    # Factory methods

    # Returns a NSFetchRequest with the current scope.
    def request
      
    end

    # Executes the request and returns the results as a set.
    def set
      
    end

    # Returns a NSFetchedResultsController with this fetch request.
    def controller(options = {})
      NSFetchedResultsController.alloc.initWithFetchRequest(self,
                                       managedObjectContext:MotionData::Context.current,
                                         sectionNameKeyPath:options[:sectionNameKeyPath],
                                                  cacheName:options[:cacheName])
    end

    #class ToManyRelationship < Scope
      ## Returns the relationship set, normally provided by a Core Data to-many
      ## relationship.
      #def set
        
      #end
    #end
  end
end
