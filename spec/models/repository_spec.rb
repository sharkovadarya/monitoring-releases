require 'rails_helper'

describe Repository, type: :model do
  describe '.refresh' do
    context 'when repository has releases' do
      it 'sets correct latest tag' do
        initialize_repositories
        rubocop_repo = Repository.find(1)
        expect(rubocop_repo.latest_tag).to eq "v1.31.2"
      end
    end

    context 'when repository has no releases, only tags' do
      it 'sets correct latest tag' do
        initialize_repositories
        rspec_metagem_repo = Repository.find(2)
        expect(rspec_metagem_repo.latest_tag).to eq "v3.11.0"
      end
    end

    private
    def initialize_repositories
      create(:repository, name: "rubocop", owner: "rubocop")
      create(:repository, name: "rspec-metagem", owner: "rspec")
      Repository.refresh
    end
  end
end
