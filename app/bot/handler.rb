# elsif parse api ohjelmoija

include Facebook::Messenger

def get_log(reply_type)
   puts "Received '#{reply_type.inspect}' from #{reply_type.sender}"
end

def get_sha(job)
  return job.sha
end

def normalize_str(str)
  return str.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/n,'').downcase.to_s
end

def get_data_from_api(city, job, reply_type, user)
  city = normalize_str(user.city.downcase)
  preferences = normalize_str(user.preferences.downcase)

  jobs = Net::HTTP.get(URI.parse("https://duunitori.fi/api/v1/b8a48683ae94fc9662b4220b7a87ed50f60a8cab/jobentries?search=&area=#{city}&tag=#{preferences}&format=json"))
  hash = JSON.parse(jobs)
  # while hash
    hash["results"].each do |result|
      heading = result["heading"]
      descr   = result["descr"]
      sha     = calculate_sha(descr)
      existing_entry = Job.find_by(sha: sha)
      unless existing_entry.blank?
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
      else
        job = existing_entry
      end
      if job
        is_not_a_match_yet = user.matches.find_by(job_id: job.id).nil?
        if is_not_a_match_yet
          @user.matches.create(job: job)
        end
      end
      # hash = hash["next"] ? JSON.parse(Net::HTTP.get(URI.parse(hash["next"]))) : nil
      # puts "Next page!"
    # end
  end
end

def show_unseen_jobs(reply_type)
  potential_jobs = []
  @user.matches.each do |match|
    unless match.seen
      job = Job.find_by(id: match.job_id)
      potential_jobs.push(job)
    else
      potential_jobs
    end
  end
  create_view(potential_jobs, reply_type)
end

def create_view(potential_jobs, reply_type)
  collection = potential_jobs.last(3).collect do |job|
    Match.find_by(job_id: job.id).update_attribute(:seen, true)
    url = job.export_image_url || "https://scontent-cdg2-1.xx.fbcdn.net/v/t1.0-9/23754745_869460746550078_4841348036297697774_n.png?oh=d10383d8d4eec7bf794b294902824408&oe=5A9634DB"
    {
      title: job.heading,
      subtitle: job.descr.truncate_words(2),
      image_url: url,
      buttons: [
        {
          title: "View",
          type: "web_url",
          url: "https://71d8cb9e.ngrok.io/jobs/#{job.id}" ,
          messenger_extensions: true,
          webview_height_ratio: "tall",
          fallback_url: "https://71d8cb9e.ngrok.io/jobs/#{job.id}"
        }
      ]
    }
  end

  unseen = Match.count - Match.where(seen: true).count
  button = []

  if unseen > 0
    button.push(
        { title: ANSWERS["more"],
          type: "postback",
          payload: "MORE_PLEASE"
        }
      )
  else
    button.push(
        { title: ANSWERS["alert"],
          type: "postback",
          payload: "KEEP_ME_UPDATED"
        }
      )
  end

  if collection.length > 1
    reply_type.reply(
      text: ANSWERS["found"]
    )
    reply_type.reply(
       attachment: {
        type: "template",
        payload: {
          template_type: "list",
          top_element_style: "compact",
          elements: collection,
           buttons: button
        }
      }
    )
  else
    say(ANSWERS["sorry"] + " #{@user.preferences} @#{@user.city}.", reply_type)
    attach_choice_button(ANSWERS["menu_action"],
                { "type" => "postback", "title" => ANSWERS["alert"], "payload" => "KEEP_ME_UPDATED" },
                { "type" => "postback", "title" => ANSWERS["preferences"], "payload" => "NEW_PREFERENCES" },
              reply_type)
  end
end

def calculate_sha(str)
 return Digest::SHA2.hexdigest(str)
end

def get_user(messenger_id)
  return User.find_by(messenger_id: messenger_id) || false
end

def set_user(messenger_id)
  @user = get_user(messenger_id)
end

def say(text, reply_type)
  return reply_type.reply( text: text)
end

def attach_button_url(action_text, btn, reply_type)
  reply_type.reply(
    attachment: {
      type: 'template',
      payload: {
        template_type: 'button',
        text: action_text,
        buttons: [
          { type: btn["type"], title: btn["title"], url: btn["url"] },
        ]
      }
    }
  )
end

def attach_choice_button(action_text, btn1, btn2, reply_type)
  return reply_type.reply(
    attachment: {
      type: 'template',
      payload: {
        template_type: 'button',
        text: action_text,
        buttons: [
          { type: btn1["type"], title: btn1["title"], payload: btn1["payload"] },
          { type: btn2["type"], title: btn2["title"], payload: btn2["payload"] }
        ]
      }
    }
  )
end

def attach_button(action_text, btn, reply_type)
  reply_type.reply(
    attachment: {
      type: 'template',
      payload: {
        template_type: 'button',
        text: ANSWERS["change"],
        buttons: [
          { type: btn["type"], title: btn["title"], payload: btn["payload"] },
        ]
      }
    }
  )
end

Bot.on :postback do |postback|

  get_log(postback)
  set_user(postback.sender["id"])

  case postback.payload

  when 'GET_STARTED_PAYLOAD'
    say(ANSWERS["hello_human"], postback)
    say(ANSWERS["thanks_human"], postback)
    attach_choice_button(ANSWERS["job"],
                        { "type" => "postback", "title" => ANSWERS["ye"], "payload" => "HUMAN_AUTHENTICATE" },
                        { "type" => "postback", "title" => ANSWERS["ne"], "payload" => "HUMAN_LOOP" },
                        postback)

  when 'HUMAN_AUTHENTICATE'
    @user = get_user(postback.sender["id"])
    unless @user
      say(ANSWERS["perfect"], postback)
      attach_button_url(ANSWERS["authenticate"],
                   { "type" => "web_url", "title" => ANSWERS["auth_action"], "url" => "https://71d8cb9e.ngrok.io/signin?messenger_id=#{postback.sender['id']}" },
                   postback)
    else
      @user.say_hi
    end

  when 'HUMAN_LOOP'
    attach_button(ANSWERS["change"],
                 { "type" => "postback", "title" => ANSWERS["changed_my_mind"], "payload" => "HUMAN_AUTHENTICATE" },
                 postback)


  when 'NEW_CITY'
    say(ANSWERS["city_choice"], postback)

  # when 'HISTORY'
  #   say('You have no history yet!', postback)

  when 'HUMAN_NOT_LOOKING_FOR_JOB'
    say(ANSWERS["sad"], postback)

  when 'MORE_PLEASE'
    collection = @user.matches.where(seen: false)
    if collection.length > 0
      show_unseen_jobs(postback)
    else
      attach_button(ANSWERS["sorry"] + " #{@user.preferences} @#{@user.city}.",
                  { "type" => "postback", "title" => ANSWERS["updated"], "payload" => "KEEP_ME_UPDATED" },
                  postback)
    end


  # menu items
  when 'HISTORY'
    if @user
      say('Your history is...', postback)
    else
      attach_button_url(ANSWERS["authenticate"],
                   { "type" => "web_url", "title" => ANSWERS["auth_action"], "url" => "https://71d8cb9e.ngrok.io/signin?messenger_id=#{postback.sender['id']}" },
                   postback)
    end

  when 'PREFERENCES'
    if @user
      if !@user.city.nil? & !@user.preferences.nil?
        say("#{@user.preferences} @#{@user.city}.", postback)
      else
        say(ANSWER["no_prefs"], postback)
      end
    else
      attach_button_url(ANSWERS["authenticate"],
                   { "type" => "web_url", "title" => ANSWERS["auth_action"], "url" => "https://71d8cb9e.ngrok.io/signin?messenger_id=#{postback.sender['id']}" },
                   postback)
    end

  when 'NEW_PREFERENCES'
    if @user
      @user.update_attribute(:preferences, nil)
      @user.update_attribute(:city, nil)
      @user.update_attribute(:require_preference, true)
      @user.matches.destroy_all
      @user.save!
      say(ANSWERS["reset"], postback)
    else
      attach_button_url(ANSWERS["authenticate"],
                   { "type" => "web_url", "title" => ANSWERS["auth_action"], "url" => "https://71d8cb9e.ngrok.io/signin?messenger_id=#{postback.sender['id']}" },
                   postback)
    end

  when 'CONTACT_INFO'
    say(ANSWERS["contact"],postback)

  when 'NO_THANKS'
    say(ANSWERS["change"])

  when 'KEEP_ME_UPDATED'
    @user.update_attribute(:subscribed, true)
    say(ANSWERS["update"], postback)
    say(ANSWERS["menu_action_2"], postback)

  else
    say(ANSWERS["sorry_2"], postback)
  end
  postback.typing_off
end

Bot.on :message do |message|
  get_log(message)
  @user ||= set_user(message.sender["id"])
  if @user
    @user.update_attribute(:require_city, false)
    if @user.require_city
      message.reply( text: ANSWERS["city_choice"])
    elsif @user.city.nil?
      message.reply( text: ANSWERS["cool"])
      @user.update_attribute(:city, message.text)
      @user.update_attribute(:require_preference, false)
      message.reply( text: ANSWERS["city_set"] + " #{@user.city}.")
      message.reply( text: ANSWERS["job_choice"])
    elsif @user.preferences.nil?
      @user.update_attribute(:preferences, message.text)
      message.reply( text: ANSWERS["set_preferences"] + " #{@user.preferences} @#{@user.city}.")
      message.reply( text: ANSWERS["begin"])
      get_data_from_api(@user.city, @user.preferences, message, @user)
      show_unseen_jobs(message)
    elsif !@user.city.nil? && !@user.preferences.nil?
      get_data_from_api(@user.city, @user.preferences, message, @user)
      show_unseen_jobs(message)
    else
      message.typing_off
    end
  else
    say(ANSWERS["non_user"], message)
    attach_button_url(ANSWERS["authenticate"],
                       { "type" => "web_url",
                         "title" => ANSWERS["auth_action"],
                         "url" => "https://71d8cb9e.ngrok.io/signin?messenger_id=#{message.sender['id']}" },
                       message)
  end
  message.typing_off
end


