require 'cfndsl'
require 'cfndsl/globals'
require 'cfndsl/serializer'
require 'optparse'

module CfnDsl
  # Runner class for invoking CfnDsl from the command line
  class Runner
    def self.options
      @options ||= {}
    end

    def self.optparse
      @optparse ||= OptionParser.new do |opts|
        opts.version = CfnDsl::VERSION
        opts.banner = 'Usage: cfndsl [options] FILE'

        opts.on('-o', '--output FILE', 'Write output to file') do |file|
          options[:output] = file
        end

        opts.on('-e', '--extra FILE', 'Import yaml/json file as local parameters') do |fname|
          ExternalParameters.current.load_file File.expand_path(fname)
        end

        opts.on('-p', '--pretty', 'Pretty-format output JSON') do
          options[:pretty] = true
        end

        opts.on('-f', '--format FORMAT', %w[json yaml], 'Specify the output format. Default json') do |format|
          options[:format] = format
        end

        opts.on('-D', '--define key1:val1', Array, 'Define key-value pairs') do |pairs|
          key_vals = pairs.map { |p| p.split(/:/) if p.include? ':' }.compact
          ExternalParameters.current.add_to_binding Hash[key_vals]
        end

        opts.on('-d', '--debug', 'Turn on verbose ouptut') do
          CfnDsl.debug!
        end

        opts.on_tail('-v', '--version', 'Display the version')
        opts.on_tail('-h', '--help', 'Display this screen')
      end
    end

    def self.invoke!
      args = optparse.parse!
      abort(optparse.help) if args.empty?
      template_file = args.shift
      model = CfnDsl.eval_file template_file
      Serializer.new(options).serialize model.as_json
    end
  end
end
