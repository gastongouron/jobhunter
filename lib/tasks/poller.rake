namespace :poller do

  task :create_jobs => :environment do

    puts "Polling starts"

    def get_jobs

      jobs = Net::HTTP.get(URI.parse('https://duunitori.fi/api/v1/b8a48683ae94fc9662b4220b7a87ed50f60a8cab/jobentries?format=json'))
      hash = JSON.parse(jobs)

      Job.delete_all

      while hash
        hash["results"].each do |result|
          heading = result["heading"]
          descr = result["descr"]
          sha = Digest::SHA2.hexdigest(descr)
          unless Job.find_by(sha: sha)
            job = Job.create(
              heading:           heading,
              date_posted:       result["date_posted"],
              slug:              result["slug"],
              municipality_name: result["municipality_name"],
              export_image_url:  result["export_image_url"],
              company_name:      result["company_name"],
              descr:             descr,
              latitude:          result["latitude"],
              longitude:         result["longitude"],
              area_name:         result["area_name"],
              sha:               sha
              )
          end
        end
        hash = hash["next"] ? JSON.parse(Net::HTTP.get(URI.parse(hash["next"]))) : nil
        puts "Next page!"
      end
    end

    get_jobs

  end

end
