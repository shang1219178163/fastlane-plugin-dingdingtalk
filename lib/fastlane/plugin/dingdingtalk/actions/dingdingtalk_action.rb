require 'fastlane/action'
require_relative '../helper/dingdingtalk_helper'

module Fastlane
  module Actions
    class DingdingtalkAction < Action

      def self.send_dingTalk(appPath, appUrl, appIcon, dingUrl, markdownText = nil)
        appName    = other_action.get_ipa_info_plist_value(ipa: appPath, key: "CFBundleDisplayName")
        appVersion = other_action.get_ipa_info_plist_value(ipa: appPath, key: "CFBundleShortVersionString")
        appBuild   = other_action.get_ipa_info_plist_value(ipa: appPath, key: "CFBundleVersion")

        appName = appName.empty? == false ? appName : other_action.get_ipa_info_plist_value(ipa: appPath, key: "CFBundleBundleName")

        platformInfo = appPath.include?("fir") == true ? "已更新至fir" : "已上传至AppStoreConnect"

        title = "iOS #{appName} #{appVersion} #{platformInfo}"

        markdown =
        {
          msgtype: "link",
          link: {
              title: title,
              text: "版  本：#{appBuild}\n地  址：#{appUrl}\n时  间：#{Time.new.strftime('%Y-%m-%d %H:%M')}",
              picUrl: "#{appIcon}",
              messageUrl: "#{appUrl}"
          }
        }

        if markdownText
          markdownText = "#{markdownText}   \n  - [下载地址](#{appUrl})"
          puts markdownText

          markdown ={
               "msgtype": "markdown",
               "markdown": {"title": "#{title}",
                            "text": "### #{title}\n#{markdownText}",
               }
           }
        end


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

        # params = {
        #           ipaDir: "/Users/shang/ECP/ecp-ios/firim",
        #           ipaName: "*",
        #           appUrl: "fir的app下载网址",
        #           appIcon: "appStore中app图标网址",
        #           dingUrl: "钉钉机器人"
        #         }
        # puts "-----------#{params}-------------------"

        send_dingTalk(
          params[:ipaDir] + "/#{params[:ipaName]}.ipa",
          params[:appUrl],
          params[:appIcon],
          params[:dingUrl],
          params[:markdownText]

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
                                   env_name: "GET_IPA",
                                description: "ipa文件所在的文件夹路径",
                                   optional: false,
                                       type: String),
           FastlaneCore::ConfigItem.new(key: :appUrl,
                                description: "fir的ipa文件下载网址",
                                   optional: false,
                                       type: String),
           FastlaneCore::ConfigItem.new(key: :appIcon,
                                description: "ipa图标网络地址",
                                   optional: true,
                                       type: String),
           FastlaneCore::ConfigItem.new(key: :dingUrl,
                                description: "钉钉机器人网络接口",
                                   optional: false,
                                       type: String),
           FastlaneCore::ConfigItem.new(key: :markdownText,
                                description: "钉钉机器人 msgtype: markdown时的text",
                                   optional: true,
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
