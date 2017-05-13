module CfnDsl
  # Handles all external parameters
  class ExternalParameters
    extend Forwardable

    def_delegators :parameters, :fetch, :keys, :values, :each_pair

    attr_reader :parameters

    class << self
      def defaults(params = {})
        @defaults ||= {}
        @defaults.merge! params
        @defaults
      end

      def current
        @current || refresh!
      end

      def refresh!
        @current = new
      end
    end

    def initialize
      @parameters = self.class.defaults.clone
    end

    def set_param(k, v)
      parameters[k.to_sym] = v
    end

    def get_param(k)
      parameters[k.to_sym]
    end
    alias [] get_param

    def to_h
      parameters
    end

    def add_to_binding(parameters)
      parameters.each_pair do |key, val|
        CfnDsl.debug "Setting parameter #{key} to #{val}"
        set_param(key, val)
      end
    end

    def load_file(fname)
      format = File.extname fname
      CfnDsl.debug "Loading parameters from file #{fname}"
      case format
      when /ya?ml/
        params = YAML.load_file fname
      when /json/
        params = JSON.parse File.read(fname)
      else
        warn "Skipping file #{fname}: unrecognized extension #{format}"
        return
      end
      params.each { |key, val| set_param(key, val) }
    end
  end
end
