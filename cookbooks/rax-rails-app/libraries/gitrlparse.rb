
class Chef
  #  extract elements from a git resource locator of the forms:
  #  git@github.com:org/repo.git
  #  git@github.com:org/repo
  #  https://github.com/org/repo.git
  #  https://github.com/org/repo
  class Gitrlparse
    def self.get_basename(git_rl)
      # split the gitrl into its path components
      if git_rl.empty?
        git_rl
      else
        git_rl_components = git_rl.split('/')

        # get rightmost gitrl component
        repo_name = git_rl_components[-1]

        # scissor off the '.git' on the end, if it's there
        repo_name.gsub(/.git$/, '')
      end
    end
  end
end
