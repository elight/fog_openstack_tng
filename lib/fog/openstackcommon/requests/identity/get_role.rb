module Fog
  module Identity
    class OpenStackCommon
      class Real

        def get_role(id)
          request(
            :expects => [200, 204],
            :method  => 'GET',
            :path    => "/OS-KSADM/roles/#{id}"
          )
        end

        # class Mock
        #   def get_role(id)
        #     response = Excon::Response.new
        #     if data = self.data[:roles][id]
        #       response.status = 200
        #       response.body = { 'role' => data }
        #       response
        #     else
        #       raise Fog::Identity::OpenStackCommon::NotFound
        #     end
        #   end
        # end # class Mock

      end # Real

      class Mock
      end
    end # OpenStackCommon
  end # Identity
end # Fog
