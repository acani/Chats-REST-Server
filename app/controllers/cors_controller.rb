# class REST
#   # CORS Preflight Request
#   # curl -ik -X OPTIONS -H 'Origin: http://localhost:8000' -H 'Access-Control-Request-Method: DELETE' https://localhost:5100/me
#   def cors_options
#     origin = @env['HTTP_ORIGIN']
#
#     if origin
#       @response_headers['Access-Control-Allow-Origin'] = origin
#
#       ac_request_method = env['HTTP_ACCESS_CONTROL_REQUEST_METHOD']
#       if ac_request_method
#         @response_headers['Access-Control-Max-Age'] = 86400
#         if %w[DELETE PATCH].include?(ac_request_method)
#           @response_headers['Access-Control-Allow-Methods'] = 'DELETE, PATCH'
#         end
#
#         ac_request_headers = env['HTTP_ACCESS_CONTROL_REQUEST_HEADERS']
#         if ac_request_headers && ac_request_headers.split.any? { |h| h.casecmp('authorization') == 0 }
#           @response_headers['Access-Control-Allow-Headers'] = 'authorization'
#         end
#       end
#     end
#
#     200
#   end
# end
