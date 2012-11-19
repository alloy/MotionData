# TODO RM BridgeSupport bug
NSLocaleSensitivePredicateOption = 8

module MotionData
  module Predicate
    def inspect
      "(#{predicateFormat})"
    end

    def and(predicate)
      NSCompoundPredicate.andPredicateWithSubpredicates([self, predicate])
    end

    def or(predicate)
      NSCompoundPredicate.orPredicateWithSubpredicates([self, predicate])
    end

    class Builder
      module Mixin
        def value(keyPath)
          Builder.new(keyPath)
        end
      end

      attr_reader :leftExpression, :comparisonOptions, :negate

      def initialize(keyPath)
        @leftExpression = NSExpression.expressionForKeyPath(keyPath.to_s)
        @comparisonOptions = 0
        @negate = false
      end

      def not; @negate = true; self; end

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
        predicate = NSComparisonPredicate.predicateWithLeftExpression(@leftExpression,
                                                      rightExpression:NSExpression.expressionForConstantValue(value),
                                                             modifier:NSDirectPredicateModifier,
                                                                 type:comparisonType,
                                                              options:@comparisonOptions)
        @negate ? NSCompoundPredicate.notPredicateWithSubpredicate(predicate) : predicate
      end
    end
  end
end

# I did not want open up classes, but it's undoable to handle NSPredicate and
# its subclasses consistently throughout the lib without a lot of extending, in
# which case all instances are techinally opened-up anyways.
class NSPredicate
  include MotionData::Predicate
end
