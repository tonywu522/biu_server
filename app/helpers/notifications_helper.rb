require 'houston'
module NotificationsHelper
    # def push_match_notification(user1, user2)
    #     if !user1 && !user2
    #         return
    #     end
    #
    #     alert = I18n.t('match_push_notification_alert')
    #     payload1 = {"matched_user" => user2.to_hash}
    #     push_notification(user1.device.token, alert, payload1, category: "MATCHED", content_available: false)
    #
    #     payload2 = {"matched_user" => user1.to_hash}
    #     push_notification(user2.device.token, alert, payload2, category: "MATCHED", content_available: false)
    # end
    
    def push_match_notification(user, matched_user)
        if !user && !matched_user
            return;
        end
        
        I18n.locale = :cn
        alert = I18n.t('match_push_notification_alert')
        if (ENV['RAILS_ENV'] == 'production')
            payload = {"matched_user" => matched_user.to_hash}
        else
            payload = matched_user.to_hash
        end
        push_notification(user.device.token, alert, payload, category: "UPDATE_MATCH_INFO", content_available: false)
    end
    
    def push_matched_user_accepted_notification(user)
        if !user
            return;
        end
        I18n.locale = :cn
        alert = I18n.t('matched_user_accepted')
        Rails.logger.debug { "Send accept message to #{user.username}" }
        push_notification(user.device.token, alert, nil, category: "MATCH_ACCEPTED", content_available: false)
    end
    
    def push_matched_user_rejected_notification(user)
        if !user
            return;
        end
        I18n.locale = :cn
        alert = I18n.t('matched_user_rejected')
        Rails.logger.debug { "Send reject message to #{user.username}" }
        push_notification(user.device.token, alert, nil, category: "MATCH_REJECTED", content_available: false)
    end
    
    def push_user_close_conversation_notification(user)
        if !user
            return;
        end
        I18n.locale = :cn
        alert = I18n.t('user_close_conversation')
        Rails.logger.debug { "Send close message to #{user.username}" }
        push_notification(user.device.token, alert, nil, category: "CONVERSATION_CLOSE", content_available: false)
    end
    
    def push_message_notification(sender, receiver, type, content)
        I18n.locale = :cn
        alert = I18n.t('you_receive_new_message')
        payload = {"message" => {"from" => sender.id, "to" => receiver.id, "type" => type, "content" => content}}
        
        Rails.logger.debug { "#{Time.now}, #{sender.username} sending message to #{receiver.username}" }
        push_notification(receiver.device.token, alert, payload, category: "MESSAGE", content_available: false)
    end
    
    def push_user_start_navigation_notifiction(user)
        if !user
            return;
        end
        
        I18n.locale = :cn
        alert = I18n.t('user_start_navigation')
        Rails.logger.debug { "#{Time.now}, send start navigation message to #{user.username}" }
        push_notification(user.device.token, alert, nil, category: "START_NAVIGATION", content_available: false)
    end

    def push_user_stop_navigation_notification(user)
        if !user
            return;
        end
        
        I18n.locale = :cn
        alert = I18n.t('user_stop_navigation')
        Rails.logger.debug { "#{Time.now}, send stop navigation message to #{user.username}" }
        push_notification(user.device.token, alert, nil, category: "STOP_NAVIGATION", content_available: false)
    end
    
    def push_notification(token, alert, payload, badge: 0, sound: "sosumi.aiff", category: "MESSAGE_CATEGORY", content_available: true)
        if !token || !alert
            puts "#{Time.now}, input is null"
        end
        
        if (ENV['RAILS_ENV'] == 'production')
            apn = Houston::Client.development
            apn.certificate = File.read("/home/deploy/certification/apple_push_notification_development.pem")
        
            notification = Houston::Notification.new(device: token)
            notification.alert = alert
            notification.badge = badge
            notification.sound = sound
            notification.category = category
            notification.content_available = content_available
            notification.custom_data = payload
        
            apn.push(notification)
            Rails.logger.debug("#{Time.now}, push message success.")
        elsif (ENV['RAILS_ENV'] == 'test')
            apn = Houston::Client.development
            apn.certificate = File.read("/home/certification/apple_push_notification_development.pem")
        
            notification = Houston::Notification.new(device: token)
            notification.alert = alert
            notification.badge = badge
            notification.sound = sound
            notification.category = category
            notification.content_available = content_available
            notification.custom_data = payload
            apn.push(notification)
            
            if notification.error
                Rails.logger.debug { "#{Time.now}, Error: #{notfication.error}." }
                apn.push(notification)
            else
                Rails.logger.debug("#{Time.now}, push message success.")
            end
        else
            notification = {"aps" => {"alert" => alert, "badge" => badge, "category" => category, "content_available" => content_available},
                            "matched_user" => payload}
            command = "echo -n '#{notification.to_json}' | nc -4u -w1 192.168.1.100 9930"
            puts "#{command}"
            # system(command)
        end
        
    end
end
