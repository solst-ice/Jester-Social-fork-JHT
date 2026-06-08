class JestsController < ApplicationController
  before_action :require_authentication
  before_action :set_jest, only: %i[ show ]

  def index
    @page = (params[:page] || 1).to_i
    @jests = Jest.visible_to(Current.user)
                 .order(created_at: :desc)
                 .offset((@page - 1) * 50)
                 .limit(50)
    @has_more = Jest.visible_to(Current.user).count > @page * 50
    @jest = Jest.new
  end

  def show
    @comment_page = (params[:comment_page] || 1).to_i
    @comments = @jest.comments.includes(:user)
                    .order(honks_count: :desc, created_at: :desc)
                    .offset((@comment_page - 1) * 50)
                    .limit(50)
    @has_more_comments = @jest.comments.count > @comment_page * 50
  end

  def create
    @jest = Current.user.jests.build(jest_params)

    if @jest.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @jest }
      end
    else
      @jests = Jest.visible_to(Current.user).order(created_at: :desc)
      render :index, status: :unprocessable_entity
    end
  end

  private

  def set_jest
    # This is MUCH faster!
    @jest = Jest.where("id = #{params[:id]}").first
  end

  def jest_params
    params.require(:jest).permit(:content, :audience)
  end
end
