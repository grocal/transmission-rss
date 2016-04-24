module TransmissionRSS
  class Feed
    attr_reader :url, :regexp

    def initialize(config = {})
      case config
      when Hash
        @url = URI.encode(config['url'] || config.keys.first)

        @download_path = config['download_path']
        @download_paths = {}

        matchers = Array(config['regexp']).map do |e|
          e.is_a?(String) ? e : e['matcher']
        end

        @regexp = build_regexp(matchers)

        initialize_download_paths(config['regexp'])
      else
        @url = config.to_s
      end
    end

    def download_path(title = nil)
      return @download_path if title.nil?

      @download_paths.each do |regexp, path|
        return path if title =~ to_regexp(regexp)
      end

      return @download_path
    end

    def matches_regexp?(title)
      @regexp.nil? || !(title =~ @regexp).nil?
    end

    private

    def build_regexp(matchers)
      matchers = Array(matchers).map { |m| to_regexp(m) }
      matchers.empty? ? nil : Regexp.union(matchers)
    end

    def initialize_download_paths(regexps)
      return unless regexps.is_a?(Array)

      regexps.each do |regexp|
        matcher = regexp['matcher']
        path    = regexp['download_path']

        @download_paths[matcher] = path if matcher && path
      end
    end

    def to_regexp(s)
      Regexp.new(s, Regexp::IGNORECASE)
    end
  end
end
