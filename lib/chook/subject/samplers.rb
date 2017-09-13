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

    # # return a hash of all the data needed for a Computer Subject
    # # from a single random computer in the JSS.
    # def self.computer
    #   random_computer = JSS::Computer.fetch id: JSS::Computer.all_ids.sample
    #   hash = Chook::Subject.classes[Chook::Subject::COMPUTER].dup
    #   hash.each do |attrib, definition|
    #     hash[attrib] = case definition[:api_object_attribute]
    #                    when nil then nil
    #                    when Symbol then random_computer.send definition[:api_object_attribute]
    #                    when Array then random_computer.send(definition[:api_object_attribute][0])[definition[:api_object_attribute][1]]
    #                    end # case
    #   end # do k
    #   hash
    # end

    # Serial Number
    #
    # @param [JSS:MobileDevice or JSS::Computer] device_object JSS Mobile Device or Computer Object
    # @return [Type] Sampled Computer or Mobile Device Serial Number
    #
    def self.serial_number(device_object) # mobile = false)
      device_object.serial_number
      # if mobile
      #   JSS::MobileDevice.all_serial_numbers.sample
      # else
      #   JSS::Computer.all_serial_numbers.sample
      # end
    end # end serial_number

    # # Computer Serial Number (wrapper)
    # #
    # # @return [String] Sampled Computer Serial Number
    # #
    # def self.computer_serial_number
    #   serial_number
    # end # end computer_serial_number
    #
    # # Mobile Serial Number (wrapper)
    # #
    # # @return [String] Sampled Mobile Device Serial Number
    # #
    # def self.mobile_serial_number
    #   serial_number(true)
    # end # end mobile_serial_number

    # MAC Address Sampler
    #
    # @param [JSS:MobileDevice or JSS::Computer] device_object JSS Mobile Device or Computer Object
    # @return [String] A MAC Address sampled from a MobileDevice or Computer in the JSS
    #
    def self.mac_address(device_object) # mobile = false)
      if device_object.is_a? JSS::Computer
        device_object.mac_address
      else
        device_object.wifi_mac_address
      end
      # if mobile
      #   JSS::MobileDevice.all_wifi_mac_addresses.sample
      # else
      #   JSS::Computer.all_mac_addresses.sample
      # end
    end # end mac_address

    # # Computer MAC Address (wrapper)
    # #
    # # @return [String] A MAC Address sampled from a Computer in the JSS
    # #
    # def self.computer_mac_address
    #   mac_address
    # end # end computer_mac_address
    #
    # # Mobile MAC Address (wrapper)
    # #
    # # @return [String] A MAC Address sampled from a MobileDevice in the JSS
    # #
    # def self.mobile_mac_address
    #   mac_address(true)
    # end # end mobile_mac_address

    # UDID Sampler
    #
    # @param [JSS:MobileDevice or JSS::Computer] device_object JSS Mobile Device or Computer Object
    # @return [String] A UDID sampled from a MobileDevice or Computer in the JSS
    #
    def self.udid(device_object) # mobile = false)
      if device_object.is_a? JSS::Computer
        device_object.udid
      else
        device_object.uuid
      end
      # if mobile
      #   JSS::MobileDevice.all_udids.sample
      # else
      #   JSS::Computer.all_udids.sample
      # end
    end # end udid

    # # Mobile UDID (wrapper)
    # #
    # # @return [String] A UDID sampled from a MobileDevice in the JSS
    # #
    # def self.mobile_udid
    #   udid(true)
    # end # end mobile_udid
    #
    # # Computer UUID (wrapper)
    # #
    # # @return [String] A UUID sampled from a Computer in the JSS
    # #
    # def self.computer_udid
    #   udid
    # end # end computer_udid

    # IMEI Sampler
    #
    # @param [JSS:MobileDevice] device_object JSS Mobile Device Object
    # @return [String] An IMEI sampled from a MobileDevice in the JSS
    #
    def self.imei(mobile_device_object) # api: JSS.api)
      mobile_device_object.network[:imei]
      # imei = ''
      # i = 0
      # while imei.nil? || imei.empty?
      #   i += 1
      #   id = jssid(mobile: true)
      #   raw_subset = api.get_rsrc("mobiledevices/id/#{id}/subset/network")
      #   imei = raw_subset[:mobile_device][:network][:imei]
      #   if i > 3
      #     imei = 'Undefined'
      #     break
      #   end
      # end
      # imei
    end # end imei

    # ICCID Sampler
    #
    # @param [JSS:MobileDevice] device_object JSS Mobile Device Object
    # @return [String] An ICCID sampled from a MobileDevice in the JSS
    #
    def self.iccid(mobile_device_object) #api: JSS.api)
      mobile_device_object.network[:iccid]
      # iccid = ''
      # i = 0
      # while iccid.nil? || imei.empty?
      #   i += 1
      #   id = jssid(mobile: true)
      #   raw_subset = api.get_rsrc("mobiledevices/id/#{id}/subset/network")
      #   iccid = raw_subset[:mobile_device][:network][:iccid]
      #   if i > 3
      #     iccid = 'Undefined'
      #     break
      #   end
      # end
      # iccid
    end # end iccid

    # Version
    #
    # @param [JSS::APIConnection] API Connection object
    # @return [String] Carrier Version String
    #
    def self.version(mobile_device_object) # api: JSS.api)
      mobile_device_object.network[:carrier_settings_version]
      # id = jssid(mobile: true)
      # raw_subset = api.get_rsrc("mobiledevices/id/#{id}/subset/network")
      # raw_subset[:mobile_device][:network][:carrier_settings_version] || ''
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
    # AURICA This can probably just be aliased to the model method...
    # @param [JSS:MobileDevice] device_object JSS Mobile Device Object
    # @return [String] Mobile Device Model String
    #
    def self.model_display(mobile_device_object) # , api: JSS.api)
      mobile_device_object.model_display
      # id = jssid(mobile: true)
      # raw_subset = api.get_rsrc("mobiledevices/id/#{id}/subset/general")
      # raw_subset[:mobile_device][:general][:model_display]
    end # end model_display

    # JSS ID Sampler
    #
    # @param [JSS:MobileDevice or JSS::Computer] device_object JSS Mobile Device or Computer Object
    # @return [Integer] A JSS ID sampled from a MobileDevice or Computer in the JSS
    #
    def self.jssid(device_object) # mobile = false)
      device_object.id
      # if mobile
      #   all_mobile = JSS::MobileDevice.all
      #   all_mobile.map { |i| i[:id] }.sample.to_i
      # else
      #   all_computer = JSS::Computer.all
      #   all_computer.map { |i| i[:id] }.sample.to_i
      # end
    end # end jssid

    # # All Mobile JSS IDs
    # #
    # # @return [Array<Integer>] All MobileDevice IDs from the JSS
    # #
    # def self.all_mobile_jssids
    #   JSS::MobileDevice.all_ids
    # end # end mobile_jssid
    #
    # # Mobile JSS ID
    # #
    # # @return [Integer] A MobileDevice ID from the JSS
    # #
    # def self.mobile_jssid
    #   all_mobile_jssids.sample
    # end # end mobile_jssid

    # # All Computer JSS IDs
    # #
    # # @return [Array<Integer>] All Computer IDs from the JSS
    # #
    # def self.all_computer_jssids
    #   JSS::Computer.all_ids
    # end # end computer_jssid
    #
    # # A Computer JSS ID
    # #
    # # @return [Integer] A Computer ID from the JSS
    # #
    # def self.computer_jssid
    #   all_computer_jssids.sample
    # end # end computer_jssid

    # OS Build Sampler
    #
    # @param [JSS:MobileDevice or JSS::Computer] device_object JSS Mobile Device or Computer Object
    # @return [String] Operating System Build from a MobileDevice or Computer in the JSS
    #
    def self.os_build(device_object) # mobile = false, api: JSS.api)
      if device_object.is_a? JSS::Computer
        device_object.hardware[:os_build]
      else
        device_object.os_build
      end
      # if mobile
      #   id = jssid(mobile: true)
      #   raw_subset = api.get_rsrc("mobiledevices/id/#{id}/subset/general")
      #   raw_subset[:mobile_device][:general][:os_build]
      # else
      #   id = jssid
      #   raw_os = api.get_rsrc("computers/id/#{id}/subset/hardware")
      #   raw_os[:computer][:hardware][:os_build]
      # end
    end # end os_build

    # # Mobile OS Build (wrapper)
    # #
    # # @return [String] Operating System build from a MobileDevice in the JSS
    # #
    # def self.mobile_os_build
    #   os_build(true)
    # end # end mobile_os_build
    #
    # # Computer OS build (wrapper)
    # #
    # # @return [String] Operating System build from a Computer in the JSS
    # #
    # def self.computer_os_build
    #   os_build
    # end # end computer_os_build

    # OS Version Sampler
    #
    # @param [JSS:MobileDevice or JSS::Computer] device_object JSS Mobile Device or Computer Object
    # @return [String] Operating System Version from a MobileDevice or Computer in the JSS
    #
    def self.os_version(device_object) # mobile = false, api: JSS.api)
      if device_object.is_a? JSS::Computer
        device_object.hardware[:os_version]
      else
        device_object.os_version
      end
      # if mobile
      #   id = jssid(mobile: true)
      #   raw_subset = api.get_rsrc("mobiledevices/id/#{id}/subset/general")
      #   raw_subset[:mobile_device][:general][:os_version]
      # else
      #   id = jssid
      #   raw_os = api.get_rsrc("computers/id/#{id}/subset/hardware")
      #   raw_os[:computer][:hardware][:os_version]
      # end
    end # end os_version

    # # Mobile OS Version (wrapper)
    # #
    # # @return [String] Operating System Version from a MobileDevice in the JSS
    # #
    # def self.mobile_os_version
    #   os_version(true)
    # end # end mobile_os_version
    #
    # # Computer OS Version (wrapper)
    # #
    # # @return [String] Operating System Version from a Computer in the JSS
    # #
    # def self.computer_os_version
    #   os_version
    # end # end computer_os_version

    # Device Name Sampler
    #
    # @param [JSS:MobileDevice or JSS::Computer] device_object JSS Mobile Device or Computer Object
    # @return [String] A name sampled from a MobileDevice or Computer in the JSS
    #
    def self.device_name(device_object) # mobile = false)
      device_object.name
      # if mobile
      #   all_mobile = JSS::MobileDevice.all
      #   all_mobile.map { |i| i[:name] }.sample
      # else
      #   all_computer = JSS::Computer.all
      #   all_computer.map { |i| i[:name] }.sample
      # end
    end # end device_name

    # # Computer Device Name Sampler (wrapper)
    # #
    # # @return [String] A name sampled from a Computer in the JSS
    # #
    # def self.computer_device_name
    #   device_name
    # end # end computer_device_name
    #
    # # Mobile Device Name Sampler (wrapper)
    # #
    # # @return [String] A name sampled from a MobileDevice in the JSS
    # #
    # def self.mobile_device_name
    #   device_name(true)
    # end # end mobile_device_name

    # Model Sampler
    #
    # @param [JSS:MobileDevice or JSS::Computer] device_object JSS Mobile Device or Computer Object
    # @return [String] A model sampled from a MobileDevice or Computer in the JSS
    #
    def self.model(device_object) # mobile = false)
      if device_object.is_a? JSS::Computer
        device_object.hardware[:model]
      else
        device_object.model
      end
      # if mobile
      #   all_mobile = JSS::MobileDevice.all
      #   all_mobile.map { |i| i[:model] }.sample
      # else
      #   all_computer = JSS::Computer.all
      #   all_computer.map { |i| i[:model] }.sample
      # end
    end # end model

    # # Mobile Model (wrapper)
    # #
    # # @return [String] A model sampled from a MobileDevice in the JSS
    # #
    # def self.mobile_model
    #   model(true)
    # end # end mobile_model
    #
    # # Computer Model (wrapper)
    # #
    # # @return [String] A model sampled from a Computer in the JSS
    # #
    # def self.computer_model
    #   model
    # end # end computer_model

    # Username Sampler
    #
    # @param [JSS:MobileDevice or JSS::Computer] device_object JSS Mobile Device or Computer Object
    # @return [String] A username sampled from a MobileDevice or Computer in the JSS
    #
    def self.username(device_object) # mobile = false)
      device_object.username
      # if mobile
      #   all_mobile = JSS::MobileDevice.all
      #   all_mobile.map { |i| i[:username] }.sample
      # else
      #   all_computer = JSS::Computer.all
      #   all_computer.map { |i| i[:username] }.sample
      # end
    end # end username

    # # Mobile Username (wrapper)
    # #
    # # @return [String] A username sampled from a MobileDevice in the JSS
    # #
    # def self.mobile_username
    #   username(true)
    # end # end mobile_username
    #
    # # Computer Username (wrapper)
    # #
    # # @return [String] A username sampled from a Computer in the JSS
    # #
    # def self.computer_username
    #   username
    # end # end computer_username

    # User Directory ID Sampler
    #
    # @param [JSS::Computer] computer_object JSS Computer Object
    # @return [Integer] A randomly sampled uid from a Computer in the JSS
    #
    def self.user_directory_id(computer_object) # api: JSS.api)
      an_account = computer_object.groups_accounts[:local_accounts].sample
      # id = jssid
      # # TODO: Benchmark get_rsrc and Computer object instantiation, use the most efficient
      # raw_groups_acccounts = api.get_rsrc("computers/id/#{id}/subset/groups_accounts")
      # an_account = raw_groups_acccounts[:computer][:groups_accounts][:local_accounts].sample
      return '-1' if an_account.empty?
      an_account[:uid]
    end # end user_directory_id

    # Real Name Sampler
    #
    # @param [JSS:MobileDevice or JSS::Computer] device_object JSS Mobile Device or Computer Object
    # @return [String] A real name from a Computer or MobileDevice in the JSS
    #
    def self.real_name(device_object) # api: JSS.api)
      device_object.real_name
      # real_name = ''
      # i = 0
      # while real_name.nil? || real_name.empty?
      #   i += 1
      #   mobile_or_computer = rand(0..1)
      #   id = jssid(mobile_or_computer)
      #   if mobile_or_computer == false
      #     raw_location = api.get_rsrc("computers/id/#{id}/subset/location")
      #     real_name = raw_location[:computer][:location][:real_name]
      #   else
      #     raw_location = api.get_rsrc("mobiledevices/id/#{id}/subset/location")
      #     real_name = raw_location[:mobile_device][:location][:real_name]
      #   end
      #   if i > 3
      #     real_name = 'Undefined'
      #     break
      #   end
      # end
      # real_name
    end # end real_name

    # Email Address Sampler
    #
    # @param [JSS:MobileDevice or JSS::Computer] device_object JSS Mobile Device or Computer Object
    # @return [String] An email address from a Computer or MobileDevice in the JSS
    #
    def self.email_address(device_object) # api: JSS.api)
      device_object.email_address
      # email_address = ''
      # i = 0
      # while email_address.nil? || email_address.empty?
      #   i += 1
      #   mobile_or_computer = rand(0..1)
      #   id = jssid(mobile_or_computer)
      #   if mobile_or_computer == false
      #     raw_location = api.get_rsrc("computers/id/#{id}/subset/location")
      #     email_address = raw_location[:computer][:location][:email_address]
      #   else
      #     raw_location = api.get_rsrc("mobiledevices/id/#{id}/subset/location")
      #     email_address = raw_location[:mobile_device][:location][:email_address]
      #   end
      #   if i > 3
      #     email_address = 'Undefined'
      #     break
      #   end
      # end
      # email_address
    end # end email_address

    # Phone Sampler
    #
    # @param [JSS:MobileDevice or JSS::Computer] device_object JSS Mobile Device or Computer Object
    # @return [String] A phone number from a Computer or MobileDevice in the JSS
    #
    def self.phone(device_object) # api: JSS.api)
      device_object.phone
      # phone = ''
      # i = 0
      # while phone.nil? || phone.empty?
      #   i += 1
      #   mobile_or_computer = rand(0..1)
      #   id = jssid(mobile_or_computer)
      #   if mobile_or_computer == false
      #     raw_location = api.get_rsrc("computers/id/#{id}/subset/location")
      #     phone = raw_location[:computer][:location][:phone]
      #   else
      #     raw_location = api.get_rsrc("mobiledevices/id/#{id}/subset/location")
      #     phone = raw_location[:mobile_device][:location][:phone]
      #   end
      #   if i > 3
      #     phone = 'Undefined'
      #     break
      #   end
      # end
      # phone
    end # end phone

    # Position Sampler
    #
    # @param [JSS:MobileDevice or JSS::Computer] device_object JSS Mobile Device or Computer Object
    # @return [String] A position from a Computer or MobileDevice in the JSS
    #
    def self.position(device_object) # api: JSS.api)
      device_object.position
      # position = ''
      # i = 0
      # while position.nil? || position.empty?
      #   i += 1
      #   mobile_or_computer = rand(0..1)
      #   id = jssid(mobile_or_computer)
      #   if mobile_or_computer == false
      #     raw_location = api.get_rsrc("computers/id/#{id}/subset/location")
      #     position = raw_location[:computer][:location][:position]
      #   else
      #     raw_location = api.get_rsrc("mobiledevices/id/#{id}/subset/location")
      #     position = raw_location[:mobile_device][:location][:position]
      #   end
      #   if i > 3
      #     position = 'Undefined'
      #     break
      #   end
      # end
      # position
    end # end position

    # Department Sampler
    #
    # @param [JSS:MobileDevice or JSS::Computer] device_object JSS Mobile Device or Computer Object
    # @return [String] A department from a Computer or MobileDevice in the JSS
    #
    def self.department(device_object) # api: JSS.api)
      device_object.department
      # department = ''
      # i = 0
      # while department.nil? || department.empty?
      #   i += 1
      #   mobile_or_computer = rand(0..1)
      #   id = jssid(mobile_or_computer)
      #   if mobile_or_computer == false
      #     raw_location = api.get_rsrc("computers/id/#{id}/subset/location")
      #     department = raw_location[:computer][:location][:department]
      #   else
      #     raw_location = api.get_rsrc("mobiledevices/id/#{id}/subset/location")
      #     department = raw_location[:mobile_device][:location][:department]
      #   end
      #   if i > 3
      #     department = 'Undefined'
      #     break
      #   end
      # end
      # department
    end # end department

    # Building Sampler
    #
    # @param [JSS:MobileDevice or JSS::Computer] device_object JSS Mobile Device or Computer Object
    # @return [String] A building from a Computer or MobileDevice in the JSS
    #
    def self.building(device_object) # api: JSS.api)
      if device_object.is_a? JSS::Computer
        device_object.building
      else
        device_object.location[:building]
      end
      # building = ''
      # i = 0
      # while building.nil? || building.empty?
      #   i += 1
      #   mobile_or_computer = rand(0..1)
      #   id = jssid(mobile_or_computer)
      #   if mobile_or_computer == false
      #     raw_location = api.get_rsrc("computers/id/#{id}/subset/location")
      #     puts raw_location
      #     building = raw_location[:computer][:location][:building]
      #   else
      #     raw_location = api.get_rsrc("mobiledevices/id/#{id}/subset/location")
      #     puts raw_location
      #     building = raw_location[:mobile_device][:location][:building]
      #   end
      #   if i > 3
      #     building = 'Undefined'
      #     break
      #   end
      # end
      # building
    end # end building

    # Room Sampler
    #
    # @param [JSS:MobileDevice or JSS::Computer] device_object JSS Mobile Device or Computer Object
    # @return [String] A room from a Computer or MobileDevice in the JSS
    #
    def self.room(device_object) # api: JSS.api)
      device_object.room
      # room = ''
      # i = 0
      # while room.nil? || room.empty?
      #   i += 1
      #   mobile_or_computer = rand(0..1)
      #   id = jssid(mobile_or_computer)
      #   if mobile_or_computer == false
      #     raw_location = api.get_rsrc("computers/id/#{id}/subset/location")
      #     room = raw_location[:computer][:location][:room]
      #   else
      #     raw_location = api.get_rsrc("mobiledevices/id/#{id}/subset/location")
      #     room = raw_location[:mobile_device][:location][:room]
      #   end
      #   if i > 3
      #     room = 'Undefined'
      #     break
      #   end
      # end
      # room
    end # end room

    # SmartGroup

    # Smart Group Sampler
    #
    # @param [JSS::APIConnection] API Connection object
    # @return [String] A Smart Group name from the JSS
    #
    def self.smart_group(mobile = false, api: JSS.api)
      if mobile
        raw_mobile_groups = api.get_rsrc('mobiledevicegroups')
        smart_groups = raw_mobile_groups[:mobile_device_groups].select { |group| group[:is_smart] == true }
      else
        raw_computer_groups = api.get_rsrc('computergroups')
        smart_groups = raw_computer_groups[:computer_groups].select { |group| group[:is_smart] == true }
      end
      smart_groups.sample[:name]
    end # end smart_group

    # Smart Group ID Sampler
    #
    # @param [Boolean] mobile Set to true to indicate MobileDevice vs. Computer
    # @return [Integer] The ID # of a MobileDevice or Computer Smart Group from JSS
    #
    def self.smart_group_jssid(mobile = false, api: JSS.api)
      if mobile
        all_mobile_smart = JSS::MobileDeviceGroup.all_smart(true, api: api)
        all_mobile_smart.map { |i| i[:id] }.sample.to_i
      else
        all_computer_smart = JSS::ComputerGroup.all_smart(true, api: api)
        all_computer_smart.map { |i| i[:id] }.sample.to_i
      end
    end # end group_jssid

    # Computer Smart Group ID (wrapper)
    #
    # @return [Integer] The ID # of a Computer Smart Group from JSS
    #
    def self.computer_smart_group_jssid
      smart_group_jssid
    end # end computer_smart_group_id

    # Mobile Device Smart Group ID (wrapper)
    #
    # @return [Integer] The ID # of a MobileDevice Smart Group from JSS
    #
    def self.mobile_smart_group_jssid
      smart_group_jssid(true)
    end # end mobile_smart_group_id

    # Any Smart Group ID (wrapper)
    #
    # @return [Integer] The ID # of a MobileDevice or Computer Smart Group from JSS
    #
    def self.any_smart_group_jssid
      [computer_smart_group_jssid, mobile_smart_group_jssid].sample
    end # end any_smart_group_id

    # PatchSoftwareTitleUpdated

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

    def self.patch_report_url(_patch_hash, api: JSS.api)
      api.rest_url
    end # end patch_report_url

    # Patch Name Sampler
    #
    # @param [Hash] raw_patch Hash of output from API query like get_rsrc("patches/id/#{id}")
    # @return [String] A Patch Reporting Software Title Name
    #
    def self.patch_name(raw_patch) # , api: JSS.api)
      raw_patch[:software_title][:name]
      # all_titles = api.get_rsrc('patches')[:patch_reporting_software_titles]
      # if id.nil?
      #   all_titles.sample[:name]
      # else
      #   all_titles.select { |title| title[:id] == id }[0][:name]
      # end
    end # end patch_name

    # Patch Latest Version
    #
    # @param [Hash] raw_patch Hash of output from API query like get_rsrc("patches/id/#{id}")
    # @return [String] The lastest version of a patch software title
    #
    def self.patch_latest_version(raw_patch) # api: JSS.api)
      raw_patch[:software_title][:versions].select { |i| i.is_a? String }.first
      # all_titles = api.get_rsrc('patches')[:patch_reporting_software_titles]
      # id = all_titles.sample[:id].to_i if id.nil?
      # raw_patch = api.get_rsrc("patches/id/#{id}")
      # raw_patch[:software_title][:versions].select { |i| i.is_a? String }.first
    end # end patch_latest_version

  end # module samplers

end # module Chook
