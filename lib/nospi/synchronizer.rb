class Synchronizer
  INTERVALS = Project::INTERVALS
  
  def perform interval
    if INTERVALS.includes? interval
      projets = Project.where(interval: interval)
      projets.find_each |project| do
        if project.is_archive?
          pull_result = ArchivePuller.pull project
        elsif project.is_git?
          pull_result = GitPuller.pull project
        else
          pull_result = nil
        end
        
        if pull_result && log = pull_result[:log]
          if log.updated?
            GitPusher.push project, pull_result[:source_path]
          end
        end
      end
    else
      msg = "Invalid interval value provided."
      puts msg
      Rails.logger.error msg
    end
end