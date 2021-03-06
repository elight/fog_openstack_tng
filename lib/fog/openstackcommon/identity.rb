require_relative './core'

module Fog
  module Identity
    class OpenStackCommon < Fog::Service

      requires :openstack_auth_url
      recognizes :openstack_auth_token, :openstack_management_url, :persistent,
                  :openstack_service_type, :openstack_service_name, :openstack_tenant,
                  :openstack_api_key, :openstack_username, :openstack_current_user_id,
                  :openstack_endpoint_type,
                  :current_user, :current_tenant

      model_path 'fog/openstackcommon/models/identity'
      model       :tenant
      collection  :tenants
      model       :user
      collection  :users
      model       :role
      collection  :roles
      model       :ec2_credential
      collection  :ec2_credentials

      request_path 'fog/openstackcommon/requests/identity'


      # Administrative API Operations ----------------------------
      # http://docs.openstack.org/api/openstack-identity-service/2.0/content/Admin_API_Service_Developer_Operations-d1e1356.html

      ## Token Operations
      # http://docs.openstack.org/api/openstack-identity-service/2.0/content/Token_Operations.html
      request :check_token
      request :validate_token
      request :list_endpoints_for_token

      ## User Operations
      # http://docs.openstack.org/api/openstack-identity-service/2.0/content/User_Operations.html
      request :get_user_by_name
      request :get_user_by_id
      # request :list_user_global_roles
      #
      # ---- 3/6/2014 ----
      # NOTE - commented request out as not supported in Keystone, even tho the
      # docs might still reference it - irc conversation for background.
      #
      # <wchrisj>	 Am trying to hit this URL, and the docs for v2 say it should work:
      #             http://devstack.local:5000/v2.0/users/{userid}/roles
      # <wchrisj>	 when I manually hit the url, I get a 404 - would I get that if there are no
      #             roles associated with the user in question? stevemar:
      # <@dolphm>	 stevemar: wchrisj: i don't think it's a supported call, as the error message indicates
      # <wchrisj>	 yeah, I'm getting a 404 trying to hit this url
      # <wchrisj>	 http://devstack.local:5000/v2.0/users/2f649419c1ed4801bea38ead0e1ed6ad/roles
      # <@dolphm>	 wchrisj: it's an ambiguously specified API call that we chose to never implement so as
      #             to avoid flip-flopping between the two perceivable interpretations of the spec; instead
      #             we have GET /v3/role_assignments
      # <@dolphm>	 wchrisj: which is much more powerful and avoids any confusing semantics around the call
      # <wchrisj>	 so why do the v2 docs say it exists?
      # <@dolphm>	 wchrisj: because it *may* be implemented by an alternative implementation of the API, but
      #             keystone chooses not to
      # <@dolphm>	 wchrisj: if you have authz on the rackspace public cloud, i think you'll get something
      #             back -- but you'd likely file a bug report because it's not the results you'd expect :)
      # <@dolphm>	 wchrisj: the identity service is one of the few APIs with more than one complete
      #             implementation in production floating around
      # <@dolphm>	 wchrisj: keystone just happens to be the one supported by openstack directly
      # <@dolphm>	 wchrisj: and if you look at the diablo release of keystone vs the essex release of
      #             keystone -- those were actually two completely different implementations from the ground up
      # <ayoung>	 wchrisj, we've stabilized somewhat from that point
      # <@dolphm>	 wchrisj: ++ i'd like it to be removed from openstack's api site since we don't support it directly
      # <@dolphm>	 wchrisj: you're not the only one to be confused by it :(
      # ---- 3/6/2014 ----

      ## Tenant Operations
      # http://docs.openstack.org/api/openstack-identity-service/2.0/content/Tenant_Operations.html
      request :list_tenants
      request :get_tenants_by_name
      request :get_tenants_by_id
      request :list_roles_for_user_on_tenant


      # Openstack Identity Service Extensions --------------------
      # http://docs.openstack.org/api/openstack-identity-service/2.0/content/openstack_identity_extensions.html

      ## User Operations
      # http://docs.openstack.org/api/openstack-identity-service/2.0/content/User_Operations_OS-KSADM.html
      request :list_users
      request :create_user
      request :update_user
      request :delete_user
      request :enable_user
      request :list_global_roles_for_user
      request :add_global_role_to_user
      request :delete_global_role_for_user
      request :add_credential_to_user
      request :update_credential_for_user
      request :delete_credential_for_user
      request :get_user_credentials

      ## Tenant Operations
      # http://docs.openstack.org/api/openstack-identity-service/2.0/content/Tenant_Operations_OS-KSADM.html
      request :create_tenant
      request :update_tenant
      request :delete_tenant
      request :list_users_for_tenant
      request :add_role_to_user_on_tenant
      request :delete_user_from_tenant

      ## Role Operations
      # http://docs.openstack.org/api/openstack-identity-service/2.0/content/Role_Operations_OS-KSADM.html
      request :list_roles
      request :create_role
      request :get_role
      request :delete_role

      ## Service Operations
      #http://docs.openstack.org/api/openstack-identity-service/2.0/content/Service_Operations_OS-KSADM.html


      # OS-KSCATALOG Admin Extension ------------------------------
      # http://docs.openstack.org/api/openstack-identity-service/2.0/content/Admin_API_Service_Developer_Operations-OS-KSCATALOG.html

      ## Endpoint Template Operations
      # http://docs.openstack.org/api/openstack-identity-service/2.0/content/Endpoint_Template_Operations_OS-KSCATALOG.html
      # request ???

      ## Endpoint Operations
      # http://docs.openstack.org/api/openstack-identity-service/2.0/content/Tenant_Operations_OS-KSCATALOG.html
      # request ???


      # OS-KSEC2 Admin Extension ----------------------------------
      # http://docs.openstack.org/api/openstack-identity-service/2.0/content/Admin_API_Service_Developer_Operations-OS-KSEC2.html

      ## User Operations
      request :list_ec2_credentials
      request :get_ec2_credential
      request :create_ec2_credential
      request :delete_ec2_credential


      # minimal requirement
      class Mock
      end

      class Real
        attr_reader :current_user, :current_tenant
        attr_reader :auth_token

        def initialize(options={})
          apply_options(options)
          authenticate
          connection_url = "#{@scheme}://#{@host}:#{@port}"
          @connection = Fog::Core::Connection.new(connection_url, @persistent, @connection_options)
        end

        def reload
          @connection.reset
        end

        def request(params)
          retried = false
          begin
            response = @connection.request(params.merge({
              :headers  => {
                'Content-Type' => 'application/json',
                'Accept' => 'application/json',
                'X-Auth-Token' => @auth_token
              }.merge!(params[:headers] || {}),
              :path     => "#{@base_path}#{params[:path]}"#,
            }))
          rescue Excon::Errors::Unauthorized => error
            raise if retried
            retried = true

            @openstack_must_reauthenticate = true
            authenticate
            retry
          rescue Excon::Errors::HTTPStatusError => error
            raise case error
            when Excon::Errors::NotFound
              Fog::Identity::OpenStackCommon::NotFound.slurp(error)
            else
              error
            end
          end
          unless response.body.empty?
            response.body = MultiJson.decode(response.body)
          end
          response
        end

        private

        def adapter
          @authenticator ||
          if @openstack_auth_uri.path =~ /v1(\.\d+)?/
            require_relative "./identity/adapters/authenticator_v1"
            Fog::OpenStackCommon::Authentication::Adapters::AuthenticatorV1
          else
            require_relative "./identity/adapters/authenticator_v2"
            Fog::OpenStackCommon::Authentication::Adapters::AuthenticatorV2
          end
        end

        def authenticate
          # puts "===== Fog::Identity::OpenStackCommon -> authenticate ====="
          if !@options[:openstack_management_url] || @openstack_must_reauthenticate
            credentials = adapter.authenticate(auth_options, @connection_options)
            handle_auth_results(credentials)
          else
            @auth_token = @openstack_auth_token
          end

          save_host_attributes
          credentials
        end

        def apply_options(options)
          @options = options.dup

          @openstack_auth_uri                  = URI.parse(options[:openstack_auth_url])
          @openstack_must_reauthenticate       = false
          @options[:openstack_service_type]  ||= ['identity']
          @options[:openstack_endpoint_type] ||= 'adminURL'
          @options[:connection_options]      ||= {}
          @options[:persistent]              ||= false
        end

        def auth_options
          { :openstack_api_key  => @openstack_api_key,
            :openstack_username => @openstack_username,
            :openstack_auth_token => @openstack_auth_token,
            :openstack_auth_uri => @openstack_auth_uri,
            :openstack_tenant   => @openstack_tenant,
            :openstack_service_type => @openstack_service_type,
            :openstack_service_name => @openstack_service_name,
            :openstack_endpoint_type => @openstack_endpoint_type
          }
        end

        def handle_auth_results(credentials={})
          @current_user = credentials[:user]
          @current_tenant = credentials[:tenant]
          @openstack_must_reauthenticate = false
          @auth_token = credentials[:token]
          @openstack_management_url = credentials[:server_management_url]
          @openstack_current_user_id = credentials[:current_user_id]
        end

        def save_host_attributes
          uri = URI.parse(@openstack_management_url)
          @host   = uri.host
          @base_path   = uri.path
          @base_path.sub!(/\/$/, '')
          @port   = uri.port
          @scheme = uri.scheme
          # puts "HOST: #{@host}"
          # puts "path: #{@base_path}"
          # puts "port: #{@port}"
          # puts "scheme: #{@scheme}"
        end
      end
    end
  end
end
