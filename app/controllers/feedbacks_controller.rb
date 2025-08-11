class FeedbacksController < ApplicationController
  respond_to :html, :turbo_stream
  before_action :authenticate_user!
  before_action :set_quiz
  before_action :ensure_completed_quiz!, only: [ :create ]

  PAGE_SIZE = 10

  def index
    page = params.fetch(:page, 1).to_i
    scope = @quiz.feedbacks.includes(:user).order(created_at: :desc)
    @feedbacks = scope.limit(PAGE_SIZE).offset((page - 1) * PAGE_SIZE)
    @next_page = page + 1 if @feedbacks.size == PAGE_SIZE

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def create
    @feedback = @quiz.feedbacks.new(user: current_user, **feedback_params)

    if @feedback.save
      @created_feedback = @feedback
      @feedback = @quiz.feedbacks.new

      respond_to do |format|
        format.turbo_stream { flash.now[:notice] = "Paldies par atsauksmi!"; render :create }
        format.html { redirect_to @quiz, notice: "Paldies par atsauksmi!" }
      end
    else
      respond_to do |format|
        format.turbo_stream { render :create, status: :unprocessable_entity }
        format.html { redirect_to @quiz, alert: @feedback.errors.full_messages.to_sentence }
      end
    end
  end

  private

  def set_quiz
    if params[:quiz_id]
      @quiz = Quiz.find(params[:quiz_id])
    else
      @quiz = Feedback.find(params[:id]).quiz
    end
  end

  def set_feedback
    @feedback = @quiz.feedbacks.find_by!(id: params[:id], user: current_user)
  end

  def ensure_completed_quiz!
  end

  def feedback_params
    params.require(:feedback).permit(:comment)
  end
end
