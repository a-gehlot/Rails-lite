require 'erb'

class ShowExceptions

  attr_reader :app

  def initialize(app)
    @app = app
  end

  def call(env)
    begin
      @app.call(env)
    rescue => e
      render_exception(e)
    end
  end

  private

  def render_exception(e)
    template = ERB.new((File.read('lib/rescue.html.erb')))
    ['500', {'Content-type' => 'text/html'}, template.result(binding)]
  end

end
