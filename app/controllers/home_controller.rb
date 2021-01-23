class HomeController < ApplicationController
  def index
    render plain: 'Foo Bar'
  end
end
