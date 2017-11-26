require 'rake'

Rails.app_class.load_tasks

class JobsRoutine
  def perform
    Rake::Task['poller:create_jobs'].reenable
    Rake::Task['poller:create_jobs'].invoke
  end
end

class MatchesRoutine
  def perform
    Rake::Task['hunter:find_matches'].reenable
    Rake::Task['hunter:find_matches'].invoke
  end
end

class NotifyUsers
  def perform
    Rake::Task['notifier:send_notifications'].reenable
    Rake::Task['notifier:send_notifications'].invoke
  end
end