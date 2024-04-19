# frozen_string_literal: true
# typed: true

RSpec.describe MOSAIK::Metrics::Complexity::Parser do
  subject(:parser) { described_class.new }

  let(:file) { Tempfile.new(["ruby", ".rb"]) }

  before do
    File.write file, <<~RUBY
      # frozen_string_literal: true

      class PagesController < ApplicationController
        def index
          @posts = model.active.visible_by(current_user)

          render "pages/index/page"
        end

        def search
          @posts = model.active.visible_by(current_user).search(params[:q])
          @posts = model.some_process(@posts, current_user)
          @posts = model.another_process(@posts, current_user)

          render "pages/search/page"
        end
      end
    RUBY
  end

  it "parses a Ruby file" do
    complexities = parser.parse(file)

    expect(complexities).to eq "index" => 5.0,
                               "search" => 14.0
  end
end
