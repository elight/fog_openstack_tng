require 'fog/core/collection'
require 'fog/openstackcommon/models/identity/tenant'

module Fog
  module Identity
    class OpenStackCommon
      class Tenants < Fog::Collection
        model Fog::Identity::OpenStackCommon::Tenant

        def all
          load(service.list_tenants.body['tenants'])
        end

        def find_by_id(id)
          cached_tenant = self.find {|tenant| tenant.id == id}
          return cached_tenant if cached_tenant
          tenant_hash = service.get_tenant(id).body['tenant']
          Fog::Identity::OpenStackCommon::Tenant.new(
            tenant_hash.merge(:service => service))
        end

        def destroy(id)
          tenant = self.find_by_id(id)
          tenant.destroy
        end
      end # class Tenants
    end # class OpenStack
  end # module Compute
end # module Fog
