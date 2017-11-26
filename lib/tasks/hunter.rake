namespace :hunter do

  task :find_matches => :environment do
    puts "Hunting process starting"
    jobs = Job.all
    User.all.each do |user|
      unless user.city.nil? && user.preferences.nil?
        jobs.each do |job|
          unless job.descr.nil? || job.heading.nil? || job.municipality_name.nil?
            city_match         = job.municipality_name.downcase.include?(user.city.downcase)
            heading_match      = job.heading.downcase.include?(user.preferences.downcase)
            description_match  = job.descr.downcase.include?(user.preferences.downcase)
            is_not_a_match_yet = user.matches.find_by(job_id: job.id).nil?
            if city_match && is_not_a_match_yet && (description_match || heading_match)
              user.matches.create(job: job)
            end
          end
        end
      end
    end
  end
end
