namespace :notifier do

  task :send_notifications => :environment do

    puts "Notifier process starting"

    User.all.each do |user|
      unseens = user.matches.where(seen: false)
      unless unseens.empty?
        if user.subscribed

          begin #rescue NLP failure
            puts 'begin'
            h = {}
            preference = user.preferences
            h["preferences"] = preference
            h["jobs"] = {}
            matches = user.matches

            matches.each do |m|
              jobid = m.job_id
              job = Job.find_by(id: jobid)
              h["jobs"]["#{jobid}"] = {}
              h["jobs"]["#{jobid}"]["heading"] = job.heading
              h["jobs"]["#{jobid}"]["descr"] = job.descr
            end
            File.open("test.json","w") do |f|
              f.write(h.to_json)
            end

            require 'Open3'

            npl_results = []
            stdin, stdout, stderr = Open3.popen3("python nlp.py test.json 4")
            arr = []
            stdout.each do |ele|
              arr.push(ele.split().join())
            end
            id = arr[0].split(/,/).to_ary.first.tr('^0-9', '')
            job = Job.find_by(id: id)
            match = user.mtches.find_by(job_id: job.id)
          rescue
            match = unseens.last
            job = Job.find_by(id: match.job_id)
          end

          Bot.deliver({
            recipient: {
              id: user.messenger_id
            },
            message:{
              attachment:{
                type:"template",
                payload:{
                  template_type:"generic",
                  elements:[
                     {
                      title: job.heading,
                      image_url: job.export_image_url,
                      subtitle: job.descr.truncate_words(2),
                      default_action: {
                        type: "web_url",
                        url: "https://71d8cb9e.ngrok.io/jobs/#{job.id}",
                        messenger_extensions: true,
                        webview_height_ratio: "tall",
                        fallback_url: "https://71d8cb9e.ngrok.io/jobs/#{job.id}"
                      },
                      buttons:[
                        {
                          type:"web_url",
                          url:"https://71d8cb9e.ngrok.io/jobs/#{job.id}",
                          title:"View on website"
                        }
                      ]
                    }
                  ]
                }
              }
            }
          }, access_token: ENV['ACCESS_TOKEN'])
          match.update_attribute(:seen, true)
        end
      end
    end
  end
end