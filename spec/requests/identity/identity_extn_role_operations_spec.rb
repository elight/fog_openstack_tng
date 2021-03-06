require_relative '../../spec_helper'
require 'fog/openstackcommon'

describe Fog::Identity::OpenStackCommon::Real do

  let(:valid_options) { {
    :provider          => 'OpenStackCommon',
    :openstack_auth_url => "http://devstack.local:5000/v2.0/tokens",
    :openstack_username => "admin",
    :openstack_api_key => "stack"
  } }

  let(:service) { Fog::Identity.new(valid_options) }

  describe "#create_role", :vcr do

    let(:result) { service.create_role("azahabada#{Time.now.to_i}") }

    it "creates the role" do
      result.status.must_equal 200
    end

    it "returns valid data" do
      result.body['role'].wont_be_nil
    end

  end

  describe "#get_role_by_name" do
    it { skip("TBD") }
  end

  describe "#get_role" do
    it { skip("TBD") }
  end

  describe "#delete_role" do
    it { skip("TBD") }
  end

  describe "#list_roles" do
    it { skip("TBD") }
  end


end
