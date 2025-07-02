class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    # Casos STAT que requieren atención inmediata
    @stat_cases = current_user.cases.stat.where(study_status: [:pending, :in_progress]).limit(5)

    # Casos urgentes pendientes
    @urgent_cases = current_user.cases.urgent.where(study_status: [:pending, :in_progress]).limit(10)

    # Tareas pendientes de reportes
    @pending_reports = current_user.tasks.pending_reports.includes(:case).limit(15)

    # Casos actualmente en progreso
    @cases_in_progress = current_user.cases.in_progress.includes(:tasks)

    # Tareas vencidas
    @overdue_tasks = current_user.tasks.overdue.includes(:case)

    # Procedimientos pendientes
    @pending_procedures = current_user.tasks.procedure.pending.limit(5)

    # Estadísticas del día
    @daily_stats = calculate_daily_stats

    # Casos marcados para enseñanza y QA
    @teaching_count = current_user.tasks.marked_for_teaching.count
    @qa_count = current_user.tasks.marked_for_qa.count
  end

  def stats
    # Página detallada de estadísticas
    @weekly_stats = calculate_weekly_stats
    @modality_breakdown = calculate_modality_breakdown
    @time_performance = calculate_time_performance
  end

  private

  def calculate_daily_stats
    today = Date.current.all_day

    {
      cases_read: current_user.cases.where(updated_at: today, study_status: [:reported, :signed]).count,
      reports_completed: current_user.tasks.completed.where(updated_at: today).count,
      avg_report_time: current_user.tasks.completed
                                  .where(updated_at: today)
                                  .where.not(actual_time: nil)
                                  .average(:actual_time)&.round(1) || 0,
      pending_stat_cases: current_user.cases.stat.where(study_status: [:pending, :in_progress]).count,
      total_pending: current_user.tasks.pending.count,
      hours_worked: calculate_hours_worked_today
    }
  end

  def calculate_weekly_stats
    week_ago = 1.week.ago

    {
      total_cases: current_user.cases.where('created_at > ?', week_ago).count,
      completed_tasks: current_user.tasks.completed.where('updated_at > ?', week_ago).count,
      avg_cases_per_day: (current_user.cases.where('created_at > ?', week_ago).count / 7.0).round(1),
      teaching_cases_added: current_user.tasks.marked_for_teaching.where('updated_at > ?', week_ago).count
    }
  end

  def calculate_modality_breakdown
    modalities = current_user.cases.group(:modality).count
    total = modalities.values.sum

    modalities.transform_values { |count| ((count.to_f / total) * 100).round(1) }
  end

  def calculate_time_performance
    completed_tasks = current_user.tasks.completed.where.not(actual_time: nil, estimated_time: nil)

    return {} if completed_tasks.empty?

    {
      avg_actual_time: completed_tasks.average(:actual_time).round(1),
      avg_estimated_time: completed_tasks.average(:estimated_time).round(1),
      efficiency_ratio: (completed_tasks.average(:estimated_time) / completed_tasks.average(:actual_time)).round(2)
    }
  end

  def calculate_hours_worked_today
    today_tasks = current_user.tasks.where(updated_at: Date.current.all_day)
                             .where.not(actual_time: nil)

    (today_tasks.sum(:actual_time) / 60.0).round(1) # Convertir minutos a horas
  end
end
