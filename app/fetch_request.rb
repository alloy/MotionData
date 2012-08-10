module MotionData
  class Scope
    attr_reader :target, :predicate, :sortDescriptors, :context

    def initWithTarget(target)
      initWithTarget(target, predicate:nil, sortDescriptors:nil, inContext:MotionData::Context.current)
    end

    def initWithTarget(target, predicate:predicate, sortDescriptors:sortDescriptors, inContext:context)
      if init
        @target, @predicate, @sortDescriptors, @context = target, predicate, sortDescriptors, context
      end
      self
    end

    # Add finder conditions as a hash of requirements, a Scope, or a NSPredicate.
    #
    # The conditions are added using `AND`.
    def where(conditions)
      predicate = case conditions
                  when Hash
                    NSCompoundPredicate.andPredicateWithSubpredicates(conditions.map do |key, value|
                      lhs = NSExpression.expressionForKeyPath(key)
                      rhs = NSExpression.expressionForConstantValue(value)
                      NSComparisonPredicate.predicateWithLeftExpression(lhs,
                                                        rightExpression:rhs,
                                                               modifier:NSDirectPredicateModifier,
                                                                   type:NSEqualToPredicateOperatorType,
                                                                options:0)
                    end)
                  when NSPredicate
                    conditions
                  when Scope

                  end

      if @predicate
        predicate = NSCompoundPredicate.andPredicateWithSubpredicates([@predicate, predicate])
      end

      Scope.alloc.initWithTarget(@target,
                       predicate:predicate,
                 sortDescriptors:@sortDescriptors,
                       inContext:@context)
    end

    # Add finder conditions as a hash of requirements, a Scope, or a NSPredicate.
    #
    # The conditions are added using `OR`.
    def or(conditions)
      
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

    class ToManyRelationship < FetchRequest
      # Returns the relationship set, normally provided by a Core Data to-many
      # relationship.
      def set
        
      end
    end
  end
end
