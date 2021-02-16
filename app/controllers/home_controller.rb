class HomeController < ApplicationController
  def index
    render plain: Version.all.pluck(:version)
  end
end
