require 'fastlane/action'
require_relative '../helper/dingdingtalk_helper'


module Fastlane
  module Actions
    class DingdingtalkAction < Action

      def self.send_dingTalk(isAppStore, appPatch, appUrl, appIcon, dingTalkUrl)
        appName    = get_ipa_info_plist_value(ipa: appPatch, key: "CFBundleDisplayName")
        appVersion = get_ipa_info_plist_value(ipa: appPatch, key: "CFBundleShortVersionString")
        appBuild   = get_ipa_info_plist_value(ipa: appPatch, key: "CFBundleVersion")

        platformInfo = isAppStore == false ? "已更新至fir" : "已上传至AppStoreConnect"

        markdown =
        {
          msgtype: "link",
          link: {
              title: "iOS #{appName} #{appVersion} #{platformInfo}",
              text: "版  本：#{appBuild}\n地  址：#{appUrl}\n时  间：#{Time.new.strftime('%Y-%m-%d %H:%M')}",
              picUrl: "#{appIcon}",
              messageUrl: "#{appUrl}"
          }
        }
        uri = URI.parse(dingTalkUrl)
        https = Net::HTTP.new(uri.host, uri.port)
        https.use_ssl = true

        request = Net::HTTP::Post.new(uri.request_uri)
        request.add_field('Content-Type', 'application/json')
        request.body = markdown.to_json

        response = https.request(request)
        puts "-----------#{uri.request_uri}-------------------"
        puts "Response #{response.code} #{response.message}: #{response.body}"
      end

      def self.run(params)
        UI.message("The dingdingtalk plugin is working!")
        # UI.message("----------doing something--------------")
        # UI.message("The dingdingtalk plugin is finished!")

        params = {
                  isAppStore: false,
                  ipaDir: "/Users/shang/ECP/ecp-ios/firim",
                  ipaName: "ParkingWangCoupon",
                  appUrl: "https://fir.im/zk9r",
                  appIcon: "https://is1-ssl.mzstatic.com/image/thumb/Purple/v4/aa/2f/f1/aa2ff185-feca-4800-5bee-85e3406ac648/Icon-76@2x.png.png/75x9999bb.png",
                  dingTalkUrl: "https://oapi.dingtalk.com/robot/send?access_token=f5a84c40838aef49cbf38f511bf4fcc4b9bafd6e845b7e691edf1b2660576528"
                }
        # puts "-----------#{params}-------------------"

        send_dingTalk(
          params[:isAppStore],
          params[:ipaDir] + "/#{params[:ipaName]}.ipa",
          params[:appUrl],
          params[:appIcon],
          params[:dingTalkUrl]
        )

      end

      def self.description
        "钉钉"
      end

      def self.authors
        ["Shang"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.details
        # Optional:
        "钉钉通知"
      end

      def self.available_options
        [
          # FastlaneCore::ConfigItem.new(key: :your_option,
          #                         env_name: "DINGDINGTALK_YOUR_OPTION",
          #                      description: "A description of your option",
          #                         optional: false,
          #                             type: String)
        ]
      end

      def self.is_supported?(platform)
        # Adjust this if your plugin only works for a particular platform (iOS vs. Android, for example)
        # See: https://docs.fastlane.tools/advanced/#control-configuration-by-lane-and-by-platform
        #
        # [:ios, :mac, :android].include?(platform)
        true
      end
    end
  end
end
