class InvitationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_quiz

  def new; end

  def create
    emails  = invitation_params[:emails].to_s.split(/[,\s;]+/).map(&:strip).reject(&:blank?).uniq
    message = invitation_params[:message].to_s

    if emails.empty?
      flash.now[:alert] = "Please enter at least one email."
      render :new, status: :unprocessable_entity
      return
    end

    emails.each do |email|
      QuizInviteMailer.with(quiz: @quiz, to: email, inviter: current_user, message: message)
                      .invite.deliver_later
    end

    flash.now[:notice] = "Invites sent!"
    render :create
  end

  private
  def set_quiz
    @quiz = Quiz.find(params[:quiz_id])
  end

  def invitation_params
    params.require(:invitation).permit(:emails, :message)
  end
end
