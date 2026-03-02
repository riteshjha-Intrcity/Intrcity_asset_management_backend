class AssetAssignmentMailer < ApplicationMailer
  default from: "no-reply@company.com"

  def assignment_email(assignment)
    @assignment = assignment
    @asset = assignment.asset

    user = User.find_by(emp_id: assignment.assigned_to)

    @confirmation_url =
      "#{ENV['FRONTEND_URL']}/confirm-assignment?token=#{assignment.confirmation_token}"

    mail(
      to: [user&.email, "admin@company.com"],
      subject: "Asset Assignment Confirmation Required"
    )
  end
end