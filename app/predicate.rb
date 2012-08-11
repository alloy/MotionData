# TODO RM BridgeSupport bug
NSLocaleSensitivePredicateOption = 8

# I did not want open up classes, but it's undoable to handle NSPredicate and
# its subclasses consistently throughout the lib without a lot of extending, in
# which case all instances are techinally opened-up anyways.
class NSPredicate
  def inspect
    "(#{predicateFormat})"
  end

  def and(predicate)
    NSCompoundPredicate.andPredicateWithSubpredicates([self, predicate])
  end

  def or(predicate)
    NSCompoundPredicate.orPredicateWithSubpredicates([self, predicate])
  end
end

module MotionData
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
      NSComparisonPredicate.predicateWithLeftExpression(@expression,
                                        rightExpression:NSExpression.expressionForConstantValue(value),
                                               modifier:NSDirectPredicateModifier,
                                                   type:comparisonType,
                                                options:@comparisonOptions)
    end
  end
end
