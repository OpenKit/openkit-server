module OpenKit
  module Request

    class Upload
      attr_accessor :param_name, :filepath

      def initialize(param_name, filepath)
        @param_name = param_name
        @filepath = filepath
      end

      def file
        @file ||= File.open(@filepath)
      end

      def close
        @file.close if @file  # Use ivar directly, not the #file method.
      end
    end
  end
end
