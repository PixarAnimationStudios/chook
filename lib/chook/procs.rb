### Copyright 2017 Pixar

###
###    Licensed under the Apache License, Version 2.0 (the "Apache License")
###    with the following modification; you may not use this file except in
###    compliance with the Apache License and the following modification to it:
###    Section 6. Trademarks. is deleted and replaced with:
###
###    6. Trademarks. This License does not grant permission to use the trade
###       names, trademarks, service marks, or product names of the Licensor
###       and its affiliates, except as required to comply with Section 4(c) of
###       the License and to reproduce the content of the NOTICE file.
###
###    You may obtain a copy of the Apache License at
###
###        http://www.apache.org/licenses/LICENSE-2.0
###
###    Unless required by applicable law or agreed to in writing, software
###    distributed under the Apache License with the above modification is
###    distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
###    KIND, either express or implied. See the Apache License for the specific
###    language governing permissions and limitations under the Apache License.
###
###

###
module Chook

  # A namespace to hold Proc objects in constants
  module Procs

    TRUE_RE = /^\s*(true|yes)\s*$/i

    JSS_EPOCH_TO_TIME = proc { |val| Time.strptime val.to_s[0..-4], '%s' }

    STRING_TO_BOOLEAN = proc { |val| val =~ TRUE_RE ? true : false }

    STRING_TO_PATHNAME = proc { |val| Pathname.new val }

    STRING_TO_LOG_LEVEL = proc do |level|
      if (0..5).cover? level
        level
      else
        lvl = Chook::Server::Log::LOG_LEVELS[level.to_sym]
        lvl ? lvl : Logger::UNKNOWN
      end # if..else
    end

    ENV_FROM_CONFIG = proc do |envs|
      envs = envs.split /\s*,\s*/
      envs.each do |env|
        var, val = env.split '='
        ENV[var] = val
      end
      envs
    end

    MOBILE_USERID = proc { |_device| '-1' }

    PRODUCT = proc { |_device| nil }

    ALWAYS_TRUE = proc { |_boolean| true }

    COMPUTER_USERID = proc do |comp|
      id = '-1' unless comp.groups_accounts[:local_accounts].find { |acct| acct[:name] == comp.username }
      id.is_a?(Hash) ? id[:uid] : '-1'
    end # end proc do |comp|

  end # module Procs

end # module Chook
