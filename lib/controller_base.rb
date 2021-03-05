require 'active_support'
require 'active_support/core_ext'
require 'active_support/inflector'
require 'erb'
require_relative './session'
require_relative './flash'
require 'securerandom'

class ControllerBase
  attr_reader :req, :res, :params, :form_authenticity_token

  # Setup the controller
  def initialize(req, res, params = {})
    @req = req
    @res = res
    @params = params.merge(req.params)
    @@protect_from_forgery ||= false
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  # Set the response status code and header
  def redirect_to(url)
    @res.add_header('Location', url)
    @res.status = 302
    raise 'Double render' if self.already_built_response?
    @res.finish
    session.store_session(@res)
    flash.store_flash(@res)
    @already_built_response = true
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    @res['Content-Type'] = content_type
    @res.write(content)
    raise 'Double render' if self.already_built_response?
    @res.finish
    session.store_session(@res)
    flash.store_flash(@res)
    @already_built_response = true
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    template_file = template_name.to_s.underscore + ".html.erb"
    controller = self.class.name.underscore
    path = File.join("views/", controller, template_file)
    template = ERB.new(File.read(path))
    content = template.result(binding)
    self.render_content(content, "text/html")
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(@req)
  end

  def flash
    @flash ||= Flash.new(@req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    unless @req.request_method == 'GET' || self.class.protect_from_forgery == false
      check_authenticity_token
    else
      form_authenticity_token
    end

    self.send(name)

    unless self.already_built_response?
      self.render(name.to_s)
    end
  end

  def form_authenticity_token
    @token ||= SecureRandom.urlsafe_base64 
    @res.set_cookie('authenticity_token', @token)
    @token
  end

  def check_authenticity_token
    token = @req.cookies['authenticity_token']
    unless token && token == params['authenticity_token']
      raise 'Invalid authenticity token'
    end
  end

  def self.protect_from_forgery
    @@protect_from_forgery = true
  end
end

