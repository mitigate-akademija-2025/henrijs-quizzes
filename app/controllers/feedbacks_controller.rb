class FeedbacksController < ApplicationController
  respond_to :html, :turbo_stream
  before_action :authenticate_user!
  before_action :set_quiz

  PAGE_SIZE = 10

  def index
    @quiz = Quiz.find(params[:quiz_id])
    @feedbacks = @quiz.feedbacks
                      .includes(:user)
                      .order(created_at: :desc)
                      .page(params[:page]).per(10)
    @next_page = @feedbacks.next_page

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

  def feedback_params
    params.require(:feedback).permit(:comment)
  end
end
