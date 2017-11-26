class User < ApplicationRecord

  has_many :matches
  has_many :jobs, through: :matches, dependent: :destroy
  has_and_belongs_to_many :jobs

  def self.create_with_omniauth(auth, messenger_id)
    create! do |user|
      user.provider = auth['provider']
      user.uid = auth['uid']
      user.messenger_id = messenger_id
      if auth['info']
         user.name = auth['info']['name'] || ""
      end
    end
  end

  def say_hi
    deliver_first_message
  end

  def deliver_first_message
    Bot.deliver({
      recipient: {
        id: self.messenger_id
      },
      message: {
        attachment: {
          type: 'template',
          payload: {
            template_type: 'button',
            text: ANSWERS["thanks"],
            buttons: [
              { type: 'postback', title: ANSWERS["letsgo"], payload: 'NEW_CITY' },
              { type: 'postback', title: ANSWERS["nolater"], payload: 'HUMAN_NOT_LOOKING_FOR_JOB' }
            ]
          },
        }
      }
    }, access_token: ENV['ACCESS_TOKEN'])
  end

end
