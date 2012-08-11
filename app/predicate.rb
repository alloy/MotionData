# TODO RM BridgeSupport bug
NSLocaleSensitivePredicateOption = 8

class NSPredicate
  def inspect
    "(#{predicateFormat})"
  end
end

module MotionData
  class Predicate < NSPredicate
    module Ext
      def and(predicate)
        CompoundPredicate.andPredicateWithSubpredicates([self, predicate])
      end

      def or(predicate)
        CompoundPredicate.orPredicateWithSubpredicates([self, predicate])
      end
    end

    include Predicate::Ext
  end

  class ComparisonPredicate < NSComparisonPredicate
    include Predicate::Ext
  end

  class CompoundPredicate < NSCompoundPredicate
    include Predicate::Ext
  end

  class ComparableKeyPathExpression
    module Mixin
      def value(keyPath)
        ComparableKeyPathExpression.new(keyPath)
      end
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
      ComparisonPredicate.predicateWithLeftExpression(@expression,
                                      rightExpression:NSExpression.expressionForConstantValue(value),
                                             modifier:NSDirectPredicateModifier,
                                                 type:comparisonType,
                                              options:@comparisonOptions)
    end
  end
end
