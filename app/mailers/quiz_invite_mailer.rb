class QuizInviteMailer < ApplicationMailer
  def invite
    @quiz = params[:quiz]
    @inviter = params[:inviter]
    @message = params[:message]
    @start_url = new_quiz_game_url(@quiz)

    mail to: params[:to], subject: "#{@inviter.username} invited you to play “#{@quiz.title}”" do |format|
        format.html { render template: "invitations/invite" }
    end
  end
end
