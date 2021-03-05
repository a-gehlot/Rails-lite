class Static
  attr_reader :app
  
  MIME_TYPES = {
    '.txt' => 'text/plain',
    '.jpg' => 'image/jpeg',
    '.zip' => 'application/zip'
    }

  PUBLIC_REGEX = /\/public\/(.+)/

  def initialize(app)
    @app = app
  end

  def call(env)
    req = Rack::Request.new(env)

    path = req.path

    if path =~ PUBLIC_REGEX
      res = Rack::Response.new
      match_regex = PUBLIC_REGEX.match(path)
      file_name = "public/#{match_regex[1]}"

      unless File.exist?(file_name)
        res.status = 404
        return res.finish
      end

      template = File.read(file_name)

      res.write(template)
      res['Content-Type'] = File.extname(file_name)
      res.finish
    end
  end
end
