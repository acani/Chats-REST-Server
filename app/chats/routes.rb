class Chats
  def call(env)
    @env = env
    # Eg: POST /sessions/1/1234 calls #sessions_post(1, 1234)
    path_segments = env['PATH_INFO'][1..-1].split('/', 3)
    method_name = "#{path_segments.shift}_#{env['REQUEST_METHOD'].downcase}".to_sym
    if respond_to?(method_name) && method(method_name).arity == path_segments.count
      path_segments.map! { |s| s.to_i }
      return_value = send(method_name, *path_segments)
      return_value[1] = [return_value[1]]
      return_value.insert(1, {'Content-Type' => 'application/json'})
    else
      [404, {}, []]
    end
  end
end
