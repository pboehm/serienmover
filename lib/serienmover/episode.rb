require 'serienrenamer'

class ::Serienrenamer::Episode
  attr_accessor :target, :action

  # Public: Sets the action that should be processed on this episode
  #
  # options  - generale options (default: {copy: false, move: false})
  #            :copy - if true than the file will be copied (higher priority)
  #            :move - if true than the file wille be moved
  def set_action(options = {})
    opt = {move: false, copy: false}.merge(options)

    if opt[:copy]
      @action = 'copy'
    elsif opt[:move]
      @action = 'move'
    end
  end

  # Public: Move/Copy the file to the target directory
  def process_action
    raise ArgumentError, "target needed" unless self.target
    raise ArgumentError, "action needed" unless
      self.action.match(/(move|copy)/i)

    FileUtils.mkdir_p(self.target.targetdir) unless
      File.directory?(self.target.targetdir)

    remote_file = File.join(self.target.targetdir,
      File.basename(self.episodepath))

    if self.action.match(/copy/i)
      FileUtils.cp(self.episodepath, self.target.targetdir)
    elsif self.action.match(/move/i)
      FileUtils.mv(self.episodepath, remote_file)
    end
  end
end
