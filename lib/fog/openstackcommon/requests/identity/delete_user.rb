require 'multi_json'

module Fog
  module Identity
    class OpenStackCommon
      class Real

        def delete_user(user_id)
          request(
            :expects => [200, 204],
            :method => 'DELETE',
            :path   => "/users/#{user_id}"
          )
        end

        # class Mock
        #   def delete_user(user_id)
        #     self.data[:users].delete(
        #       list_users.body['users'].find {|x| x['id'] == user_id }['id'])
        #
        #     response = Excon::Response.new
        #     response.status = 204
        #     response
        #   rescue
        #     raise Fog::Identity::OpenStackCommon::NotFound
        #   end
        # end

      end # Real

      class Mock
      end
    end # OpenStackCommon
  end # Identity
end # Fog
