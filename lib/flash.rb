require 'json'

class Flash
    def initialize(req)
        if req.cookies['_rails_lite_app_flash']
            @now = JSON.parse(req.cookies['_rails_lite_app_flash'])
        else 
            @now = {}
        end
        @flash = {}
    end

    def [](key)
        @now[key.to_s] || @flash[key.to_s]
    end

    def []=(key, value)
        @flash[key.to_s] = value
    end

    def store_flash(res)
        serialized_flash = @flash.to_json
        res.set_cookie('_rails_lite_app_flash', { :path => '/', :value => serialized_flash })
    end

    def now
        @now
    end
end
