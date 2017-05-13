require 'json'
require 'yaml'

module CfnDsl
  # Serializer for handling output options
  class Serializer
    attr_reader :format, :pretty, :outfile, :outname

    def initialize(options = {})
      @format = options[:format] || :json
      @pretty = options[:pretty] || false
      @outname = options[:output] || 'stdout'
      @outfile = outname == 'stdout' ? $stdout : File.open(output, 'w')
    end

    def serialize(jsonable)
      CfnDsl.debug "Writing #{format} output to #{outname}"
      text = case format
             when :yaml then YAML.dump(jsonable)
             when :json then pretty ? JSON.pretty_generate(jsonable) : JSON.generate(jsonable)
             end
      outfile.puts text
      outfile.close
    end
  end
end
