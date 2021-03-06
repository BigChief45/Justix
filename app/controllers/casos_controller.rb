class CasosController < ApplicationController
    
    before_action :find_bufete
    before_action :find_caso, only: [:show, :edit, :update, :destroy]
    before_action :authenticate_user!
    
    load_and_authorize_resource :through => :bufete, param_method: :caso_params
    require 'will_paginate/array'
    
    def index
        @casos = @bufete.casos.all
        
        # Ransack
        @q = @casos.ransack(params[:q])
        @casos = @q.result.includes(:bufete, :clientes).order("created_at DESC")
        
        # Pagination
        @casos = @casos.paginate(:page => params[:page], :per_page => 10)
        @title = "Mis Casos"
    end
    
    def show
        @pruebas = @caso.pruebas.order('created_at ASC')
        @records = @caso.records.order('created_at ASC')
        
        @honorarios = @caso.honorarios.order('created_at ASC')
        @saldo = @honorarios.sum(:abono)
        
        @title = @caso.nombre
    end
    
    def new
        @caso = @bufete.casos.build
        @persona = @bufete.personas.build
        @title = "Crear Nuevo Caso"
    end
    
    def edit
        @persona = @bufete.personas.build
        @title = "Editar Caso"
    end
    
    def update
        @persona = Persona.new # Dummy instance to handle the Form Nil error
        respond_to do |format|
            if @caso.update(caso_params)
                format.html { redirect_to [@bufete,@caso], :flash => { :success => 'El caso ha sido editado exitosamente.' } }
                format.json { render :show, status: :updated, location: @caso }
            else
                format.html { render :edit, :flash => { :danger => 'Hubo un error al tratar de editar el caso.' } }
                format.json { render json: @caso.errors, status: :unprocessable_entity }
            end
        end
    end
    
    def create
        @caso = @bufete.casos.build(caso_params)
        @persona = Persona.new  # Dummy instance to handle the Form Nil error
        
        respond_to do |format|
            if @caso.save
                format.html { redirect_to bufete_caso_path(@bufete, @caso), :flash => { :success => 'El caso ha sido creado exitosamente' } }
            else
                format.html { render :action => "new", :flash => { :danger => 'Hubo un error al tratar de crear el caso.' } }
            end
        end
    end
    
    def destroy
        respond_to do |format|
            if @caso.destroy
                format.html { redirect_to @bufete, :flash => { :success => "El caso '#{@caso.nombre}' ha sido eliminado del sistema exitosamente." } }
            end
        end
    end
    
    
    private
    
        def find_bufete
           @bufete = Bufete.friendly.find(params[:bufete_id]) 
        end
    
        def find_caso
            @caso = Caso.friendly.find(params[:id])
        end
        
        def caso_params
           params.require(:caso).permit(:nombre, :num_accion, :accion, :materia, :oficina, :descripcion, :terminado, :estado, :bufete_id, :cliente_tokens, :contraparte_tokens, :testigo_tokens) 
        end
end
