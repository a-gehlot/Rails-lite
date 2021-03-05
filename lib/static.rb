class Static
  attr_reader :app
  def initialize(app)
    @app = app
  end

  def call(env)
    @path = env["PATH_INFO"]
    if @path =~ /\/public\/.*/ && File.exist?(".#{@path}")
      req = Rack::Request.new(env)
      res = Rack::Response.new
      res['Content-Type'] = 'text/plain'
      template = File.read(".#{@path}")
      res.write(template)
      res.finish
    else
      [404, {"Content-Type" => "text/html"}, ["Not Found"]]
    end
  end
end
