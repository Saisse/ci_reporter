require 'ci/reporter/core'

module CI
  module Reporter
    class RSpecFailure
      def initialize(failure)
        @failure = failure
      end
      
      def failure?
        @failure.expectation_not_met?
      end
      
      def error?
        !@failure.expectation_not_met?
      end
      
      def exception
        @failure.exception
      end
    end

    class RSpec < Spec::Runner::Formatter::ProgressBarFormatter
      def initialize(output, dry_run=false, colour=false, report_mgr=nil)
        super(output, dry_run, colour)
        @report_manager = report_mgr || ReportManager.new("spec")
        @suite = nil
      end

      def start(spec_count)
        super
      end

      def add_context(name, first)
        super
        write_report if @suite
        @suite = TestSuite.new name
        @suite.start
      end

      def spec_started(name)
        super
        spec = TestCase.new name
        @suite.testcases << spec
        spec.start
      end

      def spec_failed(name, counter, failure)
        super
        spec = @suite.testcases.last
        spec.finish
        spec.failure = RSpecFailure.new(failure)
      end

      def spec_passed(name)
        super
        spec = @suite.testcases.last
        spec.finish
      end

      def start_dump
        super
      end

      def dump_failure(counter, failure)
        super
      end

      def dump_summary(duration, spec_count, failure_count)
        super
        write_report
      end

      private
      def write_report
        @suite.finish
        @report_manager.write_report(@suite)
      end
    end
  end
end