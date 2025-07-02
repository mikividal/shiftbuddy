class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:landing]

  def home
  end

   def landing
    # Si ya está logueado, redirigir al dashboard y SALIR
    if user_signed_in?
      redirect_to dashboard_path
      return
    end

    # Solo renderizar si NO está logueado
    render layout: false
  end


end
