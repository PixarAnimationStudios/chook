require 'jss'

module Chook

  # A namespace for holding Constants and methods for
  # pulling sample data from a JSS for use with Test events and test subjects
  module Samplers

    # Institution Sampler
    #
    # @param [JSS::APIConnection] API Connection object
    # @return [String] The name of the JSS's Organization Name
    #
    def self.institution(api: JSS.api)
      api.get_rsrc('activationcode')[:activation_code][:organization_name]
    end # end institution

    # Serial Number
    #
    # @param [JSS:MobileDevice or JSS::Computer] device_object JSS Mobile Device or Computer Object
    # @return [Type] Sampled Computer or Mobile Device Serial Number
    #
    def self.serial_number(device_object)
      device_object.serial_number
    end # end serial_number

    # MAC Address Sampler
    #
    # @param [JSS:MobileDevice or JSS::Computer] device_object JSS Mobile Device or Computer Object
    # @return [String] A MAC Address sampled from a MobileDevice or Computer in the JSS
    #
    def self.mac_address(device_object)
      if device_object.is_a? JSS::Computer
        device_object.mac_address
      else
        device_object.wifi_mac_address
      end
    end # end mac_address

    # UDID Sampler
    #
    # @param [JSS:MobileDevice or JSS::Computer] device_object JSS Mobile Device or Computer Object
    # @return [String] A UDID sampled from a MobileDevice or Computer in the JSS
    #
    def self.udid(device_object)
      if device_object.is_a? JSS::Computer
        device_object.udid
      else
        device_object.uuid
      end
    end # end udid

    # IMEI Sampler
    #
    # @param [JSS:MobileDevice] device_object JSS Mobile Device Object
    # @return [String] An IMEI sampled from a MobileDevice in the JSS
    #
    def self.imei(mobile_device_object)
      mobile_device_object.network[:imei]
    end # end imei

    # ICCID Sampler
    #
    # @param [JSS:MobileDevice] device_object JSS Mobile Device Object
    # @return [String] An ICCID sampled from a MobileDevice in the JSS
    #
    def self.iccid(mobile_device_object)
      mobile_device_object.network[:iccid]
    end # end iccid

    # Version
    #
    # @param [JSS::APIConnection] API Connection object
    # @return [String] Carrier Version String
    #
    def self.version(mobile_device_object)
      mobile_device_object.network[:carrier_settings_version]
    end # end version

    # Product
    # is always nil in the sample JSONs... And there isn't anything labeled "product" in api.get_rsrc("mobiledevices/id/#{id}")
    #
    # @return [NilClass] nil
    #
    def self.product
      nil
    end # end product

    # Model Display
    # @param [JSS:MobileDevice] device_object JSS Mobile Device Object
    # @return [String] Mobile Device Model String
    #
    def self.model_display(mobile_device_object)
      mobile_device_object.model_display
    end # end model_display

    # JSS ID Sampler
    #
    # @param [JSS:MobileDevice or JSS::Computer] device_object JSS Mobile Device or Computer Object
    # @return [Integer] A JSS ID sampled from a MobileDevice or Computer in the JSS
    #
    def self.jssid(device_object)
      device_object.id
    end # end jssid

    # OS Build Sampler
    #
    # @param [JSS:MobileDevice or JSS::Computer] device_object JSS Mobile Device or Computer Object
    # @return [String] Operating System Build from a MobileDevice or Computer in the JSS
    #
    def self.os_build(device_object)
      if device_object.is_a? JSS::Computer
        device_object.hardware[:os_build]
      else
        device_object.os_build
      end
    end # end os_build

    # OS Version Sampler
    #
    # @param [JSS:MobileDevice or JSS::Computer] device_object JSS Mobile Device or Computer Object
    # @return [String] Operating System Version from a MobileDevice or Computer in the JSS
    #
    def self.os_version(device_object)
      if device_object.is_a? JSS::Computer
        device_object.hardware[:os_version]
      else
        device_object.os_version
      end
    end # end os_version

    # Device Name Sampler
    #
    # @param [JSS:MobileDevice or JSS::Computer] device_object JSS Mobile Device or Computer Object
    # @return [String] A name sampled from a MobileDevice or Computer in the JSS
    #
    def self.device_name(device_object)
      device_object.name
    end # end device_name

    # Model Sampler
    #
    # @param [JSS:MobileDevice or JSS::Computer] device_object JSS Mobile Device or Computer Object
    # @return [String] A model sampled from a MobileDevice or Computer in the JSS
    #
    def self.model(device_object)
      if device_object.is_a? JSS::Computer
        device_object.hardware[:model]
      else
        device_object.model
      end
    end # end model

    # Username Sampler
    #
    # @param [JSS:MobileDevice or JSS::Computer] device_object JSS Mobile Device or Computer Object
    # @return [String] A username sampled from a MobileDevice or Computer in the JSS
    #
    def self.username(device_object)
      device_object.username
    end # end username

    # User Directory ID Sampler
    #
    # @param [JSS::Computer] computer_object JSS Computer Object
    # @return [Integer] A randomly sampled uid from a Computer in the JSS
    #
    def self.user_directory_id(computer_object)
      an_account = computer_object.groups_accounts[:local_accounts].sample
      return '-1' if an_account.empty?
      an_account[:uid]
    end # end user_directory_id

    # Real Name Sampler
    #
    # @param [JSS:MobileDevice or JSS::Computer] device_object JSS Mobile Device or Computer Object
    # @return [String] A real name from a Computer or MobileDevice in the JSS
    #
    def self.real_name(device_object)
      device_object.real_name
    end # end real_name

    # Email Address Sampler
    #
    # @param [JSS:MobileDevice or JSS::Computer] device_object JSS Mobile Device or Computer Object
    # @return [String] An email address from a Computer or MobileDevice in the JSS
    #
    def self.email_address(device_object)
      device_object.email_address
    end # end email_address

    # Phone Sampler
    #
    # @param [JSS:MobileDevice or JSS::Computer] device_object JSS Mobile Device or Computer Object
    # @return [String] A phone number from a Computer or MobileDevice in the JSS
    #
    def self.phone(device_object)
      device_object.phone
    end # end phone

    # Position Sampler
    #
    # @param [JSS:MobileDevice or JSS::Computer] device_object JSS Mobile Device or Computer Object
    # @return [String] A position from a Computer or MobileDevice in the JSS
    #
    def self.position(device_object)
      device_object.position
    end # end position

    # Department Sampler
    #
    # @param [JSS:MobileDevice or JSS::Computer] device_object JSS Mobile Device or Computer Object
    # @return [String] A department from a Computer or MobileDevice in the JSS
    #
    def self.department(device_object)
      device_object.department
    end # end department

    # Building Sampler
    #
    # @param [JSS:MobileDevice or JSS::Computer] device_object JSS Mobile Device or Computer Object
    # @return [String] A building from a Computer or MobileDevice in the JSS
    #
    def self.building(device_object)
      if device_object.is_a? JSS::Computer
        device_object.building
      else
        device_object.location[:building]
      end
    end # end building

    # Room Sampler
    #
    # @param [JSS:MobileDevice or JSS::Computer] device_object JSS Mobile Device or Computer Object
    # @return [String] A room from a Computer or MobileDevice in the JSS
    #
    def self.room(device_object)
      device_object.room
    end # end room

    #### SmartGroup

    # Smart Group Sampler
    #
    # @param [JSS:MobileDevice or JSS::Computer] device_object JSS Mobile Device or Computer Object
    # @return [String] A Smart Group name from the JSS
    #
    # def self.smart_group(device_object)
    #   if device_object.is_a? JSS::Computer
    #     device_object.smart_groups[:smart_groups].sample[:name]
    #   elsif device_object.is_a? JSS::MobileDevice
    #     device_object.mobile_device_groups.sample[:name]
    #   else
    #     ''
    #   end # if device_object.is_a? JSS::Computer
    # end # end smart_group

    # Smart Group ID Sampler
    #
    # @param [JSS:MobileDevice or JSS::Computer] device_object JSS Mobile Device or Computer Object
    # @return [Integer] The ID # of a MobileDevice or Computer Smart Group from JSS
    #
    # def self.smart_group_jssid(device_object)
    #   if device_object.is_a? JSS::Computer
    #     device_object.smart_groups[:smart_groups].sample[:id]
    #   elsif device_object.is_a? JSS::MobileDevice
    #     device_object.mobile_device_groups.sample[:id]
    #   else
    #     0
    #   end # if device_object.is_a? JSS::Computer
    # end # end group_jssid

    def self.smart_group_type(device_object)
      if device_object.is_a? JSS::Computer
        true
      elsif device_object.is_a? JSS::MobileDevice
        false
      end # if device_object.is_a? JSS::Computer
    end

    # Any Smart Group ID (wrapper)
    #
    # @return [Integer] The ID # of a MobileDevice or Computer Smart Group from JSS
    #
    # def self.any_smart_group_jssid
    #   [computer_smart_group_jssid, mobile_smart_group_jssid].sample
    # end # end any_smart_group_id

    #### PatchSoftwareTitleUpdated

    # Patch ID Sampler
    #
    # @param [JSS::APIConnection] API Connection object
    # @return [Integer] An enabled Patch Reporting Software ID from the JSS
    #
    def self.patch_id(_patch_hash, api: JSS.api)
      all_patch_ids(api).sample.to_i
    end # end patch_id

    # All Patch IDs
    #
    # @param [JSS::APIConnection] API Connection object
    # @return [Array<Integer>] An Array of enabled Patch Reporting Software IDs from the JSS
    #
    def self.all_patch_ids(_patch_hash, api: JSS.api)
      all_patches = api.get_rsrc('patches')[:patch_reporting_software_titles]
      all_ids = []
      all_patches.each { |patch| all_ids << patch[:id] }
      raise 'No Patch Reporting Software Titles found' if all_ids.empty?
      all_ids
    end # end all_patch_ids

    # Patch Last Update Sampler
    #
    # @return [Time] A Time for a Patch, since they can't be sampled via the API.
    #
    def self.patch_last_update(_patch_hash)
      Time.now
    end # end patch_last_update

    # Patch Report URL
    #
    # @param [JSS::APIConnection] API Connection object
    # @return [String] description of returned object
    #
    def self.patch_report_url(_patch_hash, api: JSS.api)
      api.rest_url.chomp('/JSSResource')
    end # end patch_report_url

    # All Patches
    #
    # @param [JSS::APIConnection] API Connection object
    # @return [Array<Hash>] Array of Hashes containing ids and names of enabled Patches
    #
    def self.all_patches(api: JSS.api)
      api.get_rsrc('patches')[:patch_reporting_software_titles]
    end # end all_patches

    # Patch Name Sampler
    #
    # @param [Hash] raw_patch Hash of output from API query like get_rsrc("patches/id/#{id}")
    # @return [String] A Patch Reporting Software Title Name
    #
    def self.patch_name(raw_patch) # , api: JSS.api)
      raw_patch[:software_title][:name]
    end # end patch_name

    # Patch Latest Version
    #
    # @param [Hash] raw_patch Hash of output from API query like get_rsrc("patches/id/#{id}")
    # @return [String] The lastest version of a patch software title
    #
    def self.patch_latest_version(raw_patch, api: JSS.api)
      patch = api.get_rsrc("patches/id/#{raw_patch[:id]}")
      patch[:software_title][:versions].select { |i| i.is_a? String }.first
    end # end patch_latest_version

  end # module samplers

end # module Chook
