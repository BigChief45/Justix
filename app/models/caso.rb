class Caso < ActiveRecord::Base
    extend FriendlyId
    friendly_id :nombre, use: :slugged
    
    validates :nombre, :presence => true
    validates :num_accion, :presence => true
    
    validate :casos_count_within_limit, on: :create
    
    belongs_to :bufete
    
    has_many :caso_personas
    #has_many :personas, through: :caso_personas
    has_many :clientes, class_name: 'Cliente', through: :caso_personas, source: :persona
    has_many :contrapartes, class_name: 'Contraparte', through: :caso_personas, source: :persona
    has_many :testigos, class_name: 'Testigo', through: :caso_personas, source: :persona
    
    has_many :pruebas, dependent: :destroy
    has_many :records, dependent: :destroy
    has_many :honorarios, dependent: :destroy
    #delegate :clientes, :contrapartes, :testigos, to: :personas
    
    attr_reader :cliente_tokens
    attr_reader :testigo_tokens
    attr_reader :contraparte_tokens
    
    
    def cliente_tokens=(ids)
        self.cliente_ids = ids.split(",")
    end
    
    def testigo_tokens=(ids)
        self.testigo_ids = ids.split(",")
    end
    
    def contraparte_tokens=(ids)
        self.contraparte_ids = ids.split(",")
    end
    
    
    
    def casos_count_within_limit
        if self.bufete.casos(:reload).count >= self.bufete.user.caso_limit # self is optional
            errors.add(:base, 'Tu plan actual no te permite crear mas casos, actualiza tu plan!')
        end
    end
end
