class EvaluationsController < ApplicationController
  layout "admin"

  def index
    @evaluations = Evaluation.includes(:suite).order(:name).page(params[:page])
  end

  def show
    @evaluation = Evaluation.find(params[:id])
  end

  def new
    @suite            = Suite.find(params[:suite_id])
    @evaluation       = Evaluation.new
    @evaluation.suite = @suite
  end

  # A suite id is required, so we load it separately
  # in order to cause a 404 if it doesn't exist
  def create
    @suite      = Suite.find(params[:evaluation][:suite_id])
    @evaluation = Evaluation.new(params[:evaluation])

    if @evaluation.save
      flash[:success] = t(:"evaluations.create.success")
      redirect_to @evaluation
    else
      render action: "new"
    end
  end

  def edit
    @evaluation = Evaluation.find(params[:id])
  end

  def update
    @evaluation = Evaluation.find(params[:id])

    if @evaluation.update_attributes(params[:evaluation])
      flash[:success] = t(:"evaluations.update.success")
      redirect_to @evaluation
    else
      render action: "edit"
    end
  end

  def confirm_destroy
    @evaluation = Evaluation.find(params[:id])
  end
  def destroy
    evaluation = Evaluation.find(params[:id])
    suite = evaluation.suite
    evaluation.destroy

    flash[:success] = t(:"evaluations.destroy.success")
    redirect_to suite
  end

  def report
    @evaluation   = Evaluation.find(params[:id])
    @suite        = @evaluation.suite
    @participants = @suite.participants

    @participants.each do |participant|
      if !@evaluation.results.exists?(student_id: participant.student_id)
        @evaluation.results.build(student_id: participant.student_id)
      end
    end

    @evaluation.results.sort_by! { |r| r.student.name }
  end

  def submit_report
    @evaluation   = Evaluation.find(params[:id])
    @suite        = @evaluation.suite
    @participants = @suite.participants

    if @evaluation.update_attributes(params[:evaluation])
      flash[:success] = t(:"evaluations.submit_report.success")
      redirect_to @suite
    else
      render action: "report"
    end
  end
end