class FeedbacksController < ApplicationController
  respond_to :html, :turbo_stream
  before_action :authenticate_user!
  before_action :set_quiz
  before_action :ensure_completed_quiz!, only: [ :create, :update ]
  before_action :set_feedback, only: [ :update ]

  def create
    @feedback = @quiz.feedbacks.find_or_initialize_by(user: current_user)
    @feedback.assign_attributes(feedback_params)

    if @feedback.save
      respond_to do |format|
        format.turbo_stream do
          flash.now[:notice] = "Thank you for your feedback!"
          render :create
        end
        format.html { redirect_to @quiz, notice: "Thank you for your feedback!" }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          flash.now[:alert] = @feedback.errors.full_messages.to_sentence
          render :create
        end
        format.html { redirect_to @quiz, alert: @feedback.errors.full_messages.to_sentence }
      end
    end
  end

  def update
    if @feedback.update(feedback_params)
      respond_to do |format|
        format.turbo_stream do
          flash.now[:notice] = "Your feedback has been updated."
          render :update
        end
        format.html { redirect_to @quiz, notice: "Your feedback has been updated." }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          flash.now[:alert] = @feedback.errors.full_messages.to_sentence
          render :update
        end
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
    has_finished = Game.where(quiz_id: @quiz.id, user_id: current_user.id)
                       .where.not(finished_at: nil)
                       .exists?
    unless has_finished
      redirect_to @quiz, alert: "Finish the quiz before leaving feedback." and return
    end
  end

  def feedback_params
    params.require(:feedback).permit(:comment)
  end
end
