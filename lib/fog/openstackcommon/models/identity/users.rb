require 'fog/core/collection'
require 'fog/openstackcommon/models/identity/user'

module Fog
  module Identity
    class OpenStackCommon
      class Users < Fog::Collection
        model Fog::Identity::OpenStackCommon::User

        attribute :tenant_id

        def all
          load(service.list_users(tenant_id).body['users'])
        end

        def find_by_id(id)
          self.find {|user| user.id == id} ||
            Fog::Identity::OpenStackCommon::User.new(
              service.get_user_by_id(id).body['user'].merge(
                'service' => service
              )
            )
        end

        def destroy(id)
          user = self.find_by_id(id)
          user.destroy
        end
      end # class Users
    end # class OpenStack
  end # module Identity
end # module Fog
