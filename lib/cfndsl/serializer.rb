require 'json'
require 'yaml'

module CfnDsl
  # Serializer for handling output options
  class Serializer
    def self.default_output_pattern
      '%{output_dir}/%{template_basename}.%{format}'
    end

    attr_reader :format, :pretty, :outfile, :outname, :pattern, :output_dir, :outdir

    def initialize(template, options = {})
      @format = options[:format] || :json
      @pretty = options[:pretty] || false
      @outdir = File.dirname(template)
      @pattern = options[:pattern]
      @outname = options[:pattern] ? interpolate_pattern(template) : 'stdout'
      @outfile = outname == 'stdout' ? $stdout : File.open(outname, 'w')
    end

    def interpolate_pattern(template)
      template_basename = File.basename(template, File.extname(template))
      lookups = {
        template_basename: template_basename,
        output_dir: outdir,
        format: format
      }
      pattern.gsub(/(%{\w+})/) do |match|
        key = match.gsub(/[%{}]/, '')
        lookups[key.to_sym]
      end
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
