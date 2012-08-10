# TODO RM BridgeSupport bug
NSLocaleSensitivePredicateOption = 8

class NSPredicate
  def inspect
    "(#{predicateFormat})"
  end
end

module MotionData
  module Predicate
    def and(predicate)
      Compound.andPredicateWithSubpredicates([self, predicate])
    end

    def or(predicate)
      Compound.orPredicateWithSubpredicates([self, predicate])
    end

    class Comparison < NSComparisonPredicate
      include Predicate
    end

    class Compound < NSCompoundPredicate
      include Predicate
    end

    class ComparableKeyPathExpression
      module Mixin
        def keyPath(keyPath)
          ComparableKeyPathExpression.new(keyPath)
        end
        alias_method :key, :keyPath
      end

      attr_reader :expression, :comparisonOptions

      def initialize(keyPath)
        @expression = NSExpression.expressionForKeyPath(keyPath.to_s)
        @comparisonOptions = 0
      end

      def caseInsensitive;      @comparisonOptions |= NSCaseInsensitivePredicateOption;      self; end
      def diacriticInsensitive; @comparisonOptions |= NSDiacriticInsensitivePredicateOption; self; end
      def localeSensitive;      @comparisonOptions |= NSLocaleSensitivePredicateOption;      self; end

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
        Comparison.predicateWithLeftExpression(@expression,
                               rightExpression:value,
                                      modifier:NSDirectPredicateModifier,
                                          type:comparisonType,
                                       options:@comparisonOptions)
      end
    end
  end
end
