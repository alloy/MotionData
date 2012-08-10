module MotionData
  class Predicate < NSComparisonPredicate
    def inspect
      "(#{predicateFormat})"
    end

    def and(predicate)
      NSCompoundPredicate.andPredicateWithSubpredicates([self, predicate])
    end

    def or(predicate)
      NSCompoundPredicate.orPredicateWithSubpredicates([self, predicate])
    end

    class KeyPathExpression
      module Mixin
        def keyPath(keyPath)
          KeyPathExpression.new(keyPath)
        end
        alias_method :key, :keyPath
      end

      attr_reader :expression

      def initialize(keyPath)
        @expression = NSExpression.expressionForKeyPath(keyPath.to_s)
      end

      def  <(value); comparisonWith(value, type:NSLessThanPredicateOperatorType);             end
      def  >(value); comparisonWith(value, type:NSGreaterThanPredicateOperatorType);          end
      def <=(value); comparisonWith(value, type:NSLessThanOrEqualToPredicateOperatorType);    end
      def >=(value); comparisonWith(value, type:NSGreaterThanOrEqualToPredicateOperatorType); end
      def !=(value); comparisonWith(value, type:NSNotEqualToPredicateOperatorType);           end
      def ==(value); comparisonWith(value, type:NSEqualToPredicateOperatorType);              end


      def between?(min, max);  comparisonWith([min, max], type:NSBetweenPredicateOperatorType);    end
      def include?(value);     comparisonWith(value,      type:NSContainsPredicateOperatorType);   end
      def in?(value);          comparisonWith(value,      type:NSInPredicateOperatorType);         end
      def beginsWith?(string); comparisonWith(string,     type:NSBeginsWithPredicateOperatorType); end
      def endsWith?(string);   comparisonWith(string,     type:NSEndsWithPredicateOperatorType);   end

      private

      def comparisonWith(value, type:comparisonType)
        value = NSExpression.expressionForConstantValue(value)
        Predicate.predicateWithLeftExpression(@expression,
                                          rightExpression:value,
                                                 modifier:NSDirectPredicateModifier,
                                                     type:comparisonType,
                                                  options:0)
      end
    end
  end
end
