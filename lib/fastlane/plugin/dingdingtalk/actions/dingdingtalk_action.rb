require 'fastlane/action'
require_relative '../helper/dingdingtalk_helper'


module Fastlane
  module Actions
    class DingdingtalkAction < Action

      def self.send_dingTalk(appPath: appPath, appUrl: appUrl, appIcon: appIcon, dingUrl: dingUrl)
        appName    = get_ipa_info_plist_value(ipa: appPath, key: "CFBundleDisplayName")
        appVersion = get_ipa_info_plist_value(ipa: appPath, key: "CFBundleShortVersionString")
        appBuild   = get_ipa_info_plist_value(ipa: appPath, key: "CFBundleVersion")

        platformInfo = appPath.include?("fir") == true ? "已更新至fir" : "已上传至AppStoreConnect"

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
        uri = URI.parse(dingUrl)
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
                  ipaDir: "/Users/shang/ECP/ecp-ios/firim",
                  ipaName: "ParkingWangCoupon",
                  appUrl: "https://fir.im/zk9r",
                  appIcon: "https://is1-ssl.mzstatic.com/image/thumb/Purple/v4/aa/2f/f1/aa2ff185-feca-4800-5bee-85e3406ac648/Icon-76@2x.png.png/75x9999bb.png",
                  dingUrl: "https://oapi.dingtalk.com/robot/send?access_token=f5a84c40838aef49cbf38f511bf4fcc4b9bafd6e845b7e691edf1b2660576528"
                }
        # puts "-----------#{params}-------------------"

        send_dingTalk(
          params[:ipaDir] + "/#{params[:ipaName]}.ipa",
          params[:appUrl],
          params[:appIcon],
          params[:dingUrl]
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
          FastlaneCore::ConfigItem.new(key: :ipaDir,
                                description: "ipa文件所在的文件夹路径",
                                   optional: false,
                                       type: String),
           FastlaneCore::ConfigItem.new(key: :ipaName,
                                description: "ipa文件名称",
                                   optional: false,
                                       type: String),
           # FastlaneCore::ConfigItem.new(key: :appPath,
           #                      description: "ipa文件路径",
           #                         optional: false,
           #                             type: String),
           FastlaneCore::ConfigItem.new(key: :appUrl,
                                description: "fir的ipa文件下载网址",
                                   optional: false,
                                       type: String),
           FastlaneCore::ConfigItem.new(key: :appIcon,
                                description: "ipa图标网络地址",
                                   optional: false,
                                       type: String),
           FastlaneCore::ConfigItem.new(key: :dingUrl,
                                description: "钉钉机器人网络接口",
                                   optional: false,
                                       type: String),
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
