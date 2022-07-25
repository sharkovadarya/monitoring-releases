class RepositoriesController < ApplicationController
  after_action :mark_everything_as_read, only: [:index, :show]

  @client = Octokit::Client.new(:access_token => ENV['PERSONAL_ACCESS_TOKEN'])

  def index
    # update_repo_tags
    @repositories = Repository.all.sort_by(&:latest_release_date).reverse!
    new
    @repositories
  end

  def show
    @repository = Repository.find(params[:id])
    Services::Monitoring.set_repo_latest_release(@repository, @client)
    @repository.save
  end

  def new
    @repository = Repository.new
  end

  def create
    @repository = Repository.new(repository_params)

    if @repository.save
      update_repo_tags
      redirect_to repositories_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @repository = Repository.find(params[:id])
    @repository.destroy

    redirect_to root_path, status: :see_other
  end

  def update_repo_tags
    Repository.all.each do |repo|
      unless repo.read
        Services::Monitoring.set_repo_latest_release(repo, @client)
        repo.save
      end
    end
  end

  private
  def repository_params
    params.require(:repository).permit(:name, :owner)
  end

  def mark_everything_as_read
    @repositories.each do |repo|
      repo.read = true
      repo.save
    end
  end
end
