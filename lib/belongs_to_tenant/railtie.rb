module BelongsToTenant
  class Railtie < Rails::Railtie
    initializer 'belongs_to_tenant.model_additions' do
      ActiveSupport.on_load :active_record do
        extend ModelAdditions
      end
    end
  end
end