require "#{Rails.root}/app/helpers/notifications_helper"
include NotificationsHelper

namespace :biu do
    desc "Matching Users"
    task :match => :environment do
        # Find user who waiting match
        matching_users = User.where(state: User::STATE_MATCHING).order(:match_distance).to_a
        if matching_users && matching_users.count > 0
            matching_users.each do |matching_user|
                prefer_users = matching_user.candidates.where(state: User::STATE_MATCHING)
                if prefer_users && prefer_users.count > 0
                    prefer_users_ids = "#{prefer_users.ids}".gsub(/\[/, "(").gsub(/\]/, ")")
                    matched_user = User.find_by_sql("SELECT *, (6378.1 * 1000 * acos(cos(radians(#{matching_user.latitude})) 
                                                                * cos(radians(latitude)) 
                                                                * cos(radians(longitude) - radians(#{matching_user.longitude})) 
                                                                + sin(radians(#{matching_user.latitude})) 
                                                                * sin(radians(latitude)))) AS distance 
                                                      FROM users 
                                                      WHERE users.id IN #{prefer_users_ids}  
                                                      HAVING distance < #{matching_user.match_distance} 
                                                      ORDER BY distance 
                                                      LIMIT 1")
                    if matched_user.count > 0
                        puts "#{Time.now}， Match successed!! user1(id: #{matching_user.id}, name: #{matching_user.username}), user2(id: #{matched_user[0].id}, name: #{matched_user[0].username})"
                        matching_user.match(matched_user[0])
                        matched_user[0].match(matching_user)
                        matching_users.delete(matching_user)
                        matching_users.delete(matched_user[0])
                    else
                        puts "#{Time.now}， There is no matched user for #{matching_user.username}"
                    end
                else
                    puts "#{Time.now}，There is no waiting matching prefer_user for #{matching_user.username}"
                end
            end
        else
            puts "#{Time.now}， No user state is matching"
        end
    end
    
    desc "Scan Users to Preferences"
    task :scan_users => :environment do
        # scan user
        users = User.all
        users.each do |user|
            # new_prefer_users = user.prefer_users
            # old_prefer_users = user.matcher
            should_unprefer_users = Array.new
            should_prefer_users = Array.new
            if user.prefer_users
                should_unprefer_users = user.candidates - user.prefer_users
                should_prefer_users = user.prefer_users - user.candidates
            else
                should_unprefer_users = user.candidates
            end
            if should_unprefer_users.count > 0
                should_unprefer_users.each do |unprefer_user|
                    user.unprefer(unprefer_user)
                end
            end
            if should_prefer_users.count > 0
                should_prefer_users.each do |prefer_user|
                     user.prefer(prefer_user)
                end
            end
        end
    end
end
